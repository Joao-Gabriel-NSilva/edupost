import 'dart:io';

class Arquivo {
  String nome;
  String url;
  String tipo;
  File file;
  Arquivo(this.nome, this.url, this.tipo, this.file);
}