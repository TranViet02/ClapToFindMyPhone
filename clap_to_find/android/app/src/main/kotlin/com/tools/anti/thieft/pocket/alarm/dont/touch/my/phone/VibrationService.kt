package com.tools.anti.thieft.pocket.alarm.dont.touch.my.phone

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.media.MediaPlayer
import android.os.*
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import org.greenrobot.eventbus.EventBus
import java.util.Timer
import java.util.TimerTask
import java.util.concurrent.atomic.AtomicBoolean

class VibrationService : Service() {

    private val isPlayingSound = AtomicBoolean(false)
    private val isShakeDetected = AtomicBoolean(false)
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null
    private var soundResId: Int = 0
    private val isFlashThreadRunning = AtomicBoolean(false)
    private lateinit var sensorManager: SensorManager
    private lateinit var accelerometer: Sensor

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }


    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    startShakeDetection()
                }
            }
            "STOP" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    stopShakeDetection()
                }
                stopSound()
                stopSelf()
            }
        }


        return START_STICKY
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun startShakeDetection() {
        if (isShakeDetected.get()) {
            return
        }

        vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager

        cameraId = cameraManager?.cameraIdList?.firstOrNull { id ->
            cameraManager?.getCameraCharacteristics(id)
                ?.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
        }

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)!!

        sensorManager.registerListener(
            shakeListener,
            accelerometer,
            SensorManager.SENSOR_DELAY_NORMAL
        )
        startForegroundService()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun stopShakeDetection() {
        isShakeDetected.set(false)
        sensorManager.unregisterListener(shakeListener)
        vibrator?.cancel()
        toggleFlash(false)
    }

    private val shakeListener = object : SensorEventListener {
        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {

        }

        @RequiresApi(Build.VERSION_CODES.M)
        override fun onSensorChanged(event: SensorEvent?) {
            if (event == null) return

            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]

            val acceleration = Math.sqrt((x * x + y * y + z * z).toDouble()).toFloat()

            if (acceleration > 10) {
                handleShakeEvent()
            }
        }
    }

    private fun startForegroundService() {
        val channelId = "VibrationDetectionServiceChannel"
        val channelName = "Vibration Detection Service"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        // Intent để mở ShakeScreen khi click vào notification
        val notificationIntent = Intent(this, MainActivity::class.java)

        notificationIntent.action = "OPEN_SHAKE_SCREEN"
        notificationIntent.putExtra("route", "/vibration")

        notificationIntent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Clap and whistle Locate: My lost phone")
            .setContentText("Rung lắc điện thoại của tôi đang chạy")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(2, notification)
    }


    @RequiresApi(Build.VERSION_CODES.M)
    private fun handleShakeEvent() {
        if (!isPlayingSound.get()) {
            playSound()
        }
        if (vibrator?.hasVibrator() == true) {
            startCustomVibratePatternCompat(vibrator)
        }
        if (cameraId != null) {
            toggleFlash(true)
        }
        EventBus.getDefault().post(VibrationServiceEvent("Shake detected"))
    }


    @RequiresApi(Build.VERSION_CODES.M)
    private fun toggleFlash(enable: Boolean) {
        try {
            val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
            val flashMode = sharedPref.getString("flashMode", "default") ?: "default"

            when (flashMode) {
                "default" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        cameraManager?.setTorchMode(cameraId!!, enable)
                        Log.d("ClapDetectionService", "Toggle flash mode to1: $enable")
                    }
                }
                "discomode" -> {
                    val pattern = longArrayOf( 100, 800, 100, 800) // Example disco pattern
                    toggleFlashDiscoMode(pattern, enable)
                    Log.d("ClapDetectionService", "Toggle flash mode to2: $enable")
                }
            }

        } catch (e: CameraAccessException) {
            e.printStackTrace()
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun toggleFlashDiscoMode(pattern: LongArray, enable: Boolean) {
        if (enable) {
            val flashThread = Thread {
                isFlashThreadRunning.set(true)
                try {
                    while (isFlashThreadRunning.get()) {
                        for (i in pattern.indices) {
                            if (!isFlashThreadRunning.get()) break // Check to exit thread if needed
                            cameraManager?.setTorchMode(cameraId!!, true)
                            Thread.sleep(pattern[i])
                            cameraManager?.setTorchMode(cameraId!!, false)
                        }
                    }
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                } catch (e: CameraAccessException) {
                    e.printStackTrace()
                } finally {
                    isFlashThreadRunning.set(false)
                    try {
                        // Ensure flash is turned off when thread ends
                        cameraManager?.setTorchMode(cameraId!!, false)
                    } catch (e: CameraAccessException) {
                        e.printStackTrace()
                    }
                }
            }
            flashThread.start()
        } else {
            // Disable disco mode
            isFlashThreadRunning.set(false)
            try {
                cameraManager?.setTorchMode(cameraId!!, false)
            } catch (e: CameraAccessException) {
                e.printStackTrace()
            }
        }
    }



    private fun startCustomVibratePatternCompat(vibrator: Vibrator?) {
        val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
        val vibrationMode = sharedPref.getString("vibrationMode", "Default") ?: "Default"
        Log.d("VibrationMode", "Current vibration mode: $vibrationMode")

        // Different vibration patterns based on selected vibration mode
        val pattern = when (vibrationMode) {
            "Default" -> longArrayOf(0, 400, 200, 400, 200)
            "Strong Vibration" -> longArrayOf(0, 1000, 100, 1000, 100)
            "Heartbeat" -> longArrayOf(0, 500, 100, 500, 100, 500, 100)
            else -> longArrayOf(0, 800, 50, 800, 50)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 1))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 1)
        }
    }

    private fun playSound() {
        if (mediaPlayer == null) {
            val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
            val soundChoice = sharedPref.getString("soundChoice", "default")

            soundResId = when (soundChoice) {
                "sound1" -> R.raw.cat
                "sound2" -> R.raw.car
                "sound3" -> R.raw.cavalry
                "sound4" -> R.raw.party_horn
                "sound5" -> R.raw.police_whistle
                else -> R.raw.cat
            }

            mediaPlayer = MediaPlayer.create(this, soundResId)
            mediaPlayer?.isLooping = true
            mediaPlayer?.start()
            isPlayingSound.set(true)
        }
    }

    private fun stopSound() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        isPlayingSound.set(false)
    }


    @RequiresApi(Build.VERSION_CODES.M)
    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(shakeListener)
        vibrator?.cancel()
        toggleFlash(false)
        stopSound()
    }
}

