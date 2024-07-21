import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:precision_hub/screens/Code/Code.dart';
import 'package:precision_hub/screens/Vitals/vitals_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

String? finalPhone;
String? value;

class Splash2 extends StatefulWidget {
  const Splash2({Key? key}) : super(key: key);

  @override
  State<Splash2> createState() => _Splash2State();
}

class _Splash2State extends State<Splash2> {
  @override
  void initState() {
    getValidationData();
    requestPermissions();
    super.initState();
  }

  Future getValidationData() async {
    const storage = FlutterSecureStorage();
    value = await storage.read(key: "status");
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    String? obtainedPhone = sharedPreferences.getString('phone');
    setState(() {
      finalPhone = obtainedPhone;
    });
  }

  Future<void> requestPermissions() async {
    Map<permission_handler.Permission, permission_handler.PermissionStatus>
        status = await [
      permission_handler.Permission.camera,
      permission_handler.Permission.microphone,
      permission_handler.Permission.storage,
      permission_handler.Permission.location
      // add other permissions here as necessary
    ].request();

    // handle the result of the permission request
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: const CircleAvatar(
        backgroundImage: AssetImage("assets/images/rhenix_logo.png"),
        backgroundColor: Colors.white,
        radius: 80,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      nextScreen: (value == "Authenticated" ? const HomePage() : const Code()),
      splashIconSize: 150,
      duration: 1000,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(seconds: 1),
    );
  }
}
