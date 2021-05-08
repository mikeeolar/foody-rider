import 'package:firebase_database/firebase_database.dart';

class Rider {
  String fullname;
  String email;
  String phone;
  String id;

  Rider({this.id, this.phone, this.fullname, this.email});

  Rider.fromSnapShot(DataSnapshot snapshot) {
    id = snapshot.key;
    phone = snapshot.value['phone_no'];
    email = snapshot.value['email'];
    fullname = snapshot.value['full_name'];
  }
}