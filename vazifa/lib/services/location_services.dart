import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationServices  extends ChangeNotifier{
  static final _location = Location();

  static bool isServiceEnable = false;
  static PermissionStatus permissionStatus = PermissionStatus.denied;
  static LocationData? currentLocation;

  LocationData? get currentLoc {
    return currentLocation;
  }

  static Future<void> init() async {
    await checkService();
    await checkPermission();
  }

  static Future<void> checkService() async {
    isServiceEnable = await _location.serviceEnabled();

    if (!isServiceEnable) {
      isServiceEnable = await _location.requestService();
      if (!isServiceEnable) {
        return; 
      }
    }
  }

  static Future<void> checkPermission() async {
    permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return; 
      }
    }
  }

   Future<LatLng> getCurrentLocation() async {
    LocationData? location;
    if (isServiceEnable && permissionStatus == PermissionStatus.granted) {
       location = await _location.getLocation();
    }

    return LatLng(location!.latitude!, location.longitude!); 


  }
  
}