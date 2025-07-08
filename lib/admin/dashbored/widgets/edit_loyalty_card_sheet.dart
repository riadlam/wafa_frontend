import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loyaltyapp/constants/app_colors.dart' as app_colors;
import 'package:loyaltyapp/services/loyalty_card_service.dart';



class EditLoyaltyCardSheet extends StatefulWidget {
  final int cardId;
  final TextEditingController shopNameController;
  final TextEditingController descriptionController;
  final TextEditingController stampsController;
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<File?> logoImage;
  final Function() onSave;
  final Function() onDelete;
  final Function(String, String, int) onUpdateSuccess;
  
  const EditLoyaltyCardSheet({
    super.key,
    required this.cardId,
    required this.shopNameController,
    required this.descriptionController,
    required this.stampsController,
    required this.selectedColor,
    required this.logoImage,
    required this.onSave,
    required this.onDelete,
    required this.onUpdateSuccess,
  });
  
  @override
  State<EditLoyaltyCardSheet> createState() => _EditLoyaltyCardSheetState();
}

class _EditLoyaltyCardSheetState extends State<EditLoyaltyCardSheet> {
  bool _isLoading = false;
  final LoyaltyCardService _loyaltyCardService = LoyaltyCardService();

  // Convert Color to hex string
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
  
  // Handle save button press
  Future<void> _handleSave() async {
    if (_isLoading) return;
    
    final shopName = widget.shopNameController.text.trim();
    final description = widget.descriptionController.text.trim();
    final totalStamps = int.tryParse(widget.stampsController.text) ?? 8;
    final color = _colorToHex(widget.selectedColor.value);
    
    if (shopName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop name is required')),
        );
      }
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _loyaltyCardService.updateLoyaltyCard(
        cardId: widget.cardId,
        shopName: shopName,
        description: description,
        color: color,
        totalStamps: totalStamps,
        logoFile: widget.logoImage.value,
      );
      
      if (!mounted) return;
      
      // Store the response data before any potential navigation
      final logoUrl = response['logo_url'] ?? '';
      final responseColor = response['color'] ?? color;
      final responseStamps = response['total_stamps'] ?? totalStamps;
      
      // Notify parent about successful update
      widget.onUpdateSuccess(logoUrl, responseColor, responseStamps);
      
      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loyalty card updated successfully')),
      );
      
      // Close the sheet
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      widget.logoImage.value = File(pickedFile.path);
    }
  }

  Future<void> _showColorPicker(BuildContext context) async {
    Color tempColor = widget.selectedColor.value;
    
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
                    widget.selectedColor.value = tempColor;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return _buildContent(context, screenWidth);
  }
  
  Widget _buildContent(BuildContext context, double screenWidth) {
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Card Design',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Modern Logo Upload Section - Full Width
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Brand Logo',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  
                ],
              ),
              const SizedBox(height: 12),
                // Full-width logo upload container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<File?>(
                        valueListenable: widget.logoImage,
                        builder: (context, file, _) {
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 100,
                                height: 100,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 2,
                                  style: BorderStyle.values[1], // Using index 1 for dashed style
                                ),
                              ),
                              child: file != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(file, fit: BoxFit.cover),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.6),
                                                Colors.transparent,
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.6),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Center(
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 24,
                                            color: Colors.blue[600],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Upload Logo',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF475569),
                                          ),
                                        ),
                                       
                                      ],
                                    ),
                            ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Recommended size: 500x500px • Max 2MB',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
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
                controller: widget.shopNameController,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF1E293B),
                ),
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
                  prefixIcon: const Icon(Icons.store_outlined, size: 20, color: Colors.grey),
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
                controller: widget.descriptionController,
                maxLines: 3,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter shop description',
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
                    borderSide: const BorderSide(
                      color: Color(0xFF4F46E5),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                      value: widget.stampsController.text.isNotEmpty 
                          ? int.tryParse(widget.stampsController.text) ?? 8
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
                        prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 20, color: Colors.grey),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      isExpanded: true,
                      items: List.generate(20, (index) => index + 1).map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          widget.stampsController.text = newValue.toString();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Color Preview Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColorPickerSection(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action Buttons
          Column(
            children: [
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app_colors.AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Save Changes',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
             
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    ));
  }

  Widget _buildColorPickerSection() {
    return ValueListenableBuilder<Color>(
      valueListenable: widget.selectedColor,
      builder: (context, currentColor, _) {
        final hexCode = '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}';
        
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    // Color preview circle
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
                    // Current color hex code
                    Text(
                      hexCode,
                      style: GoogleFonts.robotoMono(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Edit icon
                    Icon(
                      Icons.color_lens_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              image: widget.logoImage.value != null
                  ? DecorationImage(
                      image: FileImage(widget.logoImage.value!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.logoImage.value == null
                ? const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to change logo',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop Name',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.shopNameController,
          decoration: const InputDecoration(
            hintText: 'Enter shop name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Total Stamps',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.stampsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter total stamps',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildEditOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : const Color(0xFF1E293B);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the edit card sheet
void showEditLoyaltyCardSheet({
  required BuildContext context,
  required int cardId,
  required TextEditingController shopNameController,
  required TextEditingController descriptionController,
  required TextEditingController stampsController,
  required ValueNotifier<Color> selectedColor,
  required ValueNotifier<File?> logoImage,
  required Function() onSave,
  required Function() onDelete,
  required Function(String, String, int) onUpdateSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.7,
      maxChildSize: 0.7,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: EditLoyaltyCardSheet(
          cardId: cardId,
          shopNameController: shopNameController,
          descriptionController: descriptionController,
          stampsController: stampsController,
          selectedColor: selectedColor,
          logoImage: logoImage,
          onSave: onSave,
          onDelete: onDelete,
          onUpdateSuccess: onUpdateSuccess,
        ),
      ),
    ),
  );
}
