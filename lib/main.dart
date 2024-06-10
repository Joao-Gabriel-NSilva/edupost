import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/notification/firebase_notification.dart';
import 'package:edupost/screens/home_page_aluno.dart';
import 'package:edupost/screens/home_page_prof.dart';
import 'package:edupost/screens/login.dart';
import 'package:edupost/util/util_style.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'cache/theme_manager.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model/usuario.dart';

Future<Usuario> ehSuperUsuario(bool logado, User? usuario) async {
  if (logado) {
    var snap = await FirebaseFirestore.instance
        .doc('usuarios/${usuario!.email}')
        .get();
    if (snap.exists) {
      var data = snap.data()!;
      return Usuario(
          data['email'], data['nome'], data['ehSuperUsuario'], data['turma'] ?? '');
    } else {
      FirebaseFirestore.instance.collection('usuarios').add({
        'email': usuario.email,
        'nome': usuario.displayName,
        'ehSuperUsuario': false
      });
    }
  }
  return Usuario('', '', false, '');
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final noti = FirebaseNotification.instance;
  noti.initNotifications();

  var usuario = FirebaseAuth.instance.currentUser;
  var logado = usuario != null;
  var usuarioM = await ehSuperUsuario(logado, usuario);

  if (logado) {
    noti.salvarToken(usuario);
  }

  var themeManager = UtilStyle.instance.themeManager;

  runApp(App(logado, usuarioM, themeManager));
}

class App extends StatelessWidget {
  final bool logado;
  final Usuario usuario;
  final ThemeManager themeManager;

  const App(this.logado, this.usuario, this.themeManager, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeManager,
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Edupost',
            theme: themeManager.themeData,
            home: logado
                ? usuario.ehSuperUsuario
                    ? HomePageProf(usuario)
                    : HomePageAluno(usuario)
                : const Login(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
