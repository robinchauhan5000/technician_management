import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:technician_time_app/services/api_service.dart';



TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 45.0),
          userNameTextField(),
          SizedBox(height: 25.0),

          passwordTextField(),
          SizedBox(height: 25.0),
          loginButton(context)
        ],
      ),
    );
  }

 loginButton(BuildContext context) async {
    return Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.red,
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              onPressed: () async {
                try {
                  await ApiService.login(
                      usernameController.text, passwordController.text);
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (error) {
                  Fluttertoast.showToast(
                      msg: "Incorrect Credentials",

                      // toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.red,
                      textColor: Colors.blue,
                      fontSize: 50.0);
                }
              },
              child: Text("Login",
                  textAlign: TextAlign.center,
                  style: style.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ));
  }

  TextFormField passwordTextField() {
    return TextFormField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
            controller: passwordController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                hintText: "Password",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.00))));
  }

  TextFormField userNameTextField() {
    return TextFormField(
            autofocus: true,
            obscureText: false,
            enableSuggestions: false,
            autocorrect: false,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
            controller: usernameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                hintText: "Username",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.00),),),);
  }
}
