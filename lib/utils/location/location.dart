
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technician_time_app/models/location_model.dart';
import 'package:technician_time_app/services/location_db.dart';

class LocationClient {
  LatLng latlong;
  CameraPosition _cameraPosition;
  GoogleMapController _controller;
  Set<Marker> _markers = {};
  List<Address> results = [];
  DatabaseHelper dbHelper = DatabaseHelper();

  void getLocation(context) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latlong =
        new LatLng(position.latitude, position.longitude); //change location
    _cameraPosition = CameraPosition(target: latlong, zoom: 10.0);
    if (_controller != null)
      _controller
          .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));

    _markers.add(Marker(
        markerId: MarkerId("a"),
        draggable: true,
        position: latlong,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onDragEnd: (_currentlatLng) {
          latlong = _currentlatLng;
        }));

    final locationData = LocationDBModel(
        lat: latlong.latitude.toString(), long: latlong.longitude.toString());

    _saveLocation(locationDBModel: locationData, context: context);
  }

  void _saveLocation(
      {LocationDBModel locationDBModel, BuildContext context}) async {
    int result;

    result = await dbHelper.insertLocationDatabase(locationDBModel);

    if (result != 0) {
      DatabaseHelper().getCount().then((value) {
        if (value != null) {
          DatabaseHelper().deleteEnteries();
        }
      });
    }
  }

  //  get the address with
  getCurrentAddress() async {
    final coordinates = new Coordinates(latlong.latitude, latlong.longitude);
    results = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = results.first;
    if (first != null) {
      var address;

      address = "${first.locality}";
      address = " $address, ${first.countryName}";
      address = " $address, ${first.postalCode}";
    }
  }
}
