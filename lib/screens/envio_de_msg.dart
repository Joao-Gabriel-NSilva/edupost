import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/widget/home_page/form_envio_de_msg_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import '../util/util_style.dart';

class EnvioDeMsg extends StatefulWidget {
  const EnvioDeMsg({super.key});

  @override
  State<StatefulWidget> createState() {
    return EnvioDeMsgState();
  }
}

class EnvioDeMsgState extends State<EnvioDeMsg> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerMsg = TextEditingController();
  final MultiSelectController<String> _selectController =
  MultiSelectController<String>();
  final _animationButton = ValueNotifier<bool>(false);
  final GlobalKey<FormEnvioDeMsgWidgetState> _k =
  GlobalKey<FormEnvioDeMsgWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white12,
      appBar: AppBar(
          title: const Text('Enviar aviso para turmas'),
          backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
          foregroundColor: Colors.white),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: ListView(
                children: [
                  FormEnvioDeMsgWidget(
                      _formKey, _controllerMsg, _selectController,
                      key: _k),
                  _buildButton(context)
                ],
              ))
        ],
      ),
    );
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
            onPressed: !value && !_animationButton.value
                ? () async {
              var temMsg = _formKey.currentState!.validate();
              var temTurma = _k.currentState!.validaTurmaSelecionada();
              if (temMsg && temTurma) {
                _animationButton.value = true;
                var email = FirebaseAuth.instance.currentUser!.email;
                var conteudo = _controllerMsg.text;
                try {
                  for (var item in _selectController.selectedOptions) {
                    await FirebaseFirestore.instance
                        .doc('turmas/${item.value!}')
                        .collection('mensagens')
                        .add({
                      'conteudo': conteudo,
                      'data': Timestamp.now(),
                      'remetente': FirebaseFirestore.instance
                          .doc('usuarios/$email')
                    });
                    await FirebaseFirestore.instance.doc(
                        'turmas/${item.value!}').update({'ultimaMsg': conteudo});
                  }

                  _controllerMsg.clear();
                  _selectController.clearAllSelection();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mensagens enviadas com sucesso!')),
                  );
                } catch (ex) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Falha ao enviar mensagem: $ex')));
                } finally {
                  setState(() {
                    _animationButton.value = false;
                  });
                }
              }
            }
                : null,
            child: !value
                ? const Text(
              'Enviar',
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