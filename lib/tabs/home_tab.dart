import 'dart:async';
import 'package:foody_rider/helpers/push_notification_service.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:foody_rider/brand_colors.dart';
import 'package:foody_rider/global_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foody_rider/models/rider.dart';
import 'package:foody_rider/widgets/availability_button.dart';
import 'package:foody_rider/widgets/confirm_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  Position currentPosition;

  static final CameraPosition googlePlex = CameraPosition(
    target: LatLng(37.43296265331129, -122.08832357078792),
    zoom: 14,
  );

  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 4,
  );

  String availabilityTitle = 'GO ONLINE';
  Color availabilityColor = BrandColors.colorOrange;
  bool isAvailable = false;

  Stream cStream;

  void getCurrentPosition() async {
    Position position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 16);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  void goOnline() {
    Geofire.initialize('ridersAvailable');
    Geofire.setLocation(
        currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    tripRequestRef =
        FirebaseDatabase.instance.reference().child('riders/${currentFirebaseUser.uid}/neworder');
    tripRequestRef.set('waiting');
    tripRequestRef.onValue.listen((event) {});
    // tripRequestRef =
    //     FirebaseDatabase.instance.reference().child('allriders');
    // tripRequestRef.set('waiting');
    // tripRequestRef.onValue.listen((event) {});
  }

  goOffline() {
    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }

  void getLocationUpdates() {
    homeTabPositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4)
        .listen((Position position) {
      currentPosition = position;

      if (isAvailable) {
        Geofire.setLocation(currentFirebaseUser.uid, position.latitude, position.longitude);
      }

      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = new CameraPosition(target: pos, zoom: 16);
      mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    });
  }

  void showConfirmSheet(context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        builder: (BuildContext context) => ConfirmSheet(
              title: (!isAvailable) ? 'GO ONLINE' : 'GO OFFLINE',
              subtitle: (!isAvailable)
                  ? 'You are about to become '
                      'available to receive food order request.'
                  : 'You will stop '
                      'receiving food order requests',
              onPressed: () {
                if (!isAvailable) {
                  goOnline();
                  getLocationUpdates();
                  Navigator.pop(context);

                  setState(() {
                    availabilityColor = BrandColors.colorGreen;
                    availabilityTitle = 'GO OFFLINE';
                    isAvailable = true;
                  });
                } else {
                  goOffline();
                  Navigator.pop(context);

                  setState(() {
                    availabilityColor = BrandColors.colorOrange;
                    availabilityTitle = 'GO ONLINE';
                    isAvailable = false;
                  });
                }
              },
            ));
  }

  void getCurrentDriverInfo() async {
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child('riders/${currentFirebaseUser.uid}');
    driverRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentDriverInfo = Rider.fromSnapShot(snapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 130),
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.normal,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
            getCurrentPosition();
          },
        ),
        Container(
          height: 130,
          width: double.infinity,
          color: BrandColors.colorPrimary
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: () {
                  showConfirmSheet(context);
                  // showDialog(
                  //     context: context,
                  //     barrierDismissible: false,
                  //     builder: (BuildContext context) => NotificationDialog());
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
