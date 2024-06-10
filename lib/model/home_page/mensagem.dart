import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/model/home_page/remetente.dart';

class Mensagem {
  String msg;
  Timestamp hora;
  String? remetente;
  bool? anexo;
  String? path;
  String? extensao;
  String? url;
  // DocumentReference? remetenteRef;
  List<String>? lidoPor;

  Mensagem(this.msg, this.hora, this.remetente,
      {this.lidoPor, this.anexo, this.path, this.extensao, this.url});

  factory Mensagem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    var msg = Mensagem(
        data?['conteudo'],
        data?['data'],
        data?['remetente'],
        lidoPor: data?['lidoPor'] != null ? (data?['lidoPor'] as List<dynamic>)
            .cast<String>() : [],
        anexo: data?['anexo'] ?? false,
        path: data?['path'],
        extensao: data?['extensao'],
        url: data?['url']
    );
    return msg;
  }

  // Future<void> loadRemetente() async {
  //   if (remetenteRef != null) {
  //     var remetenteSnapshot = await FirebaseFirestore.instance
  //         .collection('usuarios')
  //         .doc(remetenteRef!.id)
  //         .get();
  //     remetente = Remetente.fromFirestore(
  //       remetenteSnapshot,
  //       null,
  //     );
  //   }
  //}
}
