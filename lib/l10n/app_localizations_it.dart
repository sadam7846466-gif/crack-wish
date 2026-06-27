// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Crepa&Desiderio';

  @override
  String get language => 'Lingua';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get turkish => 'turco';

  @override
  String get english => 'Inglese';

  @override
  String get close => 'Vicino';

  @override
  String languageValue(Object value) {
    return 'Selezionato:$value';
  }

  @override
  String get navHome => 'Casa';

  @override
  String get navCollection => 'Collezione';

  @override
  String get navProfile => 'Profilo';

  @override
  String get dailyCookieTitle => 'Biscotto quotidiano';

  @override
  String get dailyCookieSubtitle => 'Tocca per tentare la fortuna';

  @override
  String get luckyNumber => 'Numero fortunato';

  @override
  String get luckyColor => 'Colore fortunato';

  @override
  String get luckLabel => 'Fortuna';

  @override
  String get todayFortune => 'La fortuna di oggi';

  @override
  String get shareButton => '📸Condividi';

  @override
  String fortuneShareText(
    Object emoji,
    Object title,
    Object meaning,
    Object number,
    Object color,
    Object percent,
  ) {
    return '$emoji$title${meaning}Numero fortunato:${number}Colore fortunato:${color}Fortuna:$percent%\n\nDall\'app Biscotto della fortuna 🥠';
  }

  @override
  String get themeSelectTitle => 'Seleziona Tema';

  @override
  String themeSelected(Object value) {
    return 'Tema selezionato:$value';
  }

  @override
  String get themeGalleryTitle => 'Galleria a tema';

  @override
  String get themeGalleryOpen => 'Vai all\'elenco dei temi';

  @override
  String get themeGalleryLimited =>
      'La galleria dei temi è attualmente limitata a due opzioni';

  @override
  String get statCookies => 'Biscotti';

  @override
  String get statStreakDays => 'Giorni di serie';

  @override
  String get statDreams => 'Sogni';

  @override
  String get statMood => 'Umore';

  @override
  String get statTheme => 'Oggi...';

  @override
  String get statCollection => 'Il mio biscotto';

  @override
  String get statTalisman => 'Talismano';

  @override
  String get moodGood => 'Bene';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodBad => 'Cattivo';

  @override
  String get moodHappy => 'Contento';

  @override
  String get moodGreat => 'Grande';

  @override
  String get shortcutCollection => 'Collezione';

  @override
  String get shortcutHistory => 'Storia';

  @override
  String get shortcutFavorites => 'Preferiti';

  @override
  String get sectionShortcuts => 'Scorciatoie';

  @override
  String get sectionActivity => 'Attività';

  @override
  String get menuBadges => 'Distintivi';

  @override
  String get menuBadgesSubtitle => 'Risultati e livelli';

  @override
  String get menuSettings => 'Impostazioni';

  @override
  String get menuSettingsSubtitle => 'Notifiche, tema, privacy';

  @override
  String get menuHelpAbout => 'Aiuto e informazioni';

  @override
  String get menuHelpAboutSubtitle =>
      'Domande frequenti e informazioni sulla versione';

  @override
  String get menuShare => 'Condividere';

  @override
  String get menuShareSubtitle => 'Condividi il tuo profilo con gli amici';

  @override
  String get activityTarotOpenedTitle => 'Si è aperta la lettura dei Tarocchi';

  @override
  String get activityTarotOpenedSubtitle => 'Oggi • Carta: Stella';

  @override
  String activityCookiesOpenedTitle(Object count) {
    return '${count}biscotti rotti';
  }

  @override
  String get activityCookiesOpenedSubtitle => 'Ieri • Nuovi messaggi aperti';

  @override
  String get activityDreamSavedTitle => 'Interpretazione dei sogni salvata';

  @override
  String get activityDreamSavedSubtitle => '2 giorni fa';

  @override
  String get profileUserTitle => 'Utente';

  @override
  String get profileSubtitle => 'Meno rumore, più te';

  @override
  String get tagTarot => 'Tarocchi';

  @override
  String get tagDream => 'Sogno';

  @override
  String get tagCollection => 'Collezione';

  @override
  String get zodiacTitle => '⭐ Lettura dello zodiaco';

  @override
  String zodiacDailyTitle(Object name) {
    return '$name- Lettura quotidiana';
  }

  @override
  String get zodiacDailyBody =>
      'Sei fortunato in amore questa settimana! Le opportunità di carriera sono alla tua porta: tieni gli occhi aperti. La tua energia è alta, usala. È il momento perfetto per nuovi progetti. Le tue capacità comunicative sono al massimo, approfittane.';

  @override
  String get zodiacLove => 'Amore';

  @override
  String get zodiacCareer => 'Carriera';

  @override
  String get zodiacMoney => 'Soldi';

  @override
  String get zodiacHealth => 'Salute';

  @override
  String get collectionTitle => 'La tua collezione';

  @override
  String get collectionSubtitle =>
      'Tracce e soddisfazioni del tuo rituale quotidiano';

  @override
  String get collectionNotYet => 'Non ancora';

  @override
  String get collectionFirstTime => 'Prima volta';

  @override
  String get collectionTotalOpened => 'Totale';

  @override
  String get collectionCookieDescription =>
      'Questo biscotto aggiunge fortuna e piccole sorprese al tuo rituale. Più apri, più forte diventa la tua collezione.';

  @override
  String get collectionSummaryTitle => 'Riepilogo della raccolta';

  @override
  String get collectionSummaryTypes => 'Tipi unici';

  @override
  String get collectionSummaryTotalOpened => 'Totale aperto';

  @override
  String get collectionSummaryRare => 'Raro';

  @override
  String get collectionSummaryFooter =>
      'Ogni biscotto ha una storia. Più apri, più diventa ricco.';

  @override
  String get rarityAll => 'Tutto';

  @override
  String get rarityCommon => 'Comune';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityLegendary => 'Leggendario';

  @override
  String get collectionUndiscovered => 'Da scoprire';

  @override
  String get collectionNotFoundYet =>
      'La fortuna non ti ha portato qui... ancora.';

  @override
  String get collectionEmptyTitle => 'Non hai ancora aperto nessun cookie';

  @override
  String collectionEmptySubtitle(Object count) {
    return '${count}diversi cookie ti stanno aspettando. Apri il cookie di oggi per iniziare la tua raccolta.';
  }

  @override
  String get discoverTitle => 'Scoprire';

  @override
  String get discoverSubtitle => 'Esplora nuove funzionalità';

  @override
  String get discoverCategories => 'Categorie';

  @override
  String get categoryTarotTitle => 'Lettura dei Tarocchi';

  @override
  String get categoryTarotDesc => 'Tarocchi a 3 carte';

  @override
  String get categoryDreamTitle => 'Interpretazione dei sogni';

  @override
  String get categoryDreamDesc => 'Scopri il significato dei tuoi sogni';

  @override
  String get categoryZodiacTitle => 'Lettura dello zodiaco';

  @override
  String get categoryZodiacDesc => 'Messaggio dalle stelle';

  @override
  String get categoryPersonalityTitle => 'Test della personalità';

  @override
  String get categoryPersonalityDesc => '16 personalità';

  @override
  String get discoverDailySuggestionTitle => 'IL CONSIGLIO DI OGGI';

  @override
  String get discoverDailySuggestionHeadline => 'Hai fatto un sogno stanotte?';

  @override
  String get discoverDailySuggestionSubtitle =>
      'Interpretalo ora e scoprine il significato!';

  @override
  String get dailySuggestionDreamHeadline => 'Hai fatto un sogno stanotte?';

  @override
  String get dailySuggestionDreamSubtitle =>
      'Interpretalo ora e scoprine il significato!';

  @override
  String get dailySuggestionTarotHeadline => 'Hai controllato i tarocchi oggi?';

  @override
  String get dailySuggestionTarotSubtitle =>
      'Scegli 3 carte e vedi il tuo messaggio!';

  @override
  String get dailySuggestionZodiacHeadline =>
      'Hai già controllato la lettura dello zodiaco?';

  @override
  String get dailySuggestionZodiacSubtitle =>
      'Scopri subito l\'energia di oggi!';

  @override
  String get dailySuggestionCoffeeHeadline => 'Hai bevuto caffè oggi?';

  @override
  String get dailySuggestionCoffeeSubtitle =>
      'Capovolgi la tazza, leggiamo la tua fortuna!';

  @override
  String get dailySuggestionAllDoneHeadline =>
      'I rituali di oggi sono completi!';

  @override
  String get dailySuggestionAllDoneSubtitle =>
      'Torna domani per nuovi contenuti.';

  @override
  String get discoverFeaturedTag => 'IN PRIMO PIANO';

  @override
  String get discoverFeaturedTitle => 'Lettura dei Tarocchi a 3 carte';

  @override
  String get discoverFeaturedSubtitle =>
      'Esplora il tuo passato, presente e futuro';

  @override
  String get ctaStart => 'Inizio';

  @override
  String get homeGreeting => 'Ciao! 👋';

  @override
  String get homeFeeling => 'Come ti senti oggi?';

  @override
  String get quoteOfDayText =>
      'Il più piccolo passo che fai oggi porta alla più grande vittoria domani.';

  @override
  String get quoteOfDaySource => '— Citazione del giorno';

  @override
  String get dailyHoroscopeTitle => 'Ariete';

  @override
  String get dailyHoroscopeSubtitle => 'Lettura di oggi';

  @override
  String get dailyHoroscopeBody =>
      'Sei fortunato in amore questa settimana! Le opportunità di carriera sono alla tua porta: tieni gli occhi aperti. La tua energia è alta, usala.';

  @override
  String get aries => 'Ariete';

  @override
  String get bentoTarotTitle => 'Tarocchi';

  @override
  String get bentoTarotDesc => 'Guarda il tuo futuro';

  @override
  String get bentoTarotBadge => 'POPOLARE';

  @override
  String get bentoDreamTitle => 'Sogno';

  @override
  String get bentoDreamDesc => 'Esplora il tuo subconscio';

  @override
  String get bentoDreamBadge => 'NUOVO';

  @override
  String get bentoMotivationTitle => 'Umore';

  @override
  String get bentoMotivationDesc => 'Scopri il tuo umore';

  @override
  String get bentoMotivationBadge => 'QUOTIDIANO';

  @override
  String get bentoZodiacTitle => 'Zodiaco';

  @override
  String get bentoZodiacDesc => 'Messaggio dalle stelle';

  @override
  String get bentoZodiacBadge => 'QUOTIDIANO';

  @override
  String get moodQuestion => 'Come stai oggi?';

  @override
  String get dreamTitle => 'Racconta il tuo sogno';

  @override
  String get dreamTabNew => 'Nuovo sogno';

  @override
  String get dreamTabHistory => 'I miei sogni';

  @override
  String get dreamAnalyzeButton => 'Interpretare il sogno';

  @override
  String get dreamAnalyzeEstimate => '~ 5 secondi';

  @override
  String get dreamInterpretationTitle => 'Interpretazione dei sogni';

  @override
  String get dreamNoHistory => 'Non hai ancora nessun sogno salvato';

  @override
  String get dreamDefaultTitle => 'Sogno';

  @override
  String get dreamSpiritual => 'Spirituale';

  @override
  String get dreamEnriched => 'Interpretazione arricchita';

  @override
  String get dreamEnriching => 'Arricchire...';

  @override
  String get dreamEnrich => 'Arricchire';

  @override
  String get dreamShare => 'Condividere';

  @override
  String get dreamAnalyzing => 'Analizzando il sogno...';

  @override
  String get dreamAnalysisFailed =>
      'Impossibile generare un\'interpretazione in questo momento.';

  @override
  String get dreamClarifyThreat =>
      'C\'era un senso di minaccia o di paura nel sogno?';

  @override
  String get dreamClarifyFamiliar =>
      'Questa scena ti sembrava familiare dal passato?';

  @override
  String get dreamClarifyEscape => 'C\'era un senso di movimento o di fuga?';

  @override
  String get dreamClarifyAnxious => 'Hai provato ansia o minaccia nel sogno?';

  @override
  String get dreamUnsure => 'Non è sicuro';

  @override
  String get dreamYes => 'SÌ';

  @override
  String get dreamNo => 'NO';

  @override
  String get dreamGeneral => 'Sogno generale';

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
    return 'Titolo del sogno:${title}Data:${date}Sogno:${text}Generale:${general}Psicologico:${psychology}Spirituale:${spiritual}Consiglio:$advice#Vfortunato #Sogno';
  }

  @override
  String get scientificTitle => 'Analisi scientifica dei sogni';

  @override
  String get scientificDreamPromptTitle => 'Racconta il tuo sogno';

  @override
  String get scientificDreamHint =>
      'Scrivi il tuo sogno così come lo ricordi...';

  @override
  String get scientificEmotionQuestion =>
      'Come ti sei sentito quando ti sei svegliato?';

  @override
  String get scientificEmotionHint => 'Scegli un\'emozione';

  @override
  String get scientificClarityQuestion => 'Quanto era chiaro il sogno?';

  @override
  String get scientificDisclaimer =>
      'Questa analisi si basa sulla ricerca psicologica e neuroscientifica. Non fornisce risultati definitivi o predittivi.';

  @override
  String get scientificLoading =>
      'Valutazione basata sul sonno REM e sulle neuroscienze';

  @override
  String get scientificResultsTitle => 'Interpretazione dei sogni';

  @override
  String get scientificRecentPastTitle => 'Effetti del passato recente';

  @override
  String get scientificSaved => 'Sogno salvato';

  @override
  String get scientificSaveButton => 'Salva Sogno';

  @override
  String get cookieSpringWreath => 'Ghirlanda primaverile';

  @override
  String get cookieLuckyClover => 'Trifoglio fortunato';

  @override
  String get cookieRoyalHearts => 'Cuori reali';

  @override
  String get cookieEvilEye => 'Malocchio';

  @override
  String get cookiePizzaParty => 'Festa della Pizza';

  @override
  String get cookieSakuraBloom => 'Sakura fiorisce';

  @override
  String get cookieBluePorcelain => 'Porcellana blu';

  @override
  String get cookiePinkBlossom => 'Fiore rosa';

  @override
  String get cookieFortuneCat => 'Gatto della fortuna';

  @override
  String get cookieWildflower => 'Fiore di campo';

  @override
  String get cookieCupidRibbon => 'Nastro di Cupido';

  @override
  String get cookiePandaBamboo => 'Panda Bambù';

  @override
  String get cookieRamadanCute => 'Ramadan';

  @override
  String get cookieEnchantedForest => 'Foresta Incantata';

  @override
  String get cookieGoldenArabesque => 'Arabesco d\'oro';

  @override
  String get cookieMidnightMosaic => 'Mosaico di mezzanotte';

  @override
  String get cookiePearlLace => 'Pizzo di perle';

  @override
  String get cookieGoldenSakura => 'Sakura d\'oro';

  @override
  String get cookieDragonPhoenix => 'Drago Fenice';

  @override
  String get cookieGoldBeasts => 'Bestie d\'oro';

  @override
  String get emotionAnxiety => 'Ansioso';

  @override
  String get emotionFear => 'Paura';

  @override
  String get emotionCalm => 'Calma';

  @override
  String get emotionHappy => 'Contento';

  @override
  String get emotionSad => 'Triste';

  @override
  String get emotionConfusion => 'Incerto';

  @override
  String get emotionSurprise => 'Sorpreso';

  @override
  String get dreamMoodQuestion =>
      'Come ti sei sentito quando ti sei svegliato?';

  @override
  String get dreamMetricEmotional => 'Carico emotivo';

  @override
  String get dreamMetricUncertainty => 'Narrativa\nIncertezza';

  @override
  String get dreamMetricRecentPast => 'Passato recente';

  @override
  String get dreamMetricBrain => 'Attività cerebrale';

  @override
  String get tarotShuffleHint => 'Trascina in un cerchio per mescolare';

  @override
  String get tarotEnergyDepletedTitle => 'Energia esaurita';

  @override
  String get tarotEnergyDepletedBody =>
      'La tua energia cosmica quotidiana è esaurita.\nRicaricati per vedere la verità.';

  @override
  String get tarotEnergyDepletedSub =>
      'Le carte selezionate sono pronte, manca solo un passo...';

  @override
  String get tarotWatchAd => 'Guarda l\'annuncio e apri';

  @override
  String tarotFreeRemaining(Object count) {
    return 'Libero rimanente oggi:$count';
  }

  @override
  String get socialFeedTitle => 'Alimentazione tranquilla';

  @override
  String get feedTypeCookie => 'Biscotto';

  @override
  String get feedTagDailyCookie => 'Il biscotto di oggi';

  @override
  String get feedTypeTarot => 'Tarocchi';

  @override
  String get feedTagThreeCard => 'Pesca di 3 carte';

  @override
  String get feedTypeDream => 'Sogno';

  @override
  String get feedTagDreamMode => 'Modalità sogno';

  @override
  String get feedTypeZodiac => 'Zodiaco';

  @override
  String get feedTagDailyEnergy => 'Energia quotidiana';

  @override
  String get feedTypeMotivation => 'Motivazione';

  @override
  String get feedTagMiniAction => 'Miniazione';

  @override
  String inviteShareMessage(String handle, String link) {
    return 'Sei pronto per un viaggio mistico? Ti aspetto nell\'universo di Crack&Wish! ✨\n\nIl mio codice invito:${handle}Scarica ora:$link';
  }

  @override
  String get inviteShareSubject => 'Crack&Wish Invito';

  @override
  String get inviteSendButton => 'Invitare';

  @override
  String get inviteConnectButton => 'Collegare';

  @override
  String get inviteSentText => 'Inviato';

  @override
  String inviteRequestSent(String name) {
    return 'Richiesta inviata a$name!';
  }

  @override
  String get toastCoffeeReadyTitle => 'La tua lettura è pronta!';

  @override
  String get toastCoffeeReadyMessage =>
      'I segreti nella tua tazza sono stati rivelati.';

  @override
  String get toastViewButton => 'Visualizzazione';

  @override
  String get toastDreamReadyTitle => 'Il tuo sogno è interpretato!';

  @override
  String get toastDreamReadyMessage =>
      'I messaggi del tuo subconscio sono stati decodificati.';

  @override
  String get toastCoffeeReadyTitle2 => 'La tua lettura del caffè è pronta!';

  @override
  String get dreamFallbackTitle => 'Interpretazione dei sogni';

  @override
  String get rewardWelcomeTitle => 'Benvenuti nell\'Universo';

  @override
  String get rewardWelcomeDesc =>
      'Ti abbiamo lasciato un piccolo regalo per iniziare il tuo viaggio.';

  @override
  String get rewardReferralFallback => 'Un amico';

  @override
  String get rewardReferralReceiverTitle => 'Un regalo inaspettato';

  @override
  String rewardReferralReceiverDesc(String inviter) {
    return '${inviter}ti ha invitato qui e ti ha lasciato un regalo di benvenuto.';
  }

  @override
  String get rewardInviterTitle => 'La tua chiamata è stata ascoltata!';

  @override
  String rewardInviterDescSingle(String name) {
    return '${name}si è unito all\'universo. Sei stato premiato per essere stato una guida.';
  }

  @override
  String rewardInviterDescMultiple(String name, int count) {
    return '${name}e${count}altri amici si sono uniti all\'universo. Sei stato premiato per essere stato una guida.';
  }

  @override
  String rewardInviterDescGeneric(int count) {
    return '${count}amici si sono uniti all\'universo. Sei stato premiato per essere stato una guida.';
  }

  @override
  String birthdayTitleWithName(String name) {
    return 'Buon compleanno,$name!';
  }

  @override
  String get birthdayTitle => 'Buon compleanno!';

  @override
  String get birthdayDesc =>
      'Oggi è il giorno sacro in cui la tua anima è venuta in questo mondo. L\'universo ti ha lasciato un regalo speciale.';

  @override
  String get cookieReminderTitle => 'Non hai spezzato un biscotto oggi';

  @override
  String get cookieReminderMessage =>
      'Il tuo messaggio di fortuna quotidiano ti sta aspettando!';

  @override
  String get cookieReminderReward => '3 A sinistra';

  @override
  String achievementRewardStones(int count) {
    return '+${count}Pietre dell\'anima';
  }

  @override
  String achievementRewardAura(int count) {
    return '+${count}Aura';
  }

  @override
  String get rankUpTitle => 'Promozione Cosmica!';

  @override
  String rankUpMessage(String rank) {
    return 'Il potere della tua aura è aumentato. Nuovo titolo:$rank';
  }

  @override
  String get rankNovice => 'Veggente novizio';

  @override
  String get rankApprentice => 'Apprendista Veggente';

  @override
  String get rankSeer => 'Veggente';

  @override
  String get rankWise => 'Il saggio veggente';

  @override
  String get rankMaster => 'Maestro Veggente';

  @override
  String get rankCosmic => 'Veggente Cosmico';

  @override
  String get loginSubtitle =>
      'Sincronizzati con la guida della tua anima.\nRicorda il tuo passato, futuro e subconscio.';

  @override
  String get loginAppleContinue => 'Continua con Apple';

  @override
  String get loginAppleSignIn => 'Accedi con Apple';

  @override
  String get loginGoogleContinue => 'Continua con Google';

  @override
  String get loginGoogleSignIn => 'Accedi con Google';

  @override
  String get loginGoogleFailed => 'Accesso a Google non riuscito';

  @override
  String get loginAppleFailed => 'Accesso Apple non riuscito';

  @override
  String get loginNoAccountYet => 'Non ti sei ancora unito all\'universo?';

  @override
  String get loginHaveAccount => 'Hai già un account?';

  @override
  String get loginSignUp => 'Iscrizione';

  @override
  String get loginSignIn => 'Registrazione';

  @override
  String get loginLegalPrefix => 'Continuando accetti i ns';

  @override
  String get loginTermsOfUse => 'Termini di utilizzo';

  @override
  String get loginLegalAnd => 'E';

  @override
  String get loginPrivacyPolicy => 'politica sulla riservatezza';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get homeSubtitle1 => 'Crack, Leggi, Sorridi.';

  @override
  String get homeSubtitle2 => 'Fortuna in tasca.';

  @override
  String get homeSubtitle3 => 'Il messaggio di oggi: Tu.';

  @override
  String get homeSubtitle4 => 'Una crepa, una sorpresa.';

  @override
  String get homeSubtitle5 => 'Un piccolo biscotto, una grande sensazione.';

  @override
  String get homeSubtitle6 => 'Non il destino, solo un dolce suggerimento.';

  @override
  String get homeSubtitle7 => 'Cosa dice la tua fortuna oggi?';

  @override
  String get homeSubtitle8 => 'Apri, scopri, vai avanti.';

  @override
  String get homeSubtitle9 => 'La fortuna è a un tocco di distanza.';

  @override
  String get homeSubtitle10 => 'Un nuovo inizio con ogni crepa.';

  @override
  String get homeSubtitle11 => 'Trova il tuo messaggio.';

  @override
  String get homeSubtitle12 => 'Non a caso... solo per te.';

  @override
  String get homeSubtitle13 => 'Sfida la tua fortuna, cogli l\'attimo.';

  @override
  String get homeSubtitle14 => 'Piccole profezie che fanno sorridere.';

  @override
  String get homeSubtitle15 => 'Le sorprese fanno bene.';

  @override
  String get homeMilestoneTitle => 'Messa a fuoco incredibile!';

  @override
  String homeMilestoneMessage(int count) {
    return 'La tua serie giornaliera ha raggiunto${count}giorni.';
  }

  @override
  String homeMilestoneSoulStone(int count) {
    return '+${count}Pietre dell\'anima';
  }

  @override
  String get homeGreetingMorning => 'Buongiorno';

  @override
  String get homeGreetingAfternoon => 'Buon pomeriggio';

  @override
  String get homeGreetingEvening => 'Buonasera';

  @override
  String get homeGreetingNight => 'Buona notte';

  @override
  String get homeTimeSubMorning => 'Nuovo messaggio con il tuo caffè.';

  @override
  String get homeTimeSubAfternoon => 'Una pausa magica nella tua giornata.';

  @override
  String get homeTimeSubEvening => 'Una dolce profezia per rilassarsi.';

  @override
  String get homeTimeSubNight => 'Le stelle brillano per te stasera.';

  @override
  String get paywallSubtitleElite =>
      'La tua consapevolezza cosmica è già aperta.\nRafforza la tua illuminazione aggiornando il tuo piano.';

  @override
  String get paywallSubtitleNew =>
      'Apri la porta alla consapevolezza cosmica.\nRimuovi tutti i limiti.';

  @override
  String get paywallFeature1 => '5 Pietre dell\'Anima Fresche al Giorno';

  @override
  String get paywallFeature2 => 'Modalità di analisi principale';

  @override
  String get paywallFeature3 => 'x3 Guadagno rapido dell\'aura';

  @override
  String get paywallFeature4 => 'Archivio clinico illimitato';

  @override
  String get paywallFeature5 => 'Esperienza fluida e senza pubblicità';

  @override
  String get paywallPackageWeekly => 'Risveglio settimanale';

  @override
  String get paywallPackageMonthly => 'Intuizione mensile';

  @override
  String get paywallPackageYearly => 'Illuminismo annuale';

  @override
  String get paywallBtnCurrentPlan => 'Piano attuale';

  @override
  String get paywallBtnManage => 'Gestisci dal negozio';

  @override
  String get paywallBtnUpgrade => 'Piano di aggiornamento';

  @override
  String get paywallBtnSubscribe => 'Sblocca Elite';

  @override
  String get paywallSuccessUpgradeTitle => 'Illuminismo aggiornato';

  @override
  String get paywallSuccessTitle => 'Benvenuti nell\'Illuminismo';

  @override
  String get paywallSuccessUpgradeSubtitle =>
      'Il tuo piano è stato aggiornato con successo.';

  @override
  String get paywallSuccessSubtitle =>
      'Ora sei un membro Elite. Per te i limiti cosmici sono stati rimossi.';

  @override
  String get paywallErrorTitle => 'Errore di connessione';

  @override
  String get paywallErrorMessage =>
      'Impossibile connettersi al negozio oppure la transazione è stata annullata. I prodotti potrebbero non essere ancora pubblicati su App Store/Play Console. Per favore riprova più tardi.';

  @override
  String get paywallRestoreSuccess => 'Elite restaurata';

  @override
  String get paywallRestoreSuccessSubtitle =>
      'Bentornati alla consapevolezza cosmica. I tuoi limiti sono stati rimossi.';

  @override
  String get paywallRestoreNoSub => 'Nessun abbonamento attivo';

  @override
  String get paywallRestoreNoSubMessage =>
      'Nessun abbonamento attivo a Crack Wish Elite trovato da ripristinare. Si prega di rivedere i pacchetti.';

  @override
  String get paywallRestore => 'Ripristina gli acquisti';

  @override
  String get paywallCurrentPlanBadge => 'PIANO ATTUALE';

  @override
  String get paywallLegalTr =>
      'Crack Wish Elite è un abbonamento con rinnovo automatico. Il pagamento verrà addebitato sul tuo conto alla conferma dell\'acquisto. L\'abbonamento si rinnova automaticamente a meno che non venga annullato almeno 24 ore prima della fine del periodo corrente. Puoi gestire e annullare i tuoi abbonamenti nelle impostazioni dell\'App Store.';

  @override
  String get paywallOk => 'OK';

  @override
  String get coffeeLoading1 => 'Immergersi nelle profondità della coppa...';

  @override
  String get coffeeLoading2 =>
      'I simboli sul terreno si allineano con l\'energia universale...';

  @override
  String get coffeeLoading3 => 'Le tue linee del destino vengono mappate...';

  @override
  String get coffeeLoading4 => 'I segreti vengono svelati...';

  @override
  String get coffeeAiError =>
      'L\'IA ha riscontrato un errore durante l\'interpretazione della lettura.';

  @override
  String get coffeeGenericError =>
      'Qualcosa è andato storto. Per favore riprova.';

  @override
  String get coffeeNotifReady =>
      'Riceverai una notifica quando la tua lettura sarà pronta';

  @override
  String get coffeeCheckHistory => 'pulsante per visualizzarlo';

  @override
  String get coffeeWaitOrExplore => 'Aspetta qui o esplora l\'app';

  @override
  String get coffeeGoHome => 'Vai a casa';

  @override
  String get coffeeSections => 'Sezioni della tazza';

  @override
  String get coffeeSectionInside => 'Dentro la Coppa';

  @override
  String get coffeeSectionInsideDesc =>
      'Il tuo mondo interiore, pensieri, stato emotivo.';

  @override
  String get coffeeSectionEdge => 'Bordo della tazza';

  @override
  String get coffeeSectionEdgeDesc =>
      'Futuro prossimo, notizie, messaggi, incontri.';

  @override
  String get coffeeSectionBottom => 'Fondo della tazza';

  @override
  String get coffeeSectionBottomDesc =>
      'Persistenti problemi del passato, fardelli, questioni irrisolte.';

  @override
  String get coffeeSectionSaucer => 'Piattino';

  @override
  String get coffeeSectionSaucerDesc =>
      'Desiderio, risultato, destino, energia finale.';

  @override
  String get coffeeLoadingComment => 'Caricamento interpretazione...';

  @override
  String get coffeeStoryTitle => 'La storia raccontata dai giardini';

  @override
  String get coffeeSymbolsTitle => 'Simboli visti nella tua lettura';

  @override
  String get coffeeLove => 'Amore e relazioni';

  @override
  String get coffeeCareer => 'Carriera e finanza';

  @override
  String get coffeeFamily => 'Famiglia e cerchia ristretta';

  @override
  String get coffeeNearFuture => 'Futuro prossimo';

  @override
  String get coffeeClosing => 'Parole finali della tua lettura';

  @override
  String get coffeeShare => 'Condividi la mia lettura';

  @override
  String get coffeeRetryValidation => 'Torna indietro e riprendi';

  @override
  String get coffeeRetry => 'Riprova';

  @override
  String get coffeeCancel => 'Cancellare';

  @override
  String get coffeeSymbolLabel => 'Simbolo';

  @override
  String get coffeeSymbolLoading => 'Caricamento...';

  @override
  String get coffeeTimelineSoon => 'Molto presto';

  @override
  String get coffeeImageError =>
      'Impossibile rilevare fondi di caffè chiari in questa immagine.';

  @override
  String get coffeeCosmicTitle => 'Lettura del caffè cosmico';

  @override
  String get coffeePremiumOnly => 'Solo funzionalità Premium';

  @override
  String get coffeePremiumDesc =>
      'Coffee Reading è esclusivo per i membri d\'élite. Passa a Premium e scopri i segreti del tuo futuro con le tue Pietre dell\'Anima.';

  @override
  String get coffeePremiumSimBtn => 'Passa a Premium (Simulazione)';

  @override
  String get coffeePhotoSource => 'Fonte foto';

  @override
  String get coffeeCamera => 'Telecamera';

  @override
  String get coffeeGallery => 'Galleria';

  @override
  String get coffeeStepCupInside => 'Dentro la Coppa';

  @override
  String get coffeeStepCupInsideDesc =>
      'Posiziona la fotocamera direttamente sopra la tazza e cattura i fondi di caffè all\'interno.';

  @override
  String get coffeeStepLeftProfile => 'Profilo sinistro';

  @override
  String get coffeeStepLeftProfileDesc =>
      'Tieni la tazza per il manico e scatta una foto nitida solo del lato sinistro.';

  @override
  String get coffeeStepRightProfile => 'Profilo giusto';

  @override
  String get coffeeStepRightProfileDesc =>
      'Ora cattura il lato posteriore destro della tazza da un\'angolazione ben illuminata.';

  @override
  String get coffeeStepSaucerSecret => 'Il segreto del piattino';

  @override
  String get coffeeStepSaucerDesc =>
      'Infine, cattura l\'ampia superficie del piattino con i fondi chiaramente visibili.';

  @override
  String get coffeeStepSaucerBtn => 'Scatta la foto del piattino';

  @override
  String get coffeeHeaderTitle => 'LETTURA DEL CAFFÈ';

  @override
  String get coffeeLastReading => 'La tua ultima lettura';

  @override
  String coffeeLastReadingTime(String time) {
    return 'Alle$time• Scade a mezzanotte';
  }

  @override
  String get coffeeNoReadingYet =>
      'Non hai ancora letto.\nPrepara una tazza di caffè,\ne lascia che il terreno ti sussurri.';

  @override
  String get coffeeSoulStones => 'Le tue pietre dell\'anima';

  @override
  String get coffeeSoulStoneEmpty => 'Nessuna pietra dell\'anima rimasta';

  @override
  String get coffeeSoulStoneRequired =>
      'Necessario per l\'analisi della lettura del caffè';

  @override
  String get coffeeSoulStoneCost => 'Ogni lettura costa 1 Pietra dell\'Anima';

  @override
  String get coffeeSoulStoneEliteActive =>
      'Vantaggio Elite: 5 Pietre dell\'Anima si rinnovano ogni notte';

  @override
  String get coffeeSoulStoneElitePromo =>
      'Diventa Elite per guadagnare 5 Pietre dell\'Anima ogni notte';

  @override
  String get coffeeEliteSubscribe => 'Iscriviti a Elite';

  @override
  String get coffeeRitualLabel => 'RITUALE';

  @override
  String get coffeeRitualTitle => 'I segreti della Coppa';

  @override
  String get coffeeRitualDesc =>
      'I motivi parlano solo a chi guarda da vicino. Segui il rito per una vera lettura.';

  @override
  String get coffeeRitualStep1Title => 'Imposta la tua intenzione';

  @override
  String get coffeeRitualStep1Desc =>
      'Mentre sorseggi, lascia che una domanda o un desiderio fluiscano nella tua mente.';

  @override
  String get coffeeRitualStep2Title => 'Sorseggia da un lato';

  @override
  String get coffeeRitualStep2Desc =>
      'Bevi sempre dallo stesso lato per preservare gli schemi.';

  @override
  String get coffeeRitualStep3Title => 'Capovolgilo';

  @override
  String get coffeeRitualStep3Desc =>
      'Capovolgi la tazza, lasciala raffreddare e aprila delicatamente.';

  @override
  String get coffeeRitualListenTitle => 'Ascolta il sussurro dei terreni';

  @override
  String coffeeStepLabel(String index, String title) {
    return 'Passaggio$index:$title';
  }

  @override
  String get coffeeDiscoverFate => 'Scopri il tuo destino';

  @override
  String get coffeeNextStep => 'Passaggio successivo';

  @override
  String get coffeeCapture => 'Cattura questo angolo';

  @override
  String get coffeeValidationError =>
      'I motivi nelle foto contrassegnate\nnon è stato possibile identificarlo chiaramente.';

  @override
  String get coffeeCosmicMismatch => 'Disadattamento cosmico';

  @override
  String get coffeeCosmicCheck => 'VERIFICA DEL LEGAME COSMICO';

  @override
  String get coffeeCosmicCheckDesc =>
      'Decodificare il linguaggio dei motivi,\nascoltando i sussurri del destino...';

  @override
  String get coffeeRevealSecrets => 'Solleva il velo dei segreti';

  @override
  String get coffeeReadingInProgress => 'Leggendo i motivi...';

  @override
  String get coffeeReadingWait =>
      'Le porte del futuro si stanno aprendo, resistete.';

  @override
  String get coffeeRelationTitle => 'Il tuo stato sentimentale';

  @override
  String get coffeeRelationSubtitle => 'Poni le basi del tuo legame cosmico.';

  @override
  String get coffeeFocusTitle => 'Cos\'hai in mente?';

  @override
  String get coffeeFocusSubtitle =>
      'Scegli un\'intenzione per approfondire la tua lettura.';

  @override
  String get coffeeMoodTitle => 'Il tuo umore?';

  @override
  String get coffeeMoodSubtitle => 'Senti l\'energia della tua tazza.';

  @override
  String get coffeeCosmicBondFormed => 'Si forma il legame cosmico';

  @override
  String get coffeeSecretsReady =>
      'I segreti della tua tazza sono pronti per essere sussurrati...';

  @override
  String get coffeeNewReading => 'Nuova lettura';

  @override
  String get coffeeAiPermission => 'Permesso di analisi del caffè AI';

  @override
  String get coffeeStoneCostInfo => 'Ogni analisi costa 1 Pietra dell\'Anima';

  @override
  String get coffeeEliteRefillActive =>
      'Vantaggio Elite: 5 Pietre dell\'Anima si rinnovano ogni notte';

  @override
  String get coffeeEliteRefillPromo =>
      'Diventa Elite per guadagnare 5 Pietre dell\'Anima ogni notte';

  @override
  String get coffeeEliteGetBtn => 'Ottieni Elite';

  @override
  String get coffeeResultOnHome => 'Visualizza il risultato nella home page';

  @override
  String get onboardingStart => 'Cominciamo';

  @override
  String get onboardingContinue => 'Continuare';

  @override
  String get onboardingContinueWithoutAccount => 'Hesap Açmadan Devam Et';

  @override
  String get onboardingFinish => 'Inizia il viaggio';

  @override
  String get onboardingNameHint => 'Un nome cosmico';

  @override
  String get onboardingNamePlaceholder => 'primo_ultimo';

  @override
  String get onboardingHandleHint => 'Una maniglia cosmica';

  @override
  String get onboardingHandlePlaceholder => 'galaxy_traveler';

  @override
  String get onboardingGenderTitle => 'Genere';

  @override
  String get onboardingGenderFemale => 'Femmina';

  @override
  String get onboardingGenderMale => 'Maschio';

  @override
  String get onboardingGenderOther => 'Preferisco non dirlo';

  @override
  String get onboardingStep1Title => 'Come dovremmo chiamarti?';

  @override
  String get onboardingStep1Sub =>
      'Con quale nome e vibrazione l\'universo dovrebbe conoscerti?';

  @override
  String get onboardingAvatarSelect => 'Seleziona il tuo avatar';

  @override
  String get onboardingStep2Title =>
      'Nel momento in cui la tua anima è entrata...';

  @override
  String get onboardingStep2Sub =>
      'Abbiamo bisogno dei tuoi dati di base per calcolare il tuo tema natale astrologico e i rituali personalizzati.';

  @override
  String get onboardingBirthDateLabel => 'Data di nascita';

  @override
  String get onboardingBirthTimeLabel => 'Ora di nascita';

  @override
  String get onboardingBirthLocationLabel => 'Città di nascita';

  @override
  String get onboardingTimeHint =>
      'Se conosci l\'ora esatta, entra per un\'analisi dettagliata';

  @override
  String get onboardingLocationHint =>
      'Perfeziona il calcolo selezionando una città';

  @override
  String get onboardingUnknownTime => 'Non conosco l\'ora esatta';

  @override
  String get onboardingPrivacyNote =>
      'Utilizzato esclusivamente per disegnare il tuo grafico personalizzato.';

  @override
  String get onboardingStep3Title => 'Qual è il tuo obiettivo?';

  @override
  String get onboardingStep3Sub =>
      'Quale energia desideri maggiormente far crescere o guarire nella tua vita in questo momento?';

  @override
  String get onboardingFocusLabel => 'Focus (scelta multipla)';

  @override
  String get onboardingFocusCareer => 'Carriera e denaro';

  @override
  String get onboardingFocusLove => 'Amore e relazioni';

  @override
  String get onboardingFocusPeace => 'Pace interiore';

  @override
  String get onboardingFocusLuck => 'Fortuna e opportunità';

  @override
  String get onboardingRelLabel => 'Stato della relazione attuale:';

  @override
  String get onboardingRelSingle => 'Cielo solitario';

  @override
  String get onboardingRelComplicated => 'C\'è Qualcuno...';

  @override
  String get onboardingRelTalking => 'Complicato';

  @override
  String get onboardingRelRelationship => 'Buon legame';

  @override
  String get onboardingStep4Title =>
      'La tua connessione con l\'universo di notte...';

  @override
  String get onboardingStep4Sub =>
      'Come riceve i messaggi il tuo subconscio? Colori e sogni ci daranno indizi.';

  @override
  String get onboardingDreamLabel => 'Quanto spesso ricordi i tuoi sogni?';

  @override
  String get onboardingDreamOften => 'Spesso e chiaramente';

  @override
  String get onboardingDreamSometimes => 'A volte';

  @override
  String get onboardingDreamRarely => 'Raramente';

  @override
  String get onboardingDreamNever => 'Mai';

  @override
  String get onboardingAuraLabel =>
      'L\'aura della tua anima (come ti senti oggi?)';

  @override
  String get onboardingStep5Title => 'La tua danza con il tempo...';

  @override
  String get onboardingStep5Sub =>
      'Quando la tua energia è al massimo? Adegueremo le tue notifiche di conseguenza.';

  @override
  String get onboardingSleepLabel => 'Il tuo modello di sonno';

  @override
  String get onboardingSleepMorning => 'Persona mattiniera';

  @override
  String get onboardingSleepNight => 'Nottambulo';

  @override
  String get onboardingSleepIrregular => 'Irregolare';

  @override
  String get onboardingSleepLittle => 'Dormo pochissimo';

  @override
  String get onboardingMatchLabel => 'Corrispondenza e connessione cosmica';

  @override
  String get onboardingMatchDesc =>
      'Voglio essere aperto alla connessione con profili sinergici e abbinamenti cosmici speciali.';

  @override
  String get onboardingFinalTitle => 'Tutto è pronto...';

  @override
  String get onboardingFinalSub =>
      'Stai per scoprire cosa hanno in serbo per te le stelle. Crea il tuo account ed entra nell\'universo cosmico.';

  @override
  String get onboardingAppleCreate => 'Crea un account con Apple';

  @override
  String get onboardingGoogleCreate => 'Crea un account con Google';

  @override
  String get onboardingErrorIncomplete =>
      'Benvenuto! Mancano solo pochi passaggi per completare il tuo profilo.';

  @override
  String get onboardingErrorFailed =>
      'Accesso non riuscito. Per favore riprova.';

  @override
  String onboardingErrorAlreadyExists(String provider) {
    return 'Hai già un profilo cosmico con questo account$provider! Utilizza l\'opzione \"Accedi\" nella prima pagina.';
  }

  @override
  String onboardingErrorDBRejected(String error) {
    return 'Registrazione rifiutata dal database:${error}Si prega di contattare l\'assistenza.';
  }

  @override
  String get onboardingErrorHandleTaken =>
      'Questo nome utente è già utilizzato';

  @override
  String get notifTitle => 'Notifiche';

  @override
  String get notifSubtitle => 'Scegli quali notifiche desideri ricevere';

  @override
  String get notifAnnouncements => 'Annunci';

  @override
  String get notifAnnouncementsDesc => 'Nuove funzionalità e aggiornamenti';

  @override
  String get notifSounds => 'Suoni';

  @override
  String get notifSoundsDesc => 'Avvisi di notifica sonora';

  @override
  String get notifCookieAlarm => 'Nuovo allarme cookie';

  @override
  String get notifCookieAlarmDesc =>
      'Quando arriva un nuovo biscotto della fortuna';

  @override
  String get notifFriendAlarm => 'Allarme amico';

  @override
  String get notifFriendAlarmDesc => 'Nuovi collegamenti dalla rete Owl';

  @override
  String get notifDailyReminder => 'Promemoria giornalieri';

  @override
  String get notifDailyReminderDesc =>
      'Non dimenticare il tuo biscotto quotidiano';

  @override
  String get accountTitle => 'Dettagli dell\'account';

  @override
  String get accountSubtitle =>
      'Informazioni personali e gestione dell\'account';

  @override
  String get accountUsername => 'Nome utente';

  @override
  String get accountLinkedEmail => 'E-mail collegata';

  @override
  String get accountSignInMethod => 'Metodo di accesso';

  @override
  String get accountDeleteTitle => 'Elimina account';

  @override
  String get accountDeleteDesc =>
      'Tutti i tuoi dati verranno eliminati definitivamente.\nQuesta azione non può essere annullata.';

  @override
  String get accountDeleteCancel => 'Cancellare';

  @override
  String get accountDeleteConfirm => 'Eliminare';

  @override
  String get accountDeletePermanent => 'Elimina account in modo permanente';

  @override
  String get welcomeTagline => 'La magia è dentro di te.';

  @override
  String get welcomeAppleContinue => 'Continua con Apple';

  @override
  String get welcomeGoogleContinue => 'Continua con Google';

  @override
  String get moodGuideTitle => 'Guida all\'umore';

  @override
  String get moodAwarenessTitle => 'Consapevolezza emotiva';

  @override
  String get moodAwarenessDesc =>
      'Scegliere il tuo umore rende concreti i tuoi sentimenti; questo è il primo passo per ritrovare l’equilibrio interiore e la consapevolezza di sé.';

  @override
  String get moodCosmicTitle => 'Frequenza cosmica';

  @override
  String get moodCosmicDesc =>
      'Ogni emozione che scegli sulla ruota porta con sé una frequenza. L\'aura dello schermo si allinea direttamente con i tuoi sentimenti.';

  @override
  String get moodHowToTitle => 'Come usare?';

  @override
  String get moodHowToDesc =>
      'Basta girare la ruota e scegliere l\'espressione che meglio riflette il tuo umore. Non giudicare i tuoi sentimenti, sentili e accettali.';

  @override
  String get moodQuestionAlt => 'Com\'è il tuo umore oggi?';

  @override
  String get moodSpinHint => 'Gira la ruota, scegli il tuo umore ✨';

  @override
  String get bentoCoffeeTitle => 'Lettura del caffè';

  @override
  String get bentoCoffeeDesc => 'Sussurri di motivi';

  @override
  String get bentoUnexplored => 'Questo regno aspetta di essere esplorato...';

  @override
  String get bentoSealed => 'Sigillato';

  @override
  String get horoscopeDailyEnergy => 'L\'energia di oggi';

  @override
  String get horoscopeWestern => 'Ast occidentale.';

  @override
  String get horoscopeAsian => 'Saggezza asiatica';

  @override
  String get horoscopeMayan => 'Spirito Maya';

  @override
  String get shareSaved => 'Salvato ✓';

  @override
  String get shareDownload => 'Scaricamento';

  @override
  String get shareShare => 'Condividere';

  @override
  String get shareStory => 'Storia';

  @override
  String get sharePost => 'Inviare';

  @override
  String get shareCookieText =>
      'Questo è quello che ho ricevuto oggi dal biscotto della fortuna! 🥠✨\n#CrackWish';

  @override
  String get shareCoffeeTitle => 'Lettura del caffè';

  @override
  String get cookieLockedTitle => 'Questo cookie speciale è bloccato';

  @override
  String get cookieComingSoon => 'Prossimamente ✨';

  @override
  String get dreamWaitOrReturn =>
      'Puoi attendere qui o tornare alla home page. Ti avviseremo quando sarà pronto e potrai leggerlo dalla sezione \"I miei sogni\".';

  @override
  String get dreamReturnHome => 'Ritorna alla pagina iniziale';

  @override
  String get profileEditProfile => 'Modifica profilo';

  @override
  String get profileEditSubtitle =>
      'Modifica nome, zodiaco e informazioni personali';

  @override
  String get profileSearchHint => 'Cerca zodiaco, città o data di nascita...';

  @override
  String get profileStoreUnavailable =>
      'Il collegamento al negozio non è disponibile.';

  @override
  String get profileMailNotFound =>
      'Nessuna app di posta trovata. Puoi scrivere a support@crackandwish.com';

  @override
  String get profileRitualCode => 'Codice rituale';

  @override
  String get profileRitualDesc =>
      'Questo codice è la tua identità rituale personale. Condividilo con gli amici per invitarli su Owl Network.';

  @override
  String get profileRitualCopied => 'Codice Rituale Copiato ✨';

  @override
  String get profileRitualInfo => 'Condividi con gli amici, esplora insieme!';

  @override
  String get profileShareCode => 'Condividi codice';

  @override
  String get profileDeleteAccount => 'Elimina account';

  @override
  String get profileDeleteDesc =>
      'Tutti i tuoi dati verranno eliminati definitivamente.\nQuesta azione non può essere annullata.';

  @override
  String get profileDeleteCancel => 'Cancellare';

  @override
  String get profileDeleteConfirm => 'Elimina account';

  @override
  String get profileSignOut => 'Disconnessione';

  @override
  String get profileSignOutDesc =>
      'Esci dal tuo account in tutta sicurezza.\nI tuoi dati saranno conservati.';

  @override
  String get profileSignOutCancel => 'Cancellare';

  @override
  String get profileSignOutConfirm => 'Disconnessione';

  @override
  String get profilePrivacyPolicy => 'politica sulla riservatezza';

  @override
  String get profileTermsOfUse => 'Termini di utilizzo';

  @override
  String get profileGetElite => 'Ottieni Elite';

  @override
  String get profileGetEliteSubtitle => 'Porta verso la consapevolezza';

  @override
  String get profileCosmicProfile => 'Profilo cosmico';

  @override
  String get profileCosmicSubtitle => 'Grafico, ora e posizione';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileNotificationSettings => 'Impostazioni di notifica';

  @override
  String get profileRestorePurchases => 'Ripristina gli acquisti';

  @override
  String get profileRestoreSuccess => 'Acquisti ripristinati con successo!';

  @override
  String get profileRestoreFail => 'Nessun acquisto trovato da ripristinare.';

  @override
  String get profileHelp => 'Aiuto';

  @override
  String get profileShare => 'Condividere';

  @override
  String get profileRate => 'Valutare';

  @override
  String get profileVersion => 'Versione';

  @override
  String get profileCosmicName => 'Nome cosmico';

  @override
  String get profileSealProfile => 'Profilo di tenuta';

  @override
  String get profileChooseAvatar => 'Scegli il tuo avatar magico.';

  @override
  String get profileStrengthenBonds => 'Rafforzare i legami';

  @override
  String get profileStrengthenBondsDesc =>
      'Espandi l\'universo cosmico con gli amici.';

  @override
  String get profileEarnSoulStones => 'Guadagna +2 Pietre dell\'Anima';

  @override
  String get profileCodeCopied => 'Codice copiato!';

  @override
  String get profileNotifications => 'Notifiche';

  @override
  String get profileSupportExperience => 'Supporto ed esperienza';

  @override
  String get profileSeerNovice => 'Veggente novizio';

  @override
  String get profileSeerApprentice => 'Apprendista Veggente';

  @override
  String get profileSeer => 'Veggente';

  @override
  String get profileSeerWise => 'Il saggio veggente';

  @override
  String get profileSeerMaster => 'Maestro Veggente';

  @override
  String get profileSeerCosmic => 'Veggente Cosmico';

  @override
  String get profileUploadFailed =>
      'Caricamento foto fallito! Per favore controlla la tua connessione.';

  @override
  String get profileCropTitle => 'Raccolto cosmico';

  @override
  String get profileCropCancel => 'Cancellare';

  @override
  String get profileCropDone => 'Fatto';

  @override
  String get moderationAdultContent =>
      'L\'energia di questa immagine non è compatibile con il nostro universo cosmico (contenuto inappropriato).';

  @override
  String get moderationViolence =>
      'Scegli un avatar più tranquillo che rifletta la tua aura e non affatichi la mente (Contenuti disturbanti).';

  @override
  String get moderationTooLarge =>
      'L’immagine è abbastanza grande da mettere a dura prova la rete cosmica. Seleziona una foto di dimensioni inferiori a 5 MB.';

  @override
  String get moderationInvalidFormat =>
      'La tua foto non può essere letta dalla nostra pergamena magica, il formato è danneggiato.';

  @override
  String get moderationUnknown =>
      'Si è verificata una fluttuazione cosmica sconosciuta.';

  @override
  String profileShareInvite(String code) {
    return 'Unisciti all\'universo di Crack&Wish! ✨\nIl mio codice rituale:${code}Inserisci questo codice per guadagnare +1 Pietra dell\'anima, +50 Aura e un biscotto premium a sorpresa!\nhttps://crackandwish.com';
  }

  @override
  String get profileShareApp =>
      'Scopri la tua fortuna con Crack&Wish! •✨\nRompi i biscotti, leggi i tarocchi, interpreta i sogni.\n\nhttps://crackandwish.com';

  @override
  String get profileEliteYouAre => 'Tu sei Elite';

  @override
  String get profileGoElite => 'Vai Elite';

  @override
  String get profileEliteMystical => 'Visualizza le porte mistiche';

  @override
  String get profileEliteDoor => 'Porta alla consapevolezza';

  @override
  String get profileMyCosmicProfile => 'Il mio profilo cosmico';

  @override
  String get profileCosmicDetails => 'Dettagli su mappa, ora e luogo';

  @override
  String get profileRestorePurchasesBtn => 'Ripristina gli acquisti';

  @override
  String get profileRestoreSubtitle => 'Ripristina i tuoi acquisti precedenti';

  @override
  String get profileInviteFriends => 'Invita amici';

  @override
  String get profileInviteFriendsDesc =>
      'Costruisci legami cosmici, guadagna insieme';

  @override
  String get cosmicChart => 'Carta cosmica';

  @override
  String get cosmicWestern => 'OCCIDENTALE';

  @override
  String get cosmicAsian => 'ASIATICO';

  @override
  String get cosmicMayan => 'MAYA';

  @override
  String get cosmicRising => 'IN AUMENTO';

  @override
  String get cosmicArrivalDate => 'DATA DI ARRIVO';

  @override
  String get cosmicBirthTime => 'TEMPO DI NASCITA';

  @override
  String get cosmicTimeUnknown => 'Ora sconosciuta';

  @override
  String get cosmicBirthPlace => 'COORDINATE DEL LUOGO DI NASCITA';

  @override
  String get cosmicCountry => 'Paese';

  @override
  String get cosmicSelectCountry => 'Seleziona Paese';

  @override
  String get cosmicCityDistrict => 'Città, distretto e villaggio';

  @override
  String get cosmicSelectDateFirst => 'Seleziona prima la tua data di nascita.';

  @override
  String cosmicLockedDays(int days) {
    return 'Bloccato per${days}giorni';
  }

  @override
  String get cosmicSave => 'Salva';

  @override
  String get cosmicSearchLocation => 'Cerca la posizione esatta';

  @override
  String get cosmicSearchHint => 'Inserisci villaggio, distretto, ecc...';

  @override
  String get cosmicAddFreeText => 'Aggiungi come testo libero';

  @override
  String get cosmicRequiresTime => 'Richiede tempo';

  @override
  String get badgeReady => 'PRONTO';

  @override
  String get badgeNew => 'NUOVO';

  @override
  String get paywallLegal =>
      'Crack Wish Elite è un abbonamento con rinnovo automatico. Il pagamento verrà addebitato sul tuo conto alla conferma dell\'acquisto. L\'abbonamento si rinnova automaticamente a meno che non venga annullato almeno 24 ore prima della fine del periodo corrente. Puoi gestire e annullare i tuoi abbonamenti nelle impostazioni dell\'App Store.';

  @override
  String get cosmicSelect => 'Selezionare';

  @override
  String get coffeeRelSingle => 'Anima Unica';

  @override
  String get coffeeRelInLove => 'Il cuore è pieno';

  @override
  String get coffeeRelEngaged => 'Impegnato';

  @override
  String get coffeeRelMarried => 'Sposato';

  @override
  String get coffeeRelComplicated => 'Complicato';

  @override
  String get coffeeFocusLove => 'Amore e armonia';

  @override
  String get coffeeFocusCareer => 'Carriera e finanze';

  @override
  String get coffeeFocusHealing => 'Guarigione e pace';

  @override
  String get coffeeFocusGeneral => 'Futuro generale';

  @override
  String get coffeeFocusSurprise => 'Sorprendimi';

  @override
  String get coffeeMoodPeaceful => 'Tranquillo';

  @override
  String get coffeeMoodExcited => 'Eccitato';

  @override
  String get coffeeMoodAnxious => 'Ansioso';

  @override
  String get coffeeMoodIndecisive => 'Indeciso';

  @override
  String get coffeeMoodEnergetic => 'Energico';

  @override
  String get coffeeMoodMelancholic => 'Malinconico';

  @override
  String get coffeeAllPhotosRequired => 'Per favore, scatta tutte le foto!';

  @override
  String get coffeeNotEnoughStones =>
      'Non ci sono abbastanza Pietre dell\'Anima!';

  @override
  String coffeeSoulStoneCount(int count) {
    return '${count}Pietre dell\'anima disponibili';
  }

  @override
  String get coffeeUseSoulStone => 'Usa 1 Pietra dell\'Anima';

  @override
  String get languageSettingsSubtitle => 'Scegli la lingua dell\'app';

  @override
  String get cosmicSearchHintShort => 'Ricerca...';

  @override
  String get cosmicAddThis => 'Aggiungi questo';

  @override
  String get horoscopeWesternText =>
      'Le stelle si allineano per la tua carriera. Fai passi rapidi e decisivi.';

  @override
  String get horoscopeAsianText =>
      'L\'elemento Acqua è attivo. La tua intuizione è forte, ascolta semplicemente il tuo cuore.';

  @override
  String get horoscopeMayanText =>
      'Il tono 4 è attivo. Una giornata perfetta per stabilire ordine e pianificare la tua vita.';

  @override
  String get horoscopeExplore => 'Esplorare';

  @override
  String get cookieDayCompleted => 'Giorno completato';

  @override
  String get cookieSeeYouTomorrow => 'A domani con nuovi biscotti.';

  @override
  String get cookieRarityLegendary => 'Leggendario';

  @override
  String get cookieRarityRare => 'Raro';

  @override
  String get cookiePremiumCollection => 'Collezione Premium';

  @override
  String cookiePurchaseBtn(String price) {
    return 'Acquisto ($price)';
  }

  @override
  String get cookieTapOutsideToClose => 'Tocca all\'esterno per chiudere';

  @override
  String get cookieAddedToCollection =>
      'Cookie aggiunto con successo alla tua raccolta!';

  @override
  String get cookiePremiumFallback => 'Biscotto Premium';

  @override
  String get dreamSoulStoneRequired => 'Pietra dell\'anima richiesta';

  @override
  String get dreamSoulStoneRequiredDesc =>
      'Le Pietre dell\'Anima sono necessarie per un\'analisi profonda.\n\nPuoi guadagnare Pietre dell\'Anima convertendo i punti Aura o con l\'abbonamento Elite.';

  @override
  String get dreamGetElite => 'Ottieni Elite';

  @override
  String get dreamClinicalGateTitle => 'Porta di analisi clinica';

  @override
  String dreamClinicalGateDesc(int soulStones) {
    return 'Pietre dell\'Anima attuali:${soulStones}Questa psicoanalisi profonda a livello clinico costa 1 Pietra dell\'Anima.';
  }

  @override
  String get dreamUseOneStone => 'Usa 1 pietra';

  @override
  String get dreamDeepAnalysisBgPreparing =>
      'L\'analisi approfondita viene preparata in background. Riceverai una notifica quando sarà pronto.';

  @override
  String get dreamYourSoulStones => 'Le tue pietre dell\'anima';

  @override
  String dreamSoulStonesRemaining(int count) {
    return '${count}Pietre dell\'anima rimanenti';
  }

  @override
  String get dreamSoulStonesEmpty => 'Senza Pietre dell\'Anima';

  @override
  String get dreamRequiredForDeep => 'Necessario per l\'analisi approfondita';

  @override
  String get dreamEachAnalysisCost => 'Ogni analisi costa 1 Pietra dell\'Anima';

  @override
  String get dreamEliteRefillActive =>
      'Elite ricarica 5 Pietre dell\'Anima ogni notte';

  @override
  String get dreamEliteRefillPromo =>
      'Ottieni 5 Pietre dell\'Anima giornaliere con Elite';

  @override
  String get dreamWatchAd => 'Guarda l\'annuncio';

  @override
  String get dreamBgAnalyzing =>
      'Il tuo sogno viene analizzato in background. Riceverai una notifica quando sarà pronto.';

  @override
  String get dreamDeepAnalysis => 'Analisi approfondita';

  @override
  String get dreamDiscoverSecrets => 'Scopri i segreti';

  @override
  String get dreamDidYouKnow => 'Lo sapevate?';

  @override
  String get dreamNeuroPsychAnalysis => 'ANALISI NEURO-PSICO';

  @override
  String get dreamYourDream => 'IL TUO SOGNO';

  @override
  String get dreamEmotionalProfile => 'Profilo emotivo';

  @override
  String get dreamEmotionalProfileSub => 'Strati psicologici durante il sogno';

  @override
  String get dreamShadowSelf => 'Sé Ombra';

  @override
  String get dreamShadowSelfSub =>
      'Aspetti repressi e non esaminati del subconscio';

  @override
  String get dreamRecurringPatterns => 'Modelli ricorrenti';

  @override
  String get dreamRecurringPatternsSub =>
      'Loop ricorrenti e blocchi psicologici';

  @override
  String dreamSuggestedRitual(String title) {
    return 'Rituale suggerito:$title';
  }

  @override
  String get dreamSuggestedRitualSub =>
      'Un\'azione specializzata per gestire l\'impatto di questo sogno';

  @override
  String get dreamScienceNote => 'Nota scientifica:';

  @override
  String get dreamWriteNewDream => 'Scrivi un nuovo sogno';

  @override
  String get dreamNoMonthDreams => 'Nessun sogno scritto ancora questo mese ✨';

  @override
  String get dreamMysteriousDream => 'Sogno misterioso';

  @override
  String get dreamStandardAnalysis => 'ANALISI STANDARD';

  @override
  String get dreamGeneralAnalysis => 'Analisi generale';

  @override
  String get dreamPsychological => 'Psicologico';

  @override
  String get dreamSpiritual2 => 'Spirituale';

  @override
  String get dreamAdvice => 'Consiglio';

  @override
  String get dreamDeepenedInsights => 'Approfondimenti';

  @override
  String get dreamEliteCreditsTitle => 'Crediti d\'élite';

  @override
  String get dreamReadingCreditsTitle => 'I tuoi crediti di lettura';

  @override
  String dreamCreditsRemaining(int count) {
    return '${count}crediti rimanenti';
  }

  @override
  String get dreamDailyLimitReached => 'Limite giornaliero raggiunto';

  @override
  String get dreamZeroCredits => '0 crediti rimanenti';

  @override
  String dreamDailyPremiumReads(int count) {
    return '${count}Interpretazioni quotidiane dei sogni';
  }

  @override
  String get dreamNoAdsRequired => 'Non c\'è bisogno di guardare gli annunci';

  @override
  String get dreamCreditsResetNightly =>
      'I crediti vengono ripristinati ogni notte';

  @override
  String get dreamOneFreeDaily => '1 interpretazione gratuita ogni giorno';

  @override
  String dreamWatchAdsForCredits(int maxAds, int watched) {
    return 'Guarda gli annunci per${maxAds}crediti extra ($watched/$maxAds)';
  }

  @override
  String get dreamUnconsciousFrequencies => 'FREQUENZE INCONSCE';

  @override
  String get dreamOrbEmotion => 'EMOZIONE';

  @override
  String get dreamOrbEntropy => 'ENTROPIA';

  @override
  String get dreamOrbActivity => 'ATTIVITÀ';

  @override
  String get dreamOrbResidue => 'RESIDUI';

  @override
  String get dreamHighConfidence => 'Alta fiducia';

  @override
  String get dreamModerateConfidence => 'Fiducia moderata';

  @override
  String get dreamLowConfidence => 'Bassa fiducia';

  @override
  String get dreamCoreThematicPattern => 'MODELLO TEMATICO CENTRALE';

  @override
  String get dreamMetricEmotionalLoad => 'Emotivo\nCaricare';

  @override
  String get dreamMetricEmotionalLoadDesc =>
      'Con quanta intensità è stato attivato il centro emotivo del tuo cervello durante questo sogno.';

  @override
  String get dreamMetricUncertaintyDesc =>
      'Quanto illogico o incoerente fosse il racconto dei tuoi sogni.';

  @override
  String get dreamMetricRecentMemory => 'Recente\nConnessione';

  @override
  String get dreamMetricRecentMemoryDesc =>
      'Quanto dei tuoi sogni è stato influenzato da recenti eventi della vita reale.';

  @override
  String get dreamMetricAgency => 'Agenzia /\nControllo';

  @override
  String get dreamMetricAgencyDesc =>
      'Quanto controllo avevi sugli eventi nel tuo sogno.';

  @override
  String get dreamSeverityHigh => 'Alto';

  @override
  String get dreamSeverityNormal => 'Normale';

  @override
  String get dreamSeverityLow => 'Basso';

  @override
  String get dreamCognitiveDistribution => 'DISTRIBUZIONE COGNITIVA';

  @override
  String get dreamTapToExpand => 'TOCCA PER ESPANDERE';

  @override
  String get dreamNeurologicalBasis => 'Base neurologica';

  @override
  String get dreamEvidenceBase => 'BASE DI PROVA';

  @override
  String get dreamRootCause => 'Causa ultima';

  @override
  String get dreamAbsolutely => 'Assolutamente';

  @override
  String get dreamMaybe => 'Forse';

  @override
  String get dreamNotSure => 'Non è sicuro';

  @override
  String get dreamDreamEssence => 'ESSENZA DEL SOGNO';

  @override
  String get dreamClarifyingResponses => 'RISPOSTE CHIARIMENTI';

  @override
  String get dreamCosmicRhythmSynced => 'Ritmo cosmico sincronizzato';

  @override
  String get dreamCosmicRhythmSyncedDesc =>
      'Riceverai suggerimenti sui sogni personalizzati in base al tuo ciclo del sonno.';

  @override
  String get dreamSyncSleepData => 'Sincronizza i dati del sonno';

  @override
  String get dreamSyncSleepDataDesc =>
      'Permettigli di rilevare quando ti svegli per chiederti del tuo sogno più profondo.';

  @override
  String get dreamAwarenessFallback =>
      'Questa consapevolezza è l’inizio di un nuovo percorso. È tempo di affrontarlo.';

  @override
  String get dreamExtractingEssence => 'Estrarre l\'essenza del sogno...';

  @override
  String get dreamNoReasoning => 'Nessun ragionamento generato.';

  @override
  String get dreamNotAnalyzable =>
      'Sei sicuro che fosse un sogno?\nPer favore descrivi una scena reale che hai vissuto mentre dormivi.';

  @override
  String get owlTabFriends => 'I miei amici';

  @override
  String get owlTabConnections => 'Connessioni';

  @override
  String get owlTabInbox => 'Posta in arrivo';

  @override
  String get owlSearchCosmic => 'Cerca nell\'universo cosmico...';

  @override
  String get owlSearchFriends => 'Cerca amici...';

  @override
  String get owlPhoneContacts => 'Contatti telefonici';

  @override
  String get owlNoOneFoundCosmic => 'Nessuno trovato nell\'universo cosmico.';

  @override
  String get owlFoundInCosmic => 'Trovato nell\'universo cosmico';

  @override
  String get owlUnknownProfile => 'Profilo sconosciuto';

  @override
  String owlFriendRequestSent(String name) {
    return 'Richiesta di amicizia inviata a$name!';
  }

  @override
  String get owlRequestSentStatus => 'Inviato';

  @override
  String get owlSendRequestAction => 'Invia richiesta';

  @override
  String get owlConnectContacts => 'Connetti i contatti';

  @override
  String get owlConnectContactsDesc =>
      'Trova subito i tuoi amici.\nI tuoi contatti non vengono MAI archiviati sui server.';

  @override
  String get owlNoContactsFound =>
      'Non siamo riusciti a trovare nessuno\nnell\'universo di Crack&Wish';

  @override
  String get owlNoContactsFoundDesc =>
      'Puoi avviare l\'energia cosmica invitandoli!';

  @override
  String get owlUnknown => 'Sconosciuto';

  @override
  String get owlAppUserLabel => 'Utente Crack&Wish';

  @override
  String get owlInContactsLabel => 'Nei tuoi contatti';

  @override
  String get owlNoFriendsYet => 'Nessun amico ancora';

  @override
  String get owlNoResultsFound => 'Nessun risultato trovato';

  @override
  String get owlFriendRequests => 'Richieste di amicizia';

  @override
  String get owlFriendsHeader => 'I tuoi amici';

  @override
  String get owlAcceptAction => 'Accettare';

  @override
  String get owlRejectAction => 'Rifiutare';

  @override
  String get owlInviteReward => '+2 Pietre dell\'Anima';

  @override
  String owlInviteShareMessage(String username) {
    return 'Illuminiamo insieme l\'oscurità! ✨\nUnisciti a Crack Wish tramite il mio link di invito qui sotto, connettiti automaticamente e vinci i premi Start!\n\nIl mio link di invito:\nhttps://crackwish.com/invite/$username';
  }

  @override
  String get owlInviteFriends => 'Invita amici';

  @override
  String get owlInviteFriendsDesc => 'Riflettono l\'universo cosmico';

  @override
  String get owlNoLettersYet => 'Nessuna lettera ancora';

  @override
  String owlLetterSentNotification(String name) {
    return '${name}ha inviato una lettera...';
  }

  @override
  String get owlOnItsWay => 'Il gufo sta arrivando 🕊️';

  @override
  String owlLetterCount(int count) {
    return '${count}lettere';
  }

  @override
  String owlUnreadCountBadge(int count) {
    return '${count}Nuovo';
  }

  @override
  String get owlIUnderstand => 'Capisco';

  @override
  String get owlInviteHowTitle => 'Come vorresti invitare?';

  @override
  String get owlInviteHowSubtitle =>
      'Come vuoi inviare la tua chiave cosmica a questa persona?';

  @override
  String get owlInviteSendAsMessage => 'Invia come messaggio';

  @override
  String get owlInviteSMSSubtitle => 'Invia tramite messaggio classico';

  @override
  String get owlInviteOtherApps => 'Altre app';

  @override
  String get owlInviteOtherAppsSubtitle => 'Instagram, TikTok, X, ecc.';

  @override
  String get owlWhatsAppNotFound => 'WhatsApp non trovato';

  @override
  String get owlSMSNotFound => 'Applicazione SMS non trovata';

  @override
  String get owlDisconnectAction => 'Disconnetti';

  @override
  String owlDisconnectConfirm(String name) {
    return 'Sei sicuro di voler rompere il legame magico con$name?';
  }

  @override
  String get owlDisconnectConfirmButton => 'Sì, disconnettiti';

  @override
  String get owlCancel => 'Cancellare';

  @override
  String get owlSendMagic => 'Invia (Incantato)';

  @override
  String get owlSend => 'Inviare';

  @override
  String get owlCookieAdded => 'Biscotto aggiunto';

  @override
  String get owlAddCookie => 'Aggiungi biscotto';

  @override
  String get owlNoCookiesInCollection => 'Nessun cookie nella tua raccolta';

  @override
  String get owlWriteLetterHint => 'Scrivi la tua lettera...';

  @override
  String get owlSendCookie => 'Invia biscotto';

  @override
  String get zodiacMeasureHarmony => 'MISURA L\'ARMONIA COSMICA';

  @override
  String get zodiacDiscoverEnergy =>
      'Scopri la tua doppia energia guidata dalle stelle';

  @override
  String get zodiacChooseFriend => 'SCEGLI AMICO';

  @override
  String get zodiacChooseFriendSubtitle =>
      'Seleziona un amico per confrontare le tue energie cosmiche';

  @override
  String get zodiacDiscoverYourself => 'Scopri te stesso';

  @override
  String get zodiacCharacteristicAnalysis => 'ANALISI CARATTERISTICA';

  @override
  String zodiacAbilityMap(String name) {
    return 'Mappa delle abilità di$name';
  }

  @override
  String get zodiacPros => 'Vantaggi';

  @override
  String get zodiacCons => 'Sfide';

  @override
  String get zodiacAdvice => 'Consiglio';

  @override
  String get zodiacDailyWhisperSubtitle =>
      'Senti il sussurro di oggi e\nsvelare i segreti del tuo ritratto spirituale.';

  @override
  String get zodiacDailyWhisperHeadline =>
      'Il messaggio di oggi e il ritratto spirituale';

  @override
  String get zodiacOpenGuide => 'Apri la Guida';

  @override
  String get zodiacNoFriends => 'Nessun amico ancora';

  @override
  String get zodiacSelect => 'SELEZIONARE';

  @override
  String get zodiacQuestCompleted => 'Missione completata';

  @override
  String get zodiacQuestCompletedSubtitle =>
      'Sei completamente allineato con il ritmo dell’universo.';

  @override
  String get zodiacRewardAura => 'Premio guadagnato:\n+4 AURA';

  @override
  String get zodiacStartNewQuest => 'INIZIA UNA NUOVA MISSIONE';

  @override
  String zodiacDailyQuestTitle(int days) {
    return '$days-RICERCA GIORNALIERA';
  }

  @override
  String zodiacDailyQuestDesc(String weakness) {
    return 'Spezza la tua debolezza: \"$weakness\"';
  }

  @override
  String zodiacQuestDayProgress(int current, int total) {
    return 'GIORNO$current/$total';
  }

  @override
  String get zodiacQuestTodayDiscovery => 'LA SCOPERTA DI OGGI';

  @override
  String get zodiacQuestCompletedToday => 'COMPLETATO OGGI';

  @override
  String get zodiacQuestCompleteNow => 'COMPLETA LA MISSIONE ORA';

  @override
  String get zodiacQuestMarkCompleted => 'HO COMPLETATO OGGI';

  @override
  String get zodiacLoveHarmony => 'AMORE ARMONIA';

  @override
  String get zodiacFriendshipHarmony => 'AMICIZIA';

  @override
  String get zodiacCommunicationHarmony => 'COMUNICAZIONE E MENTE';

  @override
  String get zodiacWorkHarmony => 'COLLABORAZIONE';

  @override
  String get zodiacAdventureHarmony => 'AVVENTURA E DIVERTIMENTO';

  @override
  String get zodiacViralDynamics => 'DINAMICA VIRALE';

  @override
  String get zodiacDeepSynastryMap => 'MAPPA DELLA SINASTRA PROFONDA';

  @override
  String zodiacSynastrySubtitle1(String name) {
    return 'L\'armonia tra te e${name}non si limita ai segni solari.';
  }

  @override
  String get zodiacSynastrySubtitle2 =>
      'Basato sulla privacy, l\'algoritmo cosmico fa riferimenti incrociati ai temi astrologici di nascita, alla Luna e alle fasi ascendenti dietro le quinte, rendendo questa analisi completamente unica per te.';

  @override
  String get zodiacDailyWhisperTitle => 'Il sussurro di oggi';

  @override
  String get zodiacChooseSign => 'SCEGLI IL SEGNO';

  @override
  String get zodiacCosmicGuide => 'LA TUA GUIDA COSMICA';

  @override
  String get zodiacNew => 'NUOVO';

  @override
  String get zodiacCosmicHarmonyTitle => 'ARMONIA COSMICA';

  @override
  String get zodiacAwesome => 'ECCEZIONALE';

  @override
  String get zodiacSpiritPortrait => 'Ritratto spirituale';

  @override
  String get onboardingFeatureStepTitle => 'Cosa ti aspetta?';

  @override
  String get onboardingFeatureStepSub =>
      'Sei pronto ad ascoltare i sussurri dell\'universo e scoprire il tuo destino?';

  @override
  String get onboardingNameStepTitle => 'Conosciamoci meglio';

  @override
  String get onboardingNameStepSub =>
      'Crea il tuo profilo e determina la tua identità cosmica in modo che le tue anime gemelle possano trovarti.';

  @override
  String get onboardingDateStepTitle => 'Coordinata cosmica';

  @override
  String get onboardingDateStepSub =>
      'Scegli il momento in cui sei nato come base della tua carta astrologica.';

  @override
  String get onboardingFocusStepTitle => 'Bussola del cuore';

  @override
  String get onboardingFocusStepSub =>
      'Imposta la tua intenzione, mappiamo il tuo percorso.';

  @override
  String get onboardingDreamStepTitle => 'Voce del subconscio';

  @override
  String get onboardingDreamStepSub => 'Come ti raggiungono i tuoi sogni?';

  @override
  String get onboardingSleepStepTitle => 'La tua bussola interiore';

  @override
  String get onboardingSleepStepSub =>
      'Come trovi la strada durante i punti di svolta decisi dal destino nella tua vita?';

  @override
  String get onboardingFeatureAstrology => 'Grafico astrologico personalizzato';

  @override
  String get onboardingFeatureTarot => 'Guidare il viaggio dei Tarocchi';

  @override
  String get onboardingFeatureCoffee =>
      'Antichi segreti della predizione del caffè';

  @override
  String get onboardingFeatureDream => 'Analisi dei sogni subconsci';

  @override
  String get onboardingFeatureZodiac => 'Compatibilità mistiche cinesi e maya';

  @override
  String get onboardingWelcomeTagline =>
      'Oggi le mie speranze sono più grandi dei miei sogni.';

  @override
  String get onboardingFinalTagline =>
      'Fai clic per proteggere la tua carta cosmica.';

  @override
  String get tarotShareText =>
      'Le carte mi hanno parlato così! 🔮✨\n#CrackWish #Tarocchi';

  @override
  String get natalChartTitle => 'Grafico di nascita';

  @override
  String get natalChartCalculating => 'Calcolo del tema natale...';

  @override
  String get natalChartSwipeHint => 'Scorri per ispezionare';

  @override
  String get natalChartPlanetPositions => 'POSIZIONI DEL PIANETA';

  @override
  String get natalChartAngularPoints => 'PUNTI ANGOLARI';

  @override
  String get natalChartAsc => 'ASC (Ascendente)';

  @override
  String get natalChartAscDesc =>
      'La maschera che mostri al mondo esterno, la tua immagine e la tua prima impressione.';

  @override
  String get natalChartMc => 'MC (Mediocielo)';

  @override
  String get natalChartMcDesc =>
      'La tua carriera, la tua immagine pubblica e i tuoi obiettivi di vita.';

  @override
  String get natalChartDc => 'DC (Discendente)';

  @override
  String get natalChartDcDesc =>
      'I tratti fondamentali che cerchi nelle relazioni, nel matrimonio e nelle partnership.';

  @override
  String get natalChartIc => 'IC (Imum Coeli)';

  @override
  String get natalChartIcDesc =>
      'Le tue radici, la tua famiglia, il tuo passato e la tua sicurezza fondamentale nel tuo mondo interiore.';

  @override
  String get natalChartTabPersonality =>
      'Riepilogo della personalità principale';

  @override
  String get natalChartTabLove => 'Amore e relazioni';

  @override
  String get natalChartTabCareer => 'Carriera e denaro';

  @override
  String get natalChartTabEmotional => 'Struttura emotiva';

  @override
  String get natalChartTabStrengths => 'Punti di forza e di debolezza';

  @override
  String natalChartHouse(String house) {
    return 'Casa$house';
  }

  @override
  String zodiacGreeting(String name) {
    return 'Ciao$name,';
  }

  @override
  String get zodiacCosmicTraveler => 'Viaggiatore cosmico,';

  @override
  String get zodiacBirthDate => 'DATA DI NASCITA';

  @override
  String get zodiacStarsKnowYou => 'Lascia che le stelle ti conoscano';

  @override
  String get zodiacConfirm => 'CONFERMARE';

  @override
  String get zodiacDiscoverYourselfBtn => 'SCOPRI TE STESSO';

  @override
  String get zodiacEliteRequiredDesc =>
      'Hai bisogno di un abbonamento Elite per scoprire la profonda compatibilità astrologica e le dinamiche virali con i tuoi amici.';

  @override
  String get zodiacEliteDiscoverBtn => 'Scopri i privilegi Elite';

  @override
  String get zodiacHubWestern => 'ASTROLOGIA OCCIDENTALE';

  @override
  String get zodiacHubAsian => 'ASTROLOGIA ASIATICA';

  @override
  String get zodiacHubMayan => 'ASTROLOGIA MAYA';

  @override
  String get actionLater => 'Dopo';

  @override
  String get coffeeViewReading => 'Visualizza Lettura';

  @override
  String get coffeeReadyTitleWithEmoji => '☕️ La tua lettura è pronta!';

  @override
  String get wheelTask_w_c1 =>
      'Invia un messaggio \"ti penso\" a una persona cara';

  @override
  String get wheelTask_w_c2 => 'Saluta qualcuno con cui non parli da un po\'';

  @override
  String get wheelTask_w_c3 =>
      'Spiega a un membro della famiglia quanto è importante oggi';

  @override
  String get wheelTask_w_c4 => 'Fai un complimento a qualcuno accanto a te';

  @override
  String get wheelTask_w_c5 => 'Invia un video divertente ad un amico';

  @override
  String get wheelTask_w_c6 => 'Ringrazia qualcuno oggi e spiega perché';

  @override
  String get wheelTask_w_s1 =>
      'Guardati allo specchio, sorridi a te stesso e mantieni la posizione per 10 secondi';

  @override
  String get wheelTask_w_s2 =>
      'Ricorda l\'ultima volta che hai riso ad alta voce e sorridi di nuovo';

  @override
  String get wheelTask_w_s3 =>
      'Pensa a un ricordo divertente e ridi ad alta voce';

  @override
  String get wheelTask_w_s4 =>
      'Trova e guarda la foto più divertente sul tuo telefono';

  @override
  String get wheelTask_w_s5 => 'Sorridi alla prima persona che vedi';

  @override
  String get wheelTask_w_s6 =>
      'Pensa al momento più divertente che hai vissuto oggi';

  @override
  String get wheelTask_w_m1 => 'Alzati e fai stretching per 30 secondi';

  @override
  String get wheelTask_w_m2 => 'Cammina per la stanza per 1 minuto';

  @override
  String get wheelTask_w_m3 => 'Salta 10 volte e dì \"Posso farcela!\"';

  @override
  String get wheelTask_w_m4 =>
      'Alza le braccia ed esegui la posa di Superman per 20 secondi';

  @override
  String get wheelTask_w_m5 =>
      'Ruota le spalle in avanti 5 volte, poi indietro 5 volte';

  @override
  String get wheelTask_w_m6 =>
      'Fai un respiro profondo, apri bene le braccia e mantieni la posizione per 10 secondi';

  @override
  String get wheelTask_w_mu1 =>
      'Riproduci la tua canzone preferita e ascoltala per 1 minuto';

  @override
  String get wheelTask_w_mu2 =>
      'Riproduci un brano a caso e ascolta i primi 30 secondi';

  @override
  String get wheelTask_w_mu3 =>
      'Cantare! Canta ad alta voce come se nessuno stesse ascoltando';

  @override
  String get wheelTask_w_mu4 =>
      'Ascolta una canzone di un genere che non hai esplorato oggi';

  @override
  String get wheelTask_w_mu5 =>
      'Chiudi gli occhi e ascolta i suoni intorno a te per 30 secondi';

  @override
  String get wheelTask_w_mu6 =>
      'Tocca un ritmo sul tavolo con il dito per 15 secondi';

  @override
  String get wheelTask_w_g1 => 'Pensa a 1 cosa che hai oggi e dì \"grazie\"';

  @override
  String get wheelTask_w_g2 => 'Conta 3 piccole cose che ti rendono felice';

  @override
  String get wheelTask_w_g3 =>
      'Pensa alla cosa migliore che hai mangiato oggi e ricordane il gusto';

  @override
  String get wheelTask_w_g4 =>
      'Pensa al momento più bello della tua vita per 10 secondi';

  @override
  String get wheelTask_w_g5 =>
      'Sentiti grato per la tua salute. Fai un respiro profondo.';

  @override
  String get wheelTask_w_g6 => 'Sentiti grato che il sole sia sorto oggi';

  @override
  String get wheelTask_w_f1 => 'Salta 3 volte e grida \"Posso farcela!\"';

  @override
  String get wheelTask_w_f2 =>
      'Crea la tua faccia più divertente e mantienila per 5 secondi';

  @override
  String get wheelTask_w_f3 => 'Imita un animale: quale animale saresti?';

  @override
  String get wheelTask_w_f4 =>
      'Chiudi gli occhi e immagina di volare per 10 secondi';

  @override
  String get wheelTask_w_f5 =>
      'Assumi una posa da supereroe e mantienila per 5 secondi';

  @override
  String get wheelTask_w_f6 => 'Cammina come un robot per 10 passi';

  @override
  String get zodiacAccessWesternAdTitle =>
      'Limite gratuito giornaliero raggiunto';

  @override
  String get zodiacAccessWesternAdDesc =>
      'Puoi guardare un breve annuncio per rientrare nell\'astrologia occidentale.';

  @override
  String get zodiacAccessWatchAdBtn => 'Guarda l\'annuncio';

  @override
  String get zodiacAccessGetEliteBtn => 'Ottieni Elite';

  @override
  String get zodiacAccessGateTitle => 'Porta della Saggezza Cosmica';

  @override
  String zodiacAccessStoneCount(Object count) {
    return 'Hai${count}Pietre dell\'anima';
  }

  @override
  String get zodiacAccessPremiumInfo1 =>
      'Permesso di accesso alle profondità zodiacali';

  @override
  String get zodiacAccessPremiumInfo2 =>
      'Ogni carta astrologica consuma 1 Pietra dell\'Anima';

  @override
  String get zodiacAccessPremiumInfo3Elite =>
      'Elite: accesso illimitato con 1 Pietra dell\'Anima al giorno';

  @override
  String get zodiacAccessPremiumInfo3Normal =>
      '1 Pietra dell\'Anima è sufficiente con Elite al giorno';

  @override
  String get zodiacAccessOneStoneBtn => '1 pietra dell\'anima';

  @override
  String get onboardingTestSimulate =>
      'Modalità test: simulazione dell\'accesso al vecchio account...';

  @override
  String get onboardingTestAnon => 'Modalità test: connessione anonima...';

  @override
  String onboardingGoogleLoginFailed(Object error) {
    return 'Accesso a Google non riuscito:$error';
  }

  @override
  String onboardingAppleLoginFailed(Object error) {
    return 'Accesso Apple non riuscito:$error';
  }

  @override
  String onboardingGoogleRegisterFailed(Object error) {
    return 'Registrazione Google non riuscita:$error';
  }

  @override
  String onboardingAppleRegisterFailed(Object error) {
    return 'Registrazione Apple non riuscita:$error';
  }

  @override
  String dreamDataError(Object error) {
    return 'Errore dati salvati:$error';
  }

  @override
  String get onboardingBirthDateTitle => 'LA TUA DATA DI NASCITA';

  @override
  String get onboardingSelectBirthDate => 'Seleziona la tua data di nascita';

  @override
  String get onboardingBirthTimeTitle => 'ORA DI NASCITA (facoltativo)';

  @override
  String get onboardingBirthPlaceTitle => 'LUOGO DI NASCITA (facoltativo)';

  @override
  String get onboardingPickerDateTitle => 'Seleziona la data di nascita';

  @override
  String get onboardingPickerTimeTitle => 'Seleziona Ora di nascita';

  @override
  String get onboardingPickerDone => 'Fatto';

  @override
  String get onboardingLifeFocusSpiritual => 'Spirituale\nRisveglio';

  @override
  String get onboardingLifeFocusCareer => 'Carriera e\nPotere personale';

  @override
  String get onboardingLifeFocusLove => 'Amore e\nArmonia Cosmica';

  @override
  String get onboardingLifeFocusHealing => 'Guarigione e\nPace interiore';

  @override
  String get onboardingLifeFocusWealth => 'Ricchezza e\nAbbondanza';

  @override
  String get onboardingLifeFocusSurprise => 'Dell\'universo\nSorprese';

  @override
  String get onboardingDreamMessenger => 'Messaggero e sogni vividi';

  @override
  String get onboardingDreamChaotic => 'Eventi sorprendenti e caotici';

  @override
  String get onboardingDreamCalm => 'Calmo come le nuvole';

  @override
  String get onboardingSleepMindTitle => 'Luce della mente';

  @override
  String get onboardingSleepMindDesc =>
      'Analizzo gli eventi, li soppeso con logica e pianifico passi concreti.';

  @override
  String get onboardingSleepMindVal => 'Luce della mente (Logica)';

  @override
  String get onboardingSleepHeartTitle => 'Sussurro del cuore';

  @override
  String get onboardingSleepHeartDesc =>
      'Ascolto la mia voce interiore e mi fido sempre dei miei sentimenti piuttosto che della logica.';

  @override
  String get onboardingSleepHeartVal => 'Sussurro del cuore (Intuizione)';

  @override
  String get onboardingSleepUniverseTitle => 'Flusso dell\'Universo';

  @override
  String get onboardingSleepUniverseDesc =>
      'Credo che tutto accada per una ragione e seguo i segni dell\'universo.';

  @override
  String get onboardingSleepUniverseVal => 'Flusso dell\'Universo (Destino)';

  @override
  String get linkAccountTitle => 'Collega account';

  @override
  String get linkGoogleAccount => 'Collega account Google';

  @override
  String get linkAppleAccount => 'Collega account Apple';

  @override
  String get linkAccountStarted =>
      'Processo di collegamento dell\'account avviato...';

  @override
  String get linkAccountFailed => 'Collegamento dell\'account fallito';

  @override
  String get profileSignOutGuestDesc =>
      'Attenzione: se esci da un account ospite, non sarai più in grado di accedere a questo account e tutti i tuoi dati (Pietre dell\'Anima, letture) andranno PERSI PERMANENTEMENTE. Sei sicuro di voler uscire?';
}
