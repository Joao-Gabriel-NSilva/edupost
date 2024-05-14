import 'package:edupost/screens/login.dart';
import 'package:edupost/util/util_style.dart';
import 'package:edupost/widget/home_page/item_lista_canal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/home_page/canal.dart';

class HomePageProf extends StatefulWidget {
  final List<Canal> _canais = [
    Canal('ESW 5', 'seguinte, segunda não tem aula', 6),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 3),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1),
    Canal('ADS 5', 'testeeee', 1)
  ];

  HomePageProf({super.key});

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
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (b) => Login()),
                        (a) => false);
                  },
                ))
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
                  itemCount: widget._canais.length,
                  itemBuilder: (context, index) {
                    return ItemListaCanal(widget._canais[index]);
                  }))
        ],
      ),
    );
  }
}
