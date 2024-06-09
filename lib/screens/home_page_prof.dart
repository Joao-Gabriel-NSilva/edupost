import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/cache/theme_manager.dart';
import 'package:edupost/notification/firebase_notification.dart';
import 'package:edupost/util/util_style.dart';
import 'package:edupost/widget/home_page/item_lista_canal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/home_page/model_canal.dart';
import '../model/usuario.dart';
import '../widget/home_page/main_app_bar_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManager.instance,
      child: Consumer<ThemeManager>(builder: (context, themeManager, child) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('turmas').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                children: [
                  Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ))
                ],
              );
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

            return Scaffold(
                backgroundColor: UtilStyle.instance.backGroundColor,
                appBar: MainAppBarWidget(usuario: widget.usuario, true),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (c) => const EnvioDeMsg()));
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
                                ModelCanal(data['curso'], data['periodo'],
                                    data['semestre'], snapshot.data!.docs[index].id,
                                    mensagens: [],
                                    ultimaMsg: data['ultimaMsg'],
                                    msgsNaoVisualidazas: 0,
                                    complemento: data['complemento']),
                                true);
                          },
                        ))
                  ],
                ));
          },
        );
      }),
    );

  }
}
