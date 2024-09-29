package com.tools.anti.thieft.pocket.alarm.dont.touch.my.phone


import android.Manifest
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.*
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import org.greenrobot.eventbus.EventBus
import java.util.Timer
import java.util.TimerTask
import java.util.concurrent.atomic.AtomicBoolean

class ClapDetectionService : Service() {

    private val isRecording = AtomicBoolean(false)
    private val isPlayingSound = AtomicBoolean(false)
    private lateinit var audioRecord: AudioRecord
    private var recordingThread: Thread? = null
    private val handler = Handler(Looper.getMainLooper())
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null
    private var soundResId: Int = 0
    private val channelId = "ClapDetectionServiceChannel"
    private val notificationId = 1
    private var notificationPendingIntent: PendingIntent? = null
    private var currentVolume = 15000
    private val isFlashThreadRunning = AtomicBoolean(false)


    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Xử lý khi được gọi từ MainActivity
        when (intent?.action) {
            "START" -> {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
                    startClapDetection()
                } else {
                    // Xử lý khi không có quyền ghi âm
                }
            }
            "STOP" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    stopClapDetection()
                }
                stopSound()
                stopSelf()
            }
            "UPDATE_THRESHOLD" -> {
                val threshold = intent.getIntExtra("threshold", 15000)
                updateClapDetectionThreshold(threshold)
            }
            "PLAY_SOUND_ONLY" -> {
                handlePlaySoundOnly()
            } "STOP_SOUND_ONLY" -> {
                stopSound()
            }

        }
        return START_STICKY
    }

    private fun updateClapDetectionThreshold(threshold: Int) {
        val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putInt("threshold", threshold)
            apply()
        }
        currentVolume = threshold
    }

    private fun startClapDetection() {
        val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
        currentVolume = sharedPref.getInt("threshold", 15000)
        if (isRecording.get()) {
            return
        }
        // Xác định kích thước buffer cho AudioRecord
        val bufferSize = AudioRecord.getMinBufferSize(
            44100,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )

        if (bufferSize == AudioRecord.ERROR || bufferSize == AudioRecord.ERROR_BAD_VALUE) {
            return
        }

        // Kiểm tra quyền ghi âm
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        // Khởi tạo AudioRecord
        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            44100,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize
        )
        if (audioRecord.state != AudioRecord.STATE_INITIALIZED) {
            // Handle initialization error
            return
        }

        audioRecord.startRecording()
        isRecording.set(true)

        // Khởi tạo Vibrator
        vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator?

        // Khởi tạo CameraManager để điều khiển đèn flash
        cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager

        cameraId = cameraManager?.cameraIdList?.firstOrNull { id ->
            cameraManager?.getCameraCharacteristics(id)
                ?.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
        }

        // Tạo thread để ghi âm và phát hiện clap
        recordingThread = Thread {
            val buffer = ShortArray(bufferSize)
            while (isRecording.get()) {
                val read = audioRecord.read(buffer, 0, buffer.size)
                if (read > 0) {
                    // Tính toán giá trị cao nhất của âm lượng
                    val maxAmplitude = buffer.take(read).maxOrNull() ?: 0
                    // Phát hiện clap khi giá trị cao nhất vượt qua ngưỡng
                    if (maxAmplitude > currentVolume) {
                        Log.d("ClapDetectionService", "abc: $currentVolume")
                        handler.post {
                            if (!isPlayingSound.get()) {
                                playSound()
                            }
                            if ( vibrator?.hasVibrator() == true) {
                                startCustomVibratePatternCompat(vibrator)
                            }
                            if ( cameraId != null) {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                    toggleFlash(true)
                                }
                            }
                            ClapDetectionNotification("Đã phát hiện tiếng vỗ tay", "Đã tìm thấy điện thoại của bạn")
                            EventBus.getDefault().post(ClapDetectionEvent("Phát hiện tiếng vỗ tay"))
                        }
                    }
                }
            }
            try {
                audioRecord.stop()
            } catch (e: IllegalStateException) {
                // Handle stop error
            }

            finally {
                audioRecord.release()
            }
        }
        recordingThread?.start()
        startForegroundService()
    }

    private fun startForegroundService() {
        val channelName = "Clap Detection Service"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Clap and whistle Locate: My lost phone")
            .setContentText("Vỗ tay để tìm điện thoại của tôi đang chạy")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(createNotificationPendingIntent())
            .build()

        startForeground(notificationId, notification)
    }

    private fun ClapDetectionNotification(title: String, text: String) {

        val notificationManager = NotificationManagerCompat.from(this)
        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(createNotificationPendingIntent())
            .build()

        notificationManager.notify(notificationId, notificationBuilder)
    }

    private fun createNotificationPendingIntent(): PendingIntent {
        if (notificationPendingIntent == null) {
            val notificationIntent = Intent(this, MainActivity::class.java)
            notificationIntent.action = "OPEN_CLAP_SCREEN" // Action để phân biệt khi nào mở ClapDetectionScreen
            notificationIntent.putExtra("route", "/clapDetection") // Route của ClapDetectionScreen trong ứng dụng Flutter của bạn

            // Đảm bảo rằng chỉ có một instance của MainActivity được mở và trạng thái trước đó không bị xóa
            notificationIntent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            notificationPendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }
        return notificationPendingIntent!!
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

    @RequiresApi(Build.VERSION_CODES.M)
    private fun stopClapDetection() {
        isRecording.set(false)
        isFlashThreadRunning.set(false)
        recordingThread?.join()
        recordingThread = null
        vibrator?.cancel()
        toggleFlash(false) // Tắt đèn flash
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
            mediaPlayer?.isLooping = true // Đặt looping để phát lại liên tục
            mediaPlayer?.start()
            isPlayingSound.set(true)
        }
    }
    @RequiresApi(Build.VERSION_CODES.M)
    private fun handlePlaySoundOnly() {
        stopClapDetection()
        playSound()
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
        stopClapDetection()
        stopSound()
        vibrator?.cancel() // Dừng rung
    }
}
