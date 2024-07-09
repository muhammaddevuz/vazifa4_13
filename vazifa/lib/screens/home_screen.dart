import 'package:dars_12/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  // final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng najotTalim = const LatLng(41.2856806, 69.2034646);
  LatLng myCurrentPosition = LatLng(41.2856806, 69.2034646);
  Set<Marker> myMarkers = {};
  Set<Polyline> polylines = {};
  List<LatLng> myPositions = [];
  TextEditingController locationController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await LocationService.getCurrentLocation();
      setState(() {});
      // watchMyLocation();
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      myCurrentPosition = position.target;
    });
  }

  void watchMyLocation() {
    LocationService.getLiveLocation().listen((location) {
      print("Live location: $location");
    });
  }

  void addLocationMarker() {
    setState(() {
      myMarkers.add(
        Marker(
          markerId: MarkerId(myMarkers.length.toString()),
          position: myCurrentPosition,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );

      myPositions.add(myCurrentPosition);

      if (myPositions.length == 2) {
        LocationService.fetchPolylinePoints(
          myPositions[0],
          myPositions[1],
        ).then((List<LatLng> positions) {
          setState(() {
            polylines.add(
              Polyline(
                polylineId: PolylineId(UniqueKey().toString()),
                color: Colors.blue,
                width: 5,
                points: positions,
              ),
            );
          });
        }).catchError((error) {
          print('Error fetching polyline points: $error');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Google Maps",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            buildingsEnabled: true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: najotTalim,
              zoom: 16.0,
            ),
            trafficEnabled: true,
            onCameraMove: onCameraMove,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId("najotTalim"),
                icon: BitmapDescriptor.defaultMarker,
                position: najotTalim,
                infoWindow: const InfoWindow(
                  title: "Najot Ta'lim",
                  snippet: "Xush kelibsiz",
                ),
              ),
              Marker(
                markerId: const MarkerId("myCurrentPosition"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                position: myCurrentPosition,
                infoWindow: const InfoWindow(
                  title: "Najot Ta'lim",
                  snippet: "Xush kelibsiz",
                ),
              ),
              ...myMarkers,
            },
            polylines: polylines,
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 60, 20),
                child: GooglePlacesAutoCompleteTextFormField(
                    itmClick: (postalCodeResponse) {
                      if (postalCodeResponse.lat != null &&
                          postalCodeResponse.lng != null) {
                        setState(() {
                          myCurrentPosition = LatLng(
                            double.parse(postalCodeResponse.lat!),
                            double.parse(postalCodeResponse.lng!),
                          );
                        });
                      } else {
                        print(
                            "Received null lat or lng from postalCodeResponse");
                      }
                    },
                    decoration: InputDecoration(
                        labelText: "Search",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25))),
                    textEditingController: locationController,
                    googleAPIKey: "AIzaSyDxcIfLomcjjZW7DEVOUpmzSCX1x1cgj9I"),
              )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: addLocationMarker,
        child: const Icon(Icons.add),
      ),
    );
  }
}
