import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../model/home_page/mensagem.dart';
import 'package:intl/intl.dart';

import '../model/home_page/model_canal.dart';
import '../util/util_style.dart';

class Canal extends StatefulWidget {
  final ModelCanal canal;
  final bool ehAdm;
  final TextEditingController _controller = TextEditingController();

  Canal(this.canal, this.ehAdm, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CanalState();
  }
}

class CanalState extends State<Canal> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: dataSnapshot.data!.length,
                        itemBuilder: (context, index) {
                          var msg = dataSnapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 6.0, right: 4, left: 4),
                            child: ListTile(
                              title: Text(msg.msg,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              subtitle: Text(
                                  '${msg.remetente?.nome} - ${DateFormat('dd/MM/yyyy H:m').format(msg.hora.toDate())}',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white38)),
                              tileColor: Colors.black26,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          );
                        },
                      ),
                    ),
                    if(widget.ehAdm) Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black38, border: Border.all(color: UtilStyle.instance.corPrimaria, width: 0.5)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 0, top: 0, bottom: 0, right: 0),
                                child: Expanded(
                                  child: TextField(
                                    controller: widget._controller,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelStyle: _labelTextStyle(),
                                      focusedBorder: _focusBorder(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                  onPressed: () => _enviaMsg(context),
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 36,
                                  )),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                );
              });
        },
      ),
    );
  }

  Future<void> _enviaMsg(context) async {
    if (widget._controller.text.isNotEmpty) {
      var email = FirebaseAuth.instance.currentUser!.email;
      var conteudo = widget._controller.text;
      var remetente = FirebaseFirestore.instance.doc('usuarios/$email');
      // var nome = (await remetente.get()).data()!['nome'];
      var t = FirebaseFirestore.instance.doc('turmas/${widget.canal.id}');
      await t.collection('mensagens').add({
        'conteudo': conteudo,
        'data': Timestamp.now(),
        'remetente': remetente,
        'lidoPor': []
      });

      await FirebaseFirestore.instance
          .doc('turmas/${widget.canal.id}')
          .update({'ultimaMsg': conteudo});

      widget._controller.clear();
    }
  }

  TextStyle _labelTextStyle() {
    return const TextStyle(
      fontSize: 13,
      color: Colors.grey,
    );
  }

  InputBorder _focusBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
      ),
    );
  }

}
