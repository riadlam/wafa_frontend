import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loyaltyapp/constants/routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyaltyapp/services/auth_service.dart';
import 'subscription/index.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  bool _isLoading = false;

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        if (!mounted) return null;
        
        final enableLocation = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text(
              'Please enable location services to get the best experience.\n\n' 
              'We need your location to show nearby shops and offers.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openLocationSettings();
                  Navigator.pop(context, true);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        
        print('User chose to enable location: $enableLocation');
        if (enableLocation != true) return null;
        
        // Check again after user returns from settings
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('Current location permission: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Requested permission, new status: $permission');
        
        if (permission != LocationPermission.whileInUse && 
            permission != LocationPermission.always) {
          if (!mounted) return null;
          
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'Location permission is required to show nearby shops and offers.\n\n'
                'Please enable it in your device settings to continue.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Geolocator.openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return null;
        
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Permanently Denied'),
            content: const Text(
              'Location permissions are permanently denied.\n\n'
              'Please enable them in your device settings to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return null;
      }

      try {
        Position position = await Geolocator.getCurrentPosition();
        print('Got position: $position');
        return position;
      } catch (e) {
        print('Error getting location: $e');
        return null;
      }
    } catch (e) {
      print('Error in _getCurrentLocation: $e');
      return null;
    }
  }

  Future<void> _handleRegularUserSelection() async {
    setState(() => _isLoading = true);
    
    try {
      // Set registration_phase to false for regular users
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registration_phase', false);
      print('✅ Set registration_phase to false in SharedPreferences');
      
      // First, mark the user as existed in the backend
      try {
        final success = await AuthService().markUserAsExisted();
        if (!success) {
          throw Exception('Failed to update user status');
        }
        print('✅ User marked as existed in the backend');
      } catch (e) {
        print('⚠️ Error marking user as existed: $e');
        // Continue with the flow even if this fails
      }

      // Check location service status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        
        // Show dialog to enable location services
        final enableLocation = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text(
              'Please enable location services to get the best experience.\n\n' 
              'We need your location to show nearby shops and offers.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openLocationSettings();
                  Navigator.pop(context, true);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        
        if (enableLocation != true) {
          setState(() => _isLoading = false);
          return;
        }
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && 
            permission != LocationPermission.always) {
          if (!mounted) {
            setState(() => _isLoading = false);
            return;
          }
          
          // Show error if permission denied
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'Location permission is required to show nearby shops and offers.\n\n'
                'Please enable it in your device settings to continue.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _isLoading = false);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) {
          setState(() => _isLoading = false);
          return;
        }
        
        // Show dialog to open app settings
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Permanently Denied'),
            content: const Text(
              'Location permissions are permanently denied.\n\n'
              'Please enable them in your device settings to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isLoading = false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openAppSettings();
                  Navigator.pop(context);
                  setState(() => _isLoading = false);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }

      // If we got this far, we have permission
      try {
        final position = await Geolocator.getCurrentPosition();
        print('Regular User Location: ${position.latitude}, ${position.longitude}');
        
        // Save location to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_latitude', position.latitude);
        await prefs.setDouble('user_longitude', position.longitude);
        print('Location saved to SharedPreferences');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location found: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'),
              duration: const Duration(seconds: 3),
            ),
          );
          // Add a small delay to show the snackbar before navigation
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            context.go(Routes.home);
          }
        }
      } catch (e) {
        print('Error getting location: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not get your location. Using default location.'),
              duration: Duration(seconds: 3),
            ),
          );
          // Still navigate to home even if location fails
          context.go(Routes.home);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleShopOwnerSelection() async {
    // Save registration phase flag
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registration_phase', true);
      print('✅ Set registration_phase to true in SharedPreferences');
    } catch (e) {
      print('⚠️ Error saving registration_phase: $e');
    }
    
    // Check location service status first
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      
      // Show dialog to enable location services
      final enableLocation = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Please enable location services to continue as a shop owner.\n\n' 
            'We need your location to show your business on the map and help customers find you.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.pop(context, true);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      
      if (enableLocation != true) return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) {
        if (!mounted) return;
        
        // Show error if permission denied
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location permission is required to set up a shop.\n\n'
              'Please enable it in your device settings to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      
      // Show dialog to open app settings
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Permanently Denied'),
          content: const Text(
            'Location permissions are permanently denied.\n\n'
            'Please enable them in your device settings to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return;
    }

    // If we got this far, we have permission
    if (mounted) {
      // Navigate to subscription pricing screen first
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SubscriptionPricingScreen(),
        ),
      );
      
      // If subscription is completed, proceed to shop owner setup
      if (result == true && mounted) {
        if (context.mounted) {
          context.go(Routes.shopOwnerSetup);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Select User Type'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Regular User Button
                ElevatedButton(
                  onPressed: _isLoading 
                      ? null 
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await _handleRegularUserSelection();
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    minimumSize: const Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.person, size: 50),
                      SizedBox(height: 10),
                      Text(
                        'Regular User',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('Access app features as a customer'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Shop Owner Button
                ElevatedButton(
                  onPressed: _isLoading 
                      ? null 
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await _handleShopOwnerSelection();
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    minimumSize: const Size(double.infinity, 0),
                    backgroundColor: Colors.orange[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.store, size: 50),
                      SizedBox(height: 10),
                      Text(
                        'Shop Owner',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('Manage your business and rewards'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4.0,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
