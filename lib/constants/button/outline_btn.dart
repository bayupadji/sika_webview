import 'package:flutter/material.dart';

class OutlineButton extends StatefulWidget {
  final String label;
  final Future<void> Function()? onPressed;
  final Color? bgColor;
  final Color fgColor;
  final Color? outlineColor;

  const OutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.bgColor,
    required this.fgColor,
    this.outlineColor,
  });

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading || widget.onPressed == null) return;
    setState(() => _isLoading = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.bgColor ?? Colors.transparent,
        foregroundColor: widget.fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: widget.outlineColor ?? Colors.transparent,
            width: 1.0,
          ),
        ),
        elevation: 0,
      ),
      onPressed: _isLoading ? null : _handlePress,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isLoading
            ? SizedBox(
                key: const ValueKey('loading'),
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.fgColor),
                ),
              )
            : Text(
                key: const ValueKey('label'),
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
