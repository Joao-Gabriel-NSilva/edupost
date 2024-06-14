import 'package:flutter/material.dart';
import '../../model/usuario.dart';
import '../../util/util_style.dart';

class MainAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Usuario? usuario;
  final bool mostraLeading;
  String? titulo;

  MainAppBarWidget(this.mostraLeading, {super.key, this.titulo, this.usuario});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('EduPost'),
      backgroundColor: UtilStyle.instance.corPrimaria,
      foregroundColor: Colors.white,
      leading: mostraLeading ? _buildLeading(context) : null
    );
  }

  Widget? _buildLeading(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
      },
    );
  }
}