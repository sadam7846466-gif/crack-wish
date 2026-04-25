import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'storage_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal() {
    _loadSoundPreference();
  }

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer(); // İleride arka plan müziği gerekirse

  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  // Ses ayarını kalıcı olarak yükle
  Future<void> _loadSoundPreference() async {
    _isSoundEnabled = await StorageService.getSoundEnabled() ?? true;
    
    // iOS'ta telefon sessizdeyken (yandaki tuş) bile oyun seslerinin gelmesi için:
    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);
  }

  // Ses ayarlarını aç/kapat (kalıcı olarak kaydeder)
  Future<void> toggleSound(bool enabled) async {
    _isSoundEnabled = enabled;
    await StorageService.setSoundEnabled(enabled);
  }

  // ── KURABİYE KIRMA (COOKIE) ──

  /// Kurabiyeye her tıklandığında (ASMR çıtırtı + Tok Titreşim)
  Future<void> playCookieTap() async {
    // Tok ve kısa titreşim
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    } else {
      Vibration.vibrate(duration: 50); // Fallback
    }

    if (_isSoundEnabled) {
      // Sadece titreşim, ses yok (Sessiz Lüks)
    }
  }

  /// Kurabiye tamamen kırıldığında (Güçlü Titreşim + Kırılma Sesi)
  Future<void> playCookieBreak() async {
    // Güçlü ve uzun titreşim (Başarı hissi)
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(duration: 200, amplitude: 255);
    } else {
      Vibration.vibrate(duration: 200);
    }

    if (_isSoundEnabled) {
      await _player.play(AssetSource('sounds/fortune_cookie_snap.mp3'), volume: 0.8);
    }
  }

  // ── BAYKUŞ MEKTUPLARI (OWL LETTERS) ──

  /// Mektup Gönderildiğinde veya Geldiğinde (Çifte Titreşim + Zil)
  Future<void> playOwlLetter() async {
    // Kalp atışı gibi çifte titreşim
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(pattern: [0, 50, 100, 50], intensities: [0, 128, 0, 255]);
    } else {
      Vibration.vibrate(duration: 100);
    }

    if (_isSoundEnabled) {
      await _player.play(AssetSource('sounds/baykuszili.mp3'), volume: 0.8);
    }
  }

  // ── TAROT KART ÇEVİRME ──

  /// Tarot kartı çevrildiğinde
  Future<void> playCardFlip() async {
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(duration: 30, amplitude: 100);
    } else {
      Vibration.vibrate(duration: 30);
    }

    if (_isSoundEnabled) {
      await _player.play(AssetSource('sounds/kartsesi1.wav'), volume: 0.6);
    }
  }

  // ── ÖDÜL VE AURA TOPLAMA (REWARDS) ──

  /// Aura / Günlük ödül / Rozet toplandığında
  Future<void> playRewardClaim() async {
    // Başarı titreşimi
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(pattern: [0, 80, 50, 120], intensities: [0, 180, 0, 255]);
    } else {
      Vibration.vibrate(duration: 150);
    }

    if (_isSoundEnabled) {
      await _player.play(AssetSource('sounds/level_up_bonus.mp3'), volume: 1.0);
    }
  }

  /// Alttan çıkan CosmicToast (Başarımlar vb.) süzüldüğünde
  Future<void> playCosmicToast() async {
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(duration: 40, amplitude: 80); // Hafif ve nazik bir titreşim
    } else {
      Vibration.vibrate(duration: 40);
    }

    if (_isSoundEnabled) {
      await _player.play(AssetSource('sounds/auraodulleri.mp3'), volume: 0.8);
    }
  }

  /// Ekranın ortasında açılan büyük ödül panelleri (CosmicRewardDialog) için
  Future<void> playPanelReward() async {
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(pattern: [0, 50, 100, 50], intensities: [0, 128, 0, 255]);
    } else {
      Vibration.vibrate(duration: 100);
    }

    if (_isSoundEnabled) {
      await _player.play(AssetSource('sounds/panelhediyelr.mp3'), volume: 0.9);
    }
  }

  // ── STANDART UI TIKLAMALARI (SADECE TİTREŞİM) ──

  /// Standart buton geçişleri (Ses yok, sadece lüks dokunma hissi)
  Future<void> playLightTick() async {
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(duration: 20, amplitude: 64); // Çok hafif
    } else {
      // Android default tick
      Vibration.vibrate(duration: 20);
    }
  }
}
