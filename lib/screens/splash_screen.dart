import 'package:flutter/material.dart';
import 'package:passman/screens/home_page.dart';

import '../settings/settings_controller.dart';
import '../support/route_fade.dart';

class SplashScreen extends StatefulWidget {
  final SettingsController settingsController;
  const SplashScreen({Key? key, required this.settingsController}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _gotoHomePage();
  }

  void _gotoHomePage() async {
    await Future.delayed(const Duration (seconds: 2), () {
      Navigator.pushReplacement(
        context,
        FadeInRoute(
          routeName: HomePage.route,
          page: HomePage(settingsController: widget.settingsController,),
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xffffba90),
      child: Center(
        child: Image.asset("images/splash_icon.png", width: 250, fit: BoxFit.fitWidth,),),
    );
  }
}
