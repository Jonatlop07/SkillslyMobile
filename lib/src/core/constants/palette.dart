import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor primary = MaterialColor(
    0xff77a6f7, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xff6b95de), //10%
      100: Color(0xff5f85c6), //20%
      200: Color(0xff5374ad), //30%
      300: Color(0xff476494), //40%
      400: Color(0xff3c537c), //50%
      500: Color(0xff304263), //60%
      600: Color(0xff24324a), //70%
      700: Color(0xff182131), //80%
      800: Color(0xff0c1119), //90%
      900: Color(0xff000000)
    },
  );

  static const MaterialColor secondary = MaterialColor(
    0xff00887a, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xff007a6e), //10%
      100: Color(0xff006d62), //20%
      200: Color(0xff005f55), //30%
      300: Color(0xff005249), //40%
      400: Color(0xff00443d), //50%
      500: Color(0xff003631), //60%
      600: Color(0xff002925), //70%
      700: Color(0xff001b18), //80%
      800: Color(0xff000e0c), //90%
      900: Color(0xff000000)
    },
  );
}
