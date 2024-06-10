import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(message.notification?.title);
  print(message.notification?.body);
  print(message.data);
}

class FirebaseNotification {
  final _firebaseMessagin = FirebaseMessaging.instance;
  static final FirebaseNotification _firebaseNotification =
      FirebaseNotification._internal();

  FirebaseNotification._internal();

  static FirebaseNotification get instance {
    return _firebaseNotification;
  }

  Future<void> initNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> salvarToken(User usuario) async {
    final token = await _firebaseMessagin.getToken();
    FirebaseFirestore.instance
        .doc('usuarios/${usuario.email}')
        .update({'token': token});
  }

  void configuraNotificacoes(chatsCarregados) async {
    await _firebaseMessagin.requestPermission();
    for (var documento in chatsCarregados) {
      _firebaseMessagin.subscribeToTopic(documento.id);
    }
  }

// Future<List<String>> obterTokens(
//     DocumentReference<Map<String, dynamic>> turma) async {
//   var usuarios = await FirebaseFirestore.instance
//       .collection('usuarios')
//       .where('turma', isEqualTo: turma)
//       .get();
//   var tokens = <String>[];
//   for (var u in usuarios.docs) {
//     var data = u.data();
//     if (data['token'] != null) {
//       tokens.add(data['token']);
//     }
//   }
//   return tokens;
// }
}
