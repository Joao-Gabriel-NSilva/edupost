import 'package:edupost/screens/login.dart';
import 'package:edupost/util/util_style.dart';
import 'package:edupost/widget/home_page/item_lista_canal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/home_page/model_canal.dart';

class HomePageAluno extends StatefulWidget {
  final List<ModelCanal> _canais = [ModelCanal('teste', 'noite', 5, '1')];

  HomePageAluno({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageAlunoState();
  }
}

class HomePageAlunoState extends State<HomePageAluno> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: const Text('EduPost'),
        backgroundColor: UtilStyle.instance.corPrimaria.withOpacity(0.6),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            onSelected: (a) {},
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Configurações'),
                  ),
                ),
                PopupMenuItem(
                    child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sair'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
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
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                // Navigator.of(context).push(PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) =>
                //         Scaffold(
                //           appBar: AppBar(
                //             title: Text('asfasf'),
                //           ),
                //         ),
                //     transitionsBuilder:
                //         (context, animation, secondaryAnimation, child) {
                //       const begin = Offset(1.0, 0.0);
                //       const end = Offset.zero;
                //       const curve = Curves.ease;
                //
                //       var tween = Tween(begin: begin, end: end)
                //           .chain(CurveTween(curve: curve));
                //       var offsetAnimation = animation.drive(tween);
                //
                //       return SlideTransition(
                //         position: offsetAnimation,
                //         child: child,
                //       );
                //     }
                // ));
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (c) => Scaffold(
                          appBar: AppBar(
                            title: Text('asfasf'),
                          ),
                        )));
              },
              child: Text('asdasd'))
          // Expanded(
          //     child: ListView.builder(
          //         itemCount: widget._canais.length,
          //         itemBuilder: (context, index) {
          //           return ItemListaCanal(widget._canais[index]);
          //         }))
        ],
      ),
    );
  }
}
