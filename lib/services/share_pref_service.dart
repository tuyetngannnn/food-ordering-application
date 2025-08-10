// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:latlong2/latlong.dart';
// import 'dart:convert';
// import '../models/address.dart';
// import 'map_service.dart';
//
// class SharePrefService {
//   // Keys for SharedPreferences
//   static const String _selectedAddressKey = 'selected_address';
//   static const String _selectedLocationKey = 'selected_location';
//   static const String _selectedDistanceKey = 'selected_distance';
//   static const String _selectedPickupAddressKey = 'selected_pickup_address';
//
//   // Save selected address string
//   static Future<bool> saveSelectedAddress(String? address) async {
//     if (address == null) return false;
//
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.setString(_selectedAddressKey, address);
//   }
//
//   // Get selected address string
//   static Future<String?> getSelectedAddress() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_selectedAddressKey);
//   }
//
//   // Save selected location (LatLng)
//   static Future<bool> saveSelectedLocation(LatLng? location) async {
//     if (location == null) return false;
//
//     final prefs = await SharedPreferences.getInstance();
//     final locationMap = {
//       'latitude': location.latitude,
//       'longitude': location.longitude
//     };
//     return prefs.setString(_selectedLocationKey, jsonEncode(locationMap));
//   }
//
//   // Get selected location (LatLng)
//   static Future<LatLng?> getSelectedLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final locationString = prefs.getString(_selectedLocationKey);
//
//     if (locationString == null) return null;
//
//     try {
//       final locationMap = jsonDecode(locationString) as Map<String, dynamic>;
//       return LatLng(
//           locationMap['latitude'] as double,
//           locationMap['longitude'] as double
//       );
//     } catch (e) {
//       print('Error parsing location data: $e');
//       return null;
//     }
//   }
//
//   // Save selected distance double
//   static Future<bool> saveSelectedDistance(double? distance) async {
//     if (distance == null) return false;
//
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.setDouble(_selectedDistanceKey, distance);
//   }
//
//   // Get selected address string
//   static Future<double?> getSelectedDistance() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getDouble(_selectedDistanceKey);
//   }
//
//   // Save selected pickup address (Address object)
//   static Future<bool> saveSelectedPickupAddress(Address address) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.setString(_selectedPickupAddressKey, jsonEncode(address.toJson()));
//   }
//
//   // Get selected pickup address (Address object)
//   static Future<Address?> getSelectedPickupAddress() async {
//     final prefs = await SharedPreferences.getInstance();
//     final addressString = prefs.getString(_selectedPickupAddressKey);
//
//     if (addressString == null) return null;
//
//     try {
//       final addressMap = jsonDecode(addressString) as Map<String, dynamic>;
//       return Address.fromMap(addressMap);
//     } catch (e) {
//       print('Error parsing pickup address data: $e');
//       return null;
//     }
//   }
//
//   // Clear all location data
//   static Future<bool> clearAllLocationData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final results = await Future.wait([
//       prefs.remove(_selectedAddressKey),
//       prefs.remove(_selectedLocationKey),
//       prefs.remove(_selectedDistanceKey),
//       prefs.remove(_selectedPickupAddressKey),
//     ]);
//
//     return !results.contains(false);
//   }
//
// // Print all saved location data for debugging
//   static Future<void> printAllSavedData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final savedAddress = prefs.getString(_selectedAddressKey);
//     final savedLocationString = prefs.getString(_selectedLocationKey);
//     final savedDistanceDouble = prefs.getDouble(_selectedDistanceKey);
//     final savedPickupAddressString = prefs.getString(_selectedPickupAddressKey);
//
//     print('=== SAVED LOCATION DATA ===');
//     print('Selected Address: $savedAddress');
//     print('Selected Location: $savedLocationString');
//     print('Selected Distance: ${MapService.formatDistance(savedDistanceDouble ?? 0)}');
//     print('Selected Pickup Address: $savedPickupAddressString');
//     print('===========================');
//
//     // Parse and print the structured data
//     try {
//       if (savedLocationString != null) {
//         final locationMap = jsonDecode(savedLocationString);
//         print('Parsed Location: Lat: ${locationMap['latitude']}, Lng: ${locationMap['longitude']}');
//       }
//
//       if (savedPickupAddressString != null) {
//         final addressMap = jsonDecode(savedPickupAddressString);
//         print('Parsed Pickup Address: ${addressMap['addressName']}');
//       }
//     } catch (e) {
//       print('Error parsing saved data: $e');
//     }
//   }
//
// // Check if data exists
//   static Future<bool> hasStoredLocationData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.containsKey(_selectedAddressKey) ||
//         prefs.containsKey(_selectedLocationKey) ||
//         prefs.containsKey(_selectedDistanceKey) ||
//         prefs.containsKey(_selectedPickupAddressKey);
//   }
// }

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import '../models/address.dart';
import 'map_service.dart';

