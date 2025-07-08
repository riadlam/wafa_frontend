import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class BusinessInfoForm extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final void Function(LatLng location, String address, String wilaya, String daira) updateLocation;
  
  const BusinessInfoForm({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.updateLocation,
  });

  @override
  State<BusinessInfoForm> createState() => _BusinessInfoFormState();
}

class _BusinessInfoFormState extends State<BusinessInfoForm> with TickerProviderStateMixin {
  Widget _buildAddressChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _isLocating = false;
  String _locationError = '';
  bool _isMapReady = false;
  double _zoomLevel = 15.0;
  bool _isMapMoving = false;
  LatLng? _pendingLocation;
  Timer? _mapMoveEndTimer;
  String _address = '';
  String _wilaya = '';
  String _daira = '';
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    print('🔄 BusinessInfoForm - initState called');
    // Initialize with a default location in case we can't get the current one
    _currentLocation = const LatLng(0, 0);
    _pendingLocation = _currentLocation;
    // Start location process after a small delay to ensure widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeLocation();
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _mapMoveEndTimer?.cancel();
    // Cancel any pending address updates
    _isLoadingAddress = false;
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // First, check if we can get the current location
    await _getCurrentLocation();
    
    // If we still don't have a location, show an error
    if (_currentLocation == null) {
      setState(() {
        _isLoading = false;
        _locationError = 'Could not determine your location. Please try again or set it manually.';
      });
    }
  }

  // Get address from coordinates using the Geolocator API
  Future<void> _updateAddress(LatLng location) async {
    if (_isLoadingAddress) return;
    
    setState(() {
      _isLoadingAddress = true;
      _address = 'Getting location...';
      _wilaya = '';
      _daira = '';
    });
    
    try {
      print('🌍 Getting location for ${location.latitude}, ${location.longitude}');
      
      // Try using the Geolocator API with the provided API key
      try {
        final response = await http.get(
          Uri.parse(
            'https://geocode.maps.co/reverse?lat=${location.latitude}&lon=${location.longitude}&api_key=686367742afc5896385425vga9255e8&format=json&accept-language=fr',
          ),
          headers: {
            'User-Agent': 'LoyaltyApp/1.0',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));
        
        print('🌐 API Response Status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('📍 API Response: $data');
          
          if (data['address'] != null) {
            final address = data['address'] as Map<String, dynamic>;
            
            // Extract address components
            String wilaya = (address['state'] ?? '').toString();
            String daira = (address['city'] ?? address['town'] ?? address['village'] ?? '').toString();
            
            // Clean up wilaya and daira names
            wilaya = wilaya.replaceAll(RegExp(r'\d+'), '').trim();
            if (daira.startsWith('Daïra ')) {
              daira = daira.substring(6);
            }
            
            // Build address string with available components
            final addressParts = [
              address['road'],
              address['neighbourhood'],
              address['suburb'],
              if (daira.isNotEmpty) daira,
              if (wilaya.isNotEmpty) wilaya,
              address['postcode'] ?? '',
            ].where((part) => part != null && part.toString().isNotEmpty).toList();
            
            setState(() {
              _address = addressParts.join(', ');
              _wilaya = wilaya;
              _daira = daira;
            });
            return;
          }
        } else {
          print('⚠️ API error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('⚠️ Error with geolocation API: $e');
      }
      
      // Final fallback: Just show coordinates
      setState(() {
        _address = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        _wilaya = '';
        _daira = '';
      });
      
    } catch (e, stackTrace) {
      print('❌ Error in _updateAddress: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _address = 'Location: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        _wilaya = '';
        _daira = '';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    print('📍 Starting _getCurrentLocation');
    if (_isLocating) return; // Prevent multiple clicks
    
    setState(() {
      _isLocating = true;
      _locationError = '';
    });

    try {
      // Check location permission
      print('🔍 Checking location permissions...');
      var permission = await Geolocator.checkPermission();
      print('ℹ️ Current permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        print('⚠️ Location permission denied, requesting permission...');
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && 
            permission != LocationPermission.always) {
          setState(() {
            _locationError = 'Location permission is required to continue';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final errorMsg = 'Location permissions are permanently denied. Please enable them in app settings.';
        print('❌ $errorMsg');
        setState(() {
          _locationError = errorMsg;
          _isLoading = false;
        });
        return;
      }

      // Get current position
      print('📍 Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      final newLocation = LatLng(position.latitude, position.longitude);
      print('✅ Position obtained - Lat: ${position.latitude}, Lng: ${position.longitude}');
      print('🗺️ Updating location in BusinessInfoForm: $newLocation');

      setState(() {
        _currentLocation = newLocation;
        _isLoading = false;
      });
      
      // Update parent's location
      if (mounted) {
        widget.updateLocation(newLocation, _address, _wilaya, _daira);
      }
      
      // Update address information
      _updateAddress(newLocation);
      
      // Only try to move the map if it's ready
      if (_isMapReady && mounted) {
        print('🔄 Moving map to new location...');
        _mapController.move(
          newLocation,
          15.0,
        );
        print('✅ Map moved to: $newLocation');
      } else {
        print('ℹ️ Map not ready yet, will move when ready');
        // The map will be moved when onMapReady is called
      }
    } catch (e, stackTrace) {
      final errorMsg = '❌ Error getting location: $e';
      print(errorMsg);
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _locationError = 'Could not get your location. Please check your connection and try again.';
          _isLoading = false;
          _isLocating = false;
        });
      }
      
      print('ℹ️ Location error state set: $_locationError');
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    print('📍 Map tapped at: $point');
    setState(() {
      _currentLocation = point;
      _pendingLocation = point;
      // Clear previous address while loading new one
      _address = 'Getting address...';
      _wilaya = '';
      _daira = '';
    });
    // Update parent's location when user taps on map
    widget.updateLocation(point, _address, _wilaya, _daira);
    // Update address information
    _updateAddress(point);
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveStart) {
      setState(() {
        _isMapMoving = true;
      });
      _mapMoveEndTimer?.cancel();
    } else if (event is MapEventMoveEnd) {
      _mapMoveEndTimer?.cancel();
      _mapMoveEndTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          final newLocation = _mapController.camera.center;
          setState(() {
            _isMapMoving = false;
            _zoomLevel = _mapController.camera.zoom;
            _currentLocation = newLocation;
            _pendingLocation = newLocation;
          });
          // Update parent's location
          widget.updateLocation(newLocation, _address, _wilaya, _daira);
          // Update address for the new location
          _updateAddress(newLocation);
        }
      });
    } else if (event is MapEventFlingAnimation) {
      // Handle fling animation end
      _mapMoveEndTimer?.cancel();
      _mapMoveEndTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isMapMoving = false;
            _zoomLevel = _mapController.camera.zoom;
            _pendingLocation = _mapController.camera.center;
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔄 BusinessInfoForm - didChangeDependencies called');
    print('🌍 Current location state: ${_currentLocation?.toString() ?? 'null'}');
    print('⏳ Loading state: $_isLoading');
    print('🗺️ Map ready: $_isMapReady');
    print('❌ Error state: ${_locationError.isNotEmpty ? _locationError : 'No errors'}');
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building BusinessInfoForm UI...');
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Business Location',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please confirm your business location on the map',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // Map Container
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _locationError.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_off, size: 64, color: Colors.orange),
                                const SizedBox(height: 24),
                                Text(
                                  _locationError,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (_locationError.contains('permissions'))
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text(
                                      'Please enable location permissions in your device settings to continue.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ElevatedButton.icon(
                                  onPressed: _getCurrentLocation,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            FlutterMap(
                              key: const ValueKey('business_location_map'),
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _currentLocation!,
                                initialZoom: _zoomLevel,
                                interactionOptions: const InteractionOptions(
                                  flags: ~InteractiveFlag.doubleTapZoom & ~InteractiveFlag.doubleTapDragZoom,
                                ),
                                onMapEvent: _onMapEvent,
                                onMapReady: () {
                                  print('🗺️ Map is ready!');
                                  if (mounted) {
                                    setState(() {
                                      _isMapReady = true;
                                    });
                                    _getCurrentLocation();
                                  }
                                },
                                onTap: _onMapTap,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                  userAgentPackageName: 'com.example.loyaltyapp',
                                  // Using default tile provider
                                ),
                                MarkerLayer(
                                  markers: [
                                    if (_currentLocation != null)
                                      Marker(
                                        width: 40.0,
                                        height: 40.0,
                                        point: _currentLocation!,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 40.0,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            // Centered location indicator
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Top part of the pin (the pointy end)
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                                  ),
                                  // Pin stem
                                  Container(
                                    width: 2,
                                    height: 15,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Prominent location display at bottom of map
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isMapMoving ? 'UPDATING LOCATION...' : 'SELECTED LOCATION',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}  Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_isLoadingAddress) ...[
                                            const SizedBox(height: 4),
                                            const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                              ),
                                            ),
                                          ] else if (_address.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              _address,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (_wilaya.isNotEmpty || _daira.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  if (_daira.isNotEmpty) ...[
                                                    _buildAddressChip('Daira: $_daira'),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  if (_wilaya.isNotEmpty)
                                                    _buildAddressChip('Wilaya: $_wilaya'),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Map controls
                            Positioned(
                              bottom: 70,
                              right: 16,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Current location button
                                  FloatingActionButton(
                                    heroTag: 'my_location',
                                    onPressed: _isLocating ? null : _getCurrentLocation,
                                    backgroundColor: Colors.white,
                                    mini: true,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: _isLocating
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                              ),
                                            )
                                          : const Icon(Icons.my_location, color: Colors.blue, size: 20, key: ValueKey('location_icon')),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Zoom in button
                                  FloatingActionButton.small(
                                    heroTag: 'zoom_in',
                                    onPressed: () {
                                      setState(() {
                                        _zoomLevel = (_zoomLevel + 1).clamp(2.0, 18.0);
                                      });
                                      _mapController.move(
                                        _mapController.camera.center,
                                        _zoomLevel,
                                      );
                                    },
                                    backgroundColor: Colors.white,
                                    child: const Icon(Icons.add, color: Colors.blue, size: 20),
                                  ),
                                  const SizedBox(height: 4),
                                  // Zoom out button
                                  FloatingActionButton.small(
                                    heroTag: 'zoom_out',
                                    onPressed: () {
                                      setState(() {
                                        _zoomLevel = (_zoomLevel - 1).clamp(2.0, 18.0);
                                      });
                                      _mapController.move(
                                        _mapController.camera.center,
                                        _zoomLevel,
                                      );
                                    },
                                    backgroundColor: Colors.white,
                                    child: const Icon(Icons.remove, color: Colors.blue, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Removed the separate location panel as it's now inside the map
          
          // Continue button
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentLocation != null ? () {
                  print('🚀 Continue button pressed with location: $_currentLocation');
                  print('📌 Latitude: ${_currentLocation!.latitude}, Longitude: ${_currentLocation!.longitude}');
                  widget.onNext();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
