
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/widget/home_page/form_envio_de_msg_widget.dart';
import 'package:edupost/widget/home_page/main_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import '../model/home_page/arquivo.dart';
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
  List<Arquivo> _files = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: UtilStyle.instance.backGroundColor,
      appBar: MainAppBarWidget(
        false,
        titulo: 'Enviar aviso para turmas',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: ListView(
            children: [
              FormEnvioDeMsgWidget(_formKey, _controllerMsg, _selectController,
                  (arquivos) {
                _files = arquivos;
              }, key: _k),
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
                    _enviaMsg(context);
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

  void _enviaMsg(context) async {
    var temMsg = _files.isNotEmpty ||
        _formKey.currentState!.validate() &&
            _controllerMsg.text.trim().isNotEmpty;
    if (temMsg && _selectController.selectedOptions.isNotEmpty) {
      _animationButton.value = true;
      var email = FirebaseAuth.instance.currentUser!.email;
      var conteudo = _controllerMsg.text;
      try {
        var remetente = FirebaseFirestore.instance.doc('usuarios/$email');
        var nome = (await remetente.get()).data()!['nome'];
        for (var item in _selectController.selectedOptions) {
          var t = FirebaseFirestore.instance.doc('turmas/${item.value!}');

          if (conteudo.isNotEmpty) {
            await t.collection('mensagens').add({
              'conteudo': conteudo,
              'data': Timestamp.now(),
              'remetente': nome,
              'lidoPor': []
            });
            if (_files.isEmpty) {
              await FirebaseFirestore.instance
                  .doc('turmas/${item.value!}')
                  .update({'ultimaMsg': conteudo});
            }
          }

          if (_files.isNotEmpty) {
            var path = 'anexos/${item.value}/';
            for (var f in _files) {
              Reference ref =
                  FirebaseStorage.instance.ref().child(path + f.nome);
              SettableMetadata metadata = SettableMetadata(contentType: f.tipo);
              // Sobe o arquivo
              await ref.putFile(f.file, metadata);
              String url = await ref.getDownloadURL();

              await t.collection('mensagens').add({
                'conteudo': 'Anexo 📎',
                'data': Timestamp.now(),
                'remetente': nome,
                'lidoPor': [],
                'anexo': true,
                'path': path + f.nome,
                'extensao': f.tipo,
                'url': url
              });

              await FirebaseFirestore.instance
                  .doc('turmas/${item.value}')
                  .update({'ultimaMsg': 'Anexo 📎'});
            }
          }
        }

        _controllerMsg.clear();
        _selectController.clearAllSelection();
        _k.currentState!.arquivosSelecionados.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mensagem enviada com sucesso!')),
        );
      } catch (ex) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao enviar mensagem: $ex')));
      } finally {
        setState(() {
          _animationButton.value = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Informe o conteúdo da mensagem ou anexo e ao menos uma turma.')),
      );
    }
  }
}
