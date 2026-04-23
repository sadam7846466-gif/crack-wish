import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer(); // İleride arka plan müziği gerekirse

  bool _isSoundEnabled = true;

  // Ses ayarlarını aç/kapat
  void toggleSound(bool enabled) {
    _isSoundEnabled = enabled;
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
      // Sadece ufak tıklama/ısırık sesi
      await _player.play(AssetSource('sounds/cookie_bite.mp3'), volume: 0.5);
    }
  }

  /// Kurabiye tamamen kırıldığında (Senin indirdiğin KIRIK sesi + Güçlü Titreşim)
  Future<void> playCookieBreak() async {
    // Güçlü ve uzun titreşim (Başarı hissi)
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(duration: 200, amplitude: 255);
    } else {
      Vibration.vibrate(duration: 200);
    }

    if (_isSoundEnabled) {
      // Senin özel indirdiğin kurabiye kırma sesi
      await _player.play(AssetSource('sounds/cookieKIRIK.mp3'), volume: 1.0);
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
      // Kaliteli tını (level_up_bonus.mp3)
      await _player.play(AssetSource('sounds/level_up_bonus.mp3'), volume: 1.0);
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
