import 'package:flutter/material.dart';

enum ClipType {
  curved,
  waved,
  oval,
}

class ClipperBase extends CustomClipper<Path> {
  ClipType clipType;

  ClipperBase(this.clipType);

  @override
  Path getClip(Size size) {
    var path = Path();

    switch (clipType) {
      case ClipType.curved:
        createCurve(size, path);
        break;
      case ClipType.oval:
        createOval(size, path);
        break;
      case ClipType.waved:
        createWave(size, path);
        break;
    }

    path.close();
    return path;
  }

  void createCurve(Size size, Path path) {
    path.lineTo(0, size.height);

    var curXPos = 0.0;
    var curYPos = size.height;
    var increment = size.width / 20;
    while (curXPos < size.width) {
      curXPos += increment;
      path.arcToPoint(Offset(curXPos, curYPos), radius: const Radius.circular(5));
    }
    path.lineTo(size.width, 0);
  }

  void createOval(Size size, Path path) {
    path.lineTo(0, size.height - 26);
    path.quadraticBezierTo(
        size.width / 2, size.height + 5, size.width - 100, size.height - 68);
    path.lineTo(size.width, 0);
  }

  void createWave(Size size, Path path) {
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 4, size.height - 50, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height);
    path.lineTo(size.width, 0);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
