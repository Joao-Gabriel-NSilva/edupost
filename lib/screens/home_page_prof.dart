import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/model/home_page/mensagem.dart';
import 'package:edupost/notification/firebase_notification.dart';
import 'package:edupost/screens/login.dart';
import 'package:edupost/util/util_style.dart';
import 'package:edupost/widget/home_page/item_lista_canal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/home_page/curso.dart';
import '../model/home_page/model_canal.dart';
import '../model/usuario.dart';
import 'envio_de_msg.dart';

class HomePageProf extends StatefulWidget {
  final Usuario usuario;
  const HomePageProf(this.usuario, {super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageProfState();
  }
}

class HomePageProfState extends State<HomePageProf> {
  @override
  void initState() {
    super.initState();
  }

  // Future<List<ModelCanal>> _getDadosTurma(List<DocumentSnapshot> turmas) async {
  //   List<ModelCanal> lista = [];
  //   for (var snapshot in turmas) {
  //     var data = snapshot.data() as Map<String, dynamic>;
  //     var mens = await snapshot.reference
  //         .collection('mensagens')
  //         .orderBy('data')
  //         .get();
  //     // List<Mensagem> msgs = [];
  //     var naoLidasCount = 0;
  //     if (mens.docs.isNotEmpty) {
  //       for (var m in mens.docs
  //           .map((m) => Mensagem.fromFirestore(
  //               m as DocumentSnapshot<Map<String, dynamic>>, null))
  //           .toList()) {
  //         if (m.lidoPor != null &&
  //             !m.lidoPor!.contains(FirebaseAuth.instance.currentUser!.email)) {
  //           naoLidasCount++;
  //         }
  //         // await m.loadRemetente();
  //       }
  //     }
  //
  //     var canal = ModelCanal(
  //         data['curso'], data['periodo'], data['semestre'], snapshot.id,
  //         mensagens: [],
  //         ultimaMsg: data['ultimaMsg'],
  //         msgsNaoVisualidazas: naoLidasCount,
  //         complemento: data['complemento']);
  //     lista.add(canal);
  //   }
  //   return lista;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: const Text('EduPost'),
        backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            onSelected: (a) {},
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Configurações'),
                  ),
                ),
                PopupMenuItem(
                    child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sair'),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (b) => const Login()),
                        (a) => false);
                  },
                ))
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (c) => const EnvioDeMsg()));
        },
        backgroundColor: UtilStyle.instance.corPrimaria,
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.send,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('turmas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData) {
            return const Column(
              children: [
                Expanded(
                    child: Center(
                  child: CircularProgressIndicator(),
                ))
              ],
            );
          }

          // FirebaseNotification.instance.configuraNotificacoes(snapshot.data!.docs);

          return Column(
            children: [
              Expanded(
                  child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return ItemListaCanal(ModelCanal(
                      data['curso'],
                      data['periodo'],
                      data['semestre'],
                      snapshot.data!.docs[index].id,
                      mensagens: [],
                      ultimaMsg: data['ultimaMsg'],
                      msgsNaoVisualidazas: 0,
                      complemento: data['complemento']), true);
                },
              ))
            ],
          );
        },
      ),
    );
  }
}
