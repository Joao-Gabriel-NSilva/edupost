import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/widget/home_page/main_app_bar_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/home_page/arquivo.dart';
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
  final List<String> extensoesPermitidas = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'svg',
    'pdf',
    'doc',
    'docx',
    'odt',
    'txt',
    'rtf',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'mp4',
    'avi',
    'mkv',
  ];

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_scrollController.hasClients) {
    //     _scrollController
    //         .jumpTo(_scrollController.position.extentTotal);
    //     Future.delayed(const Duration(milliseconds: 1500), () {
    //       _scrollController
    //           .jumpTo(_scrollController.position.maxScrollExtent);
    //     },);
    //
    //   }
    // });
  }

  List<Arquivo> _files = [];

  void _removeFile(Arquivo arq) {
    setState(() {
      _files.remove(arq);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .doc('turmas/${widget.canal.id}')
          .collection('mensagens')
          .orderBy('data', descending: true)
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
                    reverse: true,
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
                if (_files.isNotEmpty) SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _files.map((arquivo) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Chip(
                          color: const WidgetStatePropertyAll(Colors.grey),
                          deleteIconColor: UtilStyle.instance.foreGroundColor,
                          labelStyle: TextStyle(
                              color: UtilStyle.instance.foreGroundColor),
                          label: Text(arquivo.nome),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            _removeFile(arquivo);
                          },
                        ),
                      );
                    }).toList(),
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
                placeholder:
                    'assets/loading.gif', // ou outra imagem de placeholder
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
                  icon: const Icon(Icons.download),
                  onPressed: () => launchUrl(Uri.parse(msg.url!)),
                ),
              );
            });
  }

  Future<void> _enviaMsg(context) async {
    if (widget._controller.text.isNotEmpty || _files.isNotEmpty) {
      var email = FirebaseAuth.instance.currentUser!.email;
      var conteudo = widget._controller.text;
      var arquivosSelecionados = List.from(_files);

      widget._controller.clear();
      setState(() {
        _files.clear();
      });

      var remetente = FirebaseFirestore.instance.doc('usuarios/$email');
      var nome = (await remetente.get()).data()!['nome'];
      var t = FirebaseFirestore.instance.doc('turmas/${widget.canal.id}');

      if(conteudo.isNotEmpty) {
        await t.collection('mensagens').add({
          'conteudo': conteudo,
          'data': Timestamp.now(),
          'remetente': nome,
          'lidoPor': []
        });
        if(arquivosSelecionados.isEmpty) {
          await FirebaseFirestore.instance
              .doc('turmas/${widget.canal.id}')
              .update({'ultimaMsg': conteudo});
        }
      }

      if(arquivosSelecionados.isNotEmpty) {
        var path = 'anexos/${widget.canal.id}/';
        for(var f in arquivosSelecionados) {
          Reference ref = FirebaseStorage.instance.ref().child(path + f.nome);
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
              .doc('turmas/${widget.canal.id}')
              .update({'ultimaMsg': 'Anexo 📎'});
        }
      }


    }
  }

  Future<void> _enviaMsgAnexo(path, extensao, url) async {
    var email = FirebaseAuth.instance.currentUser!.email;

    widget._controller.clear();

    var remetente = FirebaseFirestore.instance.doc('usuarios/$email');
    var nome = (await remetente.get()).data()!['nome'];
    var t = FirebaseFirestore.instance.doc('turmas/${widget.canal.id}');



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
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, allowedExtensions: extensoesPermitidas, type: FileType.custom);

    if (result != null) {
      var files = result.files;
      for(var arq in files) {
        File file = File(arq.path!);
        String mimeType = getMimeType(arq.path!);
        var a = Arquivo(arq.name, '', mimeType, file);
        _files.add(a);
      }
      setState(() {
      });
    }
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
