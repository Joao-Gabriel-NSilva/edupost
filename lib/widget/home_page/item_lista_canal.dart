import 'package:flutter/material.dart';

import '../../model/home_page/canal.dart';


class ItemListaCanal extends StatelessWidget {
  final Canal canal;

  const ItemListaCanal(this.canal, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          tileColor: Colors.black26,
          title: Text(
            canal.nome,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          subtitle: Text(
            canal.ultimaMsg,
            style: const TextStyle(color: Colors.white38),
          ),
          trailing: Badge(
            label: Text(canal.msgsNaoVisualidazas.toString()),
            textStyle: const TextStyle(fontSize: 14),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          ),
          onTap: () {

          },
        ));
  }
}
