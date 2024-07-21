import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:precision_hub/screens/Registration/additional_info.dart';
import 'package:precision_hub/widgets/User_Provider.dart';
import 'package:precision_hub/widgets/custom_widgets/auth_button.dart';
import 'package:precision_hub/widgets/custom_widgets/date_picker.dart';
import 'package:precision_hub/widgets/custom_widgets/drop_down.dart';
import 'package:precision_hub/widgets/custom_widgets/text_box.dart';
import 'package:precision_hub/widgets/custom_widgets/text_box_login.dart';
import 'package:precision_hub/widgets/custom_widgets/top_splash.dart';
import '../Code/Code.dart';


String finalcode=" ";
String CompanyName= " ";

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final user = UserProvider();

  String gender = "Female";
  String countryCode = "+1";

  String UnqCode= "";

  //controllers
  TextEditingController fullName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController zipCode = TextEditingController();
  // TextEditingController refferalCode = TextEditingController();
  TextEditingController Phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController fieldText = TextEditingController();
  TextEditingController dateinput = TextEditingController();
  TextEditingController ComName = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  //height initial values
  String heightUnit = 'm/cm';
  String feet = "";
  String inch = "";
  String meter = "";
  String cm = "";

  //weight intial values
  String weightUnit = 'kg';

  //initial values
  String genderDropdownCurValue = 'Female';
  List<String> genderDropDownValues = ['Female', 'Male', 'Others'];

  String countryDropdownCurValue = 'India';

  static List<String> heightList = ['ft/in', 'm/cm'];
  String heightTypeCurrentValue = heightList[1];

  static List<String> weightList = ['kg', 'lbs'];
  String weightCurrentValue = weightList[0];

  static List<String> feetList = ['2', '3', '4', '5', '6', '7', '8'];
  String feetCurrentValue = feetList[0];

  static List<String> inchList = List<String>.generate(12, (i) => "$i");
  String inchCurrentValue = inchList[0];

  static List<String> meterList = ['1', '2', '3', '4'];
  String meterCurrValue = meterList[0];

  static List<String> cmList = List<String>.generate(100, (i) => "$i");
  String cmCurrValue = cmList[0];

  //for country code
  String? _currentAddress;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude).then((List<Placemark> placemarks) {
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

  //init
  @override
  void initState() {
    super.initState();
    dateinput.text = "";
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(_currentAddress);
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Code()));
        return false; // return true if you want to prevent the back button press, otherwise return false
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              const TopSplashWidget(imagePath: 'assets/images/rhenix_logo.png'),
              BorderedTextField(
                labelText: "Name",
                borderRadius: MediaQuery.of(context).size.height * 0.02,
                padding: MediaQuery.of(context).size.height * 0.015,
                keyboardType: TextInputType.text,
                controller: fullName,
                validator: validateName,

                // {
                //   if (text == "") {
                //     return "Please enter your name";
                //   }
                //   return null;
                // },
              ),
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
                child: IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.02),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.02),
                    ),
                  ),
                  initialCountryCode: _currentAddress,
                  onChanged: (phone) {
                    setState(
                          () {
                        Phone.text = phone.number;
                        // countryCode = phone.countryCode;
                        if (kDebugMode) {
                          print(countryCode);
                        }

                      },
                    );
                  },
                  onCountryChanged:(code){
                    setState(
                          () {
                        // Phone.text = phone.number;
                        countryCode = "+${code.dialCode}";
                        if (kDebugMode) {
                          print(countryCode);
                        }
                      },
                    );
                  },
                ),
              ),
              BorderedTextField(
                labelText: "Email",
                borderRadius: MediaQuery.of(context).size.height * 0.02,
                padding: MediaQuery.of(context).size.height * 0.015,
                keyboardType: TextInputType.emailAddress,
                controller: email,
                validator: validateEmail,
                // validator: (text) {
                //   if (text == "") {
                //     return "Please enter your email";
                //   }
                //   return null;
                // },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DatePicker(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter DOB';
                        }
                        return null;
                      },
                      label: "DOB",
                      circularRadius: MediaQuery.of(context).size.height * 0.02,
                      onTap: () async {
                        DateTime? pickedDate =
                        await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());

                        if (pickedDate != null) {
                          String formattedDate = DateFormat('MMMM d, y').format(pickedDate);
                          if (mounted) {
                            setState(() {
                              dateinput.text = formattedDate;
                              Age = dateinput;
                            });
                          } else {
                            if (kDebugMode) {
                              print("Date is not selected");
                            }

                          }
                        }
                      },
                      controller: dateinput,
                    ),
                  ),
                  Expanded(
                    child: DropDown(
                      leftAndRightPadding: MediaQuery.of(context).size.height * 0.015,
                      borderRadius: MediaQuery.of(context).size.height * 0.02,
                      dropdownItems: genderDropDownValues,
                      hint: const Text("Gender"),
                      onPressed: (String newValue) {
                        if (mounted) {
                          setState(
                                () {
                              genderDropdownCurValue = newValue;
                              gender = newValue;
                            },
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BorderedTextField(
                      labelText: "Zipcode",
                      borderRadius: MediaQuery.of(context).size.height * 0.02,
                      padding: MediaQuery.of(context).size.height * 0.015,
                      keyboardType: TextInputType.number,
                      controller: zipCode,
                      validator: (text) {
                        if (text!.length > 6 || text.isEmpty || !RegExp(r'^\d{5}$').hasMatch(text)) {
                          return "Enter valid zip";
                        }
                        return null;
                      },
                    ),
                  ),
                  Expanded(
                    child: BorderedTextFieldLogin(
                      labelText: "Company Name",
                      borderRadius: MediaQuery.of(context).size.height * 0.02,
                      padding: MediaQuery.of(context).size.height * 0.015,
                      keyboardType: TextInputType.text,
                      controller: ComName,
                      validator: (text) {
                        if(text!.isEmpty){
                        return " ";
                        }
                        else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(text)) {
                          return ' Invalid Company name';
                        }
                       return null;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15.0),
              AuthButton(
                buttonText: "Signup",
                leftPadding: MediaQuery.of(context).size.height * 0.03,
                rightPadding: MediaQuery.of(context).size.height * 0.03,
                onPressed: () async {
                  Text(_formKey.currentState?.validate() == false ? '' : ' ');
                   validateRegForm();
                  CompanyName = ComName.text;
                  UnqCode = CompanyName;
                  if(UnqCode.isNotEmpty){
                  finalcode = UnqCode.substring(0,4).toLowerCase();}
                  else{
                    finalcode = " ";
                  }
                  if (_formKey.currentState!.validate()) {
                    if (await user.signUp(Phone.text, fullName.text, Age.text, zipCode.text, gender, countryCode, email.text,finalcode,ComName.text) == true) {


                      // Navigator.of(context).pushReplacement(
                      //   MaterialPageRoute(
                      //       builder: (context) => AdditionalDetails(
                      //             phone: Phone.text,
                      //             headerText: "Additinal Info",
                      //             buttonText: "Register",
                      //             destWidget: const LoginPage(),
                      //           )),
                      // );
                     if(UnqCode.isNotEmpty ) {
                       Fluttertoast.showToast(
                           msg: "Signed up Successfully",
                           toastLength: Toast.LENGTH_SHORT,
                           gravity: ToastGravity.BOTTOM,
                           timeInSecForIosWeb: 1,
                           backgroundColor: Colors.blue,
                           textColor: Colors.white,
                           fontSize: 16.0);
                       showDialog(
                         context: context,
                         builder: (BuildContext context) {
                           return AlertDialog(
                             title: Text('Your code is $finalcode'),
                             actions: <Widget>[
                               // TextButton(
                               //   child: const Text(
                               //     'Yes, Logout',
                               //     style: TextStyle(color: Colors.red),
                               //   ),
                               //   onPressed: () {
                               //     user.signOut();
                               //     Navigator.push(
                               //       context,
                               //       MaterialPageRoute(
                               //         builder: (context) {
                               //           return const LoginPage();
                               //         },
                               //       ),
                               //     );
                               //   },
                               // ),
                               TextButton(
                                 child: const Text('Got it '),
                                 onPressed: () {
                                   print("Phone.textr here");
                                   String phoneNumNew = Phone.text;
                                   Navigator.of(context).pushReplacement(
                                     MaterialPageRoute(
                                         builder: (context) =>
                                             AdditionalDetails(
                                               phone: phoneNumNew,
                                               headerText: "Height and Weight Info",
                                               buttonText: "Register",
                                               destWidget: const Code(),

                                             )),
                                   );
                                   clearForm();
                                 },
                               ),
                             ],
                           );
                         },
                       );
                     }
                     else{
                       Fluttertoast.showToast(
                           msg: "Signed up Successfully",
                           toastLength: Toast.LENGTH_SHORT,
                           gravity: ToastGravity.BOTTOM,
                           timeInSecForIosWeb: 1,
                           backgroundColor: Colors.white,
                           textColor: Colors.blue,
                           fontSize: 16.0);
                       print("Phone.textr here");
                       String phoneNumNew = Phone.text;
                       Navigator.of(context).pushReplacement(
                         MaterialPageRoute(
                             builder: (context) =>
                                 AdditionalDetails(
                                   phone: phoneNumNew,
                                   headerText: "Additinal Info",
                                   buttonText: "Register",
                                   destWidget: const Code(),

                                 )),
                       );
                       clearForm();
                     }
                    } else {
                      if (!await user.signUp(Phone.text, fullName.text, Age.text, zipCode.text, gender, countryCode, email.text,finalcode,ComName.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User already exist")),
                        );
                      }
                    }
                  }
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              LimitedBox(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Code()));
                      },
                      child: Text(
                        'Login',
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
      ),);
  }
  bool validateRegForm() {
    if ((fullName.text == "" || Phone.text == "" || email.text == "" || dateinput.text == "" || zipCode.text == "" )) {
      Fluttertoast.showToast(
          msg: "Please enter all details",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
   return true;
  }
  void clearText() {
    fieldText.clear();
  }

  void clearForm() {
    fullName.clear();
    Phone.clear();
    Age.clear();
    zipCode.clear();
    weight.clear();
  }
}

String? validateEmail(String? value) {
  const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  final regex = RegExp(pattern);
  if(value!.isNotEmpty && !regex.hasMatch(value)){
    return 'Enter a valid email address';
  }
  else if (value.isEmpty){
    return 'Please enter email';
  }
  return null;
  // return value!.isNotEmpty && !regex.hasMatch(value)
  //     ? 'Enter a valid email address'
  //     : "null";
}
String? validateName(String? value) {
  const pattern = r"^[a-zA-Z ]*$";
  final regex = RegExp(pattern);
   if (value!.isEmpty){
  return 'Please enter name';
  }
  else if(value.isNotEmpty && !regex.hasMatch(value)){
    return 'Enter a valid name';
  }
   return null;

  // return value!.isNotEmpty && !regex.hasMatch(value)
  //     ? 'Enter a valid Name'
  //     : "null";

}