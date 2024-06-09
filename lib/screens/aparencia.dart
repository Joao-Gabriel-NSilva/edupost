import 'package:edupost/cache/theme_manager.dart';
import 'package:edupost/util/util_style.dart';
import 'package:edupost/widget/home_page/main_app_bar_widget.dart';
import 'package:flutter/material.dart';

class Aparencia extends StatefulWidget {
  Aparencia({super.key});

  @override
  State<StatefulWidget> createState() {
    return AparenciaState();
  }
}

class AparenciaState extends State<Aparencia> {
  bool temaEscuro = ThemeManager.instance.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBarWidget(false, titulo: 'Aparência'),
      backgroundColor: UtilStyle.instance.backGroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Tema escuro:',
                  style: TextStyle(
                      fontSize: 16, color: UtilStyle.instance.foreGroundColor),
                ),
                Switch(
                    value: temaEscuro,
                    onChanged: (value) {
                      setState(() {
                        temaEscuro = value;
                        UtilStyle.instance.setarTema();
                      });
                    },
                    activeColor: UtilStyle.instance.corPrimaria)
              ],
            )
          ],
        ),
      ),
    );
  }
}
