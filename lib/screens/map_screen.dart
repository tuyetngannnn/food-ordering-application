import 'package:demo_firebase/widgets/custom_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../services/map_service.dart';

class MapScreen extends StatefulWidget {
  final LatLng startPoint;
  final LatLng? initialLocation;

  const MapScreen({super.key, required this.startPoint, this.initialLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Will hold tap position
  LatLng? _endPoint;

  // Controller for the map
  final MapController _mapController = MapController();

  // Store polyline points
  List<LatLng> _routePoints = [];

  // Loading state
  bool _isLoading = false;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Search results
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Selected address text
  String _selectedAddress = '';

  // Distance between points
  double? _distance;

  @override
  void initState() {
    super.initState();

    // If there's an initial location, use it as end point
    if (widget.initialLocation != null) {
      _endPoint = widget.initialLocation;
      _getAddressFromLatLng(_endPoint!);
    }

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get user's current location to set as default instead of (0,0)
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position? position = await MapService.getCurrentPosition();

      if (position != null) {
        setState(() {
          // If no end point was set, set current location as end point too
          if (_endPoint == null) {
            _endPoint = widget.startPoint;
            _getAddressFromLatLng(_endPoint!);
          }

          // Move map to current position
          _mapController.move(
              LatLng(position.latitude, position.longitude), 18);

          // Get the route if we have both points
          if (_endPoint != null) {
            _endPoint = LatLng(position.latitude, position.longitude);
            _getAddressFromLatLng(_endPoint!);
            _updateDistance();
            _getRoute();
          }
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update the distance calculation
  void _updateDistance() {
    if (_endPoint != null) {
      _distance = MapService.calculateDistance(widget.startPoint, _endPoint!);
    }
  }

  // Fetch route from OSRM API
  Future<void> _getRoute() async {
    if (_endPoint == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<LatLng> routePoints =
          await MapService.getRoute(widget.startPoint, _endPoint!);

      setState(() {
        _routePoints = routePoints;
      });
    } catch (e) {
      print("Error fetching route: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get address from lat/lng
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      String? address = await MapService.getAddressFromLatLng(position);

      if (address != null) {
        setState(() {
          _selectedAddress = address;
          _updateDistance();
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  // Search for address
  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Map<String, dynamic>> results =
          await MapService.searchAddress(query);

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print("Error searching for location: $e");
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Set destination from search result
  Future<void> _selectSearchResult(Map<String, dynamic> result) async {
    LatLng location = result['location'];
    String address = result['address'];

    setState(() {
      _endPoint = location;
      _selectedAddress = address;
      _searchResults = [];
      _searchController.clear();
      _updateDistance();
    });

    // Move map to the selected location
    _mapController.move(location, 13);

    // Get route
    _getRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chọn địa chỉ giao hàng',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
              onPressed: _getCurrentLocation, icon: Icon(Icons.my_location)),
          SizedBox(width: 10)
        ],
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.startPoint,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _endPoint = point;
                  // Clear previous route
                  _routePoints = [];
                });
                _getAddressFromLatLng(point);
                _getRoute();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              CurrentLocationLayer(
                positionStream: const LocationMarkerDataStreamFactory()
                    .fromGeolocatorPositionStream(
                  stream: Geolocator.getPositionStream(),
                ),
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: Colors.blue,
                  ),
                  markerSize: Size(20, 20),
                  accuracyCircleColor: Colors.blue,
                ),
              ),
              // Markers layer with rotation
              MarkerLayer(
                rotate: true,
                alignment: const Alignment(0.0, -0.25),
                markers: [
                  // Start marker
                  Marker(
                    point: widget.startPoint,
                    child: const Icon(
                      Icons.store,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  // End marker (if set)
                  if (_endPoint != null)
                    Marker(
                      point: _endPoint!,
                      child: Icon(
                        CupertinoIcons.map_pin_ellipse,
                        color: Colors.purple,
                        size: 40,
                      ),
                    ),
                ],
              ),
              // Polyline for the route
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 6.0,
                    ),
                  ],
                ),
            ],
          ),
          // Search bar
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa chỉ...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: _searchAddress,
                  ),
                ),
                // Search results
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_searchResults[index]['address']),
                          onTap: () {
                            _selectSearchResult(_searchResults[index]);
                          },
                        );
                      },
                    ),
                  ),
                if (_isSearching)
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          // Confirm button at the bottom
          if (_endPoint != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Distance and time estimate display
                    if (_distance != null && _distance! > 0)
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.straighten,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 4),
                                Text(
                                  MapService.formatDistance(_distance!),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            VerticalDivider(
                              thickness: 0.5,
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 4),
                                Text(
                                  MapService.getEstimatedTime(_distance!),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 8),
                    // Confirm button
                    GestureDetector(
                      onTap: () {
                        // Return the selected location and address to the previous screen
                        Navigator.pop(context, {
                          'location': _endPoint,
                          'address': _selectedAddress,
                          'distance': _distance,
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _selectedAddress,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            const Center(
              child: CustomLoading(),
            ),
        ],
      ),
    );
  }
}
