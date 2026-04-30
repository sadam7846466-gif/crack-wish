// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Crack&Wish';

  @override
  String get language => 'Dil';

  @override
  String get selectLanguage => 'Dil Seç';

  @override
  String get systemLanguage => 'Sistem';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get close => 'Kapat';

  @override
  String languageValue(Object value) {
    return 'Seçili: $value';
  }

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navCollection => 'Koleksiyon';

  @override
  String get navProfile => 'Profil';

  @override
  String get dailyCookieTitle => 'Günün Kurabiyesi';

  @override
  String get dailyCookieSubtitle => 'Şansını denemek için dokun';

  @override
  String get luckyNumber => 'Şanslı Sayı';

  @override
  String get luckyColor => 'Şanslı Renk';

  @override
  String get luckLabel => 'Şans';

  @override
  String get todayFortune => 'Bugünün Şansı';

  @override
  String get shareButton => '📸 Paylaş';

  @override
  String fortuneShareText(
    Object emoji,
    Object title,
    Object meaning,
    Object number,
    Object color,
    Object percent,
  ) {
    return '$emoji $title\n\n$meaning\n\nŞanslı Sayı: $number\nŞanslı Renk: $color\nŞans: $percent%\n\nŞans Kurabiyesi uygulamasından 🥠';
  }

  @override
  String get themeSelectTitle => 'Tasarım Seç';

  @override
  String themeSelected(Object value) {
    return 'Tasarım seçildi: $value';
  }

  @override
  String get themeGalleryTitle => 'Tema Galerisi';

  @override
  String get themeGalleryOpen => 'Tema listesine git';

  @override
  String get themeGalleryLimited => 'Tema galerisi şu an iki seçenekle sınırlı';

  @override
  String get statCookies => 'Kurabiye';

  @override
  String get statStreakDays => 'Gün seri';

  @override
  String get statDreams => 'Rüya';

  @override
  String get statMood => 'Ruh Hali';

  @override
  String get statTheme => 'Bugün...';

  @override
  String get statCollection => 'Kurabiyem';

  @override
  String get statTalisman => 'Tılsım';

  @override
  String get moodGood => 'İyi';

  @override
  String get moodSad => 'Üzgün';

  @override
  String get moodBad => 'Kötü';

  @override
  String get moodHappy => 'Mutlu';

  @override
  String get moodGreat => 'Harika';

  @override
  String get shortcutCollection => 'Koleksiyon';

  @override
  String get shortcutHistory => 'Geçmiş';

  @override
  String get shortcutFavorites => 'Favoriler';

  @override
  String get sectionShortcuts => 'Kısayollar';

  @override
  String get sectionActivity => 'Aktivite';

  @override
  String get menuBadges => 'Rozetler';

  @override
  String get menuBadgesSubtitle => 'Başarılar ve seviyeler';

  @override
  String get menuSettings => 'Ayarlar';

  @override
  String get menuSettingsSubtitle => 'Bildirim, tema, gizlilik';

  @override
  String get menuHelpAbout => 'Yardım & Hakkında';

  @override
  String get menuHelpAboutSubtitle => 'SSS ve sürüm bilgisi';

  @override
  String get menuShare => 'Paylaş';

  @override
  String get menuShareSubtitle => 'Profili arkadaşlarınla paylaş';

  @override
  String get activityTarotOpenedTitle => 'Tarot falı açıldı';

  @override
  String get activityTarotOpenedSubtitle => 'Bugün • Kart: Yıldız';

  @override
  String activityCookiesOpenedTitle(Object count) {
    return '$count kurabiye kırıldı';
  }

  @override
  String get activityCookiesOpenedSubtitle => 'Dün • Yeni mesajlar açıldı';

  @override
  String get activityDreamSavedTitle => 'Rüya yorumu kaydedildi';

  @override
  String get activityDreamSavedSubtitle => '2 gün önce';

  @override
  String get profileUserTitle => 'Kullanıcı';

  @override
  String get profileSubtitle => 'Daha az gürültü, daha çok sen';

  @override
  String get tagTarot => 'Tarot';

  @override
  String get tagDream => 'Rüya';

  @override
  String get tagCollection => 'Koleksiyon';

  @override
  String get zodiacTitle => '⭐ Burç Yorumu';

  @override
  String zodiacDailyTitle(Object name) {
    return '$name Burcu - Günlük Yorum';
  }

  @override
  String get zodiacDailyBody =>
      'Bu hafta aşk konusunda şanslısın! Kariyer fırsatları kapında, gözlerini aç. Enerjin yüksek, bunu değerlendir. Yeni projeler için mükemmel bir zaman. İletişim becerilerin zirvede, bunu kullan.';

  @override
  String get zodiacLove => 'Aşk';

  @override
  String get zodiacCareer => 'Kariyer';

  @override
  String get zodiacMoney => 'Para';

  @override
  String get zodiacHealth => 'Sağlık';

  @override
  String get collectionTitle => 'Koleksiyonun';

  @override
  String get collectionSubtitle => 'Günlük ritüelin izleri ve ödülleri';

  @override
  String get collectionNotYet => 'Henüz değil';

  @override
  String get collectionFirstTime => 'İlk defa';

  @override
  String get collectionTotalOpened => 'Toplam';

  @override
  String get collectionCookieDescription =>
      'Bu kurabiye ritüeline şans ve küçük sürprizler katıyor. Daha çok açtıkça Koleksiyonun güçlenir.';

  @override
  String get collectionSummaryTitle => 'Koleksiyon Özeti';

  @override
  String get collectionSummaryTypes => 'Farklı tür';

  @override
  String get collectionSummaryTotalOpened => 'Toplam açılan';

  @override
  String get collectionSummaryRare => 'Nadir';

  @override
  String get collectionSummaryFooter =>
      'Her kurabiyenin bir hikâyesi var. Ne kadar çok açarsan, o kadar zenginleşir.';

  @override
  String get rarityAll => 'Tümü';

  @override
  String get rarityCommon => 'Sık';

  @override
  String get rarityRare => 'Nadir';

  @override
  String get rarityLegendary => 'Efsanevi';

  @override
  String get collectionUndiscovered => 'Keşfedilmedi';

  @override
  String get collectionNotFoundYet => 'Şansın seni buraya getirmedi… henüz.';

  @override
  String get collectionEmptyTitle => 'Henüz kurabiye açmadın';

  @override
  String collectionEmptySubtitle(Object count) {
    return '$count farklı kurabiye seni bekliyor. Bugünün kurabiyesini aç, koleksiyonunu başlat.';
  }

  @override
  String get discoverTitle => 'Keşfet';

  @override
  String get discoverSubtitle => 'Yeni özellikler keşfet';

  @override
  String get discoverCategories => 'Kategoriler';

  @override
  String get categoryTarotTitle => 'Tarot Falı';

  @override
  String get categoryTarotDesc => '3 Kartlı Tarot';

  @override
  String get categoryDreamTitle => 'Rüya Tabiri';

  @override
  String get categoryDreamDesc => 'Rüyalarının sırrını çöz';

  @override
  String get categoryZodiacTitle => 'Burç Yorumu';

  @override
  String get categoryZodiacDesc => 'Yıldızların mesajı';

  @override
  String get categoryPersonalityTitle => 'Kişilik Testi';

  @override
  String get categoryPersonalityDesc => '16 Kişilik';

  @override
  String get discoverDailySuggestionTitle => 'GÜNÜN ÖNERİSİ';

  @override
  String get discoverDailySuggestionHeadline => 'Dün gece bir rüya gördün mü?';

  @override
  String get discoverDailySuggestionSubtitle =>
      'Hemen yorumla, anlamını öğren!';

  @override
  String get dailySuggestionDreamHeadline => 'Dün gece bir rüya gördün mü?';

  @override
  String get dailySuggestionDreamSubtitle => 'Hemen yorumla, anlamını öğren!';

  @override
  String get dailySuggestionTarotHeadline => 'Bugün tarot falına baktın mı?';

  @override
  String get dailySuggestionTarotSubtitle => '3 kart seç, günlük mesajını gör!';

  @override
  String get dailySuggestionZodiacHeadline => 'Burç yorumunu kontrol ettin mi?';

  @override
  String get dailySuggestionZodiacSubtitle => 'Günün enerjisini hemen öğren!';

  @override
  String get dailySuggestionAllDoneHeadline => 'Bugünün ritüelleri tamam!';

  @override
  String get dailySuggestionAllDoneSubtitle =>
      'Yarın için geri gel, yeni içerikler gelecek.';

  @override
  String get discoverFeaturedTag => 'ÖNE ÇIKAN';

  @override
  String get discoverFeaturedTitle => '3 Kartlı Tarot Falı';

  @override
  String get discoverFeaturedSubtitle => 'Geçmiş, şimdi ve geleceğini keşfet';

  @override
  String get ctaStart => 'Başla';

  @override
  String get homeGreeting => 'Merhaba! 👋';

  @override
  String get homeFeeling => 'Bugün nasıl hissediyorsun?';

  @override
  String get quoteOfDayText =>
      'Bugün yapabileceğin en küçük adım, yarının en büyük zaferine götürür.';

  @override
  String get quoteOfDaySource => '— Günün Sözü';

  @override
  String get dailyHoroscopeTitle => 'Koç Burcu';

  @override
  String get dailyHoroscopeSubtitle => 'Bugünkü Yorum';

  @override
  String get dailyHoroscopeBody =>
      'Bu hafta aşk konusunda şanslısın! Kariyer fırsatları kapında, gözlerini aç. Enerjin yüksek, bunu değerlendir.';

  @override
  String get aries => 'Koç';

  @override
  String get bentoTarotTitle => 'Tarot';

  @override
  String get bentoTarotDesc => 'Geleceğini gör';

  @override
  String get bentoTarotBadge => 'POPÜLER';

  @override
  String get bentoDreamTitle => 'Rüya';

  @override
  String get bentoDreamDesc => 'Bilinçaltını keşfet';

  @override
  String get bentoDreamBadge => 'YENİ';

  @override
  String get bentoMotivationTitle => 'Mod';

  @override
  String get bentoMotivationDesc => 'Ruh halini keşfet';

  @override
  String get bentoMotivationBadge => 'GÜNLÜK';

  @override
  String get bentoZodiacTitle => 'Burç';

  @override
  String get bentoZodiacDesc => 'Yıldızların mesajı';

  @override
  String get bentoZodiacBadge => 'GÜNLÜK';

  @override
  String get moodQuestion => 'Bugün nasılsın?';

  @override
  String get dreamTitle => 'Rüyanı Anlat';

  @override
  String get dreamTabNew => 'Yeni Rüya';

  @override
  String get dreamTabHistory => 'Rüyalarım';

  @override
  String get dreamAnalyzeButton => 'Rüyayı Yorumla';

  @override
  String get dreamAnalyzeEstimate => '~ 5 sn sürer';

  @override
  String get dreamInterpretationTitle => 'Rüyanın Yorumu';

  @override
  String get dreamNoHistory => 'Henüz kayıtlı rüyan yok';

  @override
  String get dreamDefaultTitle => 'Rüya';

  @override
  String get dreamSpiritual => 'Spiritüel';

  @override
  String get dreamEnriched => 'Derinleştirilmiş Yorum';

  @override
  String get dreamEnriching => 'Derinleştiriliyor...';

  @override
  String get dreamEnrich => 'Derinleştir';

  @override
  String get dreamShare => 'Paylaş';

  @override
  String get dreamAnalyzing => 'Rüya analiz ediliyor...';

  @override
  String get dreamAnalysisFailed => 'Şu anda yorum oluşturulamadı.';

  @override
  String get dreamClarifyThreat => 'Rüyada tehdit veya korku hissi var mıydı?';

  @override
  String get dreamClarifyFamiliar => 'Bu sahne sana geçmişten tanıdık mıydı?';

  @override
  String get dreamClarifyEscape => 'Rüyada hareket/kaçış hissi var mıydı?';

  @override
  String get dreamClarifyAnxious =>
      'Rüyada tedirginlik veya tehdit hissi var mıydı?';

  @override
  String get dreamUnsure => 'Emin değilim';

  @override
  String get dreamYes => 'Evet';

  @override
  String get dreamNo => 'Hayır';

  @override
  String get dreamGeneral => 'Genel Rüya';

  @override
  String dreamShareText(
    Object title,
    Object date,
    Object text,
    Object general,
    Object psychology,
    Object spiritual,
    Object advice,
  ) {
    return 'Rüya Başlığı: $title\nTarih: $date\n\nRüya: $text\n\nGenel: $general\nPsikolojik: $psychology\nSpiritüel: $spiritual\nTavsiye: $advice\n\n#VLucky #Rüya';
  }

  @override
  String get scientificTitle => 'Bilimsel Rüya Analizi';

  @override
  String get scientificDreamPromptTitle => 'Rüyanı Anlat';

  @override
  String get scientificDreamHint => 'Rüyanı hatırladığın kadar yaz...';

  @override
  String get scientificEmotionQuestion => 'Uyandığında nasıl hissettin?';

  @override
  String get scientificEmotionHint => 'Tek bir duygu seç';

  @override
  String get scientificClarityQuestion => 'Rüya ne kadar netti?';

  @override
  String get scientificDisclaimer =>
      'Bu analiz psikoloji ve nörobilim araştırmalarına dayanmaktadır. Kesin veya öngörücü sonuçlar sunmaz.';

  @override
  String get scientificLoading =>
      'REM uykusu ve nörobilim temelinde değerlendiriliyor';

  @override
  String get scientificResultsTitle => 'Rüyanın Yorumu';

  @override
  String get scientificRecentPastTitle => 'Yakın Geçmiş Etkileri';

  @override
  String get scientificSaved => 'Rüya kaydedildi';

  @override
  String get scientificSaveButton => 'Rüyayı Kaydet';

  @override
  String get cookieSpringWreath => 'Bahar Çelengi';

  @override
  String get cookieLuckyClover => 'Şanslı Yonca';

  @override
  String get cookieRoyalHearts => 'Kraliyet Kalpleri';

  @override
  String get cookieEvilEye => 'Nazar';

  @override
  String get cookiePizzaParty => 'Pizza Partisi';

  @override
  String get cookieSakuraBloom => 'Sakura';

  @override
  String get cookieBluePorcelain => 'Mavi Porselen';

  @override
  String get cookiePinkBlossom => 'Pembe Çiçek';

  @override
  String get cookieFortuneCat => 'Şans Kedisi';

  @override
  String get cookieWildflower => 'Kır Çiçeği';

  @override
  String get cookieCupidRibbon => 'Aşk Kurdelesi';

  @override
  String get cookiePandaBamboo => 'Panda';

  @override
  String get cookieRamadanCute => 'Ramazan';

  @override
  String get cookieEnchantedForest => 'Büyülü Orman';

  @override
  String get cookieGoldenArabesque => 'Altın Arabesk';

  @override
  String get cookieMidnightMosaic => 'Gece Mozaiği';

  @override
  String get cookiePearlLace => 'İnci Dantel';

  @override
  String get cookieGoldenSakura => 'Altın Sakura';

  @override
  String get cookieDragonPhoenix => 'Ejderha & Anka';

  @override
  String get cookieGoldBeasts => 'Altın Canavarlar';

  @override
  String get emotionAnxiety => 'Kaygılı';

  @override
  String get emotionFear => 'Korkmuş';

  @override
  String get emotionCalm => 'Huzurlu';

  @override
  String get emotionHappy => 'Mutlu';

  @override
  String get emotionSad => 'Üzgün';

  @override
  String get emotionConfusion => 'Belirsiz';

  @override
  String get emotionSurprise => 'Şaşkın';

  @override
  String get dreamMoodQuestion => 'Uyandığında nasıl hissettin?';

  @override
  String get dreamMetricEmotional => 'Duygusal Yük';

  @override
  String get dreamMetricUncertainty => 'Belirsizlik';

  @override
  String get dreamMetricRecentPast => 'Yakın Geçmiş';

  @override
  String get dreamMetricBrain => 'Beyin Akt.';

  @override
  String get tarotShuffleHint => 'Karıştırmak için dairesel sürükle';

  @override
  String get tarotEnergyDepletedTitle => 'Enerji Tükendi';

  @override
  String get tarotEnergyDepletedBody =>
      'Günlük kozmik enerjin tükendi.\nGerçeği görmek için enerjini yenile.';

  @override
  String get tarotEnergyDepletedSub =>
      'Seçtiğin kartlar hazır, sadece bir adım kaldı...';

  @override
  String get tarotWatchAd => 'Reklam İzle & Aç';

  @override
  String tarotFreeRemaining(Object count) {
    return 'Bugün kalan ücretsiz: $count';
  }

  @override
  String get socialFeedTitle => 'Sessiz Akış';

  @override
  String get feedTypeCookie => 'Kurabiye';

  @override
  String get feedTagDailyCookie => 'Bugünkü kurabiye';

  @override
  String get feedTypeTarot => 'Tarot';

  @override
  String get feedTagThreeCard => '3 kart çekimi';

  @override
  String get feedTypeDream => 'Rüya';

  @override
  String get feedTagDreamMode => 'Rüya modu';

  @override
  String get feedTypeZodiac => 'Burç';

  @override
  String get feedTagDailyEnergy => 'Günlük enerji';

  @override
  String get feedTypeMotivation => 'Motivasyon';

  @override
  String get feedTagMiniAction => 'Mini eylem';

  @override
  String inviteShareMessage(String handle, String link) {
    return 'Mistik bir yolculuğa hazır mısın? Crack&Wish evreninde seni bekliyorum! ✨\n\nDavet kodum: $handle\nHemen İndir: $link';
  }

  @override
  String get inviteShareSubject => 'Crack&Wish Daveti';

  @override
  String get inviteSendButton => 'Davet Et';

  @override
  String get inviteConnectButton => 'Bağlan';

  @override
  String get inviteSentText => 'Gönderildi';

  @override
  String inviteRequestSent(String name) {
    return '$name kişisine istek gönderildi!';
  }
}
