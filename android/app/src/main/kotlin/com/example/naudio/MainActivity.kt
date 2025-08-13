package com.example.naudio

import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.audio/recorder"
    private var recorder: MediaRecorder? = null
    private var player: MediaPlayer? = null
    private var filePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startRecording" -> {
                        val format = call.argument<String>("format") ?: "3gp"
                        startRecording(format)
                        result.success(filePath)
                    }
                    "stopRecording" -> {
                        stopRecording()
                        result.success(filePath)
                    }
                    "playRecording" -> {
                        val path = call.argument<String>("path")
                        playRecording(path)
                        result.success(null)
                    }
                    "stopPlaying" -> {
                        stopPlaying()
                        result.success(null)
                    }
                    "deleteRecording" -> {
                        val path = call.argument<String>("path")
                        deleteRecording(path)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startRecording(format: String) {
        val outputDir = getExternalFilesDir(null)
        filePath = "${outputDir?.absolutePath}/recording_${System.currentTimeMillis()}.$format"

        recorder = MediaRecorder().apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFile(filePath)

            // Set output format and encoder based on the chosen format
            when (format) {
                "mp3" -> {
                    setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                    setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                }
                "aac" -> {
                    setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                    setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                }
                "wav" -> {
                    setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP) // WAV is not natively supported, using 3GP as workaround
                    setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
                }
                else -> {
                    setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP)
                    setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
                }
            }

            try {
                prepare()
                start()
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
    }

    private fun stopRecording() {
        recorder?.apply {
            stop()
            release()
        }
        recorder = null
    }

    private fun playRecording(path: String?) {
        path ?: return

        player = MediaPlayer().apply {
            try {
                setDataSource(path)
                prepare()
                start()
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
    }

    private fun stopPlaying() {
        player?.apply {
            stop()
            release()
        }
        player = null
    }

    private fun deleteRecording(path: String?) {
        path ?: return
        val file = File(path)
        if (file.exists()) {
            file.delete()
        }
    }
}
