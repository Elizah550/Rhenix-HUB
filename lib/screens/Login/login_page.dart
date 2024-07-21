import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:precision_hub/screens/Login/sen' 'dotp.dart';
import 'package:precision_hub/screens/Registration/registration_page.dart';
import 'package:precision_hub/screens/Vitals/vitals_page.dart';
import 'package:precision_hub/widgets/User_Provider.dart';
import 'package:precision_hub/widgets/custom_widgets/auth_button.dart';
import 'package:precision_hub/widgets/custom_widgets/common.dart';
import 'package:precision_hub/widgets/custom_widgets/top_splash.dart';
import 'package:precision_hub/widgets/health_records/header_text.dart';
import '../Code/Code.dart';

TextEditingController Phone = TextEditingController();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final user = UserProvider();
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
        print('${place.isoCountryCode}');
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    super.initState();
    Phone.text = "";
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    print(_currentAddress);
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
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      const HeaderText("Login"),
                      Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.015),
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
                                // countryCode = phone.countryCode;
                                print(countryCode);
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
                          height: MediaQuery.of(context).size.height * 0.04),
                      AuthButton(
                        buttonText: "Continue",
                        leftPadding: MediaQuery.of(context).size.height * 0.03,
                        rightPadding: MediaQuery.of(context).size.height * 0.03,
                        onPressed: () async {
                          Text(_formKey.currentState?.validate() == false
                              ? ''
                              : ' ');
                          if (_formKey.currentState!.validate()) {
                            if (!await user.signIn(Phone.text, countryCode)) {
                              Fluttertoast.showToast(
                                  msg: "User does not exist",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     content: Text('User doesnot exist'),
                              //   ),
                              // );
                            } else if (Phone.text.isNotEmpty) {
                              if (Phone.text == '9490007929') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()),
                                );
                              } else {
                                changeScreenReplacement(
                                  context,
                                  OtpPage(
                                    phonenumber: Phone.text,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
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
                                // Navigator.of(context).pushReplacement(
                                //   MaterialPageRoute(
                                //       builder: (context) => AdditionalDetails(
                                //         phone: Phone.text,
                                //         headerText: "Additinal Info",
                                //         buttonText: "Register",
                                //         destWidget: const   Code(),
                                //       )),
                                // );
                              },
                              child: Text(
                                'Create an account',
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
