import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final List<Widget> children;
  final double width;
  final double height;

  const MyWidget(
      {super.key,
      required this.children,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 12,
                offset: const Offset(0, 3),
              )
            ]),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: children),
      ),
    );
  }
}
