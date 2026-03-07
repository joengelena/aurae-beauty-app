import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

/// Types of vehicle compliance that require expiry notifications.
///
/// Each type has a unique ID offset to prevent notification ID collisions.
/// ID offsets are spaced by 20 to allow for future expansion of notification types.
enum ExpiryType {
  wof('WOF', 0),
  rego('REGO', 20),
  insurance('Insurance', 40);

  final String displayName;
  final int idOffset;

  const ExpiryType(this.displayName, this.idOffset);
}

/// Configuration for a single expiry notification
class _ExpiryConfig {
  final ExpiryType type;
  final DateTime expiryDate;

  const _ExpiryConfig({required this.type, required this.expiryDate});
}

/// Service for scheduling and managing vehicle expiry notifications.
///
/// Schedules 15 notifications per vehicle (5 per expiry type):
/// - WOF: 1 month before, 1 week before, 1 day before, on expiry day, 1 day after
/// - REGO: 1 month before, 1 week before, 1 day before, on expiry day, 1 day after
/// - Insurance: 1 month before, 1 week before, 1 day before, on expiry day, 1 day after
///
/// All notifications are scheduled at 9:00 AM NZ time.
class VehicleNotificationService {
  VehicleNotificationService._internal();
  static final VehicleNotificationService _instance =
      VehicleNotificationService._internal();
  factory VehicleNotificationService() => _instance;

  // Notification channel configuration
  static const String _notificationChannelId = 'vehicle_expiry_channel';
  static const String _notificationChannelName = 'Vehicle Expiry Notifications';
  static const String _notificationChannelDescription =
      'Notifications for vehicle registration, WOF, and insurance expiry';

  // Notification timing
  static const int _notificationHour = 9; // 9:00 AM
  static const int _daysInOneWeek = 7;

  // Notification ID calculation
  static const int _notificationIdMultiplier = 100;
  static const int _maxNotificationsPerVehicle = 60;

  // Date calculation
  static const int _maxDayForMonthEnd = 28;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Callback invoked when a notification is tapped.
  /// Receives the vehicle ID as a parameter.
  static Function(int vehicleId)? onNotificationTap;

  /// Checks if the current platform supports notifications
  bool get _isMobilePlatform => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Initializes the notification service and requests permissions.
  ///
  /// Should be called once during app initialization.
  /// Only operates on iOS and Android platforms.
  Future<void> initialize() async {
    if (!_isMobilePlatform) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Pacific/Auckland'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Request permissions
    await _requestPermissions();
  }

  /// Handles notification tap events by invoking the registered callback.
  void _handleNotificationTap(NotificationResponse details) {
    if (details.payload != null) {
      final vehicleId = int.tryParse(details.payload!);
      if (vehicleId != null && onNotificationTap != null) {
        onNotificationTap!(vehicleId);
      }
    }
  }

  Future<void> _requestPermissions() async {
    // iOS permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android 13+ permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Requests notification permission on Android 13+ (API 33+).
  ///
  /// This permission is required to show any notifications to the user.
  /// Without it, scheduled notifications won't appear even if they're scheduled.
  ///
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;

      // Request the permission - shows system dialog
      final result = await Permission.notification.request();

      if (result.isDenied || result.isPermanentlyDenied) {
        debugPrint('Notification permission denied. Opening app settings.');
        await openAppSettings();
        return false;
      }

      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Requests SCHEDULE_EXACT_ALARM permission on Android 12+ (API 31+).
  ///
  /// This permission is required to schedule exact alarms for timely vehicle
  /// expiry notifications (WOF, registration, insurance).
  ///
  /// Opens system settings where user must manually enable the permission.
  ///
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // Check if permission is already granted
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isGranted) return true;

      // Request the permission
      // Note: On Android 12+, this opens system settings where user must manually enable
      final result = await Permission.scheduleExactAlarm.request();

