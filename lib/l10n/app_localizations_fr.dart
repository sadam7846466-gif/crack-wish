// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Crack et souhait';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionnez la langue';

  @override
  String get systemLanguage => 'Système';

  @override
  String get turkish => 'turc';

  @override
  String get english => 'Anglais';

  @override
  String get close => 'Fermer';

  @override
  String languageValue(Object value) {
    return 'Sélectionné :$value';
  }

  @override
  String get navHome => 'Maison';

  @override
  String get navCollection => 'Collection';

  @override
  String get navProfile => 'Profil';

  @override
  String get dailyCookieTitle => 'Biscuit quotidien';

  @override
  String get dailyCookieSubtitle => 'Appuyez pour tenter votre chance';

  @override
  String get luckyNumber => 'Numéro porte-bonheur';

  @override
  String get luckyColor => 'Couleur chanceuse';

  @override
  String get luckLabel => 'Chance';

  @override
  String get todayFortune => 'La fortune d\'aujourd\'hui';

  @override
  String get shareButton => '📸 Partager';

  @override
  String fortuneShareText(
    Object emoji,
    Object title,
    Object meaning,
    Object number,
    Object color,
    Object percent,
  ) {
    return '$emoji$title${meaning}Numéro porte-bonheur :${number}Couleur porte-bonheur :${color}Chance :$percent%\n\nDepuis l\'application Fortune Cookie 🥠';
  }

  @override
  String get themeSelectTitle => 'Sélectionnez un thème';

  @override
  String themeSelected(Object value) {
    return 'Thème sélectionné :$value';
  }

  @override
  String get themeGalleryTitle => 'Galerie de thèmes';

  @override
  String get themeGalleryOpen => 'Aller à la liste des thèmes';

  @override
  String get themeGalleryLimited =>
      'La galerie de thèmes est actuellement limitée à deux options';

  @override
  String get statCookies => 'Cookies';

  @override
  String get statStreakDays => 'Jours consécutifs';

  @override
  String get statDreams => 'Rêves';

  @override
  String get statMood => 'Humeur';

  @override
  String get statTheme => 'Aujourd\'hui...';

  @override
  String get statCollection => 'Mon biscuit';

  @override
  String get statTalisman => 'Talisman';

  @override
  String get moodGood => 'Bien';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodBad => 'Mauvais';

  @override
  String get moodHappy => 'Heureux';

  @override
  String get moodGreat => 'Super';

  @override
  String get shortcutCollection => 'Collection';

  @override
  String get shortcutHistory => 'Histoire';

  @override
  String get shortcutFavorites => 'Favoris';

  @override
  String get sectionShortcuts => 'Raccourcis';

  @override
  String get sectionActivity => 'Activité';

  @override
  String get menuBadges => 'Insignes';

  @override
  String get menuBadgesSubtitle => 'Réalisations et niveaux';

  @override
  String get menuSettings => 'Paramètres';

  @override
  String get menuSettingsSubtitle => 'Notifications, thème, confidentialité';

  @override
  String get menuHelpAbout => 'Aide et à propos';

  @override
  String get menuHelpAboutSubtitle => 'FAQ et informations sur la version';

  @override
  String get menuShare => 'Partager';

  @override
  String get menuShareSubtitle => 'Partagez votre profil avec des amis';

  @override
  String get activityTarotOpenedTitle => 'Lecture du Tarot ouverte';

  @override
  String get activityTarotOpenedSubtitle => 'Aujourd\'hui • Carte : Étoile';

  @override
  String activityCookiesOpenedTitle(Object count) {
    return '${count}cookies fissurés';
  }

  @override
  String get activityCookiesOpenedSubtitle =>
      'Hier • Nouveaux messages ouverts';

  @override
  String get activityDreamSavedTitle => 'Interprétation des rêves enregistrée';

  @override
  String get activityDreamSavedSubtitle => 'il y a 2 jours';

  @override
  String get profileUserTitle => 'Utilisateur';

  @override
  String get profileSubtitle => 'Moins de bruit, plus vous';

  @override
  String get tagTarot => 'Tarot';

  @override
  String get tagDream => 'Rêve';

  @override
  String get tagCollection => 'Collection';

  @override
  String get zodiacTitle => '⭐ Lecture du zodiaque';

  @override
  String zodiacDailyTitle(Object name) {
    return '$name- Lecture quotidienne';
  }

  @override
  String get zodiacDailyBody =>
      'Vous avez de la chance en amour cette semaine ! Des opportunités de carrière sont à votre porte : gardez les yeux ouverts. Votre énergie est élevée, utilisez-la. C\'est le moment idéal pour de nouveaux projets. Vos capacités de communication sont à leur apogée, profitez-en.';

  @override
  String get zodiacLove => 'Amour';

  @override
  String get zodiacCareer => 'Carrière';

  @override
  String get zodiacMoney => 'Argent';

  @override
  String get zodiacHealth => 'Santé';

  @override
  String get collectionTitle => 'Votre collection';

  @override
  String get collectionSubtitle =>
      'Traces et récompenses de votre rituel quotidien';

  @override
  String get collectionNotYet => 'Pas encore';

  @override
  String get collectionFirstTime => 'Première fois';

  @override
  String get collectionTotalOpened => 'Total';

  @override
  String get collectionCookieDescription =>
      'Ce cookie ajoute de la chance et des petites surprises à votre rituel. Plus vous ouvrez, plus votre collection devient forte.';

  @override
  String get collectionSummaryTitle => 'Résumé de la collecte';

  @override
  String get collectionSummaryTypes => 'Types uniques';

  @override
  String get collectionSummaryTotalOpened => 'Total ouvert';

  @override
  String get collectionSummaryRare => 'Rare';

  @override
  String get collectionSummaryFooter =>
      'Chaque cookie a une histoire. Plus vous l’ouvrez, plus il s’enrichit.';

  @override
  String get rarityAll => 'Tous';

  @override
  String get rarityCommon => 'Commun';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityLegendary => 'Légendaire';

  @override
  String get collectionUndiscovered => 'Non découvert';

  @override
  String get collectionNotFoundYet =>
      'La chance ne vous a pas amené ici... pour le moment.';

  @override
  String get collectionEmptyTitle =>
      'Vous n\'avez pas encore ouvert de cookies';

  @override
  String collectionEmptySubtitle(Object count) {
    return '${count}différents cookies vous attendent. Ouvrez le cookie d\'aujourd\'hui pour démarrer votre collection.';
  }

  @override
  String get discoverTitle => 'Découvrir';

  @override
  String get discoverSubtitle => 'Explorez de nouvelles fonctionnalités';

  @override
  String get discoverCategories => 'Catégories';

  @override
  String get categoryTarotTitle => 'Lecture du Tarot';

  @override
  String get categoryTarotDesc => 'Tarot à 3 cartes';

  @override
  String get categoryDreamTitle => 'Interprétation des rêves';

  @override
  String get categoryDreamDesc => 'Découvrez le sens de vos rêves';

  @override
  String get categoryZodiacTitle => 'Lecture du zodiaque';

  @override
  String get categoryZodiacDesc => 'Message des étoiles';

  @override
  String get categoryPersonalityTitle => 'Test de personnalité';

  @override
  String get categoryPersonalityDesc => '16 personnalités';

  @override
  String get discoverDailySuggestionTitle => 'LA SUGGESTION DU JOUR';

  @override
  String get discoverDailySuggestionHeadline =>
      'As-tu fait un rêve cette nuit ?';

  @override
  String get discoverDailySuggestionSubtitle =>
      'Interprétez-le maintenant et découvrez sa signification !';

  @override
  String get dailySuggestionDreamHeadline => 'As-tu fait un rêve cette nuit ?';

  @override
  String get dailySuggestionDreamSubtitle =>
      'Interprétez-le maintenant et découvrez sa signification !';

  @override
  String get dailySuggestionTarotHeadline =>
      'Avez-vous vérifié votre tarot aujourd\'hui ?';

  @override
  String get dailySuggestionTarotSubtitle =>
      'Choisissez 3 cartes et voyez votre message !';

  @override
  String get dailySuggestionZodiacHeadline =>
      'Vous avez déjà vérifié votre lecture du zodiaque ?';

  @override
  String get dailySuggestionZodiacSubtitle =>
      'Découvrez immédiatement l\'énergie d\'aujourd\'hui !';

  @override
  String get dailySuggestionCoffeeHeadline => 'As-tu bu du café aujourd\'hui ?';

  @override
  String get dailySuggestionCoffeeSubtitle =>
      'Retournez votre tasse, lisons votre fortune !';

  @override
  String get dailySuggestionAllDoneHeadline =>
      'Les rituels du jour sont terminés !';

  @override
  String get dailySuggestionAllDoneSubtitle =>
      'Revenez demain pour du nouveau contenu.';

  @override
  String get discoverFeaturedTag => 'EN VEDETTE';

  @override
  String get discoverFeaturedTitle => 'Lecture du Tarot à 3 cartes';

  @override
  String get discoverFeaturedSubtitle =>
      'Explorez votre passé, votre présent et votre avenir';

  @override
  String get ctaStart => 'Commencer';

  @override
  String get homeGreeting => 'Bonjour! 👋';

  @override
  String get homeFeeling => 'Comment te sens-tu aujourd’hui ?';

  @override
  String get quoteOfDayText =>
      'Le plus petit pas que vous faites aujourd’hui mènera à la plus grande victoire demain.';

  @override
  String get quoteOfDaySource => '— Citation du jour';

  @override
  String get dailyHoroscopeTitle => 'Bélier';

  @override
  String get dailyHoroscopeSubtitle => 'Lecture du jour';

  @override
  String get dailyHoroscopeBody =>
      'Vous avez de la chance en amour cette semaine ! Des opportunités de carrière sont à votre porte : gardez les yeux ouverts. Votre énergie est élevée, utilisez-la.';

  @override
  String get aries => 'Bélier';

  @override
  String get bentoTarotTitle => 'Tarot';

  @override
  String get bentoTarotDesc => 'Voyez votre avenir';

  @override
  String get bentoTarotBadge => 'POPULAIRE';

  @override
  String get bentoDreamTitle => 'Rêve';

  @override
  String get bentoDreamDesc => 'Explorez votre subconscient';

  @override
  String get bentoDreamBadge => 'NOUVEAU';

  @override
  String get bentoMotivationTitle => 'Humeur';

  @override
  String get bentoMotivationDesc => 'Découvrez votre humeur';

  @override
  String get bentoMotivationBadge => 'TOUS LES JOURS';

  @override
  String get bentoZodiacTitle => 'Zodiaque';

  @override
  String get bentoZodiacDesc => 'Message des étoiles';

  @override
  String get bentoZodiacBadge => 'TOUS LES JOURS';

  @override
  String get moodQuestion => 'Comment allez-vous aujourd\'hui?';

  @override
  String get dreamTitle => 'Racontez votre rêve';

  @override
  String get dreamTabNew => 'Nouveau rêve';

  @override
  String get dreamTabHistory => 'Mes rêves';

  @override
  String get dreamAnalyzeButton => 'Interpréter le rêve';

  @override
  String get dreamAnalyzeEstimate => '~ 5 secondes';

  @override
  String get dreamInterpretationTitle => 'Interprétation des rêves';

  @override
  String get dreamNoHistory => 'Vous n\'avez pas encore de rêves enregistrés';

  @override
  String get dreamDefaultTitle => 'Rêve';

  @override
  String get dreamSpiritual => 'Spirituel';

  @override
  String get dreamEnriched => 'Interprétation enrichie';

  @override
  String get dreamEnriching => 'Enrichissant...';

  @override
  String get dreamEnrich => 'Enrichir';

  @override
  String get dreamShare => 'Partager';

  @override
  String get dreamAnalyzing => 'Analyser le rêve...';

  @override
  String get dreamAnalysisFailed =>
      'Impossible de générer une interprétation pour le moment.';

  @override
  String get dreamClarifyThreat =>
      'Y avait-il un sentiment de menace ou de peur dans le rêve ?';

  @override
  String get dreamClarifyFamiliar =>
      'Cette scène vous semble-t-elle familière du passé ?';

  @override
  String get dreamClarifyEscape =>
      'Y a-t-il eu une sensation de mouvement ou d’évasion ?';

  @override
  String get dreamClarifyAnxious =>
      'Avez-vous ressenti de l\'anxiété ou une menace dans le rêve ?';

  @override
  String get dreamUnsure => 'Pas sûr';

  @override
  String get dreamYes => 'OUI';

  @override
  String get dreamNo => 'NON';

  @override
  String get dreamGeneral => 'Rêve général';

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
    return 'Titre du rêve :${title}Date :${date}Rêve :${text}Général :${general}Psychologique :${psychology}Spirituel :${spiritual}Conseil :$advice#VLucky #Rêve';
  }

  @override
  String get scientificTitle => 'Analyse scientifique des rêves';

  @override
  String get scientificDreamPromptTitle => 'Racontez votre rêve';

  @override
  String get scientificDreamHint =>
      'Écrivez votre rêve tel que vous vous en souvenez...';

  @override
  String get scientificEmotionQuestion => 'Qu’avez-vous ressenti au réveil ?';

  @override
  String get scientificEmotionHint => 'Choisissez une émotion';

  @override
  String get scientificClarityQuestion =>
      'Dans quelle mesure le rêve était-il clair ?';

  @override
  String get scientificDisclaimer =>
      'Cette analyse s’appuie sur des recherches en psychologie et en neurosciences. Il ne fournit pas de résultats définitifs ou prédictifs.';

  @override
  String get scientificLoading =>
      'Évaluation basée sur le sommeil paradoxal et les neurosciences';

  @override
  String get scientificResultsTitle => 'Interprétation des rêves';

  @override
  String get scientificRecentPastTitle => 'Effets passés récents';

  @override
  String get scientificSaved => 'Rêve sauvé';

  @override
  String get scientificSaveButton => 'Sauver le rêve';

  @override
  String get cookieSpringWreath => 'Couronne de printemps';

  @override
  String get cookieLuckyClover => 'Trèfle porte-bonheur';

  @override
  String get cookieRoyalHearts => 'Coeurs royaux';

  @override
  String get cookieEvilEye => 'Mauvais œil';

  @override
  String get cookiePizzaParty => 'Soirée Pizza';

  @override
  String get cookieSakuraBloom => 'Sakura fleurit';

  @override
  String get cookieBluePorcelain => 'Porcelaine Bleue';

  @override
  String get cookiePinkBlossom => 'Fleur rose';

  @override
  String get cookieFortuneCat => 'Chat porte-bonheur';

  @override
  String get cookieWildflower => 'Fleurs sauvages';

  @override
  String get cookieCupidRibbon => 'Ruban Cupidon';

  @override
  String get cookiePandaBamboo => 'Panda Bambou';

  @override
  String get cookieRamadanCute => 'Ramadan';

  @override
  String get cookieEnchantedForest => 'Forêt enchantée';

  @override
  String get cookieGoldenArabesque => 'Arabesque dorée';

  @override
  String get cookieMidnightMosaic => 'Mosaïque de minuit';

  @override
  String get cookiePearlLace => 'Dentelle perlée';

  @override
  String get cookieGoldenSakura => 'Sakura doré';

  @override
  String get cookieDragonPhoenix => 'Dragon Phénix';

  @override
  String get cookieGoldBeasts => 'Bêtes d\'or';

  @override
  String get emotionAnxiety => 'Anxieux';

  @override
  String get emotionFear => 'Effrayé';

  @override
  String get emotionCalm => 'Calme';

  @override
  String get emotionHappy => 'Heureux';

  @override
  String get emotionSad => 'Triste';

  @override
  String get emotionConfusion => 'Incertain';

  @override
  String get emotionSurprise => 'Surpris';

  @override
  String get dreamMoodQuestion => 'Qu’avez-vous ressenti au réveil ?';

  @override
  String get dreamMetricEmotional => 'Charge émotionnelle';

  @override
  String get dreamMetricUncertainty => 'Récit\nIncertitude';

  @override
  String get dreamMetricRecentPast => 'Passé récent';

  @override
  String get dreamMetricBrain => 'Activité cérébrale';

  @override
  String get tarotShuffleHint => 'Faites glisser en cercle pour mélanger';

  @override
  String get tarotEnergyDepletedTitle => 'Énergie épuisée';

  @override
  String get tarotEnergyDepletedBody =>
      'Votre énergie cosmique quotidienne est épuisée.\nRechargez pour voir la vérité.';

  @override
  String get tarotEnergyDepletedSub =>
      'Vos cartes sélectionnées sont prêtes, il ne reste plus qu\'une étape...';

  @override
  String get tarotWatchAd => 'Regarder l\'annonce et ouvrir';

  @override
  String tarotFreeRemaining(Object count) {
    return 'Libre restant aujourd\'hui :$count';
  }

  @override
  String get socialFeedTitle => 'Alimentation silencieuse';

  @override
  String get feedTypeCookie => 'Biscuit';

  @override
  String get feedTagDailyCookie => 'Le biscuit du jour';

  @override
  String get feedTypeTarot => 'Tarot';

  @override
  String get feedTagThreeCard => 'tirage à 3 cartes';

  @override
  String get feedTypeDream => 'Rêve';

  @override
  String get feedTagDreamMode => 'Mode rêve';

  @override
  String get feedTypeZodiac => 'Zodiaque';

  @override
  String get feedTagDailyEnergy => 'Énergie quotidienne';

  @override
  String get feedTypeMotivation => 'Motivation';

  @override
  String get feedTagMiniAction => 'Mini-actions';

  @override
  String inviteShareMessage(String handle, String link) {
    return 'Êtes-vous prêt pour un voyage mystique ? Je vous attends dans l\'univers Crack&Wish ! ✨\n\nMon code d\'invitation :${handle}Télécharger maintenant :$link';
  }

  @override
  String get inviteShareSubject => 'Crack&Wish Inviter';

  @override
  String get inviteSendButton => 'Inviter';

  @override
  String get inviteConnectButton => 'Connecter';

  @override
  String get inviteSentText => 'Envoyé';

  @override
  String inviteRequestSent(String name) {
    return 'Demande envoyée à$name!';
  }

  @override
  String get toastCoffeeReadyTitle => 'Votre lecture est prête !';

  @override
  String get toastCoffeeReadyMessage =>
      'Les secrets de votre tasse ont été révélés.';

  @override
  String get toastViewButton => 'Voir';

  @override
  String get toastDreamReadyTitle => 'Votre rêve est interprété !';

  @override
  String get toastDreamReadyMessage =>
      'Les messages de votre subconscient ont été décodés.';

  @override
  String get toastCoffeeReadyTitle2 => 'Votre lecture de café est prête !';

  @override
  String get dreamFallbackTitle => 'Interprétation des rêves';

  @override
  String get rewardWelcomeTitle => 'Bienvenue dans l\'Univers';

  @override
  String get rewardWelcomeDesc =>
      'Nous vous avons laissé un petit cadeau pour commencer votre voyage.';

  @override
  String get rewardReferralFallback => 'Un ami';

  @override
  String get rewardReferralReceiverTitle => 'Un cadeau inattendu';

  @override
  String rewardReferralReceiverDesc(String inviter) {
    return '${inviter}vous a invité ici et vous a laissé un cadeau de bienvenue.';
  }

  @override
  String get rewardInviterTitle => 'Votre appel a été entendu !';

  @override
  String rewardInviterDescSingle(String name) {
    return '${name}a rejoint l\'univers. Vous avez été récompensé pour être un guide.';
  }

  @override
  String rewardInviterDescMultiple(String name, int count) {
    return '${name}et${count}d\'autres amis ont rejoint l\'univers. Vous avez été récompensé pour être un guide.';
  }

  @override
  String rewardInviterDescGeneric(int count) {
    return '${count}amis ont rejoint l\'univers. Vous avez été récompensé pour être un guide.';
  }

  @override
  String birthdayTitleWithName(String name) {
    return 'Joyeux anniversaire,$name!';
  }

  @override
  String get birthdayTitle => 'Joyeux anniversaire!';

  @override
  String get birthdayDesc =>
      'Aujourd\'hui est le jour sacré où votre âme est venue dans ce monde. L\'univers vous a laissé un cadeau spécial.';

  @override
  String get cookieReminderTitle =>
      'Vous n\'avez pas piraté un cookie aujourd\'hui';

  @override
  String get cookieReminderMessage =>
      'Votre message de fortune quotidien vous attend !';

  @override
  String get cookieReminderReward => '3 gauche';

  @override
  String achievementRewardStones(int count) {
    return '+${count}Pierres d\'âme';
  }

  @override
  String achievementRewardAura(int count) {
    return '+${count}Aura';
  }

  @override
  String get rankUpTitle => 'Promotion cosmique !';

  @override
  String rankUpMessage(String rank) {
    return 'Votre puissance d’aura a augmenté. Nouveau titre :$rank';
  }

  @override
  String get rankNovice => 'Voyant novice';

  @override
  String get rankApprentice => 'Apprenti voyant';

  @override
  String get rankSeer => 'Voyant';

  @override
  String get rankWise => 'Voyant sage';

  @override
  String get rankMaster => 'Maître Voyant';

  @override
  String get rankCosmic => 'Voyant cosmique';

  @override
  String get loginSubtitle =>
      'Synchronisez-vous avec le guide de votre âme.\nSouvenez-vous de votre passé, de votre avenir et de votre subconscient.';

  @override
  String get loginAppleContinue => 'Continuer avec Apple';

  @override
  String get loginAppleSignIn => 'Connectez-vous avec Apple';

  @override
  String get loginGoogleContinue => 'Continuer avec Google';

  @override
  String get loginGoogleSignIn => 'Connectez-vous avec Google';

  @override
  String get loginGoogleFailed => 'Échec de la connexion à Google';

  @override
  String get loginAppleFailed => 'Échec de la connexion Apple';

  @override
  String get loginNoAccountYet =>
      'Vous n\'avez pas encore rejoint l\'univers ?';

  @override
  String get loginHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get loginSignUp => 'S\'inscrire';

  @override
  String get loginSignIn => 'Se connecter';

  @override
  String get loginLegalPrefix => 'En continuant, vous acceptez notre';

  @override
  String get loginTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get loginLegalAnd => 'et';

  @override
  String get loginPrivacyPolicy => 'politique de confidentialité';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get homeSubtitle1 => 'Craquez, lisez, souriez.';

  @override
  String get homeSubtitle2 => 'La chance dans votre poche.';

  @override
  String get homeSubtitle3 => 'Le message du jour : Vous.';

  @override
  String get homeSubtitle4 => 'Un craquement, une surprise.';

  @override
  String get homeSubtitle5 => 'Un petit cookie, une grande sensation.';

  @override
  String get homeSubtitle6 => 'Pas le destin, juste un doux indice.';

  @override
  String get homeSubtitle7 => 'Que dit votre chance aujourd\'hui ?';

  @override
  String get homeSubtitle8 => 'Ouvrez, découvrez, avancez.';

  @override
  String get homeSubtitle9 => 'La chance est à portée de main.';

  @override
  String get homeSubtitle10 => 'Un nouveau départ à chaque fissure.';

  @override
  String get homeSubtitle11 => 'Trouvez votre message.';

  @override
  String get homeSubtitle12 => 'Pas au hasard… juste pour vous.';

  @override
  String get homeSubtitle13 => 'Tentez votre chance, saisissez votre journée.';

  @override
  String get homeSubtitle14 => 'De petites prophéties qui font sourire.';

  @override
  String get homeSubtitle15 => 'Les surprises font du bien.';

  @override
  String get homeMilestoneTitle => 'Une concentration incroyable !';

  @override
  String homeMilestoneMessage(int count) {
    return 'Votre séquence quotidienne a atteint${count}jours.';
  }

  @override
  String homeMilestoneSoulStone(int count) {
    return '+${count}Pierres d\'âme';
  }

  @override
  String get homeGreetingMorning => 'Bonjour';

  @override
  String get homeGreetingAfternoon => 'Bon après-midi';

  @override
  String get homeGreetingEvening => 'Bonne soirée';

  @override
  String get homeGreetingNight => 'Bonne nuit';

  @override
  String get homeTimeSubMorning => 'Message frais avec votre café.';

  @override
  String get homeTimeSubAfternoon => 'Une pause magique dans votre journée.';

  @override
  String get homeTimeSubEvening => 'Une douce prophétie pour se détendre.';

  @override
  String get homeTimeSubNight => 'Les étoiles brillent pour toi ce soir.';

  @override
  String get paywallSubtitleElite =>
      'Votre conscience cosmique est déjà ouverte.\nRenforcez votre illumination en améliorant votre plan.';

  @override
  String get paywallSubtitleNew =>
      'Ouvrez la porte à la conscience cosmique.\nSupprimez toutes les limites.';

  @override
  String get paywallFeature1 => '5 pierres d\'âme fraîches par jour';

  @override
  String get paywallFeature2 => 'Mode d\'analyse maître';

  @override
  String get paywallFeature3 => 'Gain d\'aura rapide x3';

  @override
  String get paywallFeature4 => 'Archives cliniques illimitées';

  @override
  String get paywallFeature5 => 'Expérience fluide et sans publicité';

  @override
  String get paywallPackageWeekly => 'Réveil hebdomadaire';

  @override
  String get paywallPackageMonthly => 'Intuition mensuelle';

  @override
  String get paywallPackageYearly => 'Illumination annuelle';

  @override
  String get paywallBtnCurrentPlan => 'Forfait actuel';

  @override
  String get paywallBtnManage => 'Gérer depuis le magasin';

  @override
  String get paywallBtnUpgrade => 'Plan de mise à niveau';

  @override
  String get paywallBtnSubscribe => 'Débloquez Élite';

  @override
  String get paywallSuccessUpgradeTitle => 'Illumination améliorée';

  @override
  String get paywallSuccessTitle => 'Bienvenue aux Lumières';

  @override
  String get paywallSuccessUpgradeSubtitle =>
      'Votre forfait a été mis à niveau avec succès.';

  @override
  String get paywallSuccessSubtitle =>
      'Vous êtes désormais membre Élite. Les limites cosmiques ont été supprimées pour vous.';

  @override
  String get paywallErrorTitle => 'Erreur de connexion';

  @override
  String get paywallErrorMessage =>
      'Impossible de se connecter au magasin ou la transaction a été annulée. Les produits ne peuvent pas encore être publiés sur l\'App Store/Play Console. Veuillez réessayer plus tard.';

  @override
  String get paywallRestoreSuccess => 'Élite restaurée';

  @override
  String get paywallRestoreSuccessSubtitle =>
      'Bon retour à la conscience cosmique. Vos limites ont été supprimées.';

  @override
  String get paywallRestoreNoSub => 'Aucun abonnement actif';

  @override
  String get paywallRestoreNoSubMessage =>
      'Aucun abonnement Crack Wish Elite actif trouvé à restaurer. Veuillez consulter les forfaits.';

  @override
  String get paywallRestore => 'Restaurer les achats';

  @override
  String get paywallCurrentPlanBadge => 'RÉGIME ACTUEL';

  @override
  String get paywallLegalTr =>
      'Crack Wish Elite est un abonnement à renouvellement automatique. Le paiement sera débité de votre compte lors de la confirmation de l\'achat. L\'abonnement se renouvelle automatiquement sauf annulation au moins 24 heures avant la fin de la période en cours. Vous pouvez gérer et annuler vos abonnements dans les paramètres de votre App Store.';

  @override
  String get paywallOk => 'D\'ACCORD';

  @override
  String get coffeeLoading1 => 'Plonger dans les profondeurs de la coupe...';

  @override
  String get coffeeLoading2 =>
      'Les symboles sur le terrain s\'alignent sur l\'énergie universelle...';

  @override
  String get coffeeLoading3 =>
      'Vos lignes de destin sont en train d\'être tracées...';

  @override
  String get coffeeLoading4 => 'Des secrets sont révélés...';

  @override
  String get coffeeAiError =>
      'L\'IA a rencontré une erreur lors de l\'interprétation de la lecture.';

  @override
  String get coffeeGenericError =>
      'Quelque chose s\'est mal passé. Veuillez réessayer.';

  @override
  String get coffeeNotifReady =>
      'Vous serez averti lorsque votre lecture sera prête';

  @override
  String get coffeeCheckHistory => 'bouton pour le voir';

  @override
  String get coffeeWaitOrExplore => 'Attendez ici ou explorez l\'application';

  @override
  String get coffeeGoHome => 'Aller à la maison';

  @override
  String get coffeeSections => 'Sections de coupe';

  @override
  String get coffeeSectionInside => 'À l\'intérieur de la Coupe';

  @override
  String get coffeeSectionInsideDesc =>
      'Votre monde intérieur, vos pensées, votre état émotionnel.';

  @override
  String get coffeeSectionEdge => 'Bord de la coupe';

  @override
  String get coffeeSectionEdgeDesc =>
      'Futur proche, nouvelles, messages, rencontres.';

  @override
  String get coffeeSectionBottom => 'Fond de tasse';

  @override
  String get coffeeSectionBottomDesc =>
      'Problèmes passés persistants, fardeaux, questions non résolues.';

  @override
  String get coffeeSectionSaucer => 'Soucoupe';

  @override
  String get coffeeSectionSaucerDesc =>
      'Souhait, résultat, destin, énergie finale.';

  @override
  String get coffeeLoadingComment => 'Chargement de l\'interprétation...';

  @override
  String get coffeeStoryTitle => 'L\'histoire racontée par le terrain';

  @override
  String get coffeeSymbolsTitle => 'Symboles vus dans votre lecture';

  @override
  String get coffeeLove => 'Amour et relations';

  @override
  String get coffeeCareer => 'Carrière et finances';

  @override
  String get coffeeFamily => 'Famille & Cercle Proche';

  @override
  String get coffeeNearFuture => 'Futur proche';

  @override
  String get coffeeClosing => 'Derniers mots de votre lecture';

  @override
  String get coffeeShare => 'Partager ma lecture';

  @override
  String get coffeeRetryValidation => 'Revenir en arrière et reprendre';

  @override
  String get coffeeRetry => 'Essayer à nouveau';

  @override
  String get coffeeCancel => 'Annuler';

  @override
  String get coffeeSymbolLabel => 'Symbole';

  @override
  String get coffeeSymbolLoading => 'Chargement...';

  @override
  String get coffeeTimelineSoon => 'Très bientôt';

  @override
  String get coffeeImageError =>
      'Impossible de détecter du marc de café clair sur cette image.';

  @override
  String get coffeeCosmicTitle => 'Lecture de café cosmique';

  @override
  String get coffeePremiumOnly => 'Fonctionnalité Premium uniquement';

  @override
  String get coffeePremiumDesc =>
      'Coffee Reading est réservé aux membres d’élite. Passez à Premium et découvrez les secrets de votre avenir avec vos Soul Stones.';

  @override
  String get coffeePremiumSimBtn => 'Passez au Premium (Simulation)';

  @override
  String get coffeePhotoSource => 'Source des photos';

  @override
  String get coffeeCamera => 'Caméra';

  @override
  String get coffeeGallery => 'Galerie';

  @override
  String get coffeeStepCupInside => 'À l\'intérieur de la Coupe';

  @override
  String get coffeeStepCupInsideDesc =>
      'Placez la caméra directement au-dessus de la tasse et capturez le marc de café à l\'intérieur.';

  @override
  String get coffeeStepLeftProfile => 'Profil gauche';

  @override
  String get coffeeStepLeftProfileDesc =>
      'Tenez la tasse par sa poignée et prenez une photo claire du côté gauche uniquement.';

  @override
  String get coffeeStepRightProfile => 'Bon profil';

  @override
  String get coffeeStepRightProfileDesc =>
      'Capturez maintenant le côté arrière droit de la tasse sous un angle bien éclairé.';

  @override
  String get coffeeStepSaucerSecret => 'Le secret de la soucoupe';

  @override
  String get coffeeStepSaucerDesc =>
      'Enfin, capturez la large surface de la soucoupe avec les motifs clairement visibles.';

  @override
  String get coffeeStepSaucerBtn => 'Prendre une photo de soucoupe';

  @override
  String get coffeeHeaderTitle => 'LECTURE DE CAFÉ';

  @override
  String get coffeeLastReading => 'Votre dernière lecture';

  @override
  String coffeeLastReadingTime(String time) {
    return 'À$time• Expire à minuit';
  }

  @override
  String get coffeeNoReadingYet =>
      'Vous n\'avez pas encore eu de lecture.\nPréparez une tasse de café,\net laissez le terrain vous chuchoter.';

  @override
  String get coffeeSoulStones => 'Vos pierres d\'âme';

  @override
  String get coffeeSoulStoneEmpty => 'Il ne reste plus aucune pierre d\'âme';

  @override
  String get coffeeSoulStoneRequired =>
      'Requis pour l\'analyse de la lecture du café';

  @override
  String get coffeeSoulStoneCost => 'Chaque lecture coûte 1 pierre d\'âme';

  @override
  String get coffeeSoulStoneEliteActive =>
      'Avantage d\'élite : 5 pierres d\'âme rafraîchies chaque nuit';

  @override
  String get coffeeSoulStoneElitePromo =>
      'Devenez Elite pour gagner 5 Soul Stones chaque soir';

  @override
  String get coffeeEliteSubscribe => 'Abonnez-vous à Élite';

  @override
  String get coffeeRitualLabel => 'RITUEL';

  @override
  String get coffeeRitualTitle => 'Secrets de la Coupe';

  @override
  String get coffeeRitualDesc =>
      'Les motifs ne parlent qu\'à ceux qui regardent attentivement. Suivez le rituel pour une vraie lecture.';

  @override
  String get coffeeRitualStep1Title => 'Définissez votre intention';

  @override
  String get coffeeRitualStep1Desc =>
      'Pendant que vous sirotez, laissez une question ou un souhait vous traverser l’esprit.';

  @override
  String get coffeeRitualStep2Title => 'Sirotez d\'un côté';

  @override
  String get coffeeRitualStep2Desc =>
      'Buvez toujours du même côté pour préserver les motifs.';

  @override
  String get coffeeRitualStep3Title => 'Retournez-le';

  @override
  String get coffeeRitualStep3Desc =>
      'Retournez la tasse, laissez-la refroidir et ouvrez-la doucement.';

  @override
  String get coffeeRitualListenTitle => 'Écoutez les murmures du terrain';

  @override
  String coffeeStepLabel(String index, String title) {
    return 'Étape$index:$title';
  }

  @override
  String get coffeeDiscoverFate => 'Découvrez votre destin';

  @override
  String get coffeeNextStep => 'Étape suivante';

  @override
  String get coffeeCapture => 'Capturez cet angle';

  @override
  String get coffeeValidationError =>
      'Le terrain sur les photos marquées\nn\'a pas pu être clairement identifié.';

  @override
  String get coffeeCosmicMismatch => 'Inadéquation cosmique';

  @override
  String get coffeeCosmicCheck => 'VÉRIFICATION DES LIENS COSMIQUES';

  @override
  String get coffeeCosmicCheckDesc =>
      'Décoder le langage des motifs,\nécouter les murmures du destin...';

  @override
  String get coffeeRevealSecrets => 'Soulevez le voile des secrets';

  @override
  String get coffeeReadingInProgress => 'Lire les motifs...';

  @override
  String get coffeeReadingWait => 'Les portes du futur s’ouvrent, tenez bon.';

  @override
  String get coffeeRelationTitle => 'Votre statut relationnel';

  @override
  String get coffeeRelationSubtitle =>
      'Établissez les bases de votre lien cosmique.';

  @override
  String get coffeeFocusTitle => 'Qu\'est-ce qui préoccupe votre esprit?';

  @override
  String get coffeeFocusSubtitle =>
      'Choisissez une intention pour approfondir votre lecture.';

  @override
  String get coffeeMoodTitle => 'Votre humeur ?';

  @override
  String get coffeeMoodSubtitle => 'Ressentez l\'énergie de votre tasse.';

  @override
  String get coffeeCosmicBondFormed => 'Lien cosmique formé';

  @override
  String get coffeeSecretsReady =>
      'Les secrets de votre tasse sont prêts à être murmurés...';

  @override
  String get coffeeNewReading => 'Nouvelle lecture';

  @override
  String get coffeeAiPermission => 'Autorisation d\'analyse du café par l\'IA';

  @override
  String get coffeeStoneCostInfo => 'Chaque analyse coûte 1 Pierre d\'Âme';

  @override
  String get coffeeEliteRefillActive =>
      'Avantage d\'élite : 5 pierres d\'âme rafraîchies chaque nuit';

  @override
  String get coffeeEliteRefillPromo =>
      'Devenez Elite pour gagner 5 Soul Stones chaque soir';

  @override
  String get coffeeEliteGetBtn => 'Obtenez Élite';

  @override
  String get coffeeResultOnHome => 'Voir le résultat sur la page d\'accueil';

  @override
  String get onboardingStart => 'Commençons';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingContinueWithoutAccount => 'Hesap Açmadan Devam Et';

  @override
  String get onboardingFinish => 'Commencer le voyage';

  @override
  String get onboardingNameHint => 'Un nom cosmique';

  @override
  String get onboardingNamePlaceholder => 'premier_dernier';

  @override
  String get onboardingHandleHint => 'Une poignée cosmique';

  @override
  String get onboardingHandlePlaceholder => 'galaxy_traveler';

  @override
  String get onboardingGenderTitle => 'Genre';

  @override
  String get onboardingGenderFemale => 'Femelle';

  @override
  String get onboardingGenderMale => 'Mâle';

  @override
  String get onboardingGenderOther => 'Je préfère ne pas dire';

  @override
  String get onboardingStep1Title => 'Comment devrions-nous vous appeler ?';

  @override
  String get onboardingStep1Sub =>
      'Sous quel nom et quelle vibration l’univers devrait-il vous connaître ?';

  @override
  String get onboardingAvatarSelect => 'Sélectionnez votre avatar';

  @override
  String get onboardingStep2Title => 'Au moment où ton âme est entrée...';

  @override
  String get onboardingStep2Sub =>
      'Nous avons besoin de vos informations de base pour calculer votre thème astrologique et vos rituels personnalisés.';

  @override
  String get onboardingBirthDateLabel => 'Date de naissance';

  @override
  String get onboardingBirthTimeLabel => 'Heure de naissance';

  @override
  String get onboardingBirthLocationLabel => 'Ville de naissance';

  @override
  String get onboardingTimeHint =>
      'Si vous connaissez l\'heure exacte, entrez pour une analyse détaillée';

  @override
  String get onboardingLocationHint =>
      'Affiner le calcul en sélectionnant une ville';

  @override
  String get onboardingUnknownTime => 'je ne connais pas l\'heure exacte';

  @override
  String get onboardingPrivacyNote =>
      'Utilisé exclusivement pour dessiner votre graphique personnalisé.';

  @override
  String get onboardingStep3Title => 'Quelle est votre priorité ?';

  @override
  String get onboardingStep3Sub =>
      'Quelle énergie souhaitez-vous le plus développer ou guérir dans votre vie en ce moment ?';

  @override
  String get onboardingFocusLabel => 'Mise au point (choix multiple)';

  @override
  String get onboardingFocusCareer => 'Carrière et argent';

  @override
  String get onboardingFocusLove => 'Amour et relations';

  @override
  String get onboardingFocusPeace => 'Paix intérieure';

  @override
  String get onboardingFocusLuck => 'Chance et opportunités';

  @override
  String get onboardingRelLabel => 'Statut actuel de la relation :';

  @override
  String get onboardingRelSingle => 'Ciel solitaire';

  @override
  String get onboardingRelComplicated => 'Il y a quelqu\'un...';

  @override
  String get onboardingRelTalking => 'Compliqué';

  @override
  String get onboardingRelRelationship => 'Lien heureux';

  @override
  String get onboardingStep4Title => 'Votre connexion à l\'univers la nuit...';

  @override
  String get onboardingStep4Sub =>
      'Comment votre subconscient reçoit-il les messages ? Les couleurs et les rêves nous donneront des indices.';

  @override
  String get onboardingDreamLabel =>
      'À quelle fréquence vous souvenez-vous de vos rêves ?';

  @override
  String get onboardingDreamOften => 'Souvent et clairement';

  @override
  String get onboardingDreamSometimes => 'Parfois';

  @override
  String get onboardingDreamRarely => 'Rarement';

  @override
  String get onboardingDreamNever => 'Jamais';

  @override
  String get onboardingAuraLabel =>
      'L\'aura de votre âme (Comment vous sentez-vous aujourd\'hui ?)';

  @override
  String get onboardingStep5Title => 'Ta danse avec le temps...';

  @override
  String get onboardingStep5Sub =>
      'Quand votre énergie est-elle la plus élevée ? Nous ajusterons vos notifications en conséquence.';

  @override
  String get onboardingSleepLabel => 'Votre rythme de sommeil';

  @override
  String get onboardingSleepMorning => 'Personne du matin';

  @override
  String get onboardingSleepNight => 'Oiseau de nuit';

  @override
  String get onboardingSleepIrregular => 'Irrégulier';

  @override
  String get onboardingSleepLittle => 'Je dors très peu';

  @override
  String get onboardingMatchLabel => 'Correspondance et connexion cosmique';

  @override
  String get onboardingMatchDesc =>
      'Je veux être ouvert à la connexion avec des profils synergiques et des correspondances cosmiques spéciales.';

  @override
  String get onboardingFinalTitle => 'Tout est prêt...';

  @override
  String get onboardingFinalSub =>
      'Vous êtes sur le point de découvrir ce que les stars ont prévu pour vous. Créez votre compte et entrez dans l\'univers cosmique.';

  @override
  String get onboardingAppleCreate => 'Créer un compte avec Apple';

  @override
  String get onboardingGoogleCreate => 'Créer un compte avec Google';

  @override
  String get onboardingErrorIncomplete =>
      'Accueillir! Plus que quelques étapes pour compléter votre profil.';

  @override
  String get onboardingErrorFailed =>
      'La connexion a échoué. Veuillez réessayer.';

  @override
  String onboardingErrorAlreadyExists(String provider) {
    return 'Vous avez déjà un profil cosmique avec ce compte$provider! Veuillez utiliser l\'option « Connexion » sur la première page.';
  }

  @override
  String onboardingErrorDBRejected(String error) {
    return 'Inscription rejetée par la base de données :${error}Veuillez contacter l\'assistance.';
  }

  @override
  String get onboardingErrorHandleTaken =>
      'Ce nom d\'utilisateur est déjà pris';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifSubtitle =>
      'Choisissez les notifications que vous souhaitez recevoir';

  @override
  String get notifAnnouncements => 'Annonces';

  @override
  String get notifAnnouncementsDesc =>
      'Nouvelles fonctionnalités et mises à jour';

  @override
  String get notifSounds => 'Des sons';

  @override
  String get notifSoundsDesc => 'Alertes de notification sonore';

  @override
  String get notifCookieAlarm => 'Nouvelle alarme de cookies';

  @override
  String get notifCookieAlarmDesc => 'Quand un nouveau biscuit chinois arrive';

  @override
  String get notifFriendAlarm => 'Alarme ami';

  @override
  String get notifFriendAlarmDesc => 'Nouvelles connexions du réseau Owl';

  @override
  String get notifDailyReminder => 'Rappels quotidiens';

  @override
  String get notifDailyReminderDesc => 'N\'oubliez pas votre cookie quotidien';

  @override
  String get accountTitle => 'Détails du compte';

  @override
  String get accountSubtitle =>
      'Informations personnelles et gestion du compte';

  @override
  String get accountUsername => 'Nom d\'utilisateur';

  @override
  String get accountLinkedEmail => 'E-mail lié';

  @override
  String get accountSignInMethod => 'Méthode de connexion';

  @override
  String get accountDeleteTitle => 'Supprimer le compte';

  @override
  String get accountDeleteDesc =>
      'Toutes vos données seront définitivement supprimées.\nCette action ne peut pas être annulée.';

  @override
  String get accountDeleteCancel => 'Annuler';

  @override
  String get accountDeleteConfirm => 'Supprimer';

  @override
  String get accountDeletePermanent => 'Supprimer le compte définitivement';

  @override
  String get welcomeTagline => 'La magie est en vous.';

  @override
  String get welcomeAppleContinue => 'Continuer avec Apple';

  @override
  String get welcomeGoogleContinue => 'Continuer avec Google';

  @override
  String get moodGuideTitle => 'Guide de l\'humeur';

  @override
  String get moodAwarenessTitle => 'Conscience émotionnelle';

  @override
  String get moodAwarenessDesc =>
      'Choisir votre humeur rend vos sentiments concrets ; c\'est la première étape pour trouver l\'équilibre intérieur et la conscience de soi.';

  @override
  String get moodCosmicTitle => 'Fréquence cosmique';

  @override
  String get moodCosmicDesc =>
      'Chaque émotion que vous choisissez sur la roue porte une fréquence. L\'aura de l\'écran s\'aligne directement sur vos sentiments.';

  @override
  String get moodHowToTitle => 'Comment utiliser ?';

  @override
  String get moodHowToDesc =>
      'Faites simplement tourner la roue et choisissez l’expression qui reflète le mieux votre humeur. Ne jugez pas vos sentiments, ressentez-les et acceptez-les.';

  @override
  String get moodQuestionAlt => 'Comment est ton humeur aujourd\'hui ?';

  @override
  String get moodSpinHint =>
      'Faites tourner la roue, choisissez votre humeur ✨';

  @override
  String get bentoCoffeeTitle => 'Lecture de café';

  @override
  String get bentoCoffeeDesc => 'Murmures de motifs';

  @override
  String get bentoUnexplored => 'Ce domaine attend d\'être exploré...';

  @override
  String get bentoSealed => 'Scellé';

  @override
  String get horoscopeDailyEnergy => 'L\'énergie d\'aujourd\'hui';

  @override
  String get horoscopeWestern => 'Ast occidental.';

  @override
  String get horoscopeAsian => 'Sagesse asiatique';

  @override
  String get horoscopeMayan => 'Esprit Maya';

  @override
  String get shareSaved => 'Enregistré ✓';

  @override
  String get shareDownload => 'Télécharger';

  @override
  String get shareShare => 'Partager';

  @override
  String get shareStory => 'Histoire';

  @override
  String get sharePost => 'Poste';

  @override
  String get shareCookieText =>
      'C\'est ce que j\'ai reçu du fortune cookie aujourd\'hui ! 🥠✨\n#CrackWish';

  @override
  String get shareCoffeeTitle => 'Lecture de café';

  @override
  String get cookieLockedTitle => 'Ce cookie spécial est verrouillé';

  @override
  String get cookieComingSoon => 'À venir ✨';

  @override
  String get dreamWaitOrReturn =>
      'Vous pouvez attendre ici ou retourner à la page d\'accueil. Nous vous informerons lorsqu\'il sera prêt et vous pourrez le lire dans la section « Mes rêves ».';

  @override
  String get dreamReturnHome => 'Retour à la page d\'accueil';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get profileEditSubtitle =>
      'Modifier le nom, le zodiaque et les informations personnelles';

  @override
  String get profileSearchHint =>
      'Rechercher un zodiaque, une ville ou une date de naissance...';

  @override
  String get profileStoreUnavailable =>
      'Le lien du magasin n\'est pas disponible.';

  @override
  String get profileMailNotFound =>
      'Aucune application de messagerie trouvée. Vous pouvez écrire à support@crackandwish.com';

  @override
  String get profileRitualCode => 'Code rituel';

  @override
  String get profileRitualDesc =>
      'Ce code est votre identité rituelle personnelle. Partagez-le avec vos amis pour les inviter au réseau Owl.';

  @override
  String get profileRitualCopied => 'Code rituel copié ✨';

  @override
  String get profileRitualInfo => 'Partagez avec vos amis, explorez ensemble !';

  @override
  String get profileShareCode => 'Partager le code';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileDeleteDesc =>
      'Toutes vos données seront définitivement supprimées.\nCette action ne peut pas être annulée.';

  @override
  String get profileDeleteCancel => 'Annuler';

  @override
  String get profileDeleteConfirm => 'Supprimer le compte';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileSignOutDesc =>
      'Déconnectez-vous de votre compte en toute sécurité.\nVos données seront conservées.';

  @override
  String get profileSignOutCancel => 'Annuler';

  @override
  String get profileSignOutConfirm => 'Se déconnecter';

  @override
  String get profilePrivacyPolicy => 'politique de confidentialité';

  @override
  String get profileTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get profileGetElite => 'Obtenez Élite';

  @override
  String get profileGetEliteSubtitle => 'Porte vers la conscience';

  @override
  String get profileCosmicProfile => 'Profil cosmique';

  @override
  String get profileCosmicSubtitle => 'Graphique, heure et lieu';

  @override
  String get profileSectionAccount => 'Compte';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileNotificationSettings => 'Paramètres de notification';

  @override
  String get profileRestorePurchases => 'Restaurer les achats';

  @override
  String get profileRestoreSuccess => 'Achats restaurés avec succès !';

  @override
  String get profileRestoreFail => 'Aucun achat trouvé à restaurer.';

  @override
  String get profileHelp => 'Aide';

  @override
  String get profileShare => 'Partager';

  @override
  String get profileRate => 'Taux';

  @override
  String get profileVersion => 'Version';

  @override
  String get profileCosmicName => 'Nom cosmique';

  @override
  String get profileSealProfile => 'Profil de joint';

  @override
  String get profileChooseAvatar => 'Choisissez votre avatar magique.';

  @override
  String get profileStrengthenBonds => 'Renforcer les liens';

  @override
  String get profileStrengthenBondsDesc =>
      'Développez l\'univers cosmique avec des amis.';

  @override
  String get profileEarnSoulStones => 'Gagnez +2 pierres d\'âme';

  @override
  String get profileCodeCopied => 'Code copié !';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileSupportExperience => 'Assistance et expérience';

  @override
  String get profileSeerNovice => 'Voyant novice';

  @override
  String get profileSeerApprentice => 'Apprenti voyant';

  @override
  String get profileSeer => 'Voyant';

  @override
  String get profileSeerWise => 'Voyant sage';

  @override
  String get profileSeerMaster => 'Maître Voyant';

  @override
  String get profileSeerCosmic => 'Voyant cosmique';

  @override
  String get profileUploadFailed =>
      'Le téléchargement des photos a échoué ! Veuillez vérifier votre connexion.';

  @override
  String get profileCropTitle => 'Culture cosmique';

  @override
  String get profileCropCancel => 'Annuler';

  @override
  String get profileCropDone => 'Fait';

  @override
  String get moderationAdultContent =>
      'L\'énergie de cette image n\'est pas compatible avec notre univers Cosmique (Contenu Inapproprié).';

  @override
  String get moderationViolence =>
      'Veuillez choisir un avatar plus calme qui reflète votre aura et ne fatigue pas l\'esprit (Contenu dérangeant).';

  @override
  String get moderationTooLarge =>
      'L’image est suffisamment grande pour mettre à rude épreuve le réseau cosmique. Veuillez sélectionner une photo de moins de 5 Mo.';

  @override
  String get moderationInvalidFormat =>
      'Votre photo n\'a pas pu être lue par notre parchemin magique, le format est corrompu.';

  @override
  String get moderationUnknown =>
      'Une fluctuation cosmique inconnue s\'est produite.';

  @override
  String profileShareInvite(String code) {
    return 'Rejoignez l\'univers Crack&Wish ! ✨\nMon code rituel :${code}Entrez ce code pour gagner +1 Soul Stone, +50 Aura et un Cookie Premium surprise !\nhttps://crackandwish.com';
  }

  @override
  String get profileShareApp =>
      'Découvrez votre fortune avec Crack&Wish ! •✨\nCassez des cookies, lisez le tarot, interprétez les rêves.\n\nhttps://crackandwish.com';

  @override
  String get profileEliteYouAre => 'Vous êtes l\'élite';

  @override
  String get profileGoElite => 'Passez à l\'élite';

  @override
  String get profileEliteMystical => 'Voir les portes mystiques';

  @override
  String get profileEliteDoor => 'Porte vers la conscience';

  @override
  String get profileMyCosmicProfile => 'Mon profil cosmique';

  @override
  String get profileCosmicDetails =>
      'Détails du graphique, de l\'heure et du lieu';

  @override
  String get profileRestorePurchasesBtn => 'Restaurer les achats';

  @override
  String get profileRestoreSubtitle => 'Restaurez vos achats précédents';

  @override
  String get profileInviteFriends => 'Inviter des amis';

  @override
  String get profileInviteFriendsDesc =>
      'Construisez des liens cosmiques, gagnez ensemble';

  @override
  String get cosmicChart => 'Carte cosmique';

  @override
  String get cosmicWestern => 'OCCIDENTAL';

  @override
  String get cosmicAsian => 'ASIATIQUE';

  @override
  String get cosmicMayan => 'MAYA';

  @override
  String get cosmicRising => 'SOULÈVEMENT';

  @override
  String get cosmicArrivalDate => 'DATE D\'ARRIVÉE';

  @override
  String get cosmicBirthTime => 'HEURE DE NAISSANCE';

  @override
  String get cosmicTimeUnknown => 'Heure inconnue';

  @override
  String get cosmicBirthPlace => 'COORDONNÉES DU LIEU DE NAISSANCE';

  @override
  String get cosmicCountry => 'Pays';

  @override
  String get cosmicSelectCountry => 'Sélectionnez un pays';

  @override
  String get cosmicCityDistrict => 'Ville & Quartier & Village';

  @override
  String get cosmicSelectDateFirst =>
      'Veuillez d\'abord sélectionner votre date de naissance.';

  @override
  String cosmicLockedDays(int days) {
    return 'Verrouillé pendant${days}jours';
  }

  @override
  String get cosmicSave => 'Sauvegarder';

  @override
  String get cosmicSearchLocation => 'Rechercher l\'emplacement exact';

  @override
  String get cosmicSearchHint => 'Entrez le village, le quartier, etc...';

  @override
  String get cosmicAddFreeText => 'Ajouter sous forme de texte libre';

  @override
  String get cosmicRequiresTime => 'Nécessite du temps';

  @override
  String get badgeReady => 'PRÊT';

  @override
  String get badgeNew => 'NOUVEAU';

  @override
  String get paywallLegal =>
      'Crack Wish Elite est un abonnement à renouvellement automatique. Le paiement sera débité de votre compte lors de la confirmation de l\'achat. L\'abonnement se renouvelle automatiquement sauf annulation au moins 24 heures avant la fin de la période en cours. Vous pouvez gérer et annuler vos abonnements dans les paramètres de votre App Store.';

  @override
  String get cosmicSelect => 'Sélectionner';

  @override
  String get coffeeRelSingle => 'Âme célibataire';

  @override
  String get coffeeRelInLove => 'Le coeur est plein';

  @override
  String get coffeeRelEngaged => 'Engagé';

  @override
  String get coffeeRelMarried => 'Marié';

  @override
  String get coffeeRelComplicated => 'Compliqué';

  @override
  String get coffeeFocusLove => 'Amour et Harmonie';

  @override
  String get coffeeFocusCareer => 'Carrière et finances';

  @override
  String get coffeeFocusHealing => 'Guérison et paix';

  @override
  String get coffeeFocusGeneral => 'Avenir général';

  @override
  String get coffeeFocusSurprise => 'Surprenez-moi';

  @override
  String get coffeeMoodPeaceful => 'Pacifique';

  @override
  String get coffeeMoodExcited => 'Excité';

  @override
  String get coffeeMoodAnxious => 'Anxieux';

  @override
  String get coffeeMoodIndecisive => 'Indécis';

  @override
  String get coffeeMoodEnergetic => 'Énergique';

  @override
  String get coffeeMoodMelancholic => 'Mélancolique';

  @override
  String get coffeeAllPhotosRequired =>
      'S\'il vous plaît, prenez toutes les photos !';

  @override
  String get coffeeNotEnoughStones => 'Pas assez de pierres d’âme !';

  @override
  String coffeeSoulStoneCount(int count) {
    return '${count}Pierres d\'âme disponibles';
  }

  @override
  String get coffeeUseSoulStone => 'Utilisez 1 pierre d\'âme';

  @override
  String get languageSettingsSubtitle => 'Choisir la langue de l\'application';

  @override
  String get cosmicSearchHintShort => 'Recherche...';

  @override
  String get cosmicAddThis => 'Ajoutez ceci';

  @override
  String get horoscopeWesternText =>
      'Les étoiles s’alignent pour votre carrière. Prenez des mesures rapides et décisives.';

  @override
  String get horoscopeAsianText =>
      'L’élément eau est actif. Votre intuition est forte, écoutez simplement votre cœur.';

  @override
  String get horoscopeMayanText =>
      'La tonalité 4 est active. Une journée parfaite pour établir l’ordre et planifier votre vie.';

  @override
  String get horoscopeExplore => 'Explorer';

  @override
  String get cookieDayCompleted => 'Journée terminée';

  @override
  String get cookieSeeYouTomorrow => 'A demain avec de nouveaux cookies.';

  @override
  String get cookieRarityLegendary => 'Légendaire';

  @override
  String get cookieRarityRare => 'Rare';

  @override
  String get cookiePremiumCollection => 'Collection Premium';

  @override
  String cookiePurchaseBtn(String price) {
    return 'Achat ($price)';
  }

  @override
  String get cookieTapOutsideToClose => 'Appuyez à l\'extérieur pour fermer';

  @override
  String get cookieAddedToCollection =>
      'Cookie ajouté avec succès à votre collection !';

  @override
  String get cookiePremiumFallback => 'Biscuit premium';

  @override
  String get dreamSoulStoneRequired => 'Pierre d\'âme requise';

  @override
  String get dreamSoulStoneRequiredDesc =>
      'Les pierres d’âme sont nécessaires pour une analyse approfondie.\n\nVous pouvez gagner des Soul Stones en convertissant des points Aura ou avec un abonnement Elite.';

  @override
  String get dreamGetElite => 'Obtenez Élite';

  @override
  String get dreamClinicalGateTitle => 'Porte d\'analyse clinique';

  @override
  String dreamClinicalGateDesc(int soulStones) {
    return 'Pierres d\'âme actuelles :${soulStones}Cette psychanalyse profonde de niveau clinique coûte 1 pierre d’âme.';
  }

  @override
  String get dreamUseOneStone => 'Utilisez 1 pierre';

  @override
  String get dreamDeepAnalysisBgPreparing =>
      'Une analyse approfondie est en cours de préparation en arrière-plan. Vous recevrez une notification lorsqu\'il sera prêt.';

  @override
  String get dreamYourSoulStones => 'Vos pierres d\'âme';

  @override
  String dreamSoulStonesRemaining(int count) {
    return '${count}Pierres d\'âme restantes';
  }

  @override
  String get dreamSoulStonesEmpty => 'À court de pierres d\'âme';

  @override
  String get dreamRequiredForDeep => 'Requis pour une analyse approfondie';

  @override
  String get dreamEachAnalysisCost => 'Chaque analyse coûte 1 Pierre d\'Âme';

  @override
  String get dreamEliteRefillActive =>
      'Elite recharge 5 pierres d\'âme tous les soirs';

  @override
  String get dreamEliteRefillPromo =>
      'Obtenez 5 pierres d\'âme quotidiennes avec Elite';

  @override
  String get dreamWatchAd => 'Regarder l\'annonce';

  @override
  String get dreamBgAnalyzing =>
      'Votre rêve est analysé en arrière-plan. Vous recevrez une notification lorsqu\'il sera prêt.';

  @override
  String get dreamDeepAnalysis => 'Analyse approfondie';

  @override
  String get dreamDiscoverSecrets => 'Découvrez des secrets';

  @override
  String get dreamDidYouKnow => 'Saviez-vous?';

  @override
  String get dreamNeuroPsychAnalysis => 'ANALYSE NEURO-PSYQUE';

  @override
  String get dreamYourDream => 'VOTRE RÊVE';

  @override
  String get dreamEmotionalProfile => 'Profil émotionnel';

  @override
  String get dreamEmotionalProfileSub =>
      'Couches psychologiques pendant le rêve';

  @override
  String get dreamShadowSelf => 'Soi de l\'ombre';

  @override
  String get dreamShadowSelfSub =>
      'Aspects refoulés et non examinés du subconscient';

  @override
  String get dreamRecurringPatterns => 'Modèles récurrents';

  @override
  String get dreamRecurringPatternsSub =>
      'Boucles récurrentes et blocages psychologiques';

  @override
  String dreamSuggestedRitual(String title) {
    return 'Rituel suggéré :$title';
  }

  @override
  String get dreamSuggestedRitualSub =>
      'Une action spécialisée pour gérer l\'impact de ce rêve';

  @override
  String get dreamScienceNote => 'Note scientifique :';

  @override
  String get dreamWriteNewDream => 'Écrivez un nouveau rêve';

  @override
  String get dreamNoMonthDreams =>
      'Aucun rêve écrit pour l\'instant ce mois-ci ✨';

  @override
  String get dreamMysteriousDream => 'Rêve mystérieux';

  @override
  String get dreamStandardAnalysis => 'ANALYSE STANDARD';

  @override
  String get dreamGeneralAnalysis => 'Analyse générale';

  @override
  String get dreamPsychological => 'Psychologique';

  @override
  String get dreamSpiritual2 => 'Spirituel';

  @override
  String get dreamAdvice => 'Conseil';

  @override
  String get dreamDeepenedInsights => 'Informations approfondies';

  @override
  String get dreamEliteCreditsTitle => 'Crédits Élite';

  @override
  String get dreamReadingCreditsTitle => 'Vos crédits de lecture';

  @override
  String dreamCreditsRemaining(int count) {
    return '${count}crédits restants';
  }

  @override
  String get dreamDailyLimitReached => 'Limite quotidienne atteinte';

  @override
  String get dreamZeroCredits => '0 crédits restants';

  @override
  String dreamDailyPremiumReads(int count) {
    return '${count}Interprétations quotidiennes des rêves';
  }

  @override
  String get dreamNoAdsRequired => 'Pas besoin de regarder des publicités';

  @override
  String get dreamCreditsResetNightly =>
      'Les crédits sont réinitialisés chaque nuit';

  @override
  String get dreamOneFreeDaily => '1 interprétation gratuite chaque jour';

  @override
  String dreamWatchAdsForCredits(int maxAds, int watched) {
    return 'Regardez des publicités pour${maxAds}crédits supplémentaires ($watched/$maxAds)';
  }

  @override
  String get dreamUnconsciousFrequencies => 'FRÉQUENCES INCONSCIENTES';

  @override
  String get dreamOrbEmotion => 'ÉMOTION';

  @override
  String get dreamOrbEntropy => 'ENTROPIE';

  @override
  String get dreamOrbActivity => 'ACTIVITÉ';

  @override
  String get dreamOrbResidue => 'RÉSIDU';

  @override
  String get dreamHighConfidence => 'Haute confiance';

  @override
  String get dreamModerateConfidence => 'Confiance modérée';

  @override
  String get dreamLowConfidence => 'Faible confiance';

  @override
  String get dreamCoreThematicPattern => 'MODÈLE THÉMATIQUE DE BASE';

  @override
  String get dreamMetricEmotionalLoad => 'Émotionnel\nCharger';

  @override
  String get dreamMetricEmotionalLoadDesc =>
      'Avec quelle intensité le centre émotionnel de votre cerveau a été activé pendant ce rêve.';

  @override
  String get dreamMetricUncertaintyDesc =>
      'À quel point le récit de votre rêve était illogique ou incohérent.';

  @override
  String get dreamMetricRecentMemory => 'Récent\nConnexion';

  @override
  String get dreamMetricRecentMemoryDesc =>
      'Dans quelle mesure votre rêve a-t-il été influencé par des événements réels récents.';

  @override
  String get dreamMetricAgency => 'Agence /\nContrôle';

  @override
  String get dreamMetricAgencyDesc =>
      'Quel contrôle vous aviez sur les événements de votre rêve.';

  @override
  String get dreamSeverityHigh => 'Haut';

  @override
  String get dreamSeverityNormal => 'Normale';

  @override
  String get dreamSeverityLow => 'Faible';

  @override
  String get dreamCognitiveDistribution => 'DISTRIBUTION COGNITIVE';

  @override
  String get dreamTapToExpand => 'APPUYEZ POUR DÉVELOPPER';

  @override
  String get dreamNeurologicalBasis => 'Base neurologique';

  @override
  String get dreamEvidenceBase => 'BASE DE PREUVES';

  @override
  String get dreamRootCause => 'Cause première';

  @override
  String get dreamAbsolutely => 'Absolument';

  @override
  String get dreamMaybe => 'Peut être';

  @override
  String get dreamNotSure => 'Pas sûr';

  @override
  String get dreamDreamEssence => 'ESSENCE DE RÊVE';

  @override
  String get dreamClarifyingResponses => 'RÉPONSES CLARIFIANTES';

  @override
  String get dreamCosmicRhythmSynced => 'Rythme cosmique synchronisé';

  @override
  String get dreamCosmicRhythmSyncedDesc =>
      'Vous recevrez des invites de rêve personnalisées en fonction de votre cycle de sommeil.';

  @override
  String get dreamSyncSleepData => 'Synchroniser les données de sommeil';

  @override
  String get dreamSyncSleepDataDesc =>
      'Permettez-lui de détecter votre réveil pour vous poser des questions sur votre rêve le plus profond.';

  @override
  String get dreamAwarenessFallback =>
      'Cette prise de conscience est le début d’un nouveau chemin. Il est temps d\'y faire face.';

  @override
  String get dreamExtractingEssence => 'Extraire l\'essence du rêve...';

  @override
  String get dreamNoReasoning => 'Aucun raisonnement généré.';

  @override
  String get dreamNotAnalyzable =>
      'Es-tu sûr que c\'était un rêve ?\nVeuillez décrire une scène réelle que vous avez vécue pendant votre sommeil.';

  @override
  String get owlTabFriends => 'Mes amis';

  @override
  String get owlTabConnections => 'Relations';

  @override
  String get owlTabInbox => 'Boîte de réception';

  @override
  String get owlSearchCosmic => 'Rechercher l\'univers cosmique...';

  @override
  String get owlSearchFriends => 'Rechercher des amis...';

  @override
  String get owlPhoneContacts => 'Contacts téléphoniques';

  @override
  String get owlNoOneFoundCosmic => 'Personne trouvé dans l\'univers cosmique.';

  @override
  String get owlFoundInCosmic => 'Trouvé dans l\'univers cosmique';

  @override
  String get owlUnknownProfile => 'Profil inconnu';

  @override
  String owlFriendRequestSent(String name) {
    return 'Demande d\'ami envoyée à$name!';
  }

  @override
  String get owlRequestSentStatus => 'Envoyé';

  @override
  String get owlSendRequestAction => 'Envoyer la demande';

  @override
  String get owlConnectContacts => 'Connecter les contacts';

  @override
  String get owlConnectContactsDesc =>
      'Trouvez vos amis instantanément.\nVos contacts ne sont JAMAIS stockés sur des serveurs.';

  @override
  String get owlNoContactsFound =>
      'Nous n\'avons trouvé personne\ndans l\'Univers Crack&Wish';

  @override
  String get owlNoContactsFoundDesc =>
      'Vous pouvez démarrer l\'énergie cosmique en les invitant !';

  @override
  String get owlUnknown => 'Inconnu';

  @override
  String get owlAppUserLabel => 'Utilisateur Crack&Wish';

  @override
  String get owlInContactsLabel => 'Dans vos contacts';

  @override
  String get owlNoFriendsYet => 'Pas encore d\'amis';

  @override
  String get owlNoResultsFound => 'Aucun résultat trouvé';

  @override
  String get owlFriendRequests => 'Demandes d\'amis';

  @override
  String get owlFriendsHeader => 'Vos amis';

  @override
  String get owlAcceptAction => 'Accepter';

  @override
  String get owlRejectAction => 'Rejeter';

  @override
  String get owlInviteReward => '+2 pierres d\'âme';

  @override
  String owlInviteShareMessage(String username) {
    return 'Ensemble, illuminons les ténèbres ! ✨\nRejoignez Crack Wish via mon lien d\'invitation ci-dessous, connectez-vous automatiquement et gagnez des Start Rewards !\n\nMon lien d\'invitation :\nhttps://crackwish.com/invite/$username';
  }

  @override
  String get owlInviteFriends => 'Inviter des amis';

  @override
  String get owlInviteFriendsDesc => 'Refléter l\'univers cosmique';

  @override
  String get owlNoLettersYet => 'Pas encore de lettres';

  @override
  String owlLetterSentNotification(String name) {
    return '${name}a envoyé une lettre...';
  }

  @override
  String get owlOnItsWay => 'La chouette est en route 🕊️';

  @override
  String owlLetterCount(int count) {
    return '${count}lettres';
  }

  @override
  String owlUnreadCountBadge(int count) {
    return '${count}Nouveau';
  }

  @override
  String get owlIUnderstand => 'Je comprends';

  @override
  String get owlInviteHowTitle => 'Comment souhaiteriez-vous inviter ?';

  @override
  String get owlInviteHowSubtitle =>
      'Comment souhaitez-vous envoyer votre clé cosmique à cette personne ?';

  @override
  String get owlInviteSendAsMessage => 'Envoyer comme message';

  @override
  String get owlInviteSMSSubtitle => 'Envoyer par message classique';

  @override
  String get owlInviteOtherApps => 'Autres applications';

  @override
  String get owlInviteOtherAppsSubtitle => 'Instagram, TikTok, X, etc.';

  @override
  String get owlWhatsAppNotFound => 'WhatsApp introuvable';

  @override
  String get owlSMSNotFound => 'Application SMS introuvable';

  @override
  String get owlDisconnectAction => 'Déconnecter';

  @override
  String owlDisconnectConfirm(String name) {
    return 'Etes-vous sûr de vouloir rompre le lien magique avec$name?';
  }

  @override
  String get owlDisconnectConfirmButton => 'Oui, déconnecter';

  @override
  String get owlCancel => 'Annuler';

  @override
  String get owlSendMagic => 'Envoyer (Charmé)';

  @override
  String get owlSend => 'Envoyer';

  @override
  String get owlCookieAdded => 'Cookie ajouté';

  @override
  String get owlAddCookie => 'Ajouter un cookie';

  @override
  String get owlNoCookiesInCollection => 'Aucun cookie dans votre collection';

  @override
  String get owlWriteLetterHint => 'Écrivez votre lettre...';

  @override
  String get owlSendCookie => 'Envoyer un cookie';

  @override
  String get zodiacMeasureHarmony => 'MESURER L\'HARMONIE COSMIQUE';

  @override
  String get zodiacDiscoverEnergy =>
      'Découvrez votre double énergie guidée par les étoiles';

  @override
  String get zodiacChooseFriend => 'CHOISISSEZ UN AMI';

  @override
  String get zodiacChooseFriendSubtitle =>
      'Sélectionnez un ami pour comparer vos énergies cosmiques';

  @override
  String get zodiacDiscoverYourself => 'Découvrez-vous';

  @override
  String get zodiacCharacteristicAnalysis => 'ANALYSE DES CARACTÉRISTIQUES';

  @override
  String zodiacAbilityMap(String name) {
    return 'Carte des capacités de$name';
  }

  @override
  String get zodiacPros => 'Avantages';

  @override
  String get zodiacCons => 'Défis';

  @override
  String get zodiacAdvice => 'Conseil';

  @override
  String get zodiacDailyWhisperSubtitle =>
      'Ressentez le murmure d\'aujourd\'hui et\npercez les secrets de votre portrait spirituel.';

  @override
  String get zodiacDailyWhisperHeadline =>
      'Message et portrait spirituel du jour';

  @override
  String get zodiacOpenGuide => 'Ouvrir le Guide';

  @override
  String get zodiacNoFriends => 'Pas encore d\'amis';

  @override
  String get zodiacSelect => 'SÉLECTIONNER';

  @override
  String get zodiacQuestCompleted => 'Quête terminée';

  @override
  String get zodiacQuestCompletedSubtitle =>
      'Vous êtes pleinement aligné sur le rythme de l’univers.';

  @override
  String get zodiacRewardAura => 'Récompense gagnée :\n+4 AURA';

  @override
  String get zodiacStartNewQuest => 'COMMENCER UNE NOUVELLE QUÊTE';

  @override
  String zodiacDailyQuestTitle(int days) {
    return '$days-QUÊTE JOUR';
  }

  @override
  String zodiacDailyQuestDesc(String weakness) {
    return 'Brisez votre faiblesse : \"$weakness\"';
  }

  @override
  String zodiacQuestDayProgress(int current, int total) {
    return 'JOUR$current/$total';
  }

  @override
  String get zodiacQuestTodayDiscovery => 'LA DÉCOUVERTE D\'AUJOURD\'HUI';

  @override
  String get zodiacQuestCompletedToday => 'TERMINÉ AUJOURD\'HUI';

  @override
  String get zodiacQuestCompleteNow => 'TERMINER LA QUÊTE MAINTENANT';

  @override
  String get zodiacQuestMarkCompleted => 'J\'AI TERMINÉ AUJOURD\'HUI';

  @override
  String get zodiacLoveHarmony => 'AMOUR HARMONIE';

  @override
  String get zodiacFriendshipHarmony => 'AMITIÉ';

  @override
  String get zodiacCommunicationHarmony => 'COMMUNICATION ET ESPRIT';

  @override
  String get zodiacWorkHarmony => 'COLLABORATION';

  @override
  String get zodiacAdventureHarmony => 'AVENTURE ET PLAISIR';

  @override
  String get zodiacViralDynamics => 'DYNAMIQUE VIRALE';

  @override
  String get zodiacDeepSynastryMap => 'CARTE DE SYNASTRIE PROFONDE';

  @override
  String zodiacSynastrySubtitle1(String name) {
    return 'L’harmonie entre vous et${name}ne se limite pas aux signes solaires.';
  }

  @override
  String get zodiacSynastrySubtitle2 =>
      'Basé sur la confidentialité, l\'algorithme cosmique croise les thèmes astrologiques, la Lune et les phases ascendantes en coulisses, ce qui rend cette analyse totalement unique pour vous.';

  @override
  String get zodiacDailyWhisperTitle => 'Le murmure du jour';

  @override
  String get zodiacChooseSign => 'CHOISISSEZ LE SIGNE';

  @override
  String get zodiacCosmicGuide => 'VOTRE GUIDE COSMIQUE';

  @override
  String get zodiacNew => 'NOUVEAU';

  @override
  String get zodiacCosmicHarmonyTitle => 'HARMONIE COSMIQUE';

  @override
  String get zodiacAwesome => 'GÉNIAL';

  @override
  String get zodiacSpiritPortrait => 'Portrait spirituel';

  @override
  String get onboardingFeatureStepTitle => 'Qu\'est-ce qui vous attend ?';

  @override
  String get onboardingFeatureStepSub =>
      'Êtes-vous prêt à écouter les murmures de l\'univers et à découvrir votre destin ?';

  @override
  String get onboardingNameStepTitle => 'Apprenons à vous connaître';

  @override
  String get onboardingNameStepSub =>
      'Créez votre profil et déterminez votre identité cosmique afin que vos âmes sœurs puissent vous trouver.';

  @override
  String get onboardingDateStepTitle => 'Coordonnée cosmique';

  @override
  String get onboardingDateStepSub =>
      'Choisissez le moment de votre naissance sur la base de votre thème astrologique.';

  @override
  String get onboardingFocusStepTitle => 'Boussole du cœur';

  @override
  String get onboardingFocusStepSub =>
      'Définissez votre intention, traçons votre chemin.';

  @override
  String get onboardingDreamStepTitle => 'Voix du subconscient';

  @override
  String get onboardingDreamStepSub =>
      'Comment vos rêves vous parviennent-ils ?';

  @override
  String get onboardingSleepStepTitle => 'Votre boussole intérieure';

  @override
  String get onboardingSleepStepSub =>
      'Comment s\'orienter lors des tournants du destin dans votre vie ?';

  @override
  String get onboardingFeatureAstrology => 'Tableau d\'astrologie personnalisé';

  @override
  String get onboardingFeatureTarot => 'Guider le voyage du tarot';

  @override
  String get onboardingFeatureCoffee =>
      'Anciens secrets de la divination du café';

  @override
  String get onboardingFeatureDream => 'Analyse des rêves subconscients';

  @override
  String get onboardingFeatureZodiac =>
      'Compatibilités mystiques chinoises et mayas';

  @override
  String get onboardingWelcomeTagline =>
      'Aujourd\'hui, mes espoirs sont plus grands que mes rêves.';

  @override
  String get onboardingFinalTagline =>
      'Cliquez pour sécuriser votre carte cosmique.';

  @override
  String get tarotShareText =>
      'Les cartes me parlaient ainsi ! 🔮✨\n#CrackWish #Tarot';

  @override
  String get natalChartTitle => 'Thème de naissance';

  @override
  String get natalChartCalculating => 'Calculer votre thème natal...';

  @override
  String get natalChartSwipeHint => 'Glissez pour inspecter';

  @override
  String get natalChartPlanetPositions => 'POSITIONS SUR LA PLANÈTE';

  @override
  String get natalChartAngularPoints => 'POINTS ANGULAIRES';

  @override
  String get natalChartAsc => 'ASC (Ascendant)';

  @override
  String get natalChartAscDesc =>
      'Le masque que vous montrez au monde extérieur, votre image et votre première impression.';

  @override
  String get natalChartMc => 'MC (Milieu du Ciel)';

  @override
  String get natalChartMcDesc =>
      'Votre carrière, votre image publique et vos objectifs de vie.';

  @override
  String get natalChartDc => 'DC (descendant)';

  @override
  String get natalChartDcDesc =>
      'Les traits fondamentaux que vous recherchez dans les relations, le mariage et les partenariats.';

  @override
  String get natalChartIc => 'IC (Imum Cœli)';

  @override
  String get natalChartIcDesc =>
      'Vos racines, votre famille, votre passé et votre sécurité fondamentale dans votre monde intérieur.';

  @override
  String get natalChartTabPersonality => 'Résumé de la personnalité principale';

  @override
  String get natalChartTabLove => 'Amour et relations';

  @override
  String get natalChartTabCareer => 'Carrière et argent';

  @override
  String get natalChartTabEmotional => 'Structure émotionnelle';

  @override
  String get natalChartTabStrengths => 'Forces et faiblesses';

  @override
  String natalChartHouse(String house) {
    return 'Maison$house';
  }

  @override
  String zodiacGreeting(String name) {
    return 'Bonjour$name,';
  }

  @override
  String get zodiacCosmicTraveler => 'Voyageur cosmique,';

  @override
  String get zodiacBirthDate => 'DATE DE NAISSANCE';

  @override
  String get zodiacStarsKnowYou => 'Que les étoiles te connaissent';

  @override
  String get zodiacConfirm => 'CONFIRMER';

  @override
  String get zodiacDiscoverYourselfBtn => 'DÉCOUVREZ-VOUS';

  @override
  String get zodiacEliteRequiredDesc =>
      'Vous avez besoin d’un abonnement Elite pour découvrir une profonde compatibilité astrologique et une dynamique virale avec vos amis.';

  @override
  String get zodiacEliteDiscoverBtn => 'Découvrez les privilèges Élite';

  @override
  String get zodiacHubWestern => 'ASTROLOGIE OCCIDENTALE';

  @override
  String get zodiacHubAsian => 'ASTROLOGIE ASIATIQUE';

  @override
  String get zodiacHubMayan => 'ASTROLOGIE MAYA';

  @override
  String get actionLater => 'Plus tard';

  @override
  String get coffeeViewReading => 'Voir la lecture';

  @override
  String get coffeeReadyTitleWithEmoji => '☕️ Votre lecture est prête !';

  @override
  String get wheelTask_w_c1 =>
      'Envoyer un message « je pense à toi » à un proche';

  @override
  String get wheelTask_w_c2 =>
      'Dites bonjour à quelqu\'un à qui vous n\'avez pas parlé depuis un moment';

  @override
  String get wheelTask_w_c3 =>
      'Dites à un membre de votre famille à quel point il est important aujourd\'hui';

  @override
  String get wheelTask_w_c4 => 'Félicitez quelqu\'un à côté de vous';

  @override
  String get wheelTask_w_c5 => 'Envoyez une vidéo amusante à un ami';

  @override
  String get wheelTask_w_c6 =>
      'Remerciez quelqu\'un aujourd\'hui et expliquez pourquoi';

  @override
  String get wheelTask_w_s1 =>
      'Regardez-vous dans le miroir, souriez-vous et maintenez pendant 10 secondes';

  @override
  String get wheelTask_w_s2 =>
      'Rappelez-vous la dernière fois que vous avez éclaté de rire et souriez à nouveau';

  @override
  String get wheelTask_w_s3 =>
      'Pensez à un souvenir amusant et riez aux éclats';

  @override
  String get wheelTask_w_s4 =>
      'Trouvez et regardez la photo la plus drôle sur votre téléphone';

  @override
  String get wheelTask_w_s5 => 'Souriez à la première personne que vous voyez';

  @override
  String get wheelTask_w_s6 =>
      'Pensez au moment le plus drôle que vous ayez vécu aujourd\'hui';

  @override
  String get wheelTask_w_m1 => 'Levez-vous et étirez-vous pendant 30 secondes';

  @override
  String get wheelTask_w_m2 =>
      'Faites le tour de votre chambre pendant 1 minute';

  @override
  String get wheelTask_w_m3 => 'Sautez 10 fois et dites « Je peux le faire ! »';

  @override
  String get wheelTask_w_m4 =>
      'Levez les bras et faites une pose de Superman pendant 20 secondes';

  @override
  String get wheelTask_w_m5 =>
      'Roulez vos épaules vers l’avant 5 fois, puis vers l’arrière 5 fois';

  @override
  String get wheelTask_w_m6 =>
      'Respirez profondément, ouvrez grand les bras et maintenez pendant 10 secondes';

  @override
  String get wheelTask_w_mu1 =>
      'Jouez votre chanson préférée et écoutez-la pendant 1 minute';

  @override
  String get wheelTask_w_mu2 =>
      'Jouez une chanson au hasard et écoutez les 30 premières secondes';

  @override
  String get wheelTask_w_mu3 =>
      'Chanter! Chante à haute voix comme si personne n\'écoutait';

  @override
  String get wheelTask_w_mu4 =>
      'Écoutez une chanson dans un genre que vous n\'avez pas exploré aujourd\'hui';

  @override
  String get wheelTask_w_mu5 =>
      'Fermez les yeux et écoutez les sons autour de vous pendant 30 secondes';

  @override
  String get wheelTask_w_mu6 =>
      'Tapez un rythme sur la table avec votre doigt pendant 15 secondes';

  @override
  String get wheelTask_w_g1 =>
      'Pensez à une chose que vous avez aujourd\'hui et dites « merci »';

  @override
  String get wheelTask_w_g2 =>
      'Comptez 3 petites choses qui vous rendent heureux';

  @override
  String get wheelTask_w_g3 =>
      'Pensez à la meilleure chose que vous avez mangée aujourd\'hui et souvenez-vous de son goût';

  @override
  String get wheelTask_w_g4 =>
      'Pensez au meilleur moment de votre vie pendant 10 secondes';

  @override
  String get wheelTask_w_g5 =>
      'Soyez reconnaissant pour votre santé. Respirez profondément.';

  @override
  String get wheelTask_w_g6 =>
      'Soyez reconnaissant que le soleil se soit levé aujourd\'hui';

  @override
  String get wheelTask_w_f1 => 'Sautez 3 fois et criez « Je peux le faire ! »';

  @override
  String get wheelTask_w_f2 =>
      'Faites votre grimace la plus drôle et maintenez-la pendant 5 secondes';

  @override
  String get wheelTask_w_f3 => 'Imitez un animal : quel animal seriez-vous ?';

  @override
  String get wheelTask_w_f4 =>
      'Fermez les yeux et imaginez que vous volez pendant 10 secondes';

  @override
  String get wheelTask_w_f5 =>
      'Prenez la pose de super-héros et maintenez-la pendant 5 secondes';

  @override
  String get wheelTask_w_f6 => 'Marchez comme un robot pendant 10 pas';

  @override
  String get zodiacAccessWesternAdTitle =>
      'Limite quotidienne gratuite atteinte';

  @override
  String get zodiacAccessWesternAdDesc =>
      'Vous pouvez regarder une courte publicité pour réintégrer l’astrologie occidentale.';

  @override
  String get zodiacAccessWatchAdBtn => 'Regarder l\'annonce';

  @override
  String get zodiacAccessGetEliteBtn => 'Obtenez Élite';

  @override
  String get zodiacAccessGateTitle => 'Porte de la sagesse cosmique';

  @override
  String zodiacAccessStoneCount(Object count) {
    return 'Vous avez${count}Pierres d\'âme';
  }

  @override
  String get zodiacAccessPremiumInfo1 =>
      'Autorisation d\'accès aux profondeurs du zodiaque';

  @override
  String get zodiacAccessPremiumInfo2 =>
      'Chaque thème astrologique consomme 1 pierre d\'âme';

  @override
  String get zodiacAccessPremiumInfo3Elite =>
      'Elite : Accès illimité avec 1 Soul Stone par jour';

  @override
  String get zodiacAccessPremiumInfo3Normal =>
      '1 Soul Stone suffit avec Elite par jour';

  @override
  String get zodiacAccessOneStoneBtn => '1 pierre d\'âme';

  @override
  String get onboardingTestSimulate =>
      'Mode test : simulation de la connexion à un ancien compte...';

  @override
  String get onboardingTestAnon => 'Mode test : connexion anonyme...';

  @override
  String onboardingGoogleLoginFailed(Object error) {
    return 'Échec de la connexion à Google :$error';
  }

  @override
  String onboardingAppleLoginFailed(Object error) {
    return 'Échec de la connexion Apple :$error';
  }

  @override
  String onboardingGoogleRegisterFailed(Object error) {
    return 'Échec de l\'enregistrement Google :$error';
  }

  @override
  String onboardingAppleRegisterFailed(Object error) {
    return 'Échec de l\'enregistrement Apple :$error';
  }

  @override
  String dreamDataError(Object error) {
    return 'Erreur de données enregistrées :$error';
  }

  @override
  String get onboardingBirthDateTitle => 'VOTRE DATE DE NAISSANCE';

  @override
  String get onboardingSelectBirthDate =>
      'Sélectionnez votre date de naissance';

  @override
  String get onboardingBirthTimeTitle => 'HEURE DE NAISSANCE (Facultatif)';

  @override
  String get onboardingBirthPlaceTitle => 'LIEU DE NAISSANCE (Facultatif)';

  @override
  String get onboardingPickerDateTitle => 'Sélectionnez la date de naissance';

  @override
  String get onboardingPickerTimeTitle => 'Sélectionnez l\'heure de naissance';

  @override
  String get onboardingPickerDone => 'Fait';

  @override
  String get onboardingLifeFocusSpiritual => 'Spirituel\nÉveil';

  @override
  String get onboardingLifeFocusCareer => 'Carrière et\nPouvoir personnel';

  @override
  String get onboardingLifeFocusLove => 'Amour et\nHarmonie cosmique';

  @override
  String get onboardingLifeFocusHealing => 'Guérison et\nPaix intérieure';

  @override
  String get onboardingLifeFocusWealth => 'Richesse et\nAbondance';

  @override
  String get onboardingLifeFocusSurprise => 'L\'univers\nDes surprises';

  @override
  String get onboardingDreamMessenger => 'Messager et rêves vifs';

  @override
  String get onboardingDreamChaotic => 'Événements surprenants et chaotiques';

  @override
  String get onboardingDreamCalm => 'Aussi calme que les nuages';

  @override
  String get onboardingSleepMindTitle => 'Lumière de l\'esprit';

  @override
  String get onboardingSleepMindDesc =>
      'J\'analyse les événements, je les pèse avec logique et je planifie des étapes concrètes.';

  @override
  String get onboardingSleepMindVal => 'Lumière de l\'esprit (logique)';

  @override
  String get onboardingSleepHeartTitle => 'Murmure du coeur';

  @override
  String get onboardingSleepHeartDesc =>
      'J\'écoute ma voix intérieure et je fais toujours confiance à mes sentiments plutôt qu\'à la logique.';

  @override
  String get onboardingSleepHeartVal => 'Murmure du cœur (Intuition)';

  @override
  String get onboardingSleepUniverseTitle => 'Flux de l\'Univers';

  @override
  String get onboardingSleepUniverseDesc =>
      'Je crois que tout arrive pour une raison et je suis les signes de l\'univers.';

  @override
  String get onboardingSleepUniverseVal => 'Flux de l\'Univers (Destin)';

  @override
  String get linkAccountTitle => 'Lier le compte';

  @override
  String get linkGoogleAccount => 'Lier le compte Google';

  @override
  String get linkAppleAccount => 'Lier le compte Apple';

  @override
  String get linkAccountStarted => 'Processus de liaison de compte démarré...';

  @override
  String get linkAccountFailed => 'Échec de la liaison du compte';

  @override
  String get profileSignOutGuestDesc =>
      'Avertissement : Si vous vous déconnectez d\'un compte invité, vous ne pourrez plus accéder à ce compte et toutes vos données (Pierres d\'Âme, lectures) seront PERDUES DÉFINITIVEMENT. Êtes-vous sûr de vouloir vous déconnecter ?';
}
