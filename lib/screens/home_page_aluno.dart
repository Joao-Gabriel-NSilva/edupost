import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/screens/login.dart';
import 'package:edupost/util/util_style.dart';
import 'package:edupost/widget/home_page/item_lista_canal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/home_page/model_canal.dart';
import '../model/usuario.dart';

class HomePageAluno extends StatefulWidget {
  final Usuario usuario;

  const HomePageAluno(this.usuario, {super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageAlunoState();
  }
}

class HomePageAlunoState extends State<HomePageAluno> {
  @override
  void initState() {
    super.initState();
  }

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
                  onTap: () async {
                    _signout(context);
                  },
                ))
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('turmas')
            .doc(widget.usuario.turma)
            .snapshots(),
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
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              ItemListaCanal(
                  ModelCanal(data['curso'], data['periodo'], data['semestre'],
                      snapshot.data!.id,
                      mensagens: [],
                      ultimaMsg: data['ultimaMsg'],
                      msgsNaoVisualidazas: 0,
                      complemento: data['complemento']),
                  false),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (b) => const Login()),
            (a) => false);
  }
}
