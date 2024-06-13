import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/widget/home_page/main_app_bar_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/home_page/mensagem.dart';
import 'package:intl/intl.dart';

import '../model/home_page/model_canal.dart';
import '../util/util_style.dart';

class Canal extends StatefulWidget {
  final ModelCanal canal;
  final bool ehAdm;
  final TextEditingController _controller = TextEditingController();

  Canal(this.canal, this.ehAdm, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CanalState();
  }
}

class CanalState extends State<Canal> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .doc('turmas/${widget.canal.id}')
          .collection('mensagens')
          .orderBy('data')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              backgroundColor: UtilStyle.instance.backGroundColor,
              appBar: MainAppBarWidget(
                false,
                titulo: widget.canal.nome,
              ),
              body: const Column(
                children: [
                  Expanded(
                      child: Center(
                    child: CircularProgressIndicator(),
                  ))
                ],
              ));
        }

        if (!snapshot.hasData) {
          return Scaffold(
              backgroundColor: UtilStyle.instance.backGroundColor,
              appBar: MainAppBarWidget(
                false,
                titulo: widget.canal.nome,
              ),
              body: const Column(
                children: [
                  Expanded(
                      child: Center(
                    child: CircularProgressIndicator(),
                  ))
                ],
              ));
        }

        if (snapshot.data!.docs.isEmpty) {
          return Scaffold(
            backgroundColor: UtilStyle.instance.backGroundColor,
            appBar: MainAppBarWidget(
              false,
              titulo: widget.canal.nome,
            ),
            body: Column(
              children: [
                const Expanded(child: Column()),
                if (widget.ehAdm) _buildTextField()
              ],
            ),
          );
        }

        List<Mensagem> msgs = snapshot.data!.docs
            .map((m) => Mensagem.fromFirestore(
                m as DocumentSnapshot<Map<String, dynamic>>, null))
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return Scaffold(
            backgroundColor: UtilStyle.instance.backGroundColor,
            appBar: MainAppBarWidget(
              false,
              titulo: widget.canal.nome,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      var msg = msgs[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 6.0, right: 4, left: 4),
                        child: msg.anexo == null || !msg.anexo!
                            ? _buildListTileMsg(msg)
                            : _buildListTileAnexo(msg),
                      );
                    },
                  ),
                ),
                if (widget.ehAdm) _buildTextField()
              ],
            ));
      },
    );
  }

  Widget _buildListTileMsg(msg) {
    return ListTile(
      title: Text(msg.msg,
          style: TextStyle(fontSize: 16, color: UtilStyle.instance.titleColor)),
      subtitle: Text(
          '${msg.remetente} - ${DateFormat('dd/MM/yyyy HH:mm').format(msg.hora.toDate())}',
          style:
              TextStyle(fontSize: 16, color: UtilStyle.instance.subTitleColor)),
      tileColor: UtilStyle.instance.tileColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: UtilStyle.instance.corPrimaria, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
    );
  }

  Widget _buildListTileAnexo(Mensagem msg) {
    return msg.extensao!.contains('image')
        ? ListTile(
            title: SizedBox(
              // height: 300,
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/loading.gif', // ou outra imagem de placeholder
                image: msg.url!,
                fit: BoxFit.fill,
              ),
            ),
            subtitle: Text(
                '${msg.remetente} - ${DateFormat('dd/MM/yyyy HH:mm').format(msg.hora.toDate())}',
                style: TextStyle(
                    fontSize: 16, color: UtilStyle.instance.subTitleColor)),
            tileColor: UtilStyle.instance.tileColor,
            shape: RoundedRectangleBorder(
                side:
                    BorderSide(color: UtilStyle.instance.corPrimaria, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
          )
        : FutureBuilder(
            future: canLaunchUrl(Uri.parse(msg.url!)),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Column(
                  children: [
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
                );
              }
              var titulo = 'Baixar anexo';
              if (msg.extensao!.contains('pdf')) {
                titulo = 'Baixar pdf';
              }
              if (msg.extensao!.contains('video')) {
                titulo = 'Baixar vídeo';
              }
              //launchUrl(Uri.parse(msg.url!));
              return ListTile(
                title: Text(titulo),
                subtitle: Text(
                    '${msg.remetente} - ${DateFormat('dd/MM/yyyy HH:mm').format(msg.hora.toDate())}',
                    style: TextStyle(
                        fontSize: 16, color: UtilStyle.instance.subTitleColor)),
                tileColor: UtilStyle.instance.tileColor,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: UtilStyle.instance.corPrimaria, width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                trailing: IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () => launchUrl(Uri.parse(msg.url!)),
                ),
              );
            });
  }

  Future<void> _enviaMsg(context) async {
    if (widget._controller.text.isNotEmpty) {
      var email = FirebaseAuth.instance.currentUser!.email;
      var conteudo = widget._controller.text;

      widget._controller.clear();

      var remetente = FirebaseFirestore.instance.doc('usuarios/$email');
      var nome = (await remetente.get()).data()!['nome'];
      var t = FirebaseFirestore.instance.doc('turmas/${widget.canal.id}');

      await t.collection('mensagens').add({
        'conteudo': conteudo,
        'data': Timestamp.now(),
        'remetente': nome,
        'lidoPor': []
      });

      await FirebaseFirestore.instance
          .doc('turmas/${widget.canal.id}')
          .update({'ultimaMsg': conteudo});
    }
  }

  Future<void> _enviaMsgAnexo(path, extensao, url) async {
    var email = FirebaseAuth.instance.currentUser!.email;

    widget._controller.clear();

    var remetente = FirebaseFirestore.instance.doc('usuarios/$email');
    var nome = (await remetente.get()).data()!['nome'];
    var t = FirebaseFirestore.instance.doc('turmas/${widget.canal.id}');

    await t.collection('mensagens').add({
      'conteudo': 'Anexo 📎',
      'data': Timestamp.now(),
      'remetente': nome,
      'lidoPor': [],
      'anexo': true,
      'path': path,
      'extensao': extensao,
      'url': url
    });

    await FirebaseFirestore.instance
        .doc('turmas/${widget.canal.id}')
        .update({'ultimaMsg': 'Anexo 📎'});
  }

  TextStyle _labelTextStyle() {
    return const TextStyle(
      fontSize: 13,
      color: Colors.grey,
    );
  }

  InputBorder _focusBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
            color: UtilStyle.instance.textFieldBackGroundColor,
            border: Border.all(
              color: UtilStyle.instance.corPrimaria,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: TextField(
                  controller: widget._controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(color: UtilStyle.instance.foreGroundColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelStyle: _labelTextStyle(),
                    focusedBorder: _focusBorder(),
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () => uploadFile(context),
                icon: const Icon(Icons.attach_file)),
            // IconButton(onPressed: () => getFileMetadata(), icon: const Icon(Icons.download)),
            IconButton(
              onPressed: () => _enviaMsg(context),
              icon: Icon(
                Icons.send,
                color: UtilStyle.instance.foreGroundColor,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getMimeType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType ?? 'application/octet-stream';
  }

  Future<void> uploadFile(context) async {
    // Seleciona o arquivo
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      File file = File(filePath);
      String mimeType = getMimeType(filePath);

      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enviando anexo...'),
          duration: Duration(seconds: 3),
        ));
        // Cria uma referência no Firebase Storage
        var path = 'anexos/${widget.canal.id}/${result.files.single.name}';
        Reference ref = FirebaseStorage.instance.ref().child(path);
        SettableMetadata metadata = SettableMetadata(contentType: mimeType);
        // Sobe o arquivo
        await ref.putFile(file, metadata);
        String url = await ref.getDownloadURL();
        await _enviaMsgAnexo(path, mimeType, url);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Anexo enviado.')));
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Falha ao enviar anexo: $e')));
      }
    } else {}
  }

  Future<void> getFileMetadata() async {
    try {
      // Cria uma referência para o arquivo no Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('anexos/${widget.canal.id}/IMG-20240609-WA0002.jpg');
      // Obtém os metadados do arquivo
      FullMetadata metadata = await ref.getMetadata();
      String mimeType = metadata.contentType ?? 'Unknown';
      print('Tipo de arquivo: $mimeType');
    } catch (e) {
      print('Erro ao obter os metadados do arquivo: $e');
    }
  }
}
