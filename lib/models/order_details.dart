import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderDetails {
  String address;
  LatLng location;
  String orderId;
  String paymentMethod;
  String riderName;
  String riderPhone;
  String mealTitle;
  double amount;
  double riderFee;
  LatLng pickup;
  LatLng destination;

  OrderDetails(
      {this.address,
      this.orderId,
      this.location,
      this.paymentMethod = 'cash',
      this.riderName,
      this.amount,
      this.riderPhone,
      this.riderFee,
      this.pickup,
      this.destination});
}
