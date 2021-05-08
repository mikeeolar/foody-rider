import 'package:flutter/material.dart';
import 'package:foody_rider/brand_colors.dart';

class RiderOutlinedButton extends StatelessWidget {

  final String title;
  final Function onPressed;
  final Color color;

  RiderOutlinedButton({this.title, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            // primary: color,
          side: BorderSide(color: color),
        ),
        onPressed: onPressed,
        child: Container(
          height: 50.0,
          child: Center(
            child: Text(title,
                style: TextStyle(fontSize: 15.0, fontFamily: 'Brand-Bold', color: BrandColors
                    .colorText)),
          ),
        )
    );
  }
}


