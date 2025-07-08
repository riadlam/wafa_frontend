import 'dart:async';
import 'dart:convert';
import 'dart:io' show WebSocketException;

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  final String _url;
  final Map<String, String>? _headers;
  final Duration _reconnectInterval;
  final Function(dynamic)? onMessage;
  final Function()? onConnected;
  final Function()? onDisconnected;
  final Function(dynamic)? onError;
  Timer? _reconnectTimer;

  WebSocketService({
    required String url,
    Map<String, String>? headers,
    this.onMessage,
    this.onConnected,
    this.onDisconnected,
    this.onError,
    Duration? reconnectInterval,
  })  : _url = url,
        _headers = headers,
        _reconnectInterval = reconnectInterval ?? const Duration(seconds: 5);

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      await _subscription?.cancel();
      await _channel?.sink.close();

      _channel = IOWebSocketChannel.connect(
        _url,
        headers: _headers,
        pingInterval: const Duration(seconds: 30),
      );

      _subscription = _channel?.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: true,
      );

      _isConnected = true;
      onConnected?.call();
    } catch (e) {
      _handleError(e);
      _scheduleReconnect();
    }
  }


  void send(dynamic message) {
    if (_isConnected && _channel != null) {
      try {
        if (message is String) {
          _channel!.sink.add(message);
        } else if (message is Map || message is List) {
          _channel!.sink.add(jsonEncode(message));
        } else {
          _channel!.sink.add(message.toString());
        }
      } catch (e) {
        _handleError(e);
      }
    } else {
      _handleError('Not connected to WebSocket server');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      // Try to decode JSON if the message is a String
      if (message is String) {
        try {
          final decoded = jsonDecode(message);
          onMessage?.call(decoded);
          return;
        } catch (e) {
          // If it's not JSON, pass the raw message
          onMessage?.call(message);
        }
      } else {
        onMessage?.call(message);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    if (error is WebSocketException) {
      debugPrint('WebSocket error: ${error.message}');
    } else {
      debugPrint('WebSocket error: $error');
    }
    onError?.call(error);
    _handleDisconnect();
  }

  void _handleDisconnect() {
    if (_isConnected) {
      _isConnected = false;
      onDisconnected?.call();
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectInterval, () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _reconnectTimer?.cancel();
  }
}
