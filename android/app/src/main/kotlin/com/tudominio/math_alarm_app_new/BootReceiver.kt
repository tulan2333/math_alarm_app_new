package com.tudominio.math_alarm_app_new

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Data

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Dispositivo reiniciado, restaurando alarmas")
            
            // Usar WorkManager para restaurar alarmas en segundo plano
            val workRequest = OneTimeWorkRequestBuilder<AlarmRestoreWorker>()
                .build()
                
            WorkManager.getInstance(context).enqueue(workRequest)
        }
    }
}