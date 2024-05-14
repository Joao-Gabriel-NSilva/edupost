import 'package:edupost/screens/home_page_prof.dart';
import 'package:flutter/material.dart';

import '../util/util_style.dart';
import '../widget/login/form_login_widget.dart';
import '../widget/login/head_login_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                    if (_formKey.currentState!.validate()) {
                      _animationButton.value = true;
                      try {
                        await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _controllerLogin.text,
                                password: _controllerPassword.text);
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (BuildContext contect) =>
                                    HomePageProf()), (a) => false);
                      } catch (ex) {
                        _animationButton.value = false;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 5),
                            content: Text(
                                'Falha na autenticação. Usuário ou senha incorretos.'),
                          ),
                        );
                      }
                    }
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
}
