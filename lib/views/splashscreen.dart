import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sika/providers/splash_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Memulai proses loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SplashProvider>(context, listen: false).simulateLoading(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    final splashProvider = Provider.of<SplashProvider>(context);

    return Scaffold(
      body: Center(
        child: splashProvider.isLoading
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/main_logo.png'),
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  CircularProgressIndicator(
                    color: Color(0xFF10A9A4)
                  ),
                ],
              )
            : Container(), // Jika tidak loading, bisa menampilkan konten lain
      ),
    );
  }
}
