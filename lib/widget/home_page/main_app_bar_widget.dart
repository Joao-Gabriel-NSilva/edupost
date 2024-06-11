import 'package:flutter/material.dart';
import '../../model/usuario.dart';
import '../../util/util_style.dart';

class MainAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Usuario? usuario;
  final bool mostraActions;
  String? titulo;

  MainAppBarWidget(this.mostraActions, {super.key, this.titulo, this.usuario});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('EduPost'),
      backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
      foregroundColor: Colors.white,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    );
  }
}