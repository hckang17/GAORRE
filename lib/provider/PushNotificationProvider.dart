import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final notificationManagerProvider = ChangeNotifierProvider<NotificationManager>((ref) {
  return NotificationManager();
});

class NotificationManager extends ChangeNotifier {
  bool _isNotificationEnabled = false;

  bool get isNotificationEnabled => _isNotificationEnabled;

  NotificationManager() {
    checkNotificationPermission();
  }

  Future<void> checkNotificationPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
    _isNotificationEnabled = settings.authorizationStatus == AuthorizationStatus.authorized;
    notifyListeners();
  }

  Future<void> toggleNotification() async {
    print("toggleNotification() called");
    if (_isNotificationEnabled) {
      print("Opening app settings because notifications are already enabled.");
      openAppSettings();
    } else {
      print("Requesting permission for notifications.");
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print("Permission request completed: ${settings.authorizationStatus}");
      checkNotificationPermission(); // 상태 업데이트
    }
  }
}
