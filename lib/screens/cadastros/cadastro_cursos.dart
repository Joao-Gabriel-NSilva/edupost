import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:edupost/util/util_style.dart';

class CadastroCursosPage extends StatefulWidget {
  const CadastroCursosPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return CadastroCursosPageState();
  }
}

class CadastroCursosPageState extends State<CadastroCursosPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerNome = TextEditingController();

  void _cadastrarCurso() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('cursos').add({
        'nome': _controllerNome.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Curso cadastrado com sucesso!')),
      );
      _formKey.currentState!.reset();
      _controllerNome.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de cursos'),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _controllerNome,
                      decoration: InputDecoration(
                        labelText: 'Nome do Curso',
                        prefixIcon: const Icon(Icons.book),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o nome do curso';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child:
                    ElevatedButton(
                      onPressed: _cadastrarCurso,
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
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}