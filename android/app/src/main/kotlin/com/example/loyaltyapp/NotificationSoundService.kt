package com.example.loyaltyapp

import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.example.loyaltyapp.R

class NotificationSoundService(private val context: Context) : MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var notificationManager: NotificationManager? = null

    companion object {
        private const val CHANNEL = "notification_sound"
        private const val METHOD_INIT = "initialize"
        private const val METHOD_PLAY = "playNotificationSound"
    }

    fun configureChannel(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler(this)
        notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            METHOD_INIT -> result.success(null)
            METHOD_PLAY -> {
                playNotificationSound()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun playNotificationSound() {
        try {
            Log.d("NotificationSound", "Attempting to play custom notification sound")
            
            // First try to play the custom sound
            try {
                val mediaPlayer = MediaPlayer.create(context, R.raw.notification_sound)?.apply {
                    setOnCompletionListener { mp ->
                        mp.release()
                        Log.d("NotificationSound", "Custom sound playback completed")
                    }
                    
                    setOnErrorListener { mp, what, extra ->
                        Log.e("NotificationSound", "Error playing custom sound: $what, $extra")
                        mp.release()
                        false
                    }
                    
                    // Set audio attributes for better control over playback
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        val audioAttributes = AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                        setAudioAttributes(audioAttributes)
                    } else {
                        @Suppress("DEPRECATION")
                        setAudioStreamType(android.media.AudioManager.STREAM_NOTIFICATION)
                    }
                    
                    start()
                    Log.d("NotificationSound", "Custom sound playback started")
                    return
                }
                
                if (mediaPlayer == null) {
                    throw Exception("Failed to create MediaPlayer - resource might not exist")
                }
            } catch (e: Exception) {
                Log.e("NotificationSound", "Error with custom sound: ${e.message}")
                playDefaultNotification()
            }
        } catch (e: Exception) {
            Log.e("NotificationSound", "Unexpected error: ${e.message}")
            playDefaultNotification()
        }
    }
    
    private fun playDefaultNotification() {
        try {
            val notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val ringtone = RingtoneManager.getRingtone(context, notification)
            ringtone.play()
            Log.d("NotificationSound", "Playing default notification sound")
            
            // Stop after 2 seconds
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    ringtone.stop()
                } catch (e: Exception) {
                    Log.e("NotificationSound", "Error stopping default sound: ${e.message}")
                }
            }, 2000)
        } catch (e: Exception) {
            Log.e("NotificationSound", "Error playing default sound: ${e.message}")
        }
    }
}
