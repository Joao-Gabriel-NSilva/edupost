import 'package:cloud_firestore/cloud_firestore.dart';

class Remetente {
  String nome;
  String email;

  Remetente(this.nome, this.email);

  factory Remetente.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    var data = snapshot.data();
    return Remetente(data?['nome'] ?? '', data?['email'] ?? '');
  }
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'email': email
    };
  }
}