import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:edupost/util/util_style.dart';

class CadastroTurmasPage extends StatefulWidget {
  const CadastroTurmasPage({super.key});

  @override
  _CadastroTurmasPageState createState() => _CadastroTurmasPageState();
}

class _CadastroTurmasPageState extends State<CadastroTurmasPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllerComplemento = TextEditingController();
  String _cursoSelecionado = '';
  int _semestreSelecionado = 1;
  String _periodo = 'Matutino';
  final List<String> _periodos = ['Matutino', 'Vespertino', 'Noturno'];

  Future<List<String>> _fetchCursos() async {
    final cursosSnapshot = await FirebaseFirestore.instance.collection('cursos').get();
    return cursosSnapshot.docs.map((doc) => doc['nome'] as String).toList();
  }

  void _cadastrarTurma() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('turmas').add({
        'complemento': _controllerComplemento.text ?? '',
        'curso': _cursoSelecionado,
        'periodo': _periodo,
        'semestre': _semestreSelecionado,
        'ultimaMsg': '',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turma cadastrada com sucesso!')),
      );
      _formKey.currentState!.reset();
      _controllerComplemento.clear();
      setState(() {
        _cursoSelecionado = '';
        _periodo = 'Matutino';
        _semestreSelecionado = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de turmas'),
        backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _controllerComplemento,
                    decoration: InputDecoration(
                      labelText: 'Complemento',
                      prefixIcon: const Icon(Icons.comment_bank_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      fillColor: Colors.white,
                      filled: true,
                    )
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<String>>(
                    future: _fetchCursos(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Nenhum curso encontrado');
                      }
                      return DropdownButtonFormField<String>(
                        value: _cursoSelecionado.isNotEmpty ? _cursoSelecionado : null,
                        decoration: InputDecoration(
                          labelText: 'Curso',
                          prefixIcon: const Icon(Icons.book),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: UtilStyle.instance.corPrimaria)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: snapshot.data!.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _cursoSelecionado = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o curso';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _periodo,
                    decoration: InputDecoration(
                      labelText: 'Período',
                      prefixIcon: const Icon(Icons.watch_later),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    items: _periodos.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _periodo = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    value: _semestreSelecionado,
                    decoration: InputDecoration(
                      labelText: 'Semestre',
                      prefixIcon: const Icon(Icons.layers),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    items: List.generate(10, (index) => index + 1).map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value°'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _semestreSelecionado = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Informe o semestre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: ElevatedButton(
                      onPressed: _cadastrarTurma,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UtilStyle.instance.corPrimaria,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('CADASTRAR',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}