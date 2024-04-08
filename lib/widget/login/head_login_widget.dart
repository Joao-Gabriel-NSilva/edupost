import 'package:flutter/material.dart';

import '../../util/clipper_base.dart';
import '../../util/util_style.dart';

const double heightDefault = 148;
const double heightSecondary = heightDefault - 8;

class HeadLoginWidget extends StatelessWidget {
  const HeadLoginWidget({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: ClipperBase(ClipType.oval),
          child: Container(
            height: heightDefault,
            decoration: BoxDecoration(
              color: UtilStyle.instance.colorLogin.withOpacity(0.2),
            ),
          ),
        ),
        ClipPath(
          clipper: ClipperBase(ClipType.waved),
          child: Container(
            height: heightDefault - 15,
            decoration: BoxDecoration(
              color: UtilStyle.instance.colorLogin.withOpacity(0.2),
            ),
          ),
        ),
        ClipPath(
          // clipper: ClipperBase(ClipType.waved),
          child: Container(
            height: heightSecondary,
            decoration: BoxDecoration(
              color: UtilStyle.instance.colorLogin.withOpacity(0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/logo_unicv.png'),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      bottom: 20,
                    ),
                    child: Text('Edupost',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: UtilStyle.instance.colorLogin,
                            fontSize: 24,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w900)))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
