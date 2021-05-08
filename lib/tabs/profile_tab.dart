import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_rider/screens/login_screen.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: TextButton(
      child: Text('Logout'),
      onPressed: () {
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            LoginScreen()), (route) => false);
      },
    ));
  }
}
