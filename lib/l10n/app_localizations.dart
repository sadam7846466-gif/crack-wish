import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Crack&Wish'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seç'**
  String get selectLanguage;

  /// No description provided for @systemLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get systemLanguage;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// Selected language label
  ///
  /// In tr, this message translates to:
  /// **'Seçili: {value}'**
  String languageValue(Object value);

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navCollection.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon'**
  String get navCollection;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @dailyCookieTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün Kurabiyesi'**
  String get dailyCookieTitle;

  /// No description provided for @dailyCookieSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şansını denemek için dokun'**
  String get dailyCookieSubtitle;

  /// No description provided for @luckyNumber.
  ///
  /// In tr, this message translates to:
  /// **'Şanslı Sayı'**
  String get luckyNumber;

  /// No description provided for @luckyColor.
  ///
  /// In tr, this message translates to:
  /// **'Şanslı Renk'**
  String get luckyColor;

  /// No description provided for @luckLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şans'**
  String get luckLabel;

  /// No description provided for @todayFortune.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün Şansı'**
  String get todayFortune;

  /// No description provided for @shareButton.
  ///
  /// In tr, this message translates to:
  /// **'📸 Paylaş'**
  String get shareButton;

  /// Share text for fortune
  ///
  /// In tr, this message translates to:
  /// **'{emoji} {title}\n\n{meaning}\n\nŞanslı Sayı: {number}\nŞanslı Renk: {color}\nŞans: {percent}%\n\nŞans Kurabiyesi uygulamasından 🥠'**
  String fortuneShareText(
    Object emoji,
    Object title,
    Object meaning,
    Object number,
    Object color,
    Object percent,
  );

  /// No description provided for @themeSelectTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tasarım Seç'**
  String get themeSelectTitle;

  /// Theme selected snackbar
  ///
  /// In tr, this message translates to:
  /// **'Tasarım seçildi: {value}'**
  String themeSelected(Object value);

  /// No description provided for @themeGalleryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema Galerisi'**
  String get themeGalleryTitle;

  /// No description provided for @themeGalleryOpen.
  ///
  /// In tr, this message translates to:
  /// **'Tema listesine git'**
  String get themeGalleryOpen;

  /// No description provided for @themeGalleryLimited.
  ///
  /// In tr, this message translates to:
  /// **'Tema galerisi şu an iki seçenekle sınırlı'**
  String get themeGalleryLimited;

  /// No description provided for @statCookies.
  ///
  /// In tr, this message translates to:
  /// **'Kurabiye'**
  String get statCookies;

  /// No description provided for @statStreakDays.
  ///
  /// In tr, this message translates to:
  /// **'Gün seri'**
  String get statStreakDays;

  /// No description provided for @statDreams.
  ///
  /// In tr, this message translates to:
  /// **'Rüya'**
  String get statDreams;

  /// No description provided for @statMood.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali'**
  String get statMood;

  /// No description provided for @statTheme.
  ///
  /// In tr, this message translates to:
  /// **'Bugün...'**
  String get statTheme;

  /// No description provided for @statCollection.
  ///
  /// In tr, this message translates to:
  /// **'Kurabiyem'**
  String get statCollection;

  /// No description provided for @statTalisman.
  ///
  /// In tr, this message translates to:
  /// **'Tılsım'**
  String get statTalisman;

  /// No description provided for @moodGood.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get moodGood;

  /// No description provided for @moodSad.
  ///
  /// In tr, this message translates to:
  /// **'Üzgün'**
  String get moodSad;

  /// No description provided for @moodBad.
  ///
  /// In tr, this message translates to:
  /// **'Kötü'**
  String get moodBad;

  /// No description provided for @moodHappy.
  ///
  /// In tr, this message translates to:
  /// **'Mutlu'**
  String get moodHappy;

  /// No description provided for @moodGreat.
  ///
  /// In tr, this message translates to:
  /// **'Harika'**
  String get moodGreat;

  /// No description provided for @shortcutCollection.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon'**
  String get shortcutCollection;

  /// No description provided for @shortcutHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get shortcutHistory;

  /// No description provided for @shortcutFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get shortcutFavorites;

  /// No description provided for @sectionShortcuts.
  ///
  /// In tr, this message translates to:
  /// **'Kısayollar'**
  String get sectionShortcuts;

  /// No description provided for @sectionActivity.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite'**
  String get sectionActivity;

  /// No description provided for @menuBadges.
  ///
  /// In tr, this message translates to:
  /// **'Rozetler'**
  String get menuBadges;

  /// No description provided for @menuBadgesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar ve seviyeler'**
  String get menuBadgesSubtitle;

  /// No description provided for @menuSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get menuSettings;

  /// No description provided for @menuSettingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim, tema, gizlilik'**
  String get menuSettingsSubtitle;

  /// No description provided for @menuHelpAbout.
  ///
  /// In tr, this message translates to:
  /// **'Yardım & Hakkında'**
  String get menuHelpAbout;

  /// No description provided for @menuHelpAboutSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'SSS ve sürüm bilgisi'**
  String get menuHelpAboutSubtitle;

  /// No description provided for @menuShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get menuShare;

  /// No description provided for @menuShareSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Profili arkadaşlarınla paylaş'**
  String get menuShareSubtitle;

  /// No description provided for @activityTarotOpenedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarot falı açıldı'**
  String get activityTarotOpenedTitle;

  /// No description provided for @activityTarotOpenedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugün • Kart: Yıldız'**
  String get activityTarotOpenedSubtitle;

  /// Cookies opened activity title
  ///
  /// In tr, this message translates to:
  /// **'{count} kurabiye kırıldı'**
  String activityCookiesOpenedTitle(Object count);

  /// No description provided for @activityCookiesOpenedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Dün • Yeni mesajlar açıldı'**
  String get activityCookiesOpenedSubtitle;

  /// No description provided for @activityDreamSavedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüya yorumu kaydedildi'**
  String get activityDreamSavedTitle;

  /// No description provided for @activityDreamSavedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'2 gün önce'**
  String get activityDreamSavedSubtitle;

  /// No description provided for @profileUserTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get profileUserTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Daha az gürültü, daha çok sen'**
  String get profileSubtitle;

  /// No description provided for @tagTarot.
  ///
  /// In tr, this message translates to:
  /// **'Tarot'**
  String get tagTarot;

  /// No description provided for @tagDream.
  ///
  /// In tr, this message translates to:
  /// **'Rüya'**
  String get tagDream;

  /// No description provided for @tagCollection.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon'**
  String get tagCollection;

  /// No description provided for @zodiacTitle.
  ///
  /// In tr, this message translates to:
  /// **'⭐ Burç Yorumu'**
  String get zodiacTitle;

  /// Zodiac daily title
  ///
  /// In tr, this message translates to:
  /// **'{name} Burcu - Günlük Yorum'**
  String zodiacDailyTitle(Object name);

  /// No description provided for @zodiacDailyBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta aşk konusunda şanslısın! Kariyer fırsatları kapında, gözlerini aç. Enerjin yüksek, bunu değerlendir. Yeni projeler için mükemmel bir zaman. İletişim becerilerin zirvede, bunu kullan.'**
  String get zodiacDailyBody;

  /// No description provided for @zodiacLove.
  ///
  /// In tr, this message translates to:
  /// **'Aşk'**
  String get zodiacLove;

  /// No description provided for @zodiacCareer.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer'**
  String get zodiacCareer;

  /// No description provided for @zodiacMoney.
  ///
  /// In tr, this message translates to:
  /// **'Para'**
  String get zodiacMoney;

  /// No description provided for @zodiacHealth.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get zodiacHealth;

  /// No description provided for @collectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonun'**
  String get collectionTitle;

  /// No description provided for @collectionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük ritüelin izleri ve ödülleri'**
  String get collectionSubtitle;

  /// No description provided for @collectionNotYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz değil'**
  String get collectionNotYet;

  /// No description provided for @collectionFirstTime.
  ///
  /// In tr, this message translates to:
  /// **'İlk defa'**
  String get collectionFirstTime;

  /// No description provided for @collectionTotalOpened.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get collectionTotalOpened;

  /// No description provided for @collectionCookieDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu kurabiye ritüeline şans ve küçük sürprizler katıyor. Daha çok açtıkça Koleksiyonun güçlenir.'**
  String get collectionCookieDescription;

  /// No description provided for @collectionSummaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon Özeti'**
  String get collectionSummaryTitle;

  /// No description provided for @collectionSummaryTypes.
  ///
  /// In tr, this message translates to:
  /// **'Farklı tür'**
  String get collectionSummaryTypes;

  /// No description provided for @collectionSummaryTotalOpened.
  ///
  /// In tr, this message translates to:
  /// **'Toplam açılan'**
  String get collectionSummaryTotalOpened;

  /// No description provided for @collectionSummaryRare.
  ///
  /// In tr, this message translates to:
  /// **'Nadir'**
  String get collectionSummaryRare;

  /// No description provided for @collectionSummaryFooter.
  ///
  /// In tr, this message translates to:
  /// **'Her kurabiyenin bir hikâyesi var. Ne kadar çok açarsan, o kadar zenginleşir.'**
  String get collectionSummaryFooter;

  /// No description provided for @rarityAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get rarityAll;

  /// No description provided for @rarityCommon.
  ///
  /// In tr, this message translates to:
  /// **'Sık'**
  String get rarityCommon;

  /// No description provided for @rarityRare.
  ///
  /// In tr, this message translates to:
  /// **'Nadir'**
  String get rarityRare;

  /// No description provided for @rarityLegendary.
  ///
  /// In tr, this message translates to:
  /// **'Efsanevi'**
  String get rarityLegendary;

  /// No description provided for @collectionUndiscovered.
  ///
  /// In tr, this message translates to:
  /// **'Keşfedilmedi'**
  String get collectionUndiscovered;

  /// No description provided for @collectionNotFoundYet.
  ///
  /// In tr, this message translates to:
  /// **'Şansın seni buraya getirmedi… henüz.'**
  String get collectionNotFoundYet;

  /// No description provided for @collectionEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kurabiye açmadın'**
  String get collectionEmptyTitle;

  /// Empty collection subtitle
  ///
  /// In tr, this message translates to:
  /// **'{count} farklı kurabiye seni bekliyor. Bugünün kurabiyesini aç, koleksiyonunu başlat.'**
  String collectionEmptySubtitle(Object count);

  /// No description provided for @discoverTitle.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get discoverTitle;

  /// No description provided for @discoverSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni özellikler keşfet'**
  String get discoverSubtitle;

  /// No description provided for @discoverCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get discoverCategories;

  /// No description provided for @categoryTarotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarot Falı'**
  String get categoryTarotTitle;

  /// No description provided for @categoryTarotDesc.
  ///
  /// In tr, this message translates to:
  /// **'3 Kartlı Tarot'**
  String get categoryTarotDesc;

  /// No description provided for @categoryDreamTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüya Tabiri'**
  String get categoryDreamTitle;

  /// No description provided for @categoryDreamDesc.
  ///
  /// In tr, this message translates to:
  /// **'Rüyalarının sırrını çöz'**
  String get categoryDreamDesc;

  /// No description provided for @categoryZodiacTitle.
  ///
  /// In tr, this message translates to:
  /// **'Burç Yorumu'**
  String get categoryZodiacTitle;

  /// No description provided for @categoryZodiacDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızların mesajı'**
  String get categoryZodiacDesc;

  /// No description provided for @categoryPersonalityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişilik Testi'**
  String get categoryPersonalityTitle;

  /// No description provided for @categoryPersonalityDesc.
  ///
  /// In tr, this message translates to:
  /// **'16 Kişilik'**
  String get categoryPersonalityDesc;

  /// No description provided for @discoverDailySuggestionTitle.
  ///
  /// In tr, this message translates to:
  /// **'GÜNÜN ÖNERİSİ'**
  String get discoverDailySuggestionTitle;

  /// No description provided for @discoverDailySuggestionHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Dün gece bir rüya gördün mü?'**
  String get discoverDailySuggestionHeadline;

  /// No description provided for @discoverDailySuggestionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hemen yorumla, anlamını öğren!'**
  String get discoverDailySuggestionSubtitle;

  /// No description provided for @dailySuggestionDreamHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Dün gece bir rüya gördün mü?'**
  String get dailySuggestionDreamHeadline;

  /// No description provided for @dailySuggestionDreamSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hemen yorumla, anlamını öğren!'**
  String get dailySuggestionDreamSubtitle;

  /// No description provided for @dailySuggestionTarotHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Bugün tarot falına baktın mı?'**
  String get dailySuggestionTarotHeadline;

  /// No description provided for @dailySuggestionTarotSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'3 kart seç, günlük mesajını gör!'**
  String get dailySuggestionTarotSubtitle;

  /// No description provided for @dailySuggestionZodiacHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Burç yorumunu kontrol ettin mi?'**
  String get dailySuggestionZodiacHeadline;

  /// No description provided for @dailySuggestionZodiacSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün enerjisini hemen öğren!'**
  String get dailySuggestionZodiacSubtitle;

  /// No description provided for @dailySuggestionCoffeeHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Bugün kahve içtin mi?'**
  String get dailySuggestionCoffeeHeadline;

  /// No description provided for @dailySuggestionCoffeeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Fincanını kapat, falına bakalım!'**
  String get dailySuggestionCoffeeSubtitle;

  /// No description provided for @dailySuggestionAllDoneHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün ritüelleri tamam!'**
  String get dailySuggestionAllDoneHeadline;

  /// No description provided for @dailySuggestionAllDoneSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yarın için geri gel, yeni içerikler gelecek.'**
  String get dailySuggestionAllDoneSubtitle;

  /// No description provided for @discoverFeaturedTag.
  ///
  /// In tr, this message translates to:
  /// **'ÖNE ÇIKAN'**
  String get discoverFeaturedTag;

  /// No description provided for @discoverFeaturedTitle.
  ///
  /// In tr, this message translates to:
  /// **'3 Kartlı Tarot Falı'**
  String get discoverFeaturedTitle;

  /// No description provided for @discoverFeaturedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş, şimdi ve geleceğini keşfet'**
  String get discoverFeaturedSubtitle;

  /// No description provided for @ctaStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get ctaStart;

  /// No description provided for @homeGreeting.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba! 👋'**
  String get homeGreeting;

  /// No description provided for @homeFeeling.
  ///
  /// In tr, this message translates to:
  /// **'Bugün nasıl hissediyorsun?'**
  String get homeFeeling;

  /// No description provided for @quoteOfDayText.
  ///
  /// In tr, this message translates to:
  /// **'Bugün yapabileceğin en küçük adım, yarının en büyük zaferine götürür.'**
  String get quoteOfDayText;

  /// No description provided for @quoteOfDaySource.
  ///
  /// In tr, this message translates to:
  /// **'— Günün Sözü'**
  String get quoteOfDaySource;

  /// No description provided for @dailyHoroscopeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koç Burcu'**
  String get dailyHoroscopeTitle;

  /// No description provided for @dailyHoroscopeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü Yorum'**
  String get dailyHoroscopeSubtitle;

  /// No description provided for @dailyHoroscopeBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta aşk konusunda şanslısın! Kariyer fırsatları kapında, gözlerini aç. Enerjin yüksek, bunu değerlendir.'**
  String get dailyHoroscopeBody;

  /// No description provided for @aries.
  ///
  /// In tr, this message translates to:
  /// **'Koç'**
  String get aries;

  /// No description provided for @bentoTarotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarot'**
  String get bentoTarotTitle;

  /// No description provided for @bentoTarotDesc.
  ///
  /// In tr, this message translates to:
  /// **'Geleceğini gör'**
  String get bentoTarotDesc;

  /// No description provided for @bentoTarotBadge.
  ///
  /// In tr, this message translates to:
  /// **'POPÜLER'**
  String get bentoTarotBadge;

  /// No description provided for @bentoDreamTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüya'**
  String get bentoDreamTitle;

  /// No description provided for @bentoDreamDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bilinçaltını keşfet'**
  String get bentoDreamDesc;

  /// No description provided for @bentoDreamBadge.
  ///
  /// In tr, this message translates to:
  /// **'YENİ'**
  String get bentoDreamBadge;

  /// No description provided for @bentoMotivationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mod'**
  String get bentoMotivationTitle;

  /// No description provided for @bentoMotivationDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ruh halini keşfet'**
  String get bentoMotivationDesc;

  /// No description provided for @bentoMotivationBadge.
  ///
  /// In tr, this message translates to:
  /// **'GÜNLÜK'**
  String get bentoMotivationBadge;

  /// No description provided for @bentoZodiacTitle.
  ///
  /// In tr, this message translates to:
  /// **'Burç'**
  String get bentoZodiacTitle;

  /// No description provided for @bentoZodiacDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızların mesajı'**
  String get bentoZodiacDesc;

  /// No description provided for @bentoZodiacBadge.
  ///
  /// In tr, this message translates to:
  /// **'GÜNLÜK'**
  String get bentoZodiacBadge;

  /// No description provided for @moodQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Bugün nasılsın?'**
  String get moodQuestion;

  /// No description provided for @dreamTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanı Anlat'**
  String get dreamTitle;

  /// No description provided for @dreamTabNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Rüya'**
  String get dreamTabNew;

  /// No description provided for @dreamTabHistory.
  ///
  /// In tr, this message translates to:
  /// **'Rüyalarım'**
  String get dreamTabHistory;

  /// No description provided for @dreamAnalyzeButton.
  ///
  /// In tr, this message translates to:
  /// **'Rüyayı Yorumla'**
  String get dreamAnalyzeButton;

  /// No description provided for @dreamAnalyzeEstimate.
  ///
  /// In tr, this message translates to:
  /// **'~ 5 sn sürer'**
  String get dreamAnalyzeEstimate;

  /// No description provided for @dreamInterpretationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanın Yorumu'**
  String get dreamInterpretationTitle;

  /// No description provided for @dreamNoHistory.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı rüyan yok'**
  String get dreamNoHistory;

  /// No description provided for @dreamDefaultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüya'**
  String get dreamDefaultTitle;

  /// No description provided for @dreamSpiritual.
  ///
  /// In tr, this message translates to:
  /// **'Spiritüel'**
  String get dreamSpiritual;

  /// No description provided for @dreamEnriched.
  ///
  /// In tr, this message translates to:
  /// **'Derinleştirilmiş Yorum'**
  String get dreamEnriched;

  /// No description provided for @dreamEnriching.
  ///
  /// In tr, this message translates to:
  /// **'Derinleştiriliyor...'**
  String get dreamEnriching;

  /// No description provided for @dreamEnrich.
  ///
  /// In tr, this message translates to:
  /// **'Derinleştir'**
  String get dreamEnrich;

  /// No description provided for @dreamShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get dreamShare;

  /// No description provided for @dreamAnalyzing.
  ///
  /// In tr, this message translates to:
  /// **'Rüya analiz ediliyor...'**
  String get dreamAnalyzing;

  /// No description provided for @dreamAnalysisFailed.
  ///
  /// In tr, this message translates to:
  /// **'Şu anda yorum oluşturulamadı.'**
  String get dreamAnalysisFailed;

  /// No description provided for @dreamClarifyThreat.
  ///
  /// In tr, this message translates to:
  /// **'Rüyada tehdit veya korku hissi var mıydı?'**
  String get dreamClarifyThreat;

  /// No description provided for @dreamClarifyFamiliar.
  ///
  /// In tr, this message translates to:
  /// **'Bu sahne sana geçmişten tanıdık mıydı?'**
  String get dreamClarifyFamiliar;

  /// No description provided for @dreamClarifyEscape.
  ///
  /// In tr, this message translates to:
  /// **'Rüyada hareket/kaçış hissi var mıydı?'**
  String get dreamClarifyEscape;

  /// No description provided for @dreamClarifyAnxious.
  ///
  /// In tr, this message translates to:
  /// **'Rüyada tedirginlik veya tehdit hissi var mıydı?'**
  String get dreamClarifyAnxious;

  /// No description provided for @dreamUnsure.
  ///
  /// In tr, this message translates to:
  /// **'Emin değilim'**
  String get dreamUnsure;

  /// No description provided for @dreamYes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get dreamYes;

  /// No description provided for @dreamNo.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get dreamNo;

  /// No description provided for @dreamGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel Rüya'**
  String get dreamGeneral;

  /// Share text for dream analysis
  ///
  /// In tr, this message translates to:
  /// **'Rüya Başlığı: {title}\nTarih: {date}\n\nRüya: {text}\n\nGenel: {general}\nPsikolojik: {psychology}\nSpiritüel: {spiritual}\nTavsiye: {advice}\n\n#VLucky #Rüya'**
  String dreamShareText(
    Object title,
    Object date,
    Object text,
    Object general,
    Object psychology,
    Object spiritual,
    Object advice,
  );

  /// No description provided for @scientificTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bilimsel Rüya Analizi'**
  String get scientificTitle;

  /// No description provided for @scientificDreamPromptTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanı Anlat'**
  String get scientificDreamPromptTitle;

  /// No description provided for @scientificDreamHint.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanı hatırladığın kadar yaz...'**
  String get scientificDreamHint;

  /// No description provided for @scientificEmotionQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Uyandığında nasıl hissettin?'**
  String get scientificEmotionQuestion;

  /// No description provided for @scientificEmotionHint.
  ///
  /// In tr, this message translates to:
  /// **'Tek bir duygu seç'**
  String get scientificEmotionHint;

  /// No description provided for @scientificClarityQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Rüya ne kadar netti?'**
  String get scientificClarityQuestion;

  /// No description provided for @scientificDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'Bu analiz psikoloji ve nörobilim araştırmalarına dayanmaktadır. Kesin veya öngörücü sonuçlar sunmaz.'**
  String get scientificDisclaimer;

  /// No description provided for @scientificLoading.
  ///
  /// In tr, this message translates to:
  /// **'REM uykusu ve nörobilim temelinde değerlendiriliyor'**
  String get scientificLoading;

  /// No description provided for @scientificResultsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanın Yorumu'**
  String get scientificResultsTitle;

  /// No description provided for @scientificRecentPastTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakın Geçmiş Etkileri'**
  String get scientificRecentPastTitle;

  /// No description provided for @scientificSaved.
  ///
  /// In tr, this message translates to:
  /// **'Rüya kaydedildi'**
  String get scientificSaved;

  /// No description provided for @scientificSaveButton.
  ///
  /// In tr, this message translates to:
  /// **'Rüyayı Kaydet'**
  String get scientificSaveButton;

  /// No description provided for @cookieSpringWreath.
  ///
  /// In tr, this message translates to:
  /// **'Bahar Çelengi'**
  String get cookieSpringWreath;

  /// No description provided for @cookieLuckyClover.
  ///
  /// In tr, this message translates to:
  /// **'Şanslı Yonca'**
  String get cookieLuckyClover;

  /// No description provided for @cookieRoyalHearts.
  ///
  /// In tr, this message translates to:
  /// **'Kraliyet Kalpleri'**
  String get cookieRoyalHearts;

  /// No description provided for @cookieEvilEye.
  ///
  /// In tr, this message translates to:
  /// **'Nazar'**
  String get cookieEvilEye;

  /// No description provided for @cookiePizzaParty.
  ///
  /// In tr, this message translates to:
  /// **'Pizza Partisi'**
  String get cookiePizzaParty;

  /// No description provided for @cookieSakuraBloom.
  ///
  /// In tr, this message translates to:
  /// **'Sakura'**
  String get cookieSakuraBloom;

  /// No description provided for @cookieBluePorcelain.
  ///
  /// In tr, this message translates to:
  /// **'Mavi Porselen'**
  String get cookieBluePorcelain;

  /// No description provided for @cookiePinkBlossom.
  ///
  /// In tr, this message translates to:
  /// **'Pembe Çiçek'**
  String get cookiePinkBlossom;

  /// No description provided for @cookieFortuneCat.
  ///
  /// In tr, this message translates to:
  /// **'Şans Kedisi'**
  String get cookieFortuneCat;

  /// No description provided for @cookieWildflower.
  ///
  /// In tr, this message translates to:
  /// **'Kır Çiçeği'**
  String get cookieWildflower;

  /// No description provided for @cookieCupidRibbon.
  ///
  /// In tr, this message translates to:
  /// **'Aşk Kurdelesi'**
  String get cookieCupidRibbon;

  /// No description provided for @cookiePandaBamboo.
  ///
  /// In tr, this message translates to:
  /// **'Panda'**
  String get cookiePandaBamboo;

  /// No description provided for @cookieRamadanCute.
  ///
  /// In tr, this message translates to:
  /// **'Ramazan'**
  String get cookieRamadanCute;

  /// No description provided for @cookieEnchantedForest.
  ///
  /// In tr, this message translates to:
  /// **'Büyülü Orman'**
  String get cookieEnchantedForest;

  /// No description provided for @cookieGoldenArabesque.
  ///
  /// In tr, this message translates to:
  /// **'Altın Arabesk'**
  String get cookieGoldenArabesque;

  /// No description provided for @cookieMidnightMosaic.
  ///
  /// In tr, this message translates to:
  /// **'Gece Mozaiği'**
  String get cookieMidnightMosaic;

  /// No description provided for @cookiePearlLace.
  ///
  /// In tr, this message translates to:
  /// **'İnci Dantel'**
  String get cookiePearlLace;

  /// No description provided for @cookieGoldenSakura.
  ///
  /// In tr, this message translates to:
  /// **'Altın Sakura'**
  String get cookieGoldenSakura;

  /// No description provided for @cookieDragonPhoenix.
  ///
  /// In tr, this message translates to:
  /// **'Ejderha & Anka'**
  String get cookieDragonPhoenix;

  /// No description provided for @cookieGoldBeasts.
  ///
  /// In tr, this message translates to:
  /// **'Altın Canavarlar'**
  String get cookieGoldBeasts;

  /// No description provided for @emotionAnxiety.
  ///
  /// In tr, this message translates to:
  /// **'Kaygılı'**
  String get emotionAnxiety;

  /// No description provided for @emotionFear.
  ///
  /// In tr, this message translates to:
  /// **'Korkmuş'**
  String get emotionFear;

  /// No description provided for @emotionCalm.
  ///
  /// In tr, this message translates to:
  /// **'Huzurlu'**
  String get emotionCalm;

  /// No description provided for @emotionHappy.
  ///
  /// In tr, this message translates to:
  /// **'Mutlu'**
  String get emotionHappy;

  /// No description provided for @emotionSad.
  ///
  /// In tr, this message translates to:
  /// **'Üzgün'**
  String get emotionSad;

  /// No description provided for @emotionConfusion.
  ///
  /// In tr, this message translates to:
  /// **'Belirsiz'**
  String get emotionConfusion;

  /// No description provided for @emotionSurprise.
  ///
  /// In tr, this message translates to:
  /// **'Şaşkın'**
  String get emotionSurprise;

  /// No description provided for @dreamMoodQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Uyandığında nasıl hissettin?'**
  String get dreamMoodQuestion;

  /// No description provided for @dreamMetricEmotional.
  ///
  /// In tr, this message translates to:
  /// **'Duygusal Yük'**
  String get dreamMetricEmotional;

  /// No description provided for @dreamMetricUncertainty.
  ///
  /// In tr, this message translates to:
  /// **'Belirsizlik'**
  String get dreamMetricUncertainty;

  /// No description provided for @dreamMetricRecentPast.
  ///
  /// In tr, this message translates to:
  /// **'Yakın Geçmiş'**
  String get dreamMetricRecentPast;

  /// No description provided for @dreamMetricBrain.
  ///
  /// In tr, this message translates to:
  /// **'Beyin Akt.'**
  String get dreamMetricBrain;

  /// No description provided for @tarotShuffleHint.
  ///
  /// In tr, this message translates to:
  /// **'Karıştırmak için dairesel sürükle'**
  String get tarotShuffleHint;

  /// No description provided for @tarotEnergyDepletedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Enerji Tükendi'**
  String get tarotEnergyDepletedTitle;

  /// No description provided for @tarotEnergyDepletedBody.
  ///
  /// In tr, this message translates to:
  /// **'Günlük kozmik enerjin tükendi.\nGerçeği görmek için enerjini yenile.'**
  String get tarotEnergyDepletedBody;

  /// No description provided for @tarotEnergyDepletedSub.
  ///
  /// In tr, this message translates to:
  /// **'Seçtiğin kartlar hazır, sadece bir adım kaldı...'**
  String get tarotEnergyDepletedSub;

  /// No description provided for @tarotWatchAd.
  ///
  /// In tr, this message translates to:
  /// **'Reklam İzle & Aç'**
  String get tarotWatchAd;

  /// Free readings remaining
  ///
  /// In tr, this message translates to:
  /// **'Bugün kalan ücretsiz: {count}'**
  String tarotFreeRemaining(Object count);

  /// No description provided for @socialFeedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz Akış'**
  String get socialFeedTitle;

  /// No description provided for @feedTypeCookie.
  ///
  /// In tr, this message translates to:
  /// **'Kurabiye'**
  String get feedTypeCookie;

  /// No description provided for @feedTagDailyCookie.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü kurabiye'**
  String get feedTagDailyCookie;

  /// No description provided for @feedTypeTarot.
  ///
  /// In tr, this message translates to:
  /// **'Tarot'**
  String get feedTypeTarot;

  /// No description provided for @feedTagThreeCard.
  ///
  /// In tr, this message translates to:
  /// **'3 kart çekimi'**
  String get feedTagThreeCard;

  /// No description provided for @feedTypeDream.
  ///
  /// In tr, this message translates to:
  /// **'Rüya'**
  String get feedTypeDream;

  /// No description provided for @feedTagDreamMode.
  ///
  /// In tr, this message translates to:
  /// **'Rüya modu'**
  String get feedTagDreamMode;

  /// No description provided for @feedTypeZodiac.
  ///
  /// In tr, this message translates to:
  /// **'Burç'**
  String get feedTypeZodiac;

  /// No description provided for @feedTagDailyEnergy.
  ///
  /// In tr, this message translates to:
  /// **'Günlük enerji'**
  String get feedTagDailyEnergy;

  /// No description provided for @feedTypeMotivation.
  ///
  /// In tr, this message translates to:
  /// **'Motivasyon'**
  String get feedTypeMotivation;

  /// No description provided for @feedTagMiniAction.
  ///
  /// In tr, this message translates to:
  /// **'Mini eylem'**
  String get feedTagMiniAction;

  /// No description provided for @inviteShareMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mistik bir yolculuğa hazır mısın? Crack&Wish evreninde seni bekliyorum! ✨\n\nDavet kodum: {handle}\nHemen İndir: {link}'**
  String inviteShareMessage(String handle, String link);

  /// No description provided for @inviteShareSubject.
  ///
  /// In tr, this message translates to:
  /// **'Crack&Wish Daveti'**
  String get inviteShareSubject;

  /// No description provided for @inviteSendButton.
  ///
  /// In tr, this message translates to:
  /// **'Davet Et'**
  String get inviteSendButton;

  /// No description provided for @inviteConnectButton.
  ///
  /// In tr, this message translates to:
  /// **'Bağlan'**
  String get inviteConnectButton;

  /// No description provided for @inviteSentText.
  ///
  /// In tr, this message translates to:
  /// **'Gönderildi'**
  String get inviteSentText;

  /// No description provided for @inviteRequestSent.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisine istek gönderildi!'**
  String inviteRequestSent(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
