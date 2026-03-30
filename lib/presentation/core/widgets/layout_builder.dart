import 'package:flutter/material.dart';

class ResponsiveUI extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;
  const ResponsiveUI({
    Key? key,
    required this.mobile,
    required this.desktop,
  }) : super(key: key);

  static const mobileWidth = 600;
  static const tabletWidth = 1200;

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
