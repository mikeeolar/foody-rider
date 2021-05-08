import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foody_rider/models/rider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

String mapKey = 'AIzaSyBT47b_triwjr_4n7jDvqwlxlCtg72AyWE';

User currentFirebaseUser;
DatabaseReference tripRequestRef;
StreamSubscription<Position> homeTabPositionStream;
StreamSubscription<Position> ridePositionStream;
final assetsAudioPlayer = AssetsAudioPlayer();
Position currentPosition;
DatabaseReference rideRef;
Rider currentDriverInfo;
final firestoreInstance = FirebaseFirestore.instance;
final user = FirebaseAuth.instance.currentUser;