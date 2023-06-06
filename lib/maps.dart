import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'ratings.dart';

class Map extends StatefulWidget {
  final String dentistID;

  const Map({super.key, required this.dentistID});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    fetchDentistLocations();
  }

  Future<void> fetchDentistLocations() async {
    // Retrieve the dentist document from Firestore using the dentistID
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dentistID)
        .get();

    if (snapshot.exists) {
      String address = snapshot.get('address1.address1') as String;
      addMarker(address);
    }
  }

  Future<void> addMarker(String address) async {
    // Use Geocoding to get the latitude and longitude of the address
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      LatLng latLng = LatLng(
        location.latitude,
        location.longitude,
      );
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(address),
            position: latLng,
            infoWindow: InfoWindow(
              title: 'Dentist',
              snippet: address,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6153ff),
        title: Text('Mapa'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 1,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: _navigateToRatingsPage,
          child: Icon(Icons.star),
        ),
      ),
    );
  }

  void _navigateToRatingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Ratings(dentistID: widget.dentistID)),
    );
  }
}
