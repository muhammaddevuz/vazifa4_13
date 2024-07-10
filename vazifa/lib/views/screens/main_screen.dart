// import 'package:flutter/material.dart';
// import 'package:practice/services/location_services.dart';
// import 'package:provider/provider.dart';

// class MainScreen extends StatefulWidget {
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final locationService = Provider.of<LocationServices>(context);
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text("Main Screen"),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Center(
//           child: LocationServices.currentLocation == null
//               ? Text('Lokatsiya mavjud emas')
//               : Text("lat: ${locationService.currentLoc!.latitude}\n"
//                   "long: ${locationService.currentLoc!.longitude}"),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await locationService.getCurrentLocation();
//         },
//         child: Icon(
//           Icons.location_on,
//         ),
//       ),
//     );
//   }
// }
