import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool>
      isLocationServiceEnabled() async {

    return await Geolocator
        .isLocationServiceEnabled();
  }

  static Future<LocationPermission>
      checkPermission() async {

    return await Geolocator
        .checkPermission();
  }

  static Future<LocationPermission>
      requestPermission() async {

    return await Geolocator
        .requestPermission();
  }
  static Future<Position?>
      getCurrentLocation({
    BuildContext? context,
  }) async {

    try {
      bool serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'GPS is disabled',
              ),
            ),
          );
        }
        return null;
      }
      LocationPermission permission =
          await Geolocator
              .checkPermission();
      if (permission ==
          LocationPermission.denied) {

        permission =
            await Geolocator
                .requestPermission();
      }
      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission
                  .deniedForever) {

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission denied',
              ),
            ),
          );
        }

        return null;
      }
      Position position =
          await Geolocator
              .getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return position;
    } catch (e) {
      debugPrint(
        'Get Location Error : $e',
      );
      return null;
    }
  }
  static Stream<Position>
      getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
  static Future<bool>
      openLocationSettings() async {
        return await Geolocator.openLocationSettings();
  }
  static Future<bool>
      openAppSettings() async {
        return await Geolocator.openAppSettings();
  }
}
