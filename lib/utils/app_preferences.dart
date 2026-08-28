import 'package:hive_flutter/hive_flutter.dart';

/// Small, local UI preferences — the choices a person makes about how they want
/// to look at their own data, remembered between visits.
///
/// Deliberately its own Hive box rather than a corner of the HTTP cache: that
/// box is cleared whenever a write invalidates a cache key, which would quietly
/// reset preferences every time an owner edited a dress.
///
/// Reads are synchronous so a widget can pick a layout in its first build with
/// no flash of the wrong one, which means [initialize] must run at startup
/// before anything reads from here.
class AppPreferences {
  static const String _boxName = 'app_preferences';
  static const String _wardrobeViewModeKey = 'wardrobe_view_mode';

  static Box? _box;

  static Future<void> initialize() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
  }

  /// 'cards' or 'list'. Null when never set, so the caller keeps its default
  /// rather than this file having an opinion about which view is right.
  static String? get wardrobeViewMode {
    final box = _box;
    if (box == null || !box.isOpen) return null;
    final value = box.get(_wardrobeViewModeKey);
    return value is String ? value : null;
  }

  static Future<void> setWardrobeViewMode(String mode) async {
    final box = _box;
    if (box == null || !box.isOpen) return;
    await box.put(_wardrobeViewModeKey, mode);
  }
}
