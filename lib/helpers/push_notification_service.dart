import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_rider/global_variables.dart';
import 'package:foody_rider/models/order_details.dart';
import 'package:foody_rider/widgets/notification_dialog.dart';
import 'package:foody_rider/widgets/progress_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  final currentFirebaseUser = FirebaseAuth.instance.currentUser;

  // Future<void> _firebaseMessagingBackgroundHandler(
  //     RemoteMessage remoteMessage) async {
  //   await Firebase.initializeApp();
  //   Map<String, dynamic> message = remoteMessage.data;
  //   fetchOrderInfo(getOrderId(message));
  // }


  Future initialize(context) async {

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      Map<String, dynamic> message = remoteMessage.data;
      print('From onMessage');
      fetchOrderInfo(getOrderId(message), context);
    });

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      Map<String, dynamic> message = remoteMessage.data;
      print('From onMessageOpenedApp');
      fetchOrderInfo(getOrderId(message), context);
    });
  }

  Future<String> getToken() async {
    String token = await fcm.getToken();
    print('token: $token');

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('riders/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('allriders');
    fcm.subscribeToTopic('allusers');

    return token;
  }

  String getOrderId(Map<String, dynamic> message) {
    String orderId;

    if (Platform.isAndroid) {
      orderId = message['order_id'];
      print('order_id: $orderId');
    }
    return orderId;
  }

  void fetchOrderInfo(String orderId, context) {
    showDialog(
      context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Fetching details...',
            ));

    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('orderRequest/$orderId');

    Navigator.of(context).pop();

    rideRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        assetsAudioPlayer.open(
          Audio('assets/sounds/alert.mp3'),
        );
        assetsAudioPlayer.play();

        final double yabaLat = 6.519581187378638;
        final double yabaLng = 3.3733998585813496;
        double locationLat =
            double.parse(snapshot.value['location']['latitude'].toString());
        double locationLng =
            double.parse(snapshot.value['location']['longitude'].toString());
        String address = snapshot.value['address'].toString();
        String fullName = snapshot.value['rider_name'].toString();
        String phoneNumber = snapshot.value['rider_phone'].toString();
        double deliveryFee = double.parse(snapshot.value['riderFee'].toString());
        String paymentMethod = snapshot.value['payment_method'];

        OrderDetails orderDetails = OrderDetails();
        orderDetails.orderId = orderId;
        orderDetails.address = address;
        orderDetails.riderName = fullName;
        orderDetails.riderPhone = phoneNumber;
        orderDetails.riderFee = deliveryFee;
        orderDetails.location = LatLng(locationLat, locationLng);
        orderDetails.paymentMethod = paymentMethod;
        orderDetails.pickup = LatLng(yabaLat, yabaLng);

        showDialog(
          context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialog(orderDetails: orderDetails,));
      }
    });
  }
}