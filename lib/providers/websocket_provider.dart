import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketProvider with ChangeNotifier {
  bool _isDisposed = false;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _lastMessage;
  String? _error;
  StreamSubscription? _subscription;
  bool _isInitializing = false;

  bool get isConnected => _isConnected;
  String? get lastMessage => _lastMessage;
  String? get error => _error;

  // Initialize WebSocket connection
  void initialize({String? authToken}) {
    if (_isDisposed || _isInitializing) return;
    
    _isInitializing = true;
    
    try {
      // Close any existing connection
      _cleanup();

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://ws-eu.pusher.com:443/app/7e8fce68170007f551f3?protocol=7&client=dart-client&version=1.0.0'),
      );

      // Listen to incoming messages
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnected,
        cancelOnError: true,
      );

      // Subscribe to the chat channel
      subscribeToChannel('chat');
      
      _isConnected = true;
      _isInitializing = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      _isInitializing = false;
      if (!_isDisposed) {
        _handleError(e);
      }
    }
  }
  
  // Subscribe to a specific channel
  void subscribeToChannel(String channelName) {
    if (_channel == null || _isDisposed) return;
    
    try {
      final subscribeMsg = {
        'event': 'pusher:subscribe',
        'data': {'channel': channelName}
      };
      
      _channel!.sink.add(jsonEncode(subscribeMsg));
    } catch (e) {
      if (!_isDisposed) {
        _handleError(e);
      }
    }
  }
  
  // Send a message to the WebSocket
  void sendMessage(dynamic message) {
    if (_channel == null || !_isConnected || _isDisposed) return;
    
    try {
      final messageData = {
        'event': 'message',
        'data': message,
      };
      
      _channel!.sink.add(jsonEncode(messageData));
    } catch (e) {
      if (!_isDisposed) {
        _handleError(e);
      }
    }
  }


  // Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data);
      
      // Handle Pusher events
      if (json['event'] == 'pusher:connection_established') {
        _isConnected = true;
        _error = null;
      } 
      // Handle custom events (like 'message')
      else if (json['event'] == 'message') {
        _lastMessage = json['data']?.toString();
        debugPrint('New message: $_lastMessage');
      }
      
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // Handle errors
  void _handleError(dynamic error) {
    if (_isDisposed) return;
    
    _error = error.toString();
    _isConnected = false;
    debugPrint('WebSocket error: $error');
    if (!_isDisposed) {
      notifyListeners();
    }
  }
  
  // Handle disconnection
  void _handleDisconnected() {
    if (_isDisposed) return;
    
    _isConnected = false;
    debugPrint('WebSocket disconnected');
    if (!_isDisposed) {
      notifyListeners();
    }
    
    // Attempt to reconnect after a delay if not disposed
    if (!_isDisposed) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected && !_isDisposed) {
          initialize();
        }
      });
    }
  }

  // Clean up resources without notifying listeners
  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }
  
  // Clean up resources
  @override
  void dispose() {
    _isDisposed = true;
    _cleanup();
    super.dispose();
  }
}
