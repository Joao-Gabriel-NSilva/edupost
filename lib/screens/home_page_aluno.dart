import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/screens/configuracoes.dart';
import 'package:edupost/screens/login.dart';
import 'package:edupost/util/util_style.dart';
import 'package:edupost/widget/home_page/item_lista_canal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/home_page/model_canal.dart';
import '../model/usuario.dart';
import '../notification/firebase_notification.dart';
import '../widget/home_page/main_app_bar_widget.dart';
import 'canal.dart';

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
      backgroundColor: UtilStyle.instance.backGroundColor,
      appBar: MainAppBarWidget(usuario:widget.usuario, true),
      drawer: buildDrawer(context, widget.usuario),
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

          FirebaseNotification.instance.configuraNotificacoes([snapshot.data!]);



          var data = snapshot.data!.data() as Map<String, dynamic>;

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => Canal(ModelCanal(data['curso'], data['periodo'], data['semestre'],
                snapshot.data!.id,
                mensagens: [],
                ultimaMsg: data['ultimaMsg'],
                msgsNaoVisualidazas: 0,
                complemento: data['complemento']), widget.usuario)));
          },);
          return Column(
            children: [
              ItemListaCanal(
                  ModelCanal(data['curso'], data['periodo'], data['semestre'],
                      snapshot.data!.id,
                      mensagens: [],
                      ultimaMsg: data['ultimaMsg'],
                      msgsNaoVisualidazas: 0,
                      complemento: data['complemento']),
                  widget.usuario),
            ],
          );
        },
      ),
    );
  }

  Drawer buildDrawer(BuildContext context, Usuario usuario) {
    return Drawer(
      backgroundColor: UtilStyle.instance.backGroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 80,
            color: UtilStyle.instance.corPrimaria,
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              'MENU',
              style: TextStyle(
                color: UtilStyle.instance.textBackGroundColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: UtilStyle.instance.textBackGroundColor),
            title: Text(
              'Configurações',
              style: TextStyle(
                  color: UtilStyle.instance.textBackGroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Configuracoes(usuario)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: UtilStyle.instance.textBackGroundColor),
            title: Text(
              'Sair',
              style: TextStyle(
                  color: UtilStyle.instance.textBackGroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (b) => const Login()),
                    (a) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
