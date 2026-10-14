import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'settings_service.dart';

/// Distinct in-game sound effect cues. Add new cases here and register
/// their asset path below when a new triggerable sound is needed.
///
/// [placement] doubles as the general button-tap sound (line drawn on
/// the board, or any button pressed anywhere in the app).
enum SfxEvent { placement, boxComplete }

/// Thin wrapper around [AudioPlayer] for background music and one-shot
/// sound effects. This class does not own the on/off state — callers
/// pass `enabled` (backed by [SettingsService]) so playback and user
/// preference never drift out of sync.
///
/// Asset files:
///   assets/audio/music/background.mp3   (looping background music)
///   assets/audio/sfx/yerlestirme.wav    (line drawn / any button tap)
///   assets/audio/sfx/dolma.mp3          (played when a box is captured)
class AudioService {
  AudioService()
    : _musicPlayer = AudioPlayer(playerId: 'music'),
      _sfxPlayer = AudioPlayer(playerId: 'sfx') {
    // Without this, the music player and sfx player fight over the same
    // platform audio session: on iOS a non-mixing session interrupts the
    // other player's session when activated, and on Android both players
    // default to AudioFocus.gain, so playing a sfx steals focus and stops
    // the music. Both effects show up as "music cuts out on every tap".
    AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );
    // ReleaseMode.release (not .loop): looping is driven manually below via
    // _onMusicPosition, which restarts the track slightly before it ends —
    // the platform's own loop waits for a "completed" event first, which is
    // what caused the multi-second gap of silence between plays.
    _musicPlayer.setReleaseMode(ReleaseMode.release);
    _musicPlayer.setVolume(0.5);
    // Kicked off immediately (constructor runs before Settings even loads)
    // so the asset is decoded and buffered well before the splash screen
    // finishes and playback is actually requested — otherwise the first
    // `resume()` call is the one paying for that decode time, which is
    // what made the music noticeably late to start.
    _preloadMusic();
    _durationSub = _musicPlayer.onDurationChanged.listen((d) => _musicDuration = d);
    _positionSub = _musicPlayer.onPositionChanged.listen(_onMusicPosition);
    // Safety net: if the near-the-end window above is somehow missed (a
    // slow device skipping a position tick), don't let the track just go
    // silent forever — restart it once the platform reports it finished.
    _completeSub = _musicPlayer.onPlayerComplete.listen((_) => _restartMusic());
  }

  final AudioPlayer _musicPlayer;
  final AudioPlayer _sfxPlayer;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completeSub;
  Duration? _musicDuration;
  bool _restartingLoop = false;

  static const _musicAsset = 'audio/music/background.mp3';
  static const _sfxAssets = {
    SfxEvent.placement: 'audio/sfx/yerlestirme.wav',
    SfxEvent.boxComplete: 'audio/sfx/dolma.mp3',
  };

  bool _musicPlaying = false;

  Future<void> _preloadMusic() async {
    try {
      await _musicPlayer.setSourceAsset(_musicAsset);
      _musicDuration ??= await _musicPlayer.getDuration();
    } catch (e) {
      debugPrint('AudioService: failed to preload background music: $e');
    }
  }

  void _onMusicPosition(Duration position) {
    final duration = _musicDuration;
    if (!_musicPlaying || duration == null || _restartingLoop) return;
    if (duration - position > const Duration(milliseconds: 300)) return;
    _restartMusic();
  }

  void _restartMusic() {
    if (!_musicPlaying || _restartingLoop) return;
    _restartingLoop = true;
    _musicPlayer
        .seek(Duration.zero)
        .then((_) => _musicPlayer.resume())
        .catchError(
          (e) => debugPrint('AudioService: failed to loop background music: $e'),
        )
        .whenComplete(() => _restartingLoop = false);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    if (enabled == _musicPlaying) return;
    try {
      if (enabled) {
        if (_musicDuration == null) await _preloadMusic();
        await _musicPlayer.resume();
      } else {
        await _musicPlayer.pause();
      }
      _musicPlaying = enabled;
    } catch (e) {
      // Missing/invalid asset or platform audio failure — keep the app
      // usable regardless, but leave a trail for diagnosing why music
      // silently isn't playing on a given device.
      debugPrint('AudioService: setMusicEnabled($enabled) failed: $e');
    }
  }

  Future<void> playSfx(SfxEvent event, {required bool enabled}) async {
    if (!enabled) return;
    final asset = _sfxAssets[event];
    if (asset == null) return;
    try {
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('AudioService: playSfx($event) failed: $e');
    }
  }

  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completeSub?.cancel();
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

/// Convenience for the general button-tap sound, gated by the user's
/// sound-effects preference. Call at the top of a button's onPressed.
void playButtonSfx(BuildContext context) {
  context.read<AudioService>().playSfx(
    SfxEvent.placement,
    enabled: context.read<SettingsService>().soundEnabled,
  );
}
