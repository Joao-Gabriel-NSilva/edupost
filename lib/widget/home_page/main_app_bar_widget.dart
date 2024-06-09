import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../model/usuario.dart';
import '../../screens/configuracoes.dart';
import '../../screens/login.dart';
import '../../util/util_style.dart';

class MainAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Usuario? usuario;
  final bool mostraActions;
  String? titulo;

  MainAppBarWidget(this.mostraActions, {super.key, this.titulo, this.usuario});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo??'EduPost'),
      backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
      foregroundColor: Colors.white,
      actions: [
        if(mostraActions) PopupMenuButton(
          onSelected: (a) {},
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configurações'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (b) => Configuracoes(usuario!))),
                ),
              ),
              PopupMenuItem(
                  child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (b) => const Login()),
                      (a) => false);
                },
              ))
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(0, 60);
}
