import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/cache/theme_manager.dart';
import 'package:edupost/notification/firebase_notification.dart';
import 'package:edupost/screens/cadastros/cadastro_page.dart';
import 'package:edupost/screens/configuracoes.dart';
import 'package:edupost/screens/login.dart';
import 'package:edupost/util/util_style.dart';
import 'package:edupost/widget/home_page/item_lista_canal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/home_page/model_canal.dart';
import '../model/usuario.dart';
import '../widget/home_page/main_app_bar_widget.dart';
import 'cadastros/perfil.dart';
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
  late ThemeManager themeManager;

  @override
  void initState() {
    themeManager = ThemeManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('turmas').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: UtilStyle.instance.backGroundColor,
            appBar: MainAppBarWidget(
              true,
              usuario: widget.usuario,
            ),
            drawer: buildDrawer(context, widget.usuario),
            body: const Column(
              children: [
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: UtilStyle.instance.backGroundColor,
            appBar: MainAppBarWidget(
              true,
              usuario: widget.usuario,
            ),
            drawer: buildDrawer(context, widget.usuario),
            body: const Column(
              children: [
                Center(child: Text('Nenhuma turma cadastrada')),
              ],
            ),
          );
        }

        FirebaseNotification.instance.configuraNotificacoes(snapshot.data!.docs);

        return Scaffold(
          backgroundColor: UtilStyle.instance.backGroundColor,
          appBar: MainAppBarWidget(
            true,
            usuario: widget.usuario,
          ),
          drawer: buildDrawer(context, widget.usuario),
          floatingActionButton: FloatingActionButton(
            heroTag: 'hero${DateTime.now().second}',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (c) => const EnvioDeMsg()),
              );
            },
            backgroundColor: UtilStyle.instance.corPrimaria,
            foregroundColor: Colors.white,
            child: const Icon(
              Icons.send,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data()
                    as Map<String, dynamic>;
                    return ItemListaCanal(
                      ModelCanal(
                        data['curso'],
                        data['periodo'],
                        data['semestre'],
                        snapshot.data!.docs[index].id,
                        mensagens: [],
                        ultimaMsg: data['ultimaMsg'],
                        msgsNaoVisualidazas: 0,
                        complemento: data['complemento'],
                      ),
                      widget.usuario,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
            leading: Icon(Icons.add_card, color: UtilStyle.instance.textBackGroundColor),
            title: Text(
              'Cadastros',
              style: TextStyle(
                  color: UtilStyle.instance.textBackGroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CadastroPage()),
              );
            },
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
            leading: Icon(Icons.person, color: UtilStyle.instance.textBackGroundColor),
            title: Text(
              'Perfil',
              style: TextStyle(
                  color: UtilStyle.instance.textBackGroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Perfil(usuario)),
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