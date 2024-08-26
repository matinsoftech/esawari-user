import 'package:emartconsumer/main.dart';
import 'package:flutter/material.dart';

class EsawariSplashScreen extends StatefulWidget {
  const EsawariSplashScreen({super.key});

  @override
  State<EsawariSplashScreen> createState() => _EsawariSplashScreenState();
}

class _EsawariSplashScreenState extends State<EsawariSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => OnBoarding(),
          ),
          (route) => false, //if you want to disable back feature set to false
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/esewari_splash.png'),
            ),
          ),
        ),
      ),
    );
  }
}
