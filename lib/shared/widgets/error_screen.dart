import 'package:flutter/material.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/shared/widgets/default_button.dart';

/// Layar error generik untuk menampilkan HTTP/WebView error.
class ErrorScreen extends StatelessWidget {
  final int code;
  final String url;
  final String description;
  final Future<void> Function()? onRetry;

  const ErrorScreen({
    super.key,
    required this.code,
    required this.url,
    required this.description,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                AppConstants.warningAsset,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'Error $code',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(AppConstants.textSecondaryColor),
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: DefaultButton(
                  label: 'Coba Lagi',
                  bgColor: const Color(AppConstants.primaryColor),
                  fgColor: Colors.white,
                  onPressed: onRetry,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
