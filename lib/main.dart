import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(

        primarySwatch: Colors.blue,

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MapView(),
    );
  }
}


class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  // Initial location of the Map view
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

  // For controlling the view of the Map
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  // For storing the current position
  Position _currentPosition;

  String _currentAddress;

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();


  Set<Marker> markers = {};

  Position startCoordinates;
  Position destinationCoordinates;





  getPlacemarks() async {
    List<Placemark> startPlacemark =
    await _geolocator.placemarkFromAddress(_startAddress);
    List<Placemark> destinationPlacemark =
    await _geolocator.placemarkFromAddress(_destinationAddress);

// Retrieving coordinates
    startCoordinates = startPlacemark[0].position;
    destinationCoordinates = destinationPlacemark[0].position;

    // Start Location Marker
    Marker startMarker = Marker(
      markerId: MarkerId('$startCoordinates'),
      position: LatLng(
        startCoordinates.latitude,
        startCoordinates.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'Start',
        snippet: _startAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

// Destination Location Marker
    Marker destinationMarker = Marker(
      markerId: MarkerId('$destinationCoordinates'),
      position: LatLng(
        destinationCoordinates.latitude,
        destinationCoordinates.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: _destinationAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    markers.add(startMarker);
    markers.add(destinationMarker);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
    _getAddress();
    getPlacemarks();
  }

  @override
  Widget build(BuildContext context) {

    // Determining the screen width and height
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        height: height,
        width: width,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              GoogleMap(
                markers: markers != null ? Set<Marker>.from(markers) : null,
                initialCameraPosition: _initialLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Text('Places',style: TextStyle(fontSize: 20),),
                      _textField(
                          controller: startAddressController,
                          prefixIcon: Icon(Icons.looks_one),
                          suffixIcon: Icon(Icons.my_location),
                          width: width,
                          label: 'Start'
                      ),
                      SizedBox(height: 5,),
                      _textField(
                          controller: destinationAddressController,
                          prefixIcon: Icon(Icons.looks_two),
                          width: width,
                          label: 'Destination'
                      ),
                      SizedBox(height: 5,),
                      RaisedButton(
                        onPressed: (){

                        },
                        child: Text('SHOW ROUTE',style: TextStyle(color: Colors.white),),
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                      )
                    ],
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                    child: Material(
                      color: Colors.orange[100], // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  // Will be fetching in the next step
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  ClipOval(
                    child: Material(
                      color: Colors.blue[300], // button color
                      child: InkWell(
                        splashColor: Colors.blue, // inkwell color
                        child: SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(Icons.add,),
                        ),
                        onTap: () {
                          // TODO: Add the operation to be performed
                          // on button tap
                          mapController.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        },

                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  ClipOval(
                    child: Material(
                      color: Colors.blue[300], // button color
                      child: InkWell(
                        splashColor: Colors.blue, // inkwell color
                        child: SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(Icons.remove),
                        ),
                        onTap: () {
                          // TODO: Add the operation to be performed
                          // on button tap
                          mapController.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        },

                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getCurrentLocation() async {
    await _geolocator.
      getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position){

          setState(() {
            _currentPosition = position;

            print('Current Pos: $_currentPosition');

            // For moving the camera to current Location
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 18.0,
                ),
              ),
            );
          });

    }).catchError((e){
      print(e);
    });
  }

  Widget _textField({
    TextEditingController controller,
    String label,
    String hint,
    String initialValue,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        // initialValue: initialValue,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  _getAddress() async {
    try {
      // Places are retrieved using the coordinates
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      // Taking the most probable result
      Placemark place = p[0];

      setState(() {

        // Structuring the address
        _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";

        // Update the text of the TextField
        startAddressController.text = _currentAddress;

        // Setting the user's present location as the starting address
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }
}
