import 'package:flutter/widgets.dart';

class Adaptive {
  final BuildContext context;
  Adaptive(this.context);

  static Adaptive of(BuildContext context) => Adaptive(context);

  double scale(double size) {
    final mq = MediaQuery.of(context);
    final shortest = mq.size.shortestSide;
    if (shortest < 360) return size * 0.9;
    if (shortest > 720) return size * 1.2;
    return size;
  }

  bool isTablet() => MediaQuery.of(context).size.shortestSide >= 600;
}
