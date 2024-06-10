import 'package:edupost/model/usuario.dart';
import 'package:edupost/screens/home_page_prof.dart';
import 'package:flutter/material.dart';

import '../util/util_style.dart';
import '../widget/login/form_login_widget.dart';
import '../widget/login/head_login_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page_aluno.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  final TextEditingController _controllerLogin = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _animationButton = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: ListView(
              children: [
                const HeadLoginWidget(),
                FormLoginWidget(
                    _formKey, _controllerLogin, _controllerPassword),
                _buildButton(context),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: InkWell(
                  child: Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: Colors.blueAccent.shade100),
                  ),
                  onTap: () async {
                    _recuperarSenha(context);
                  },
                )),
              ],
            ))
          ],
        ));
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: ValueListenableBuilder<bool>(
        valueListenable: _animationButton,
        builder: (context, value, child) {
          return TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.white70),
              backgroundColor:
                  WidgetStateProperty.all(UtilStyle.instance.corPrimaria),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: UtilStyle.instance.corPrimaria,
                    width: 2.0, // Tamanho da borda
                  ),
                ),
              ),
            ),
            onPressed: !value
                ? () async {
                    _auth(context);
                  }
                : null,
            child: !value
                ? const Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> _auth(context) async {
    if (_formKey.currentState!.validate()) {
      _animationButton.value = true;
      try {
        var credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _controllerLogin.text, password: _controllerPassword.text);

        var usuario = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(credential.user!.email)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            var data = documentSnapshot.data()! as Map<String, dynamic>;
            return Usuario(data['email'], data['nome'], data['ehSuperUsuario'],
                data['turma']);
          }
          return null;
        });

        if (usuario != null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext contect) => usuario.ehSuperUsuario
                      ? HomePageProf(usuario)
                      : HomePageAluno(usuario)),
              (a) => false);
        }
      } catch (ex) {
        _animationButton.value = false;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content:
                Text('Falha na autenticação. Usuário ou senha incorretos.'),
          ),
        );
      }
    }
  }

  Future<void> _recuperarSenha(context) async {
    if (_controllerLogin.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text(
              'Informe o seu email, um link para redefinição de senha será enviado.'),
        ),
      );
    } else {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _controllerLogin.text);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
                'Email enviado.'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if(e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 5),
              content: Text(
                  'Email inválido. Informe um email válido e tente novamente.'),
            ),
          );
        }
        if(e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 5),
              content: Text(
                  'Usuário não encontrado.'),
            ),
          );
        }
      }
    }
  }
}
