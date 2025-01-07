import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color fgColor;

  const DefaultButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
