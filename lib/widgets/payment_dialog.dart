import 'package:flutter/material.dart';
import 'package:foody_rider/brand_colors.dart';
import 'package:foody_rider/helpers/helpermethods.dart';
import 'package:foody_rider/widgets/brand_divider.dart';
import 'package:foody_rider/widgets/rider_button.dart';

class PaymentDialog extends StatelessWidget {

  final String paymentMethod;
  final double fares;

  PaymentDialog({this.paymentMethod, this.fares});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 20,),

          Text('${paymentMethod.toUpperCase()} PAYMENT'),

          SizedBox(height: 20,),

          BrandDivider(),

          SizedBox(height: 16,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/naira.png',
                height: 20,
              ),
              Text('$fares', style: TextStyle(fontFamily: 'Brand-Bold', fontSize:
              30),),
            ],
          ),

          SizedBox(height: 16,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Amount above is the total fares to be charged to the'
                ' rider', textAlign: TextAlign.center,),
          ),

          SizedBox(height: 30,),

          Container(
            width: 200,
            child: RiderButton(
              title: (paymentMethod == 'cash') ? 'COLLECT CASH' : 'CONFIRM',
              color: BrandColors.colorGreen,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);

                HelperMethods.enableHomeTabLocationUpdates();
              },
            ),
          ),
          SizedBox(height: 35,),
        ]),
      ),
    );
  }
}
