import 'package:flutter/material.dart';

class ResponsiveUI extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;
  const ResponsiveUI({super.key, required this.mobile, required this.desktop});

  static const mobileWidth = 600;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        if (constraints.maxWidth < mobileWidth) {
          return mobile;
        } else {
          return desktop;
        }
      }),
    );
  }
}
