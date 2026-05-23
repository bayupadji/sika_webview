// error_modal.dart
import 'package:flutter/material.dart';
import 'package:sika/core/constants/button/default_btn.dart';

class ErrorModal {
  static void showErrorModal(
    BuildContext context, {
    required String errorMessage,
    required Future<void> Function() onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Error",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          content: Text(
            "Terjadi kesalahan: $errorMessage",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: DefaultButton(
                label: "Coba Lagi",
                onPressed: () async {
                  Navigator.of(context).pop();
                  await onRetry();
                },
                bgColor: Color(0xFF10A9A4),
                fgColor: Colors.white,
              ),
            )
          ],
        );
      },
    );
  }
}
