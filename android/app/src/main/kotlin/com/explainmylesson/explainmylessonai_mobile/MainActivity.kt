package com.explainmylesson.explainmylessonai_mobile

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.ln
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.explainmylesson/sound"
        private const val SAMPLE_RATE = 44100
    }

    private val executor = Executors.newFixedThreadPool(4)
    private val pcmCache = HashMap<String, ShortArray>()

    @Volatile
    private var lastClickMs = 0L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Pre-warm suara klik agar instan saat pertama kali ditekan
        executor.execute {
            getOrBuildPcm("playClick")
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playClick",
                    "playCorrect",
                    "playWrong",
                    "playCoin",
                    "playBadgeFanfare" -> {
                        if (call.method == "playClick") {
                            val now = System.currentTimeMillis()
                            if (now - lastClickMs < 40L) {
                                result.success(null)
                                return@setMethodCallHandler
                            }
                            lastClickMs = now
                        }
                        playSoundAsync(call.method)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        executor.shutdownNow()
        super.onDestroy()
    }

    private fun playSoundAsync(name: String) {
        executor.execute {
            try {
                val samples = getOrBuildPcm(name)
                val bufferBytes = samples.size * 2
                val track = AudioTrack(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_GAME)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                    AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(SAMPLE_RATE)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build(),
                    bufferBytes,
                    AudioTrack.MODE_STATIC,
                    AudioManager.AUDIO_SESSION_ID_GENERATE
                )

                track.write(samples, 0, samples.size)
                track.play()

                val durationMs = (samples.size * 1000L) / SAMPLE_RATE
                Thread.sleep(durationMs + 60L)
                track.stop()
                track.release()
            } catch (_: Exception) {
                // Abaikan jika gagal memutar audio
            }
        }
    }

    private fun getOrBuildPcm(name: String): ShortArray {
        synchronized(pcmCache) {
            pcmCache[name]?.let { return it }
        }
        val generated = when (name) {
            "playClick" -> buildClickPcm()
            "playCorrect" -> buildCorrectPcm()
            "playWrong" -> buildWrongPcm()
            "playCoin" -> buildCoinPcm()
            "playBadgeFanfare" -> buildBadgeFanfarePcm()
            else -> ShortArray(0)
        }
        synchronized(pcmCache) {
            pcmCache[name] = generated
        }
        return generated
    }

    private enum class Wave { SINE, TRIANGLE, SQUARE, SAWTOOTH }

    private fun waveSample(wave: Wave, phase: Double): Double {
        val p = phase - kotlin.math.floor(phase)
        return when (wave) {
            Wave.SINE -> sin(2.0 * PI * p)
            Wave.TRIANGLE -> 1.0 - 4.0 * kotlin.math.abs(p - 0.5)
            Wave.SQUARE -> if (p < 0.5) 1.0 else -1.0
            Wave.SAWTOOTH -> 2.0 * p - 1.0
        }
    }

    private fun addTone(
        mix: DoubleArray,
        wave: Wave,
        startSec: Double,
        durationSec: Double,
        fStart: Double,
        fEnd: Double,
        peakGain: Double,
        attackSec: Double = 0.015
    ) {
        val startIdx = max(0, (startSec * SAMPLE_RATE).toInt())
        val endIdx = min(mix.size, ((startSec + durationSec) * SAMPLE_RATE).toInt())
        if (endIdx <= startIdx) return

        var phase = 0.0
        val ratio = if (fStart > 0.0 && fEnd > 0.0) fEnd / fStart else 1.0
        val decayRate = ln(0.001 / max(0.002, peakGain)) / max(0.01, durationSec - attackSec)

        for (i in startIdx until endIdx) {
            val t = (i - startIdx).toDouble() / SAMPLE_RATE
            val progress = t / durationSec
            val freq = if (fStart == fEnd) {
                fStart
            } else {
                fStart * ratio.pow(min(1.0, progress))
            }
            phase += freq / SAMPLE_RATE

            val env = if (t < attackSec) {
                0.01 + (peakGain - 0.01) * (t / max(0.001, attackSec))
            } else {
                peakGain * exp(decayRate * (t - attackSec))
            }

            mix[i] += waveSample(wave, phase) * env
        }
    }

    private fun toPcm16(mix: DoubleArray): ShortArray {
        val out = ShortArray(mix.size)
        for (i in mix.indices) {
            val clamped = max(-0.98, min(0.98, mix[i]))
            out[i] = (clamped * Short.MAX_VALUE).toInt().toShort()
        }
        return out
    }

    private fun buildClickPcm(): ShortArray {
        val mix = DoubleArray((0.14 * SAMPLE_RATE).toInt())
        addTone(mix, Wave.SINE, 0.0, 0.13, 520.0, 1350.0, 0.45, attackSec = 0.015)
        addTone(mix, Wave.TRIANGLE, 0.0, 0.05, 1600.0, 700.0, 0.30, attackSec = 0.003)
        return toPcm16(mix)
    }

    private fun buildCorrectPcm(): ShortArray {
        val mix = DoubleArray((0.95 * SAMPLE_RATE).toInt())
        val fanfareNotes = doubleArrayOf(523.25, 659.25, 783.99, 1046.5, 1318.51, 1567.98)
        fanfareNotes.forEachIndexed { idx, freq ->
            addTone(mix, Wave.TRIANGLE, idx * 0.065, 0.24, freq, freq, 0.30, attackSec = 0.02)
        }
        doubleArrayOf(0.25, 0.38, 0.52).forEach { t ->
            addTone(mix, Wave.SINE, t, 0.36, 2093.0, 2093.0, 0.18, attackSec = 0.005)
        }
        doubleArrayOf(523.25, 659.25, 783.99, 1046.5).forEach { f ->
            addTone(mix, Wave.SINE, 0.42, 0.50, f, f, 0.14, attackSec = 0.03)
        }
        return toPcm16(mix)
    }

    private fun buildWrongPcm(): ShortArray {
        val mix = DoubleArray((0.78 * SAMPLE_RATE).toInt())
        doubleArrayOf(0.0, 0.12).forEach { delay ->
            addTone(mix, Wave.SAWTOOTH, delay, 0.10, 155.0, 155.0, 0.32, attackSec = 0.015)
            addTone(mix, Wave.SQUARE, delay, 0.10, 116.0, 116.0, 0.22, attackSec = 0.015)
        }
        addTone(mix, Wave.TRIANGLE, 0.22, 0.32, 320.0, 120.0, 0.38, attackSec = 0.02)
        addTone(mix, Wave.SINE, 0.45, 0.30, 110.0, 65.0, 0.35, attackSec = 0.01)
        return toPcm16(mix)
    }

    private fun buildCoinPcm(): ShortArray {
        val mix = DoubleArray((0.58 * SAMPLE_RATE).toInt())
        val coinPitches = doubleArrayOf(987.77, 1318.51, 1760.0, 2093.0)
        coinPitches.forEachIndexed { idx, freq ->
            addTone(mix, Wave.SINE, idx * 0.075, 0.28, freq, freq, 0.26, attackSec = 0.015)
        }
        return toPcm16(mix)
    }

    private fun buildBadgeFanfarePcm(): ShortArray {
        val mix = DoubleArray((0.96 * SAMPLE_RATE).toInt())
        val melody = doubleArrayOf(392.0, 523.25, 659.25, 783.99, 1046.5)
        melody.forEachIndexed { idx, freq ->
            addTone(mix, Wave.TRIANGLE, idx * 0.08, 0.36, freq, freq, 0.32, attackSec = 0.02)
        }
        val sparkles = doubleArrayOf(1567.98, 2093.0, 2637.02)
        sparkles.forEachIndexed { idx, freq ->
            addTone(mix, Wave.SINE, 0.38 + idx * 0.07, 0.40, freq, freq, 0.20, attackSec = 0.02)
        }
        return toPcm16(mix)
    }
}

