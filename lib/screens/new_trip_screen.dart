import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:foody_rider/brand_colors.dart';
import 'package:foody_rider/global_variables.dart';
import 'package:foody_rider/helpers/helpermethods.dart';
import 'package:foody_rider/helpers/mapkithelper.dart';
import 'package:foody_rider/models/order_details.dart';
import 'package:foody_rider/widgets/payment_dialog.dart';
import 'package:foody_rider/widgets/progress_dialog.dart';
import 'package:foody_rider/widgets/rider_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripScreen extends StatefulWidget {
  final OrderDetails orderDetails;

  NewTripScreen({this.orderDetails});

  @override
  _NewTripScreenState createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController rideMapController;
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  BitmapDescriptor movingMarkerIcon;
  Position myPosition;
  String status = 'accepted';
  String durationString = '';
  bool isRequestingDirection = false;
  String buttonTitle = 'START TRIP';
  Color buttonColor = Colors.green;

  static final CameraPosition googlePlex = CameraPosition(
    target: LatLng(37.43296265331129, -122.08832357078792),
    zoom: 14,
  );

  void getCurrentPosition() async {
    Position position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  void createMarker() {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/images/rider_move.png')
          .then((icon) {
        movingMarkerIcon = icon;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    acceptTrip();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      body: Stack(children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: 220, top: 35),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapToolbarEnabled: true,
          trafficEnabled: true,
          compassEnabled: true,
          initialCameraPosition: googlePlex,
          circles: _circles,
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) async {
            _controller.complete(controller);
            rideMapController = controller;

            getCurrentPosition();

            var currentLatLng = LatLng(6.519581187378638, 3.3733998585813496);
            var pickupLatLng = widget.orderDetails.location;
            await getDirection(currentLatLng, pickupLatLng);

            getLocationUpdates();
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 15,
                      color: Colors.black26,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      )),
                ]),
            height: 220,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      durationString,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Brand-Bold',
                          color: BrandColors.colorAccentPurple),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.orderDetails.riderName,
                          style: TextStyle(fontSize: 22, fontFamily: 'Brand-Bold'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: CircleAvatar(child: Icon(Icons.call)),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.orderDetails.address,
                              style: TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RiderButton(
                      title: buttonTitle,
                      color: buttonColor,
                      onPressed: () async {
                        if (status == 'accepted') {
                          status = 'ontrip';
                          rideRef.child('status').set('ontrip');

                          setState(() {
                            buttonTitle = 'END TRIP';
                            buttonColor = Colors.red;
                          });
                          HelperMethods.showProgressDialog(context);

                          await getDirection(widget.orderDetails.pickup,
                              widget.orderDetails.location);

                          Navigator.pop(context);
                        } else if (status == 'ontrip') {
                          endTrip();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> getDirection(LatLng pickupLatLng, LatLng destinationLatLng) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait...',
            ));

    var thisDetails = await HelperMethods.getDirectionDetails(pickupLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();

    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    LatLngBounds bounds;

    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
        northeast: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.green,
        strokeWidth: 3,
        radius: 5,
        center: pickupLatLng,
        fillColor: BrandColors.colorGreen);

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 5,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void acceptTrip() {
    String rideID = widget.orderDetails.orderId;
    rideRef = FirebaseDatabase.instance.reference().child('orderRequest/$rideID');

    rideRef.child('status').set('accepted');
    rideRef.child('driver_name').set(currentDriverInfo.fullname);
    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef.child('driver_id').set(currentDriverInfo.id);
  }

  void getLocationUpdates() {
    LatLng oldPosition = LatLng(0, 0);

    ridePositionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation)
            .listen((Position position) {
      myPosition = position;
      currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);

      var rotation = MapKitHelper.getMarkerRotation(
          oldPosition.latitude, oldPosition.longitude, pos.latitude, pos.longitude);

      Marker movingMarker = Marker(
        markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotation,
        infoWindow: InfoWindow(title: 'Current Position'),
      );

      setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom: 16);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMarker);
      });
      oldPosition = pos;
      updateTripDetails();

      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString,
      };

      rideRef.child('rider_location').set(locationMap);
    });
  }

  void updateTripDetails() async {
    if (!isRequestingDirection) {
      isRequestingDirection = true;

      if (myPosition == null) {
        return;
      }

      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);

      LatLng destinationLatLng;
      if (status == 'accepted') {
        destinationLatLng = widget.orderDetails.location;
      } else {
        destinationLatLng = widget.orderDetails.location;
      }
      var directionDetails =
          await HelperMethods.getDirectionDetails(positionLatLng, destinationLatLng);

      if (directionDetails != null) {
        print(directionDetails.durationText);

        setState(() {
          durationString = directionDetails.durationText;
        });
      }
    }
    isRequestingDirection = false;
  }

  void endTrip() {
    rideRef.child('status').set('ended');
    ridePositionStream.cancel();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => PaymentDialog(
          paymentMethod: widget.orderDetails.paymentMethod,
          fares: widget.orderDetails.riderFee,
        ));
    topUpEarnings(widget.orderDetails.riderFee);
  }

  void topUpEarnings(double fares) {
    DatabaseReference earningsRef = FirebaseDatabase.instance
        .reference()
        .child('riders/${currentFirebaseUser.uid}/earnings');

    earningsRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        double oldEarnings = double.parse(snapshot.value.toString());
        double adjustedEarnings = fares + oldEarnings;
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      } else {
        double adjustedEarnings = fares;
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      }
    });
  }
}
