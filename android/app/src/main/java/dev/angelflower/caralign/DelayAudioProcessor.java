package dev.angelflower.caralign;

import androidx.annotation.OptIn;
import androidx.media3.common.C;
import androidx.media3.common.audio.AudioProcessor.AudioFormat;
import androidx.media3.common.audio.BaseAudioProcessor;
import androidx.media3.common.util.UnstableApi;

import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * ExoPlayer audio processor that delays one channel of the stereo stream using {@link DelayLine}.
 * Mono input is duplicated to stereo; anything that is not 16-bit mono/stereo passes through untouched.
 */
@OptIn(markerClass = UnstableApi.class)
final class DelayAudioProcessor extends BaseAudioProcessor {
    private DelayLine line;
    private int sampleRate;
    private boolean monoInput;
    private long seenVersion = -1;

    @Override
    protected AudioFormat onConfigure(AudioFormat input) {
        if (input.encoding != C.ENCODING_PCM_16BIT || input.channelCount < 1 || input.channelCount > 2) {
            return AudioFormat.NOT_SET; // inactive: the sink plays the stream as it is
        }
        sampleRate = input.sampleRate;
        monoInput = input.channelCount == 1;
        return new AudioFormat(input.sampleRate, 2, C.ENCODING_PCM_16BIT);
    }

    @Override
    protected void onFlush() {
        PlayerDelay.Setting s = PlayerDelay.get();
        line = new DelayLine(samplesFor(s), s.left);
        seenVersion = s.version;
        Log.i("CarAlign", "player stream: " + sampleRate + " Hz, delay " + samplesFor(s) + " samples (" + (s.left ? "left" : "right") + ")");
    }

    @Override
    protected void onReset() {
        line = null;
    }

    private int samplesFor(PlayerDelay.Setting s) {
        return Math.round(s.ms * sampleRate / 1000f);
    }

    @Override
    public void queueInput(ByteBuffer input) {
        int bytes = input.remaining();
        if (bytes == 0) return;
        ByteBuffer in = input.order(ByteOrder.LITTLE_ENDIAN);
        int inShorts = bytes / 2;
        int outShorts = monoInput ? inShorts * 2 : inShorts;
        short[] buf = new short[outShorts];
        if (monoInput) {
            for (int i = 0; i < inShorts; i++) {
                short v = in.getShort();
                buf[2 * i] = v;
                buf[2 * i + 1] = v;
            }
        } else {
            in.asShortBuffer().get(buf, 0, inShorts);
            in.position(in.position() + bytes);
        }
        PlayerDelay.Setting s = PlayerDelay.get();
        if (s.version != seenVersion) {
            seenVersion = s.version;
            Log.i("CarAlign", "player delay -> " + samplesFor(s) + " samples (" + (s.left ? "left" : "right") + ")");
            if (s.rampSeconds > 0) line.ramp(s.left, samplesFor(s), s.rampSeconds, sampleRate);
            else line.set(s.left, samplesFor(s));
        }
        line.process(buf, buf.length);
        ByteBuffer out = replaceOutputBuffer(outShorts * 2).order(ByteOrder.LITTLE_ENDIAN);
        out.asShortBuffer().put(buf);
        out.position(out.position() + outShorts * 2);
        out.flip();
    }
}
