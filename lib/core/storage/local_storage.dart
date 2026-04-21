import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/auth_user.dart';

class LocalStorage {
  LocalStorage._();

  static const String boxName = 'pulse_app';
  static const String watchlistKey = 'watchlist_ids';
  static const String recentlyViewedKey = 'recently_viewed_stock_ids';
  static const String currentUserKey = 'current_auth_user';
  static const String authUsersKey = 'auth_users';
  static const String appThemeModeKey = 'app_theme_mode';

  static const List<String> defaultWatchlist = ['aapl', 'tsla', 'nvda', 'msft'];
  static const List<String> defaultRecentlyViewed = [];

  static List<String> loadWatchlist() {
    if (!Hive.isBoxOpen(boxName)) {
      return List<String>.from(defaultWatchlist);
    }

    final dynamic raw = Hive.box(boxName).get(watchlistKey);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }

    return List<String>.from(defaultWatchlist);
  }

  static Future<void> saveWatchlist(List<String> ids) async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box(boxName).put(watchlistKey, ids);
  }

  static List<String> loadRecentlyViewed() {
    if (!Hive.isBoxOpen(boxName)) {
      return List<String>.from(defaultRecentlyViewed);
    }

    final dynamic raw = Hive.box(boxName).get(recentlyViewedKey);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }

    return List<String>.from(defaultRecentlyViewed);
  }

  static Future<void> saveRecentlyViewed(List<String> ids) async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box(boxName).put(recentlyViewedKey, ids);
  }

  static AuthUser? loadCurrentUser() {
    if (!Hive.isBoxOpen(boxName)) return null;

    final dynamic raw = Hive.box(boxName).get(currentUserKey);
    if (raw is Map) {
      return AuthUser.fromMap(Map<String, dynamic>.from(raw));
    }

    return null;
  }

  static Future<void> saveCurrentUser(AuthUser user) async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box(boxName).put(currentUserKey, user.toMap());
  }

  static Future<void> clearCurrentUser() async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box(boxName).delete(currentUserKey);
  }

  static List<Map<String, dynamic>> loadAuthUsers() {
    if (!Hive.isBoxOpen(boxName)) return <Map<String, dynamic>>[];

    final dynamic raw = Hive.box(boxName).get(authUsersKey);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  static Future<void> saveAuthUsers(List<Map<String, dynamic>> users) async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box(boxName).put(authUsersKey, users);
  }

  static String? loadThemeModeName() {
    if (!Hive.isBoxOpen(boxName)) return null;
    return Hive.box(boxName).get(appThemeModeKey)?.toString();
  }

  static Future<void> saveThemeModeName(String modeName) async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box(boxName).put(appThemeModeKey, modeName);
  }
}
