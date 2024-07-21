import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:googleapis/androidenterprise/v1.dart';
import 'package:http/http.dart';
import 'package:precision_hub/screens/Vitals/vitals_page.dart';
import 'dart:convert';
import 'package:precision_hub/widgets/User_Provider.dart';
import 'package:precision_hub/widgets/custom_widgets/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:permission_handler/permission_handler.dart';
import 'login_page.dart';

// import 'package:googleapis/androidenterprise/v1.dart' as androidenterprise;
// import 'package:permission_handler/permission_handler.dart' as permission_handler;
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

String phone = "";
String code = "";
late String zipcode;
Color resendCodecolor = Colors.black;
var newotp = '----';

class OtpPage extends StatefulWidget {
  final phonenumber;
  const OtpPage({super.key, this.phonenumber});
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final user = UserProvider();

  TextEditingController otpverify = TextEditingController();
  bool startTimer = false;
  String textOnButton = "Send OTP";
  bool isSendOtpPressed = false;
  bool isResendOtpPressed = false;
  bool onTimerEnds = false;
  bool isButtonDisabled = false;
  bool isResendButtonDisabled = false;
  late Widget resendButton;

  bool resultChecker(String enteredOtp) {
    return enteredOtp == newotp;
  }

  @override
  void initState() {
    super.initState();
    phone = widget.phonenumber;
    getcode(phone);
    // _listenForCode();
  }

  // Future<void> _listenForCode() async {
  //   // await SmsAutoFill().listenForCode;
  //   String code = (await SmsAutoFill().getAppSignature).replaceAll(" ", "");
  //   // otpverify.text = await SmsAutoFill().getInitialCode;
  //   print("code is ...................");
  //   print(code);
  // }
  @override
  void dispose() {
    //SmsAutoFill().unregisterListener();
    //  SmsAutoFill().unregisterListener();
    super.dispose();
  }

