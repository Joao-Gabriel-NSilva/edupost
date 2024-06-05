import 'mensagem.dart';

class ModelCanal {
  String nome;
  String? ultimaMsg;
  int? msgsNaoVisualidazas;
  List<Mensagem>? mensagens;
  String? complemento;
  String periodo;
  int semestre;
  String id;

  ModelCanal(this.nome, this.periodo, this.semestre, this.id,
      {this.ultimaMsg,
      this.msgsNaoVisualidazas,
      this.mensagens,
      this.complemento});
}
