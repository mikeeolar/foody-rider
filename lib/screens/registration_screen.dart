import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foody_rider/screens/dashboard_screen.dart';
import 'package:foody_rider/screens/login_screen.dart';
import 'package:foody_rider/widgets/input_field.dart';
import 'package:foody_rider/widgets/progress_dialog.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = 'registration';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;

  void _showSnackBar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    ));
  }

  Future<void> _registerUser() async {
    UserCredential userCredential;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) => ProgressDialog(status: 'Registering...'));

    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      if (userCredential.user == null) {
        return;
      }

      Navigator.pop(context);

      DatabaseReference newUserRef =
      FirebaseDatabase.instance.reference().child('riders/${userCredential.user.uid}');

      newUserRef.set({
        'full_name': fullNameController.text,
        'email': emailController.text,
        'phone_no': phoneNoController.text
      });

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          DashboardScreen()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('The password provided is too weak.'),
          backgroundColor: Theme.of(context).errorColor,
        ));
        Navigator.of(context).pop();
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('The account already exists for that email.'),
          backgroundColor: Theme.of(context).errorColor,
        ));
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
                        'Create new account',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          maxRadius: 50,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.person,
                            size: 80.0,
                          ),
                        ),
                        Positioned(
                          top: 60,
                          left: 60,
                          child: CircleAvatar(
                            child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {}),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InputField('Full Name', TextInputType.text, fullNameController),
                  SizedBox(
                    height: 10,
                  ),
                  InputField('Email', TextInputType.emailAddress, emailController),
                  SizedBox(
                    height: 10,
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
                    height: 10,
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 15),
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InputField('Phone Number', TextInputType.phone, phoneNoController),
                  SizedBox(
                    height: 20,
                  ),
                  Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(50.0),
                      color: Colors.green,
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width * 0.7,
                        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                        onPressed: () async {
                          if (fullNameController.text.isEmpty) {
                            _showSnackBar('Please provide a valid first name');
                            return;
                          } else if (passwordController.text != confirmPasswordController.text) {
                            _showSnackBar('Password mismatch');
                          }
                          await _registerUser();
                        },
                        child: Text('Register',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (BuildContext ctx) => LoginScreen()));
                      },
                      child: Text(
                        'Already have '
                        'an account, Login here',
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
