import 'package:dars_12/services/location_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationServices.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController myController;
  final textController = TextEditingController();
  final LocationServices locationServices = LocationServices();
  final locationController = Location();
  Map<PolylineId, Polyline> polylines = {};

  final LatLng center = const LatLng(41.2, 69.2);
  LatLng najotTalim = const LatLng(41.2856806, 69.2034646);

  List<LatLng> points = [];

  double? lat;
  double? lng;
  LatLng? curPlace;
  MapType mapType = MapType.normal;

  void onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  Future<void> fetchLocation() async {
    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          curPlace =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ',
        request: PolylineRequest(
            origin: PointLatLng(curPlace!.latitude, curPlace!.longitude),
            destination: PointLatLng(lat!, lng!),
            mode: TravelMode.walking));

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      return [];
    }
  }

  Future<void> generatePolyline(List<LatLng> pooints) async {
    const id = PolylineId("polyline");

    final polyline = Polyline(
        polylineId: id, color: Colors.blueAccent, points: pooints, width: 5);
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> initializeMap() async {
    await fetchLocation();
    final points = await getPolylinePoints();
    generatePolyline(points);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationServices()),
      ],
      builder: (context, child) {
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text(
                "Google Map",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                GoogleMap(
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  polylines: Set<Polyline>.of(polylines.values),
                  markers: {
                    if (lat != null && lng != null)
                      Marker(
                        markerId: const MarkerId("search place"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: LatLng(lat!, lng!),
                      ),
                    if (curPlace != null)
                      Marker(
                        markerId: const MarkerId("current location"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: curPlace!,
                      ),
                  },
                  mapType: mapType,
                  initialCameraPosition:
                      CameraPosition(target: najotTalim, zoom: 10),
                  onMapCreated: onMapCreated,
                ),
                Positioned(
                  top: 120,
                  right: 20,
                  child: DropdownButton(
                    icon: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.green,
                        ),
                        child: const Icon(Icons.map)),
                    items: [
                      DropdownMenuItem(
                        value: MapType.normal,
                        child: TextButton(
                            onPressed: () {}, child: const Text("normal")),
                      ),
                      DropdownMenuItem(
                        value: MapType.satellite,
                        child: TextButton(
                            onPressed: () {}, child: const Text("sputnik")),
                      ),
                      DropdownMenuItem(
                        value: MapType.terrain,
                        child: TextButton(
                            onPressed: () {}, child: const Text("terrain")),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        mapType = value!;
                      });
                    },
                  ),
                ),
                Positioned(
                    top: 40,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      height: 50,
                      width: 370,
                      child: GooglePlacesAutoCompleteTextFormField(
                          itmClick: (prediction) async {
                            textController.text = prediction.description!;
                            curPlace =
                                await locationServices.getCurrentLocation();
                            setState(() {});

                            // textController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                          },
                          isLatLngRequired: true,
                          getPlaceDetailWithLatLng: (postalCodeResponse) {
                            print(
                                "lat: ${postalCodeResponse.lat}, long: ${postalCodeResponse.lng}");
                            setState(() {
                              lat = double.parse(postalCodeResponse.lat!);
                              lng = double.parse(postalCodeResponse.lng!);
                            });
                          },
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    textController.clear();
                                    lat = null;
                                    lng = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear,
                                ),
                              ),
                              border: const OutlineInputBorder(),
                              hintText: "Search"),
                          textEditingController: textController,
                          googleAPIKey:
                              'AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ'),
                    )),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: lat != null
                ? FloatingActionButton(
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      if (lat != null && lng != null) {
                        initializeMap();
                      }
                    },
                    child: const Icon(
                      CupertinoIcons.location,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
