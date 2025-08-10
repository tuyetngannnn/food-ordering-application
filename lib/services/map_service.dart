import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/address.dart';

class MapService {
  static Future<List<Address>> getAddressesFromFirebase() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('addresses').get();
      return querySnapshot.docs.map((doc) => Address.fromJson(doc)).toList();
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }
  // Fetch the user's current location
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
    } catch (e) {
      print("Error getting current location: $e");
      return null;
    }
  }

  // Get address from latitude and longitude
  static Future<String?> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        // Format address
        String address = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.subAdministrativeArea,
          placemark.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        return address;
      }
      return null;
    } catch (e) {
      print("Error getting address: $e");
      return null;
    }
  }

  // Get address from latitude and longitude with distance from current location
  static Future<String?> getAddressWithDistance(LatLng position,
      LatLng currentPosition) async {
    try {
      String? address = await getAddressFromLatLng(position);
      if (address == null) return null;

      // Calculate distance between positions
      double distanceInMeters = calculateDistance(currentPosition, position);

      // Format distance string
      String distanceString = formatDistance(distanceInMeters);

      return '$address • $distanceString';
    } catch (e) {
      print("Error getting address with distance: $e");
      return null;
    }
  }

  // Search for addresses using a query string
  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    if (query
        .trim()
        .isEmpty) {
      return [];
    }

    try {
      List<Location> locations = await locationFromAddress(query);
      List<Map<String, dynamic>> results = [];

      for (var location in locations) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude
        );

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;

          // Format address
          String address = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
            placemark.subAdministrativeArea,
            placemark.administrativeArea,
          ].where((element) => element != null && element.isNotEmpty).join(
              ', ');

          results.add({
            'address': address,
            'location': LatLng(location.latitude, location.longitude)
          });
        }
      }

      return results;
    } catch (e) {
      print("Error searching for location: $e");
      return [];
    }
  }

  // Get route between two points using OSRM API
  static Future<List<LatLng>> getRoute(LatLng startPoint,
      LatLng endPoint) async {
    try {
      // Format coordinates for OSRM: {longitude},{latitude}
      final String coordinates = "${startPoint.longitude},${startPoint
          .latitude};${endPoint.longitude},${endPoint.latitude}";

      // Create OSRM API URL (using driving profile)
      final String url = "https://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract route geometry from response
        final List<
            dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

        // Convert OSRM coordinates [lng, lat] to LatLng objects
        return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
      } else {
        print("Failed to get route: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching route: $e");
      return [];
    }
  }

  // Convert a Position to a LatLng object
  static LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  // Get location from an address string
  static Future<LatLng?> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      print("Error getting location from address: $e");
      return null;
    }
  }

  // Calculate distance between two points
  static double calculateDistance(LatLng point1, LatLng point2) {
    // Calculate distance in meters using Geolocator package
    return Geolocator.distanceBetween(
        point1.latitude,
        point1.longitude,
        point2.latitude,
        point2.longitude
    );
  }

  // Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      // Display in meters if less than 1 km
      return '${distanceInMeters.round()} m';
    } else {
      // Display in kilometers with 1 decimal place
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  // Get estimated travel time based on distance (very rough estimate)
  static String getEstimatedTime(double distanceInMeters) {
    // Assuming average speed of 30 km/h or 500 m/min
    double timeInMinutes = distanceInMeters / 500;

    if (timeInMinutes < 1) {
      return 'Ít hơn 1 phút';
    } else if (timeInMinutes < 60) {
      return '${timeInMinutes.round()} phút';
    } else {
      double timeInHours = timeInMinutes / 60;
      return '${timeInHours.toStringAsFixed(1)} giờ';
    }
  }
}