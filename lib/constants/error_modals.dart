// error_modal.dart
import 'package:flutter/material.dart';

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
          title: const Text("Error"),
          content: Text(
            "Terjadi kesalahan: $errorMessage",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text("Tutup"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
                onRetry(); // Panggil fungsi retry
              },
              child: const Text("Coba Lagi"),
            ),
          ],
        );
      },
    );
  }
}
