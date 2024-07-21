import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getx;
import 'package:http/http.dart';

import 'package:intl/intl.dart';
import 'package:precision_hub/dynamic_links/ui/home_screen.dart';
import 'package:precision_hub/dynamic_links/utils/constants/app_constants.dart';
import 'package:precision_hub/dynamic_links/utils/dialog_utils.dart';
import 'package:precision_hub/fetchfunctions/getZoomUrl.dart';
import 'package:precision_hub/fetchfunctions/new_appoitment_function.dart';
import 'package:precision_hub/fetchfunctions/user_info.dart';
import 'package:precision_hub/models/userModel.dart';
import 'package:precision_hub/screens/Appointments/new_appointment_ui.dart/upcoming_appointments.dart';
import 'package:precision_hub/screens/doctor_patient/doctor_home.dart';
import 'package:precision_hub/utils/use_12_hour_format.dart';
import 'package:precision_hub/widgets/custom_widgets/time_picker.dart';

import '../../../fetchfunctions/fetch_upcoming_appointments.dart';
import '../../../models/appointment_model.dart';
import '../../../utils/email_utils.dart';
import '../../../widgets/custom_widgets/date_picker.dart';

class AddAppointment extends StatefulWidget {
  const AddAppointment({Key? key}) : super(key: key);

  @override
  State<AddAppointment> createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  final _storage = const FlutterSecureStorage();

  //form key to submit the form
  final _formKey = GlobalKey<FormState>();

  //switch for zoom url
  bool isSwitched = false;

  //initial values for date and time
  DateTime currTime = DateTime.now();
  String appointmentDate = DateFormat('MMMM d, y').format(DateTime.now());
  String appointmentTime = "";

  //variables used to send mail
  String userFullname = "";
  String userPhone = "";
  var timeIsValid = "true";
  //date and time controllers
  TextEditingController appointmentDateController = TextEditingController();
  TextEditingController appointmentTimeController = TextEditingController();

