import 'package:edupost/util/util_style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroUsuariosPage extends StatefulWidget {
  const CadastroUsuariosPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return CadastroUsuariosPageState();
  }
}

class CadastroUsuariosPageState extends State<CadastroUsuariosPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmSenhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _turmaController = TextEditingController();
  String? _selectedCurso;
  String? _selectedTurma;
  String? _selectedSemestre;
  String? _selectedPeriodo;
  String? _selectedComplemento;
  bool _ehSuperUsuario = false;
  final _animationButton = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de usuários'),
        backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextField(_nomeController, 'Nome', Icons.person, minLength: 3),
                        _buildTextField(_emailController, 'Email', Icons.email, emailValidation: true),
                        _buildTextField(_senhaController, 'Senha', Icons.lock, obscureText: true, minLength: 6),
                        _buildTextField(_confirmSenhaController, 'Confirmar Senha', Icons.lock, obscureText: true, confirmPassword: true),
                        _buildCursoDropdown(),
                        if (_selectedCurso != null) _buildTurmaDropdown(),
                        _buildCheckbox(),
                        _buildButton(context),
                      ]
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscureText = false,
        int minLength = 0,
        bool emailValidation = false,
        bool confirmPassword = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          fillColor: Colors.white,
          filled: true,
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira $label';
          }
          if (minLength > 0 && value.length < minLength) {
            return '$label deve ter pelo menos $minLength caracteres';
          }
          if (emailValidation && !RegExp(r'^[a-zA-Z]+\.([0-9]+)-([0-9]{4})@aluno\.unicv\.edu\.br$').hasMatch(value)) {
            return 'Por favor, insira um email válido';
          }
          if (confirmPassword && value != _senhaController.text) {
            return 'As senhas não coincidem';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCursoDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cursos').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        var cursos = snapshot.data!.docs.map((doc) => doc['nome'] as String).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<String>(
            value: _selectedCurso,
            decoration: InputDecoration(
              labelText: 'Curso',
              prefixIcon: const Icon(Icons.book),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (value) {
              setState(() {
                _selectedCurso = value;
                _turmaController.clear();
                _selectedTurma = null;
              });
            },
            items: cursos.map((curso) {
              return DropdownMenuItem(
                value: curso,
                child: Text(curso),
              );
            }).toList(),
            validator: (value) => value == null ? 'Por favor, selecione um curso' : null,
          ),
        );
      },
    );
  }

  Widget _buildTurmaDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('turmas').where('curso', isEqualTo: _selectedCurso).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        var turmas = snapshot.data!.docs.map((doc) {
          var semestre = doc['semestre'] as int;
          var periodo = doc['periodo'] as String;
          var complemento = doc['complemento'] as String;
          var turmaDisplay = '$semestre° | $periodo | $complemento';
          return DropdownMenuItem(
            value: turmaDisplay,
            child: Text(turmaDisplay),
          );
        }).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<String>(
            value: _selectedTurma,
            decoration: InputDecoration(
              labelText: 'Turma',
              prefixIcon: const Icon(Icons.class_),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (value) {
              setState(() {
                _selectedTurma = value;
                var parts = value!.split(' | ');
                _selectedSemestre = parts[0].split('°')[0];
                _selectedPeriodo = parts[1];
                _selectedComplemento = parts[2];
                _turmaController.text = value;
              });
            },
            items: turmas,
            validator: (value) => value == null || value.isEmpty ? 'Por favor, selecione uma turma' : null,
          ),
        );
      },
    );
  }

  Widget _buildCheckbox() {
    return CheckboxListTile(
      title: const Text('É administrador'),
      value: _ehSuperUsuario,
      onChanged: (bool? value) {
        setState(() {
          _ehSuperUsuario = value ?? false;
        });
      },
    );
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: ValueListenableBuilder<bool>(
        valueListenable: _animationButton,
        builder: (context, value, child) {
          return TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.white),
              backgroundColor: WidgetStateProperty.all(UtilStyle.instance.corPrimaria),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            onPressed: !value ? () async {
              if (_formKey.currentState!.validate()) {
                _animationButton.value = true;
                await _cadastraUsuario(context);
                _animationButton.value = false;
              }
            } : null,
            child: !value
                ? const Text(
              'Cadastrar',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            )
                : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _cadastraUsuario(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      var turmaSnapshot = await FirebaseFirestore.instance.collection('turmas')
          .where('curso', isEqualTo: _selectedCurso)
          .where('semestre', isEqualTo: int.parse(_selectedSemestre!))
          .where('periodo', isEqualTo: _selectedPeriodo)
          .where('complemento', isEqualTo: _selectedComplemento)
          .get();

      var turmaId = turmaSnapshot.docs.first.id;

      await FirebaseFirestore.instance.collection('usuarios').doc(_emailController.text.trim()).set({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'ehSuperUsuario': _ehSuperUsuario,
        'curso': _selectedCurso,
        'turma': turmaId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );

      _clearFields();
      setState(() {
        _ehSuperUsuario = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao cadastrar usuário: $e')),
      );
    }
  }

  void _clearFields() {
    _emailController.clear();
    _senhaController.clear();
    _confirmSenhaController.clear();
    _nomeController.clear();
    _turmaController.clear();
    _selectedCurso = null;
  }
}