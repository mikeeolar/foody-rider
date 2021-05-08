import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foody_rider/brand_colors.dart';
import 'package:foody_rider/global_variables.dart';
import 'package:foody_rider/helpers/helpermethods.dart';
import 'package:foody_rider/models/order_details.dart';
import 'package:foody_rider/widgets/brand_divider.dart';
import 'package:foody_rider/widgets/progress_dialog.dart';
import 'package:foody_rider/widgets/rider_button.dart';
import 'package:foody_rider/widgets/rider_outlined_button.dart';
import 'package:foody_rider/screens/new_trip_screen.dart';
import 'package:toast/toast.dart';

class NotificationDialog extends StatelessWidget {
  final OrderDetails orderDetails;

  NotificationDialog({this.orderDetails});

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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: 30,
          ),
          Image.asset(
            'assets/images/food-order.png',
            width: 100,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'NEW FOOD ORDER REQUEST',
            style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(
                      width: 18,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          orderDetails.address,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/rider.png', width: 27),
                    SizedBox(
                      width: 18,
                    ),
                    Expanded(
                      child: Container(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/naira.png',
                              width: 20,
                            ),
                            Text(
                              '${orderDetails.riderFee}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          BrandDivider(),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: RiderOutlinedButton(
                      title: 'DECLINE',
                      color: BrandColors.colorPrimary,
                      onPressed: () async {
                        assetsAudioPlayer.pause();
                        Navigator.pop(context);
                        assetsAudioPlayer.stop();
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    child: RiderButton(
                      title: 'ACCEPT',
                      color: Colors.green[10],
                      onPressed: () async {
                        assetsAudioPlayer.stop();
                        checkAvailability(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ]),
      ),
    );
  }

  void checkAvailability(context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Accepting request...',
      ),
    );

    DatabaseReference newRideRef = FirebaseDatabase.instance
        .reference()
        .child('riders/${currentFirebaseUser.uid}/neworder');

    DatabaseReference awaitRef = FirebaseDatabase.instance
        .reference()
        .child('awaitingRequest/${orderDetails.orderId}/neworder');
    final awaitSnap = await awaitRef.once();

    // DatabaseReference newOrderRef =
    // FirebaseDatabase.instance.reference().child('allriders');
    // newOrderRef.once().then((DataSnapshot snapshot) {
    //   Navigator.of(context).pop();
    //   Navigator.of(context).pop();
    //
    //   String orderId = "";
    //   if (snapshot.value != null) {
    //     orderId = snapshot.value.toString();
    //   } else {
    //     print('Order not found');
    //   }
    //
    //   if (orderId == orderDetails.orderId) {
    //     newOrderRef.set('accepted');
    //     HelperMethods.disableHomeTabLocationUpdates();
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => NewTripScreen(
    //               orderDetails: orderDetails,
    //             )));
    //   } else if (orderId == 'accepted') {
    //     Toast.show('Order has been accepted', context,
    //         duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    //   } else if (orderId == 'cancelled') {
    //     Toast.show('Order has been cancelled', context,
    //         duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    //   } else if (orderId == 'timeout') {
    //     Toast.show('Order has timed out', context,
    //         duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    //   } else {
    //     Toast.show('Order not found', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    //   }
    // });
    newRideRef.once().then((DataSnapshot snapshot) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      String orderId = "";
      if (awaitSnap.value != null) {
        orderId = awaitSnap.value.toString();
      } else {
        print('No order Found');
      }

      if (orderId == 'waiting') {
        newRideRef.set('accepted');
        awaitRef.set('accepted');
        HelperMethods.disableHomeTabLocationUpdates();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewTripScreen(
                      orderDetails: orderDetails,
                    )));
      } else if (orderId == 'accepted') {
        Toast.show('Order has been accepted', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else if (orderId == 'cancelled') {
        Toast.show('Order has been cancelled', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else if (orderId == 'timeout') {
        Toast.show('Order has timed out', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        Toast.show('Order not found', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    });
  }
}
