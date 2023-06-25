import 'package:ani_meet/pages/account_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ani_meet/pages/reusable_widgets/reusable_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:ani_meet/pages/signin_page.dart';
import 'package:ani_meet/theme/colors.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:intl/intl.dart';

import 'functions/gender_and_interests.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

const List<String> gender_list = <String>['Female', 'Male', 'Other'];
const List<String> gender_interest_list = <String>['Female', 'Male', 'Other', 'Female & Male','Female & Other','Male & Other', 'Any'];

Future<void> updateUser(String id,String gender_dropdownValue,String interest_dropdownValue,int age, int minimum_interestAge, int maximum_interestAge) async{
  print(id);
  Map<String,bool> interests = createInterestsMap(interest_dropdownValue);
  await FirebaseFirestore.instance.collection("users").doc(id).update({
    'liked': FieldValue.arrayUnion([]),
    'gender': gender_dropdownValue,
    'interests': interests,
    'age': age,
    'min_age': minimum_interestAge,
    'max_age': maximum_interestAge
  });
}

int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

class _SettingsScreenState extends State<SettingsScreen> {
  bool isChanged = false;
  late int age;

  late String gender_dropdownValue;
  late String interest_dropdownValue;
  late int minimum_interestAge;
  late int maximum_interestAge;
  late List<int> ageList_under18;
  late List<int> ageList_over18;
  @override
  void initState(){
    super.initState();
    gender_dropdownValue = gender_list.first;
    interest_dropdownValue = gender_interest_list.first;
    age = 0;
    ageList_under18 = getAges_under18(13);
    ageList_over18 = getAges_over18(18);
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.2),
      body: getBody(),
    );
  }

Widget getBody() {
    String id= FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(id).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> user) {
            if(user.hasData){
              var userInfo = user.data?.data() as Map<String,dynamic>;
              if(isChanged == false){
                var interests = getUserGenderInterest(userInfo['interests']);
                minimum_interestAge = userInfo['min_age'];
                maximum_interestAge = userInfo['max_age'];
                gender_dropdownValue = userInfo['gender'];
                age = userInfo['age'];
                interest_dropdownValue = interests;
              }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration:const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/ani-meet-color-scheme.jpg"),
              fit: BoxFit.cover,
              )
            ),
            child: SingleChildScrollView(child: Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Your age: "+userInfo['age'].toString(),
                      style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 110),
                    child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                      SizedBox(
                        height: 5,
                      ),
                      ]
                    )
                  )
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Your gender:",
                      style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                   DropdownButton<String>(
                    value: gender_dropdownValue,
                    icon: const Icon(Icons.person, color: white,),
                    elevation: 16,
                    dropdownColor: hot_orange,
                    style: const TextStyle(color: white),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        //print(value);
                        isChanged = true;
                        gender_dropdownValue = value!;
                      });
                    },
                    items: gender_list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Gender interests:",
                      style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButton<String>(
                    value: interest_dropdownValue,
                    icon: const Icon(Icons.people, color: white,),
                    elevation: 16,
                    dropdownColor: hot_orange,
                    style: const TextStyle(color: white),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        //print(value);
                        isChanged = true;
                        interest_dropdownValue = value!;
                      });
                    },
                    items: gender_interest_list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  RichText(
                    text: TextSpan(
                      text: "Age group",
                      style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      text: "Lower limit:",
                      style: TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5),
                CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          borderRadius: BorderRadius.circular(25),
                          minSize: 50,
                          color: Colors.black,
                          onPressed: () => showCupertinoModalPopup(
                            context: context,
                            builder: (_) => SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              itemExtent: 30,
                              scrollController: FixedExtentScrollController(
                                initialItem: 0
                              ),
                              children: userInfo['age'] < 18 ? [
                                for(int i = 0; i <= ageList_under18.indexOf(maximum_interestAge); i++)...
                                [
                                  Text('${ageList_under18[i]}'),
                                ]
                              ] : [
                                for(int i = 0; i <= ageList_over18.indexOf(maximum_interestAge); i++)...
                                [
                                  Text('${ageList_over18[i]}'),
                                ]
                              ],
                              onSelectedItemChanged: (int value) {
                                setState(() {
                                  isChanged = true;
                                  if(userInfo['age'] < 18){
                                    minimum_interestAge = ageList_under18[value];
                                  }
                                  else{
                                     minimum_interestAge = ageList_over18[value];
                                  }
                                });
                              },
                              )
                            ),
                          ),
                          child: Container(constraints: const BoxConstraints(maxWidth: 50,minWidth: 50),
                            alignment: Alignment.center,
                            child:Text('$minimum_interestAge', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24))
                          )
                        ),
                        SizedBox(height: 20),
                        RichText(
                    text: TextSpan(
                      text: "Upper limit:",
                      style: TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          borderRadius: BorderRadius.circular(25),
                          minSize: 50,
                          color: Colors.black,
                          onPressed: () => showCupertinoModalPopup(
                            context: context,
                            builder: (_) => SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              itemExtent: 30,
                              scrollController: FixedExtentScrollController(
                                initialItem: 0
                              ),
                              children: userInfo['age'] < 18 ? [
                                for(int i = ageList_under18.indexOf(minimum_interestAge+1) ; i <= ageList_under18.length-1; i++)...
                                [
                                  Text('${ageList_under18[i]}'),
                                ]
                              ] : [
                                for(int i = ageList_over18.indexOf(minimum_interestAge+1); i <= ageList_over18.length-1; i++)...
                                [
                                  Text('${ageList_over18[i]}'),
                                ]
                              ],
                              onSelectedItemChanged: (int value) {
                                setState(() {
                                  isChanged = true;
                                  if(userInfo['age'] < 18){
                                    maximum_interestAge = ageList_under18[value];
                                  }
                                  else{
                                     maximum_interestAge = ageList_over18[value]+1;
                                  }
                                });
                              },
                              )
                            ),
                            
                          ),
                          child: Container(constraints: const BoxConstraints(maxWidth: 50,minWidth: 50),
                            alignment: Alignment.center,
                            child:Text('$maximum_interestAge', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24))
                          )
                        ),
                        SizedBox(height: 60),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),

                          ),
                        child:
                        ElevatedButton(
                    onPressed: () async{
                      updateUser(id, gender_dropdownValue, interest_dropdownValue, age, minimum_interestAge, maximum_interestAge);
                    },
                    style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                            shadowColor: Colors.transparent,
                          ),
                    child: Text("Save changes"),
                  ),
                        ),
                ],
              ),
            )
          )
        ),
      );
      }
      else
      {
          return Container(child: const CircularProgressIndicator(color: hot_pink));
      }
      }
    );
    }
}