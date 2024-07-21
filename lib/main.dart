import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:precision_hub/screens/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterBranchSdk.validateSDKIntegration();
  const storage = FlutterSecureStorage();
  final all = await storage.readAll();
  var status = false;
  if (all["status"] == "Authenticated") {
    status = true;
  } else {
    status = false;
  }

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  runApp(MyApp(
    page_status: status,
  ));
}

class MyApp extends StatelessWidget {
  final page_status;
  const MyApp({
    super.key,
    this.page_status,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rhenix HUB',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Splash2());
    // home: page_status == true ? const Code() : const Splash2());
    // home: NewAppointment());
  }
}
