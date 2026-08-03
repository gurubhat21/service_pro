import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final Geocoding _geocoding = Geocoding();
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(20.5937, 78.9629); // Default to India
  Marker? _selectedMarker;
  String _selectedAddress = "Tap on map to select location";
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _getUserCurrentLocation();
  }

  Future<void> _getUserCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      LatLng latLng = LatLng(position.latitude, position.longitude);
      
      _updateSelectedLocation(latLng);
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSelectedLocation(LatLng position) async {
    setState(() {
      _currentPosition = position;
      _selectedMarker = Marker(
        markerId: const MarkerId('selected-location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
    });

    try {
      List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = "Location selected: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
    }
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      List<Location> locations = await _geocoding.locationFromAddress(query);
      if (locations.isNotEmpty) {
        LatLng latLng = LatLng(locations.first.latitude, locations.first.longitude);
        await _updateSelectedLocation(latLng);
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 15),
        ));
      } else {
        throw Exception('Address not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not find address')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF00BCD4)),
            onPressed: () {
              Navigator.pop(context, {
                'latitude': _currentPosition.latitude,
                'longitude': _currentPosition.longitude,
                'address': _selectedAddress,
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 14),
            markers: _selectedMarker != null ? {_selectedMarker!} : {},
            onTap: _updateSelectedLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          // Search Bar Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search address...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _searchAddress(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                    onPressed: _searchAddress,
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
              ),
            ),

          // Bottom Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Address',
                    style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'latitude': _currentPosition.latitude,
                          'longitude': _currentPosition.longitude,
                          'address': _selectedAddress,
                        });
                      },
                      child: const Text('Confirm Location', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Current Location FAB
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF1C2128),
              onPressed: _getUserCurrentLocation,
              child: const Icon(Icons.my_location, color: Color(0xFF00BCD4)),
            ),
          ),
        ],
      ),
    );
  }
}
