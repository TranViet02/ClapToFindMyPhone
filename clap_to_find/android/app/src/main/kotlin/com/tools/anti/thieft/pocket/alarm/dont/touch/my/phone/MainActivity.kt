package com.tools.anti.thieft.pocket.alarm.dont.touch.my.phone
import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class MainActivity : FlutterActivity() {

    private val CLAP_TO_FIND_CHANNEL = "clap_to_find"
    private val VIBRATION_SERVICE_CHANNEL = "vibration_service"
    private val PERMISSION_REQUEST_CODE = 1
    private var isPermissionGranted = false
    private var currentVolume  = 15000
    private var currentFlashMode: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register EventBus to receive events from ClapDetectionService
        EventBus.getDefault().register(this)

        // Setup MethodChannel 'clap_to_find' to receive and handle method calls from Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CLAP_TO_FIND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    // Handle startService request
                    val action = call.argument<String>("action")
                    if (action == "start") {
                        // Start clap detection service
                        startClapDetection()
                    } else if (action == "stop") {
                        // Stop clap detection service
                        stopClapDetection()
                    }
                    result.success(null)
                }

                "checkPermission" -> {
                    // Check audio recording permission
                    checkAudioRecordingPermission(result)
                }

                "requestPermission" -> {
                    // Request audio recording permission
                    requestAudioRecordingPermission(result)
                }

                "checkServiceState" -> {
                    // Check clap detection service state
                    val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
                    val isServiceRunning = sharedPref.getBoolean("isServiceRunning", false)
                    result.success(isServiceRunning)
                }

                "saveSoundChoice" -> {
                    // Save sound choice
                    val soundChoice = call.argument<String>("soundChoice")
                    saveSoundChoice(soundChoice)
                    result.success(null)
                }

                "updateClapDetectionThreshold" -> {
                    val threshold = call.argument<Int>("threshold")
                    if (threshold != null) {
                        currentVolume = threshold
                        Log.d("volumduocguituflutter", "abc: $currentVolume")
                        sendThresholdToService(currentVolume)
                    }
                    result.success(null)
                }
                "updateFlashMode" -> {
                    val flashMode = call.argument<String>("flashMode")
                    if (flashMode != null) {
                        currentFlashMode = flashMode
                        updateFlashMode(currentFlashMode!!)
                        result.success(null)
                    }
                }
                "updateVibrationMode" -> {
                    val mode = call.argument<String>("mode")
                    if (mode != null) {
                        updateVibrationMode(mode)
                        result.success(null)
                    }
                }
                "playSoundOnly" -> {
                    startPlaySoundOnly()
                    result.success(null)
                }
                "stopSound" -> {
                    stopPlaySoundOnly()  // Add this line
                    result.success(null)
                }


                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIBRATION_SERVICE_CHANNEL).setMethodCallHandler{ call, result ->
            when(call.method){
                "startServiceVibration" -> {
                    // Xử lý yêu cầu bắt đầu dịch vụ rung
                    val action = call.argument<String>("action")
                    if (action == "start") {
                        startVibrationService()

                    } else if (action == "stop") {
                        // Dừng dịch vụ rung
                        stopVibrationService()
                    }
                    result.success(null)
                }

                "checkPermission" -> {
                    // Kiểm tra quyền rung
                    checkVibrationPermission(result)
                }

                "requestPermission" -> {
                    // Yêu cầu quyền rung
                    requestVibrationPermission(result)
                }

                "checkServiceState" -> {
                    // Kiểm tra trạng thái của dịch vụ rung
                    val sharedPref =
                        getSharedPreferences("VibrationServicePrefs", Context.MODE_PRIVATE)
                    val isServiceRunning = sharedPref.getBoolean("isServiceRunning", false)
                    result.success(isServiceRunning)
                }

                "saveSoundChoice" -> {
                    val soundChoice = call.argument<String>("soundChoice")
                    saveSoundChoice(soundChoice)
                    result.success(null)
                }
                "updateFlashMode" -> {
                    val flashMode = call.argument<String>("flashMode")
                    if (flashMode != null) {
                        currentFlashMode = flashMode
                        updateFlashMode(currentFlashMode!!)
                        result.success(null)
                    }
                }
                "updateVibrationMode" -> {
                    val mode = call.argument<String>("mode")
                    if (mode != null) {
                        updateVibrationMode(mode)
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun stopPlaySoundOnly() {
        val serviceIntent = Intent(this, ClapDetectionService::class.java)
        serviceIntent.action = "STOP_SOUND_ONLY"
        startService(serviceIntent)
    }

    private fun startPlaySoundOnly() {
        val serviceIntent = Intent(this, ClapDetectionService::class.java)
        serviceIntent.action = "PLAY_SOUND_ONLY"
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            startForegroundService(serviceIntent)
//        } else {
//            startService(serviceIntent)
//        }
    }

    private fun updateVibrationMode(mode: String) {
        Log.d("FlutterCommunication", "Đã nhận yêu cầu cập nhật chế độ rung từ Flutter: $mode")

        val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("vibrationMode", mode)
            apply()
        }

        // Gửi chế độ rung tới ClapDetectionService thông qua Intent
        val serviceIntent = Intent(this, ClapDetectionService::class.java)
        serviceIntent.action = "UPDATE_VIBRATION_MODE"
        serviceIntent.putExtra("vibrationMode", mode)
    }


    private fun updateFlashMode(flashMode: String) {
        println("Đã nhận được chế độ flash từ Flutter: $flashMode")
        // Đưa dữ liệu flashMode vào SharedPreferences để sử dụng trong service
        val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("flashMode", flashMode)
            apply()
        }
        // Gửi flashMode tới ClapDetectionService thông qua Intent
        val serviceIntent = Intent(this, ClapDetectionService::class.java)
        serviceIntent.action = "UPDATE_FLASH_MODE"
        serviceIntent.putExtra("flashMode", flashMode)
    }


    private fun sendThresholdToService(volume: Int) {
        val serviceIntent = Intent(this, ClapDetectionService::class.java)
        serviceIntent.action = "UPDATE_THRESHOLD"
        serviceIntent.putExtra("threshold", volume)
        startService(serviceIntent)
    }


    // Hàm bắt đầu dịch vụ rung
    private fun startVibrationService() {
        val serviceIntent = Intent(this, VibrationService::class.java)
        serviceIntent.action = "START"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        }

        // Lưu trạng thái của dịch vụ vào SharedPreferences
        val sharedPref = getSharedPreferences("VibrationServicePrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putBoolean("isServiceRunning", true)
            apply()
        }
    }

    // Hàm dừng dịch vụ rung
    private fun stopVibrationService() {
        val serviceIntent = Intent(this, VibrationService::class.java)
        serviceIntent.action = "STOP"
        stopService(serviceIntent)

        // Cập nhật trạng thái của dịch vụ trong SharedPreferences
        val sharedPref = getSharedPreferences("VibrationServicePrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putBoolean("isServiceRunning", false)
            apply()
        }
    }
    // Hàm kiểm tra quyền rung
    private fun checkVibrationPermission(result: MethodChannel.Result) {
        val isPermissionGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.VIBRATE
        ) == PackageManager.PERMISSION_GRANTED
        result.success(isPermissionGranted)
    }
    // Hàm yêu cầu quyền rung
    private fun requestVibrationPermission(result: MethodChannel.Result) {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.VIBRATE),
            PERMISSION_REQUEST_CODE
        )
        result.success(null)
    }


    // Start clap detection service
    private fun startClapDetection() {
        val serviceIntent = Intent(this, ClapDetectionService::class.java)
        serviceIntent.action = "START"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        }
        // Save service state in SharedPreferences
        val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putBoolean("isServiceRunning", true)
            apply()
        }
    }

    // Stop clap detection service
    private fun stopClapDetection() {
        val serviceIntent = Intent(this, ClapDetectionService::class.java)
        serviceIntent.action = "STOP"
        stopService(serviceIntent)

        // Update service state in SharedPreferences
        val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putBoolean("isServiceRunning", false)
            apply()
        }
    }

    // Check audio recording permission
    private fun checkAudioRecordingPermission(result: MethodChannel.Result) {
        val isPermissionGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        result.success(isPermissionGranted)
    }

    // Request audio recording permission
    private fun requestAudioRecordingPermission(result: MethodChannel.Result) {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.RECORD_AUDIO),
            PERMISSION_REQUEST_CODE
        )
        result.success(null)
    }

    // Save sound choice
    private fun saveSoundChoice(soundChoice: String?) {
        val sharedPref = getSharedPreferences("ClapDetectionPrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("soundChoice", soundChoice)
            apply()
        }
    }

    // Handle permission request results
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            isPermissionGranted =
                grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            // Send result back to Flutter via MethodChannel
            MethodChannel(
                flutterEngine!!.dartExecutor.binaryMessenger,
                CLAP_TO_FIND_CHANNEL
            ).invokeMethod("permissionResult", isPermissionGranted)
        }
    }

    // Unregister EventBus when Activity is destroyed
    override fun onDestroy() {
        super.onDestroy()
        EventBus.getDefault().unregister(this)
    }

    // Handle ClapDetectionEvent received through EventBus
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onEvent(event: ClapDetectionEvent) {
        // Send ClapDetectionEvent back to Flutter via MethodChannel
        MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            CLAP_TO_FIND_CHANNEL
        ).invokeMethod("clapDetected", event.message)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onEvent(event: VibrationServiceEvent) {
        flutterEngine?.let {
            MethodChannel(it.dartExecutor.binaryMessenger, VIBRATION_SERVICE_CHANNEL)
                .invokeMethod("vibrationDetected", event.message)
        }
    }

    // Check if a service is running
//    private fun isMyServiceRunning(serviceClass: Class<*>): Boolean {
//        val manager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
//        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
//            if (serviceClass.name == service.service.className) {
//                return true
//            }
//        }
//        return false
//    }

}


