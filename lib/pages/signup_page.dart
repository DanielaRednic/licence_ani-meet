import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ani_meet/pages/reusable_widgets/reusable_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:ani_meet/pages/signin_page.dart';
import 'package:ani_meet/theme/colors.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

const List<String> gender_list = <String>['Female', 'Male', 'Other'];
const List<String> gender_interest_list = <String>['Female', 'Male', 'Other', 'Female & Male','Female & Other','Male & Other', 'Any'];

Future<bool> userExists(String username) async =>
      (await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: username).get()).docs.length > 0;

Map<String,bool> createInterestsMap(String interests){
  Map<String,bool> interestsMap={
    'Female' : false,
    'Male' : false,
    'Other' : false
  };

  if(interests.contains('Any')){
    interestsMap.updateAll((key, value) => true);
  }
  else{
    for(var gender in gender_list){
      if(interests.contains(gender)){
        interestsMap.update(gender, (value) => true);
      }
    }
  }
  return interestsMap;
}

Future<void> saveUser(UserCredential value,TextEditingController username,String gender_dropdownValue,String interest_dropdownValue,int age,TextEditingController dateController) async{
  var id = value.user!.uid;
  final storageRef = FirebaseStorage.instance.ref();
  final imageUrl = await storageRef.child('no_user_picture.png').getDownloadURL();
  print(imageUrl);
  await FirebaseChatCore.instance.createUserInFirestore(
    types.User(
      firstName: username.text,
      id: id,
      imageUrl: imageUrl
    )
  );
  print(id);
  Map<String,bool> interests = createInterestsMap(interest_dropdownValue);
  await FirebaseFirestore.instance.collection("users").doc(id).update({
    'liked': FieldValue.arrayUnion([]),
    'gender': gender_dropdownValue,
    'interests': interests,
    'age': age,
    'min_age': age,
    'max_age': age < 18 ? 17 : age+1,
    'birthday': dateController.text
  });

  await FirebaseFirestore.instance.collection('animes').doc(id).set({
    'number': 0,
    'info':[],
    'genres_general': {
      'action': {
        'liked_count': 0,
        'weight': 0.0
      },
      'adventure': {
        'liked_count': 0,
        'weight': 0.0
      },
      'comedy': {
        'liked_count': 0,
        'weight': 0.0
      },
      'fantasy': {
        'liked_count': 0,
        'weight': 0.0
      },
      'horror': {
        'liked_count': 0,
        'weight': 0.0
      },
      'romance': {
        'liked_count': 0,
        'weight': 0.0
      },
      'sci-fi': {
        'liked_count': 0,
        'weight': 0.0
      },
      'slice of life': {
        'liked_count': 0,
        'weight': 0.0
      }
    }
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

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  final dateController = TextEditingController();
  late int age;

  late String gender_dropdownValue;
  late String interest_dropdownValue;
  @override
  void initState(){
    super.initState();
    gender_dropdownValue = gender_list.first;
    interest_dropdownValue = gender_interest_list.first;
    age= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
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
                  reusableTextField(text: "Enter Username", icon: Icons.person_outline, isPasswordType: false, controller: _userNameTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField(text: "Enter Email", icon: Icons.person_outline, isPasswordType: false, controller: _emailTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField(text: "Enter Password", icon: Icons.lock, isPasswordType: true, controller: _passwordTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Center(
                        child: Column(children: [
                      TextField(
                        style: TextStyle(color: Colors.white),
                        readOnly: true,
                        controller: dateController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(width:0, style: BorderStyle.none)),
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          fillColor: Colors.white.withOpacity(0.3),
                          hintText: 'Enter your birthday',
                          hintStyle: TextStyle(color: white)),
                        onTap: () async {
                          var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));
                          if (date != null) {
                            setState(() {
                              age = calculateAge(date);
                            });
                            dateController.text = DateFormat('dd/MM/yyyy').format(date);
                          }
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      age == 0 ? 
                      Text('') :
                      Text(
                        age < 13 ? 'You are not old enough!'
                        :'You are $age years old!', 
                        style: TextStyle(color: white),
                        )
                      ]
                    )
                  )
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
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        print(value);
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
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        print(value);
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
                  signInSignUpButton(context, false, () async{
                    if(await userExists(_userNameTextController.text)) {
                      print('User already exists');
                    }
                    else{
                      FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text).then((value) async {
                          await saveUser(value, _userNameTextController,gender_dropdownValue,interest_dropdownValue,age,dateController);
                          print("Created New Account!");
                          Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignInScreen()));
                        }).onError((error, stackTrace) {
                          print("Error ${error.toString()}");
                      });
                    }
                  })
                ],
              ),
            )
          )
        ),
      );
  }
}