  // void SmsAutoFillTextField() async {
  //   var status = await permission_handler.Permission.sms.status;
  //   if (!status.isGranted) {
  //     await permission_handler.Permission.sms.request();
  //   }
  //   String otpCode =
  //   await SmsAutoFill().getAppSignature.then((signature) => SmsAutoFill().listenForCode());
  //   // Check if the app has permission to read SMS
  //
  //   // Get the latest SMS message containing the OTP code
  //   // String otpCode = await SmsAutoFill().getAppSignature.then((signature) => SmsAutoFill().listenForCode());
  //   // String otpCode = await SmsAutoFill().getAppSignature.then((signature) =>
  //   //     SmsAutoFill().listenForCode()
  //   // );
  //   // String otpCode = await SmsAutoFill().listenForCode();
  //
  //   // Autofill the OTP code in the PinInputTextField
  //   otpverify.text = otpCode;
  // }
  String hintText = 'XXXX XXX';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
        return false; // return true if you want to prevent the back button press, otherwise return false
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        key: _scaffoldKey,
        body: Center(
          child: Card(
            shadowColor: Theme.of(context).primaryColor,
            elevation: 5,
            margin: const EdgeInsets.all(15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  Icon(Icons.message,
                      size: 50, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Enter your OTP",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Container(
                  //   width: 300,
                  //   child: TextField(
                  //     controller: otpverify, // Your controller for OTP input
                  //     keyboardType: TextInputType.number,
                  //     maxLength: 4, // 4 digits and 3 dashes
                  //   ),
                  // ),

                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: otpverify, // Your controller for OTP input
                      keyboardType: TextInputType.number,
                      maxLength: 7, // 4 digits and 3 spaces
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
                      onTap: () {
                        if (otpverify.text == '') {
                          setState(() {
                            otpverify.text =
                                ''; // Clear the hint text when the field is tapped
                          });
                        }
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty && value.length <= 7) {
                          String sanitizedValue =
                              value.replaceAll(' ', ''); // Remove spaces
                          otpverify.text =
                              sanitizedValue; // Store the OTP without spaces
                        }
                      },
                      decoration: InputDecoration(
                        hintText: otpverify.text.isEmpty
                            ? hintText
                            : '', // Show 'XXXX XXX' as hint initially
                        counterText: '',
                      ),
                      textAlign: TextAlign.center,
                      showCursor: true,
                    ),
                  ),

                  // Container(
                  //   width: 300,
                  //   child: TextField(
                  //     controller: otpverify, // Your controller for OTP input
                  //     keyboardType: TextInputType.number,
                  //     maxLength: 7, // 4 digits and 3 spaces
                  //     inputFormatters: [
                  //       FilteringTextInputFormatter.digitsOnly,
                  //       LengthLimitingTextInputFormatter(7),
                  //     ],
                  //     onChanged: (value) {
                  //       if (value.length >= 1 && value.length <= 7) {
                  //         String sanitizedValue =
                  //             value.replaceAll(' ', ''); // Remove spaces
                  //         otpverify.text =
                  //             sanitizedValue; // Store the OTP without spaces
                  //       }
                  //     },
                  //     decoration: InputDecoration(
                  //       hintText: 'XXXX XXX',
                  //       counterText: '',
                  //     ),
                  //     textAlign: TextAlign.center,
                  //     showCursor: false,
                  //   ),
                  // ),

                  // Container(
                  //   width: 300,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       for (int i = 0; i < 4; i++)
                  //         Container(
                  //           width: 50,
                  //           alignment: Alignment.center,
                  //           child: TextField(
                  //             keyboardType: TextInputType.number,
                  //             maxLength: 1,
                  //             decoration: InputDecoration(
                  //               hintText: '-',
                  //               counterText: '',
                  //             ),
                  //             textAlign: TextAlign.center,
                  //             showCursor: false,
                  //           ),
                  //         ),
                  //     ],
                  //   ),
                  // ),

                  // Container(
                  //   width: 300,
                  //   child: TextField(
                  //     controller: otpverify, // Your controller for OTP input
                  //     keyboardType: TextInputType.number,
                  //     maxLength: 4,
                  //     decoration: InputDecoration(
                  //       hintText: 'Enter OTP',
                  //     ),
                  //   ),
                  // ),

                  // Container(
                  //   width: 300,
                  //   Commented here child: PinInputTextField(
                  //     controller: otpverify,
                  //     pinLength: 4,
                  //   ),
                  //   child: PinInputTextField(
                  //     controller: otpverify,
                  //     pinLength: 4,
                  //     textInputAction: TextInputAction.next,
                  //     onChanged: (String value) {
                  //       if (value.length == 4) {
                  //         SmsAutoFillTextField();
                  //       }
                  //     },
                  //     enabled: false, // Disable user input
                  //   ),
                  // ),
                  const Padding(padding: EdgeInsets.only(bottom: 20)),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      (onTimerEnds)
                          ? MaterialButton(
                              child: Ink(
                                decoration: BoxDecoration(
                                    color: Colors.orange.shade300,
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: Container(
                                  constraints: const BoxConstraints(
                                      maxWidth: 120.0, minHeight: 50.0),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text(
                                        "Resend",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      isResendOtpPressed
                                          ? getTimer(isTimerEnd: false)
                                          : const Text(""),
                                    ],
                                  ),
                                ),
                              ),
                              onPressed: () {
                                (isResendButtonDisabled)
                                    ? () {}
                                    : sendotpnew(phone);
                                Fluttertoast.showToast(
                                  msg: "OTP sent successfully",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                setState(() {
                                  isResendButtonDisabled = true;
                                  isResendOtpPressed = true;
                                  Timer(const Duration(seconds: 10), () {
                                    setState(() {
                                      onTimerEnds = true;
                                      isResendButtonDisabled =
                                          false; // Enable button again
                                      isResendOtpPressed =
                                          false; // Remove timer from button
                                    });
                                  });
                                });
                              },
                            )
                          : MaterialButton(
                              child: Ink(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: Container(
                                  constraints: const BoxConstraints(
                                      maxWidth: 140.0, minHeight: 50.0),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text(
                                        "Send OTP",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      isSendOtpPressed
                                          ? getTimer(isTimerEnd: false)
                                          : const Text(""),
                                    ],
                                  ),
                                ),
                              ),
                              onPressed: () {
                                (isButtonDisabled) ? () {} : sendotpnew(phone);
                                print("Sent otp successfully");
                                Fluttertoast.showToast(
                                    msg: "OTP sent successfully",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                // setState(() {
                                //   isButtonDisabled = true;
                                //   isSendOtpPressed = true;
                                //   Timer(const Duration(seconds: 10), () =>
                                //   onTimerEnds = true);
                                // });
                                setState(() {
                                  isButtonDisabled = true;
                                  isSendOtpPressed = true;
                                });
                                Timer(
                                    const Duration(seconds: 10),
                                    () => setState(() {
                                          onTimerEnds = true;
                                        }));
                              },
                            ),
                      MaterialButton(
                        child: Ink(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25.0)),
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth: 100.0, minHeight: 50.0),
                            alignment: Alignment.center,
                            child: const Text(
                              "Verify OTP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          bool isCorrectOTP = resultChecker(otpverify.text);
                          if (isCorrectOTP) {
                            user.confirmed(phone);
                            final SharedPreferences sharedpreferences =
                                await SharedPreferences.getInstance();
                            sharedpreferences.setString('phone', phone);
                            Timer(const Duration(seconds: 2), () {
                              changeScreenReplacement(
                                  context, const HomePage());
                              Fluttertoast.showToast(
                                  msg: "Login successful",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });
                          } else {
                            otpverify.clear();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Your OTP is incorrect'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Ok'),
                                      onPressed: () {
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) => const LoginPage()),
                                        // );
                                        if (kDebugMode) {
                                          print('--hello this is opt');
                                          print(otpverify);
                                        }

                                        //otpverify.dispose();
                                        // cleartext();
                                        Navigator.of(context).pop('login_page');
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            if (kDebugMode) {
                              print("not verified");
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getTimer({bool isTimerEnd = false}) {
    if (isTimerEnd) {
      return const Text(""); // Return empty Text widget when timer ends
    } else {
      return TweenAnimationBuilder<Duration>(
        duration: const Duration(seconds: 60),
        tween: Tween(begin: const Duration(seconds: 60), end: Duration.zero),
        onEnd: () {
          setState(() {
            isTimerEnd = true;
          });
        },
        builder: (BuildContext context, Duration value, Widget? child) {
          final minutes = value.inMinutes;
          final seconds = value.inSeconds % 60;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '$minutes:$seconds',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          );
        },
      );
    }
  }
}

void getcode(number) async {
  Uri url = Uri.parse(
      'https://dors1qol6j.execute-api.ap-south-1.amazonaws.com/Seniorcitizen_Countrycode/');
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"phone_number": "$number" }';
  Response response = await post(url, headers: headers, body: json);
  var list = jsonDecode(response.body);
  code = list[0]["Country_Code"];
  if (kDebugMode) {
    print("New Otp entered -------------------------------");
    print(code);
  }

  zipcode = list[0]["Zipcode"];
}

void sendotpnew(String number) async {
  Uri url = Uri.parse(
      'https://gitpao19gl.execute-api.ap-south-1.amazonaws.com/Seniorcitizen_Sendotp/');
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"phone_number": "$number", "countrycode":"$code" }';
  // print("Sent otp");
  if (kDebugMode) {
    print(number);
    print(code);
  }

  Response response = await post(url, headers: headers, body: json);
  if (kDebugMode) {
    print(response.body);
  }
  var list = jsonDecode(response.body);
  newotp = list['body'].toString();
  if (kDebugMode) {
    print(newotp);
  }
}