      if (result.isDenied || result.isPermanentlyDenied) {
        debugPrint(
          'SCHEDULE_EXACT_ALARM permission denied. Opening app settings.',
        );
        // Open app settings for user to manually grant permission
        await openAppSettings();
        return false;
      }

      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// Schedules all expiry notifications for a vehicle.
  ///
  /// Creates 15 notifications: WOF, REGO, and Insurance, each with
  /// 1-month-before, 1-week-before, 1-day-before, on-expiry-day, and 1-day-after reminders.
  ///
  /// Notifications scheduled for past dates are sent immediately.
  /// Errors are logged but do not throw to avoid blocking vehicle creation.
  ///
  /// On Android, requires both POST_NOTIFICATIONS and SCHEDULE_EXACT_ALARM permissions.
  Future<void> scheduleVehicleNotifications(UserVehicle vehicle) async {
    if (!_isMobilePlatform) return;

    try {
      // Check and request permissions on Android
      if (Platform.isAndroid) {
        // First, request notification permission (required to show any notifications)
        final hasNotificationPermission = await requestNotificationPermission();
        if (!hasNotificationPermission) {
          debugPrint(
            'Cannot schedule notifications without notification permission. '
            'User will not receive vehicle expiry reminders.',
          );
          // Don't continue - without notification permission, there's no point scheduling
          return;
        }

        // Then request exact alarm permission (for timely delivery)
        final hasExactAlarmPermission = await requestExactAlarmPermission();
        if (!hasExactAlarmPermission) {
          debugPrint(
            'Cannot schedule exact notifications without SCHEDULE_EXACT_ALARM permission. '
            'Vehicle notifications may not be delivered at exact times.',
          );
          // Continue anyway - notifications will be scheduled but may not fire exactly
        }
      }

      final now = DateTime.now();

      // Build list of expiry configurations
      final expiryConfigs = [
        _ExpiryConfig(
          type: ExpiryType.wof,
          expiryDate: DateTime.parse(vehicle.wofExpiryDate),
        ),
        _ExpiryConfig(
          type: ExpiryType.rego,
          expiryDate: DateTime.parse(vehicle.regoExpiryDate),
        ),
        _ExpiryConfig(
          type: ExpiryType.insurance,
          expiryDate: DateTime.parse(vehicle.insuranceExpiryDate),
        ),
      ];

      // Schedule notifications for each expiry type
      for (final config in expiryConfigs) {
        await _scheduleExpiryNotifications(
          vehicle: vehicle,
          expiryDate: config.expiryDate,
          expiryType: config.type.displayName,
          notificationIdBase:
              vehicle.id * _notificationIdMultiplier + config.type.idOffset,
          now: now,
        );
      }
    } catch (e, stackTrace) {
      // Log error but don't throw - vehicle creation should succeed even if notifications fail
      debugPrint(
        'Failed to schedule notifications for vehicle ${vehicle.id}: $e\n$stackTrace',
      );
    }
  }

