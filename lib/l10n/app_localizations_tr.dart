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
  String get dailySuggestionCoffeeHeadline => 'Bugün kahve içtin mi?';

  @override
  String get dailySuggestionCoffeeSubtitle =>
      'Fincanını kapat, falına bakalım!';

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
  String get dreamYes => 'EVET';

  @override
  String get dreamNo => 'HAYIR';

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
  String get dreamMetricUncertainty => 'Anlatısal\nBelirsizlik';

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

  @override
  String get toastCoffeeReadyTitle => 'Falın Hazır!';

  @override
  String get toastCoffeeReadyMessage => 'Fincanındaki sırlar çözüldü.';

  @override
  String get toastViewButton => 'Göz At';

  @override
  String get toastDreamReadyTitle => 'Rüyan Yorumlandı!';

  @override
  String get toastDreamReadyMessage => 'Bilinçaltının mesajları çözüldü.';

  @override
  String get toastCoffeeReadyTitle2 => 'Kahve Falın Hazır!';

  @override
  String get dreamFallbackTitle => 'Rüya Yorumu';

  @override
  String get rewardWelcomeTitle => 'Evrene Hoş Geldin';

  @override
  String get rewardWelcomeDesc =>
      'Yolculuğuna başlaman için sana küçük bir hediye bıraktık.';

  @override
  String get rewardReferralFallback => 'Bir arkadaşın';

  @override
  String get rewardReferralReceiverTitle => 'Beklenmedik Bir Hediye';

  @override
  String rewardReferralReceiverDesc(String inviter) {
    return '$inviter seni buraya davet ettiği için sana bir karşılama hediyesi bıraktı.';
  }

  @override
  String get rewardInviterTitle => 'Çağrın Duyuldu!';

  @override
  String rewardInviterDescSingle(String name) {
    return '$name evrene katıldı. Yol gösterici olduğun için ödüllendirildin.';
  }

  @override
  String rewardInviterDescMultiple(String name, int count) {
    return '$name ve $count arkadaşın daha evrene katıldı. Yol gösterici olduğun için ödüllendirildin.';
  }

  @override
  String rewardInviterDescGeneric(int count) {
    return '$count arkadaşın evrene katıldı. Yol gösterici olduğun için ödüllendirildin.';
  }

  @override
  String birthdayTitleWithName(String name) {
    return '$name, Doğum Günün Kutlu Olsun!';
  }

  @override
  String get birthdayTitle => 'Doğum Günün Kutlu Olsun!';

  @override
  String get birthdayDesc =>
      'Bugün ruhunun bu dünyaya indiği kutsal gün. Evren sana özel bir hediye bıraktı.';

  @override
  String get cookieReminderTitle => 'Bugün Kurabiye Kırmadın';

  @override
  String get cookieReminderMessage => 'Günlük şans mesajın seni bekliyor!';

  @override
  String get cookieReminderReward => '3 Hak';

  @override
  String achievementRewardStones(int count) {
    return '+$count Ruh Taşı';
  }

  @override
  String achievementRewardAura(int count) {
    return '+$count Aura';
  }

  @override
  String get rankUpTitle => 'Kozmik Terfi!';

  @override
  String rankUpMessage(String rank) {
    return 'Aura gücün arttı. Yeni unvanın: $rank';
  }

  @override
  String get rankNovice => 'Acemi Kahin';

  @override
  String get rankApprentice => 'Çırak Kahin';

  @override
  String get rankSeer => 'Kahin';

  @override
  String get rankWise => 'Bilge Kahin';

  @override
  String get rankMaster => 'Usta Kahin';

  @override
  String get rankCosmic => 'Kozmik Kahin';

  @override
  String get loginSubtitle =>
      'Ruhunun rehberi ile senkronize ol.\nGeçmişini, geleceğini ve bilinçaltını hatırla.';

  @override
  String get loginAppleContinue => 'Apple ile Devam Et';

  @override
  String get loginAppleSignIn => 'Apple ile Giriş Yap';

  @override
  String get loginGoogleContinue => 'Google ile Devam Et';

  @override
  String get loginGoogleSignIn => 'Google ile Giriş Yap';

  @override
  String get loginGoogleFailed => 'Google Girişi Başarısız';

  @override
  String get loginAppleFailed => 'Apple Girişi Başarısız';

  @override
  String get loginNoAccountYet => 'Henüz evrene katılmadın mı?  ';

  @override
  String get loginHaveAccount => 'Zaten hesabın var mı?  ';

  @override
  String get loginSignUp => 'Kayıt Ol';

  @override
  String get loginSignIn => 'Giriş Yap';

  @override
  String get loginLegalPrefix => 'Devam ederek ';

  @override
  String get loginTermsOfUse => 'Kullanım Şartları';

  @override
  String get loginLegalAnd => ' ve ';

  @override
  String get loginPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get loginLegalSuffix => '\'nı kabul etmiş olursunuz.';

  @override
  String get homeSubtitle1 => 'Kır, Oku, Gülümse.';

  @override
  String get homeSubtitle2 => 'Şansın cebinde.';

  @override
  String get homeSubtitle3 => 'Günün mesajı: Sen.';

  @override
  String get homeSubtitle4 => 'Bir kırık, bir sürpriz.';

  @override
  String get homeSubtitle5 => 'Küçük bir kurabiye, büyük bir his.';

  @override
  String get homeSubtitle6 => 'Kader değil, tatlı bir ipucu.';

  @override
  String get homeSubtitle7 => 'Bugün ne diyor şansın?';

  @override
  String get homeSubtitle8 => 'Aç, keşfet, devam et.';

  @override
  String get homeSubtitle9 => 'Şans bir tık uzağında.';

  @override
  String get homeSubtitle10 => 'Her kırışta yeni bir başlangıç.';

  @override
  String get homeSubtitle11 => 'Mesajını bul.';

  @override
  String get homeSubtitle12 => 'Rastgele değil… tam sana göre.';

  @override
  String get homeSubtitle13 => 'Şansını kır, gününü yakala.';

  @override
  String get homeSubtitle14 => 'Gülümseten minik kehanetler.';

  @override
  String get homeSubtitle15 => 'Sürpriz iyi gelir.';

  @override
  String get homeMilestoneTitle => 'İnanılmaz Odak!';

  @override
  String homeMilestoneMessage(int count) {
    return 'Günlük serin tam $count güne ulaştı.';
  }

  @override
  String homeMilestoneSoulStone(int count) {
    return '+$count Ruh Taşı';
  }

  @override
  String get homeGreetingMorning => 'Günaydın';

  @override
  String get homeGreetingAfternoon => 'İyi Günler';

  @override
  String get homeGreetingEvening => 'İyi Akşamlar';

  @override
  String get homeGreetingNight => 'İyi Geceler';

  @override
  String get homeTimeSubMorning => 'Kahvenin yanına taze bir mesaj geldi.';

  @override
  String get homeTimeSubAfternoon => 'Günün koşturmacasına sihirli bir mola.';

  @override
  String get homeTimeSubEvening =>
      'Günün yorgunluğunu atacak tatlı bir kehanet.';

  @override
  String get homeTimeSubNight => 'Yıldızlar bu gece senin için parlıyor.';

  @override
  String get paywallSubtitleElite =>
      'Kozmik farkındalığın zaten açık.\nPlanını yükselterek aydınlanmanı güçlendir.';

  @override
  String get paywallSubtitleNew =>
      'Kozmik farkındalığa giden kapıyı aç.\nSınırları tamamen kaldır.';

  @override
  String get paywallFeature1 => 'Günde 5 Taze Ruh Taşı';

  @override
  String get paywallFeature2 => 'Master Analiz Modu';

  @override
  String get paywallFeature3 => 'x3 Hızlı Aura Kazanımı';

  @override
  String get paywallFeature4 => 'Sonsuz Klinik Arşiv';

  @override
  String get paywallFeature5 => 'Reklamsız Kesintisiz Deneyim';

  @override
  String get paywallPackageWeekly => 'Haftalık Uyanış';

  @override
  String get paywallPackageMonthly => 'Aylık Sezgi';

  @override
  String get paywallPackageYearly => 'Yıllık Aydınlanma';

  @override
  String get paywallBtnCurrentPlan => 'Mevcut Planın';

  @override
  String get paywallBtnManage => 'Mağazadan Yönet';

  @override
  String get paywallBtnUpgrade => 'Planı Yükselt';

  @override
  String get paywallBtnSubscribe => 'Elite Sınırlarını Aç';

  @override
  String get paywallSuccessUpgradeTitle => 'Aydınlanma Yükseldi';

  @override
  String get paywallSuccessTitle => 'Aydınlanmaya Hoşgeldiniz';

  @override
  String get paywallSuccessUpgradeSubtitle => 'Planınız başarıyla yükseltildi.';

  @override
  String get paywallSuccessSubtitle =>
      'Artık bir Elite üyesisiniz. Kozmik sınırlar sizin için kaldırıldı.';

  @override
  String get paywallErrorTitle => 'Bağlantı Hatası';

  @override
  String get paywallErrorMessage =>
      'Mağazaya bağlanılamadı veya işlem iptal edildi. Ürünler henüz App Store/Play Console\'da yayına alınmamış olabilir. Lütfen daha sonra tekrar deneyin.';

  @override
  String get paywallRestoreSuccess => 'Elite Geri Yüklendi';

  @override
  String get paywallRestoreSuccessSubtitle =>
      'Kozmik farkındalığa yeniden hoş geldiniz. Sınırlarınız kaldırıldı.';

  @override
  String get paywallRestoreNoSub => 'Aktif Abonelik Yok';

  @override
  String get paywallRestoreNoSubMessage =>
      'Geri yüklenebilecek aktif bir Crack Wish Elite üyeliği bulunamadı. Lütfen paketleri inceleyin.';

  @override
  String get paywallRestore => 'Satın Alımları Geri Yükle';

  @override
  String get paywallCurrentPlanBadge => 'MEVCUT PLAN';

  @override
  String get paywallLegalTr =>
      'Aboneliğiniz, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Ödeme, satın alma onayında Apple ID / Google Play hesabınızdan tahsil edilir. Aboneliğinizi mağaza hesap ayarlarınızdan dilediğiniz zaman yönetebilirsiniz.';

  @override
  String get paywallOk => 'Tamam';

  @override
  String get coffeeLoading1 => 'Fincanın derinliklerine iniliyor...';

  @override
  String get coffeeLoading2 =>
      'Telvelerdeki semboller evrensel enerjiyle eşleşiyor...';

  @override
  String get coffeeLoading3 => 'Kader çizgilerin haritalanıyor...';

  @override
  String get coffeeLoading4 => 'Sırlar açığa çıkıyor...';

  @override
  String get coffeeAiError => 'AI falı yorumlarken bir hata ile karşılaştı.';

  @override
  String get coffeeGenericError => 'Bir sorun oluştu. Lütfen tekrar dene.';

  @override
  String get coffeeNotifReady => 'Falın hazır olunca bildirim alacaksın';

  @override
  String get coffeeCheckHistory => '  butonundan görebilirsin';

  @override
  String get coffeeWaitOrExplore => 'Burada bekle ya da uygulamayı keşfet';

  @override
  String get coffeeGoHome => 'Ana Sayfaya Dön';

  @override
  String get coffeeSections => 'Fincanın Bölümleri';

  @override
  String get coffeeSectionInside => 'Fincan İçi';

  @override
  String get coffeeSectionInsideDesc =>
      'İç dünyan, düşüncelerin, duygusal halin.';

  @override
  String get coffeeSectionEdge => 'Fincan Kenarı';

  @override
  String get coffeeSectionEdgeDesc => 'Yakın gelecek, haber, mesaj, görüşme.';

  @override
  String get coffeeSectionBottom => 'Fincan Dibi';

  @override
  String get coffeeSectionBottomDesc =>
      'Geçmişten kalan konu, yük, kapanmamış mesele.';

  @override
  String get coffeeSectionSaucer => 'Tabak';

  @override
  String get coffeeSectionSaucerDesc => 'Dilek, sonuç, kısmet, son enerji.';

  @override
  String get coffeeLoadingComment => 'Yorum yükleniyor...';

  @override
  String get coffeeStoryTitle => 'Telvelerin Anlattığı Hikaye';

  @override
  String get coffeeSymbolsTitle => 'Falında Görülen Semboller';

  @override
  String get coffeeLove => 'Aşk & İlişkiler';

  @override
  String get coffeeCareer => 'İş & Para';

  @override
  String get coffeeFamily => 'Aile & Yakın Çevre';

  @override
  String get coffeeNearFuture => 'Yakın Gelecek';

  @override
  String get coffeeClosing => 'Falın Son Sözü';

  @override
  String get coffeeShare => 'Falımı Paylaş';

  @override
  String get coffeeRetryValidation => 'Geri Dön & Yeniden Çek';

  @override
  String get coffeeRetry => 'Tekrar Dene';

  @override
  String get coffeeCancel => 'İptal Et';

  @override
  String get coffeeSymbolLabel => 'Sembol';

  @override
  String get coffeeSymbolLoading => 'Yükleniyor...';

  @override
  String get coffeeTimelineSoon => 'Çok Yakında';

  @override
  String get coffeeImageError =>
      'Bu görselde net bir kahve telvesi seçilemiyor.';

  @override
  String get coffeeCosmicTitle => 'Kozmik Kahve Yorumu';

  @override
  String get coffeePremiumOnly => 'Sadece Premium Özeldir';

  @override
  String get coffeePremiumDesc =>
      'Kahve Falı özelliği uygulamanın elit üyelerine aittir. Premium\'a geç ve Ruh Taşlarınla geleceğin sırlarını arala.';

  @override
  String get coffeePremiumSimBtn => 'Premium Ol (Simülasyon)';

  @override
  String get coffeePhotoSource => 'Fotoğraf Kaynağı';

  @override
  String get coffeeCamera => 'Kamera';

  @override
  String get coffeeGallery => 'Galeri';

  @override
  String get coffeeStepCupInside => 'Fincan İçi';

  @override
  String get coffeeStepCupInsideDesc =>
      'Kamerayı fincanın tam üstüne getirin ve içindeki telveleri odaklayarak çekin.';

  @override
  String get coffeeStepLeftProfile => 'Sol Profil';

  @override
  String get coffeeStepLeftProfileDesc =>
      'Fincanı kulbundan tutup sadece sol yüzünün fotoğrafını net bir şekilde çekin.';

  @override
  String get coffeeStepRightProfile => 'Sağ Profil';

  @override
  String get coffeeStepRightProfileDesc =>
      'Şimdi fincanın sağ arka yüzünü, ışığın vurduğu açıdan çekin.';

  @override
  String get coffeeStepSaucerSecret => 'Tabağın Sırrı';

  @override
  String get coffeeStepSaucerDesc =>
      'Son olarak tabağın geniş yüzeyini, içindeki telveler net görünecek şekilde çekin.';

  @override
  String get coffeeStepSaucerBtn => 'Tabak Fotoğrafı Çek';

  @override
  String get coffeeHeaderTitle => 'KAHVE FALI';

  @override
  String get coffeeLastReading => 'Son Falın';

  @override
  String coffeeLastReadingTime(String time) {
    return 'Saat $time • Gece 00:00\'da silinir';
  }

  @override
  String get coffeeNoReadingYet =>
      'Henüz fal baktırmadın.\nBir fincan kahve demle,\ntelvelerin sana fısıldamasını bekle.';

  @override
  String get coffeeSoulStones => 'Ruh Taşların';

  @override
  String get coffeeSoulStoneEmpty => 'Ruh Taşın bitti';

  @override
  String get coffeeSoulStoneRequired => 'Kahve falı yorumlaması için gerekli';

  @override
  String get coffeeSoulStoneCost => 'Her yorum 1 Ruh Taşı harcar';

  @override
  String get coffeeSoulStoneEliteActive =>
      'Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir';

  @override
  String get coffeeSoulStoneElitePromo => 'Elite ile her gece 5 Ruh Taşı kazan';

  @override
  String get coffeeEliteSubscribe => 'Elite Abone Ol';

  @override
  String get coffeeRitualLabel => 'RİTÜEL';

  @override
  String get coffeeRitualTitle => 'Fincanın Sırları';

  @override
  String get coffeeRitualDesc =>
      'Telveler sadece onlara doğru bakanlara konuşur. Gerçek bir okuma için ritüeli takip et.';

  @override
  String get coffeeRitualStep1Title => 'Niyetini Belirle';

  @override
  String get coffeeRitualStep1Desc =>
      'Yudumlarken zihninden bir soru veya dilek geçir.';

  @override
  String get coffeeRitualStep2Title => 'Aynı Yerden İç';

  @override
  String get coffeeRitualStep2Desc =>
      'Şekillerin bozulmaması için hep aynı taraftan yudumla.';

  @override
  String get coffeeRitualStep3Title => 'Ters Çevir';

  @override
  String get coffeeRitualStep3Desc =>
      'Fincanı kapat, soğumasını bekle ve yavaşça aç.';

  @override
  String get coffeeRitualListenTitle => 'Telvelerin Fısıltısını Dinle';

  @override
  String coffeeStepLabel(String index, String title) {
    return 'Adım $index: $title';
  }

  @override
  String get coffeeDiscoverFate => 'Kaderini Keşfet';

  @override
  String get coffeeNextStep => 'Sonraki Adım';

  @override
  String get coffeeValidationError =>
      'İşaretli fotoğraflardaki telveler\ntam olarak seçilemiyor.';

  @override
  String get coffeeCosmicMismatch => 'Kozmik Uyumsuzluk';

  @override
  String get coffeeCosmicCheck => 'KOZMİK BAĞ KONTROLÜ';

  @override
  String get coffeeCosmicCheckDesc =>
      'Telvelerin dili çözülüyor,\nkaderin fısıltıları dinleniyor...';

  @override
  String get coffeeRevealSecrets => 'Sır Perdesini Arala';

  @override
  String get coffeeReadingInProgress => 'Telveler Okunuyor...';

  @override
  String get coffeeReadingWait => 'Geleceğin kapıları aralanıyor, bekle.';

  @override
  String get coffeeRelationTitle => 'İlişki Durumun';

  @override
  String get coffeeRelationSubtitle => 'Kozmik bağın temelini belirle.';

  @override
  String get coffeeFocusTitle => 'Aklında Ne Var?';

  @override
  String get coffeeFocusSubtitle =>
      'Bir niyet seç, yorumun ona göre derinleşsin.';

  @override
  String get coffeeMoodTitle => 'Ruh Halin?';

  @override
  String get coffeeMoodSubtitle => 'Fincanının enerjisini hisset.';

  @override
  String get coffeeCosmicBondFormed => 'Kozmik Bağ Kuruldu';

  @override
  String get coffeeSecretsReady => 'Fincanının sırları fısıldanmaya hazır...';

  @override
  String get coffeeNewReading => 'Yeni Fal Bak';

  @override
  String get coffeeAiPermission => 'Yapay zeka kahve analizi izni';

  @override
  String get coffeeStoneCostInfo => 'Her analiz 1 Ruh Taşı harcar';

  @override
  String get coffeeEliteRefillActive =>
      'Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir';

  @override
  String get coffeeEliteRefillPromo => 'Elite ile her gece 5 Ruh Taşı kazan';

  @override
  String get coffeeEliteGetBtn => 'Elite Al';

  @override
  String get coffeeResultOnHome => 'Sonucu ana sayfadaki  ';

  @override
  String get onboardingStart => 'Hadi Başlayalım';

  @override
  String get onboardingContinue => 'Devam Et';

  @override
  String get onboardingFinish => 'Yolculuğa Başla';

  @override
  String get onboardingNameHint => 'Kozmik Bir İsim';

  @override
  String get onboardingNamePlaceholder => 'isim_soyisim';

  @override
  String get onboardingHandleHint => 'Kozmik Bir Lakap';

  @override
  String get onboardingHandlePlaceholder => 'galaksi_gezgin';

  @override
  String get onboardingGenderTitle => 'Cinsiyet';

  @override
  String get onboardingGenderFemale => 'Kadın';

  @override
  String get onboardingGenderMale => 'Erkek';

  @override
  String get onboardingGenderOther => 'Belirtmek İstemiyorum';

  @override
  String get onboardingStep1Title => 'Sana ne demeliyiz?';

  @override
  String get onboardingStep1Sub =>
      'Evren seni hangi isimle ve titreşimle tanısın?';

  @override
  String get onboardingAvatarSelect => 'Görünümünü Seç';

  @override
  String get onboardingStep2Title => 'Ruhunun bedene girdiği an...';

  @override
  String get onboardingStep2Sub =>
      'Astrolojik doğum haritanı ve sana özel ritüelleri hesaplayabilmemiz için temel bilgilerine ihtiyacımız var.';

  @override
  String get onboardingBirthDateLabel => 'Doğum Tarihin';

  @override
  String get onboardingBirthTimeLabel => 'Doğum Saatin';

  @override
  String get onboardingBirthLocationLabel => 'Doğduğu Şehir';

  @override
  String get onboardingTimeHint =>
      'Tam saati biliyorsan detaylı analiz için gir';

  @override
  String get onboardingLocationHint => 'Şehir seçerek hesaplamayı netleştir';

  @override
  String get onboardingUnknownTime => 'Tam saati bilmiyorum';

  @override
  String get onboardingPrivacyNote =>
      'Yalnızca sana özel haritanı çizmek içindir.';

  @override
  String get onboardingStep3Title => 'Odak noktan neresi?';

  @override
  String get onboardingStep3Sub =>
      'Şu sıralar hayatında en çok hangi enerjiyi büyütmek veya şifalandırmak istiyorsun?';

  @override
  String get onboardingFocusLabel => 'Odak (Çoklu Seçim)';

  @override
  String get onboardingFocusCareer => 'Kariyer & Para';

  @override
  String get onboardingFocusLove => 'Aşk & İlişkiler';

  @override
  String get onboardingFocusPeace => 'İçsel Huzur';

  @override
  String get onboardingFocusLuck => 'Şans & Fırsatlar';

  @override
  String get onboardingRelLabel => 'Şu anki ilişki durumun:';

  @override
  String get onboardingRelSingle => 'Yalnız Gökyüzü';

  @override
  String get onboardingRelComplicated => 'Biri Var...';

  @override
  String get onboardingRelTalking => 'Karmaşık';

  @override
  String get onboardingRelRelationship => 'Mutlu Bir Bağ';

  @override
  String get onboardingStep4Title => 'Geceleri evrenle bağın...';

  @override
  String get onboardingStep4Sub =>
      'Bilinçaltın mesajları nasıl alıyor? Renklerin ve rüyaların bize ipucu verecek.';

  @override
  String get onboardingDreamLabel => 'Ne sıklıkla rüya hatırlarsın?';

  @override
  String get onboardingDreamOften => 'Sık Sık ve Çok Net';

  @override
  String get onboardingDreamSometimes => 'Bazen Hatırlarım';

  @override
  String get onboardingDreamRarely => 'Nadir';

  @override
  String get onboardingDreamNever => 'Hiç Rüya Görmem';

  @override
  String get onboardingAuraLabel =>
      'Ruhunun Aurası (Bugün nasıl hissediyorsun?)';

  @override
  String get onboardingStep5Title => 'Zamanla olan dansın...';

  @override
  String get onboardingStep5Sub =>
      'Günün hangi saatlerinde enerjin en yüksek? Bildirimlerini buna göre ayarlayacağız.';

  @override
  String get onboardingSleepLabel => 'Uyku Düzenin';

  @override
  String get onboardingSleepMorning => 'Sabah İnsanı';

  @override
  String get onboardingSleepNight => 'Gece Kuşu';

  @override
  String get onboardingSleepIrregular => 'Düzensiz';

  @override
  String get onboardingSleepLittle => 'Çok Az Uyurum';

  @override
  String get onboardingMatchLabel => 'Eşleşme ve Kozmik Bağ';

  @override
  String get onboardingMatchDesc =>
      'Sinerji uyumlu profillerle bağ kurmaya ve özel kozmik eşleşmelere açık olmak istiyorum.';

  @override
  String get onboardingFinalTitle => 'Her şey hazır...';

  @override
  String get onboardingFinalSub =>
      'Yıldızların senin için ne planladığını öğrenmek üzeresin. Hesabını oluştur ve kozmik evrene giriş yap.';

  @override
  String get onboardingAppleCreate => 'Apple ile Hesabını Oluştur';

  @override
  String get onboardingGoogleCreate => 'Google ile Hesabını Oluştur';

  @override
  String get onboardingErrorIncomplete =>
      'Hoş geldin! Profilini tamamlamak için birkaç adım kaldı.';

  @override
  String get onboardingErrorFailed =>
      'Giriş başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String onboardingErrorAlreadyExists(String provider) {
    return 'Bu $provider hesabı ile zaten bir kozmik profilin var! Lütfen ilk sayfadaki \'Giriş Yap\' seçeneğini kullan.';
  }

  @override
  String onboardingErrorDBRejected(String error) {
    return 'Kayıt işlemi veritabanında reddedildi:\n$error\nLütfen destek ile iletişime geçin.';
  }

  @override
  String get onboardingErrorHandleTaken => 'Bu kullanıcı adı zaten alınmış';

  @override
  String get notifTitle => 'Bildirimler';

  @override
  String get notifSubtitle => 'Hangi bildirimleri almak istediğini seç';

  @override
  String get notifAnnouncements => 'Duyurular';

  @override
  String get notifAnnouncementsDesc => 'Yeni özellikler ve güncellemeler';

  @override
  String get notifSounds => 'Sesler';

  @override
  String get notifSoundsDesc => 'Sesli bildirim uyarıları';

  @override
  String get notifCookieAlarm => 'Yeni Kurabiye Alarmı';

  @override
  String get notifCookieAlarmDesc => 'Yeni fortune cookie geldiğinde';

  @override
  String get notifFriendAlarm => 'Arkadaş Alarmı';

  @override
  String get notifFriendAlarmDesc => 'Baykuş ağından yeni bağlantılar';

  @override
  String get notifDailyReminder => 'Günlük Hatırlatıcılar';

  @override
  String get notifDailyReminderDesc => 'Günlük kurabiyeni almayı unutma';

  @override
  String get accountTitle => 'Hesap Detayları';

  @override
  String get accountSubtitle => 'Kişisel bilgilerin ve hesap yönetimin';

  @override
  String get accountUsername => 'Kullanıcı Adı';

  @override
  String get accountLinkedEmail => 'Bağlı E-posta';

  @override
  String get accountSignInMethod => 'Giriş Yöntemi';

  @override
  String get accountDeleteTitle => 'Hesabı Sil';

  @override
  String get accountDeleteDesc =>
      'Tüm verilerin kalıcı olarak silinecek.\nBu işlem geri alınamaz.';

  @override
  String get accountDeleteCancel => 'Vazgeç';

  @override
  String get accountDeleteConfirm => 'Hesabı Sil';

  @override
  String get accountDeletePermanent => 'Hesabı Kalıcı Olarak Sil';

  @override
  String get welcomeTagline => 'The magic is within you.';

  @override
  String get welcomeAppleContinue => 'Apple ile Devam Et';

  @override
  String get welcomeGoogleContinue => 'Google ile Devam Et';

  @override
  String get moodGuideTitle => 'Mod Rehberi';

  @override
  String get moodAwarenessTitle => 'Duygusal Farkındalık';

  @override
  String get moodAwarenessDesc =>
      'Ruh halini seçmek hislerini somutlaştırır; bu, içsel dengeni bulmanın ve öz-farkındalığın ilk adımıdır.';

  @override
  String get moodCosmicTitle => 'Kozmik Frekans';

  @override
  String get moodCosmicDesc =>
      'Mod tekerinden seçtiğin her duygunun bir frekansı vardır. Ekranın aurası doğrudan senin hislerinle uyumlanır.';

  @override
  String get moodHowToTitle => 'Nasıl Kullanmalı?';

  @override
  String get moodHowToDesc =>
      'Sadece çarkı çevirip o anki ruh halini en iyi yansıtan ifadeyi seç. Duygunu yargılama, sadece hisset ve kabul et.';

  @override
  String get moodQuestionAlt => 'Bugün modun nasıl?';

  @override
  String get moodSpinHint => 'Çarkı çevir, ruh halini seç ✨';

  @override
  String get bentoCoffeeTitle => 'Kahve Falı';

  @override
  String get bentoCoffeeDesc => 'Telvelerin dili';

  @override
  String get bentoUnexplored => 'Bu alan henüz keşfedilmeyi bekliyor...';

  @override
  String get bentoSealed => 'Mühürlü';

  @override
  String get horoscopeDailyEnergy => 'Günün Enerjisi';

  @override
  String get horoscopeWestern => 'Batı Astrolojisi';

  @override
  String get horoscopeAsian => 'Asya Bilgeliği';

  @override
  String get horoscopeMayan => 'Maya Ruhu';

  @override
  String get shareSaved => 'Kaydedildi ✓';

  @override
  String get shareDownload => 'İndir';

  @override
  String get shareShare => 'Paylaş';

  @override
  String get shareStory => 'Hikaye';

  @override
  String get sharePost => 'Gönderi';

  @override
  String get shareCoffeeTitle => 'Kahve Falı';

  @override
  String get cookieLockedTitle => 'Bu özel kurabiye kilitli';

  @override
  String get cookieComingSoon => 'Yakında Satışa Çıkacak ✨';

  @override
  String get dreamWaitOrReturn =>
      'Burada bekleyebilir veya ana sayfaya dönebilirsin. Yorumun hazır olduğunda sana bildirim göndereceğiz ve \"Rüyalarım\" sekmesinden okuyabileceksin.';

  @override
  String get dreamReturnHome => 'Ana Sayfaya Dön';

  @override
  String get profileEditProfile => 'Profilini Düzenle';

  @override
  String get profileEditSubtitle => 'Ad, burç ve kişisel bilgilerini düzenle';

  @override
  String get profileSearchHint => 'Burç, şehir veya doğum tarihi ara...';

  @override
  String get profileStoreUnavailable => 'Mağaza bağlantısı şu an kurulamıyor.';

  @override
  String get profileMailNotFound =>
      'Mail uygulaması bulunamadı. support@crackandwish.com adresine yazabilirsiniz.';

  @override
  String get profileRitualCode => 'Ritüel Kodun';

  @override
  String get profileRitualDesc =>
      'Bu kod senin kişisel ritüel kimliğin. Arkadaşlarınla paylaşarak onları Baykuş Ağı\'na davet edebilirsin.';

  @override
  String get profileRitualCopied => 'Ritüel Kodun Kopyalandı ✨';

  @override
  String get profileRitualInfo => 'Arkadaşlarınla paylaş, birlikte keşfedin!';

  @override
  String get profileShareCode => 'Kodu Paylaş';

  @override
  String get profileDeleteAccount => 'Hesabı Sil';

  @override
  String get profileDeleteDesc =>
      'Tüm verilerin kalıcı olarak silinecek.\nBu işlem geri alınamaz.';

  @override
  String get profileDeleteCancel => 'Vazgeç';

  @override
  String get profileDeleteConfirm => 'Hesabı Sil';

  @override
  String get profileSignOut => 'Çıkış Yap';

  @override
  String get profileSignOutDesc =>
      'Hesabından güvenli çıkış yap.\nVerilerin korunur.';

  @override
  String get profileSignOutCancel => 'Vazgeç';

  @override
  String get profileSignOutConfirm => 'Çıkış Yap';

  @override
  String get profilePrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get profileTermsOfUse => 'Kullanım Koşulları';

  @override
  String get profileGetElite => 'Elite\'e Geç';

  @override
  String get profileGetEliteSubtitle => 'Farkındalığa giden kapı';

  @override
  String get profileCosmicProfile => 'Kozmik Profilim';

  @override
  String get profileCosmicSubtitle => 'Harita, Saat ve Konum Bilgileri';

  @override
  String get profileSectionAccount => 'Hesap';

  @override
  String get profileEmail => 'E-posta';

  @override
  String get profileNotificationSettings => 'Bildirim Tercihleri';

  @override
  String get profileRestorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get profileRestoreSuccess =>
      'Satın alımların başarıyla geri yüklendi!';

  @override
  String get profileRestoreFail => 'Geri yüklenecek satın alım bulunamadı.';

  @override
  String get profileHelp => 'Yardım';

  @override
  String get profileShare => 'Paylaş';

  @override
  String get profileRate => 'Değerlendir';

  @override
  String get profileVersion => 'Sürüm';

  @override
  String get profileCosmicName => 'Kozmik Adın';

  @override
  String get profileSealProfile => 'Mührü Onayla';

  @override
  String get profileChooseAvatar => 'Sihirli avatarını seç.';

  @override
  String get profileStrengthenBonds => 'Bağlarını Güçlendir';

  @override
  String get profileStrengthenBondsDesc =>
      'Kozmik evreni arkadaşlarınla büyüt.';

  @override
  String get profileEarnSoulStones => '+2 Ruh Taşı Kazan';

  @override
  String get profileCodeCopied => 'Kod kopyalandı!';

  @override
  String get profileNotifications => 'Bildirimler';

  @override
  String get profileSupportExperience => 'Destek & Deneyim';

  @override
  String get profileSeerNovice => 'Acemi Kahin';

  @override
  String get profileSeerApprentice => 'Çırak Kahin';

  @override
  String get profileSeer => 'Kahin';

  @override
  String get profileSeerWise => 'Bilge Kahin';

  @override
  String get profileSeerMaster => 'Usta Kahin';

  @override
  String get profileSeerCosmic => 'Kozmik Kahin';

  @override
  String get profileUploadFailed =>
      'Fotoğraf buluta yüklenemedi! Lütfen bağlantını kontrol et.';

  @override
  String get profileCropTitle => 'Kozmik Kesim';

  @override
  String get profileCropCancel => 'İptal';

  @override
  String get profileCropDone => 'Tamam';

  @override
  String get moderationAdultContent =>
      'Bu görselin enerjisi Kozmik evrenimizle uyumlu değil (Uygunsuz İçerik).';

  @override
  String get moderationViolence =>
      'Lütfen zihni yormayan, auranı yansıtan daha sakin bir avatar seç (Rahatsız Edici İçerik).';

  @override
  String get moderationTooLarge =>
      'Görselin kozmik ağı yoracak kadar büyük. Lütfen 5MB altı bir fotoğraf seç.';

  @override
  String get moderationInvalidFormat =>
      'Fotoğrafın sihirli parşömenimiz tarafından okunamadı, format bozuk.';

  @override
  String get moderationUnknown => 'Bilinmeyen bir kozmik dalgalanma oluştu.';

  @override
  String profileShareInvite(String code) {
    return 'Crack&Wish evrenine katıl! ✨\nRitüel Kodum: $code\n\nBu kodu girerek +1 Ruh Taşı, +50 Aura ve sürpriz bir Premium Kurabiye kazanabilirsin!\nhttps://crackandwish.com';
  }

  @override
  String get profileShareApp =>
      'Crack&Wish ile şansını keşfet! •✨\nKurabiye kır, tarot aç, rüya yorumla.\n\nhttps://crackandwish.com';

  @override
  String get profileEliteYouAre => 'Elite Büyücüsün';

  @override
  String get profileGoElite => 'Elite\'e Geç';

  @override
  String get profileEliteMystical => 'Mistik kapıları incele';

  @override
  String get profileEliteDoor => 'Farkındalığa giden kapı';

  @override
  String get profileMyCosmicProfile => 'Kozmik Profilim';

  @override
  String get profileCosmicDetails => 'Harita, Saat ve Konum Bilgileri';

  @override
  String get profileRestorePurchasesBtn => 'Satın Alımları Geri Yükle';

  @override
  String get profileRestoreSubtitle => 'Önceki satın alımlarını geri yükle';

  @override
  String get profileInviteFriends => 'Arkadaşlarını Davet Et';

  @override
  String get profileInviteFriendsDesc => 'Kozmik bağlar kur, birlikte kazan';

  @override
  String get cosmicChart => 'Kozmik Harita';

  @override
  String get cosmicWestern => 'BATI';

  @override
  String get cosmicAsian => 'ASYA';

  @override
  String get cosmicMayan => 'MAYA';

  @override
  String get cosmicRising => 'YÜKSELEN';

  @override
  String get cosmicArrivalDate => 'DÜNYAYA İNİŞ TARİHİ';

  @override
  String get cosmicBirthTime => 'DOĞUM SAATİ';

  @override
  String get cosmicTimeUnknown => 'Saat Bilinmiyor';

  @override
  String get cosmicBirthPlace => 'DOĞUM YERİ KOORDİNATLARI';

  @override
  String get cosmicCountry => 'Ülke';

  @override
  String get cosmicSelectCountry => 'Ülke Seç';

  @override
  String get cosmicCityDistrict => 'Şehir & İlçe & Köy';

  @override
  String get cosmicSelectDateFirst => 'Lütfen önce doğum tarihinizi seçin.';

  @override
  String cosmicLockedDays(int days) {
    return '$days Gün Sonra Değiştirilebilir';
  }

  @override
  String get cosmicSave => 'Kaydet';

  @override
  String get cosmicSearchLocation => 'Tam Konumu Ara';

  @override
  String get cosmicSearchHint => 'Köy, ilçe veya şehir yaz...';

  @override
  String get cosmicAddFreeText => 'Serbest metin olarak ekle';

  @override
  String get cosmicRequiresTime => 'Saat Gerekli';

  @override
  String get badgeReady => 'HAZIR';

  @override
  String get badgeNew => 'YENİ';

  @override
  String get paywallLegal =>
      'Aboneliğiniz, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Ödeme, satın alma onayında Apple ID / Google Play hesabınızdan tahsil edilir. Aboneliğinizi mağaza hesap ayarlarınızdan dilediğiniz zaman yönetebilirsiniz.';

  @override
  String get cosmicSelect => 'Seç';

  @override
  String get coffeeRelSingle => 'Yalnız Ruhum';

  @override
  String get coffeeRelInLove => 'Kalbim Dolu';

  @override
  String get coffeeRelEngaged => 'Nişanlıyım';

  @override
  String get coffeeRelMarried => 'Evliyim';

  @override
  String get coffeeRelComplicated => 'Karmaşık';

  @override
  String get coffeeFocusLove => 'Aşk ve Uyum';

  @override
  String get coffeeFocusCareer => 'Kariyer ve Maddiyat';

  @override
  String get coffeeFocusHealing => 'Şifa ve Huzur';

  @override
  String get coffeeFocusGeneral => 'Genel Gelecek';

  @override
  String get coffeeFocusSurprise => 'Sürpriz Olsun';

  @override
  String get coffeeMoodPeaceful => 'Huzurlu';

  @override
  String get coffeeMoodExcited => 'Heyecanlı';

  @override
  String get coffeeMoodAnxious => 'Endişeli';

  @override
  String get coffeeMoodIndecisive => 'Kararsız';

  @override
  String get coffeeMoodEnergetic => 'Enerjik';

  @override
  String get coffeeMoodMelancholic => 'Hüzünlü';

  @override
  String get coffeeAllPhotosRequired => 'Lütfen tüm fotoğrafları çekin!';

  @override
  String get coffeeNotEnoughStones => 'Yeterli Ruh Taşın yok!';

  @override
  String coffeeSoulStoneCount(int count) {
    return '$count Ruh Taşın var';
  }

  @override
  String get coffeeUseSoulStone => '1 Ruh Taşı Kullan';

  @override
  String get languageSettingsSubtitle => 'Uygulama dilini belirle';

  @override
  String get cosmicSearchHintShort => 'Ara...';

  @override
  String get cosmicAddThis => 'Bunu ekle';

  @override
  String get horoscopeWesternText =>
      'Yıldızlar kariyerin için hizalanıyor. Hızlı ve kararlı adımlar atmalısın.';

  @override
  String get horoscopeAsianText =>
      'Su elementi devrede. Sezgilerin çok güçlü, bugün sadece kalbini dinle.';

  @override
  String get horoscopeMayanText =>
      'Ton 4 aktif. Hayatında düzen kurmak ve plan yapmak için mükemmel bir gün.';

  @override
  String get horoscopeExplore => 'Keşfet';

  @override
  String get cookieDayCompleted => 'Gün Tamamlandı';

  @override
  String get cookieSeeYouTomorrow => 'Yarın yeni şanslarla tekrar buluşalım.';

  @override
  String get cookieRarityLegendary => 'Efsanevi';

  @override
  String get cookieRarityRare => 'Nadir';

  @override
  String get cookiePremiumCollection => 'Premium Koleksiyon';

  @override
  String cookiePurchaseBtn(String price) {
    return 'Satın Al ($price)';
  }

  @override
  String get cookieTapOutsideToClose => 'Kapatmak için dışına dokun';

  @override
  String get cookieAddedToCollection =>
      'Kurabiye başarıyla koleksiyonuna eklendi!';

  @override
  String get cookiePremiumFallback => 'Premium Kurabiye';

  @override
  String get dreamSoulStoneRequired => 'Ruh Taşı Gerekli';

  @override
  String get dreamSoulStoneRequiredDesc =>
      'Derin analiz için Ruh Taşı gereklidir.\n\nRuh Taşlarını Aura puanlarını dönüştürerek veya Elite abonelik ile kazanabilirsin.';

  @override
  String get dreamGetElite => 'Elite Abone Ol';

  @override
  String get dreamClinicalGateTitle => 'Klinik Analiz Kapısı';

  @override
  String dreamClinicalGateDesc(int soulStones) {
    return 'Mevcut Ruh Taşın: $soulStones\n\nBu klinik seviye derin psikolojik analiz için 1 Ruh Taşı harcanır.';
  }

  @override
  String get dreamUseOneStone => '1 Ruh Taşı Kullan';

  @override
  String get dreamDeepAnalysisBgPreparing =>
      'Derin Analiz arka planda hazırlanıyor. Tamamlandığında bildirim alacaksınız.';

  @override
  String get dreamYourSoulStones => 'Ruh Taşların';

  @override
  String dreamSoulStonesRemaining(int count) {
    return '$count Ruh Taşın var';
  }

  @override
  String get dreamSoulStonesEmpty => 'Ruh Taşın bitti';

  @override
  String get dreamRequiredForDeep => 'Derin Analiz için gerekli';

  @override
  String get dreamEachAnalysisCost => 'Her analiz 1 Ruh Taşı harcar';

  @override
  String get dreamEliteRefillActive =>
      'Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir';

  @override
  String get dreamEliteRefillPromo => 'Elite ile her gece 5 Ruh Taşı kazan';

  @override
  String get dreamWatchAd => 'Reklam İzle';

  @override
  String get dreamBgAnalyzing =>
      'Rüyanız arka planda analiz ediliyor. Tamamlandığında bildirim alacaksınız.';

  @override
  String get dreamDeepAnalysis => 'Derin Analiz';

  @override
  String get dreamDiscoverSecrets => 'Sırlarını keşfet';

  @override
  String get dreamDidYouKnow => 'Biliyor muydun?';

  @override
  String get dreamNeuroPsychAnalysis => 'NÖRO-PSİKOLOJİK ANALİZ';

  @override
  String get dreamYourDream => 'RÜYANIZ';

  @override
  String get dreamEmotionalProfile => 'Duygusal Profil';

  @override
  String get dreamEmotionalProfileSub =>
      'Rüya sırasındaki psikolojik katmanlarınız';

  @override
  String get dreamShadowSelf => 'Gölge Benlik';

  @override
  String get dreamShadowSelfSub =>
      'Bastırdığınız ve yüzleşmekten kaçındığınız yönler';

  @override
  String get dreamRecurringPatterns => 'Kalıplar ve Davranışlar';

  @override
  String get dreamRecurringPatternsSub =>
      'Hayatınızda sürekli tekrar eden psikolojik döngüler';

  @override
  String dreamSuggestedRitual(String title) {
    return 'Önerilen Ritüel: $title';
  }

  @override
  String get dreamSuggestedRitualSub =>
      'Bu rüyanın etkisini yönetmek için size özel eylem';

  @override
  String get dreamScienceNote => 'Bilimsel Not:';

  @override
  String get dreamWriteNewDream => 'Yeni Bir Rüya Yaz';

  @override
  String get dreamNoMonthDreams => 'Bu ay henüz rüya yazmadın ✨';

  @override
  String get dreamMysteriousDream => 'Gizemli Rüya';

  @override
  String get dreamStandardAnalysis => 'STANDART ANALİZ';

  @override
  String get dreamGeneralAnalysis => 'Genel Analiz';

  @override
  String get dreamPsychological => 'Psikolojik Örüntü';

  @override
  String get dreamSpiritual2 => 'Ruhsal / Sembolik';

  @override
  String get dreamAdvice => 'Öneri & Adım';

  @override
  String get dreamDeepenedInsights => 'Derinleştirilmiş Analiz';

  @override
  String get dreamEliteCreditsTitle => 'Elite Okuma Hakların';

  @override
  String get dreamReadingCreditsTitle => 'Okuma Hakların';

  @override
  String dreamCreditsRemaining(int count) {
    return '$count okuma hakkın var';
  }

  @override
  String get dreamDailyLimitReached => 'Bugünlük hakkın bitti';

  @override
  String get dreamZeroCredits => '0 okuma hakkın var';

  @override
  String dreamDailyPremiumReads(int count) {
    return 'Günlük $count Rüya Yorumu hakkı';
  }

  @override
  String get dreamNoAdsRequired => 'Reklam izleme zorunluluğu yok';

  @override
  String get dreamCreditsResetNightly => 'Haklar her gece sıfırlanır';

  @override
  String get dreamOneFreeDaily => 'Her gün 1 ücretsiz yorum';

  @override
  String dreamWatchAdsForCredits(int maxAds, int watched) {
    return 'Reklam ile ek $maxAds hak ($watched/$maxAds)';
  }

  @override
  String get dreamUnconsciousFrequencies => 'BİLİNÇDIŞI FREKANSLAR';

  @override
  String get dreamOrbEmotion => 'DUYGU YÜKÜ';

  @override
  String get dreamOrbEntropy => 'BELİRSİZLİK';

  @override
  String get dreamOrbActivity => 'BEYİN AKT.';

  @override
  String get dreamOrbResidue => 'YAKIN GEÇMİŞ';

  @override
  String get dreamHighConfidence => 'Yüksek Güven';

  @override
  String get dreamModerateConfidence => 'Orta Güven';

  @override
  String get dreamLowConfidence => 'Düşük Güven';

  @override
  String get dreamCoreThematicPattern => 'ANA TEMATİK ÖRÜNTÜ';

  @override
  String get dreamMetricEmotionalLoad => 'Duygusal\nYoğunluk';

  @override
  String get dreamMetricEmotionalLoadDesc =>
      'Rüyan sırasında beyninin duygusal merkezi (amigdala) ne kadar yoğun çalıştı. Yüksekse rüyanda güçlü duygular (huzur, mutluluk, korku, heyecan) yaşandı.';

  @override
  String get dreamMetricUncertaintyDesc =>
      'Rüyanda ne kadar mantıksız veya tutarsız olay yaşandı. Yüksekse mekanlar aniden değişti, olaylar mantığa aykırıydı.';

  @override
  String get dreamMetricRecentMemory => 'Yakın\nGeçmiş';

  @override
  String get dreamMetricRecentMemoryDesc =>
      'Rüyanın ne kadarı son günlerde yaşadığın gerçek olaylardan etkilenmiş. Yüksekse beynin günlük anıları rüyada işliyor.';

  @override
  String get dreamMetricAgency => 'Ajans /\nKontrol';

  @override
  String get dreamMetricAgencyDesc =>
      'Rüyanda olayları ne kadar kontrol edebildin. Düşükse sadece izledin, yüksekse kararlar aldın ve müdahale ettin.';

  @override
  String get dreamSeverityHigh => 'Yüksek';

  @override
  String get dreamSeverityNormal => 'Normal';

  @override
  String get dreamSeverityLow => 'Düşük';

  @override
  String get dreamCognitiveDistribution => 'BİLİŞSEL DAĞILIM';

  @override
  String get dreamTapToExpand => 'GENİŞLETMEK İÇİN DOKUN';

  @override
  String get dreamNeurologicalBasis => 'Nörolojik Taban';

  @override
  String get dreamEvidenceBase => 'BU SONUCA NEDEN VARDIK?';

  @override
  String get dreamRootCause => 'Rüyanın Gerçek Sebebi';

  @override
  String get dreamAbsolutely => 'Kesinlikle';

  @override
  String get dreamMaybe => 'Olabilir';

  @override
  String get dreamNotSure => 'Emin Değilim';

  @override
  String get dreamDreamEssence => 'RÜYANIN ÖZÜ';

  @override
  String get dreamClarifyingResponses => 'ANALİZİ NETLEŞTİREN YANITLAR';

  @override
  String get dreamCosmicRhythmSynced => 'Kozmik Ritmin Bağlandı';

  @override
  String get dreamCosmicRhythmSyncedDesc =>
      'Uyku döngünüze göre özel rüya bildirimleri alacaksınız.';

  @override
  String get dreamSyncSleepData => 'Uyku Verini Senkronize Et';

  @override
  String get dreamSyncSleepDataDesc =>
      'Tam uyandığın anı tespit edip en derin rüyanı sormasına izin ver.';

  @override
  String get dreamAwarenessFallback =>
      'Bu farkındalık yeni bir yolun başlangıcıdır. Şimdi yüzleşme zamanı.';

  @override
  String get dreamExtractingEssence => 'Rüyanın özü derleniyor...';

  @override
  String get dreamNoReasoning =>
      'Bu metrik için özel bir açıklama üretilmemiş.';

  @override
  String get dreamNotAnalyzable =>
      'Bunun bir rüyaya ait olduğuna emin misin?\nLütfen uykudayken zihninde canlanan gerçek bir sahneyi anlat.';

  @override
  String get owlTabFriends => 'Arkadaşlarım';

  @override
  String get owlTabConnections => 'Bağlantılar';

  @override
  String get owlTabInbox => 'Gelen Mektup';

  @override
  String get owlSearchCosmic => 'Kozmik evrende ara...';

  @override
  String get owlSearchFriends => 'Arkadaş ara...';

  @override
  String get owlPhoneContacts => 'Telefon Rehberin';

  @override
  String get owlNoOneFoundCosmic => 'Kozmik evrende kimse bulunamadı.';

  @override
  String get owlFoundInCosmic => 'Kozmik Evrende Bulunanlar';

  @override
  String get owlUnknownProfile => 'Bilinmeyen Profil';

  @override
  String owlFriendRequestSent(String name) {
    return '$name kişisine arkadaşlık isteği gönderildi!';
  }

  @override
  String get owlRequestSentStatus => 'Gönderildi';

  @override
  String get owlSendRequestAction => 'İstek Gönder';

  @override
  String get owlConnectContacts => 'Rehberini Bağla';

  @override
  String get owlConnectContactsDesc =>
      'Arkadaşlarını anında bul.\nRehberin ASLA sunucularda saklanmaz.';

  @override
  String get owlNoContactsFound => 'Crack&Wish Evreninde\nKimseyi Bulamadık';

  @override
  String get owlNoContactsFoundDesc =>
      'Onları davet ederek kozmik enerjiyi başlatabilirsin!';

  @override
  String get owlUnknown => 'Bilinmeyen';

  @override
  String get owlAppUserLabel => 'Crack&Wish Kullanıcısı';

  @override
  String get owlInContactsLabel => 'Rehberinde ekli';

  @override
  String get owlNoFriendsYet => 'Henüz arkadaşın yok';

  @override
  String get owlNoResultsFound => 'Sonuç bulunamadı';

  @override
  String get owlFriendRequests => 'Arkadaşlık İstekleri';

  @override
  String get owlFriendsHeader => 'Arkadaşların';

  @override
  String get owlAcceptAction => 'Kabul';

  @override
  String get owlRejectAction => 'Red';

  @override
  String get owlInviteReward => '+2 Ruh Taşı';

  @override
  String owlInviteShareMessage(String username) {
    return 'Karanlığı birlikte aydınlatalım! ✨\nCrack Wish\'e aşağıdaki davet bağlantımdan katıl, otomatik olarak birbirimize bağlanıp Başlangıç Ödülleri kazanalım!\n\nDavet Bağlantım:\nhttps://crackwish.com/invite/$username';
  }

  @override
  String get owlInviteFriends => 'Arkadaş Davet Et';

  @override
  String get owlInviteFriendsDesc => 'Kozmik evreni yansıt';

  @override
  String get owlNoLettersYet => 'Henüz mektup yok';

  @override
  String owlLetterSentNotification(String name) {
    return '$name mektup gönderdi...';
  }

  @override
  String get owlOnItsWay => 'Baykuş yolda 🕊️';

  @override
  String owlLetterCount(int count) {
    return '$count adet mektup';
  }

  @override
  String owlUnreadCountBadge(int count) {
    return '$count Yeni';
  }

  @override
  String get owlIUnderstand => 'Anladım';

  @override
  String get owlInviteHowTitle => 'Nasıl Davet Etmek İstersin?';

  @override
  String get owlInviteHowSubtitle =>
      'Bu kişiye kozmik anahtarını nasıl göndermek istiyorsun?';

  @override
  String get owlInviteSendAsMessage => 'Mesaj olarak gönder';

  @override
  String get owlInviteSMSSubtitle => 'Klasik mesaj ile yolla';

  @override
  String get owlInviteOtherApps => 'Diğer Uygulamalar';

  @override
  String get owlInviteOtherAppsSubtitle => 'Instagram, TikTok, X vb.';

  @override
  String get owlWhatsAppNotFound => 'WhatsApp bulunamadı';

  @override
  String get owlSMSNotFound => 'SMS uygulaması bulunamadı';

  @override
  String get owlDisconnectAction => 'Bağı Kes';

  @override
  String owlDisconnectConfirm(String name) {
    return '$name ile arandaki sihirli bağı koparmak istediğine emin misin?';
  }

  @override
  String get owlDisconnectConfirmButton => 'Evet, Kopar';

  @override
  String get owlCancel => 'İptal';

  @override
  String get owlSendMagic => 'Gönder (Tılsımlı)';

  @override
  String get owlSend => 'Gönder';

  @override
  String get owlCookieAdded => 'Kurabiye Eklendi';

  @override
  String get owlAddCookie => 'Kurabiye Ekle';

  @override
  String get owlNoCookiesInCollection => 'Koleksiyonunda kurabiye yok';

  @override
  String get owlWriteLetterHint => 'Mektubunu yaz...';

  @override
  String get owlSendCookie => 'Kurabiye At';

  @override
  String get zodiacMeasureHarmony => 'KOZMİK UYUMUNU ÖLÇ';

  @override
  String get zodiacDiscoverEnergy =>
      'Yıldızların rehberliğinde ikili enerjini keşfet';

  @override
  String get zodiacChooseFriend => 'ARKADAŞ SEÇ';

  @override
  String get zodiacPros => 'Avantajlar';

  @override
  String get zodiacCons => 'Zorluklar';

  @override
  String get zodiacAdvice => 'Tavsiye';

  @override
  String get zodiacDailyWhisperSubtitle =>
      'Bugünün fısıltısını hisset ve\nruhsal portrenin sırlarını çöz.';

  @override
  String get zodiacDailyWhisperHeadline => 'Bugünün mesajı & ruhsal portre';

  @override
  String get zodiacOpenGuide => 'Rehberi Arala';

  @override
  String get zodiacNoFriends => 'Henüz arkadaşın yok';

  @override
  String get zodiacSelect => 'SEÇ';

  @override
  String get zodiacQuestCompleted => 'Serüven Tamamlandı';

  @override
  String get zodiacQuestCompletedSubtitle =>
      'Evrenin ritmiyle tamamen uyumlandın.';

  @override
  String get zodiacRewardAura => 'Kazanılan Ödül:\n+4 AURA';

  @override
  String get zodiacStartNewQuest => 'YENİ SERÜVENE BAŞLA';

  @override
  String zodiacDailyQuestTitle(int days) {
    return '$days GÜNLÜK SERÜVEN';
  }

  @override
  String zodiacDailyQuestDesc(String weakness) {
    return '\"$weakness\" Zaafını Yık';
  }

  @override
  String zodiacQuestDayProgress(int current, int total) {
    return 'GÜN $current / $total';
  }

  @override
  String get zodiacQuestTodayDiscovery => 'GÜNÜN KEŞFİ';

  @override
  String get zodiacQuestCompletedToday => 'BUGÜN TAMAMLANDI';

  @override
  String get zodiacQuestCompleteNow => 'SERÜVENİ TAMAMLA';

  @override
  String get zodiacQuestMarkCompleted => 'BUGÜNÜ TAMAMLADIM';

  @override
  String get zodiacLoveHarmony => 'AŞK UYUMU';

  @override
  String get zodiacFriendshipHarmony => 'ARKADAŞLIK';

  @override
  String get zodiacCommunicationHarmony => 'İLETİŞİM & ZİHİN';

  @override
  String get zodiacWorkHarmony => 'ORTAK ÇALIŞMA';

  @override
  String get zodiacAdventureHarmony => 'MACERA & EĞLENCE';

  @override
  String get zodiacViralDynamics => 'VİRAL DİNAMİKLER';

  @override
  String get zodiacDeepSynastryMap => 'DERİN SİNASTRİ HARİTASI';

  @override
  String zodiacSynastrySubtitle1(String name) {
    return '$name ile arandaki uyum sadece Güneş burçlarıyla sınırlandırılmadı.';
  }

  @override
  String get zodiacSynastrySubtitle2 =>
      'Kozmik algoritma, gizlilik esasına dayanarak her iki tarafın da astrolojik doğum haritalarını, Ay ve Yükselen evrelerini perde arkasında çaprazlayarak bu analizi tamamen size özel hale getirdi.';

  @override
  String get zodiacDailyWhisperTitle => 'Günün Fısıltısı';

  @override
  String get zodiacChooseSign => 'BURÇ SEÇ';

  @override
  String get zodiacCosmicGuide => 'KOZMİK REHBERİN';

  @override
  String get zodiacNew => 'YENİ';

  @override
  String get zodiacCosmicHarmonyTitle => 'KOZMİK UYUM';

  @override
  String get zodiacAwesome => 'HARİKA';

  @override
  String get zodiacSpiritPortrait => 'Ruhsal Portre';

  @override
  String get onboardingFeatureStepTitle => 'Seni Neler Bekliyor?';

  @override
  String get onboardingFeatureStepSub =>
      'Evrenin fısıltılarına kulak verip kaderini keşfetmeye hazır mısın?';

  @override
  String get onboardingNameStepTitle => 'Seni Tanıyalım';

  @override
  String get onboardingNameStepSub =>
      'Ruh eşlerinin seni bulabilmesi için profilini oluştur ve kozmik kimliğini belirle.';

  @override
  String get onboardingDateStepTitle => 'Kozmik Koordinat';

  @override
  String get onboardingDateStepSub =>
      'Astrolojik haritanın temeli için doğduğun anı seç.';

  @override
  String get onboardingFocusStepTitle => 'Kalbinin Pusulası';

  @override
  String get onboardingFocusStepSub => 'Niyetini belirle, yolunu çizelim.';

  @override
  String get onboardingDreamStepTitle => 'Bilinçaltının Sesi';

  @override
  String get onboardingDreamStepSub => 'Rüyaların sana nasıl ulaşıyor?';

  @override
  String get onboardingSleepStepTitle => 'İçsel Pusulan';

  @override
  String get onboardingSleepStepSub =>
      'Hayatındaki kadersel dönüm noktalarında yolunu nasıl bulursun?';

  @override
  String get onboardingFeatureAstrology => 'Sana Özel Astroloji Haritası';

  @override
  String get onboardingFeatureTarot => 'Yol Gösterici Tarot Serüveni';

  @override
  String get onboardingFeatureCoffee =>
      'Telvelerde Gizlenen Kadim Kahve Falı Sırları';

  @override
  String get onboardingFeatureDream => 'Bilinçaltı Rüya Analizleri';

  @override
  String get onboardingFeatureZodiac => 'Mistik Çin & Maya Uyumları';

  @override
  String get onboardingWelcomeTagline =>
      'Bugün umutlarım hayallerimden daha büyük.';

  @override
  String get onboardingFinalTagline =>
      'Kozmik haritanı güvenceye almak için tıkla.';
}
