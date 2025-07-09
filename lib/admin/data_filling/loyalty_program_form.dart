import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loyaltyapp/constants/colors.dart' as app_colors;

import 'package:loyaltyapp/screens/subscribedloyaltycards/models/loyalty_card_model.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/widgets/loyalty_card_item.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Card preview using the actual LoyaltyCardItem widget
class CardPreview extends StatelessWidget {
  final String shopName;
  final File? logoFile;
  final Color color;
  final int totalStamps;
  final int? earnedStamps; // Make earnedStamps optional
  final String? tempImagePath;
  final int? categoryId; // Add category ID

  const CardPreview({
    super.key,
    required this.shopName,
    this.logoFile,
    required this.color,
    this.totalStamps = 8,
    this.earnedStamps,
    this.tempImagePath,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we have a logo file or temp image path
    final hasLogoFile = logoFile != null && logoFile!.path.isNotEmpty;
    final hasTempImage = tempImagePath != null && tempImagePath!.isNotEmpty;
    final hasImage = hasLogoFile || hasTempImage;

    // Calculate half of total stamps (rounded down)
    final halfStamps = totalStamps ~/ 2;
    // Use provided earnedStamps if available, otherwise use half of total
    final effectiveEarnedStamps = earnedStamps ?? halfStamps;

    // Create a temporary LoyaltyCardModel for preview
    final card = _createCardModel(
      name: shopName.isNotEmpty ? shopName : 'Your Shop Name',
      totalStamps: totalStamps,
      earnedStamps: effectiveEarnedStamps,
      color: color,
      // For local files, we need to use the file:// scheme
      imageUrl:
          hasLogoFile
              ? 'file://${logoFile!.path}'
              : (hasTempImage ? tempImagePath : null),
      categoryId: categoryId,
    );

    debugPrint('Card image URL: ${card.imageUrl}');

    return LoyaltyCardItem(
      card: card,
      // Always pass the category icon, the widget will handle whether to show it or not
      icon: _getCategoryIcon(categoryId),
    );
  }

  IconData _getCategoryIcon(int? categoryId) {
    // Map category IDs to Material icons
    switch (categoryId) {
      case 1: // Assuming 1 is the ID for pizza
        return LucideIcons.sprayCan;
      case 2: // Example for another category
        return LucideIcons.sprayCan;
      case 3:
        return LucideIcons.scissors;
      case 4:
        return LucideIcons.ruler;
      case 5:
        return LucideIcons.cupSoda;
      case 6:
        return LucideIcons.sandwich;
      default:
        return Icons.store; // Default icon
    }
  }

  LoyaltyCardModel _createCardModel({
    required String name,
    required int totalStamps,
    required int earnedStamps,
    required Color color,
    String? imageUrl,
    int? categoryId,
  }) {
    // Use category-based icon if no image is provided
    final icon = imageUrl == null ? _getCategoryIcon(categoryId) : null;

    return LoyaltyCardModel(
      id: 'preview',
      name: name,
      description: 'Loyalty Card',
      totalStamps: totalStamps,
      earnedStamps: earnedStamps,
      imageUrl: imageUrl,
      icon: icon,
      backgroundColor: color,
      textColor: Colors.white,
      stampColor: Colors.white.withOpacity(0.8),
      stampFillColor: Colors.white,
    );
  }
}

class LoyaltyProgramForm extends StatefulWidget {
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;
  final TextEditingController shopNameController;
  final TextEditingController descriptionController;
  final TextEditingController stampsController;
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<File?> logoImage;
  final bool isSubmitting;
  final int? selectedCategoryId;

  const LoyaltyProgramForm({
    super.key,
    required this.onPrevious,
    required this.onSubmit,
    required this.shopNameController,
    required this.descriptionController,
    required this.stampsController,
    required this.selectedColor,
    required this.logoImage,
    required this.isSubmitting,
    this.selectedCategoryId,
  });