  Future<void> _scheduleExpiryNotifications({
    required UserVehicle vehicle,
    required DateTime expiryDate,
    required String expiryType,
    required int notificationIdBase,
    required DateTime now,
  }) async {
    final vehicleName = '${vehicle.year} ${vehicle.make} ${vehicle.model}';
    final formattedDate = DateFormat('dd MMM yyyy').format(expiryDate);

    // Define notification periods with their configurations
    final notificationPeriods = [
      (
        idOffset: 1,
        date: _calculateOneMonthBefore(expiryDate),
        title: '$expiryType Expiring Soon',
        body: 'Your $vehicleName\'s $expiryType expires on $formattedDate',
      ),
      (
        idOffset: 2,
        date: _calculateOneWeekBefore(expiryDate),
        title: '$expiryType Expiring This Week',
        body: 'Your $vehicleName\'s $expiryType expires on $formattedDate',
      ),
      (
        idOffset: 3,
        date: _calculateOneDayBefore(expiryDate),
        title: '$expiryType Expires Tomorrow',
        body: 'Your $vehicleName\'s $expiryType expires on $formattedDate',
      ),
      (
        idOffset: 4,
        date: _calculateExpiryDay(expiryDate),
        title: '$expiryType Expires Today',
        body: 'Your $vehicleName\'s $expiryType expires today! Please renew immediately.',
      ),
      (
        idOffset: 5,
        date: _calculateOneDayAfter(expiryDate),
        title: '$expiryType Expired',
        body: 'Your $vehicleName\'s $expiryType expired on $formattedDate. Renew urgently!',
      ),
    ];

    // Split notifications into past and future
    final pastNotifications = <({int id, DateTime date, String title, String body})>[];
    final futureNotifications = <({int id, DateTime date, String title, String body})>[];

    for (final period in notificationPeriods) {
      final notification = (
        id: notificationIdBase + period.idOffset,
        date: period.date,
        title: period.title,
        body: period.body,
      );

      if (_isPastOrToday(period.date, now)) {
        pastNotifications.add(notification);
      } else {
        futureNotifications.add(notification);
      }
    }

    // Send only the most recent past notification
    if (pastNotifications.isNotEmpty) {
      // Sort by date descending (most recent first)
      pastNotifications.sort((a, b) => b.date.compareTo(a.date));

      final mostRecent = pastNotifications.first;
      await _notifications.show(
        mostRecent.id,
        mostRecent.title,
        mostRecent.body,
        _createNotificationDetails(),
        payload: vehicle.id.toString(),
      );
    }

    // Schedule all future notifications
    for (final notification in futureNotifications) {
      final tzScheduledDate = tz.TZDateTime.from(notification.date, tz.local);
      await _notifications.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        tzScheduledDate,
        _createNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: vehicle.id.toString(),
      );
    }
  }

  /// Calculates the date one month before the given date at 9:00 AM.
  ///
  /// Handles year rollover (Jan -> Dec of previous year) and month-end edge cases.
  /// Days greater than 28 are capped at 28 to avoid invalid dates like Feb 30.
  DateTime _calculateOneMonthBefore(DateTime date) {
    return DateTime(
      date.month == 1 ? date.year - 1 : date.year,
      date.month == 1 ? 12 : date.month - 1,
      date.day > _maxDayForMonthEnd ? _maxDayForMonthEnd : date.day,
      _notificationHour,
      0,
    );
  }

  /// Calculates the date one week before the given date at 9:00 AM.
  DateTime _calculateOneWeekBefore(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - _daysInOneWeek,
      _notificationHour,
      0,
    );
  }

  /// Calculates the date one day before the given date at 9:00 AM.
  DateTime _calculateOneDayBefore(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - 1,
      _notificationHour,
      0,
    );
  }

  /// Calculates the given date at 9:00 AM.
  DateTime _calculateExpiryDay(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      _notificationHour,
      0,
    );
  }

  /// Calculates the date one day after the given date at 9:00 AM.
  DateTime _calculateOneDayAfter(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day + 1,
      _notificationHour,
      0,
    );
  }

  /// Creates the notification details for both Android and iOS.
  NotificationDetails _createNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Checks if the scheduled date is in the past or is today.
  bool _isPastOrToday(DateTime scheduledDate, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDay = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    return scheduleDay.isBefore(today) || scheduleDay.isAtSameMomentAs(today);
  }

  /// Reschedules all notifications for a vehicle.
  ///
  /// This is a convenience method that cancels existing notifications
  /// and schedules new ones with updated vehicle data. Errors are handled
  /// gracefully and logged without throwing to prevent blocking vehicle operations.
  ///
  /// Use this when updating a vehicle to ensure notifications reflect the latest data.
  Future<void> rescheduleNotifications(UserVehicle vehicle) async {
    try {
      await cancelVehicleNotifications(vehicle.id);
      await scheduleVehicleNotifications(vehicle);
    } catch (e) {
      // Log error but don't throw - notification failures shouldn't block vehicle updates
      debugPrint('Failed to reschedule notifications for vehicle ${vehicle.id}: $e');
    }
  }

  /// Safely cancels all notifications for a vehicle with error handling.
  ///
  /// This is a convenience method that cancels notifications and handles
  /// any errors gracefully by logging them without throwing.
  ///
  /// Use this when deleting a vehicle to ensure cleanup doesn't block the operation.
  Future<void> safelyCancelNotifications(int vehicleId) async {
    try {
      await cancelVehicleNotifications(vehicleId);
    } catch (e) {
      // Log error but don't throw - notification failures shouldn't block vehicle deletion
      debugPrint('Failed to cancel notifications for vehicle $vehicleId: $e');
    }
  }

  /// Cancels all scheduled notifications for a specific vehicle.
  ///
  /// This removes all 15 notifications (WOF, REGO, Insurance × 5 each)
  /// associated with the vehicle ID.
  Future<void> cancelVehicleNotifications(int vehicleId) async {
    final baseId = vehicleId * _notificationIdMultiplier;
    for (int i = 0; i < _maxNotificationsPerVehicle; i++) {
      await _notifications.cancel(baseId + i);
    }
  }

  /// Cancels all scheduled notifications for all vehicles.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
