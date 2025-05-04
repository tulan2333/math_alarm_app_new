package com.tudominio.math_alarm_app_new

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tudominio.math_alarm_app_new/alarm_restore"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // Implementar métodos del canal aquí
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Verificar si se debe restaurar las alarmas
        if (intent?.getBooleanExtra("RESTORE_ALARMS", false) == true) {
            // Notificar a Flutter que debe restaurar las alarmas
            intent.removeExtra("RESTORE_ALARMS")
            
            // Esperar a que Flutter esté listo
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("restoreAlarms", null)
            }
        }
    }
}
