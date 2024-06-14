class Usuario {
  String nome;
  String email;
  bool ehSuperUsuario;
  String turma;
  String? urlFoto;

  Usuario(this.email, this.nome, this.ehSuperUsuario, this.turma, {this.urlFoto});
}