  //varaibles for deep linking
  late BranchUniversalObject buo;
  late BranchLinkProperties lp;
  late BranchResponse response;
  String result = "";

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  Future getUserData() async {
    String? phone = await _storage.read(key: 'Phone');
    UserData userInfo = await UserInfo.fetchUserInfo(phone!);
    setState(() {
      userFullname = userInfo.fullName;
      userPhone = userInfo.usersPhone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottomOpacity: 0,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: (getx.Get.arguments['image'].contains(".svg"))
                              ? const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png')
                              : NetworkImage(getx.Get.arguments['image']),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              getx.Get.arguments['doctorName'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              getx.Get.arguments['speciality'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Select Date",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            DatePicker(
              label: "Date",
              circularRadius: MediaQuery.of(context).size.height * 0.02,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(
                    currTime.year,
                    currTime.month,
                    currTime.day + 1,
                  ),
                  firstDate: DateTime(
                    currTime.year,
                    currTime.month,
                    currTime.day + 1,
                  ),
                  lastDate: DateTime(
                    currTime.year + 1,
                    currTime.month,
                    currTime.day,
                  ),
                );

                if (pickedDate != null) {
                  String formattedDate = DateFormat('MMMM d, y').format(pickedDate);

                  setState(
                    () {
                      appointmentDate = formattedDate;
                      appointmentDateController.text = appointmentDate;
                    },
                  );
                } else {}
              },
              controller: appointmentDateController,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Available Slots",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            TimePicker(
              label: " Time",
              controller: appointmentTimeController,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  initialTime: TimeOfDay.now(),
                  context: context,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                      child: child ?? Container(),
                    );
                  },
                );
                if (pickedTime != null) {
                  String pickTimeIn24hrFormat = use12HourFormat(pickedTime, MaterialLocalizations.of(context));

                  DateTime parsedTime = DateFormat.jm().parse(pickTimeIn24hrFormat);
                  String formattedTime = DateFormat("h:mm a").format(parsedTime);
                  setState(
                    () {
                      appointmentTimeController.text = formattedTime;
                      appointmentTime = appointmentTimeController.text;
                    },
                  );
                } else {}
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: Text(
                    'Add video call link',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                        if (isSwitched == true) {
                          getZoomUrl(appointmentDate, appointmentTime , getx.Get.arguments['doctorName']);
                        }
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),



            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                ),
                child: const Text("Book Appointment"),
                onPressed: ()  async {
                  // print("details are");
                  // print(appointmentDateController.text);
                  // print(userPhone);
                   print(timeIsValid);
                  // setState(() async {
                   await validateTime(appointmentDateController.text,appointmentTimeController.text,userPhone);
                    if (kDebugMode) {
                      print(timeIsValid);
                    }
                  // });
                  if(timeIsValid == 'true'){
                  if (_formKey.currentState!.validate() &&
                      await newAppointment(userPhone, getx.Get.arguments['doctorName'], appointmentDateController.text,
                              appointmentTimeController.text, appointmentTimeController.text, uniqueZoomUrl, password) ==
                          true) {
                    _generateDeepLink(context);
                    String doctorName =  getx.Get.arguments['doctorName'];
            //        DateTime date = DateFormat('MMMM d, y').parse(appointmentDate);
                 //   DateTime time = DateFormat.jm().parse(appointmentTime);
                    // afterAppointment(
                    //     userFullname, date, time, doctorName, uniqueZoomUrl, password, phone, code, appointmentDate);

                 //   Navigator.of(context).pop();
                   // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewAppointmentPage()));
                   //  Navigator.of(context).pop();
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const NewAppointmentPage()));
                    String? date =  appointmentDateController.text;
                    List<String?> parts = date.split(",");
                    print(parts[0]);
                    print(parts[0].runtimeType);
                    String dateFinal = parts[0].toString();
                    String? countryCode = await _storage.read(key: "Country_Code");
                    String? phoneFinal =  await _storage.read(key: "Phone");
                    await sendEmail(doctorName, userFullname, dateFinal, phoneFinal!, countryCode!, appointmentTimeController.text, uniqueZoomUrl, password);
                    Fluttertoast.showToast(
                        msg: "Appointment Booked successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                }
                 else {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const NewAppointmentPage()),
                    // );
                    // Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: "Appointment already exists in that time",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                // Navigator.of(context).pop();
                   Navigator.pop(context);
                  //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const NewAppointmentPage()));
                  setState(
                    () {
                      clearForm();
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void clearForm() {
    appointmentDateController.clear();
    appointmentTimeController.clear();
    appointmentDate = "";
    appointmentTime = "";
  }

  //deeplinking
  void listenDeepLinkData(BuildContext context) async {
    streamSubscriptionDeepLink = FlutterBranchSdk.initSession().listen((data) {
      if (data.containsKey(AppConstants.clickedBranchLink) && data[AppConstants.clickedBranchLink] == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DoctorsHome(
                      phone: data["ammu"],
                    )));
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
    });
  }

  //To Setup Data For Generation Of Deep Link
  void initializeDeepLinkData() {
    buo = BranchUniversalObject(
      canonicalIdentifier: AppConstants.branchIoCanonicalIdentifier,
      contentMetadata: BranchContentMetaData()..addCustomMetadata("ammu", phone),
    );
    FlutterBranchSdk.registerView(buo: buo);

    lp = BranchLinkProperties();
    lp.addControlParam(AppConstants.controlParamsKey, '1');
  }
 Future<void> validateTime(String date,String time,String phone) async{
    Uri url = Uri.parse('https://is6kkaby26.execute-api.ap-south-1.amazonaws.com/fetchingAppointments/fetchappointmentsghp');
    Map<String, String> headers = {"Content-type": "application/json"};
    String json = '{"Phone": "$phone"}';
    Response response = await post(url, headers: headers, body: json);
    int statusCode = response.statusCode;
    var jsonData = jsonDecode(response.body);

    List<Appointment> appointments = [];
    for (var u in jsonData) {

      Appointment appointment = Appointment(u['DoctorName'], u['AppointmentDate'], u['AppointmentTime'],u['ZoomUrl']);
      if (DateFormat('MMMM d, y').parse(appointment.appointmentDate).isAfter(DateTime.now())) {
        appointments.add(appointment);

      }
    }
    appointments.sort((a, b) => combineDateTime(a).compareTo(combineDateTime(b)));
    // String currDate = DateFormat('MMMM d, y').format(DateTime.now()).toString();
    // Uri url = Uri.parse('https://is6kkaby26.execute-api.ap-south-1.amazonaws.com/fetchingAppointments/fetchappointmentsghp');
    // Map<String, String> headers = {"Content-type": "application/json"};
    // String json = '{"Phone": "$phone"}';
    // Response response = await post(url, headers: headers, body: json);
    // var jsonData = jsonDecode(response.body);
    // List<Appointment> appointments = [];
    //
    // for (var u in jsonData) {
    //   Appointment appointment = Appointment(u['DoctorName'], u['AppointmentDate'], u['AppointmentTime']);
    //   if (DateFormat('MMMM d, y').parse(appointment.appointmentDate).isBefore(DateTime.now())) {
    //     appointments.add(appointment);
    //
    //   }
    // }
    //
    // appointments.sort((a, b) => combineDateTime(b).compareTo(combineDateTime(a)));
    //
    List<String> timeMeridian = time.split(" ");
    for (int i=0;i<appointments.length;i++){
      String timePrevious = appointments[i].appointmentTime;
      List<String> timePreviousMeridian = timePrevious.split(" ");
      List<String> timeMeridianSplit= timeMeridian[0].split(":");
      List<String> timePreviousMeridianSplit= timePreviousMeridian[0].split(":");
      var timeHours= int.tryParse(timeMeridianSplit[0]) ?? -1;
      var timePreviousHours = int.tryParse(timePreviousMeridianSplit[0]) ?? -1;
      var timeMinutes = int.tryParse(timeMeridianSplit[1]) ?? -1;
      var timePreviousMinutes =  int.tryParse(timePreviousMeridianSplit[1]) ?? -1;
      var totalTime = timeHours * 60 + timeMinutes;
      var totalTimePrevious = timePreviousHours * 60 + timePreviousMinutes;
      if (kDebugMode) {
        print(totalTimePrevious);
        print(totalTime);
        print(totalTime-1);
      }

      // int.parse(timeMeridianSplit[0]);
      // int.parse(timePreviousMeridian[0]);
      // int.parse(timeMeridianSplit[1]);
      // int.parse(timePreviousMeridianSplit[1]);
      // num timeHours = int.parse(timeMeridianSplit[0]) * 60 ;
      // num timeMeridianHours =  int.parse(timePreviousMeridian[0]) * 60;
      // num totalTime = timeHours + int.parse(timeMeridianSplit[1]);
      // num totalTimePrevious = timeMeridianHours + int.parse(timePreviousMeridianSplit[1]);

      if (kDebugMode) {
        // print(dt);
        // print(dtPrev);
        // print(date);
        // print(appointments[i].appointmentDate);
        // print(date == appointments[i].appointmentDate);
        // print(time);
        // print(appointments[i].appointmentTime);
        // print(timeMeridian[1]);
        // print(timePreviousMeridian[1]);
      }
      // int.parse(appointments[i].appointmentDate);
      // int.parse(appointments[i].appointmentTime);
      // if(appointments[i].appointmentDate == ' '){
      //   timeIsValid = true;
      // }
      if(date == appointments[i].appointmentDate && (timeMeridian[1]==timePreviousMeridian[1])  && ((totalTime - 60) < (totalTimePrevious)) && (totalTimePrevious<(totalTime+60))){
        timeIsValid = 'false';
        break;
        //  if(timePreviousMeridian == timeMeridian ){
        //    timeIsValid = 'false';
        //    break;
        // }
      }
      else{
        timeIsValid = 'true';
      }
    }
    if (kDebugMode) {
      print(timeIsValid);
    }
   // return timeIsvalid;
    //   print("Hi there");
    //   print(timeIsvalid);
    //   // else{
    //   //   timeIsvalid = true;
    //   // }
    //
    // }

  }
  //To Generate Deep Link For Branch Io
  void _generateDeepLink(BuildContext context) async {
    BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      result = response.result;
      ToastUtils.displayToast("${response.result}");
    } else {}
  }
}
