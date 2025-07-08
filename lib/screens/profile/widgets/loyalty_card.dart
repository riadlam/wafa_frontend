import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import '../../../../providers/user_provider.dart';

class LoyaltyCard extends StatelessWidget {
  const LoyaltyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    if (userProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    if (userProvider.error != null) {
      return Center(
        child: Text(
          'Error loading user data',
          style: GoogleFonts.poppins(color: AppColors.textPrimary),
        ),
      );
    }
    
    final userEmail = userProvider.user?.email ?? 'user@example.com';
    
    return _buildLoyaltyCard(context, userEmail);
  }
  
  Widget _buildLoyaltyCard(BuildContext context, String userEmail) {
    final screenSize = MediaQuery.of(context).size;
    final qrCodeHeight = screenSize.height / 3;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Premium Member',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    'Scan to earn points',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: screenSize.width - 20, // Full width minus 10px on each side
                    height: qrCodeHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 10), // 10px padding on each side
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=$userEmail&margin=10&color=000000&qzone=3&ecc=H&format=png',
                          height: qrCodeHeight * 0.7, // 70% of the container height
                          width: qrCodeHeight * 0.7, // Keep it square
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: qrCodeHeight * 0.6,
                              width: qrCodeHeight * 0.6,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error_outline, size: 40, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Show this code at checkout',
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${userEmail.split('@').first}\'s Card',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                    ),
                  ),
                                 SizedBox(height: 100),

                ],
              ),
            ),
          ],
        )
      )
    );
  }
}
