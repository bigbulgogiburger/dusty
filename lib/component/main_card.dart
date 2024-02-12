import 'package:dusty/const/colors.dart';
import 'package:flutter/material.dart';

class MainCard extends StatelessWidget {
  final Widget child;
  const MainCard({required this.child,super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
    shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
    Radius.circular(16.0),
    ),
    ),
    color: lightColor,
    child: child,);
  }
}
