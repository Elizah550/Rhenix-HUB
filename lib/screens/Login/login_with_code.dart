import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:precision_hub/screens/Registration/registration_page.dart';
import 'package:precision_hub/screens/Vitals/vitals_page.dart';
import 'package:precision_hub/widgets/User_Provider.dart';
import 'package:precision_hub/widgets/custom_widgets/auth_button.dart';
import 'package:precision_hub/widgets/custom_widgets/text_box.dart';
import 'package:precision_hub/widgets/custom_widgets/top_splash.dart';
import 'package:precision_hub/widgets/health_records/header_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Code/Code.dart';

class LoginPageCode extends StatefulWidget {
  const LoginPageCode({Key? key}) : super(key: key);

  @override
  State<LoginPageCode> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPageCode> {
  final _formKey = GlobalKey<FormState>();
  final user = UserProvider();
  TextEditingController finalcode = TextEditingController();
  String countryCode = "1";
  TextEditingController Phone = TextEditingController();
  String countryDropdownCurValue = 'India';
  String? _currentAddress;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final formKey = GlobalKey<FormState>();
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.isoCountryCode}';
        if (kDebugMode) {
          print('${place.isoCountryCode}');
        }
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    super.initState();
    finalcode.text = "";
    Phone.text = "";
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Code()));
        return false; // return true if you want to prevent the back button press, otherwise return false
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              const TopSplashWidget(imagePath: 'assets/images/rhenix_logo.png'),
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              Card(
                shadowColor: Theme.of(context).primaryColor,
                elevation: 5,
                margin:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * 0.03)),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      const HeaderText("Login"),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      BorderedTextField(
                        labelText: "Enter code",
                        borderRadius: MediaQuery.of(context).size.height * 0.02,
                        padding: MediaQuery.of(context).size.height * 0.02,
                        keyboardType: TextInputType.text,
                        controller: finalcode,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Please Enter Code";
                          } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(text)) {
                            return 'Invalid code';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.02),
                        child: IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height * 0.02),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height * 0.02),
                            ),
                          ),
                          initialCountryCode: _currentAddress,
                          onChanged: (phone) {
                            setState(
                              () {
                                Phone.text = phone.number;
                                // countryCode = code.dialCode;

                                if (kDebugMode) {
                                  print(countryCode);
                                }
                              },
                            );
                          },
                          onCountryChanged: (code) {
                            setState(
                              () {
                                // Phone.text = phone.number;
                                countryCode = code.dialCode;
                                if (kDebugMode) {
                                  print(countryCode);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      AuthButton(
                        buttonText: "Continue",
                        leftPadding: MediaQuery.of(context).size.height * 0.04,
                        rightPadding: MediaQuery.of(context).size.height * 0.03,
                        onPressed: () async {
                          Text(_formKey.currentState?.validate() == false
                              ? ''
                              : ' ');
                          var orCode = Phone.text;
                          var countrycode = countryCode;
                          if (kDebugMode) {
                            print("-----------here is the code==============");
                            print(orCode);
                          }
                          if (_formKey.currentState!.validate()) {
                            if (!await user.signInCode(orCode,
                                finalcode.text.toLowerCase(), countrycode)) {
                              Fluttertoast.showToast(
                                  msg: "User does not exist",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   // const SnackBar(
                              //   //   content: Text('User doesnot exist'),
                              //   // ),
                              // );
                            } else if (orCode.isNotEmpty) {
                              if (orCode == '9490007929') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()),
                                );
                              } else {
                                final SharedPreferences sharedpreferences =
                                    await SharedPreferences.getInstance();
                                sharedpreferences.setString(
                                    'phone', Phone.text);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()),
                                );
                                Fluttertoast.showToast(
                                    msg: "Login successful",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.blue,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            }
                          }
                        },
                      ),
                      // AuthButton(
                      //   buttonText: "Continue",
                      //   leftPadding: MediaQuery.of(context).size.height * 0.03,
                      //   rightPadding: MediaQuery.of(context).size.height * 0.03,
                      //   onPressed: () async {
                      //     var orCode = finalcode.text.replaceAll(RegExp('[^0-9]'),'');
                      //     print("-----------here is the code==============");
                      //     print(orCode);
                      //     if (!await user.signInCode(orCode)) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         const SnackBar(
                      //           content: Text('User doesnot exist'),
                      //         ),
                      //       );
                      //     } else if (finalcode.text.isNotEmpty) {
                      //       if (finalcode.text == '9490007929') {
                      //         Navigator.pushReplacement(
                      //           context,
                      //           MaterialPageRoute(builder: (context) => const HomePage()),
                      //         );
                      //       }
                      //       else {
                      //         // changeScreenReplacement(
                      //         //   context,
                      //         //   OtpPage(
                      //         //     phonenumber: Phone.text,
                      //         //   ),
                      //         // );
                      //         Navigator.pushReplacement(
                      //           context,
                      //           MaterialPageRoute(builder: (context) => const HomePage()),
                      //         );
                      //       }
                      //     }
                      //   },
                      // ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      LimitedBox(
                        maxHeight: MediaQuery.of(context).size.height * 0.07,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('New user? '),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationPage()));
                              },
                              child: Text(
                                'Create a code',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
