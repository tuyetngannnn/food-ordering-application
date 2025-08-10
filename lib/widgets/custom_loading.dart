import 'package:flutter/material.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF8F8F8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/dancing_frosty.gif', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
