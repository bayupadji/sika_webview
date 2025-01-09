import 'package:flutter/material.dart';
import 'package:sika/constants/button/outline_btn.dart';

class ErrorPage extends StatelessWidget {
  final String descriptions;
  final String title;
  final String btnLabel;
  final String image;
  final VoidCallback? onPressed;

  const ErrorPage({
    super.key,
    required this.descriptions,
    required this.title,
    required this.image,
    required this.onPressed,
    required this.btnLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      image,
                      width: double.infinity,
                    ),
                    SizedBox(height: 16,),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      descriptions,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF828282)
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                child: DefaultButton(
                  label: "Coba Lagi",
                  onPressed: onPressed,
                  bgColor: Color(0xFF10A9A4),
                  fgColor: Colors.white
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
