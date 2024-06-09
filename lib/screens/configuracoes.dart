import 'package:edupost/widget/home_page/main_app_bar_widget.dart';
import 'package:flutter/material.dart';

import '../model/usuario.dart';
import '../util/util_style.dart';
import 'aparencia.dart';

class Configuracoes extends StatefulWidget {
  final Usuario usuario;

  const Configuracoes(this.usuario, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ConfiguracoesState();
  }
}

class ConfiguracoesState extends State<Configuracoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtilStyle.instance.backGroundColor,
      appBar: MainAppBarWidget(false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              title: Text(
                'Aparência',
                style: TextStyle(
                    color: UtilStyle.instance.titleColor, fontSize: 16),
              ),
              tileColor: UtilStyle.instance.tileColor,
              leading: Icon(
                Icons.palette_outlined,
                color: UtilStyle.instance.foreGroundColor,
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Aparencia()))
                    .then((tema) {
                      setState(() {

                      });
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
