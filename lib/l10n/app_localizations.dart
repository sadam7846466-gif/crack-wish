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
  /// **'EVET'**
  String get dreamYes;

  /// No description provided for @dreamNo.
  ///
  /// In tr, this message translates to:
  /// **'HAYIR'**
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
  /// **'Anlatısal\nBelirsizlik'**
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

  /// No description provided for @toastCoffeeReadyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Falın Hazır!'**
  String get toastCoffeeReadyTitle;

  /// No description provided for @toastCoffeeReadyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Fincanındaki sırlar çözüldü.'**
  String get toastCoffeeReadyMessage;

  /// No description provided for @toastViewButton.
  ///
  /// In tr, this message translates to:
  /// **'Göz At'**
  String get toastViewButton;

  /// No description provided for @toastDreamReadyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüyan Yorumlandı!'**
  String get toastDreamReadyTitle;

  /// No description provided for @toastDreamReadyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bilinçaltının mesajları çözüldü.'**
  String get toastDreamReadyMessage;

  /// No description provided for @toastCoffeeReadyTitle2.
  ///
  /// In tr, this message translates to:
  /// **'Kahve Falın Hazır!'**
  String get toastCoffeeReadyTitle2;

  /// No description provided for @dreamFallbackTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rüya Yorumu'**
  String get dreamFallbackTitle;

  /// No description provided for @rewardWelcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Evrene Hoş Geldin'**
  String get rewardWelcomeTitle;

  /// No description provided for @rewardWelcomeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğuna başlaman için sana küçük bir hediye bıraktık.'**
  String get rewardWelcomeDesc;

  /// No description provided for @rewardReferralFallback.
  ///
  /// In tr, this message translates to:
  /// **'Bir arkadaşın'**
  String get rewardReferralFallback;

  /// No description provided for @rewardReferralReceiverTitle.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmedik Bir Hediye'**
  String get rewardReferralReceiverTitle;

  /// No description provided for @rewardReferralReceiverDesc.
  ///
  /// In tr, this message translates to:
  /// **'{inviter} seni buraya davet ettiği için sana bir karşılama hediyesi bıraktı.'**
  String rewardReferralReceiverDesc(String inviter);

  /// No description provided for @rewardInviterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çağrın Duyuldu!'**
  String get rewardInviterTitle;

  /// No description provided for @rewardInviterDescSingle.
  ///
  /// In tr, this message translates to:
  /// **'{name} evrene katıldı. Yol gösterici olduğun için ödüllendirildin.'**
  String rewardInviterDescSingle(String name);

  /// No description provided for @rewardInviterDescMultiple.
  ///
  /// In tr, this message translates to:
  /// **'{name} ve {count} arkadaşın daha evrene katıldı. Yol gösterici olduğun için ödüllendirildin.'**
  String rewardInviterDescMultiple(String name, int count);

  /// No description provided for @rewardInviterDescGeneric.
  ///
  /// In tr, this message translates to:
  /// **'{count} arkadaşın evrene katıldı. Yol gösterici olduğun için ödüllendirildin.'**
  String rewardInviterDescGeneric(int count);

  /// No description provided for @birthdayTitleWithName.
  ///
  /// In tr, this message translates to:
  /// **'{name}, Doğum Günün Kutlu Olsun!'**
  String birthdayTitleWithName(String name);

  /// No description provided for @birthdayTitle.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Günün Kutlu Olsun!'**
  String get birthdayTitle;

  /// No description provided for @birthdayDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bugün ruhunun bu dünyaya indiği kutsal gün. Evren sana özel bir hediye bıraktı.'**
  String get birthdayDesc;

  /// No description provided for @cookieReminderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugün Kurabiye Kırmadın'**
  String get cookieReminderTitle;

  /// No description provided for @cookieReminderMessage.
  ///
  /// In tr, this message translates to:
  /// **'Günlük şans mesajın seni bekliyor!'**
  String get cookieReminderMessage;

  /// No description provided for @cookieReminderReward.
  ///
  /// In tr, this message translates to:
  /// **'3 Hak'**
  String get cookieReminderReward;

  /// No description provided for @achievementRewardStones.
  ///
  /// In tr, this message translates to:
  /// **'+{count} Ruh Taşı'**
  String achievementRewardStones(int count);

  /// No description provided for @achievementRewardAura.
  ///
  /// In tr, this message translates to:
  /// **'+{count} Aura'**
  String achievementRewardAura(int count);

  /// No description provided for @rankUpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Terfi!'**
  String get rankUpTitle;

  /// No description provided for @rankUpMessage.
  ///
  /// In tr, this message translates to:
  /// **'Aura gücün arttı. Yeni unvanın: {rank}'**
  String rankUpMessage(String rank);

  /// No description provided for @rankNovice.
  ///
  /// In tr, this message translates to:
  /// **'Acemi Kahin'**
  String get rankNovice;

  /// No description provided for @rankApprentice.
  ///
  /// In tr, this message translates to:
  /// **'Çırak Kahin'**
  String get rankApprentice;

  /// No description provided for @rankSeer.
  ///
  /// In tr, this message translates to:
  /// **'Kahin'**
  String get rankSeer;

  /// No description provided for @rankWise.
  ///
  /// In tr, this message translates to:
  /// **'Bilge Kahin'**
  String get rankWise;

  /// No description provided for @rankMaster.
  ///
  /// In tr, this message translates to:
  /// **'Usta Kahin'**
  String get rankMaster;

  /// No description provided for @rankCosmic.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Kahin'**
  String get rankCosmic;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ruhunun rehberi ile senkronize ol.\nGeçmişini, geleceğini ve bilinçaltını hatırla.'**
  String get loginSubtitle;

  /// No description provided for @loginAppleContinue.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile Devam Et'**
  String get loginAppleContinue;

  /// No description provided for @loginAppleSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile Giriş Yap'**
  String get loginAppleSignIn;

  /// No description provided for @loginGoogleContinue.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Devam Et'**
  String get loginGoogleContinue;

  /// No description provided for @loginGoogleSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get loginGoogleSignIn;

  /// No description provided for @loginGoogleFailed.
  ///
  /// In tr, this message translates to:
  /// **'Google Girişi Başarısız'**
  String get loginGoogleFailed;

  /// No description provided for @loginAppleFailed.
  ///
  /// In tr, this message translates to:
  /// **'Apple Girişi Başarısız'**
  String get loginAppleFailed;

  /// No description provided for @loginNoAccountYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz evrene katılmadın mı?  '**
  String get loginNoAccountYet;

  /// No description provided for @loginHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?  '**
  String get loginHaveAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get loginSignUp;

  /// No description provided for @loginSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginSignIn;

  /// No description provided for @loginLegalPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Devam ederek '**
  String get loginLegalPrefix;

  /// No description provided for @loginTermsOfUse.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get loginTermsOfUse;

  /// No description provided for @loginLegalAnd.
  ///
  /// In tr, this message translates to:
  /// **' ve '**
  String get loginLegalAnd;

  /// No description provided for @loginPrivacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get loginPrivacyPolicy;

  /// No description provided for @loginLegalSuffix.
  ///
  /// In tr, this message translates to:
  /// **'\'nı kabul etmiş olursunuz.'**
  String get loginLegalSuffix;

  /// No description provided for @homeSubtitle1.
  ///
  /// In tr, this message translates to:
  /// **'Kır, Oku, Gülümse.'**
  String get homeSubtitle1;

  /// No description provided for @homeSubtitle2.
  ///
  /// In tr, this message translates to:
  /// **'Şansın cebinde.'**
  String get homeSubtitle2;

  /// No description provided for @homeSubtitle3.
  ///
  /// In tr, this message translates to:
  /// **'Günün mesajı: Sen.'**
  String get homeSubtitle3;

  /// No description provided for @homeSubtitle4.
  ///
  /// In tr, this message translates to:
  /// **'Bir kırık, bir sürpriz.'**
  String get homeSubtitle4;

  /// No description provided for @homeSubtitle5.
  ///
  /// In tr, this message translates to:
  /// **'Küçük bir kurabiye, büyük bir his.'**
  String get homeSubtitle5;

  /// No description provided for @homeSubtitle6.
  ///
  /// In tr, this message translates to:
  /// **'Kader değil, tatlı bir ipucu.'**
  String get homeSubtitle6;

  /// No description provided for @homeSubtitle7.
  ///
  /// In tr, this message translates to:
  /// **'Bugün ne diyor şansın?'**
  String get homeSubtitle7;

  /// No description provided for @homeSubtitle8.
  ///
  /// In tr, this message translates to:
  /// **'Aç, keşfet, devam et.'**
  String get homeSubtitle8;

  /// No description provided for @homeSubtitle9.
  ///
  /// In tr, this message translates to:
  /// **'Şans bir tık uzağında.'**
  String get homeSubtitle9;

  /// No description provided for @homeSubtitle10.
  ///
  /// In tr, this message translates to:
  /// **'Her kırışta yeni bir başlangıç.'**
  String get homeSubtitle10;

  /// No description provided for @homeSubtitle11.
  ///
  /// In tr, this message translates to:
  /// **'Mesajını bul.'**
  String get homeSubtitle11;

  /// No description provided for @homeSubtitle12.
  ///
  /// In tr, this message translates to:
  /// **'Rastgele değil… tam sana göre.'**
  String get homeSubtitle12;

  /// No description provided for @homeSubtitle13.
  ///
  /// In tr, this message translates to:
  /// **'Şansını kır, gününü yakala.'**
  String get homeSubtitle13;

  /// No description provided for @homeSubtitle14.
  ///
  /// In tr, this message translates to:
  /// **'Gülümseten minik kehanetler.'**
  String get homeSubtitle14;

  /// No description provided for @homeSubtitle15.
  ///
  /// In tr, this message translates to:
  /// **'Sürpriz iyi gelir.'**
  String get homeSubtitle15;

  /// No description provided for @homeMilestoneTitle.
  ///
  /// In tr, this message translates to:
  /// **'İnanılmaz Odak!'**
  String get homeMilestoneTitle;

  /// No description provided for @homeMilestoneMessage.
  ///
  /// In tr, this message translates to:
  /// **'Günlük serin tam {count} güne ulaştı.'**
  String homeMilestoneMessage(int count);

  /// No description provided for @homeMilestoneSoulStone.
  ///
  /// In tr, this message translates to:
  /// **'+{count} Ruh Taşı'**
  String homeMilestoneSoulStone(int count);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In tr, this message translates to:
  /// **'Günaydın'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'İyi Günler'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In tr, this message translates to:
  /// **'İyi Akşamlar'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingNight.
  ///
  /// In tr, this message translates to:
  /// **'İyi Geceler'**
  String get homeGreetingNight;

  /// No description provided for @homeTimeSubMorning.
  ///
  /// In tr, this message translates to:
  /// **'Kahvenin yanına taze bir mesaj geldi.'**
  String get homeTimeSubMorning;

  /// No description provided for @homeTimeSubAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'Günün koşturmacasına sihirli bir mola.'**
  String get homeTimeSubAfternoon;

  /// No description provided for @homeTimeSubEvening.
  ///
  /// In tr, this message translates to:
  /// **'Günün yorgunluğunu atacak tatlı bir kehanet.'**
  String get homeTimeSubEvening;

  /// No description provided for @homeTimeSubNight.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızlar bu gece senin için parlıyor.'**
  String get homeTimeSubNight;

  /// No description provided for @paywallSubtitleElite.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik farkındalığın zaten açık.\nPlanını yükselterek aydınlanmanı güçlendir.'**
  String get paywallSubtitleElite;

  /// No description provided for @paywallSubtitleNew.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik farkındalığa giden kapıyı aç.\nSınırları tamamen kaldır.'**
  String get paywallSubtitleNew;

  /// No description provided for @paywallFeature1.
  ///
  /// In tr, this message translates to:
  /// **'Günde 5 Taze Ruh Taşı'**
  String get paywallFeature1;

  /// No description provided for @paywallFeature2.
  ///
  /// In tr, this message translates to:
  /// **'Master Analiz Modu'**
  String get paywallFeature2;

  /// No description provided for @paywallFeature3.
  ///
  /// In tr, this message translates to:
  /// **'x3 Hızlı Aura Kazanımı'**
  String get paywallFeature3;

  /// No description provided for @paywallFeature4.
  ///
  /// In tr, this message translates to:
  /// **'Sonsuz Klinik Arşiv'**
  String get paywallFeature4;

  /// No description provided for @paywallFeature5.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız Kesintisiz Deneyim'**
  String get paywallFeature5;

  /// No description provided for @paywallPackageWeekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Uyanış'**
  String get paywallPackageWeekly;

  /// No description provided for @paywallPackageMonthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Sezgi'**
  String get paywallPackageMonthly;

  /// No description provided for @paywallPackageYearly.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık Aydınlanma'**
  String get paywallPackageYearly;

  /// No description provided for @paywallBtnCurrentPlan.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Planın'**
  String get paywallBtnCurrentPlan;

  /// No description provided for @paywallBtnManage.
  ///
  /// In tr, this message translates to:
  /// **'Mağazadan Yönet'**
  String get paywallBtnManage;

  /// No description provided for @paywallBtnUpgrade.
  ///
  /// In tr, this message translates to:
  /// **'Planı Yükselt'**
  String get paywallBtnUpgrade;

  /// No description provided for @paywallBtnSubscribe.
  ///
  /// In tr, this message translates to:
  /// **'Elite Sınırlarını Aç'**
  String get paywallBtnSubscribe;

  /// No description provided for @paywallSuccessUpgradeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlanma Yükseldi'**
  String get paywallSuccessUpgradeTitle;

  /// No description provided for @paywallSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlanmaya Hoşgeldiniz'**
  String get paywallSuccessTitle;

  /// No description provided for @paywallSuccessUpgradeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Planınız başarıyla yükseltildi.'**
  String get paywallSuccessUpgradeSubtitle;

  /// No description provided for @paywallSuccessSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Artık bir Elite üyesisiniz. Kozmik sınırlar sizin için kaldırıldı.'**
  String get paywallSuccessSubtitle;

  /// No description provided for @paywallErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Hatası'**
  String get paywallErrorTitle;

  /// No description provided for @paywallErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mağazaya bağlanılamadı veya işlem iptal edildi. Ürünler henüz App Store/Play Console\'da yayına alınmamış olabilir. Lütfen daha sonra tekrar deneyin.'**
  String get paywallErrorMessage;

  /// No description provided for @paywallRestoreSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Elite Geri Yüklendi'**
  String get paywallRestoreSuccess;

  /// No description provided for @paywallRestoreSuccessSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik farkındalığa yeniden hoş geldiniz. Sınırlarınız kaldırıldı.'**
  String get paywallRestoreSuccessSubtitle;

  /// No description provided for @paywallRestoreNoSub.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Abonelik Yok'**
  String get paywallRestoreNoSub;

  /// No description provided for @paywallRestoreNoSubMessage.
  ///
  /// In tr, this message translates to:
  /// **'Geri yüklenebilecek aktif bir Crack Wish Elite üyeliği bulunamadı. Lütfen paketleri inceleyin.'**
  String get paywallRestoreNoSubMessage;

  /// No description provided for @paywallRestore.
  ///
  /// In tr, this message translates to:
  /// **'Satın Alımları Geri Yükle'**
  String get paywallRestore;

  /// No description provided for @paywallCurrentPlanBadge.
  ///
  /// In tr, this message translates to:
  /// **'MEVCUT PLAN'**
  String get paywallCurrentPlanBadge;

  /// No description provided for @paywallLegalTr.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliğiniz, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Ödeme, satın alma onayında Apple ID / Google Play hesabınızdan tahsil edilir. Aboneliğinizi mağaza hesap ayarlarınızdan dilediğiniz zaman yönetebilirsiniz.'**
  String get paywallLegalTr;

  /// No description provided for @paywallOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get paywallOk;

  /// No description provided for @coffeeLoading1.
  ///
  /// In tr, this message translates to:
  /// **'Fincanın derinliklerine iniliyor...'**
  String get coffeeLoading1;

  /// No description provided for @coffeeLoading2.
  ///
  /// In tr, this message translates to:
  /// **'Telvelerdeki semboller evrensel enerjiyle eşleşiyor...'**
  String get coffeeLoading2;

  /// No description provided for @coffeeLoading3.
  ///
  /// In tr, this message translates to:
  /// **'Kader çizgilerin haritalanıyor...'**
  String get coffeeLoading3;

  /// No description provided for @coffeeLoading4.
  ///
  /// In tr, this message translates to:
  /// **'Sırlar açığa çıkıyor...'**
  String get coffeeLoading4;

  /// No description provided for @coffeeAiError.
  ///
  /// In tr, this message translates to:
  /// **'AI falı yorumlarken bir hata ile karşılaştı.'**
  String get coffeeAiError;

  /// No description provided for @coffeeGenericError.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu. Lütfen tekrar dene.'**
  String get coffeeGenericError;

  /// No description provided for @coffeeNotifReady.
  ///
  /// In tr, this message translates to:
  /// **'Falın hazır olunca bildirim alacaksın'**
  String get coffeeNotifReady;

  /// No description provided for @coffeeCheckHistory.
  ///
  /// In tr, this message translates to:
  /// **'  butonundan görebilirsin'**
  String get coffeeCheckHistory;

  /// No description provided for @coffeeWaitOrExplore.
  ///
  /// In tr, this message translates to:
  /// **'Burada bekle ya da uygulamayı keşfet'**
  String get coffeeWaitOrExplore;

  /// No description provided for @coffeeGoHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfaya Dön'**
  String get coffeeGoHome;

  /// No description provided for @coffeeSections.
  ///
  /// In tr, this message translates to:
  /// **'Fincanın Bölümleri'**
  String get coffeeSections;

  /// No description provided for @coffeeSectionInside.
  ///
  /// In tr, this message translates to:
  /// **'Fincan İçi'**
  String get coffeeSectionInside;

  /// No description provided for @coffeeSectionInsideDesc.
  ///
  /// In tr, this message translates to:
  /// **'İç dünyan, düşüncelerin, duygusal halin.'**
  String get coffeeSectionInsideDesc;

  /// No description provided for @coffeeSectionEdge.
  ///
  /// In tr, this message translates to:
  /// **'Fincan Kenarı'**
  String get coffeeSectionEdge;

  /// No description provided for @coffeeSectionEdgeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yakın gelecek, haber, mesaj, görüşme.'**
  String get coffeeSectionEdgeDesc;

  /// No description provided for @coffeeSectionBottom.
  ///
  /// In tr, this message translates to:
  /// **'Fincan Dibi'**
  String get coffeeSectionBottom;

  /// No description provided for @coffeeSectionBottomDesc.
  ///
  /// In tr, this message translates to:
  /// **'Geçmişten kalan konu, yük, kapanmamış mesele.'**
  String get coffeeSectionBottomDesc;

  /// No description provided for @coffeeSectionSaucer.
  ///
  /// In tr, this message translates to:
  /// **'Tabak'**
  String get coffeeSectionSaucer;

  /// No description provided for @coffeeSectionSaucerDesc.
  ///
  /// In tr, this message translates to:
  /// **'Dilek, sonuç, kısmet, son enerji.'**
  String get coffeeSectionSaucerDesc;

  /// No description provided for @coffeeLoadingComment.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yükleniyor...'**
  String get coffeeLoadingComment;

  /// No description provided for @coffeeStoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Telvelerin Anlattığı Hikaye'**
  String get coffeeStoryTitle;

  /// No description provided for @coffeeSymbolsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Falında Görülen Semboller'**
  String get coffeeSymbolsTitle;

  /// No description provided for @coffeeLove.
  ///
  /// In tr, this message translates to:
  /// **'Aşk & İlişkiler'**
  String get coffeeLove;

  /// No description provided for @coffeeCareer.
  ///
  /// In tr, this message translates to:
  /// **'İş & Para'**
  String get coffeeCareer;

  /// No description provided for @coffeeFamily.
  ///
  /// In tr, this message translates to:
  /// **'Aile & Yakın Çevre'**
  String get coffeeFamily;

  /// No description provided for @coffeeNearFuture.
  ///
  /// In tr, this message translates to:
  /// **'Yakın Gelecek'**
  String get coffeeNearFuture;

  /// No description provided for @coffeeClosing.
  ///
  /// In tr, this message translates to:
  /// **'Falın Son Sözü'**
  String get coffeeClosing;

  /// No description provided for @coffeeShare.
  ///
  /// In tr, this message translates to:
  /// **'Falımı Paylaş'**
  String get coffeeShare;

  /// No description provided for @coffeeRetryValidation.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dön & Yeniden Çek'**
  String get coffeeRetryValidation;

  /// No description provided for @coffeeRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get coffeeRetry;

  /// No description provided for @coffeeCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal Et'**
  String get coffeeCancel;

  /// No description provided for @coffeeSymbolLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sembol'**
  String get coffeeSymbolLabel;

  /// No description provided for @coffeeSymbolLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get coffeeSymbolLoading;

  /// No description provided for @coffeeTimelineSoon.
  ///
  /// In tr, this message translates to:
  /// **'Çok Yakında'**
  String get coffeeTimelineSoon;

  /// No description provided for @coffeeImageError.
  ///
  /// In tr, this message translates to:
  /// **'Bu görselde net bir kahve telvesi seçilemiyor.'**
  String get coffeeImageError;

  /// No description provided for @coffeeCosmicTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Kahve Yorumu'**
  String get coffeeCosmicTitle;

  /// No description provided for @coffeePremiumOnly.
  ///
  /// In tr, this message translates to:
  /// **'Sadece Premium Özeldir'**
  String get coffeePremiumOnly;

  /// No description provided for @coffeePremiumDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kahve Falı özelliği uygulamanın elit üyelerine aittir. Premium\'a geç ve Ruh Taşlarınla geleceğin sırlarını arala.'**
  String get coffeePremiumDesc;

  /// No description provided for @coffeePremiumSimBtn.
  ///
  /// In tr, this message translates to:
  /// **'Premium Ol (Simülasyon)'**
  String get coffeePremiumSimBtn;

  /// No description provided for @coffeePhotoSource.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Kaynağı'**
  String get coffeePhotoSource;

  /// No description provided for @coffeeCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get coffeeCamera;

  /// No description provided for @coffeeGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get coffeeGallery;

  /// No description provided for @coffeeStepCupInside.
  ///
  /// In tr, this message translates to:
  /// **'Fincan İçi'**
  String get coffeeStepCupInside;

  /// No description provided for @coffeeStepCupInsideDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kamerayı fincanın tam üstüne getirin ve içindeki telveleri odaklayarak çekin.'**
  String get coffeeStepCupInsideDesc;

  /// No description provided for @coffeeStepLeftProfile.
  ///
  /// In tr, this message translates to:
  /// **'Sol Profil'**
  String get coffeeStepLeftProfile;

  /// No description provided for @coffeeStepLeftProfileDesc.
  ///
  /// In tr, this message translates to:
  /// **'Fincanı kulbundan tutup sadece sol yüzünün fotoğrafını net bir şekilde çekin.'**
  String get coffeeStepLeftProfileDesc;

  /// No description provided for @coffeeStepRightProfile.
  ///
  /// In tr, this message translates to:
  /// **'Sağ Profil'**
  String get coffeeStepRightProfile;

  /// No description provided for @coffeeStepRightProfileDesc.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi fincanın sağ arka yüzünü, ışığın vurduğu açıdan çekin.'**
  String get coffeeStepRightProfileDesc;

  /// No description provided for @coffeeStepSaucerSecret.
  ///
  /// In tr, this message translates to:
  /// **'Tabağın Sırrı'**
  String get coffeeStepSaucerSecret;

  /// No description provided for @coffeeStepSaucerDesc.
  ///
  /// In tr, this message translates to:
  /// **'Son olarak tabağın geniş yüzeyini, içindeki telveler net görünecek şekilde çekin.'**
  String get coffeeStepSaucerDesc;

  /// No description provided for @coffeeStepSaucerBtn.
  ///
  /// In tr, this message translates to:
  /// **'Tabak Fotoğrafı Çek'**
  String get coffeeStepSaucerBtn;

  /// No description provided for @coffeeHeaderTitle.
  ///
  /// In tr, this message translates to:
  /// **'KAHVE FALI'**
  String get coffeeHeaderTitle;

  /// No description provided for @coffeeLastReading.
  ///
  /// In tr, this message translates to:
  /// **'Son Falın'**
  String get coffeeLastReading;

  /// No description provided for @coffeeLastReadingTime.
  ///
  /// In tr, this message translates to:
  /// **'Saat {time} • Gece 00:00\'da silinir'**
  String coffeeLastReadingTime(String time);

  /// No description provided for @coffeeNoReadingYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz fal baktırmadın.\nBir fincan kahve demle,\ntelvelerin sana fısıldamasını bekle.'**
  String get coffeeNoReadingYet;

  /// No description provided for @coffeeSoulStones.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Taşların'**
  String get coffeeSoulStones;

  /// No description provided for @coffeeSoulStoneEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Taşın bitti'**
  String get coffeeSoulStoneEmpty;

  /// No description provided for @coffeeSoulStoneRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kahve falı yorumlaması için gerekli'**
  String get coffeeSoulStoneRequired;

  /// No description provided for @coffeeSoulStoneCost.
  ///
  /// In tr, this message translates to:
  /// **'Her yorum 1 Ruh Taşı harcar'**
  String get coffeeSoulStoneCost;

  /// No description provided for @coffeeSoulStoneEliteActive.
  ///
  /// In tr, this message translates to:
  /// **'Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir'**
  String get coffeeSoulStoneEliteActive;

  /// No description provided for @coffeeSoulStoneElitePromo.
  ///
  /// In tr, this message translates to:
  /// **'Elite ile her gece 5 Ruh Taşı kazan'**
  String get coffeeSoulStoneElitePromo;

  /// No description provided for @coffeeEliteSubscribe.
  ///
  /// In tr, this message translates to:
  /// **'Elite Abone Ol'**
  String get coffeeEliteSubscribe;

  /// No description provided for @coffeeRitualLabel.
  ///
  /// In tr, this message translates to:
  /// **'RİTÜEL'**
  String get coffeeRitualLabel;

  /// No description provided for @coffeeRitualTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fincanın Sırları'**
  String get coffeeRitualTitle;

  /// No description provided for @coffeeRitualDesc.
  ///
  /// In tr, this message translates to:
  /// **'Telveler sadece onlara doğru bakanlara konuşur. Gerçek bir okuma için ritüeli takip et.'**
  String get coffeeRitualDesc;

  /// No description provided for @coffeeRitualStep1Title.
  ///
  /// In tr, this message translates to:
  /// **'Niyetini Belirle'**
  String get coffeeRitualStep1Title;

  /// No description provided for @coffeeRitualStep1Desc.
  ///
  /// In tr, this message translates to:
  /// **'Yudumlarken zihninden bir soru veya dilek geçir.'**
  String get coffeeRitualStep1Desc;

  /// No description provided for @coffeeRitualStep2Title.
  ///
  /// In tr, this message translates to:
  /// **'Aynı Yerden İç'**
  String get coffeeRitualStep2Title;

  /// No description provided for @coffeeRitualStep2Desc.
  ///
  /// In tr, this message translates to:
  /// **'Şekillerin bozulmaması için hep aynı taraftan yudumla.'**
  String get coffeeRitualStep2Desc;

  /// No description provided for @coffeeRitualStep3Title.
  ///
  /// In tr, this message translates to:
  /// **'Ters Çevir'**
  String get coffeeRitualStep3Title;

  /// No description provided for @coffeeRitualStep3Desc.
  ///
  /// In tr, this message translates to:
  /// **'Fincanı kapat, soğumasını bekle ve yavaşça aç.'**
  String get coffeeRitualStep3Desc;

  /// No description provided for @coffeeRitualListenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Telvelerin Fısıltısını Dinle'**
  String get coffeeRitualListenTitle;

  /// No description provided for @coffeeStepLabel.
  ///
  /// In tr, this message translates to:
  /// **'Adım {index}: {title}'**
  String coffeeStepLabel(String index, String title);

  /// No description provided for @coffeeDiscoverFate.
  ///
  /// In tr, this message translates to:
  /// **'Kaderini Keşfet'**
  String get coffeeDiscoverFate;

  /// No description provided for @coffeeNextStep.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Adım'**
  String get coffeeNextStep;

  /// No description provided for @coffeeValidationError.
  ///
  /// In tr, this message translates to:
  /// **'İşaretli fotoğraflardaki telveler\ntam olarak seçilemiyor.'**
  String get coffeeValidationError;

  /// No description provided for @coffeeCosmicMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Uyumsuzluk'**
  String get coffeeCosmicMismatch;

  /// No description provided for @coffeeCosmicCheck.
  ///
  /// In tr, this message translates to:
  /// **'KOZMİK BAĞ KONTROLÜ'**
  String get coffeeCosmicCheck;

  /// No description provided for @coffeeCosmicCheckDesc.
  ///
  /// In tr, this message translates to:
  /// **'Telvelerin dili çözülüyor,\nkaderin fısıltıları dinleniyor...'**
  String get coffeeCosmicCheckDesc;

  /// No description provided for @coffeeRevealSecrets.
  ///
  /// In tr, this message translates to:
  /// **'Sır Perdesini Arala'**
  String get coffeeRevealSecrets;

  /// No description provided for @coffeeReadingInProgress.
  ///
  /// In tr, this message translates to:
  /// **'Telveler Okunuyor...'**
  String get coffeeReadingInProgress;

  /// No description provided for @coffeeReadingWait.
  ///
  /// In tr, this message translates to:
  /// **'Geleceğin kapıları aralanıyor, bekle.'**
  String get coffeeReadingWait;

  /// No description provided for @coffeeRelationTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlişki Durumun'**
  String get coffeeRelationTitle;

  /// No description provided for @coffeeRelationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik bağın temelini belirle.'**
  String get coffeeRelationSubtitle;

  /// No description provided for @coffeeFocusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aklında Ne Var?'**
  String get coffeeFocusTitle;

  /// No description provided for @coffeeFocusSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir niyet seç, yorumun ona göre derinleşsin.'**
  String get coffeeFocusSubtitle;

  /// No description provided for @coffeeMoodTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Halin?'**
  String get coffeeMoodTitle;

  /// No description provided for @coffeeMoodSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Fincanının enerjisini hisset.'**
  String get coffeeMoodSubtitle;

  /// No description provided for @coffeeCosmicBondFormed.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Bağ Kuruldu'**
  String get coffeeCosmicBondFormed;

  /// No description provided for @coffeeSecretsReady.
  ///
  /// In tr, this message translates to:
  /// **'Fincanının sırları fısıldanmaya hazır...'**
  String get coffeeSecretsReady;

  /// No description provided for @coffeeNewReading.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Fal Bak'**
  String get coffeeNewReading;

  /// No description provided for @coffeeAiPermission.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka kahve analizi izni'**
  String get coffeeAiPermission;

  /// No description provided for @coffeeStoneCostInfo.
  ///
  /// In tr, this message translates to:
  /// **'Her analiz 1 Ruh Taşı harcar'**
  String get coffeeStoneCostInfo;

  /// No description provided for @coffeeEliteRefillActive.
  ///
  /// In tr, this message translates to:
  /// **'Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir'**
  String get coffeeEliteRefillActive;

  /// No description provided for @coffeeEliteRefillPromo.
  ///
  /// In tr, this message translates to:
  /// **'Elite ile her gece 5 Ruh Taşı kazan'**
  String get coffeeEliteRefillPromo;

  /// No description provided for @coffeeEliteGetBtn.
  ///
  /// In tr, this message translates to:
  /// **'Elite Al'**
  String get coffeeEliteGetBtn;

  /// No description provided for @coffeeResultOnHome.
  ///
  /// In tr, this message translates to:
  /// **'Sonucu ana sayfadaki  '**
  String get coffeeResultOnHome;

  /// No description provided for @onboardingStart.
  ///
  /// In tr, this message translates to:
  /// **'Hadi Başlayalım'**
  String get onboardingStart;

  /// No description provided for @onboardingContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get onboardingContinue;

  /// No description provided for @onboardingFinish.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğa Başla'**
  String get onboardingFinish;

  /// No description provided for @onboardingNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Bir İsim'**
  String get onboardingNameHint;

  /// No description provided for @onboardingNamePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'isim_soyisim'**
  String get onboardingNamePlaceholder;

  /// No description provided for @onboardingHandleHint.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Bir Lakap'**
  String get onboardingHandleHint;

  /// No description provided for @onboardingHandlePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'galaksi_gezgin'**
  String get onboardingHandlePlaceholder;

  /// No description provided for @onboardingGenderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get onboardingGenderTitle;

  /// No description provided for @onboardingGenderFemale.
  ///
  /// In tr, this message translates to:
  /// **'Kadın'**
  String get onboardingGenderFemale;

  /// No description provided for @onboardingGenderMale.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get onboardingGenderMale;

  /// No description provided for @onboardingGenderOther.
  ///
  /// In tr, this message translates to:
  /// **'Belirtmek İstemiyorum'**
  String get onboardingGenderOther;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In tr, this message translates to:
  /// **'Sana ne demeliyiz?'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Sub.
  ///
  /// In tr, this message translates to:
  /// **'Evren seni hangi isimle ve titreşimle tanısın?'**
  String get onboardingStep1Sub;

  /// No description provided for @onboardingAvatarSelect.
  ///
  /// In tr, this message translates to:
  /// **'Görünümünü Seç'**
  String get onboardingAvatarSelect;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In tr, this message translates to:
  /// **'Ruhunun bedene girdiği an...'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Sub.
  ///
  /// In tr, this message translates to:
  /// **'Astrolojik doğum haritanı ve sana özel ritüelleri hesaplayabilmemiz için temel bilgilerine ihtiyacımız var.'**
  String get onboardingStep2Sub;

  /// No description provided for @onboardingBirthDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihin'**
  String get onboardingBirthDateLabel;

  /// No description provided for @onboardingBirthTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Saatin'**
  String get onboardingBirthTimeLabel;

  /// No description provided for @onboardingBirthLocationLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğduğu Şehir'**
  String get onboardingBirthLocationLabel;

  /// No description provided for @onboardingTimeHint.
  ///
  /// In tr, this message translates to:
  /// **'Tam saati biliyorsan detaylı analiz için gir'**
  String get onboardingTimeHint;

  /// No description provided for @onboardingLocationHint.
  ///
  /// In tr, this message translates to:
  /// **'Şehir seçerek hesaplamayı netleştir'**
  String get onboardingLocationHint;

  /// No description provided for @onboardingUnknownTime.
  ///
  /// In tr, this message translates to:
  /// **'Tam saati bilmiyorum'**
  String get onboardingUnknownTime;

  /// No description provided for @onboardingPrivacyNote.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca sana özel haritanı çizmek içindir.'**
  String get onboardingPrivacyNote;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In tr, this message translates to:
  /// **'Odak noktan neresi?'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Sub.
  ///
  /// In tr, this message translates to:
  /// **'Şu sıralar hayatında en çok hangi enerjiyi büyütmek veya şifalandırmak istiyorsun?'**
  String get onboardingStep3Sub;

  /// No description provided for @onboardingFocusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Odak (Çoklu Seçim)'**
  String get onboardingFocusLabel;

  /// No description provided for @onboardingFocusCareer.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer & Para'**
  String get onboardingFocusCareer;

  /// No description provided for @onboardingFocusLove.
  ///
  /// In tr, this message translates to:
  /// **'Aşk & İlişkiler'**
  String get onboardingFocusLove;

  /// No description provided for @onboardingFocusPeace.
  ///
  /// In tr, this message translates to:
  /// **'İçsel Huzur'**
  String get onboardingFocusPeace;

  /// No description provided for @onboardingFocusLuck.
  ///
  /// In tr, this message translates to:
  /// **'Şans & Fırsatlar'**
  String get onboardingFocusLuck;

  /// No description provided for @onboardingRelLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şu anki ilişki durumun:'**
  String get onboardingRelLabel;

  /// No description provided for @onboardingRelSingle.
  ///
  /// In tr, this message translates to:
  /// **'Yalnız Gökyüzü'**
  String get onboardingRelSingle;

  /// No description provided for @onboardingRelComplicated.
  ///
  /// In tr, this message translates to:
  /// **'Biri Var...'**
  String get onboardingRelComplicated;

  /// No description provided for @onboardingRelTalking.
  ///
  /// In tr, this message translates to:
  /// **'Karmaşık'**
  String get onboardingRelTalking;

  /// No description provided for @onboardingRelRelationship.
  ///
  /// In tr, this message translates to:
  /// **'Mutlu Bir Bağ'**
  String get onboardingRelRelationship;

  /// No description provided for @onboardingStep4Title.
  ///
  /// In tr, this message translates to:
  /// **'Geceleri evrenle bağın...'**
  String get onboardingStep4Title;

  /// No description provided for @onboardingStep4Sub.
  ///
  /// In tr, this message translates to:
  /// **'Bilinçaltın mesajları nasıl alıyor? Renklerin ve rüyaların bize ipucu verecek.'**
  String get onboardingStep4Sub;

  /// No description provided for @onboardingDreamLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ne sıklıkla rüya hatırlarsın?'**
  String get onboardingDreamLabel;

  /// No description provided for @onboardingDreamOften.
  ///
  /// In tr, this message translates to:
  /// **'Sık Sık ve Çok Net'**
  String get onboardingDreamOften;

  /// No description provided for @onboardingDreamSometimes.
  ///
  /// In tr, this message translates to:
  /// **'Bazen Hatırlarım'**
  String get onboardingDreamSometimes;

  /// No description provided for @onboardingDreamRarely.
  ///
  /// In tr, this message translates to:
  /// **'Nadir'**
  String get onboardingDreamRarely;

  /// No description provided for @onboardingDreamNever.
  ///
  /// In tr, this message translates to:
  /// **'Hiç Rüya Görmem'**
  String get onboardingDreamNever;

  /// No description provided for @onboardingAuraLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ruhunun Aurası (Bugün nasıl hissediyorsun?)'**
  String get onboardingAuraLabel;

  /// No description provided for @onboardingStep5Title.
  ///
  /// In tr, this message translates to:
  /// **'Zamanla olan dansın...'**
  String get onboardingStep5Title;

  /// No description provided for @onboardingStep5Sub.
  ///
  /// In tr, this message translates to:
  /// **'Günün hangi saatlerinde enerjin en yüksek? Bildirimlerini buna göre ayarlayacağız.'**
  String get onboardingStep5Sub;

  /// No description provided for @onboardingSleepLabel.
  ///
  /// In tr, this message translates to:
  /// **'Uyku Düzenin'**
  String get onboardingSleepLabel;

  /// No description provided for @onboardingSleepMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah İnsanı'**
  String get onboardingSleepMorning;

  /// No description provided for @onboardingSleepNight.
  ///
  /// In tr, this message translates to:
  /// **'Gece Kuşu'**
  String get onboardingSleepNight;

  /// No description provided for @onboardingSleepIrregular.
  ///
  /// In tr, this message translates to:
  /// **'Düzensiz'**
  String get onboardingSleepIrregular;

  /// No description provided for @onboardingSleepLittle.
  ///
  /// In tr, this message translates to:
  /// **'Çok Az Uyurum'**
  String get onboardingSleepLittle;

  /// No description provided for @onboardingMatchLabel.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme ve Kozmik Bağ'**
  String get onboardingMatchLabel;

  /// No description provided for @onboardingMatchDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sinerji uyumlu profillerle bağ kurmaya ve özel kozmik eşleşmelere açık olmak istiyorum.'**
  String get onboardingMatchDesc;

  /// No description provided for @onboardingFinalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Her şey hazır...'**
  String get onboardingFinalTitle;

  /// No description provided for @onboardingFinalSub.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızların senin için ne planladığını öğrenmek üzeresin. Hesabını oluştur ve kozmik evrene giriş yap.'**
  String get onboardingFinalSub;

  /// No description provided for @onboardingAppleCreate.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile Hesabını Oluştur'**
  String get onboardingAppleCreate;

  /// No description provided for @onboardingGoogleCreate.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Hesabını Oluştur'**
  String get onboardingGoogleCreate;

  /// No description provided for @onboardingErrorIncomplete.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin! Profilini tamamlamak için birkaç adım kaldı.'**
  String get onboardingErrorIncomplete;

  /// No description provided for @onboardingErrorFailed.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız oldu. Lütfen tekrar deneyin.'**
  String get onboardingErrorFailed;

  /// No description provided for @onboardingErrorAlreadyExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu {provider} hesabı ile zaten bir kozmik profilin var! Lütfen ilk sayfadaki \'Giriş Yap\' seçeneğini kullan.'**
  String onboardingErrorAlreadyExists(String provider);

  /// No description provided for @onboardingErrorDBRejected.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt işlemi veritabanında reddedildi:\n{error}\nLütfen destek ile iletişime geçin.'**
  String onboardingErrorDBRejected(String error);

  /// No description provided for @onboardingErrorHandleTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı zaten alınmış'**
  String get onboardingErrorHandleTaken;

  /// No description provided for @notifTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifTitle;

  /// No description provided for @notifSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hangi bildirimleri almak istediğini seç'**
  String get notifSubtitle;

  /// No description provided for @notifAnnouncements.
  ///
  /// In tr, this message translates to:
  /// **'Duyurular'**
  String get notifAnnouncements;

  /// No description provided for @notifAnnouncementsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yeni özellikler ve güncellemeler'**
  String get notifAnnouncementsDesc;

  /// No description provided for @notifSounds.
  ///
  /// In tr, this message translates to:
  /// **'Sesler'**
  String get notifSounds;

  /// No description provided for @notifSoundsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sesli bildirim uyarıları'**
  String get notifSoundsDesc;

  /// No description provided for @notifCookieAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kurabiye Alarmı'**
  String get notifCookieAlarm;

  /// No description provided for @notifCookieAlarmDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yeni fortune cookie geldiğinde'**
  String get notifCookieAlarmDesc;

  /// No description provided for @notifFriendAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş Alarmı'**
  String get notifFriendAlarm;

  /// No description provided for @notifFriendAlarmDesc.
  ///
  /// In tr, this message translates to:
  /// **'Baykuş ağından yeni bağlantılar'**
  String get notifFriendAlarmDesc;

  /// No description provided for @notifDailyReminder.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hatırlatıcılar'**
  String get notifDailyReminder;

  /// No description provided for @notifDailyReminderDesc.
  ///
  /// In tr, this message translates to:
  /// **'Günlük kurabiyeni almayı unutma'**
  String get notifDailyReminderDesc;

  /// No description provided for @accountTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Detayları'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel bilgilerin ve hesap yönetimin'**
  String get accountSubtitle;

  /// No description provided for @accountUsername.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get accountUsername;

  /// No description provided for @accountLinkedEmail.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı E-posta'**
  String get accountLinkedEmail;

  /// No description provided for @accountSignInMethod.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yöntemi'**
  String get accountSignInMethod;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verilerin kalıcı olarak silinecek.\nBu işlem geri alınamaz.'**
  String get accountDeleteDesc;

  /// No description provided for @accountDeleteCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get accountDeleteCancel;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeletePermanent.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Kalıcı Olarak Sil'**
  String get accountDeletePermanent;

  /// No description provided for @welcomeTagline.
  ///
  /// In tr, this message translates to:
  /// **'The magic is within you.'**
  String get welcomeTagline;

  /// No description provided for @welcomeAppleContinue.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile Devam Et'**
  String get welcomeAppleContinue;

  /// No description provided for @welcomeGoogleContinue.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Devam Et'**
  String get welcomeGoogleContinue;

  /// No description provided for @moodGuideTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mod Rehberi'**
  String get moodGuideTitle;

  /// No description provided for @moodAwarenessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Duygusal Farkındalık'**
  String get moodAwarenessTitle;

  /// No description provided for @moodAwarenessDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ruh halini seçmek hislerini somutlaştırır; bu, içsel dengeni bulmanın ve öz-farkındalığın ilk adımıdır.'**
  String get moodAwarenessDesc;

  /// No description provided for @moodCosmicTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Frekans'**
  String get moodCosmicTitle;

  /// No description provided for @moodCosmicDesc.
  ///
  /// In tr, this message translates to:
  /// **'Mod tekerinden seçtiğin her duygunun bir frekansı vardır. Ekranın aurası doğrudan senin hislerinle uyumlanır.'**
  String get moodCosmicDesc;

  /// No description provided for @moodHowToTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Kullanmalı?'**
  String get moodHowToTitle;

  /// No description provided for @moodHowToDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sadece çarkı çevirip o anki ruh halini en iyi yansıtan ifadeyi seç. Duygunu yargılama, sadece hisset ve kabul et.'**
  String get moodHowToDesc;

  /// No description provided for @moodQuestionAlt.
  ///
  /// In tr, this message translates to:
  /// **'Bugün modun nasıl?'**
  String get moodQuestionAlt;

  /// No description provided for @moodSpinHint.
  ///
  /// In tr, this message translates to:
  /// **'Çarkı çevir, ruh halini seç ✨'**
  String get moodSpinHint;

  /// No description provided for @bentoCoffeeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kahve Falı'**
  String get bentoCoffeeTitle;

  /// No description provided for @bentoCoffeeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Telvelerin dili'**
  String get bentoCoffeeDesc;

  /// No description provided for @bentoUnexplored.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan henüz keşfedilmeyi bekliyor...'**
  String get bentoUnexplored;

  /// No description provided for @bentoSealed.
  ///
  /// In tr, this message translates to:
  /// **'Mühürlü'**
  String get bentoSealed;

  /// No description provided for @horoscopeDailyEnergy.
  ///
  /// In tr, this message translates to:
  /// **'Günün Enerjisi'**
  String get horoscopeDailyEnergy;

  /// No description provided for @horoscopeWestern.
  ///
  /// In tr, this message translates to:
  /// **'Batı Astrolojisi'**
  String get horoscopeWestern;

  /// No description provided for @horoscopeAsian.
  ///
  /// In tr, this message translates to:
  /// **'Asya Bilgeliği'**
  String get horoscopeAsian;

  /// No description provided for @horoscopeMayan.
  ///
  /// In tr, this message translates to:
  /// **'Maya Ruhu'**
  String get horoscopeMayan;

  /// No description provided for @shareSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi ✓'**
  String get shareSaved;

  /// No description provided for @shareDownload.
  ///
  /// In tr, this message translates to:
  /// **'İndir'**
  String get shareDownload;

  /// No description provided for @shareShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get shareShare;

  /// No description provided for @shareStory.
  ///
  /// In tr, this message translates to:
  /// **'Hikaye'**
  String get shareStory;

  /// No description provided for @sharePost.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi'**
  String get sharePost;

  /// No description provided for @shareCoffeeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kahve Falı'**
  String get shareCoffeeTitle;

  /// No description provided for @cookieLockedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu özel kurabiye kilitli'**
  String get cookieLockedTitle;

  /// No description provided for @cookieComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Yakında Satışa Çıkacak ✨'**
  String get cookieComingSoon;

  /// No description provided for @dreamWaitOrReturn.
  ///
  /// In tr, this message translates to:
  /// **'Burada bekleyebilir veya ana sayfaya dönebilirsin. Yorumun hazır olduğunda sana bildirim göndereceğiz ve \"Rüyalarım\" sekmesinden okuyabileceksin.'**
  String get dreamWaitOrReturn;

  /// No description provided for @dreamReturnHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfaya Dön'**
  String get dreamReturnHome;

  /// No description provided for @profileEditProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profilini Düzenle'**
  String get profileEditProfile;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ad, burç ve kişisel bilgilerini düzenle'**
  String get profileEditSubtitle;

  /// No description provided for @profileSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Burç, şehir veya doğum tarihi ara...'**
  String get profileSearchHint;

  /// No description provided for @profileStoreUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza bağlantısı şu an kurulamıyor.'**
  String get profileStoreUnavailable;

  /// No description provided for @profileMailNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Mail uygulaması bulunamadı. support@crackandwish.com adresine yazabilirsiniz.'**
  String get profileMailNotFound;

  /// No description provided for @profileRitualCode.
  ///
  /// In tr, this message translates to:
  /// **'Ritüel Kodun'**
  String get profileRitualCode;

  /// No description provided for @profileRitualDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod senin kişisel ritüel kimliğin. Arkadaşlarınla paylaşarak onları Baykuş Ağı\'na davet edebilirsin.'**
  String get profileRitualDesc;

  /// No description provided for @profileRitualCopied.
  ///
  /// In tr, this message translates to:
  /// **'Ritüel Kodun Kopyalandı ✨'**
  String get profileRitualCopied;

  /// No description provided for @profileRitualInfo.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarınla paylaş, birlikte keşfedin!'**
  String get profileRitualInfo;

  /// No description provided for @profileShareCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Paylaş'**
  String get profileShareCode;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verilerin kalıcı olarak silinecek.\nBu işlem geri alınamaz.'**
  String get profileDeleteDesc;

  /// No description provided for @profileDeleteCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get profileDeleteCancel;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get profileDeleteConfirm;

  /// No description provided for @profileSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get profileSignOut;

  /// No description provided for @profileSignOutDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hesabından güvenli çıkış yap.\nVerilerin korunur.'**
  String get profileSignOutDesc;

  /// No description provided for @profileSignOutCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get profileSignOutCancel;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get profileSignOutConfirm;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileTermsOfUse.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get profileTermsOfUse;

  /// No description provided for @profileGetElite.
  ///
  /// In tr, this message translates to:
  /// **'Elite\'e Geç'**
  String get profileGetElite;

  /// No description provided for @profileGetEliteSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Farkındalığa giden kapı'**
  String get profileGetEliteSubtitle;

  /// No description provided for @profileCosmicProfile.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Profilim'**
  String get profileCosmicProfile;

  /// No description provided for @profileCosmicSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Harita, Saat ve Konum Bilgileri'**
  String get profileCosmicSubtitle;

  /// No description provided for @profileSectionAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get profileSectionAccount;

  /// No description provided for @profileEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get profileEmail;

  /// No description provided for @profileNotificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Tercihleri'**
  String get profileNotificationSettings;

  /// No description provided for @profileRestorePurchases.
  ///
  /// In tr, this message translates to:
  /// **'Satın Alımları Geri Yükle'**
  String get profileRestorePurchases;

  /// No description provided for @profileRestoreSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Satın alımların başarıyla geri yüklendi!'**
  String get profileRestoreSuccess;

  /// No description provided for @profileRestoreFail.
  ///
  /// In tr, this message translates to:
  /// **'Geri yüklenecek satın alım bulunamadı.'**
  String get profileRestoreFail;

  /// No description provided for @profileHelp.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get profileHelp;

  /// No description provided for @profileShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get profileShare;

  /// No description provided for @profileRate.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendir'**
  String get profileRate;

  /// No description provided for @profileVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get profileVersion;

  /// No description provided for @profileCosmicName.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Adın'**
  String get profileCosmicName;

  /// No description provided for @profileSealProfile.
  ///
  /// In tr, this message translates to:
  /// **'Mührü Onayla'**
  String get profileSealProfile;

  /// No description provided for @profileChooseAvatar.
  ///
  /// In tr, this message translates to:
  /// **'Sihirli avatarını seç.'**
  String get profileChooseAvatar;

  /// No description provided for @profileStrengthenBonds.
  ///
  /// In tr, this message translates to:
  /// **'Bağlarını Güçlendir'**
  String get profileStrengthenBonds;

  /// No description provided for @profileStrengthenBondsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik evreni arkadaşlarınla büyüt.'**
  String get profileStrengthenBondsDesc;

  /// No description provided for @profileEarnSoulStones.
  ///
  /// In tr, this message translates to:
  /// **'+2 Ruh Taşı Kazan'**
  String get profileEarnSoulStones;

  /// No description provided for @profileCodeCopied.
  ///
  /// In tr, this message translates to:
  /// **'Kod kopyalandı!'**
  String get profileCodeCopied;

  /// No description provided for @profileNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get profileNotifications;

  /// No description provided for @profileSupportExperience.
  ///
  /// In tr, this message translates to:
  /// **'Destek & Deneyim'**
  String get profileSupportExperience;

  /// No description provided for @profileSeerNovice.
  ///
  /// In tr, this message translates to:
  /// **'Acemi Kahin'**
  String get profileSeerNovice;

  /// No description provided for @profileSeerApprentice.
  ///
  /// In tr, this message translates to:
  /// **'Çırak Kahin'**
  String get profileSeerApprentice;

  /// No description provided for @profileSeer.
  ///
  /// In tr, this message translates to:
  /// **'Kahin'**
  String get profileSeer;

  /// No description provided for @profileSeerWise.
  ///
  /// In tr, this message translates to:
  /// **'Bilge Kahin'**
  String get profileSeerWise;

  /// No description provided for @profileSeerMaster.
  ///
  /// In tr, this message translates to:
  /// **'Usta Kahin'**
  String get profileSeerMaster;

  /// No description provided for @profileSeerCosmic.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Kahin'**
  String get profileSeerCosmic;

  /// No description provided for @profileUploadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf buluta yüklenemedi! Lütfen bağlantını kontrol et.'**
  String get profileUploadFailed;

  /// No description provided for @profileCropTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Kesim'**
  String get profileCropTitle;

  /// No description provided for @profileCropCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get profileCropCancel;

  /// No description provided for @profileCropDone.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get profileCropDone;

  /// No description provided for @moderationAdultContent.
  ///
  /// In tr, this message translates to:
  /// **'Bu görselin enerjisi Kozmik evrenimizle uyumlu değil (Uygunsuz İçerik).'**
  String get moderationAdultContent;

  /// No description provided for @moderationViolence.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen zihni yormayan, auranı yansıtan daha sakin bir avatar seç (Rahatsız Edici İçerik).'**
  String get moderationViolence;

  /// No description provided for @moderationTooLarge.
  ///
  /// In tr, this message translates to:
  /// **'Görselin kozmik ağı yoracak kadar büyük. Lütfen 5MB altı bir fotoğraf seç.'**
  String get moderationTooLarge;

  /// No description provided for @moderationInvalidFormat.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafın sihirli parşömenimiz tarafından okunamadı, format bozuk.'**
  String get moderationInvalidFormat;

  /// No description provided for @moderationUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen bir kozmik dalgalanma oluştu.'**
  String get moderationUnknown;

  /// No description provided for @profileShareInvite.
  ///
  /// In tr, this message translates to:
  /// **'Crack&Wish evrenine katıl! ✨\nRitüel Kodum: {code}\n\nBu kodu girerek +1 Ruh Taşı, +50 Aura ve sürpriz bir Premium Kurabiye kazanabilirsin!\nhttps://crackandwish.com'**
  String profileShareInvite(String code);

  /// No description provided for @profileShareApp.
  ///
  /// In tr, this message translates to:
  /// **'Crack&Wish ile şansını keşfet! •✨\nKurabiye kır, tarot aç, rüya yorumla.\n\nhttps://crackandwish.com'**
  String get profileShareApp;

  /// No description provided for @profileEliteYouAre.
  ///
  /// In tr, this message translates to:
  /// **'Elite Büyücüsün'**
  String get profileEliteYouAre;

  /// No description provided for @profileGoElite.
  ///
  /// In tr, this message translates to:
  /// **'Elite\'e Geç'**
  String get profileGoElite;

  /// No description provided for @profileEliteMystical.
  ///
  /// In tr, this message translates to:
  /// **'Mistik kapıları incele'**
  String get profileEliteMystical;

  /// No description provided for @profileEliteDoor.
  ///
  /// In tr, this message translates to:
  /// **'Farkındalığa giden kapı'**
  String get profileEliteDoor;

  /// No description provided for @profileMyCosmicProfile.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Profilim'**
  String get profileMyCosmicProfile;

  /// No description provided for @profileCosmicDetails.
  ///
  /// In tr, this message translates to:
  /// **'Harita, Saat ve Konum Bilgileri'**
  String get profileCosmicDetails;

  /// No description provided for @profileRestorePurchasesBtn.
  ///
  /// In tr, this message translates to:
  /// **'Satın Alımları Geri Yükle'**
  String get profileRestorePurchasesBtn;

  /// No description provided for @profileRestoreSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Önceki satın alımlarını geri yükle'**
  String get profileRestoreSubtitle;

  /// No description provided for @profileInviteFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarını Davet Et'**
  String get profileInviteFriends;

  /// No description provided for @profileInviteFriendsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik bağlar kur, birlikte kazan'**
  String get profileInviteFriendsDesc;

  /// No description provided for @cosmicChart.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Harita'**
  String get cosmicChart;

  /// No description provided for @cosmicWestern.
  ///
  /// In tr, this message translates to:
  /// **'BATI'**
  String get cosmicWestern;

  /// No description provided for @cosmicAsian.
  ///
  /// In tr, this message translates to:
  /// **'ASYA'**
  String get cosmicAsian;

  /// No description provided for @cosmicMayan.
  ///
  /// In tr, this message translates to:
  /// **'MAYA'**
  String get cosmicMayan;

  /// No description provided for @cosmicRising.
  ///
  /// In tr, this message translates to:
  /// **'YÜKSELEN'**
  String get cosmicRising;

  /// No description provided for @cosmicArrivalDate.
  ///
  /// In tr, this message translates to:
  /// **'DÜNYAYA İNİŞ TARİHİ'**
  String get cosmicArrivalDate;

  /// No description provided for @cosmicBirthTime.
  ///
  /// In tr, this message translates to:
  /// **'DOĞUM SAATİ'**
  String get cosmicBirthTime;

  /// No description provided for @cosmicTimeUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Saat Bilinmiyor'**
  String get cosmicTimeUnknown;

  /// No description provided for @cosmicBirthPlace.
  ///
  /// In tr, this message translates to:
  /// **'DOĞUM YERİ KOORDİNATLARI'**
  String get cosmicBirthPlace;

  /// No description provided for @cosmicCountry.
  ///
  /// In tr, this message translates to:
  /// **'Ülke'**
  String get cosmicCountry;

  /// No description provided for @cosmicSelectCountry.
  ///
  /// In tr, this message translates to:
  /// **'Ülke Seç'**
  String get cosmicSelectCountry;

  /// No description provided for @cosmicCityDistrict.
  ///
  /// In tr, this message translates to:
  /// **'Şehir & İlçe & Köy'**
  String get cosmicCityDistrict;

  /// No description provided for @cosmicSelectDateFirst.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen önce doğum tarihinizi seçin.'**
  String get cosmicSelectDateFirst;

  /// No description provided for @cosmicLockedDays.
  ///
  /// In tr, this message translates to:
  /// **'{days} Gün Sonra Değiştirilebilir'**
  String cosmicLockedDays(int days);

  /// No description provided for @cosmicSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get cosmicSave;

  /// No description provided for @cosmicSearchLocation.
  ///
  /// In tr, this message translates to:
  /// **'Tam Konumu Ara'**
  String get cosmicSearchLocation;

  /// No description provided for @cosmicSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Köy, ilçe veya şehir yaz...'**
  String get cosmicSearchHint;

  /// No description provided for @cosmicAddFreeText.
  ///
  /// In tr, this message translates to:
  /// **'Serbest metin olarak ekle'**
  String get cosmicAddFreeText;

  /// No description provided for @cosmicRequiresTime.
  ///
  /// In tr, this message translates to:
  /// **'Saat Gerekli'**
  String get cosmicRequiresTime;

  /// No description provided for @badgeReady.
  ///
  /// In tr, this message translates to:
  /// **'HAZIR'**
  String get badgeReady;

  /// No description provided for @badgeNew.
  ///
  /// In tr, this message translates to:
  /// **'YENİ'**
  String get badgeNew;

  /// No description provided for @paywallLegal.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliğiniz, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Ödeme, satın alma onayında Apple ID / Google Play hesabınızdan tahsil edilir. Aboneliğinizi mağaza hesap ayarlarınızdan dilediğiniz zaman yönetebilirsiniz.'**
  String get paywallLegal;

  /// No description provided for @cosmicSelect.
  ///
  /// In tr, this message translates to:
  /// **'Seç'**
  String get cosmicSelect;

  /// No description provided for @coffeeRelSingle.
  ///
  /// In tr, this message translates to:
  /// **'Yalnız Ruhum'**
  String get coffeeRelSingle;

  /// No description provided for @coffeeRelInLove.
  ///
  /// In tr, this message translates to:
  /// **'Kalbim Dolu'**
  String get coffeeRelInLove;

  /// No description provided for @coffeeRelEngaged.
  ///
  /// In tr, this message translates to:
  /// **'Nişanlıyım'**
  String get coffeeRelEngaged;

  /// No description provided for @coffeeRelMarried.
  ///
  /// In tr, this message translates to:
  /// **'Evliyim'**
  String get coffeeRelMarried;

  /// No description provided for @coffeeRelComplicated.
  ///
  /// In tr, this message translates to:
  /// **'Karmaşık'**
  String get coffeeRelComplicated;

  /// No description provided for @coffeeFocusLove.
  ///
  /// In tr, this message translates to:
  /// **'Aşk ve Uyum'**
  String get coffeeFocusLove;

  /// No description provided for @coffeeFocusCareer.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer ve Maddiyat'**
  String get coffeeFocusCareer;

  /// No description provided for @coffeeFocusHealing.
  ///
  /// In tr, this message translates to:
  /// **'Şifa ve Huzur'**
  String get coffeeFocusHealing;

  /// No description provided for @coffeeFocusGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel Gelecek'**
  String get coffeeFocusGeneral;

  /// No description provided for @coffeeFocusSurprise.
  ///
  /// In tr, this message translates to:
  /// **'Sürpriz Olsun'**
  String get coffeeFocusSurprise;

  /// No description provided for @coffeeMoodPeaceful.
  ///
  /// In tr, this message translates to:
  /// **'Huzurlu'**
  String get coffeeMoodPeaceful;

  /// No description provided for @coffeeMoodExcited.
  ///
  /// In tr, this message translates to:
  /// **'Heyecanlı'**
  String get coffeeMoodExcited;

  /// No description provided for @coffeeMoodAnxious.
  ///
  /// In tr, this message translates to:
  /// **'Endişeli'**
  String get coffeeMoodAnxious;

  /// No description provided for @coffeeMoodIndecisive.
  ///
  /// In tr, this message translates to:
  /// **'Kararsız'**
  String get coffeeMoodIndecisive;

  /// No description provided for @coffeeMoodEnergetic.
  ///
  /// In tr, this message translates to:
  /// **'Enerjik'**
  String get coffeeMoodEnergetic;

  /// No description provided for @coffeeMoodMelancholic.
  ///
  /// In tr, this message translates to:
  /// **'Hüzünlü'**
  String get coffeeMoodMelancholic;

  /// No description provided for @coffeeAllPhotosRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm fotoğrafları çekin!'**
  String get coffeeAllPhotosRequired;

  /// No description provided for @coffeeNotEnoughStones.
  ///
  /// In tr, this message translates to:
  /// **'Yeterli Ruh Taşın yok!'**
  String get coffeeNotEnoughStones;

  /// No description provided for @coffeeSoulStoneCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Ruh Taşın var'**
  String coffeeSoulStoneCount(int count);

  /// No description provided for @coffeeUseSoulStone.
  ///
  /// In tr, this message translates to:
  /// **'1 Ruh Taşı Kullan'**
  String get coffeeUseSoulStone;

  /// No description provided for @languageSettingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dilini belirle'**
  String get languageSettingsSubtitle;

  /// No description provided for @cosmicSearchHintShort.
  ///
  /// In tr, this message translates to:
  /// **'Ara...'**
  String get cosmicSearchHintShort;

  /// No description provided for @cosmicAddThis.
  ///
  /// In tr, this message translates to:
  /// **'Bunu ekle'**
  String get cosmicAddThis;

  /// No description provided for @horoscopeWesternText.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızlar kariyerin için hizalanıyor. Hızlı ve kararlı adımlar atmalısın.'**
  String get horoscopeWesternText;

  /// No description provided for @horoscopeAsianText.
  ///
  /// In tr, this message translates to:
  /// **'Su elementi devrede. Sezgilerin çok güçlü, bugün sadece kalbini dinle.'**
  String get horoscopeAsianText;

  /// No description provided for @horoscopeMayanText.
  ///
  /// In tr, this message translates to:
  /// **'Ton 4 aktif. Hayatında düzen kurmak ve plan yapmak için mükemmel bir gün.'**
  String get horoscopeMayanText;

  /// No description provided for @horoscopeExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get horoscopeExplore;

  /// No description provided for @cookieDayCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Gün Tamamlandı'**
  String get cookieDayCompleted;

  /// No description provided for @cookieSeeYouTomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın yeni şanslarla tekrar buluşalım.'**
  String get cookieSeeYouTomorrow;

  /// No description provided for @cookieRarityLegendary.
  ///
  /// In tr, this message translates to:
  /// **'Efsanevi'**
  String get cookieRarityLegendary;

  /// No description provided for @cookieRarityRare.
  ///
  /// In tr, this message translates to:
  /// **'Nadir'**
  String get cookieRarityRare;

  /// No description provided for @cookiePremiumCollection.
  ///
  /// In tr, this message translates to:
  /// **'Premium Koleksiyon'**
  String get cookiePremiumCollection;

  /// No description provided for @cookiePurchaseBtn.
  ///
  /// In tr, this message translates to:
  /// **'Satın Al ({price})'**
  String cookiePurchaseBtn(String price);

  /// No description provided for @cookieTapOutsideToClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapatmak için dışına dokun'**
  String get cookieTapOutsideToClose;

  /// No description provided for @cookieAddedToCollection.
  ///
  /// In tr, this message translates to:
  /// **'Kurabiye başarıyla koleksiyonuna eklendi!'**
  String get cookieAddedToCollection;

  /// No description provided for @cookiePremiumFallback.
  ///
  /// In tr, this message translates to:
  /// **'Premium Kurabiye'**
  String get cookiePremiumFallback;

  /// No description provided for @dreamSoulStoneRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Taşı Gerekli'**
  String get dreamSoulStoneRequired;

  /// No description provided for @dreamSoulStoneRequiredDesc.
  ///
  /// In tr, this message translates to:
  /// **'Derin analiz için Ruh Taşı gereklidir.\n\nRuh Taşlarını Aura puanlarını dönüştürerek veya Elite abonelik ile kazanabilirsin.'**
  String get dreamSoulStoneRequiredDesc;

  /// No description provided for @dreamGetElite.
  ///
  /// In tr, this message translates to:
  /// **'Elite Abone Ol'**
  String get dreamGetElite;

  /// No description provided for @dreamClinicalGateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Klinik Analiz Kapısı'**
  String get dreamClinicalGateTitle;

  /// No description provided for @dreamClinicalGateDesc.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Ruh Taşın: {soulStones}\n\nBu klinik seviye derin psikolojik analiz için 1 Ruh Taşı harcanır.'**
  String dreamClinicalGateDesc(int soulStones);

  /// No description provided for @dreamUseOneStone.
  ///
  /// In tr, this message translates to:
  /// **'1 Ruh Taşı Kullan'**
  String get dreamUseOneStone;

  /// No description provided for @dreamDeepAnalysisBgPreparing.
  ///
  /// In tr, this message translates to:
  /// **'Derin Analiz arka planda hazırlanıyor. Tamamlandığında bildirim alacaksınız.'**
  String get dreamDeepAnalysisBgPreparing;

  /// No description provided for @dreamYourSoulStones.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Taşların'**
  String get dreamYourSoulStones;

  /// No description provided for @dreamSoulStonesRemaining.
  ///
  /// In tr, this message translates to:
  /// **'{count} Ruh Taşın var'**
  String dreamSoulStonesRemaining(int count);

  /// No description provided for @dreamSoulStonesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Taşın bitti'**
  String get dreamSoulStonesEmpty;

  /// No description provided for @dreamRequiredForDeep.
  ///
  /// In tr, this message translates to:
  /// **'Derin Analiz için gerekli'**
  String get dreamRequiredForDeep;

  /// No description provided for @dreamEachAnalysisCost.
  ///
  /// In tr, this message translates to:
  /// **'Her analiz 1 Ruh Taşı harcar'**
  String get dreamEachAnalysisCost;

  /// No description provided for @dreamEliteRefillActive.
  ///
  /// In tr, this message translates to:
  /// **'Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir'**
  String get dreamEliteRefillActive;

  /// No description provided for @dreamEliteRefillPromo.
  ///
  /// In tr, this message translates to:
  /// **'Elite ile her gece 5 Ruh Taşı kazan'**
  String get dreamEliteRefillPromo;

  /// No description provided for @dreamWatchAd.
  ///
  /// In tr, this message translates to:
  /// **'Reklam İzle'**
  String get dreamWatchAd;

  /// No description provided for @dreamBgAnalyzing.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanız arka planda analiz ediliyor. Tamamlandığında bildirim alacaksınız.'**
  String get dreamBgAnalyzing;

  /// No description provided for @dreamDeepAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'Derin Analiz'**
  String get dreamDeepAnalysis;

  /// No description provided for @dreamDiscoverSecrets.
  ///
  /// In tr, this message translates to:
  /// **'Sırlarını keşfet'**
  String get dreamDiscoverSecrets;

  /// No description provided for @dreamDidYouKnow.
  ///
  /// In tr, this message translates to:
  /// **'Biliyor muydun?'**
  String get dreamDidYouKnow;

  /// No description provided for @dreamNeuroPsychAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'NÖRO-PSİKOLOJİK ANALİZ'**
  String get dreamNeuroPsychAnalysis;

  /// No description provided for @dreamYourDream.
  ///
  /// In tr, this message translates to:
  /// **'RÜYANIZ'**
  String get dreamYourDream;

  /// No description provided for @dreamEmotionalProfile.
  ///
  /// In tr, this message translates to:
  /// **'Duygusal Profil'**
  String get dreamEmotionalProfile;

  /// No description provided for @dreamEmotionalProfileSub.
  ///
  /// In tr, this message translates to:
  /// **'Rüya sırasındaki psikolojik katmanlarınız'**
  String get dreamEmotionalProfileSub;

  /// No description provided for @dreamShadowSelf.
  ///
  /// In tr, this message translates to:
  /// **'Gölge Benlik'**
  String get dreamShadowSelf;

  /// No description provided for @dreamShadowSelfSub.
  ///
  /// In tr, this message translates to:
  /// **'Bastırdığınız ve yüzleşmekten kaçındığınız yönler'**
  String get dreamShadowSelfSub;

  /// No description provided for @dreamRecurringPatterns.
  ///
  /// In tr, this message translates to:
  /// **'Kalıplar ve Davranışlar'**
  String get dreamRecurringPatterns;

  /// No description provided for @dreamRecurringPatternsSub.
  ///
  /// In tr, this message translates to:
  /// **'Hayatınızda sürekli tekrar eden psikolojik döngüler'**
  String get dreamRecurringPatternsSub;

  /// No description provided for @dreamSuggestedRitual.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen Ritüel: {title}'**
  String dreamSuggestedRitual(String title);

  /// No description provided for @dreamSuggestedRitualSub.
  ///
  /// In tr, this message translates to:
  /// **'Bu rüyanın etkisini yönetmek için size özel eylem'**
  String get dreamSuggestedRitualSub;

  /// No description provided for @dreamScienceNote.
  ///
  /// In tr, this message translates to:
  /// **'Bilimsel Not:'**
  String get dreamScienceNote;

  /// No description provided for @dreamWriteNewDream.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bir Rüya Yaz'**
  String get dreamWriteNewDream;

  /// No description provided for @dreamNoMonthDreams.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay henüz rüya yazmadın ✨'**
  String get dreamNoMonthDreams;

  /// No description provided for @dreamMysteriousDream.
  ///
  /// In tr, this message translates to:
  /// **'Gizemli Rüya'**
  String get dreamMysteriousDream;

  /// No description provided for @dreamStandardAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'STANDART ANALİZ'**
  String get dreamStandardAnalysis;

  /// No description provided for @dreamGeneralAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'Genel Analiz'**
  String get dreamGeneralAnalysis;

  /// No description provided for @dreamPsychological.
  ///
  /// In tr, this message translates to:
  /// **'Psikolojik Örüntü'**
  String get dreamPsychological;

  /// No description provided for @dreamSpiritual2.
  ///
  /// In tr, this message translates to:
  /// **'Ruhsal / Sembolik'**
  String get dreamSpiritual2;

  /// No description provided for @dreamAdvice.
  ///
  /// In tr, this message translates to:
  /// **'Öneri & Adım'**
  String get dreamAdvice;

  /// No description provided for @dreamDeepenedInsights.
  ///
  /// In tr, this message translates to:
  /// **'Derinleştirilmiş Analiz'**
  String get dreamDeepenedInsights;

  /// No description provided for @dreamEliteCreditsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Elite Okuma Hakların'**
  String get dreamEliteCreditsTitle;

  /// No description provided for @dreamReadingCreditsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Hakların'**
  String get dreamReadingCreditsTitle;

  /// No description provided for @dreamCreditsRemaining.
  ///
  /// In tr, this message translates to:
  /// **'{count} okuma hakkın var'**
  String dreamCreditsRemaining(int count);

  /// No description provided for @dreamDailyLimitReached.
  ///
  /// In tr, this message translates to:
  /// **'Bugünlük hakkın bitti'**
  String get dreamDailyLimitReached;

  /// No description provided for @dreamZeroCredits.
  ///
  /// In tr, this message translates to:
  /// **'0 okuma hakkın var'**
  String get dreamZeroCredits;

  /// No description provided for @dreamDailyPremiumReads.
  ///
  /// In tr, this message translates to:
  /// **'Günlük {count} Rüya Yorumu hakkı'**
  String dreamDailyPremiumReads(int count);

  /// No description provided for @dreamNoAdsRequired.
  ///
  /// In tr, this message translates to:
  /// **'Reklam izleme zorunluluğu yok'**
  String get dreamNoAdsRequired;

  /// No description provided for @dreamCreditsResetNightly.
  ///
  /// In tr, this message translates to:
  /// **'Haklar her gece sıfırlanır'**
  String get dreamCreditsResetNightly;

  /// No description provided for @dreamOneFreeDaily.
  ///
  /// In tr, this message translates to:
  /// **'Her gün 1 ücretsiz yorum'**
  String get dreamOneFreeDaily;

  /// No description provided for @dreamWatchAdsForCredits.
  ///
  /// In tr, this message translates to:
  /// **'Reklam ile ek {maxAds} hak ({watched}/{maxAds})'**
  String dreamWatchAdsForCredits(int maxAds, int watched);

  /// No description provided for @dreamUnconsciousFrequencies.
  ///
  /// In tr, this message translates to:
  /// **'BİLİNÇDIŞI FREKANSLAR'**
  String get dreamUnconsciousFrequencies;

  /// No description provided for @dreamOrbEmotion.
  ///
  /// In tr, this message translates to:
  /// **'DUYGU YÜKÜ'**
  String get dreamOrbEmotion;

  /// No description provided for @dreamOrbEntropy.
  ///
  /// In tr, this message translates to:
  /// **'BELİRSİZLİK'**
  String get dreamOrbEntropy;

  /// No description provided for @dreamOrbActivity.
  ///
  /// In tr, this message translates to:
  /// **'BEYİN AKT.'**
  String get dreamOrbActivity;

  /// No description provided for @dreamOrbResidue.
  ///
  /// In tr, this message translates to:
  /// **'YAKIN GEÇMİŞ'**
  String get dreamOrbResidue;

  /// No description provided for @dreamHighConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Güven'**
  String get dreamHighConfidence;

  /// No description provided for @dreamModerateConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Orta Güven'**
  String get dreamModerateConfidence;

  /// No description provided for @dreamLowConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Düşük Güven'**
  String get dreamLowConfidence;

  /// No description provided for @dreamCoreThematicPattern.
  ///
  /// In tr, this message translates to:
  /// **'ANA TEMATİK ÖRÜNTÜ'**
  String get dreamCoreThematicPattern;

  /// No description provided for @dreamMetricEmotionalLoad.
  ///
  /// In tr, this message translates to:
  /// **'Duygusal\nYoğunluk'**
  String get dreamMetricEmotionalLoad;

  /// No description provided for @dreamMetricEmotionalLoadDesc.
  ///
  /// In tr, this message translates to:
  /// **'Rüyan sırasında beyninin duygusal merkezi (amigdala) ne kadar yoğun çalıştı. Yüksekse rüyanda güçlü duygular (huzur, mutluluk, korku, heyecan) yaşandı.'**
  String get dreamMetricEmotionalLoadDesc;

  /// No description provided for @dreamMetricUncertaintyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanda ne kadar mantıksız veya tutarsız olay yaşandı. Yüksekse mekanlar aniden değişti, olaylar mantığa aykırıydı.'**
  String get dreamMetricUncertaintyDesc;

  /// No description provided for @dreamMetricRecentMemory.
  ///
  /// In tr, this message translates to:
  /// **'Yakın\nGeçmiş'**
  String get dreamMetricRecentMemory;

  /// No description provided for @dreamMetricRecentMemoryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanın ne kadarı son günlerde yaşadığın gerçek olaylardan etkilenmiş. Yüksekse beynin günlük anıları rüyada işliyor.'**
  String get dreamMetricRecentMemoryDesc;

  /// No description provided for @dreamMetricAgency.
  ///
  /// In tr, this message translates to:
  /// **'Ajans /\nKontrol'**
  String get dreamMetricAgency;

  /// No description provided for @dreamMetricAgencyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanda olayları ne kadar kontrol edebildin. Düşükse sadece izledin, yüksekse kararlar aldın ve müdahale ettin.'**
  String get dreamMetricAgencyDesc;

  /// No description provided for @dreamSeverityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get dreamSeverityHigh;

  /// No description provided for @dreamSeverityNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get dreamSeverityNormal;

  /// No description provided for @dreamSeverityLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get dreamSeverityLow;

  /// No description provided for @dreamCognitiveDistribution.
  ///
  /// In tr, this message translates to:
  /// **'BİLİŞSEL DAĞILIM'**
  String get dreamCognitiveDistribution;

  /// No description provided for @dreamTapToExpand.
  ///
  /// In tr, this message translates to:
  /// **'GENİŞLETMEK İÇİN DOKUN'**
  String get dreamTapToExpand;

  /// No description provided for @dreamNeurologicalBasis.
  ///
  /// In tr, this message translates to:
  /// **'Nörolojik Taban'**
  String get dreamNeurologicalBasis;

  /// No description provided for @dreamEvidenceBase.
  ///
  /// In tr, this message translates to:
  /// **'BU SONUCA NEDEN VARDIK?'**
  String get dreamEvidenceBase;

  /// No description provided for @dreamRootCause.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanın Gerçek Sebebi'**
  String get dreamRootCause;

  /// No description provided for @dreamAbsolutely.
  ///
  /// In tr, this message translates to:
  /// **'Kesinlikle'**
  String get dreamAbsolutely;

  /// No description provided for @dreamMaybe.
  ///
  /// In tr, this message translates to:
  /// **'Olabilir'**
  String get dreamMaybe;

  /// No description provided for @dreamNotSure.
  ///
  /// In tr, this message translates to:
  /// **'Emin Değilim'**
  String get dreamNotSure;

  /// No description provided for @dreamDreamEssence.
  ///
  /// In tr, this message translates to:
  /// **'RÜYANIN ÖZÜ'**
  String get dreamDreamEssence;

  /// No description provided for @dreamClarifyingResponses.
  ///
  /// In tr, this message translates to:
  /// **'ANALİZİ NETLEŞTİREN YANITLAR'**
  String get dreamClarifyingResponses;

  /// No description provided for @dreamCosmicRhythmSynced.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Ritmin Bağlandı'**
  String get dreamCosmicRhythmSynced;

  /// No description provided for @dreamCosmicRhythmSyncedDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uyku döngünüze göre özel rüya bildirimleri alacaksınız.'**
  String get dreamCosmicRhythmSyncedDesc;

  /// No description provided for @dreamSyncSleepData.
  ///
  /// In tr, this message translates to:
  /// **'Uyku Verini Senkronize Et'**
  String get dreamSyncSleepData;

  /// No description provided for @dreamSyncSleepDataDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tam uyandığın anı tespit edip en derin rüyanı sormasına izin ver.'**
  String get dreamSyncSleepDataDesc;

  /// No description provided for @dreamAwarenessFallback.
  ///
  /// In tr, this message translates to:
  /// **'Bu farkındalık yeni bir yolun başlangıcıdır. Şimdi yüzleşme zamanı.'**
  String get dreamAwarenessFallback;

  /// No description provided for @dreamExtractingEssence.
  ///
  /// In tr, this message translates to:
  /// **'Rüyanın özü derleniyor...'**
  String get dreamExtractingEssence;

  /// No description provided for @dreamNoReasoning.
  ///
  /// In tr, this message translates to:
  /// **'Bu metrik için özel bir açıklama üretilmemiş.'**
  String get dreamNoReasoning;

  /// No description provided for @dreamNotAnalyzable.
  ///
  /// In tr, this message translates to:
  /// **'Bunun bir rüyaya ait olduğuna emin misin?\nLütfen uykudayken zihninde canlanan gerçek bir sahneyi anlat.'**
  String get dreamNotAnalyzable;

  /// No description provided for @owlTabFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarım'**
  String get owlTabFriends;

  /// No description provided for @owlTabConnections.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantılar'**
  String get owlTabConnections;

  /// No description provided for @owlTabInbox.
  ///
  /// In tr, this message translates to:
  /// **'Gelen Mektup'**
  String get owlTabInbox;

  /// No description provided for @owlSearchCosmic.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik evrende ara...'**
  String get owlSearchCosmic;

  /// No description provided for @owlSearchFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş ara...'**
  String get owlSearchFriends;

  /// No description provided for @owlPhoneContacts.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Rehberin'**
  String get owlPhoneContacts;

  /// No description provided for @owlNoOneFoundCosmic.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik evrende kimse bulunamadı.'**
  String get owlNoOneFoundCosmic;

  /// No description provided for @owlFoundInCosmic.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Evrende Bulunanlar'**
  String get owlFoundInCosmic;

  /// No description provided for @owlUnknownProfile.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Profil'**
  String get owlUnknownProfile;

  /// No description provided for @owlFriendRequestSent.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisine arkadaşlık isteği gönderildi!'**
  String owlFriendRequestSent(String name);

  /// No description provided for @owlRequestSentStatus.
  ///
  /// In tr, this message translates to:
  /// **'Gönderildi'**
  String get owlRequestSentStatus;

  /// No description provided for @owlSendRequestAction.
  ///
  /// In tr, this message translates to:
  /// **'İstek Gönder'**
  String get owlSendRequestAction;

  /// No description provided for @owlConnectContacts.
  ///
  /// In tr, this message translates to:
  /// **'Rehberini Bağla'**
  String get owlConnectContacts;

  /// No description provided for @owlConnectContactsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarını anında bul.\nRehberin ASLA sunucularda saklanmaz.'**
  String get owlConnectContactsDesc;

  /// No description provided for @owlNoContactsFound.
  ///
  /// In tr, this message translates to:
  /// **'Crack&Wish Evreninde\nKimseyi Bulamadık'**
  String get owlNoContactsFound;

  /// No description provided for @owlNoContactsFoundDesc.
  ///
  /// In tr, this message translates to:
  /// **'Onları davet ederek kozmik enerjiyi başlatabilirsin!'**
  String get owlNoContactsFoundDesc;

  /// No description provided for @owlUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen'**
  String get owlUnknown;

  /// No description provided for @owlAppUserLabel.
  ///
  /// In tr, this message translates to:
  /// **'Crack&Wish Kullanıcısı'**
  String get owlAppUserLabel;

  /// No description provided for @owlInContactsLabel.
  ///
  /// In tr, this message translates to:
  /// **'Rehberinde ekli'**
  String get owlInContactsLabel;

  /// No description provided for @owlNoFriendsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz arkadaşın yok'**
  String get owlNoFriendsYet;

  /// No description provided for @owlNoResultsFound.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get owlNoResultsFound;

  /// No description provided for @owlFriendRequests.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlık İstekleri'**
  String get owlFriendRequests;

  /// No description provided for @owlFriendsHeader.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşların'**
  String get owlFriendsHeader;

  /// No description provided for @owlAcceptAction.
  ///
  /// In tr, this message translates to:
  /// **'Kabul'**
  String get owlAcceptAction;

  /// No description provided for @owlRejectAction.
  ///
  /// In tr, this message translates to:
  /// **'Red'**
  String get owlRejectAction;

  /// No description provided for @owlInviteReward.
  ///
  /// In tr, this message translates to:
  /// **'+2 Ruh Taşı'**
  String get owlInviteReward;

  /// No description provided for @owlInviteShareMessage.
  ///
  /// In tr, this message translates to:
  /// **'Karanlığı birlikte aydınlatalım! ✨\nCrack Wish\'e aşağıdaki davet bağlantımdan katıl, otomatik olarak birbirimize bağlanıp Başlangıç Ödülleri kazanalım!\n\nDavet Bağlantım:\nhttps://crackwish.com/invite/{username}'**
  String owlInviteShareMessage(String username);

  /// No description provided for @owlInviteFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş Davet Et'**
  String get owlInviteFriends;

  /// No description provided for @owlInviteFriendsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik evreni yansıt'**
  String get owlInviteFriendsDesc;

  /// No description provided for @owlNoLettersYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz mektup yok'**
  String get owlNoLettersYet;

  /// No description provided for @owlLetterSentNotification.
  ///
  /// In tr, this message translates to:
  /// **'{name} mektup gönderdi...'**
  String owlLetterSentNotification(String name);

  /// No description provided for @owlOnItsWay.
  ///
  /// In tr, this message translates to:
  /// **'Baykuş yolda 🕊️'**
  String get owlOnItsWay;

  /// No description provided for @owlLetterCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} adet mektup'**
  String owlLetterCount(int count);

  /// No description provided for @owlUnreadCountBadge.
  ///
  /// In tr, this message translates to:
  /// **'{count} Yeni'**
  String owlUnreadCountBadge(int count);

  /// No description provided for @owlIUnderstand.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get owlIUnderstand;

  /// No description provided for @owlInviteHowTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Davet Etmek İstersin?'**
  String get owlInviteHowTitle;

  /// No description provided for @owlInviteHowSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu kişiye kozmik anahtarını nasıl göndermek istiyorsun?'**
  String get owlInviteHowSubtitle;

  /// No description provided for @owlInviteSendAsMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj olarak gönder'**
  String get owlInviteSendAsMessage;

  /// No description provided for @owlInviteSMSSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Klasik mesaj ile yolla'**
  String get owlInviteSMSSubtitle;

  /// No description provided for @owlInviteOtherApps.
  ///
  /// In tr, this message translates to:
  /// **'Diğer Uygulamalar'**
  String get owlInviteOtherApps;

  /// No description provided for @owlInviteOtherAppsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Instagram, TikTok, X vb.'**
  String get owlInviteOtherAppsSubtitle;

  /// No description provided for @owlWhatsAppNotFound.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp bulunamadı'**
  String get owlWhatsAppNotFound;

  /// No description provided for @owlSMSNotFound.
  ///
  /// In tr, this message translates to:
  /// **'SMS uygulaması bulunamadı'**
  String get owlSMSNotFound;

  /// No description provided for @owlDisconnectAction.
  ///
  /// In tr, this message translates to:
  /// **'Bağı Kes'**
  String get owlDisconnectAction;

  /// No description provided for @owlDisconnectConfirm.
  ///
  /// In tr, this message translates to:
  /// **'{name} ile arandaki sihirli bağı koparmak istediğine emin misin?'**
  String owlDisconnectConfirm(String name);

  /// No description provided for @owlDisconnectConfirmButton.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Kopar'**
  String get owlDisconnectConfirmButton;

  /// No description provided for @owlCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get owlCancel;

  /// No description provided for @owlSendMagic.
  ///
  /// In tr, this message translates to:
  /// **'Gönder (Tılsımlı)'**
  String get owlSendMagic;

  /// No description provided for @owlSend.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get owlSend;

  /// No description provided for @owlCookieAdded.
  ///
  /// In tr, this message translates to:
  /// **'Kurabiye Eklendi'**
  String get owlCookieAdded;

  /// No description provided for @owlAddCookie.
  ///
  /// In tr, this message translates to:
  /// **'Kurabiye Ekle'**
  String get owlAddCookie;

  /// No description provided for @owlNoCookiesInCollection.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonunda kurabiye yok'**
  String get owlNoCookiesInCollection;

  /// No description provided for @owlWriteLetterHint.
  ///
  /// In tr, this message translates to:
  /// **'Mektubunu yaz...'**
  String get owlWriteLetterHint;

  /// No description provided for @owlSendCookie.
  ///
  /// In tr, this message translates to:
  /// **'Kurabiye At'**
  String get owlSendCookie;

  /// No description provided for @zodiacMeasureHarmony.
  ///
  /// In tr, this message translates to:
  /// **'KOZMİK UYUMUNU ÖLÇ'**
  String get zodiacMeasureHarmony;

  /// No description provided for @zodiacDiscoverEnergy.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızların rehberliğinde ikili enerjini keşfet'**
  String get zodiacDiscoverEnergy;

  /// No description provided for @zodiacChooseFriend.
  ///
  /// In tr, this message translates to:
  /// **'ARKADAŞ SEÇ'**
  String get zodiacChooseFriend;

  /// No description provided for @zodiacPros.
  ///
  /// In tr, this message translates to:
  /// **'Avantajlar'**
  String get zodiacPros;

  /// No description provided for @zodiacCons.
  ///
  /// In tr, this message translates to:
  /// **'Zorluklar'**
  String get zodiacCons;

  /// No description provided for @zodiacAdvice.
  ///
  /// In tr, this message translates to:
  /// **'Tavsiye'**
  String get zodiacAdvice;

  /// No description provided for @zodiacDailyWhisperSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün fısıltısını hisset ve\nruhsal portrenin sırlarını çöz.'**
  String get zodiacDailyWhisperSubtitle;

  /// No description provided for @zodiacDailyWhisperHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün mesajı & ruhsal portre'**
  String get zodiacDailyWhisperHeadline;

  /// No description provided for @zodiacOpenGuide.
  ///
  /// In tr, this message translates to:
  /// **'Rehberi Arala'**
  String get zodiacOpenGuide;

  /// No description provided for @zodiacNoFriends.
  ///
  /// In tr, this message translates to:
  /// **'Henüz arkadaşın yok'**
  String get zodiacNoFriends;

  /// No description provided for @zodiacSelect.
  ///
  /// In tr, this message translates to:
  /// **'SEÇ'**
  String get zodiacSelect;

  /// No description provided for @zodiacQuestCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Serüven Tamamlandı'**
  String get zodiacQuestCompleted;

  /// No description provided for @zodiacQuestCompletedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Evrenin ritmiyle tamamen uyumlandın.'**
  String get zodiacQuestCompletedSubtitle;

  /// No description provided for @zodiacRewardAura.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan Ödül:\n+4 AURA'**
  String get zodiacRewardAura;

  /// No description provided for @zodiacStartNewQuest.
  ///
  /// In tr, this message translates to:
  /// **'YENİ SERÜVENE BAŞLA'**
  String get zodiacStartNewQuest;

  /// No description provided for @zodiacDailyQuestTitle.
  ///
  /// In tr, this message translates to:
  /// **'{days} GÜNLÜK SERÜVEN'**
  String zodiacDailyQuestTitle(int days);

  /// No description provided for @zodiacDailyQuestDesc.
  ///
  /// In tr, this message translates to:
  /// **'\"{weakness}\" Zaafını Yık'**
  String zodiacDailyQuestDesc(String weakness);

  /// No description provided for @zodiacQuestDayProgress.
  ///
  /// In tr, this message translates to:
  /// **'GÜN {current} / {total}'**
  String zodiacQuestDayProgress(int current, int total);

  /// No description provided for @zodiacQuestTodayDiscovery.
  ///
  /// In tr, this message translates to:
  /// **'GÜNÜN KEŞFİ'**
  String get zodiacQuestTodayDiscovery;

  /// No description provided for @zodiacQuestCompletedToday.
  ///
  /// In tr, this message translates to:
  /// **'BUGÜN TAMAMLANDI'**
  String get zodiacQuestCompletedToday;

  /// No description provided for @zodiacQuestCompleteNow.
  ///
  /// In tr, this message translates to:
  /// **'SERÜVENİ TAMAMLA'**
  String get zodiacQuestCompleteNow;

  /// No description provided for @zodiacQuestMarkCompleted.
  ///
  /// In tr, this message translates to:
  /// **'BUGÜNÜ TAMAMLADIM'**
  String get zodiacQuestMarkCompleted;

  /// No description provided for @zodiacLoveHarmony.
  ///
  /// In tr, this message translates to:
  /// **'AŞK UYUMU'**
  String get zodiacLoveHarmony;

  /// No description provided for @zodiacFriendshipHarmony.
  ///
  /// In tr, this message translates to:
  /// **'ARKADAŞLIK'**
  String get zodiacFriendshipHarmony;

  /// No description provided for @zodiacCommunicationHarmony.
  ///
  /// In tr, this message translates to:
  /// **'İLETİŞİM & ZİHİN'**
  String get zodiacCommunicationHarmony;

  /// No description provided for @zodiacWorkHarmony.
  ///
  /// In tr, this message translates to:
  /// **'ORTAK ÇALIŞMA'**
  String get zodiacWorkHarmony;

  /// No description provided for @zodiacAdventureHarmony.
  ///
  /// In tr, this message translates to:
  /// **'MACERA & EĞLENCE'**
  String get zodiacAdventureHarmony;

  /// No description provided for @zodiacViralDynamics.
  ///
  /// In tr, this message translates to:
  /// **'VİRAL DİNAMİKLER'**
  String get zodiacViralDynamics;

  /// No description provided for @zodiacDeepSynastryMap.
  ///
  /// In tr, this message translates to:
  /// **'DERİN SİNASTRİ HARİTASI'**
  String get zodiacDeepSynastryMap;

  /// No description provided for @zodiacSynastrySubtitle1.
  ///
  /// In tr, this message translates to:
  /// **'{name} ile arandaki uyum sadece Güneş burçlarıyla sınırlandırılmadı.'**
  String zodiacSynastrySubtitle1(String name);

  /// No description provided for @zodiacSynastrySubtitle2.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik algoritma, gizlilik esasına dayanarak her iki tarafın da astrolojik doğum haritalarını, Ay ve Yükselen evrelerini perde arkasında çaprazlayarak bu analizi tamamen size özel hale getirdi.'**
  String get zodiacSynastrySubtitle2;

  /// No description provided for @zodiacDailyWhisperTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün Fısıltısı'**
  String get zodiacDailyWhisperTitle;

  /// No description provided for @zodiacChooseSign.
  ///
  /// In tr, this message translates to:
  /// **'BURÇ SEÇ'**
  String get zodiacChooseSign;

  /// No description provided for @zodiacCosmicGuide.
  ///
  /// In tr, this message translates to:
  /// **'KOZMİK REHBERİN'**
  String get zodiacCosmicGuide;

  /// No description provided for @zodiacNew.
  ///
  /// In tr, this message translates to:
  /// **'YENİ'**
  String get zodiacNew;

  /// No description provided for @zodiacCosmicHarmonyTitle.
  ///
  /// In tr, this message translates to:
  /// **'KOZMİK UYUM'**
  String get zodiacCosmicHarmonyTitle;

  /// No description provided for @zodiacAwesome.
  ///
  /// In tr, this message translates to:
  /// **'HARİKA'**
  String get zodiacAwesome;

  /// No description provided for @zodiacSpiritPortrait.
  ///
  /// In tr, this message translates to:
  /// **'Ruhsal Portre'**
  String get zodiacSpiritPortrait;

  /// No description provided for @onboardingFeatureStepTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seni Neler Bekliyor?'**
  String get onboardingFeatureStepTitle;

  /// No description provided for @onboardingFeatureStepSub.
  ///
  /// In tr, this message translates to:
  /// **'Evrenin fısıltılarına kulak verip kaderini keşfetmeye hazır mısın?'**
  String get onboardingFeatureStepSub;

  /// No description provided for @onboardingNameStepTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seni Tanıyalım'**
  String get onboardingNameStepTitle;

  /// No description provided for @onboardingNameStepSub.
  ///
  /// In tr, this message translates to:
  /// **'Ruh eşlerinin seni bulabilmesi için profilini oluştur ve kozmik kimliğini belirle.'**
  String get onboardingNameStepSub;

  /// No description provided for @onboardingDateStepTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik Koordinat'**
  String get onboardingDateStepTitle;

  /// No description provided for @onboardingDateStepSub.
  ///
  /// In tr, this message translates to:
  /// **'Astrolojik haritanın temeli için doğduğun anı seç.'**
  String get onboardingDateStepSub;

  /// No description provided for @onboardingFocusStepTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kalbinin Pusulası'**
  String get onboardingFocusStepTitle;

  /// No description provided for @onboardingFocusStepSub.
  ///
  /// In tr, this message translates to:
  /// **'Niyetini belirle, yolunu çizelim.'**
  String get onboardingFocusStepSub;

  /// No description provided for @onboardingDreamStepTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bilinçaltının Sesi'**
  String get onboardingDreamStepTitle;

  /// No description provided for @onboardingDreamStepSub.
  ///
  /// In tr, this message translates to:
  /// **'Rüyaların sana nasıl ulaşıyor?'**
  String get onboardingDreamStepSub;

  /// No description provided for @onboardingSleepStepTitle.
  ///
  /// In tr, this message translates to:
  /// **'İçsel Pusulan'**
  String get onboardingSleepStepTitle;

  /// No description provided for @onboardingSleepStepSub.
  ///
  /// In tr, this message translates to:
  /// **'Hayatındaki kadersel dönüm noktalarında yolunu nasıl bulursun?'**
  String get onboardingSleepStepSub;

  /// No description provided for @onboardingFeatureAstrology.
  ///
  /// In tr, this message translates to:
  /// **'Sana Özel Astroloji Haritası'**
  String get onboardingFeatureAstrology;

  /// No description provided for @onboardingFeatureTarot.
  ///
  /// In tr, this message translates to:
  /// **'Yol Gösterici Tarot Serüveni'**
  String get onboardingFeatureTarot;

  /// No description provided for @onboardingFeatureCoffee.
  ///
  /// In tr, this message translates to:
  /// **'Telvelerde Gizlenen Kadim Kahve Falı Sırları'**
  String get onboardingFeatureCoffee;

  /// No description provided for @onboardingFeatureDream.
  ///
  /// In tr, this message translates to:
  /// **'Bilinçaltı Rüya Analizleri'**
  String get onboardingFeatureDream;

  /// No description provided for @onboardingFeatureZodiac.
  ///
  /// In tr, this message translates to:
  /// **'Mistik Çin & Maya Uyumları'**
  String get onboardingFeatureZodiac;

  /// No description provided for @onboardingWelcomeTagline.
  ///
  /// In tr, this message translates to:
  /// **'Bugün umutlarım hayallerimden daha büyük.'**
  String get onboardingWelcomeTagline;

  /// No description provided for @onboardingFinalTagline.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik haritanı güvenceye almak için tıkla.'**
  String get onboardingFinalTagline;
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
