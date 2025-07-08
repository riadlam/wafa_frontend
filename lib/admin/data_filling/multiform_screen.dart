import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loyaltyapp/constants/routes.dart';
import 'package:loyaltyapp/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'business_info_form.dart';
import 'loyalty_program_form.dart';
import 'image_category_form_screen.dart';

class MultiFormScreen extends StatefulWidget {
  const MultiFormScreen({super.key});

  @override
  State<MultiFormScreen> createState() => _MultiFormScreenState();
}

class _MultiFormScreenState extends State<MultiFormScreen> {
  int _currentStep = 0;
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stampsController = TextEditingController(text: '8');
  final ValueNotifier<Color> _selectedColor = ValueNotifier<Color>(const Color(0xFF6C63FF));
  final ValueNotifier<File?> _logoImage = ValueNotifier<File?>(null);
  LatLng? _location;
  String _locationAddress = '';
  String _locationWilaya = '';
  String _locationDaira = '';
  bool _isSubmitting = false;
  
  // Store category and images from ImageCategoryForm
  int? _selectedCategoryId;
  final List<File> _shopImages = [];
  
  // Callback to update category and images from child form
  void _updateCategoryAndImages(int? categoryId, List<File> images) {
    setState(() {
      _selectedCategoryId = categoryId;
      _shopImages.clear();
      _shopImages.addAll(images);
    });
  }

  bool _isDisposed = false;
  final List<Function()> _disposables = [];

  @override
  void initState() {
    super.initState();
    // Add all disposables to the list
    _disposables.addAll([
      _shopNameController.dispose,
      _descriptionController.dispose,
      _stampsController.dispose,
      _selectedColor.dispose,
      _logoImage.dispose,
    ]);
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      // Dispose all controllers and other disposables
      for (final disposable in _disposables) {
        try {
          disposable();
        } catch (e) {
          if (kDebugMode) {
            print('Error disposing: $e');
          }
        }
      }
    }
    super.dispose();
  }

  void updateLocation(LatLng location, [String address = '', String wilaya = '', String daira = '']) {
    setState(() {
      _location = location;
      _locationAddress = address;
      _locationWilaya = wilaya;
      _locationDaira = daira;
    });
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 2) { // Changed from 1 to 2 to accommodate 3 steps
        _currentStep++;
      } else {
        _submitForm();
      }
    });
  }
  
  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      } else {
        context.go(Routes.userTypeSelection);
      }
    });
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_shopNameController.text.isEmpty) {
        throw Exception('Shop name is required');
      }
      if (_location == null) {
        throw Exception('Please set your business location');
      }
      if (_selectedCategoryId == null) {
        throw Exception('Please select a category');
      }
      if (_shopImages.isEmpty) {
        throw Exception('Please upload at least one shop image');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.8:8000/api/upsert-loyalty-card'),
      );

      final token = await AuthService().getJwtToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add location data as top-level fields
      final lat = _location?.latitude ?? 0.0;
      final lng = _location?.longitude ?? 0.0;
      
      // Add all fields to the request
      request.fields['shop_name'] = _shopNameController.text;
      request.fields['name'] = _shopNameController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['total_stamps'] = _stampsController.text;
      request.fields['color'] = _colorToHex(_selectedColor.value);
      request.fields['category_id'] = _selectedCategoryId.toString();
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();
      
      // Also include the full location details as JSON
      final locationDetails = {
        'lat': lat,
        'lng': lng,
        'address': _locationAddress,
        'wilaya': _locationWilaya,
        'daira': _locationDaira,
      };
      request.fields['location_name'] = jsonEncode(locationDetails);
      
      // Log the request body
      final requestBody = {
        'shop_name': _shopNameController.text,
        'name': _shopNameController.text,
        'description': _descriptionController.text,
        'total_stamps': _stampsController.text, // Changed from stamps_required to total_stamps
        'color': _colorToHex(_selectedColor.value),
        'category_id': _selectedCategoryId.toString(),
        'location_name': locationDetails,
        'has_logo': _logoImage.value != null,
        'shop_images_count': _shopImages.length,
      };
      
      if (kDebugMode) {
        print('📤 API Request Body:');
        print(jsonEncode(requestBody, toEncodable: (item) {
          if (item is LatLng) {
            return {'lat': item.latitude, 'lng': item.longitude};
          }
          return item.toString();
        }));
      }

      if (_logoImage.value != null) {
        final fileStream = http.ByteStream(_logoImage.value!.openRead());
        final length = await _logoImage.value!.length();
        final multipartFile = http.MultipartFile(
          'logo',
          fileStream,
          length,
          filename: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      for (var image in _shopImages) {
        final fileStream = http.ByteStream(image.openRead());
        final length = await image.length();
        final multipartFile = http.MultipartFile(
          'images[]',
          fileStream,
          length,
          filename: 'shop_image_${_shopImages.indexOf(image)}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = response.body;
      
      if (kDebugMode) {
        print('🔵 Server Response (${response.statusCode}):');
        print(responseBody);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          context.go(Routes.adminDashboard);
        }
      } else {
        try {
          final error = jsonDecode(responseBody);
          throw Exception(error['message'] ?? 'Failed to save loyalty card. Status: ${response.statusCode}');
        } catch (e) {
          // If we can't parse the error as JSON, include the raw response
          throw Exception('Failed to save loyalty card. Status: ${response.statusCode}\nResponse: $responseBody');
        }
      }
    } catch (e, stackTrace) {
      // Log the full error and stack trace
      if (kDebugMode) {
        print('❌ Error submitting form:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        
        // If it's an HTTP error, try to get the response body
        if (e is http.ClientException) {
          print('Response: ${e.message}');
        } else if (e is http.Response) {
          print('Status Code: ${e.statusCode}');
          print('Response Body: ${e.body}');
        }
      }
      
      if (mounted) {
        final errorMessage = e is http.ClientException || e is http.Response 
            ? 'Network error occurred. Please check your connection.'
            : 'Error: ${e.toString()}';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'DETAILS',
              textColor: Colors.white,
              onPressed: () {
                // Show more detailed error in a dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Text(
                        'Error: $e\n\n${stackTrace.toString()}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Owner Setup'),
        leading: _currentStep > 0 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IndexedStack(
          index: _currentStep,
          children: [
            // Step 1: Business Info Form
            BusinessInfoForm(
              onNext: _nextStep,
              onBack: _previousStep,
              updateLocation: updateLocation,
            ),
            // Step 2: Category & Images Form
            ImageCategoryForm(
              onNext: _nextStep,
              onPrevious: _previousStep,
              onUpdateData: _updateCategoryAndImages,
            ),
            // Step 3: Loyalty Program Form
            LoyaltyProgramForm(
              shopNameController: _shopNameController,
              descriptionController: _descriptionController,
              stampsController: _stampsController,
              selectedColor: _selectedColor,
              logoImage: _logoImage,
              isSubmitting: _isSubmitting,
              selectedCategoryId: _selectedCategoryId,
              onPrevious: _previousStep,
              onSubmit: _nextStep,
            ),
          ],
        ),
      ),
    );
  }
}