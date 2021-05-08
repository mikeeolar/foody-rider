// import 'package:flutter/material.dart';
// import 'package:foody_user/helpers/location_helper.dart';
// import 'package:foody_user/screens/map_screen.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
//
// class LocationInput extends StatefulWidget {
//   // final Function onSelectPlace;
//   //
//   // LocationInput(this.onSelectPlace);
//
//   @override
//   _LocationInputState createState() => _LocationInputState();
// }
//
// class _LocationInputState extends State<LocationInput> {
//   String _previewImageUrl;
//   String _locationAddress;
//
//   void _showPreview(double lat, double lng) {
//     final staticMapImageUrl = LocationHelper.generateLocationPreview(latitude: lat, longitude: lng);
//     setState(() {
//       _previewImageUrl = staticMapImageUrl;
//     });
//   }
//
//   Future<void> _getCurrentUserLocation() async {
//     try {
//       final locData = await Location().getLocation();
//       _showPreview(locData.latitude, locData.longitude);
//       // widget.onSelectPlace(locData.latitude, locData.longitude);
//       final staticMapImageUrl = LocationHelper.generateLocationPreview(
//           latitude: locData.latitude, longitude: locData.latitude);
//       setState(() {
//         _previewImageUrl = staticMapImageUrl;
//       });
//     } catch (error) {
//       return;
//     }
//   }
//
//   Future<void> _selectOnMap() async {
//     final selectedLocation =
//     await Navigator.of(context).push<LatLng>(MaterialPageRoute(
//         fullscreenDialog: true,
//         builder: (ctx) => MapScreen(
//           isSelecting: true,
//         )));
//     if (selectedLocation == null) {
//       return;
//     }
//     final address = await LocationHelper.getPlaceAddress(selectedLocation.latitude,
//         selectedLocation.longitude);
//     _locationAddress = address;
//     _showPreview(selectedLocation.latitude, selectedLocation.longitude);
//     // widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                     height: 90,
//                     // width: double.infinity,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
//                     child: _previewImageUrl == null
//                         ? Text(
//                             'No Location Chosen',
//                             textAlign: TextAlign.center,
//                           )
//                         : Image.network(
//                             _previewImageUrl,
//                             fit: BoxFit.cover,
//                             // width: double.infinity,
//                           )),
//               ),
//               SizedBox(
//                 width: 5,
//               ),
//               Column(
//                 children: [
//                   TextButton.icon(
//                     icon: Icon(
//                       Icons.location_on,
//                     ),
//                     label: Text(
//                       'Current Location',
//                       style: TextStyle(
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ),
//                     onPressed: _getCurrentUserLocation,
//                   ),
//                   TextButton.icon(
//                     icon: Icon(
//                       Icons.map,
//                     ),
//                     label: Text(
//                       'Select on Map',
//                       style: TextStyle(
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ),
//                     onPressed: _selectOnMap
//                   ),
//                 ],
//               )
//             ],
//           ),
//           Text('${_locationAddress == null ? 'Select Location' : _locationAddress}')
//         ],
//       ),
//     );
//   }
// }
