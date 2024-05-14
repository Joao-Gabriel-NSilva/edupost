import 'package:edupost/screens/home_page_prof.dart';
import 'package:edupost/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var logado = FirebaseAuth.instance.currentUser != null;
  FirebaseAuth.instance.authStateChanges().listen((User? u) {
    logado = u != null;
  });

  runApp(App(logado));

}

class App extends StatelessWidget {
  final bool logado;
  const App(this.logado, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edupost',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: logado ? HomePageProf() : const Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}