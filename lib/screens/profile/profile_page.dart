import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:loyaltyapp/screens/profile/message_popup_screen.dart';
import '../../constants/app_colors.dart';
import '../../providers/websocket_provider.dart';
import '../../services/auth_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/loyalty_card.dart';
import 'widgets/profile_drawer.dart';
import 'qr_code_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isInitializing = false;
  bool _isDisposed = false;
  bool _isConnected = false;
  String? _lastMessage;

  WebSocketProvider? _webSocketProvider;
  
  @override
  void initState() {
    super.initState();
    // Store the provider reference in initState when the context is still valid
    _webSocketProvider = context.read<WebSocketProvider>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeWebSocket();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupWebSocketListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Use the stored provider reference instead of accessing context
    _webSocketProvider?.removeListener(_onWebSocketStateChanged);
    _webSocketProvider = null;
    super.dispose();
  }

  void _setupWebSocketListeners() {
    final webSocketProvider = context.read<WebSocketProvider>();
    
    // Listen to state changes
    webSocketProvider.addListener(_onWebSocketStateChanged);
  }
  
  void _onWebSocketStateChanged() {
    if (!mounted || _isDisposed) return;
    
    final webSocketProvider = context.read<WebSocketProvider>();
    final isConnected = webSocketProvider.isConnected;
    final lastMessage = webSocketProvider.lastMessage;
    
    if (isConnected != _isConnected || lastMessage != _lastMessage) {
      setState(() {
        _isConnected = isConnected;
        _lastMessage = lastMessage;
      });
      
      // Show message dialog when a new message is received
      if (lastMessage != null && lastMessage.isNotEmpty) {
        _showMessageDialog('New message: $lastMessage');
      }
    }
  }

  Future<void> _initializeWebSocket() async {
    if (_isInitializing || _isDisposed || !mounted || _webSocketProvider == null) return;
    _isInitializing = true;
    
    try {
      final authService = context.read<AuthService>();
      
      if (_isDisposed || !mounted) return;
      
      // Get authentication token
      final token = await authService.getJwtToken();
      if (token == null) {
        if (mounted) {
          _showMessageDialog('profile.authentication_error'.tr());
        }
        return;
      }
      
      if (!mounted) return;
      
      // Only initialize if not already connected
      if (!_webSocketProvider!.isConnected) {
        if (kDebugMode) print('Initializing WebSocket connection...');
        
        // Initialize WebSocket connection with Pusher
        _webSocketProvider!.initialize(authToken: token);
        
        if (kDebugMode && mounted) {
          print('WebSocket initialization completed');
        }
      } else if (kDebugMode && mounted) {
        print('WebSocket already connected');
      }
    } catch (e, stackTrace) {
      if (mounted && !_isDisposed) {
        if (kDebugMode) print('WebSocket initialization error: $e\n$stackTrace');
        _showMessageDialog('Failed to connect to WebSocket: $e');
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitializing = false;
        });
      } else {
        _isInitializing = false;
      }
    }
  }

  void _showMessageDialog(String message) {
    if (!mounted) return;
    
    // Check if the message is an error (contains error-related keywords)
    final isError = message.toLowerCase().contains('error') || 
                   message.toLowerCase().contains('fail') ||
                   message.toLowerCase().contains('invalid');
    
    // Show the new animated popup
    MessagePopupScreen.show(
      context,
      message: message,
      isError: isError,
      autoDismiss: false, // Don't auto-dismiss
      displayDuration: const Duration(seconds: 0), // No auto-dismiss
      onClose: () {
        // Additional cleanup if needed when popup is closed
        if (kDebugMode) print('Message popup closed');
      },
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
    
    final connectionStatus = _isConnected ? 'profile.connection.connected'.tr() : 'profile.connection.disconnected'.tr();
    final statusColor = _isConnected ? Colors.green : Colors.red;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'profile.title'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 8), // Add some padding
        ],
      ),
      endDrawer: const ProfileDrawer(),
      body: Column(
        children: [
          // Connection status indicator
        
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with user info - data is now fetched internally
                  const ProfileHeader(),                 
                  // QR Code Section
                 

                  // Loyalty Card - user data is fetched internally
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: LoyaltyCard(),
                  ),
                  const SizedBox(height: 20),
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
