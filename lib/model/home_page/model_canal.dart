import 'mensagem.dart';

class ModelCanal {
  String nome;
  String? ultimaMsg;
  int? msgsNaoVisualidazas;
  List<Mensagem>? mensagens;
  String? complemento;
  String periodo;
  int semestre;

  ModelCanal(this.nome, this.periodo, this.semestre,
      {this.ultimaMsg, this.msgsNaoVisualidazas, this.mensagens});
}
