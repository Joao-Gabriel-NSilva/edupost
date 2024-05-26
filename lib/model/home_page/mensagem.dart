import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/model/home_page/remetente.dart';

class Mensagem {
  String msg;
  Timestamp hora;
  Remetente? remetente;
  DocumentReference? remetenteRef;

  Mensagem(this.msg, this.hora, {this.remetente, this.remetenteRef});

  factory Mensagem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return Mensagem(
      data?['conteudo'],
      data?['data'],
      remetenteRef: data?['remetente'],
    );
  }

  Future<void> loadRemetente() async {
    if (remetenteRef != null) {
      var remetenteSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(remetenteRef!.id)
          .get();
      remetente = Remetente.fromFirestore(
        remetenteSnapshot,
        null,
      );
    }
  }
}
