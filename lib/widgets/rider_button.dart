import 'package:flutter/material.dart';

class RiderButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function onPressed;

  const RiderButton({this.title, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          primary: color
      ),
      child: Container(
        height: 50,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold', color: Colors.white),
          ),
        ),
      ),
    );
  }
}