class SharePrefService {
  // Keys for SharedPreferences
  static const String _selectedAddressKey = 'selected_address';
  static const String _selectedLocationKey = 'selected_location';
  static const String _selectedDistanceKey = 'selected_distance';
  static const String _selectedPickupAddressKey = 'selected_pickup_address';

  // Stream controller to notify about changes
  static final StreamController<Map<String, dynamic>>
      _preferencesStreamController = StreamController.broadcast();
  // New key for first launch tracking
  static const String _firstLaunchKey = 'is_first_launch';
  // Save selected address string
  static Future<bool> saveSelectedAddress(String? address) async {
    if (address == null) return false;

    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString(_selectedAddressKey, address);

    if (success) {
      _preferencesStreamController.add({'address': address});
    }
    return success;
  }

// Check if it's the first app launch
  static Future<bool> isFirstAppLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  // Mark first launch as complete
  static Future<void> setFirstAppLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
    _preferencesStreamController.add({'first_launch': false});
  }

  //Method to reset first launch flag (useful for testing or app reset)
  static Future<void> resetFirstLaunchFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstLaunchKey);
    _preferencesStreamController.add({'first_launch': true});
  }

  // Get selected address string
  static Future<String?> getSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedAddressKey);
  }

  // Save selected location (LatLng)
  static Future<bool> saveSelectedLocation(LatLng? location) async {
    if (location == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final locationMap = {
      'latitude': location.latitude,
      'longitude': location.longitude
    };
    bool success =
        await prefs.setString(_selectedLocationKey, jsonEncode(locationMap));

    if (success) {
      _preferencesStreamController.add({'location': location});
    }
    return success;
  }

  // Get selected location (LatLng)
  static Future<LatLng?> getSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationString = prefs.getString(_selectedLocationKey);

    if (locationString == null) return null;

    try {
      final locationMap = jsonDecode(locationString) as Map<String, dynamic>;
      return LatLng(locationMap['latitude'] as double,
          locationMap['longitude'] as double);
    } catch (e) {
      print('Error parsing location data: $e');
      return null;
    }
  }

  // Save selected distance double
  static Future<bool> saveSelectedDistance(double? distance) async {
    if (distance == null) return false;

    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setDouble(_selectedDistanceKey, distance);

    if (success) {
      _preferencesStreamController.add({'distance': distance});
    }
    return success;
  }

  // Get selected distance
  static Future<double?> getSelectedDistance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_selectedDistanceKey);
  }

  // Save selected pickup address (Address object)
  static Future<bool> saveSelectedPickupAddress(Address address) async {
    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString(
        _selectedPickupAddressKey, jsonEncode(address.toJson()));

    if (success) {
      _preferencesStreamController.add({'pickup_address': address});
    }
    return success;
  }

  // Get selected pickup address (Address object)
  static Future<Address?> getSelectedPickupAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final addressString = prefs.getString(_selectedPickupAddressKey);

    if (addressString == null) return null;

    try {
      final addressMap = jsonDecode(addressString) as Map<String, dynamic>;
      return Address.fromMap(addressMap);
    } catch (e) {
      print('Error parsing pickup address data: $e');
      return null;
    }
  }

  // Clear all location data
  static Future<bool> clearAllLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    final results = await Future.wait([
      prefs.remove(_selectedAddressKey),
      prefs.remove(_selectedLocationKey),
      prefs.remove(_selectedDistanceKey),
      prefs.remove(_selectedPickupAddressKey),
    ]);

    return !results.contains(false);
  }

  // Print all saved location data for debugging
  static Future<void> printAllSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedAddress = prefs.getString(_selectedAddressKey);
    final savedLocationString = prefs.getString(_selectedLocationKey);
    final savedDistanceDouble = prefs.getDouble(_selectedDistanceKey);
    final savedPickupAddressString = prefs.getString(_selectedPickupAddressKey);

    print('=== SAVED LOCATION DATA ===');
    print('Selected Address: $savedAddress');
    print('Selected Location: $savedLocationString');
    print(
        'Selected Distance: ${MapService.formatDistance(savedDistanceDouble ?? 0)}');
    print('Selected Pickup Address: $savedPickupAddressString');
    print('===========================');

    // Parse and print the structured data
    try {
      if (savedLocationString != null) {
        final locationMap = jsonDecode(savedLocationString);
        print(
            'Parsed Location: Lat: ${locationMap['latitude']}, Lng: ${locationMap['longitude']}');
      }

      if (savedPickupAddressString != null) {
        final addressMap = jsonDecode(savedPickupAddressString);
        print('Parsed Pickup Address: ${addressMap['addressName']}');
      }
    } catch (e) {
      print('Error parsing saved data: $e');
    }
  }

  // Check if data exists
  static Future<bool> hasStoredLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_selectedAddressKey) ||
        prefs.containsKey(_selectedLocationKey) ||
        prefs.containsKey(_selectedDistanceKey) ||
        prefs.containsKey(_selectedPickupAddressKey);
  }

  // Stream to listen for changes in shared preferences
  static Stream<Map<String, dynamic>> get preferencesStream =>
      _preferencesStreamController.stream;
}
