import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {

  // CHECK GPS SERVICE
  static Future<bool>
      isLocationServiceEnabled() async {

    return await Geolocator
        .isLocationServiceEnabled();
  }

  // CHECK LOCATION PERMISSION
  static Future<LocationPermission>
      checkPermission() async {

    return await Geolocator
        .checkPermission();
  }

  // REQUEST LOCATION PERMISSION
  static Future<LocationPermission>
      requestPermission() async {

    return await Geolocator
        .requestPermission();
  }