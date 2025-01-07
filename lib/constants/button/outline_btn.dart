import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? bgColor;
  final Color fgColor;
  final Color? outlineColor;

  const DefaultButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.bgColor,
    required this.fgColor,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor ?? Colors.transparent,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: outlineColor ?? Colors.transparent,
            width: 1.0,
          ),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
