import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/notification/firebase_notification.dart';
import 'package:edupost/screens/home_page_aluno.dart';
import 'package:edupost/screens/home_page_prof.dart';
import 'package:edupost/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      return Usuario(data['email'], data['nome'],
          data['ehSuperUsuario'], data['turma']);
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

  final noti =  FirebaseNotification.instance;
  noti.initNotifications();

  var usuario = FirebaseAuth.instance.currentUser;
  var logado = usuario != null;
  var usuarioM = await ehSuperUsuario(logado, usuario);

  if(logado) {
    noti.salvarToken(usuario);
  }

  runApp(App(logado, usuarioM));
}

class App extends StatelessWidget  {
  final bool logado;
  final Usuario usuario;

  const App(this.logado, this.usuario, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edupost',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
        // pageTransitionsTheme: PageTransitionsTheme(
        //   builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        //     TargetPlatform.values,
        //     value: (dynamic _) => const FadeUpwardsPageTransitionsBuilder(),
        //   ),
        // ),
      ),
      home: logado
          ? usuario.ehSuperUsuario
              ? HomePageProf(usuario)
              : HomePageAluno(usuario)
          : const Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}
