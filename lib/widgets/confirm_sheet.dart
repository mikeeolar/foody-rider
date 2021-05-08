import 'package:flutter/material.dart';
import 'package:foody_rider/brand_colors.dart';
import 'package:foody_rider/widgets/rider_button.dart';
import 'package:foody_rider/widgets/rider_outlined_button.dart';

class ConfirmSheet extends StatelessWidget {

  final String title;
  final String subtitle;
  final Function onPressed;

  ConfirmSheet({this.title, this.subtitle, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 15,
          spreadRadius: 0.5,
          offset: Offset(0.7, 0.7),
        )
      ]),
      height: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Brand-Bold',
                color: BrandColors.colorText,
              ),
            ),

            SizedBox(
              height: 20,
            ),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BrandColors.colorTextLight,
              ),
            ),

            SizedBox(
              height: 20,
            ),

            Row(
              children: [
                Expanded(
                  child: Container(
                    child: RiderOutlinedButton(
                      title: 'BACK',
                      color: BrandColors.colorLightGrayFair,
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),

                SizedBox(width: 16,),

                Expanded(
                  child: Container(
                    child: RiderButton(
                      title: 'CONFIRM',
                      color: (title == 'GO ONLINE') ? BrandColors.colorGreen
                          : Colors.red,
                      onPressed: onPressed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
