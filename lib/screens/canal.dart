import 'package:flutter/material.dart';
import '../model/home_page/mensagem.dart';
import 'package:intl/intl.dart';

import '../util/util_style.dart';

class Canal extends StatefulWidget {
  final String nome;
  List<Mensagem> msgs;

  Canal(this.nome, this.msgs, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CanalState();
  }
}

class CanalState extends State<Canal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: Text(widget.nome),
        backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: widget.msgs.length,
                itemBuilder: (context, index) {
                  var msg = widget.msgs[index];
                  return ListTile(
                    title: Text(msg.msg,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
                    subtitle: Text(
                        '${msg.remetente?.nome} - ${DateFormat('dd/MM/yyyy H:m').format(msg.hora.toDate())}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white38)),
                  );
                }),
          )
        ],
      ),
    );
  }
}
