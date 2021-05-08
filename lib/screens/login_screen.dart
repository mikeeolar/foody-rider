import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_rider/screens/dashboard_screen.dart';
import 'package:foody_rider/screens/registration_screen.dart';
import 'package:foody_rider/widgets/input_field.dart';
import 'package:foody_rider/widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  void _showSnackBar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    ));
  }

  Future<void> _loginUser() async {
    UserCredential userCredential;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) => ProgressDialog(status: 'Login...'));

    try {
      userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      if (userCredential.user == null) {
        return;
      }

      Navigator.pop(context);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext ctx) => DashboardScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackBar('No user found for that email.');
        Navigator.of(context).pop();
      } else if (e.code == 'wrong-password') {
        _showSnackBar('Wrong password provided for that user.');
        Navigator.of(context).pop();
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Sign In',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InputField('Email', TextInputType.emailAddress, emailController),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 15),
                      hintText: 'Password',
                      hintStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(50.0),
                      color: Colors.green,
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width * 0.7,
                        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                        onPressed: () async {
                          if (emailController.text.isEmpty) {
                            _showSnackBar('Please provide a valid email');
                            return;
                          }
                          await _loginUser();
                        },
                        child: Text('Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext ctx) => RegistrationScreen()));
                      },
                      child: Text(
                        'Don\'t have '
                        'an account, Sign up here',
                        style: TextStyle(fontSize: 16),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
