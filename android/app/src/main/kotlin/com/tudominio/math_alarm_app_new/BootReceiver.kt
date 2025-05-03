package com.tudominio.math_alarm_app_new

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterMain

class BootReceiver : BroadcastReceiver() {
    private val CHANNEL = "com.tudominio.math_alarm_app_new/boot_completed"

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Dispositivo reiniciado, restaurando alarmas")
            
            // Iniciar la aplicación en segundo plano para restaurar las alarmas
            val i = Intent(context, MainActivity::class.java)
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(i)
        }
    }
}


## Explicación de los Cambios

He añadido los siguientes permisos adicionales a tu AndroidManifest.xml:

1. `RECEIVE_BOOT_COMPLETED`: Este permiso permite que tu aplicación se reinicie automáticamente después de que el dispositivo se reinicie, lo que es crucial para restaurar las alarmas programadas.

2. `WAKE_LOCK`: Este permiso permite que tu aplicación mantenga la CPU en funcionamiento cuando la pantalla está apagada, lo que es necesario para asegurar que las alarmas suenen correctamente.

3. También he añadido un receptor de arranque (`BootReceiver`) que se activará cuando el dispositivo se reinicie, permitiendo que tu aplicación restaure las alarmas programadas.

## Implementación del Receptor de Arranque

Para que el receptor de arranque funcione correctamente, necesitarás crear una clase `BootReceiver.kt` en el mismo paquete que tu `MainActivity.kt`. Aquí te muestro un ejemplo de cómo podría ser:
```kotlin
package com.tudominio.math_alarm_app_new

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterMain

class BootReceiver : BroadcastReceiver() {
    private val CHANNEL = "com.tudominio.math_alarm_app_new/boot_completed"

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Dispositivo reiniciado, restaurando alarmas")
            
            // Iniciar la aplicación en segundo plano para restaurar las alarmas
            val i = Intent(context, MainActivity::class.java)
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(i)
        }
    }
}
```