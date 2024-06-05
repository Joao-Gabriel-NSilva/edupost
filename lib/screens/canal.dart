import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/home_page/mensagem.dart';
import 'package:intl/intl.dart';

import '../model/home_page/model_canal.dart';
import '../util/util_style.dart';

class Canal extends StatefulWidget {
  final ModelCanal canal;

  const Canal(this.canal, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CanalState();
  }
}

class CanalState extends State<Canal> {
  @override
  void initState() {
    super.initState();
    // FirebaseFirestore.instance
    //     .doc('turmas/${widget.canal.id}')
    //     .collection('mensagens')
    //     .get()
    //     .then((snap) {
    //   for (var doc in snap.docs) {
    //     var lidoPor = (doc.data()['lidoPor'] as List<dynamic>).cast<String>();
    //     var e = FirebaseAuth.instance.currentUser!.email!;
    //     if (!lidoPor.contains(e)) {
    //       lidoPor.add(e);
    //       doc.reference.update({'lidoPor': lidoPor});
    //       doc.reference.parent.parent?.update({
    //         'complemento': widget.canal.complemento
    //       }); // atualiza qualquer coisa da turma pra forçar a atualização da tela anterior
    //     }
    //   }
    // });
  }

  Future<List<Mensagem>> _getMensagens(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot) async {
    List<Mensagem> msgs = snapshot.data!.docs
        .map((m) => Mensagem.fromFirestore(
            m as DocumentSnapshot<Map<String, dynamic>>, null))
        .toList();
    for (var me in msgs) {
      await me.loadRemetente();
    }
    return msgs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: Text(widget.canal.nome),
        backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .doc('turmas/${widget.canal.id}')
            .collection('mensagens')
            .orderBy('data')
            .snapshots(),
        builder: (contex, snapshot) {
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
          if (snapshot.data!.docs.isEmpty) {
            return const Column();
          }

          return FutureBuilder(
              future: _getMensagens(snapshot),
              builder: (context, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    children: [
                      Expanded(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ))
                    ],
                  );
                }
                if (!dataSnapshot.hasData) {
                  return const Column();
                }
                return Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                      itemCount: dataSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        var msg = dataSnapshot.data![index];
                        return ListTile(
                          title: Text(msg.msg,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white)),
                          subtitle: Text(
                              '${msg.remetente?.nome} - ${DateFormat('dd/MM/yyyy H:m').format(msg.hora.toDate())}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white38)),
                        );
                      },
                    ))
                  ],
                );
              });
        },
      ),
    );
  }
}
