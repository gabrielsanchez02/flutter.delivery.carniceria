import 'package:firebase_messaging/firebase_messaging.dart';

class pushNotifProvider {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  initNotifications() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token) {
      final tokenStr = token.toString();
      print(":::::FNP ${tokenStr} ");
      // do whatever you want with the token here
    });
  }
}
