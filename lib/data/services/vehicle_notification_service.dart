import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:intl/intl.dart';

/// Service for scheduling and managing vehicle expiry notifications.
///
/// Schedules 6 notifications per vehicle:
/// - WOF: 1 month before and 1 week before expiry
/// - REGO: 1 month before and 1 week before expiry
/// - Insurance: 1 month before and 1 week before expiry
///
/// All notifications are scheduled at 9:00 AM NZ time.
class VehicleNotificationService {
  VehicleNotificationService._internal();
  static final VehicleNotificationService _instance =
      VehicleNotificationService._internal();
  factory VehicleNotificationService() => _instance;

  // Constants
  static const String _notificationChannelId = 'vehicle_expiry_channel';
  static const String _notificationChannelName = 'Vehicle Expiry Notifications';
  static const String _notificationChannelDescription =
      'Notifications for vehicle registration, WOF, and insurance expiry';
  static const int _notificationHour = 9; // 9:00 AM
  static const int _notificationIdMultiplier = 100;
  static const int _wofIdOffset = 0;
  static const int _regoIdOffset = 20;
  static const int _insuranceIdOffset = 40;
  static const int _maxNotificationsPerVehicle = 60;
  static const int _maxDayForMonthEnd = 28;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Callback invoked when a notification is tapped.
  /// Receives the vehicle ID as a parameter.
  static Function(int vehicleId)? onNotificationTap;

  /// Initializes the notification service and requests permissions.
  ///
  /// Should be called once during app initialization.
  /// Only operates on iOS and Android platforms.
  Future<void> initialize() async {
    // Only initialize on mobile platforms
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Set timezone to New Zealand (all users are in NZ)
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

  /// Schedules all expiry notifications for a vehicle.
  ///
  /// Creates 6 notifications: WOF, REGO, and Insurance, each with
  /// 1-month-before and 1-week-before reminders.
  ///
  /// Notifications scheduled for past dates are sent immediately.
  /// Errors are logged but do not throw to avoid blocking vehicle creation.
  Future<void> scheduleVehicleNotifications(UserVehicle vehicle) async {
    // Only schedule on mobile platforms
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      try {
        final now = DateTime.now();

        // Schedule notifications for WOF
        await _scheduleExpiryNotifications(
          vehicle: vehicle,
          expiryDate: DateTime.parse(vehicle.wofExpiryDate),
          expiryType: 'WOF',
          notificationIdBase:
              vehicle.id * _notificationIdMultiplier + _wofIdOffset,
          now: now,
        );

        // Schedule notifications for REGO
        await _scheduleExpiryNotifications(
          vehicle: vehicle,
          expiryDate: DateTime.parse(vehicle.regoExpiryDate),
          expiryType: 'REGO',
          notificationIdBase:
              vehicle.id * _notificationIdMultiplier + _regoIdOffset,
          now: now,
        );

        // Schedule notifications for Insurance
        await _scheduleExpiryNotifications(
          vehicle: vehicle,
          expiryDate: DateTime.parse(vehicle.insuranceExpiryDate),
          expiryType: 'Insurance',
          notificationIdBase:
              vehicle.id * _notificationIdMultiplier + _insuranceIdOffset,
          now: now,
        );
      } catch (e, stackTrace) {
        // Log error but don't throw - vehicle creation should succeed even if notifications fail
        debugPrint(
            'Failed to schedule notifications for vehicle ${vehicle.id}: $e\n$stackTrace');
      }
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

    // Calculate notification dates
    final oneMonthBefore = _calculateOneMonthBefore(expiryDate);
    final oneWeekBefore = _calculateOneWeekBefore(expiryDate);

    // Schedule 1 month before notification
    await _scheduleOrSendNotification(
      id: notificationIdBase + 1,
      scheduledDate: oneMonthBefore,
      title: '$expiryType Expiring Soon',
      body: 'Your $vehicleName\'s $expiryType expires on $formattedDate',
      vehicleId: vehicle.id,
      now: now,
    );

    // Schedule 1 week before notification
    await _scheduleOrSendNotification(
      id: notificationIdBase + 2,
      scheduledDate: oneWeekBefore,
      title: '$expiryType Expiring This Week',
      body: 'Your $vehicleName\'s $expiryType expires on $formattedDate',
      vehicleId: vehicle.id,
      now: now,
    );
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
      0, // 0 minutes
    );
  }

  /// Calculates the date one week before the given date at 9:00 AM.
  DateTime _calculateOneWeekBefore(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - 7,
      _notificationHour,
      0, // 0 minutes
    );
  }

  Future<void> _scheduleOrSendNotification({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
    required int vehicleId,
    required DateTime now,
  }) async {
    final notificationDetails = _createNotificationDetails();
    final payload = vehicleId.toString();

    // If scheduled date is in the past or today, send immediately
    if (_isPastOrToday(scheduledDate, now)) {
      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } else {
      // Schedule for future
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
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
    return scheduledDate.isBefore(now) ||
        (scheduledDate.year == now.year &&
            scheduledDate.month == now.month &&
            scheduledDate.day == now.day);
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
  /// This removes all 6 notifications (WOF, REGO, Insurance × 2 each)
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
