import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String? label;
  final void Function()? onTap;
  const MyButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label ?? 'Button',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
