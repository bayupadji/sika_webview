// error_modal.dart
import 'package:flutter/material.dart';
import 'package:sika/constants/button/outline_btn.dart';

class ErrorModal {
  static void showErrorModal(
    BuildContext context, {
    required String errorMessage,
    required VoidCallback onRetry,
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
            style: TextStyle(
              fontSize: 16
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: DefaultButton(
                label: "Coba Lagi", 
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
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
