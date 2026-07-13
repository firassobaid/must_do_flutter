import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Semantic Gaps
  static const Widget gapXXS = SizedBox(height: xxs, width: xxs);
  static const Widget gapXS = SizedBox(height: xs, width: xs);
  static const Widget gapS = SizedBox(height: s, width: s);
  static const Widget gapM = SizedBox(height: m, width: m);
  static const Widget gapL = SizedBox(height: l, width: l);
  static const Widget gapXL = SizedBox(height: xl, width: xl);
}

class AppRadius {
  AppRadius._();

  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 32.0;
  static const double circular = 999.0;

  static BorderRadius radiusS = BorderRadius.circular(s);
  static BorderRadius radiusM = BorderRadius.circular(m);
  static BorderRadius radiusL = BorderRadius.circular(l);
  static BorderRadius radiusXL = BorderRadius.circular(xl);
  static BorderRadius radiusXXL = BorderRadius.circular(xxl);
}
