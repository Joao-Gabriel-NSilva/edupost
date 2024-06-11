import 'package:edupost/screens/cadastros/cadastro_cursos.dart';
import 'package:edupost/screens/cadastros/cadastro_turmas.dart';
import 'package:edupost/screens/cadastros/cadastro_usuarios.dart';
import 'package:flutter/material.dart';
import 'package:edupost/util/util_style.dart';

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastros'),
        backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              icon: const Icon(Icons.school, color: Colors.white,),
              label: const Text(
                'CURSOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: UtilStyle.instance.corPrimaria,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: UtilStyle.instance.corPrimaria,
                    width: 2.0, // Tamanho da borda
                  ),
                )
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroCursosPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.class_, color: Colors.white,),
              label: const Text(
                'TURMAS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: UtilStyle.instance.corPrimaria,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: UtilStyle.instance.corPrimaria,
                      width: 2.0,
                    ),
                  )
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroTurmasPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.person, color: Colors.white,),
              label: const Text(
                'USUÁRIOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: UtilStyle.instance.corPrimaria,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: UtilStyle.instance.corPrimaria,
                    width: 2.0, // Tamanho da borda
                  ),
                )
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroUsuariosPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
