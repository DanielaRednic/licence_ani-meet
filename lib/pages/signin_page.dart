import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:ani_meet/pages/genres_page.dart';
import 'package:ani_meet/pages/reusable_widgets/reusable_widget.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:ani_meet/pages/root_app.dart';
import 'package:ani_meet/pages/signup_page.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:ani_meet/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration:const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/ani-meet-color-scheme.jpg"),
              fit: BoxFit.cover,
          )
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  logoWidget("assets/images/logo_white.png"),
                  SizedBox(
                    height: 30,
                  ),
                  reusableTextField(text: "Enter Email", icon: Icons.person_outline, isPasswordType: false, controller: _emailTextController),
                  SizedBox(
                    height: 20,
                  ),
                  reusableTextField(text: "Enter Password", icon: Icons.lock, isPasswordType: true, controller: _passwordTextController),
                  SizedBox(
                    height: 20,
                  ),
                  signInSignUpButton(context, true, () {
                    FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text).then((value) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => RootPage()));
                      }).onError((error, stackTrace) {
                          print("Error ${error.toString()}");
                      });
                  }),
                  signUpOption()
              ],
            ),
          ),
        )
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
        style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}