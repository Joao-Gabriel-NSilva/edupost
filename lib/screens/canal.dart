import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/widget/home_page/main_app_bar_widget.dart';
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
    // for (var me in msgs) {
    //   await me.loadRemetente();
    // }
    return msgs;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .doc('turmas/${widget.canal.id}')
          .collection('mensagens')
          .orderBy('data')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              backgroundColor: UtilStyle.instance.backGroundColor,
              appBar: MainAppBarWidget(
                false,
                titulo: widget.canal.nome,
              ),
              body: const Column(
                children: [
                  Expanded(
                      child: Center(
                    child: CircularProgressIndicator(),
                  ))
                ],
              ));
        }

        if (!snapshot.hasData) {
          return Scaffold(
              backgroundColor: UtilStyle.instance.backGroundColor,
              appBar: MainAppBarWidget(
                false,
                titulo: widget.canal.nome,
              ),
              body: const Column(
                children: [
                  Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ))
                ],
              ));
        }

        if (snapshot.data!.docs.isEmpty) {
          return Scaffold(
            backgroundColor: UtilStyle.instance.backGroundColor,
            appBar: MainAppBarWidget(
              false,
              titulo: widget.canal.nome,
            ),
            body: Column(
              children: [
                const Expanded(child: Column()),
                if (widget.ehAdm) _buildTextField()
              ],
            ),
          );
        }

        List<Mensagem> msgs = snapshot.data!.docs
            .map((m) => Mensagem.fromFirestore(
                m as DocumentSnapshot<Map<String, dynamic>>, null))
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return Scaffold(
            backgroundColor: UtilStyle.instance.backGroundColor,
            appBar: MainAppBarWidget(
              false,
              titulo: widget.canal.nome,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      var msg = msgs[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 6.0, right: 4, left: 4),
                        child: ListTile(
                          title: Text(msg.msg,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: UtilStyle.instance.titleColor)),
                          subtitle: Text(
                              '${msg.remetente} - ${DateFormat('dd/MM/yyyy HH:mm').format(msg.hora.toDate())}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: UtilStyle.instance.subTitleColor)),
                          tileColor: UtilStyle.instance.tileColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: UtilStyle.instance.corPrimaria,
                                  width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.ehAdm) _buildTextField()
              ],
            ));
      },
    );
  }

  Future<void> _enviaMsg(context) async {
    if (widget._controller.text.isNotEmpty) {
      var email = FirebaseAuth.instance.currentUser!.email;
      var conteudo = widget._controller.text;
      var remetente = FirebaseFirestore.instance.doc('usuarios/$email');
      var nome = (await remetente.get()).data()!['nome'];
      var t = FirebaseFirestore.instance.doc('turmas/${widget.canal.id}');
      await t.collection('mensagens').add({
        'conteudo': conteudo,
        'data': Timestamp.now(),
        'remetente': nome,
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

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
            color: UtilStyle.instance.textFieldBackGroundColor,
            border: Border.all(
              color: UtilStyle.instance.corPrimaria,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: TextField(
                  controller: widget._controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(color: UtilStyle.instance.foreGroundColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelStyle: _labelTextStyle(),
                    focusedBorder: _focusBorder(),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _enviaMsg(context),
              icon: Icon(
                Icons.send,
                color: UtilStyle.instance.foreGroundColor,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
