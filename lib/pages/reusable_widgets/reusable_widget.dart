import 'package:flutter/material.dart';
import 'package:ani_meet/theme/colors.dart';
  
Image logoWidget(String imageName) {
    return Image.asset(imageName, fit: BoxFit.fitWidth, width:240, height: 240
    );
}

class reusableTextField extends StatefulWidget {
  const reusableTextField({
  required this.text, 
  required this.icon, 
  required this.isPasswordType, 
  required this.controller
  });

  final String text;
  final IconData icon; 
  final bool isPasswordType;
  final TextEditingController controller;
  
  @override
  _reusableTextField createState() => _reusableTextField();

}

class _reusableTextField extends State<reusableTextField> {
  bool _hidePassword=true;

  void changeVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField (
    textInputAction: TextInputAction.done,
    controller: widget.controller,
    obscureText: widget.isPasswordType ? _hidePassword : false,
    enableSuggestions: !widget.isPasswordType,
    autocorrect: !widget.isPasswordType,
    enableInteractiveSelection: true,
    maxLength: 50,
    cursorColor: signin_two,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        widget.icon, 
        color: Colors.white70
    ),
    suffixIcon: widget.isPasswordType ? IconButton(
      icon: Icon(
        _hidePassword ? Icons.visibility_off : Icons.visibility,
        color: white,
      ),
      onPressed: () => changeVisibility()
    ) : null,
    labelText: widget.text,
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    fillColor: Colors.white.withOpacity(0.3),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(width:0, style: BorderStyle.none)),
    ),
    keyboardType: widget.isPasswordType
    ? TextInputType.visiblePassword
    : TextInputType.emailAddress,
  );
  }
}

Container signInSignUpButton(
  BuildContext context, bool isLogin, Function onTap) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        child: Text(
          isLogin ? 'Log In' : 'Sign Up',
          style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))))
      ),
  );
}