  @override
  State<LoyaltyProgramForm> createState() => _LoyaltyProgramFormState();
}

class _LoyaltyProgramFormState extends State<LoyaltyProgramForm> {
  late final TextEditingController _shopNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _stampsController;
  late final ValueNotifier<Color> _selectedColor;
  late final ValueNotifier<File?> _logoImage;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _shopNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _shopNameController = widget.shopNameController;
    _descriptionController = widget.descriptionController;
    _stampsController = widget.stampsController;
    _selectedColor = widget.selectedColor;
    _logoImage = widget.logoImage;

    // Add listener to focus node to scroll to top when focused
    _shopNameFocusNode.addListener(() {
      if (_shopNameFocusNode.hasFocus) {
        _scrollToTop();
      }
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _stampsController.dispose();
    _selectedColor.dispose();
    _logoImage.dispose();
    _scrollController.dispose();
    _shopNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _logoImage.value = File(pickedFile.path);
    }
  }

  Future<void> _showColorPicker(BuildContext context) async {
    Color tempColor = _selectedColor.value;

    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pick a color'),
              content: SingleChildScrollView(
                child: MaterialPicker(
                  pickerColor: tempColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      tempColor = color;
                    });
                  },
                  enableLabel: true,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _selectedColor.value = tempColor;
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorPickerSection() {
    return ValueListenableBuilder<Color>(
      valueListenable: _selectedColor,
      builder: (context, currentColor, _) {
        final hexCode =
            '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Color',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showColorPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: currentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      hexCode,
                      style: GoogleFonts.robotoMono(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.color_lens, color: Colors.grey[600], size: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Map category IDs to their corresponding icons
  IconData _getCategoryIcon(int? categoryId) {
    switch (categoryId) {
      case 1: // Assuming 1 is the ID for pizza
        return Icons.local_pizza;
      case 2: // Example for another category
        return Icons.coffee;
      case 3:
        return Icons.restaurant;
      case 4:
        return Icons.local_cafe;
      case 5:
        return Icons.shopping_bag;
      default:
        return Icons.store; // Default icon
    }
  }

  // Function to handle scroll to top
  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Preview
          Text(
            'Card Preview',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<Color>(
            valueListenable: _selectedColor,
            builder: (context, color, _) {
              return ValueListenableBuilder<File?>(
                valueListenable: _logoImage,
                builder: (context, logoFile, _) {
                  return CardPreview(
                    shopName:
                        _shopNameController.text.isNotEmpty
                            ? _shopNameController.text
                            : 'Your Business',
                    logoFile: logoFile,
                    color: color,
                    totalStamps: int.tryParse(_stampsController.text) ?? 8,
                    categoryId: widget.selectedCategoryId,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),

          // Form Section
          const SizedBox(height: 16),

          // Logo Upload
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brand Logo',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<File?>(
                        valueListenable: _logoImage,
                        builder: (context, file, _) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1.5,
                                style: BorderStyle.values[1],
                              ),
                            ),
                            child:
                                file != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 28,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add Logo',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Shop Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shop Name',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _shopNameController,
                focusNode: _shopNameFocusNode,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter shop name',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: app_colors.AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.store_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter shop description',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4F46E5),
                      width: 1.5,
                    ),
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stamps & Color Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number of Stamps Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number of Stamps',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value:
                          _stampsController.text.isNotEmpty
                              ? int.tryParse(_stampsController.text) ?? 8
                              : 8,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: app_colors.AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        prefixIcon: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                      isExpanded: true,
                      items:
                          List.generate(
                            20,
                            (index) => index + 1,
                          ).map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _stampsController.text = newValue.toString();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Color Picker
              Expanded(child: _buildColorPickerSection()),
            ],
          ),
          const SizedBox(height: 50),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.onPrevious,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: widget.isSubmitting ? null : widget.onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      widget.isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Save & Continue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
