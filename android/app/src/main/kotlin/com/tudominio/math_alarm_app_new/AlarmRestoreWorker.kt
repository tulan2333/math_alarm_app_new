package com.tudominio.math_alarm_app_new

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters

class AlarmRestoreWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        Log.d("AlarmRestoreWorker", "Iniciando restauración de alarmas")
        
        // Iniciar el servicio Flutter en segundo plano
        val intent = Intent(applicationContext, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.putExtra("RESTORE_ALARMS", true)
        applicationContext.startActivity(intent)
        
        return Result.success()
    }
}