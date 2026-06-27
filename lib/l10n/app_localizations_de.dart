// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Crack&Wish';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Wählen Sie Sprache aus';

  @override
  String get systemLanguage => 'System';

  @override
  String get turkish => 'Türkisch';

  @override
  String get english => 'Englisch';

  @override
  String get close => 'Schließen';

  @override
  String languageValue(Object value) {
    return 'Ausgewählt:$value';
  }

  @override
  String get navHome => 'Heim';

  @override
  String get navCollection => 'Sammlung';

  @override
  String get navProfile => 'Profil';

  @override
  String get dailyCookieTitle => 'Tägliches Plätzchen';

  @override
  String get dailyCookieSubtitle =>
      'Tippen Sie hier, um Ihr Glück zu versuchen';

  @override
  String get luckyNumber => 'Glückszahl';

  @override
  String get luckyColor => 'Glücksfarbe';

  @override
  String get luckLabel => 'Glück';

  @override
  String get todayFortune => 'Das heutige Vermögen';

  @override
  String get shareButton => '📸 Teilen';

  @override
  String fortuneShareText(
    Object emoji,
    Object title,
    Object meaning,
    Object number,
    Object color,
    Object percent,
  ) {
    return '$emoji$title${meaning}Glückszahl:${number}Glücksfarbe:${color}Glück:$percent%\n\nVon der Glückskeks-App 🥠';
  }

  @override
  String get themeSelectTitle => 'Wählen Sie Thema aus';

  @override
  String themeSelected(Object value) {
    return 'Ausgewähltes Thema:$value';
  }

  @override
  String get themeGalleryTitle => 'Themengalerie';

  @override
  String get themeGalleryOpen => 'Gehen Sie zur Themenliste';

  @override
  String get themeGalleryLimited =>
      'Die Themengalerie ist derzeit auf zwei Optionen beschränkt';

  @override
  String get statCookies => 'Kekse';

  @override
  String get statStreakDays => 'Streak-Tage';

  @override
  String get statDreams => 'Träume';

  @override
  String get statMood => 'Stimmung';

  @override
  String get statTheme => 'Heute...';

  @override
  String get statCollection => 'Mein Keks';

  @override
  String get statTalisman => 'Talisman';

  @override
  String get moodGood => 'Gut';

  @override
  String get moodSad => 'Traurig';

  @override
  String get moodBad => 'Schlecht';

  @override
  String get moodHappy => 'Glücklich';

  @override
  String get moodGreat => 'Großartig';

  @override
  String get shortcutCollection => 'Sammlung';

  @override
  String get shortcutHistory => 'Geschichte';

  @override
  String get shortcutFavorites => 'Favoriten';

  @override
  String get sectionShortcuts => 'Verknüpfungen';

  @override
  String get sectionActivity => 'Aktivität';

  @override
  String get menuBadges => 'Abzeichen';

  @override
  String get menuBadgesSubtitle => 'Erfolge und Level';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuSettingsSubtitle => 'Benachrichtigungen, Thema, Datenschutz';

  @override
  String get menuHelpAbout => 'Hilfe und Info';

  @override
  String get menuHelpAboutSubtitle => 'FAQ und Versionsinformationen';

  @override
  String get menuShare => 'Aktie';

  @override
  String get menuShareSubtitle => 'Teilen Sie Ihr Profil mit Freunden';

  @override
  String get activityTarotOpenedTitle => 'Tarot-Lesung eröffnet';

  @override
  String get activityTarotOpenedSubtitle => 'Heute • Karte: Stern';

  @override
  String activityCookiesOpenedTitle(Object count) {
    return '${count}Kekse geknackt';
  }

  @override
  String get activityCookiesOpenedSubtitle =>
      'Gestern • Neue Nachrichten geöffnet';

  @override
  String get activityDreamSavedTitle => 'Traumdeutung gerettet';

  @override
  String get activityDreamSavedSubtitle => 'Vor 2 Tagen';

  @override
  String get profileUserTitle => 'Benutzer';

  @override
  String get profileSubtitle => 'Weniger Lärm, mehr Du';

  @override
  String get tagTarot => 'Tarot';

  @override
  String get tagDream => 'Traum';

  @override
  String get tagCollection => 'Sammlung';

  @override
  String get zodiacTitle => '⭐ Sternzeichen-Lesung';

  @override
  String zodiacDailyTitle(Object name) {
    return '$name– Tägliche Lektüre';
  }

  @override
  String get zodiacDailyBody =>
      'Du hast diese Woche Glück in der Liebe! Karrieremöglichkeiten liegen vor Ihrer Tür – halten Sie die Augen offen. Deine Energie ist hoch, nutze sie. Es ist eine perfekte Zeit für neue Projekte. Ihre Kommunikationsfähigkeiten sind auf dem Höhepunkt, nutzen Sie sie.';

  @override
  String get zodiacLove => 'Liebe';

  @override
  String get zodiacCareer => 'Karriere';

  @override
  String get zodiacMoney => 'Geld';

  @override
  String get zodiacHealth => 'Gesundheit';

  @override
  String get collectionTitle => 'Ihre Sammlung';

  @override
  String get collectionSubtitle =>
      'Spuren und Belohnungen Ihres täglichen Rituals';

  @override
  String get collectionNotYet => 'Noch nicht';

  @override
  String get collectionFirstTime => 'Zum ersten Mal';

  @override
  String get collectionTotalOpened => 'Gesamt';

  @override
  String get collectionCookieDescription =>
      'Dieser Keks bringt Glück und kleine Überraschungen in Ihr Ritual. Je mehr Sie öffnen, desto stärker wird Ihre Sammlung.';

  @override
  String get collectionSummaryTitle => 'Zusammenfassung der Sammlung';

  @override
  String get collectionSummaryTypes => 'Einzigartige Typen';

  @override
  String get collectionSummaryTotalOpened => 'Insgesamt geöffnet';

  @override
  String get collectionSummaryRare => 'Selten';

  @override
  String get collectionSummaryFooter =>
      'Jeder Keks hat eine Geschichte. Je mehr Sie öffnen, desto reichhaltiger wird es.';

  @override
  String get rarityAll => 'Alle';

  @override
  String get rarityCommon => 'Gemeinsam';

  @override
  String get rarityRare => 'Selten';

  @override
  String get rarityLegendary => 'Legendär';

  @override
  String get collectionUndiscovered => 'Unentdeckt';

  @override
  String get collectionNotFoundYet =>
      'Das Glück hat dich noch nicht hierher gebracht ... noch nicht.';

  @override
  String get collectionEmptyTitle => 'Sie haben noch keine Cookies geöffnet';

  @override
  String collectionEmptySubtitle(Object count) {
    return '${count}verschiedene Cookies warten auf Sie. Öffnen Sie den heutigen Cookie, um mit Ihrer Sammlung zu beginnen.';
  }

  @override
  String get discoverTitle => 'Entdecken';

  @override
  String get discoverSubtitle => 'Entdecken Sie neue Funktionen';

  @override
  String get discoverCategories => 'Kategorien';

  @override
  String get categoryTarotTitle => 'Tarot-Lesung';

  @override
  String get categoryTarotDesc => '3-Karten-Tarot';

  @override
  String get categoryDreamTitle => 'Traumdeutung';

  @override
  String get categoryDreamDesc => 'Entdecken Sie die Bedeutung Ihrer Träume';

  @override
  String get categoryZodiacTitle => 'Sternzeichen-Lesung';

  @override
  String get categoryZodiacDesc => 'Botschaft von den Sternen';

  @override
  String get categoryPersonalityTitle => 'Persönlichkeitstest';

  @override
  String get categoryPersonalityDesc => '16 Persönlichkeiten';

  @override
  String get discoverDailySuggestionTitle => 'HEUTE VORSCHLAG';

  @override
  String get discoverDailySuggestionHeadline =>
      'Hattest du letzte Nacht einen Traum?';

  @override
  String get discoverDailySuggestionSubtitle =>
      'Interpretieren Sie es jetzt und erfahren Sie seine Bedeutung!';

  @override
  String get dailySuggestionDreamHeadline =>
      'Hattest du letzte Nacht einen Traum?';

  @override
  String get dailySuggestionDreamSubtitle =>
      'Interpretieren Sie es jetzt und erfahren Sie seine Bedeutung!';

  @override
  String get dailySuggestionTarotHeadline =>
      'Haben Sie heute Ihr Tarot überprüft?';

  @override
  String get dailySuggestionTarotSubtitle =>
      'Wählen Sie 3 Karten und sehen Sie Ihre Nachricht!';

  @override
  String get dailySuggestionZodiacHeadline =>
      'Hast du deinen Sternzeichenwert schon überprüft?';

  @override
  String get dailySuggestionZodiacSubtitle =>
      'Sehen Sie sofort die heutige Energie!';

  @override
  String get dailySuggestionCoffeeHeadline => 'Hast du heute Kaffee getrunken?';

  @override
  String get dailySuggestionCoffeeSubtitle =>
      'Drehen Sie Ihre Tasse um und lassen Sie uns Ihr Schicksal lesen!';

  @override
  String get dailySuggestionAllDoneHeadline =>
      'Die heutigen Rituale sind abgeschlossen!';

  @override
  String get dailySuggestionAllDoneSubtitle =>
      'Kommen Sie morgen wieder vorbei, um neue Inhalte zu sehen.';

  @override
  String get discoverFeaturedTag => 'VORGESTELLT';

  @override
  String get discoverFeaturedTitle => '3-Karten-Tarot-Lesung';

  @override
  String get discoverFeaturedSubtitle =>
      'Entdecken Sie Ihre Vergangenheit, Gegenwart und Zukunft';

  @override
  String get ctaStart => 'Start';

  @override
  String get homeGreeting => 'Hallo! 👋';

  @override
  String get homeFeeling => 'Wie fühlst du dich heute?';

  @override
  String get quoteOfDayText =>
      'Der kleinste Schritt, den Sie heute machen, führt morgen zum größten Sieg.';

  @override
  String get quoteOfDaySource => '– Zitat des Tages';

  @override
  String get dailyHoroscopeTitle => 'Widder';

  @override
  String get dailyHoroscopeSubtitle => 'Die heutige Lesung';

  @override
  String get dailyHoroscopeBody =>
      'Du hast diese Woche Glück in der Liebe! Karrieremöglichkeiten liegen vor Ihrer Tür – halten Sie die Augen offen. Deine Energie ist hoch, nutze sie.';

  @override
  String get aries => 'Widder';

  @override
  String get bentoTarotTitle => 'Tarot';

  @override
  String get bentoTarotDesc => 'Sehen Sie Ihre Zukunft';

  @override
  String get bentoTarotBadge => 'BELIEBT';

  @override
  String get bentoDreamTitle => 'Traum';

  @override
  String get bentoDreamDesc => 'Erkunden Sie Ihr Unterbewusstsein';

  @override
  String get bentoDreamBadge => 'NEU';

  @override
  String get bentoMotivationTitle => 'Stimmung';

  @override
  String get bentoMotivationDesc => 'Entdecken Sie Ihre Stimmung';

  @override
  String get bentoMotivationBadge => 'TÄGLICH';

  @override
  String get bentoZodiacTitle => 'Tierkreis';

  @override
  String get bentoZodiacDesc => 'Botschaft von den Sternen';

  @override
  String get bentoZodiacBadge => 'TÄGLICH';

  @override
  String get moodQuestion => 'Wie geht es dir heute?';

  @override
  String get dreamTitle => 'Erzählen Sie Ihren Traum';

  @override
  String get dreamTabNew => 'Neuer Traum';

  @override
  String get dreamTabHistory => 'Meine Träume';

  @override
  String get dreamAnalyzeButton => 'Traum interpretieren';

  @override
  String get dreamAnalyzeEstimate => '~ 5 Sek';

  @override
  String get dreamInterpretationTitle => 'Traumdeutung';

  @override
  String get dreamNoHistory => 'Du hast noch keine geretteten Träume';

  @override
  String get dreamDefaultTitle => 'Traum';

  @override
  String get dreamSpiritual => 'Spirituell';

  @override
  String get dreamEnriched => 'Angereicherte Interpretation';

  @override
  String get dreamEnriching => 'Bereichernd...';

  @override
  String get dreamEnrich => 'Bereichern';

  @override
  String get dreamShare => 'Aktie';

  @override
  String get dreamAnalyzing => 'Traum analysieren...';

  @override
  String get dreamAnalysisFailed =>
      'Es kann derzeit keine Interpretation generiert werden.';

  @override
  String get dreamClarifyThreat =>
      'Gab es in dem Traum ein Gefühl von Bedrohung oder Angst?';

  @override
  String get dreamClarifyFamiliar =>
      'Kam Ihnen diese Szene aus der Vergangenheit bekannt vor?';

  @override
  String get dreamClarifyEscape =>
      'Gab es ein Gefühl von Bewegung oder Flucht?';

  @override
  String get dreamClarifyAnxious =>
      'Fühlten Sie im Traum Angst oder Bedrohung?';

  @override
  String get dreamUnsure => 'Nicht sicher';

  @override
  String get dreamYes => 'JA';

  @override
  String get dreamNo => 'NEIN';

  @override
  String get dreamGeneral => 'Allgemeiner Traum';

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
    return 'Traumtitel:${title}Datum:${date}Traum:${text}Allgemein:${general}Psychologisch:${psychology}Spirituell:${spiritual}Hinweis:$advice#VLucky #Traum';
  }

  @override
  String get scientificTitle => 'Wissenschaftliche Traumanalyse';

  @override
  String get scientificDreamPromptTitle => 'Erzählen Sie Ihren Traum';

  @override
  String get scientificDreamHint =>
      'Schreiben Sie Ihren Traum so auf, wie Sie ihn in Erinnerung haben ...';

  @override
  String get scientificEmotionQuestion =>
      'Wie haben Sie sich gefühlt, als Sie aufgewacht sind?';

  @override
  String get scientificEmotionHint => 'Wählen Sie eine Emotion';

  @override
  String get scientificClarityQuestion => 'Wie klar war der Traum?';

  @override
  String get scientificDisclaimer =>
      'Diese Analyse basiert auf psychologischer und neurowissenschaftlicher Forschung. Es liefert keine endgültigen oder prädiktiven Ergebnisse.';

  @override
  String get scientificLoading =>
      'Bewertung basierend auf REM-Schlaf und Neurowissenschaften';

  @override
  String get scientificResultsTitle => 'Traumdeutung';

  @override
  String get scientificRecentPastTitle =>
      'Jüngste Auswirkungen in der Vergangenheit';

  @override
  String get scientificSaved => 'Traum gerettet';

  @override
  String get scientificSaveButton => 'Rette den Traum';

  @override
  String get cookieSpringWreath => 'Frühlingskranz';

  @override
  String get cookieLuckyClover => 'Glücksklee';

  @override
  String get cookieRoyalHearts => 'Königliche Herzen';

  @override
  String get cookieEvilEye => 'Böser Blick';

  @override
  String get cookiePizzaParty => 'Pizza-Party';

  @override
  String get cookieSakuraBloom => 'Sakura-Blüte';

  @override
  String get cookieBluePorcelain => 'Blaues Porzellan';

  @override
  String get cookiePinkBlossom => 'Rosa Blüte';

  @override
  String get cookieFortuneCat => 'Glückskatze';

  @override
  String get cookieWildflower => 'Wildblume';

  @override
  String get cookieCupidRibbon => 'Amor-Band';

  @override
  String get cookiePandaBamboo => 'Panda-Bambus';

  @override
  String get cookieRamadanCute => 'Ramadan';

  @override
  String get cookieEnchantedForest => 'Zauberwald';

  @override
  String get cookieGoldenArabesque => 'Goldene Arabeske';

  @override
  String get cookieMidnightMosaic => 'Mitternachtsmosaik';

  @override
  String get cookiePearlLace => 'Perlenspitze';

  @override
  String get cookieGoldenSakura => 'Goldene Sakura';

  @override
  String get cookieDragonPhoenix => 'Drache Phönix';

  @override
  String get cookieGoldBeasts => 'Goldbestien';

  @override
  String get emotionAnxiety => 'Ängstlich';

  @override
  String get emotionFear => 'Besorgt';

  @override
  String get emotionCalm => 'Ruhig';

  @override
  String get emotionHappy => 'Glücklich';

  @override
  String get emotionSad => 'Traurig';

  @override
  String get emotionConfusion => 'Unsicher';

  @override
  String get emotionSurprise => 'Überrascht';

  @override
  String get dreamMoodQuestion =>
      'Wie haben Sie sich gefühlt, als Sie aufgewacht sind?';

  @override
  String get dreamMetricEmotional => 'Emotionale Belastung';

  @override
  String get dreamMetricUncertainty => 'Erzählung\nUnsicherheit';

  @override
  String get dreamMetricRecentPast => 'Jüngste Vergangenheit';

  @override
  String get dreamMetricBrain => 'Gehirnaktivität';

  @override
  String get tarotShuffleHint => 'Zum Mischen in einem Kreis ziehen';

  @override
  String get tarotEnergyDepletedTitle => 'Energie erschöpft';

  @override
  String get tarotEnergyDepletedBody =>
      'Ihre tägliche kosmische Energie ist aufgebraucht.\nTanken Sie neue Energie, um die Wahrheit zu sehen.';

  @override
  String get tarotEnergyDepletedSub =>
      'Ihre ausgewählten Karten sind fertig, nur noch ein Schritt ...';

  @override
  String get tarotWatchAd => 'Anzeige ansehen und öffnen';

  @override
  String tarotFreeRemaining(Object count) {
    return 'Heute noch frei:$count';
  }

  @override
  String get socialFeedTitle => 'Ruhiges Futter';

  @override
  String get feedTypeCookie => 'Plätzchen';

  @override
  String get feedTagDailyCookie => 'Der heutige Keks';

  @override
  String get feedTypeTarot => 'Tarot';

  @override
  String get feedTagThreeCard => '3-Karten-Ziehen';

  @override
  String get feedTypeDream => 'Traum';

  @override
  String get feedTagDreamMode => 'Traummodus';

  @override
  String get feedTypeZodiac => 'Tierkreis';

  @override
  String get feedTagDailyEnergy => 'Tägliche Energie';

  @override
  String get feedTypeMotivation => 'Motivation';

  @override
  String get feedTagMiniAction => 'Mini-Aktion';

  @override
  String inviteShareMessage(String handle, String link) {
    return 'Sind Sie bereit für eine mystische Reise? Ich warte im Crack&Wish-Universum auf dich! ✨\n\nMein Einladungscode:${handle}Jetzt herunterladen:$link';
  }

  @override
  String get inviteShareSubject => 'Crack&Wish-Einladung';

  @override
  String get inviteSendButton => 'Einladen';

  @override
  String get inviteConnectButton => 'Verbinden';

  @override
  String get inviteSentText => 'Gesendet';

  @override
  String inviteRequestSent(String name) {
    return 'Anfrage an${name}gesendet!';
  }

  @override
  String get toastCoffeeReadyTitle => 'Ihre Lektüre ist fertig!';

  @override
  String get toastCoffeeReadyMessage =>
      'Die Geheimnisse in Ihrer Tasse wurden gelüftet.';

  @override
  String get toastViewButton => 'Sicht';

  @override
  String get toastDreamReadyTitle => 'Ihr Traum wird interpretiert!';

  @override
  String get toastDreamReadyMessage =>
      'Die Botschaften Ihres Unterbewusstseins wurden entschlüsselt.';

  @override
  String get toastCoffeeReadyTitle2 => 'Ihre Kaffee-Lesung ist fertig!';

  @override
  String get dreamFallbackTitle => 'Traumdeutung';

  @override
  String get rewardWelcomeTitle => 'Willkommen im Universum';

  @override
  String get rewardWelcomeDesc =>
      'Wir haben ein kleines Geschenk für Sie hinterlassen, um Ihre Reise zu beginnen.';

  @override
  String get rewardReferralFallback => 'Ein Freund';

  @override
  String get rewardReferralReceiverTitle => 'Ein unerwartetes Geschenk';

  @override
  String rewardReferralReceiverDesc(String inviter) {
    return '${inviter}hat Sie hierher eingeladen und ein Willkommensgeschenk für Sie hinterlassen.';
  }

  @override
  String get rewardInviterTitle => 'Ihr Ruf wurde erhört!';

  @override
  String rewardInviterDescSingle(String name) {
    return '${name}ist dem Universum beigetreten. Sie wurden dafür belohnt, ein Führer zu sein.';
  }

  @override
  String rewardInviterDescMultiple(String name, int count) {
    return '${name}und${count}weitere Freunde sind dem Universum beigetreten. Sie wurden dafür belohnt, ein Führer zu sein.';
  }

  @override
  String rewardInviterDescGeneric(int count) {
    return '${count}Freunde sind dem Universum beigetreten. Sie wurden dafür belohnt, ein Führer zu sein.';
  }

  @override
  String birthdayTitleWithName(String name) {
    return 'Alles Gute zum Geburtstag,$name!';
  }

  @override
  String get birthdayTitle => 'Alles Gute zum Geburtstag!';

  @override
  String get birthdayDesc =>
      'Heute ist der heilige Tag, an dem deine Seele auf diese Welt kam. Das Universum hat ein besonderes Geschenk für Sie hinterlassen.';

  @override
  String get cookieReminderTitle => 'Du hast heute keinen Keks geknackt';

  @override
  String get cookieReminderMessage =>
      'Ihre tägliche Glücksbotschaft wartet auf Sie!';

  @override
  String get cookieReminderReward => '3 Links';

  @override
  String achievementRewardStones(int count) {
    return '+${count}Seelensteine';
  }

  @override
  String achievementRewardAura(int count) {
    return '+${count}Aura';
  }

  @override
  String get rankUpTitle => 'Kosmische Werbung!';

  @override
  String rankUpMessage(String rank) {
    return 'Deine Aurakraft wurde erhöht. Neuer Titel:$rank';
  }

  @override
  String get rankNovice => 'Anfänger-Seher';

  @override
  String get rankApprentice => 'Seherlehrling';

  @override
  String get rankSeer => 'Seher';

  @override
  String get rankWise => 'Weiser Seher';

  @override
  String get rankMaster => 'Meisterseher';

  @override
  String get rankCosmic => 'Kosmischer Seher';

  @override
  String get loginSubtitle =>
      'Synchronisieren Sie sich mit dem Führer Ihrer Seele.\nErinnern Sie sich an Ihre Vergangenheit, Zukunft und Ihr Unterbewusstsein.';

  @override
  String get loginAppleContinue => 'Weiter mit Apple';

  @override
  String get loginAppleSignIn => 'Melden Sie sich bei Apple an';

  @override
  String get loginGoogleContinue => 'Weiter mit Google';

  @override
  String get loginGoogleSignIn => 'Melden Sie sich mit Google an';

  @override
  String get loginGoogleFailed => 'Google-Anmeldung fehlgeschlagen';

  @override
  String get loginAppleFailed => 'Apple-Anmeldung fehlgeschlagen';

  @override
  String get loginNoAccountYet =>
      'Du bist dem Universum noch nicht beigetreten?';

  @override
  String get loginHaveAccount => 'Sie haben bereits ein Konto?';

  @override
  String get loginSignUp => 'Melden Sie sich an';

  @override
  String get loginSignIn => 'Anmelden';

  @override
  String get loginLegalPrefix => 'Indem Sie fortfahren, stimmen Sie unseren zu';

  @override
  String get loginTermsOfUse => 'Nutzungsbedingungen';

  @override
  String get loginLegalAnd => 'Und';

  @override
  String get loginPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get homeSubtitle1 => 'Knacken, lesen, lächeln.';

  @override
  String get homeSubtitle2 => 'Glück in der Tasche.';

  @override
  String get homeSubtitle3 => 'Die heutige Nachricht: Du.';

  @override
  String get homeSubtitle4 => 'Ein Knall, eine Überraschung.';

  @override
  String get homeSubtitle5 => 'Ein kleiner Keks, ein großes Gefühl.';

  @override
  String get homeSubtitle6 => 'Kein Schicksal, nur ein süßer Hinweis.';

  @override
  String get homeSubtitle7 => 'Was sagt Ihr Glück heute?';

  @override
  String get homeSubtitle8 => 'Öffnen, entdecken, weitermachen.';

  @override
  String get homeSubtitle9 => 'Das Glück ist nur einen Fingertipp entfernt.';

  @override
  String get homeSubtitle10 => 'Mit jedem Riss ein neuer Anfang.';

  @override
  String get homeSubtitle11 => 'Finden Sie Ihre Nachricht.';

  @override
  String get homeSubtitle12 => 'Nicht zufällig ... nur für Sie.';

  @override
  String get homeSubtitle13 => 'Versuchen Sie Ihr Glück, nutzen Sie Ihren Tag.';

  @override
  String get homeSubtitle14 =>
      'Kleine Prophezeiungen, die Sie zum Lächeln bringen.';

  @override
  String get homeSubtitle15 => 'Überraschungen tun gut.';

  @override
  String get homeMilestoneTitle => 'Unglaublicher Fokus!';

  @override
  String homeMilestoneMessage(int count) {
    return 'Ihr täglicher Streak hat${count}Tage erreicht.';
  }

  @override
  String homeMilestoneSoulStone(int count) {
    return '+${count}Seelensteine';
  }

  @override
  String get homeGreetingMorning => 'Guten Morgen';

  @override
  String get homeGreetingAfternoon => 'Guten Tag';

  @override
  String get homeGreetingEvening => 'Guten Abend';

  @override
  String get homeGreetingNight => 'Gute Nacht';

  @override
  String get homeTimeSubMorning => 'Frische Botschaft mit Ihrem Kaffee.';

  @override
  String get homeTimeSubAfternoon => 'Eine magische Pause in Ihrem Tag.';

  @override
  String get homeTimeSubEvening => 'Eine süße Prophezeiung zum Entspannen.';

  @override
  String get homeTimeSubNight => 'Die Sterne leuchten heute Nacht für dich.';

  @override
  String get paywallSubtitleElite =>
      'Dein kosmisches Bewusstsein ist bereits geöffnet.\nStärken Sie Ihre Erleuchtung, indem Sie Ihren Plan aktualisieren.';

  @override
  String get paywallSubtitleNew =>
      'Öffnen Sie die Tür zum kosmischen Bewusstsein.\nEntfernen Sie alle Grenzen.';

  @override
  String get paywallFeature1 => 'Täglich 5 frische Seelensteine';

  @override
  String get paywallFeature2 => 'Master-Analysemodus';

  @override
  String get paywallFeature3 => 'x3 Schneller Auragewinn';

  @override
  String get paywallFeature4 => 'Unbegrenztes klinisches Archiv';

  @override
  String get paywallFeature5 => 'Werbefreies, nahtloses Erlebnis';

  @override
  String get paywallPackageWeekly => 'Wöchentliches Erwachen';

  @override
  String get paywallPackageMonthly => 'Monatliche Intuition';

  @override
  String get paywallPackageYearly => 'Jährliche Aufklärung';

  @override
  String get paywallBtnCurrentPlan => 'Aktueller Plan';

  @override
  String get paywallBtnManage => 'Im Store verwalten';

  @override
  String get paywallBtnUpgrade => 'Upgrade-Plan';

  @override
  String get paywallBtnSubscribe => 'Schalte Elite frei';

  @override
  String get paywallSuccessUpgradeTitle => 'Aufklärung verbessert';

  @override
  String get paywallSuccessTitle => 'Willkommen in der Aufklärung';

  @override
  String get paywallSuccessUpgradeSubtitle =>
      'Ihr Plan wurde erfolgreich aktualisiert.';

  @override
  String get paywallSuccessSubtitle =>
      'Sie sind jetzt Elite-Mitglied. Kosmische Grenzen wurden für Sie aufgehoben.';

  @override
  String get paywallErrorTitle => 'Verbindungsfehler';

  @override
  String get paywallErrorMessage =>
      'Es konnte keine Verbindung zum Shop hergestellt werden oder die Transaktion wurde abgebrochen. Produkte sind möglicherweise noch nicht im App Store/Play Console veröffentlicht. Bitte versuchen Sie es später noch einmal.';

  @override
  String get paywallRestoreSuccess => 'Elite wiederhergestellt';

  @override
  String get paywallRestoreSuccessSubtitle =>
      'Willkommen zurück im kosmischen Bewusstsein. Ihre Limits wurden entfernt.';

  @override
  String get paywallRestoreNoSub => 'Kein aktives Abonnement';

  @override
  String get paywallRestoreNoSubMessage =>
      'Es wurde keine aktive Crack Wish Elite-Mitgliedschaft zum Wiederherstellen gefunden. Bitte überprüfen Sie die Pakete.';

  @override
  String get paywallRestore => 'Einkäufe wiederherstellen';

  @override
  String get paywallCurrentPlanBadge => 'AKTUELLER PLAN';

  @override
  String get paywallLegalTr =>
      'Crack Wish Elite ist ein Abonnement mit automatischer Verlängerung. Die Zahlung wird Ihrem Konto bei Bestätigung des Kaufs belastet. Das Abonnement verlängert sich automatisch, sofern es nicht mindestens 24 Stunden vor Ablauf des aktuellen Zeitraums gekündigt wird. Sie können Ihre Abonnements in Ihren App Store-Einstellungen verwalten und kündigen.';

  @override
  String get paywallOk => 'OK';

  @override
  String get coffeeLoading1 => 'Eintauchen in die Tiefen des Kelches...';

  @override
  String get coffeeLoading2 =>
      'Die Symbole auf dem Gelände stehen im Einklang mit der universellen Energie ...';

  @override
  String get coffeeLoading3 => 'Ihre Schicksalslinien werden kartiert ...';

  @override
  String get coffeeLoading4 => 'Geheimnisse werden gelüftet...';

  @override
  String get coffeeAiError =>
      'Bei der Interpretation des Messwerts ist AI auf einen Fehler gestoßen.';

  @override
  String get coffeeGenericError =>
      'Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.';

  @override
  String get coffeeNotifReady =>
      'Sie werden benachrichtigt, wenn Ihre Lektüre fertig ist';

  @override
  String get coffeeCheckHistory =>
      'Klicken Sie auf die Schaltfläche, um es anzuzeigen';

  @override
  String get coffeeWaitOrExplore => 'Warten Sie hier oder erkunden Sie die App';

  @override
  String get coffeeGoHome => 'Gehen Sie zu Startseite';

  @override
  String get coffeeSections => 'Pokalabschnitte';

  @override
  String get coffeeSectionInside => 'Im Pokal';

  @override
  String get coffeeSectionInsideDesc =>
      'Deine innere Welt, deine Gedanken, dein emotionaler Zustand.';

  @override
  String get coffeeSectionEdge => 'Tassenrand';

  @override
  String get coffeeSectionEdgeDesc =>
      'Nahe Zukunft, Neuigkeiten, Nachrichten, Begegnungen.';

  @override
  String get coffeeSectionBottom => 'Tassenboden';

  @override
  String get coffeeSectionBottomDesc =>
      'Verbleibende vergangene Probleme, Belastungen, ungelöste Angelegenheiten.';

  @override
  String get coffeeSectionSaucer => 'Untertasse';

  @override
  String get coffeeSectionSaucerDesc =>
      'Wunsch, Ergebnis, Schicksal, Endenergie.';

  @override
  String get coffeeLoadingComment => 'Interpretation wird geladen...';

  @override
  String get coffeeStoryTitle => 'Die vom Gelände erzählte Geschichte';

  @override
  String get coffeeSymbolsTitle => 'Symbole, die Sie in Ihrer Lektüre sehen';

  @override
  String get coffeeLove => 'Liebe & Beziehungen';

  @override
  String get coffeeCareer => 'Karriere & Finanzen';

  @override
  String get coffeeFamily => 'Familie und enger Kreis';

  @override
  String get coffeeNearFuture => 'Nahe Zukunft';

  @override
  String get coffeeClosing => 'Letzte Worte Ihrer Lektüre';

  @override
  String get coffeeShare => 'Teilen Sie meine Lektüre';

  @override
  String get coffeeRetryValidation =>
      'Gehen Sie zurück und nehmen Sie es erneut ein';

  @override
  String get coffeeRetry => 'Versuchen Sie es erneut';

  @override
  String get coffeeCancel => 'Stornieren';

  @override
  String get coffeeSymbolLabel => 'Symbol';

  @override
  String get coffeeSymbolLoading => 'Laden...';

  @override
  String get coffeeTimelineSoon => 'Sehr bald';

  @override
  String get coffeeImageError =>
      'Auf diesem Bild ist kein klarer Kaffeesatz zu erkennen.';

  @override
  String get coffeeCosmicTitle => 'Kosmische Kaffeelesung';

  @override
  String get coffeePremiumOnly => 'Nur Premium-Funktion';

  @override
  String get coffeePremiumDesc =>
      'Coffee Reading ist exklusiv für Elite-Mitglieder. Upgraden Sie auf Premium und entdecken Sie mit Ihren Seelensteinen die Geheimnisse Ihrer Zukunft.';

  @override
  String get coffeePremiumSimBtn => 'Go Premium (Simulation)';

  @override
  String get coffeePhotoSource => 'Fotoquelle';

  @override
  String get coffeeCamera => 'Kamera';

  @override
  String get coffeeGallery => 'Galerie';

  @override
  String get coffeeStepCupInside => 'Im Pokal';

  @override
  String get coffeeStepCupInsideDesc =>
      'Positionieren Sie die Kamera direkt über der Tasse und erfassen Sie den Kaffeesatz darin.';

  @override
  String get coffeeStepLeftProfile => 'Linkes Profil';

  @override
  String get coffeeStepLeftProfileDesc =>
      'Halten Sie die Tasse am Griff und machen Sie ein klares Foto nur der linken Seite.';

  @override
  String get coffeeStepRightProfile => 'Richtiges Profil';

  @override
  String get coffeeStepRightProfileDesc =>
      'Nehmen Sie nun aus einem gut beleuchteten Winkel die rechte Rückseite der Tasse auf.';

  @override
  String get coffeeStepSaucerSecret => 'Das Geheimnis der Untertasse';

  @override
  String get coffeeStepSaucerDesc =>
      'Zum Schluss erfassen Sie die breite Oberfläche der Untertasse mit deutlich sichtbarem Boden.';

  @override
  String get coffeeStepSaucerBtn => 'Machen Sie ein Untertassenfoto';

  @override
  String get coffeeHeaderTitle => 'KAFFEELESUNG';

  @override
  String get coffeeLastReading => 'Ihre letzte Lesung';

  @override
  String coffeeLastReadingTime(String time) {
    return 'Um$time• Läuft um Mitternacht ab';
  }

  @override
  String get coffeeNoReadingYet =>
      'Sie hatten noch keine Lesung.\nBrauen Sie eine Tasse Kaffee,\nund lass die Erde zu dir flüstern.';

  @override
  String get coffeeSoulStones => 'Deine Seelensteine';

  @override
  String get coffeeSoulStoneEmpty => 'Keine Seelensteine ​​mehr übrig';

  @override
  String get coffeeSoulStoneRequired =>
      'Erforderlich für die Kaffeeleseanalyse';

  @override
  String get coffeeSoulStoneCost => 'Jede Lesung kostet 1 Seelenstein';

  @override
  String get coffeeSoulStoneEliteActive =>
      'Elite-Vorteil: 5 Seelensteine ​​werden jede Nacht aktualisiert';

  @override
  String get coffeeSoulStoneElitePromo =>
      'Gehen Sie zur Elite, um jede Nacht 5 Seelensteine ​​zu verdienen';

  @override
  String get coffeeEliteSubscribe => 'Abonnieren Sie Elite';

  @override
  String get coffeeRitualLabel => 'RITUAL';

  @override
  String get coffeeRitualTitle => 'Geheimnisse des Pokals';

  @override
  String get coffeeRitualDesc =>
      'Das Gelände spricht nur den an, der genau hinschaut. Befolgen Sie das Ritual für eine echte Lesung.';

  @override
  String get coffeeRitualStep1Title => 'Legen Sie Ihre Absicht fest';

  @override
  String get coffeeRitualStep1Desc =>
      'Lassen Sie beim Nippen eine Frage oder einen Wunsch durch Ihren Kopf fließen.';

  @override
  String get coffeeRitualStep2Title => 'Nippen Sie von einer Seite';

  @override
  String get coffeeRitualStep2Desc =>
      'Trinken Sie immer von der gleichen Seite, um die Muster zu erhalten.';

  @override
  String get coffeeRitualStep3Title => 'Drehen Sie es um';

  @override
  String get coffeeRitualStep3Desc =>
      'Drehen Sie die Tasse um, lassen Sie sie abkühlen und öffnen Sie sie vorsichtig.';

  @override
  String get coffeeRitualListenTitle =>
      'Hören Sie sich das Flüstern des Geländes an';

  @override
  String coffeeStepLabel(String index, String title) {
    return 'Schritt$index:$title';
  }

  @override
  String get coffeeDiscoverFate => 'Entdecken Sie Ihr Schicksal';

  @override
  String get coffeeNextStep => 'Nächster Schritt';

  @override
  String get coffeeCapture => 'Erfassen Sie diesen Winkel';

  @override
  String get coffeeValidationError =>
      'Das Gelände auf den markierten Fotos\nkonnte nicht eindeutig identifiziert werden.';

  @override
  String get coffeeCosmicMismatch => 'Kosmisches Missverhältnis';

  @override
  String get coffeeCosmicCheck => 'KOSMISCHER BINDUNGSCHECK';

  @override
  String get coffeeCosmicCheckDesc =>
      'Entschlüsselung der Sprache der Gründe,\ndem Flüstern des Schicksals lauschen ...';

  @override
  String get coffeeRevealSecrets => 'Lüften Sie den Schleier der Geheimnisse';

  @override
  String get coffeeReadingInProgress => 'Die Begründung lesen...';

  @override
  String get coffeeReadingWait =>
      'Die Türen der Zukunft öffnen sich, warten Sie.';

  @override
  String get coffeeRelationTitle => 'Ihr Beziehungsstatus';

  @override
  String get coffeeRelationSubtitle =>
      'Legen Sie den Grundstein für Ihre kosmische Bindung.';

  @override
  String get coffeeFocusTitle => 'Was hast du im Kopf?';

  @override
  String get coffeeFocusSubtitle =>
      'Wählen Sie eine Absicht, um Ihre Lektüre zu vertiefen.';

  @override
  String get coffeeMoodTitle => 'Deine Stimmung?';

  @override
  String get coffeeMoodSubtitle => 'Spüren Sie die Energie Ihrer Tasse.';

  @override
  String get coffeeCosmicBondFormed => 'Kosmische Bindung gebildet';

  @override
  String get coffeeSecretsReady =>
      'Die Geheimnisse Ihrer Tasse sind bereit, geflüstert zu werden ...';

  @override
  String get coffeeNewReading => 'Neue Lektüre';

  @override
  String get coffeeAiPermission => 'Erlaubnis zur KI-Kaffeeanalyse';

  @override
  String get coffeeStoneCostInfo => 'Jede Analyse kostet 1 Seelenstein';

  @override
  String get coffeeEliteRefillActive =>
      'Elite-Vorteil: 5 Seelensteine ​​werden jede Nacht aktualisiert';

  @override
  String get coffeeEliteRefillPromo =>
      'Gehen Sie zur Elite, um jede Nacht 5 Seelensteine ​​zu verdienen';

  @override
  String get coffeeEliteGetBtn => 'Holen Sie sich Elite';

  @override
  String get coffeeResultOnHome =>
      'Sehen Sie sich das Ergebnis auf der Startseite an';

  @override
  String get onboardingStart => 'Fangen wir an';

  @override
  String get onboardingContinue => 'Weitermachen';

  @override
  String get onboardingContinueWithoutAccount => 'Hesap Açmadan Devam Et';

  @override
  String get onboardingFinish => 'Reise starten';

  @override
  String get onboardingNameHint => 'Ein kosmischer Name';

  @override
  String get onboardingNamePlaceholder => 'erster_letzter';

  @override
  String get onboardingHandleHint => 'Ein kosmischer Griff';

  @override
  String get onboardingHandlePlaceholder => 'galaxy_traveler';

  @override
  String get onboardingGenderTitle => 'Geschlecht';

  @override
  String get onboardingGenderFemale => 'Weiblich';

  @override
  String get onboardingGenderMale => 'Männlich';

  @override
  String get onboardingGenderOther => 'Sag es lieber nicht';

  @override
  String get onboardingStep1Title => 'Wie sollen wir dich nennen?';

  @override
  String get onboardingStep1Sub =>
      'Unter welchem ​​Namen und welcher Schwingung sollte das Universum Sie kennen?';

  @override
  String get onboardingAvatarSelect => 'Wählen Sie Ihren Avatar aus';

  @override
  String get onboardingStep2Title =>
      'Der Moment, in dem deine Seele eintrat...';

  @override
  String get onboardingStep2Sub =>
      'Wir benötigen Ihre grundlegenden Daten, um Ihr astrologisches Geburtshoroskop und personalisierte Rituale zu berechnen.';

  @override
  String get onboardingBirthDateLabel => 'Geburtsdatum';

  @override
  String get onboardingBirthTimeLabel => 'Geburtszeit';

  @override
  String get onboardingBirthLocationLabel => 'Geburtsstadt';

  @override
  String get onboardingTimeHint =>
      'Wenn Sie die genaue Uhrzeit kennen, melden Sie sich für eine detaillierte Analyse an';

  @override
  String get onboardingLocationHint =>
      'Verfeinern Sie die Berechnung, indem Sie eine Stadt auswählen';

  @override
  String get onboardingUnknownTime => 'Die genaue Uhrzeit weiß ich nicht';

  @override
  String get onboardingPrivacyNote =>
      'Wird ausschließlich zum Zeichnen Ihres personalisierten Diagramms verwendet.';

  @override
  String get onboardingStep3Title => 'Was ist Ihr Schwerpunkt?';

  @override
  String get onboardingStep3Sub =>
      'Welche Energie möchtest du in deinem Leben jetzt am meisten wachsen oder heilen?';

  @override
  String get onboardingFocusLabel => 'Fokus (Multiple Choice)';

  @override
  String get onboardingFocusCareer => 'Karriere & Geld';

  @override
  String get onboardingFocusLove => 'Liebe & Beziehungen';

  @override
  String get onboardingFocusPeace => 'Innerer Frieden';

  @override
  String get onboardingFocusLuck => 'Glück und Chancen';

  @override
  String get onboardingRelLabel => 'Aktueller Beziehungsstatus:';

  @override
  String get onboardingRelSingle => 'Einsamer Himmel';

  @override
  String get onboardingRelComplicated => 'Da ist jemand...';

  @override
  String get onboardingRelTalking => 'Kompliziert';

  @override
  String get onboardingRelRelationship => 'Glücklicher Bond';

  @override
  String get onboardingStep4Title =>
      'Deine Verbindung zum Universum bei Nacht...';

  @override
  String get onboardingStep4Sub =>
      'Wie empfängt Ihr Unterbewusstsein Nachrichten? Farben und Träume werden uns Hinweise geben.';

  @override
  String get onboardingDreamLabel =>
      'Wie oft erinnern Sie sich an Ihre Träume?';

  @override
  String get onboardingDreamOften => 'Oft und deutlich';

  @override
  String get onboardingDreamSometimes => 'Manchmal';

  @override
  String get onboardingDreamRarely => 'Selten';

  @override
  String get onboardingDreamNever => 'Niemals';

  @override
  String get onboardingAuraLabel =>
      'Die Aura deiner Seele (Wie fühlst du dich heute?)';

  @override
  String get onboardingStep5Title => 'Dein Tanz mit der Zeit...';

  @override
  String get onboardingStep5Sub =>
      'Wann ist Ihre Energie am höchsten? Wir werden Ihre Benachrichtigungen entsprechend anpassen.';

  @override
  String get onboardingSleepLabel => 'Ihr Schlafmuster';

  @override
  String get onboardingSleepMorning => 'Morgenmensch';

  @override
  String get onboardingSleepNight => 'Nachteule';

  @override
  String get onboardingSleepIrregular => 'Irregulär';

  @override
  String get onboardingSleepLittle => 'Ich schlafe sehr wenig';

  @override
  String get onboardingMatchLabel => 'Passende und kosmische Verbindung';

  @override
  String get onboardingMatchDesc =>
      'Ich möchte offen für die Verbindung mit synergistischen Profilen und besonderen kosmischen Matches sein.';

  @override
  String get onboardingFinalTitle => 'Alles ist bereit...';

  @override
  String get onboardingFinalSub =>
      'Sie werden gleich herausfinden, was die Sterne mit Ihnen geplant haben. Erstellen Sie Ihr Konto und betreten Sie das kosmische Universum.';

  @override
  String get onboardingAppleCreate => 'Erstellen Sie ein Konto bei Apple';

  @override
  String get onboardingGoogleCreate => 'Erstellen Sie ein Konto bei Google';

  @override
  String get onboardingErrorIncomplete =>
      'Willkommen! Nur noch wenige Schritte, um Ihr Profil zu vervollständigen.';

  @override
  String get onboardingErrorFailed =>
      'Fehler bei der Anmeldung. Bitte versuchen Sie es erneut.';

  @override
  String onboardingErrorAlreadyExists(String provider) {
    return 'Mit diesem$provider-Konto haben Sie bereits ein kosmisches Profil! Bitte nutzen Sie die Option „Anmelden“ auf der ersten Seite.';
  }

  @override
  String onboardingErrorDBRejected(String error) {
    return 'Registrierung von der Datenbank abgelehnt:${error}Bitte wenden Sie sich an den Support.';
  }

  @override
  String get onboardingErrorHandleTaken =>
      'Dieser Benutzername ist bereits vergeben';

  @override
  String get notifTitle => 'Benachrichtigungen';

  @override
  String get notifSubtitle =>
      'Wählen Sie aus, welche Benachrichtigungen Sie erhalten möchten';

  @override
  String get notifAnnouncements => 'Ankündigungen';

  @override
  String get notifAnnouncementsDesc => 'Neue Funktionen und Updates';

  @override
  String get notifSounds => 'Klingt';

  @override
  String get notifSoundsDesc => 'Akustische Benachrichtigungen';

  @override
  String get notifCookieAlarm => 'Neuer Cookie-Alarm';

  @override
  String get notifCookieAlarmDesc => 'Wenn ein neuer Glückskeks ankommt';

  @override
  String get notifFriendAlarm => 'Freund-Alarm';

  @override
  String get notifFriendAlarmDesc => 'Neue Verbindungen aus dem Owl Network';

  @override
  String get notifDailyReminder => 'Tägliche Erinnerungen';

  @override
  String get notifDailyReminderDesc =>
      'Vergessen Sie nicht Ihren täglichen Keks';

  @override
  String get accountTitle => 'Kontodetails';

  @override
  String get accountSubtitle => 'Persönliche Daten und Kontoverwaltung';

  @override
  String get accountUsername => 'Benutzername';

  @override
  String get accountLinkedEmail => 'Verlinkte E-Mail';

  @override
  String get accountSignInMethod => 'Anmeldemethode';

  @override
  String get accountDeleteTitle => 'Konto löschen';

  @override
  String get accountDeleteDesc =>
      'Alle Ihre Daten werden dauerhaft gelöscht.\nDiese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get accountDeleteCancel => 'Stornieren';

  @override
  String get accountDeleteConfirm => 'Löschen';

  @override
  String get accountDeletePermanent => 'Konto dauerhaft löschen';

  @override
  String get welcomeTagline => 'Die Magie ist in dir.';

  @override
  String get welcomeAppleContinue => 'Weiter mit Apple';

  @override
  String get welcomeGoogleContinue => 'Weiter mit Google';

  @override
  String get moodGuideTitle => 'Stimmungsführer';

  @override
  String get moodAwarenessTitle => 'Emotionales Bewusstsein';

  @override
  String get moodAwarenessDesc =>
      'Durch die Wahl Ihrer Stimmung werden Ihre Gefühle konkret; Dies ist der erste Schritt zur inneren Balance und zum Selbstbewusstsein.';

  @override
  String get moodCosmicTitle => 'Kosmische Frequenz';

  @override
  String get moodCosmicDesc =>
      'Jede Emotion, die Sie am Rad auswählen, trägt eine Frequenz. Die Aura des Bildschirms passt sich direkt Ihren Gefühlen an.';

  @override
  String get moodHowToTitle => 'Wie benutzt man?';

  @override
  String get moodHowToDesc =>
      'Drehen Sie einfach das Rad und wählen Sie den Ausdruck aus, der Ihre Stimmung am besten widerspiegelt. Verurteile deine Gefühle nicht, sondern fühle und akzeptiere sie einfach.';

  @override
  String get moodQuestionAlt => 'Wie ist deine Stimmung heute?';

  @override
  String get moodSpinHint => 'Drehen Sie das Rad, wählen Sie Ihre Stimmung ✨';

  @override
  String get bentoCoffeeTitle => 'Kaffeelesung';

  @override
  String get bentoCoffeeDesc => 'Flüstern von Gründen';

  @override
  String get bentoUnexplored =>
      'Dieses Reich wartet darauf, erkundet zu werden ...';

  @override
  String get bentoSealed => 'Versiegelt';

  @override
  String get horoscopeDailyEnergy => 'Die heutige Energie';

  @override
  String get horoscopeWestern => 'Western Ast.';

  @override
  String get horoscopeAsian => 'Asiatische Weisheit';

  @override
  String get horoscopeMayan => 'Maya-Geist';

  @override
  String get shareSaved => 'Gespeichert ✓';

  @override
  String get shareDownload => 'Herunterladen';

  @override
  String get shareShare => 'Aktie';

  @override
  String get shareStory => 'Geschichte';

  @override
  String get sharePost => 'Post';

  @override
  String get shareCookieText =>
      'Das habe ich heute vom Glückskeks bekommen! 🥠✨\n#CrackWish';

  @override
  String get shareCoffeeTitle => 'Kaffeelesung';

  @override
  String get cookieLockedTitle => 'Dieses spezielle Cookie ist gesperrt';

  @override
  String get cookieComingSoon => 'Demnächst erhältlich ✨';

  @override
  String get dreamWaitOrReturn =>
      'Sie können hier warten oder zur Startseite zurückkehren. Wir benachrichtigen Sie, wenn es fertig ist, und Sie können es im Abschnitt „Meine Träume“ lesen.';

  @override
  String get dreamReturnHome => 'Zurück zur Startseite';

  @override
  String get profileEditProfile => 'Profil bearbeiten';

  @override
  String get profileEditSubtitle =>
      'Bearbeiten Sie Namen, Sternzeichen und persönliche Informationen';

  @override
  String get profileSearchHint =>
      'Suchen Sie nach Sternzeichen, Stadt oder Geburtsdatum ...';

  @override
  String get profileStoreUnavailable => 'Der Store-Link ist nicht verfügbar.';

  @override
  String get profileMailNotFound =>
      'Keine Mail-App gefunden. Sie können an support@crackandwish.com schreiben';

  @override
  String get profileRitualCode => 'Ritualcode';

  @override
  String get profileRitualDesc =>
      'Dieser Code ist Ihre persönliche rituelle Identität. Teilen Sie es mit Freunden, um sie zum Owl Network einzuladen.';

  @override
  String get profileRitualCopied => 'Ritualcode kopiert ✨';

  @override
  String get profileRitualInfo => 'Mit Freunden teilen, gemeinsam erkunden!';

  @override
  String get profileShareCode => 'Code teilen';

  @override
  String get profileDeleteAccount => 'Konto löschen';

  @override
  String get profileDeleteDesc =>
      'Alle Ihre Daten werden dauerhaft gelöscht.\nDiese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get profileDeleteCancel => 'Stornieren';

  @override
  String get profileDeleteConfirm => 'Konto löschen';

  @override
  String get profileSignOut => 'Abmelden';

  @override
  String get profileSignOutDesc =>
      'Melden Sie sich sicher von Ihrem Konto ab.\nIhre Daten bleiben erhalten.';

  @override
  String get profileSignOutCancel => 'Stornieren';

  @override
  String get profileSignOutConfirm => 'Abmelden';

  @override
  String get profilePrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get profileTermsOfUse => 'Nutzungsbedingungen';

  @override
  String get profileGetElite => 'Holen Sie sich Elite';

  @override
  String get profileGetEliteSubtitle => 'Tor zum Bewusstsein';

  @override
  String get profileCosmicProfile => 'Kosmisches Profil';

  @override
  String get profileCosmicSubtitle => 'Diagramm, Zeit und Ort';

  @override
  String get profileSectionAccount => 'Konto';

  @override
  String get profileEmail => 'E-Mail';

  @override
  String get profileNotificationSettings => 'Benachrichtigungseinstellungen';

  @override
  String get profileRestorePurchases => 'Einkäufe wiederherstellen';

  @override
  String get profileRestoreSuccess => 'Einkäufe erfolgreich wiederhergestellt!';

  @override
  String get profileRestoreFail =>
      'Es wurden keine Käufe zur Wiederherstellung gefunden.';

  @override
  String get profileHelp => 'Helfen';

  @override
  String get profileShare => 'Aktie';

  @override
  String get profileRate => 'Rate';

  @override
  String get profileVersion => 'Version';

  @override
  String get profileCosmicName => 'Kosmischer Name';

  @override
  String get profileSealProfile => 'Dichtungsprofil';

  @override
  String get profileChooseAvatar => 'Wählen Sie Ihren magischen Avatar.';

  @override
  String get profileStrengthenBonds => 'Bindungen stärken';

  @override
  String get profileStrengthenBondsDesc =>
      'Erweitern Sie mit Freunden das kosmische Universum.';

  @override
  String get profileEarnSoulStones => 'Verdiene +2 Seelensteine';

  @override
  String get profileCodeCopied => 'Code kopiert!';

  @override
  String get profileNotifications => 'Benachrichtigungen';

  @override
  String get profileSupportExperience => 'Support & Erfahrung';

  @override
  String get profileSeerNovice => 'Anfänger-Seher';

  @override
  String get profileSeerApprentice => 'Seherlehrling';

  @override
  String get profileSeer => 'Seher';

  @override
  String get profileSeerWise => 'Weiser Seher';

  @override
  String get profileSeerMaster => 'Meisterseher';

  @override
  String get profileSeerCosmic => 'Kosmischer Seher';

  @override
  String get profileUploadFailed =>
      'Foto-Upload fehlgeschlagen! Bitte überprüfen Sie Ihre Verbindung.';

  @override
  String get profileCropTitle => 'Kosmische Ernte';

  @override
  String get profileCropCancel => 'Stornieren';

  @override
  String get profileCropDone => 'Erledigt';

  @override
  String get moderationAdultContent =>
      'Die Energie dieses Bildes ist nicht mit unserem kosmischen Universum kompatibel (unangemessener Inhalt).';

  @override
  String get moderationViolence =>
      'Bitte wählen Sie einen ruhigeren Avatar, der Ihre Aura widerspiegelt und den Geist nicht ermüdet (störender Inhalt).';

  @override
  String get moderationTooLarge =>
      'Das Bild ist groß genug, um das kosmische Netzwerk zu belasten. Bitte wählen Sie ein Foto unter 5 MB aus.';

  @override
  String get moderationInvalidFormat =>
      'Ihr Foto konnte von unserer magischen Schriftrolle nicht gelesen werden, das Format ist beschädigt.';

  @override
  String get moderationUnknown =>
      'Es kam zu einer unbekannten kosmischen Fluktuation.';

  @override
  String profileShareInvite(String code) {
    return 'Treten Sie dem Crack&Wish-Universum bei! ✨\nMein Ritualcode:${code}Geben Sie diesen Code ein, um +1 Seelenstein, +50 Aura und einen Überraschungs-Premium-Cookie zu erhalten!\nhttps://crackandwish.com';
  }

  @override
  String get profileShareApp =>
      'Entdecken Sie Ihr Glück mit Crack&Wish! •✨\nKekse knacken, Tarot lesen, Träume deuten.\n\nhttps://crackandwish.com';

  @override
  String get profileEliteYouAre => 'Du bist Elite';

  @override
  String get profileGoElite => 'Gehen Sie zur Elite';

  @override
  String get profileEliteMystical => 'Sehen Sie sich mystische Tore an';

  @override
  String get profileEliteDoor => 'Tür zum Bewusstsein';

  @override
  String get profileMyCosmicProfile => 'Mein kosmisches Profil';

  @override
  String get profileCosmicDetails => 'Karten-, Zeit- und Ortsdetails';

  @override
  String get profileRestorePurchasesBtn => 'Einkäufe wiederherstellen';

  @override
  String get profileRestoreSubtitle =>
      'Stellen Sie Ihre vorherigen Einkäufe wieder her';

  @override
  String get profileInviteFriends => 'Freunde einladen';

  @override
  String get profileInviteFriendsDesc =>
      'Bauen Sie kosmische Bindungen auf, verdienen Sie gemeinsam';

  @override
  String get cosmicChart => 'Kosmisches Diagramm';

  @override
  String get cosmicWestern => 'WESTERN';

  @override
  String get cosmicAsian => 'ASIATISCH';

  @override
  String get cosmicMayan => 'MAYA';

  @override
  String get cosmicRising => 'AUFSTAND';

  @override
  String get cosmicArrivalDate => 'ANREISEDATUM';

  @override
  String get cosmicBirthTime => 'GEBURTSZEIT';

  @override
  String get cosmicTimeUnknown => 'Zeit unbekannt';

  @override
  String get cosmicBirthPlace => 'Koordinaten des Geburtsortes';

  @override
  String get cosmicCountry => 'Land';

  @override
  String get cosmicSelectCountry => 'Wählen Sie Land aus';

  @override
  String get cosmicCityDistrict => 'Stadt & Bezirk & Dorf';

  @override
  String get cosmicSelectDateFirst =>
      'Bitte wählen Sie zunächst Ihr Geburtsdatum aus.';

  @override
  String cosmicLockedDays(int days) {
    return 'Gesperrt für${days}Tage';
  }

  @override
  String get cosmicSave => 'Speichern';

  @override
  String get cosmicSearchLocation => 'Genauen Standort suchen';

  @override
  String get cosmicSearchHint => 'Geben Sie Dorf, Bezirk usw. ein.';

  @override
  String get cosmicAddFreeText => 'Als Freitext hinzufügen';

  @override
  String get cosmicRequiresTime => 'Benötigt Zeit';

  @override
  String get badgeReady => 'BEREIT';

  @override
  String get badgeNew => 'NEU';

  @override
  String get paywallLegal =>
      'Crack Wish Elite ist ein Abonnement mit automatischer Verlängerung. Die Zahlung wird Ihrem Konto bei Bestätigung des Kaufs belastet. Das Abonnement verlängert sich automatisch, sofern es nicht mindestens 24 Stunden vor Ablauf des aktuellen Zeitraums gekündigt wird. Sie können Ihre Abonnements in Ihren App Store-Einstellungen verwalten und kündigen.';

  @override
  String get cosmicSelect => 'Wählen';

  @override
  String get coffeeRelSingle => 'Einzelne Seele';

  @override
  String get coffeeRelInLove => 'Das Herz ist voll';

  @override
  String get coffeeRelEngaged => 'Beschäftigt';

  @override
  String get coffeeRelMarried => 'Verheiratet';

  @override
  String get coffeeRelComplicated => 'Kompliziert';

  @override
  String get coffeeFocusLove => 'Liebe und Harmonie';

  @override
  String get coffeeFocusCareer => 'Karriere & Finanzen';

  @override
  String get coffeeFocusHealing => 'Heilung und Frieden';

  @override
  String get coffeeFocusGeneral => 'Allgemeine Zukunft';

  @override
  String get coffeeFocusSurprise => 'Überrasche mich';

  @override
  String get coffeeMoodPeaceful => 'Friedlich';

  @override
  String get coffeeMoodExcited => 'Aufgeregt';

  @override
  String get coffeeMoodAnxious => 'Ängstlich';

  @override
  String get coffeeMoodIndecisive => 'Unentschlossen';

  @override
  String get coffeeMoodEnergetic => 'Energisch';

  @override
  String get coffeeMoodMelancholic => 'Melancholisch';

  @override
  String get coffeeAllPhotosRequired => 'Bitte alle Fotos machen!';

  @override
  String get coffeeNotEnoughStones => 'Nicht genug Seelensteine!';

  @override
  String coffeeSoulStoneCount(int count) {
    return '${count}Seelensteine ​​verfügbar';
  }

  @override
  String get coffeeUseSoulStone => 'Benutze 1 Seelenstein';

  @override
  String get languageSettingsSubtitle => 'Wählen Sie die App-Sprache';

  @override
  String get cosmicSearchHintShort => 'Suchen...';

  @override
  String get cosmicAddThis => 'Fügen Sie dies hinzu';

  @override
  String get horoscopeWesternText =>
      'Die Sterne stimmen für Ihre Karriere. Ergreifen Sie schnelle und entschlossene Schritte.';

  @override
  String get horoscopeAsianText =>
      'Wasserelement ist aktiv. Deine Intuition ist stark, höre einfach auf dein Herz.';

  @override
  String get horoscopeMayanText =>
      'Ton 4 ist aktiv. Ein perfekter Tag, um Ordnung zu schaffen und Ihr Leben zu planen.';

  @override
  String get horoscopeExplore => 'Erkunden';

  @override
  String get cookieDayCompleted => 'Tag abgeschlossen';

  @override
  String get cookieSeeYouTomorrow => 'Bis morgen mit neuen Keksen.';

  @override
  String get cookieRarityLegendary => 'Legendär';

  @override
  String get cookieRarityRare => 'Selten';

  @override
  String get cookiePremiumCollection => 'Premium-Kollektion';

  @override
  String cookiePurchaseBtn(String price) {
    return 'Kauf ($price)';
  }

  @override
  String get cookieTapOutsideToClose => 'Zum Schließen nach draußen tippen';

  @override
  String get cookieAddedToCollection =>
      'Cookie wurde erfolgreich zu Ihrer Sammlung hinzugefügt!';

  @override
  String get cookiePremiumFallback => 'Premium-Cookie';

  @override
  String get dreamSoulStoneRequired => 'Seelenstein erforderlich';

  @override
  String get dreamSoulStoneRequiredDesc =>
      'Für eine tiefe Analyse werden Seelensteine ​​benötigt.\n\nSie können Seelensteine ​​verdienen, indem Sie Aura-Punkte umwandeln oder ein Elite-Abonnement abschließen.';

  @override
  String get dreamGetElite => 'Holen Sie sich Elite';

  @override
  String get dreamClinicalGateTitle => 'Klinisches Analysetor';

  @override
  String dreamClinicalGateDesc(int soulStones) {
    return 'Aktuelle Seelensteine:${soulStones}Diese tiefe Psychoanalyse auf klinischer Ebene kostet 1 Seelenstein.';
  }

  @override
  String get dreamUseOneStone => 'Benutze 1 Stein';

  @override
  String get dreamDeepAnalysisBgPreparing =>
      'Im Hintergrund wird die Tiefenanalyse vorbereitet. Sie erhalten eine Benachrichtigung, wenn es fertig ist.';

  @override
  String get dreamYourSoulStones => 'Deine Seelensteine';

  @override
  String dreamSoulStonesRemaining(int count) {
    return '${count}Seelensteine ​​übrig';
  }

  @override
  String get dreamSoulStonesEmpty => 'Aus Seelensteinen';

  @override
  String get dreamRequiredForDeep => 'Erforderlich für die Tiefenanalyse';

  @override
  String get dreamEachAnalysisCost => 'Jede Analyse kostet 1 Seelenstein';

  @override
  String get dreamEliteRefillActive =>
      'Elite füllt jede Nacht 5 Seelensteine ​​auf';

  @override
  String get dreamEliteRefillPromo =>
      'Erhalte mit Elite täglich 5 Seelensteine';

  @override
  String get dreamWatchAd => 'Anzeige ansehen';

  @override
  String get dreamBgAnalyzing =>
      'Im Hintergrund wird Ihr Traum analysiert. Sie erhalten eine Benachrichtigung, wenn es fertig ist.';

  @override
  String get dreamDeepAnalysis => 'Tiefgründige Analyse';

  @override
  String get dreamDiscoverSecrets => 'Entdecken Sie Geheimnisse';

  @override
  String get dreamDidYouKnow => 'Wussten Sie?';

  @override
  String get dreamNeuroPsychAnalysis => 'NEURO-PSYCH-ANALYSE';

  @override
  String get dreamYourDream => 'DEIN TRAUM';

  @override
  String get dreamEmotionalProfile => 'Emotionales Profil';

  @override
  String get dreamEmotionalProfileSub =>
      'Psychologische Schichten während des Traums';

  @override
  String get dreamShadowSelf => 'Schattenselbst';

  @override
  String get dreamShadowSelfSub =>
      'Unterdrückte und ungeprüfte Aspekte des Unterbewusstseins';

  @override
  String get dreamRecurringPatterns => 'Wiederkehrende Muster';

  @override
  String get dreamRecurringPatternsSub =>
      'Wiederkehrende Schleifen und psychische Blockaden';

  @override
  String dreamSuggestedRitual(String title) {
    return 'Empfohlenes Ritual:$title';
  }

  @override
  String get dreamSuggestedRitualSub =>
      'Eine spezielle Aktion, um die Auswirkungen dieses Traums zu bewältigen';

  @override
  String get dreamScienceNote => 'Wissenschaftlicher Hinweis:';

  @override
  String get dreamWriteNewDream => 'Schreiben Sie einen neuen Traum';

  @override
  String get dreamNoMonthDreams =>
      'Diesen Monat wurden noch keine Träume geschrieben ✨';

  @override
  String get dreamMysteriousDream => 'Geheimnisvoller Traum';

  @override
  String get dreamStandardAnalysis => 'STANDARDANALYSE';

  @override
  String get dreamGeneralAnalysis => 'Allgemeine Analyse';

  @override
  String get dreamPsychological => 'Psychologisch';

  @override
  String get dreamSpiritual2 => 'Spirituell';

  @override
  String get dreamAdvice => 'Beratung';

  @override
  String get dreamDeepenedInsights => 'Vertiefte Einblicke';

  @override
  String get dreamEliteCreditsTitle => 'Elite-Credits';

  @override
  String get dreamReadingCreditsTitle => 'Ihre Lesenachweise';

  @override
  String dreamCreditsRemaining(int count) {
    return '${count}Credits verbleiben';
  }

  @override
  String get dreamDailyLimitReached => 'Tageslimit erreicht';

  @override
  String get dreamZeroCredits => 'Es sind noch 0 Credits übrig';

  @override
  String dreamDailyPremiumReads(int count) {
    return '${count}täglich Traumdeutungen';
  }

  @override
  String get dreamNoAdsRequired => 'Keine Notwendigkeit, Werbung anzusehen';

  @override
  String get dreamCreditsResetNightly =>
      'Credits werden jede Nacht zurückgesetzt';

  @override
  String get dreamOneFreeDaily => '1 kostenloser Dolmetscher pro Tag';

  @override
  String dreamWatchAdsForCredits(int maxAds, int watched) {
    return 'Sehen Sie sich Anzeigen für${maxAds}zusätzliche Credits an ($watched/$maxAds)';
  }

  @override
  String get dreamUnconsciousFrequencies => 'UNBEWUSSTE FREQUENZEN';

  @override
  String get dreamOrbEmotion => 'EMOTION';

  @override
  String get dreamOrbEntropy => 'ENTROPIE';

  @override
  String get dreamOrbActivity => 'AKTIVITÄT';

  @override
  String get dreamOrbResidue => 'RÜCKSTAND';

  @override
  String get dreamHighConfidence => 'Hohes Vertrauen';

  @override
  String get dreamModerateConfidence => 'Mäßiges Selbstvertrauen';

  @override
  String get dreamLowConfidence => 'Geringes Vertrauen';

  @override
  String get dreamCoreThematicPattern => 'THEMATISCHES KERNMUSTER';

  @override
  String get dreamMetricEmotionalLoad => 'Emotional\nLaden';

  @override
  String get dreamMetricEmotionalLoadDesc =>
      'Wie intensiv das emotionale Zentrum Ihres Gehirns während dieses Traums aktiviert wurde.';

  @override
  String get dreamMetricUncertaintyDesc =>
      'Wie unlogisch oder inkonsistent Ihre Traumerzählung war.';

  @override
  String get dreamMetricRecentMemory => 'Neu\nVerbindung';

  @override
  String get dreamMetricRecentMemoryDesc =>
      'Wie stark wurde Ihr Traum durch aktuelle Ereignisse im wirklichen Leben beeinflusst?';

  @override
  String get dreamMetricAgency => 'Agentur /\nKontrolle';

  @override
  String get dreamMetricAgencyDesc =>
      'Wie viel Kontrolle hatten Sie über die Ereignisse in Ihrem Traum?';

  @override
  String get dreamSeverityHigh => 'Hoch';

  @override
  String get dreamSeverityNormal => 'Normal';

  @override
  String get dreamSeverityLow => 'Niedrig';

  @override
  String get dreamCognitiveDistribution => 'Kognitive Verteilung';

  @override
  String get dreamTapToExpand => 'TIPP ZUM ERWEITERN';

  @override
  String get dreamNeurologicalBasis => 'Neurologische Basis';

  @override
  String get dreamEvidenceBase => 'BEWEISBASIS';

  @override
  String get dreamRootCause => 'Grundursache';

  @override
  String get dreamAbsolutely => 'Absolut';

  @override
  String get dreamMaybe => 'Vielleicht';

  @override
  String get dreamNotSure => 'Nicht sicher';

  @override
  String get dreamDreamEssence => 'TRAUMESSENZ';

  @override
  String get dreamClarifyingResponses => 'ANTWORTEN ERKLÄREN';

  @override
  String get dreamCosmicRhythmSynced => 'Kosmischer Rhythmus synchronisiert';

  @override
  String get dreamCosmicRhythmSyncedDesc =>
      'Sie erhalten individuelle Traumaufforderungen basierend auf Ihrem Schlafzyklus.';

  @override
  String get dreamSyncSleepData => 'Schlafdaten synchronisieren';

  @override
  String get dreamSyncSleepDataDesc =>
      'Lassen Sie es erkennen, wann Sie aufwachen, und fragen Sie nach Ihrem tiefsten Traum.';

  @override
  String get dreamAwarenessFallback =>
      'Dieses Bewusstsein ist der Beginn eines neuen Weges. Es ist Zeit, sich dem zu stellen.';

  @override
  String get dreamExtractingEssence => 'Traumessenz extrahieren...';

  @override
  String get dreamNoReasoning => 'Keine Begründung generiert.';

  @override
  String get dreamNotAnalyzable =>
      'Bist du sicher, dass das ein Traum war?\nBitte beschreiben Sie eine reale Szene, die Sie im Schlaf erlebt haben.';

  @override
  String get owlTabFriends => 'Meine Freunde';

  @override
  String get owlTabConnections => 'Verbindungen';

  @override
  String get owlTabInbox => 'Posteingang';

  @override
  String get owlSearchCosmic => 'Kosmisches Universum durchsuchen...';

  @override
  String get owlSearchFriends => 'Freunde suchen...';

  @override
  String get owlPhoneContacts => 'Telefonkontakte';

  @override
  String get owlNoOneFoundCosmic =>
      'Niemand wurde im kosmischen Universum gefunden.';

  @override
  String get owlFoundInCosmic => 'Gefunden im kosmischen Universum';

  @override
  String get owlUnknownProfile => 'Unbekanntes Profil';

  @override
  String owlFriendRequestSent(String name) {
    return 'Freundschaftsanfrage an${name}gesendet!';
  }

  @override
  String get owlRequestSentStatus => 'Gesendet';

  @override
  String get owlSendRequestAction => 'Anfrage senden';

  @override
  String get owlConnectContacts => 'Kontakte verbinden';

  @override
  String get owlConnectContactsDesc =>
      'Finden Sie Ihre Freunde sofort.\nIhre Kontakte werden NIEMALS auf Servern gespeichert.';

  @override
  String get owlNoContactsFound =>
      'Wir konnten niemanden finden\nim Crack&Wish-Universum';

  @override
  String get owlNoContactsFoundDesc =>
      'Sie können die kosmische Energie starten, indem Sie sie einladen!';

  @override
  String get owlUnknown => 'Unbekannt';

  @override
  String get owlAppUserLabel => 'Crack&Wish-Benutzer';

  @override
  String get owlInContactsLabel => 'In Ihren Kontakten';

  @override
  String get owlNoFriendsYet => 'Noch keine Freunde';

  @override
  String get owlNoResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get owlFriendRequests => 'Freundschaftsanfragen';

  @override
  String get owlFriendsHeader => 'Deine Freunde';

  @override
  String get owlAcceptAction => 'Akzeptieren';

  @override
  String get owlRejectAction => 'Ablehnen';

  @override
  String get owlInviteReward => '+2 Seelensteine';

  @override
  String owlInviteShareMessage(String username) {
    return 'Lasst uns gemeinsam die Dunkelheit erhellen! ✨\nTreten Sie Crack Wish über meinen Einladungslink unten bei, verbinden Sie sich automatisch und gewinnen Sie Start-Prämien!\n\nMein Einladungslink:\nhttps://crackwish.com/invite/$username';
  }

  @override
  String get owlInviteFriends => 'Freunde einladen';

  @override
  String get owlInviteFriendsDesc => 'Reflektieren Sie das kosmische Universum';

  @override
  String get owlNoLettersYet => 'Noch keine Briefe';

  @override
  String owlLetterSentNotification(String name) {
    return '${name}hat einen Brief geschickt...';
  }

  @override
  String get owlOnItsWay => 'Eule ist unterwegs 🕊️';

  @override
  String owlLetterCount(int count) {
    return '${count}Buchstaben';
  }

  @override
  String owlUnreadCountBadge(int count) {
    return '${count}Neu';
  }

  @override
  String get owlIUnderstand => 'Ich verstehe';

  @override
  String get owlInviteHowTitle => 'Wie möchten Sie einladen?';

  @override
  String get owlInviteHowSubtitle =>
      'Wie möchten Sie dieser Person Ihren kosmischen Schlüssel übermitteln?';

  @override
  String get owlInviteSendAsMessage => 'Als Nachricht senden';

  @override
  String get owlInviteSMSSubtitle => 'Senden Sie per klassischer Nachricht';

  @override
  String get owlInviteOtherApps => 'Andere Apps';

  @override
  String get owlInviteOtherAppsSubtitle => 'Instagram, TikTok, X usw.';

  @override
  String get owlWhatsAppNotFound => 'WhatsApp nicht gefunden';

  @override
  String get owlSMSNotFound => 'SMS-App nicht gefunden';

  @override
  String get owlDisconnectAction => 'Trennen';

  @override
  String owlDisconnectConfirm(String name) {
    return 'Sind Sie sicher, dass Sie die magische Verbindung mit${name}lösen möchten?';
  }

  @override
  String get owlDisconnectConfirmButton => 'Ja, trennen';

  @override
  String get owlCancel => 'Stornieren';

  @override
  String get owlSendMagic => 'Senden (Charmed)';

  @override
  String get owlSend => 'Schicken';

  @override
  String get owlCookieAdded => 'Cookie hinzugefügt';

  @override
  String get owlAddCookie => 'Cookie hinzufügen';

  @override
  String get owlNoCookiesInCollection => 'Keine Cookies in Ihrer Sammlung';

  @override
  String get owlWriteLetterHint => 'Schreiben Sie Ihren Brief...';

  @override
  String get owlSendCookie => 'Cookie senden';

  @override
  String get zodiacMeasureHarmony => 'KOSMISCHE HARMONIE MESSEN';

  @override
  String get zodiacDiscoverEnergy =>
      'Entdecken Sie Ihre duale Energie, geleitet von den Sternen';

  @override
  String get zodiacChooseFriend => 'WÄHLE FREUND';

  @override
  String get zodiacChooseFriendSubtitle =>
      'Wählen Sie einen Freund aus, um Ihre kosmischen Energien zu vergleichen';

  @override
  String get zodiacDiscoverYourself => 'Entdecken Sie sich selbst';

  @override
  String get zodiacCharacteristicAnalysis => 'CHARAKTERISTISCHE ANALYSE';

  @override
  String zodiacAbilityMap(String name) {
    return 'Fähigkeitskarte von$name';
  }

  @override
  String get zodiacPros => 'Vorteile';

  @override
  String get zodiacCons => 'Herausforderungen';

  @override
  String get zodiacAdvice => 'Beratung';

  @override
  String get zodiacDailyWhisperSubtitle =>
      'Spüren Sie das heutige Flüstern und\nEntdecken Sie die Geheimnisse Ihres spirituellen Porträts.';

  @override
  String get zodiacDailyWhisperHeadline =>
      'Die heutige Botschaft und das spirituelle Porträt';

  @override
  String get zodiacOpenGuide => 'Öffnen Sie den Leitfaden';

  @override
  String get zodiacNoFriends => 'Noch keine Freunde';

  @override
  String get zodiacSelect => 'WÄHLEN';

  @override
  String get zodiacQuestCompleted => 'Quest abgeschlossen';

  @override
  String get zodiacQuestCompletedSubtitle =>
      'Sie sind vollständig auf den Rhythmus des Universums ausgerichtet.';

  @override
  String get zodiacRewardAura => 'Verdiente Belohnung:\n+4 AURA';

  @override
  String get zodiacStartNewQuest => 'NEUE QUEST STARTEN';

  @override
  String zodiacDailyQuestTitle(int days) {
    return '$days-TAGESQUEST';
  }

  @override
  String zodiacDailyQuestDesc(String weakness) {
    return 'Brechen Sie Ihre Schwäche: „$weakness“';
  }

  @override
  String zodiacQuestDayProgress(int current, int total) {
    return 'TAG$current/$total';
  }

  @override
  String get zodiacQuestTodayDiscovery => 'HEUTE ENTDECKUNG';

  @override
  String get zodiacQuestCompletedToday => 'HEUTE ABGESCHLOSSEN';

  @override
  String get zodiacQuestCompleteNow => 'Schließe die Quest jetzt ab';

  @override
  String get zodiacQuestMarkCompleted => 'Ich habe es heute abgeschlossen';

  @override
  String get zodiacLoveHarmony => 'LIEBE HARMONIE';

  @override
  String get zodiacFriendshipHarmony => 'FREUNDSCHAFT';

  @override
  String get zodiacCommunicationHarmony => 'KOMMUNIKATION & VERSTAND';

  @override
  String get zodiacWorkHarmony => 'ZUSAMMENARBEIT';

  @override
  String get zodiacAdventureHarmony => 'ABENTEUER & SPASS';

  @override
  String get zodiacViralDynamics => 'VIRALE DYNAMIK';

  @override
  String get zodiacDeepSynastryMap => 'DEEP SYNASTRY MAP';

  @override
  String zodiacSynastrySubtitle1(String name) {
    return 'Die Harmonie zwischen Ihnen und${name}ist nicht auf Sonnenzeichen beschränkt.';
  }

  @override
  String get zodiacSynastrySubtitle2 =>
      'Basierend auf der Privatsphäre vergleicht der kosmische Algorithmus hinter den Kulissen astrologische Geburtshoroskope, Mond- und Aufgangsphasen, sodass diese Analyse für Sie völlig einzigartig ist.';

  @override
  String get zodiacDailyWhisperTitle => 'Das heutige Flüstern';

  @override
  String get zodiacChooseSign => 'WÄHLEN SIE ZEICHEN';

  @override
  String get zodiacCosmicGuide => 'IHR KOSMISCHER FÜHRER';

  @override
  String get zodiacNew => 'NEU';

  @override
  String get zodiacCosmicHarmonyTitle => 'KOSMISCHE HARMONIE';

  @override
  String get zodiacAwesome => 'EINDRUCKSVOLL';

  @override
  String get zodiacSpiritPortrait => 'Spirituelles Porträt';

  @override
  String get onboardingFeatureStepTitle => 'Was erwartet Sie?';

  @override
  String get onboardingFeatureStepSub =>
      'Sind Sie bereit, dem Flüstern des Universums zu lauschen und Ihr Schicksal zu entdecken?';

  @override
  String get onboardingNameStepTitle => 'Lernen wir Sie kennen';

  @override
  String get onboardingNameStepSub =>
      'Erstellen Sie Ihr Profil und bestimmen Sie Ihre kosmische Identität, damit Ihre Seelenverwandten Sie finden können.';

  @override
  String get onboardingDateStepTitle => 'Kosmische Koordinaten';

  @override
  String get onboardingDateStepSub =>
      'Wählen Sie den Zeitpunkt Ihrer Geburt als Grundlage für Ihr astrologisches Horoskop.';

  @override
  String get onboardingFocusStepTitle => 'Herzkompass';

  @override
  String get onboardingFocusStepSub =>
      'Legen Sie Ihre Absicht fest, lassen Sie uns Ihren Weg planen.';

  @override
  String get onboardingDreamStepTitle => 'Stimme des Unterbewusstseins';

  @override
  String get onboardingDreamStepSub => 'Wie erreichen dich deine Träume?';

  @override
  String get onboardingSleepStepTitle => 'Dein innerer Kompass';

  @override
  String get onboardingSleepStepSub =>
      'Wie finden Sie sich an den Wendepunkten des Schicksals in Ihrem Leben zurecht?';

  @override
  String get onboardingFeatureAstrology =>
      'Personalisiertes Astrologie-Diagramm';

  @override
  String get onboardingFeatureTarot => 'Leitende Tarot-Reise';

  @override
  String get onboardingFeatureCoffee =>
      'Alte Geheimnisse der Kaffee-Wahrsagerei';

  @override
  String get onboardingFeatureDream => 'Unterbewusste Traumanalyse';

  @override
  String get onboardingFeatureZodiac =>
      'Mystische Chinesisch- und Maya-Kompatibilitäten';

  @override
  String get onboardingWelcomeTagline =>
      'Heute sind meine Hoffnungen größer als meine Träume.';

  @override
  String get onboardingFinalTagline =>
      'Klicken Sie hier, um Ihr kosmisches Diagramm zu sichern.';

  @override
  String get tarotShareText =>
      'Die Karten haben mich so angesprochen! 🔮✨\n#CrackWish #Tarot';

  @override
  String get natalChartTitle => 'Geburtshoroskop';

  @override
  String get natalChartCalculating => 'Berechnen Sie Ihr Geburtshoroskop...';

  @override
  String get natalChartSwipeHint => 'Wischen Sie, um zu „Inspizieren“.';

  @override
  String get natalChartPlanetPositions => 'PLANETENPOSITIONEN';

  @override
  String get natalChartAngularPoints => 'WINKELPUNKTE';

  @override
  String get natalChartAsc => 'ASC (Aszendent)';

  @override
  String get natalChartAscDesc =>
      'Die Maske, die Sie der Außenwelt zeigen, Ihr Bild und Ihr erster Eindruck.';

  @override
  String get natalChartMc => 'MC (Midheaven)';

  @override
  String get natalChartMcDesc =>
      'Ihre Karriere, Ihr öffentliches Image und Ihre Lebensziele.';

  @override
  String get natalChartDc => 'DC (Nachkomme)';

  @override
  String get natalChartDcDesc =>
      'Die Kernmerkmale, nach denen Sie in Beziehungen, Ehe und Partnerschaften suchen.';

  @override
  String get natalChartIc => 'IC (Imum Coeli)';

  @override
  String get natalChartIcDesc =>
      'Deine Wurzeln, deine Familie, deine Vergangenheit und deine zentrale Sicherheit in deiner inneren Welt.';

  @override
  String get natalChartTabPersonality => 'Hauptübersicht der Persönlichkeit';

  @override
  String get natalChartTabLove => 'Liebe & Beziehungen';

  @override
  String get natalChartTabCareer => 'Karriere & Geld';

  @override
  String get natalChartTabEmotional => 'Emotionale Struktur';

  @override
  String get natalChartTabStrengths => 'Stärken und Schwächen';

  @override
  String natalChartHouse(String house) {
    return 'Haus$house';
  }

  @override
  String zodiacGreeting(String name) {
    return 'Hallo$name,';
  }

  @override
  String get zodiacCosmicTraveler => 'Kosmischer Reisender,';

  @override
  String get zodiacBirthDate => 'GEBURTSDATUM';

  @override
  String get zodiacStarsKnowYou => 'Lass die Sterne dich kennen';

  @override
  String get zodiacConfirm => 'BESTÄTIGEN';

  @override
  String get zodiacDiscoverYourselfBtn => 'ENTDECKEN SIE SICH';

  @override
  String get zodiacEliteRequiredDesc =>
      'Sie benötigen ein Elite-Abonnement, um mit Ihren Freunden tiefe astrologische Kompatibilität und virale Dynamik zu entdecken.';

  @override
  String get zodiacEliteDiscoverBtn => 'Entdecken Sie Elite-Privilegien';

  @override
  String get zodiacHubWestern => 'WESTLICHE ASTROLOGIE';

  @override
  String get zodiacHubAsian => 'ASIATISCHE ASTROLOGIE';

  @override
  String get zodiacHubMayan => 'Maya-Astrologie';

  @override
  String get actionLater => 'Später';

  @override
  String get coffeeViewReading => 'Lesung ansehen';

  @override
  String get coffeeReadyTitleWithEmoji => '☕️ Deine Lektüre ist fertig!';

  @override
  String get wheelTask_w_c1 =>
      'Senden Sie einer geliebten Person eine „Denk an Dich“-Nachricht';

  @override
  String get wheelTask_w_c2 =>
      'Begrüßen Sie jemanden, mit dem Sie eine Weile nicht gesprochen haben';

  @override
  String get wheelTask_w_c3 =>
      'Sagen Sie einem Familienmitglied, wie wichtig es heute ist';

  @override
  String get wheelTask_w_c4 => 'Machen Sie jemandem neben Ihnen ein Kompliment';

  @override
  String get wheelTask_w_c5 => 'Senden Sie einem Freund ein lustiges Video';

  @override
  String get wheelTask_w_c6 =>
      'Bedanken Sie sich heute bei jemandem und erklären Sie, warum';

  @override
  String get wheelTask_w_s1 =>
      'Schauen Sie in den Spiegel, lächeln Sie sich selbst an und halten Sie 10 Sekunden lang gedrückt';

  @override
  String get wheelTask_w_s2 =>
      'Erinnern Sie sich an das letzte Mal, als Sie laut gelacht haben, und lächeln Sie erneut';

  @override
  String get wheelTask_w_s3 =>
      'Denken Sie an eine lustige Erinnerung und lachen Sie laut';

  @override
  String get wheelTask_w_s4 =>
      'Suchen Sie das lustigste Foto auf Ihrem Handy und schauen Sie es sich an';

  @override
  String get wheelTask_w_s5 => 'Lächle die erste Person an, die du siehst';

  @override
  String get wheelTask_w_s6 =>
      'Denken Sie an den lustigsten Moment, den Sie heute erlebt haben';

  @override
  String get wheelTask_w_m1 =>
      'Stehen Sie auf und strecken Sie sich 30 Sekunden lang';

  @override
  String get wheelTask_w_m2 => 'Gehen Sie eine Minute lang durch Ihr Zimmer';

  @override
  String get wheelTask_w_m3 => 'Springe 10 Mal und sage „Ich schaffe das!“';

  @override
  String get wheelTask_w_m4 =>
      'Heben Sie Ihre Arme und machen Sie 20 Sekunden lang eine Superman-Pose';

  @override
  String get wheelTask_w_m5 =>
      'Rollen Sie Ihre Schultern fünfmal nach vorne und dann fünfmal nach hinten';

  @override
  String get wheelTask_w_m6 =>
      'Atmen Sie tief ein, öffnen Sie Ihre Arme weit und halten Sie sie 10 Sekunden lang gedrückt';

  @override
  String get wheelTask_w_mu1 =>
      'Spielen Sie Ihr Lieblingslied und hören Sie es 1 Minute lang zu';

  @override
  String get wheelTask_w_mu2 =>
      'Spielen Sie ein zufälliges Lied und hören Sie sich die ersten 30 Sekunden an';

  @override
  String get wheelTask_w_mu3 =>
      'Singen! Singen Sie laut, als ob niemand zuhört';

  @override
  String get wheelTask_w_mu4 =>
      'Hören Sie sich einen Song in einem Genre an, das Sie heute noch nicht kennengelernt haben';

  @override
  String get wheelTask_w_mu5 =>
      'Schließen Sie Ihre Augen und lauschen Sie 30 Sekunden lang den Geräuschen um Sie herum';

  @override
  String get wheelTask_w_mu6 =>
      'Klopfen Sie mit Ihrem Finger 15 Sekunden lang einen Rhythmus auf den Tisch';

  @override
  String get wheelTask_w_g1 =>
      'Denken Sie an eine Sache, die Sie heute haben, und sagen Sie „Danke“';

  @override
  String get wheelTask_w_g2 =>
      'Zählen Sie 3 kleine Dinge, die Sie glücklich machen';

  @override
  String get wheelTask_w_g3 =>
      'Denken Sie an das Beste, was Sie heute gegessen haben, und erinnern Sie sich an seinen Geschmack';

  @override
  String get wheelTask_w_g4 =>
      'Denken Sie 10 Sekunden lang an den schönsten Moment Ihres Lebens';

  @override
  String get wheelTask_w_g5 =>
      'Seien Sie dankbar für Ihre Gesundheit. Atmen Sie tief ein.';

  @override
  String get wheelTask_w_g6 =>
      'Seien Sie dankbar, dass heute die Sonne aufgegangen ist';

  @override
  String get wheelTask_w_f1 => 'Springe dreimal und rufe „Ich schaffe das!“';

  @override
  String get wheelTask_w_f2 =>
      'Machen Sie Ihr lustigstes Gesicht und halten Sie es 5 Sekunden lang gedrückt';

  @override
  String get wheelTask_w_f3 => 'Imitiere ein Tier – welches Tier wärst du?';

  @override
  String get wheelTask_w_f4 =>
      'Schließen Sie die Augen und stellen Sie sich 10 Sekunden lang vor, Sie würden fliegen';

  @override
  String get wheelTask_w_f5 =>
      'Nehmen Sie eine Superheldenpose ein und halten Sie diese 5 Sekunden lang';

  @override
  String get wheelTask_w_f6 => 'Gehen Sie 10 Schritte wie ein Roboter';

  @override
  String get zodiacAccessWesternAdTitle => 'Tägliches Gratislimit erreicht';

  @override
  String get zodiacAccessWesternAdDesc =>
      'Sie können sich eine kurze Anzeige ansehen, um wieder in die westliche Astrologie einzusteigen.';

  @override
  String get zodiacAccessWatchAdBtn => 'Anzeige ansehen';

  @override
  String get zodiacAccessGetEliteBtn => 'Holen Sie sich Elite';

  @override
  String get zodiacAccessGateTitle => 'Tor der kosmischen Weisheit';

  @override
  String zodiacAccessStoneCount(Object count) {
    return 'Du hast${count}Seelensteine';
  }

  @override
  String get zodiacAccessPremiumInfo1 =>
      'Zugangsberechtigung zu Tierkreistiefen';

  @override
  String get zodiacAccessPremiumInfo2 =>
      'Jedes Astrologiediagramm verbraucht 1 Seelenstein';

  @override
  String get zodiacAccessPremiumInfo3Elite =>
      'Elite: Unbegrenzter Zugang mit 1 Seelenstein pro Tag';

  @override
  String get zodiacAccessPremiumInfo3Normal =>
      '1 Seelenstein reicht bei Elite pro Tag';

  @override
  String get zodiacAccessOneStoneBtn => '1 Seelenstein';

  @override
  String get onboardingTestSimulate =>
      'Testmodus: Anmeldung mit altem Konto simulieren...';

  @override
  String get onboardingTestAnon => 'Testmodus: Anonym verbinden...';

  @override
  String onboardingGoogleLoginFailed(Object error) {
    return 'Google-Anmeldung fehlgeschlagen:$error';
  }

  @override
  String onboardingAppleLoginFailed(Object error) {
    return 'Apple-Anmeldung fehlgeschlagen:$error';
  }

  @override
  String onboardingGoogleRegisterFailed(Object error) {
    return 'Google-Registrierung fehlgeschlagen:$error';
  }

  @override
  String onboardingAppleRegisterFailed(Object error) {
    return 'Apple-Registrierung fehlgeschlagen:$error';
  }

  @override
  String dreamDataError(Object error) {
    return 'Fehler bei gespeicherten Daten:$error';
  }

  @override
  String get onboardingBirthDateTitle => 'IHR GEBURTSDATUM';

  @override
  String get onboardingSelectBirthDate => 'Wählen Sie Ihr Geburtsdatum';

  @override
  String get onboardingBirthTimeTitle => 'GEBURTSZEIT (optional)';

  @override
  String get onboardingBirthPlaceTitle => 'GEBURTSORT (Optional)';

  @override
  String get onboardingPickerDateTitle => 'Wählen Sie Geburtsdatum aus';

  @override
  String get onboardingPickerTimeTitle => 'Wählen Sie Geburtszeit aus';

  @override
  String get onboardingPickerDone => 'Erledigt';

  @override
  String get onboardingLifeFocusSpiritual => 'Spirituell\nErwachen';

  @override
  String get onboardingLifeFocusCareer => 'Karriere &\nPersönliche Macht';

  @override
  String get onboardingLifeFocusLove => 'Liebe &\nKosmische Harmonie';

  @override
  String get onboardingLifeFocusHealing => 'Heilung &\nInnerer Frieden';

  @override
  String get onboardingLifeFocusWealth => 'Reichtum &\nFülle';

  @override
  String get onboardingLifeFocusSurprise => 'Universum\nÜberraschungen';

  @override
  String get onboardingDreamMessenger => 'Messenger & Vivid Dreams';

  @override
  String get onboardingDreamChaotic =>
      'Überraschende und chaotische Ereignisse';

  @override
  String get onboardingDreamCalm => 'So ruhig wie die Wolken';

  @override
  String get onboardingSleepMindTitle => 'Licht des Geistes';

  @override
  String get onboardingSleepMindDesc =>
      'Ich analysiere Ereignisse, wäge sie mit Logik ab und plane konkrete Schritte.';

  @override
  String get onboardingSleepMindVal => 'Licht des Geistes (Logik)';

  @override
  String get onboardingSleepHeartTitle => 'Flüstern des Herzens';

  @override
  String get onboardingSleepHeartDesc =>
      'Ich höre auf meine innere Stimme und vertraue immer meinen Gefühlen statt der Logik.';

  @override
  String get onboardingSleepHeartVal => 'Flüstern des Herzens (Intuition)';

  @override
  String get onboardingSleepUniverseTitle => 'Fluss des Universums';

  @override
  String get onboardingSleepUniverseDesc =>
      'Ich glaube, dass alles aus einem Grund geschieht, und folge den Zeichen des Universums.';

  @override
  String get onboardingSleepUniverseVal => 'Fluss des Universums (Schicksal)';

  @override
  String get linkAccountTitle => 'Konto verknüpfen';

  @override
  String get linkGoogleAccount => 'Google-Konto verknüpfen';

  @override
  String get linkAppleAccount => 'Apple-Konto verknüpfen';

  @override
  String get linkAccountStarted => 'Konto-Verknüpfungsprozess gestartet...';

  @override
  String get linkAccountFailed => 'Konto-Verknüpfung fehlgeschlagen';

  @override
  String get profileSignOutGuestDesc =>
      'Warnung: Wenn Sie sich von einem Gastkonto abmelden, können Sie nicht mehr auf dieses Konto zugreifen und alle Ihre Daten (Seelensteine, Lesungen) gehen DAUERHAFT VERLOREN. Sind Sie sicher, dass Sie sich abmelden möchten?';
}
