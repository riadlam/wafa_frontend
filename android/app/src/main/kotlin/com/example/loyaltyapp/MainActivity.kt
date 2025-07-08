package com.example.loyaltyapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private lateinit var notificationSoundService: NotificationSoundService

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register plugins with the new Android embedding
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Initialize notification sound service with application context
        notificationSoundService = NotificationSoundService(applicationContext)
        notificationSoundService.configureChannel(flutterEngine)
    }
}
