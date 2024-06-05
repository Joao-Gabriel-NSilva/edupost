import 'package:flutter/material.dart';

import '../../model/home_page/model_canal.dart';
import '../../screens/canal.dart';

class ItemListaCanal extends StatelessWidget {
  final ModelCanal canal;

  const ItemListaCanal(this.canal, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2),
        child: _buildListTile(context));
  }

  Widget _buildListTile(context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      tileColor: Colors.black26,
      title: Text(
        '${canal.nome} ${canal.complemento ?? ''} - ${canal.semestre}° semestre - ${canal.periodo}',
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      subtitle: Text(
        canal.ultimaMsg ?? '',
        style: const TextStyle(color: Colors.white38),
      ),
      trailing: canal.msgsNaoVisualidazas != null &&
              canal.msgsNaoVisualidazas! > 0
          ? Badge(
              label: Text(canal.msgsNaoVisualidazas.toString()),
              textStyle: const TextStyle(fontSize: 14),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            )
          : null,
      onTap: () => _tap(context),
    );
  }

  void _tap(context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => Canal(canal)));

    // Navigator.of(context).push(PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) => Canal(canal),
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       const begin = Offset(1.0, 0.0);
    //       const end = Offset.zero;
    //       const curve = Curves.ease;
    //
    //       var tween =
    //           Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    //       var offsetAnimation = animation.drive(tween);
    //
    //       return SlideTransition(
    //         position: offsetAnimation,
    //         child: child,
    //       );
    //     }));
  }
}
