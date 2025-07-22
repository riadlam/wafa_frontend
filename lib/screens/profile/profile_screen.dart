import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loyaltyapp/screens/profile/message_popup_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:loyaltyapp/providers/websocket_provider.dart';
import 'package:loyaltyapp/services/auth_service.dart';
import '../../constants/app_colors.dart';
import 'widgets/profile_header.dart';
import 'widgets/loyalty_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _lastMessage = 'profile.messages.no_messages'.tr();
  bool _isConnected = false;
  // Error state is handled by the WebSocket provider

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeWebSocket();
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      final webSocketProvider = context.read<WebSocketProvider>();
      webSocketProvider.removeListener(_onWebSocketStateChanged);
    }
    final webSocketProvider = context.read<WebSocketProvider>();
    webSocketProvider.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      return await authService.getJwtToken();
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  Future<void> _initializeWebSocket() async {
    if (!mounted) return;
    
    try {
      final token = await _getToken();
      if (token == null) {
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
          _showMessageDialog('profile.authentication_required'.tr());
        }
        return;
      }
      
      if (!mounted) return;
      
      final webSocketProvider = context.read<WebSocketProvider>();
      
      // Initialize WebSocket connection
      webSocketProvider.initialize(authToken: token);
      
      if (mounted) {
        // Listen for state changes
        webSocketProvider.addListener(_onWebSocketStateChanged);
      }
    } catch (e) {
      if (kDebugMode) print('Error initializing WebSocket: $e');
      if (mounted) {
        _showErrorDialog('profile.connection.failed'.tr());
      }
    }
  }
  
  void _onWebSocketStateChanged() {
    if (!mounted) return;
    
    try {
      final webSocketProvider = context.read<WebSocketProvider>();
      
      if (mounted) {
        setState(() {
          _isConnected = webSocketProvider.isConnected;
          _lastMessage = webSocketProvider.lastMessage ?? _lastMessage;
        });
        
        // Show message dialog when a new message is received
        if (webSocketProvider.lastMessage != null) {
          _showMessageDialog(webSocketProvider.lastMessage!);
        }
        
        // Show error dialog if there's an error
        if (webSocketProvider.error != null) {
          _showErrorDialog(webSocketProvider.error!);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error in WebSocket state change: $e');
    }
  }

  void _showMessageDialog(String message) {
    if (!mounted) return;
    MessagePopupScreen.show(
      context,
      message: message,
      isError: false,
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    MessagePopupScreen.show(
      context,
      message: message,
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock statistics
    final Map<String, dynamic> stats = {
      'points': '1,250',
      'rewards': '8',
      'visits': '24',
    };
    

    return Scaffold(
      body: Column(
        children: [
          // Connection status and message indicator
          Container(
            padding: const EdgeInsets.all(8.0),
            color: _isConnected ? Colors.green[100] : Colors.red[100],
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.circle : Icons.circle_outlined,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 8),
                
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with user info - data is now fetched internally
                  const ProfileHeader(),

                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard('profile.points'.tr(), stats['points'], Icons.star_rate_rounded),
                        const SizedBox(width: 12),
                        _buildStatCard('profile.rewards'.tr(), stats['rewards'], Icons.card_giftcard_rounded),
                        const SizedBox(width: 12),
                        _buildStatCard('profile.visits'.tr(), stats['visits'], Icons.store_rounded),
                      ],
                    ),
                  ),

                  // QR Code Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Text(
                          'loyalty_cards.qr_code'.tr(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: QrImageView(
                            data: 'user@example.com', // Replace with real user data
                            version: QrVersions.auto,
                            size: 182,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            gapless: true,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  // Loyalty Card - user data is fetched internally
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: LoyaltyCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}