import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../../model/usuario.dart';
import '../../util/util_style.dart';
import '../../widget/home_page/main_app_bar_widget.dart';

class Perfil extends StatefulWidget {
  final Usuario usuario;

  const Perfil(this.usuario, {key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PerfilState();
  }
}

class PerfilState extends State<Perfil> {
  String getMimeType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType ?? 'application/octet-stream';
  }

  void uploadFile(context) async {
    // Seleciona o arquivo
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (result != null) {
      var name = result.files.single.name;
      var f = result.files.single.path!;
      File file = File(f);
      String mimeType = getMimeType(f);
      var path = 'perfil/${widget.usuario.email}/$name';
      Reference ref = FirebaseStorage.instance.ref().child(path);
      SettableMetadata metadata = SettableMetadata(contentType: mimeType);
      // Sobe o arquivo
      await ref.putFile(file, metadata);
      String url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.usuario.email).update({'urlFoto': url});
      setState(() {
        widget.usuario.urlFoto = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtilStyle.instance.backGroundColor,
      appBar: MainAppBarWidget(false),
      body: Column(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => uploadFile(context),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: widget.usuario.urlFoto != null
                        ? NetworkImage(widget.usuario.urlFoto!)
                        : null,
                    child: widget.usuario.urlFoto == null
                        ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Toque na imagem para alterar a foto',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
