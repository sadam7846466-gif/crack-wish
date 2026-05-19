// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crack&Wish';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get systemLanguage => 'System';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String get close => 'Close';

  @override
  String languageValue(Object value) {
    return 'Selected: $value';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navCollection => 'Collection';

  @override
  String get navProfile => 'Profile';

  @override
  String get dailyCookieTitle => 'Daily Cookie';

  @override
  String get dailyCookieSubtitle => 'Tap to try your luck';

  @override
  String get luckyNumber => 'Lucky Number';

  @override
  String get luckyColor => 'Lucky Color';

  @override
  String get luckLabel => 'Luck';

  @override
  String get todayFortune => 'Today\'s Fortune';

  @override
  String get shareButton => '📸 Share';

  @override
  String fortuneShareText(
    Object emoji,
    Object title,
    Object meaning,
    Object number,
    Object color,
    Object percent,
  ) {
    return '$emoji $title\n\n$meaning\n\nLucky Number: $number\nLucky Color: $color\nLuck: $percent%\n\nFrom Fortune Cookie app 🥠';
  }

  @override
  String get themeSelectTitle => 'Select Theme';

  @override
  String themeSelected(Object value) {
    return 'Theme selected: $value';
  }

  @override
  String get themeGalleryTitle => 'Theme Gallery';

  @override
  String get themeGalleryOpen => 'Go to theme list';

  @override
  String get themeGalleryLimited =>
      'Theme gallery is currently limited to two options';

  @override
  String get statCookies => 'Cookies';

  @override
  String get statStreakDays => 'Streak Days';

  @override
  String get statDreams => 'Dreams';

  @override
  String get statMood => 'Mood';

  @override
  String get statTheme => 'Today...';

  @override
  String get statCollection => 'My Cookie';

  @override
  String get statTalisman => 'Talisman';

  @override
  String get moodGood => 'Good';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodBad => 'Bad';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodGreat => 'Great';

  @override
  String get shortcutCollection => 'Collection';

  @override
  String get shortcutHistory => 'History';

  @override
  String get shortcutFavorites => 'Favorites';

  @override
  String get sectionShortcuts => 'Shortcuts';

  @override
  String get sectionActivity => 'Activity';

  @override
  String get menuBadges => 'Badges';

  @override
  String get menuBadgesSubtitle => 'Achievements and levels';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSettingsSubtitle => 'Notifications, theme, privacy';

  @override
  String get menuHelpAbout => 'Help & About';

  @override
  String get menuHelpAboutSubtitle => 'FAQ and version info';

  @override
  String get menuShare => 'Share';

  @override
  String get menuShareSubtitle => 'Share your profile with friends';

  @override
  String get activityTarotOpenedTitle => 'Tarot reading opened';

  @override
  String get activityTarotOpenedSubtitle => 'Today • Card: Star';

  @override
  String activityCookiesOpenedTitle(Object count) {
    return '$count cookies cracked';
  }

  @override
  String get activityCookiesOpenedSubtitle => 'Yesterday • New messages opened';

  @override
  String get activityDreamSavedTitle => 'Dream interpretation saved';

  @override
  String get activityDreamSavedSubtitle => '2 days ago';

  @override
  String get profileUserTitle => 'User';

  @override
  String get profileSubtitle => 'Less noise, more you';

  @override
  String get tagTarot => 'Tarot';

  @override
  String get tagDream => 'Dream';

  @override
  String get tagCollection => 'Collection';

  @override
  String get zodiacTitle => '⭐ Zodiac Reading';

  @override
  String zodiacDailyTitle(Object name) {
    return '$name - Daily Reading';
  }

  @override
  String get zodiacDailyBody =>
      'You\'re lucky in love this week! Career opportunities are at your door—keep your eyes open. Your energy is high, use it. It\'s a perfect time for new projects. Your communication skills are at their peak, take advantage of it.';

  @override
  String get zodiacLove => 'Love';

  @override
  String get zodiacCareer => 'Career';

  @override
  String get zodiacMoney => 'Money';

  @override
  String get zodiacHealth => 'Health';

  @override
  String get collectionTitle => 'Your Collection';

  @override
  String get collectionSubtitle => 'Traces and rewards of your daily ritual';

  @override
  String get collectionNotYet => 'Not yet';

  @override
  String get collectionFirstTime => 'First time';

  @override
  String get collectionTotalOpened => 'Total';

  @override
  String get collectionCookieDescription =>
      'This cookie adds luck and small surprises to your ritual. The more you open, the stronger your collection becomes.';

  @override
  String get collectionSummaryTitle => 'Collection Summary';

  @override
  String get collectionSummaryTypes => 'Unique types';

  @override
  String get collectionSummaryTotalOpened => 'Total opened';

  @override
  String get collectionSummaryRare => 'Rare';

  @override
  String get collectionSummaryFooter =>
      'Every cookie has a story. The more you open, the richer it gets.';

  @override
  String get rarityAll => 'All';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get collectionUndiscovered => 'Undiscovered';

  @override
  String get collectionNotFoundYet => 'Luck hasn\'t brought you here... yet.';

  @override
  String get collectionEmptyTitle => 'You haven\'t opened any cookies yet';

  @override
  String collectionEmptySubtitle(Object count) {
    return '$count different cookies are waiting for you. Open today\'s cookie to start your collection.';
  }

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverSubtitle => 'Explore new features';

  @override
  String get discoverCategories => 'Categories';

  @override
  String get categoryTarotTitle => 'Tarot Reading';

  @override
  String get categoryTarotDesc => '3-Card Tarot';

  @override
  String get categoryDreamTitle => 'Dream Interpretation';

  @override
  String get categoryDreamDesc => 'Uncover the meaning of your dreams';

  @override
  String get categoryZodiacTitle => 'Zodiac Reading';

  @override
  String get categoryZodiacDesc => 'Message from the stars';

  @override
  String get categoryPersonalityTitle => 'Personality Test';

  @override
  String get categoryPersonalityDesc => '16 Personalities';

  @override
  String get discoverDailySuggestionTitle => 'TODAY\'S SUGGESTION';

  @override
  String get discoverDailySuggestionHeadline =>
      'Did you have a dream last night?';

  @override
  String get discoverDailySuggestionSubtitle =>
      'Interpret it now and learn its meaning!';

  @override
  String get dailySuggestionDreamHeadline => 'Did you have a dream last night?';

  @override
  String get dailySuggestionDreamSubtitle =>
      'Interpret it now and learn its meaning!';

  @override
  String get dailySuggestionTarotHeadline =>
      'Have you checked your tarot today?';

  @override
  String get dailySuggestionTarotSubtitle =>
      'Pick 3 cards and see your message!';

  @override
  String get dailySuggestionZodiacHeadline =>
      'Checked your zodiac reading yet?';

  @override
  String get dailySuggestionZodiacSubtitle => 'See today\'s energy right away!';

  @override
  String get dailySuggestionCoffeeHeadline => 'Did you drink coffee today?';

  @override
  String get dailySuggestionCoffeeSubtitle =>
      'Turn your cup over, let\'s read your fortune!';

  @override
  String get dailySuggestionAllDoneHeadline => 'Today\'s rituals are complete!';

  @override
  String get dailySuggestionAllDoneSubtitle =>
      'Come back tomorrow for new content.';

  @override
  String get discoverFeaturedTag => 'FEATURED';

  @override
  String get discoverFeaturedTitle => '3-Card Tarot Reading';

  @override
  String get discoverFeaturedSubtitle =>
      'Explore your past, present, and future';

  @override
  String get ctaStart => 'Start';

  @override
  String get homeGreeting => 'Hello! 👋';

  @override
  String get homeFeeling => 'How are you feeling today?';

  @override
  String get quoteOfDayText =>
      'The smallest step you take today leads to the biggest victory tomorrow.';

  @override
  String get quoteOfDaySource => '— Quote of the Day';

  @override
  String get dailyHoroscopeTitle => 'Aries';

  @override
  String get dailyHoroscopeSubtitle => 'Today\'s Reading';

  @override
  String get dailyHoroscopeBody =>
      'You\'re lucky in love this week! Career opportunities are at your door—keep your eyes open. Your energy is high, use it.';

  @override
  String get aries => 'Aries';

  @override
  String get bentoTarotTitle => 'Tarot';

  @override
  String get bentoTarotDesc => 'See your future';

  @override
  String get bentoTarotBadge => 'POPULAR';

  @override
  String get bentoDreamTitle => 'Dream';

  @override
  String get bentoDreamDesc => 'Explore your subconscious';

  @override
  String get bentoDreamBadge => 'NEW';

  @override
  String get bentoMotivationTitle => 'Mood';

  @override
  String get bentoMotivationDesc => 'Discover your mood';

  @override
  String get bentoMotivationBadge => 'DAILY';

  @override
  String get bentoZodiacTitle => 'Zodiac';

  @override
  String get bentoZodiacDesc => 'Message from the stars';

  @override
  String get bentoZodiacBadge => 'DAILY';

  @override
  String get moodQuestion => 'How are you today?';

  @override
  String get dreamTitle => 'Tell Your Dream';

  @override
  String get dreamTabNew => 'New Dream';

  @override
  String get dreamTabHistory => 'My Dreams';

  @override
  String get dreamAnalyzeButton => 'Interpret Dream';

  @override
  String get dreamAnalyzeEstimate => '~ 5 sec';

  @override
  String get dreamInterpretationTitle => 'Dream Interpretation';

  @override
  String get dreamNoHistory => 'You don\'t have any saved dreams yet';

  @override
  String get dreamDefaultTitle => 'Dream';

  @override
  String get dreamSpiritual => 'Spiritual';

  @override
  String get dreamEnriched => 'Enriched Interpretation';

  @override
  String get dreamEnriching => 'Enriching...';

  @override
  String get dreamEnrich => 'Enrich';

  @override
  String get dreamShare => 'Share';

  @override
  String get dreamAnalyzing => 'Analyzing dream...';

  @override
  String get dreamAnalysisFailed =>
      'Unable to generate an interpretation right now.';

  @override
  String get dreamClarifyThreat =>
      'Was there a sense of threat or fear in the dream?';

  @override
  String get dreamClarifyFamiliar =>
      'Did this scene feel familiar from the past?';

  @override
  String get dreamClarifyEscape => 'Was there a sense of movement or escape?';

  @override
  String get dreamClarifyAnxious =>
      'Did you feel anxiety or threat in the dream?';

  @override
  String get dreamUnsure => 'Not sure';

  @override
  String get dreamYes => 'Yes';

  @override
  String get dreamNo => 'No';

  @override
  String get dreamGeneral => 'General Dream';

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
    return 'Dream Title: $title\nDate: $date\n\nDream: $text\n\nGeneral: $general\nPsychological: $psychology\nSpiritual: $spiritual\nAdvice: $advice\n\n#VLucky #Dream';
  }

  @override
  String get scientificTitle => 'Scientific Dream Analysis';

  @override
  String get scientificDreamPromptTitle => 'Tell Your Dream';

  @override
  String get scientificDreamHint => 'Write your dream as you remember it...';

  @override
  String get scientificEmotionQuestion => 'How did you feel when you woke up?';

  @override
  String get scientificEmotionHint => 'Choose one emotion';

  @override
  String get scientificClarityQuestion => 'How clear was the dream?';

  @override
  String get scientificDisclaimer =>
      'This analysis is based on psychology and neuroscience research. It does not provide definitive or predictive results.';

  @override
  String get scientificLoading =>
      'Evaluating based on REM sleep and neuroscience';

  @override
  String get scientificResultsTitle => 'Dream Interpretation';

  @override
  String get scientificRecentPastTitle => 'Recent Past Effects';

  @override
  String get scientificSaved => 'Dream saved';

  @override
  String get scientificSaveButton => 'Save Dream';

  @override
  String get cookieSpringWreath => 'Spring Wreath';

  @override
  String get cookieLuckyClover => 'Lucky Clover';

  @override
  String get cookieRoyalHearts => 'Royal Hearts';

  @override
  String get cookieEvilEye => 'Evil Eye';

  @override
  String get cookiePizzaParty => 'Pizza Party';

  @override
  String get cookieSakuraBloom => 'Sakura Bloom';

  @override
  String get cookieBluePorcelain => 'Blue Porcelain';

  @override
  String get cookiePinkBlossom => 'Pink Blossom';

  @override
  String get cookieFortuneCat => 'Fortune Cat';

  @override
  String get cookieWildflower => 'Wildflower';

  @override
  String get cookieCupidRibbon => 'Cupid Ribbon';

  @override
  String get cookiePandaBamboo => 'Panda Bamboo';

  @override
  String get cookieRamadanCute => 'Ramadan';

  @override
  String get cookieEnchantedForest => 'Enchanted Forest';

  @override
  String get cookieGoldenArabesque => 'Golden Arabesque';

  @override
  String get cookieMidnightMosaic => 'Midnight Mosaic';

  @override
  String get cookiePearlLace => 'Pearl Lace';

  @override
  String get cookieGoldenSakura => 'Golden Sakura';

  @override
  String get cookieDragonPhoenix => 'Dragon Phoenix';

  @override
  String get cookieGoldBeasts => 'Gold Beasts';

  @override
  String get emotionAnxiety => 'Anxious';

  @override
  String get emotionFear => 'Afraid';

  @override
  String get emotionCalm => 'Calm';

  @override
  String get emotionHappy => 'Happy';

  @override
  String get emotionSad => 'Sad';

  @override
  String get emotionConfusion => 'Uncertain';

  @override
  String get emotionSurprise => 'Surprised';

  @override
  String get dreamMoodQuestion => 'How did you feel when you woke up?';

  @override
  String get dreamMetricEmotional => 'Emotional Load';

  @override
  String get dreamMetricUncertainty => 'Uncertainty';

  @override
  String get dreamMetricRecentPast => 'Recent Past';

  @override
  String get dreamMetricBrain => 'Brain Activity';

  @override
  String get tarotShuffleHint => 'Drag in a circle to shuffle';

  @override
  String get tarotEnergyDepletedTitle => 'Energy Depleted';

  @override
  String get tarotEnergyDepletedBody =>
      'Your daily cosmic energy is depleted.\nRecharge to see the truth.';

  @override
  String get tarotEnergyDepletedSub =>
      'Your selected cards are ready, just one step left...';

  @override
  String get tarotWatchAd => 'Watch Ad & Open';

  @override
  String tarotFreeRemaining(Object count) {
    return 'Free remaining today: $count';
  }

  @override
  String get socialFeedTitle => 'Quiet Feed';

  @override
  String get feedTypeCookie => 'Cookie';

  @override
  String get feedTagDailyCookie => 'Today\'s cookie';

  @override
  String get feedTypeTarot => 'Tarot';

  @override
  String get feedTagThreeCard => '3-card draw';

  @override
  String get feedTypeDream => 'Dream';

  @override
  String get feedTagDreamMode => 'Dream mode';

  @override
  String get feedTypeZodiac => 'Zodiac';

  @override
  String get feedTagDailyEnergy => 'Daily energy';

  @override
  String get feedTypeMotivation => 'Motivation';

  @override
  String get feedTagMiniAction => 'Mini action';

  @override
  String inviteShareMessage(String handle, String link) {
    return 'Are you ready for a mystical journey? I am waiting for you in the Crack&Wish universe! ✨\n\nMy invite code: $handle\nDownload Now: $link';
  }

  @override
  String get inviteShareSubject => 'Crack&Wish Invite';

  @override
  String get inviteSendButton => 'Invite';

  @override
  String get inviteConnectButton => 'Connect';

  @override
  String get inviteSentText => 'Sent';

  @override
  String inviteRequestSent(String name) {
    return 'Request sent to $name!';
  }

  @override
  String get toastCoffeeReadyTitle => 'Your Reading is Ready!';

  @override
  String get toastCoffeeReadyMessage =>
      'The secrets in your cup have been revealed.';

  @override
  String get toastViewButton => 'View';

  @override
  String get toastDreamReadyTitle => 'Your Dream is Interpreted!';

  @override
  String get toastDreamReadyMessage =>
      'The messages of your subconscious have been decoded.';

  @override
  String get toastCoffeeReadyTitle2 => 'Your Coffee Reading is Ready!';

  @override
  String get dreamFallbackTitle => 'Dream Interpretation';

  @override
  String get rewardWelcomeTitle => 'Welcome to the Universe';

  @override
  String get rewardWelcomeDesc =>
      'We left a small gift for you to start your journey.';

  @override
  String get rewardReferralFallback => 'A friend';

  @override
  String get rewardReferralReceiverTitle => 'An Unexpected Gift';

  @override
  String rewardReferralReceiverDesc(String inviter) {
    return '$inviter invited you here and left a welcome gift for you.';
  }

  @override
  String get rewardInviterTitle => 'Your Call Was Heard!';

  @override
  String rewardInviterDescSingle(String name) {
    return '$name joined the universe. You\'ve been rewarded for being a guide.';
  }

  @override
  String rewardInviterDescMultiple(String name, int count) {
    return '$name and $count more friends joined the universe. You\'ve been rewarded for being a guide.';
  }

  @override
  String rewardInviterDescGeneric(int count) {
    return '$count friends joined the universe. You\'ve been rewarded for being a guide.';
  }

  @override
  String birthdayTitleWithName(String name) {
    return 'Happy Birthday, $name!';
  }

  @override
  String get birthdayTitle => 'Happy Birthday!';

  @override
  String get birthdayDesc =>
      'Today is the sacred day your soul came into this world. The universe left a special gift for you.';

  @override
  String get cookieReminderTitle => 'You Didn\'t Crack a Cookie Today';

  @override
  String get cookieReminderMessage => 'Your daily fortune message is waiting!';

  @override
  String get cookieReminderReward => '3 Left';

  @override
  String achievementRewardStones(int count) {
    return '+$count Soul Stones';
  }

  @override
  String achievementRewardAura(int count) {
    return '+$count Aura';
  }

  @override
  String get rankUpTitle => 'Cosmic Promotion!';

  @override
  String rankUpMessage(String rank) {
    return 'Your aura power increased. New title: $rank';
  }

  @override
  String get rankNovice => 'Novice Seer';

  @override
  String get rankApprentice => 'Apprentice Seer';

  @override
  String get rankSeer => 'Seer';

  @override
  String get rankWise => 'Wise Seer';

  @override
  String get rankMaster => 'Master Seer';

  @override
  String get rankCosmic => 'Cosmic Seer';

  @override
  String get loginSubtitle =>
      'Synchronize with your soul\'s guide.\nRemember your past, future, and subconscious.';

  @override
  String get loginAppleContinue => 'Continue with Apple';

  @override
  String get loginAppleSignIn => 'Sign in with Apple';

  @override
  String get loginGoogleContinue => 'Continue with Google';

  @override
  String get loginGoogleSignIn => 'Sign in with Google';

  @override
  String get loginGoogleFailed => 'Google Sign-In Failed';

  @override
  String get loginAppleFailed => 'Apple Sign-In Failed';

  @override
  String get loginNoAccountYet => 'Haven\'t joined the universe yet?  ';

  @override
  String get loginHaveAccount => 'Already have an account?  ';

  @override
  String get loginSignUp => 'Sign Up';

  @override
  String get loginSignIn => 'Sign In';

  @override
  String get loginLegalPrefix => 'By continuing, you agree to our ';

  @override
  String get loginTermsOfUse => 'Terms of Use';

  @override
  String get loginLegalAnd => ' and ';

  @override
  String get loginPrivacyPolicy => 'Privacy Policy';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get homeSubtitle1 => 'Crack, Read, Smile.';

  @override
  String get homeSubtitle2 => 'Luck in your pocket.';

  @override
  String get homeSubtitle3 => 'Today\'s message: You.';

  @override
  String get homeSubtitle4 => 'One crack, one surprise.';

  @override
  String get homeSubtitle5 => 'A small cookie, a big feeling.';

  @override
  String get homeSubtitle6 => 'Not fate, just a sweet hint.';

  @override
  String get homeSubtitle7 => 'What does your luck say today?';

  @override
  String get homeSubtitle8 => 'Open, discover, move on.';

  @override
  String get homeSubtitle9 => 'Luck is one tap away.';

  @override
  String get homeSubtitle10 => 'A new beginning with every crack.';

  @override
  String get homeSubtitle11 => 'Find your message.';

  @override
  String get homeSubtitle12 => 'Not random… just for you.';

  @override
  String get homeSubtitle13 => 'Crack your luck, seize your day.';

  @override
  String get homeSubtitle14 => 'Tiny prophecies that make you smile.';

  @override
  String get homeSubtitle15 => 'Surprises do you good.';

  @override
  String get homeMilestoneTitle => 'Incredible Focus!';

  @override
  String homeMilestoneMessage(int count) {
    return 'Your daily streak reached $count days.';
  }

  @override
  String homeMilestoneSoulStone(int count) {
    return '+$count Soul Stones';
  }

  @override
  String get homeGreetingMorning => 'Good Morning';

  @override
  String get homeGreetingAfternoon => 'Good Afternoon';

  @override
  String get homeGreetingEvening => 'Good Evening';

  @override
  String get homeGreetingNight => 'Good Night';

  @override
  String get homeTimeSubMorning => 'Fresh message with your coffee.';

  @override
  String get homeTimeSubAfternoon => 'A magical break in your day.';

  @override
  String get homeTimeSubEvening => 'A sweet prophecy to unwind.';

  @override
  String get homeTimeSubNight => 'The stars shine for you tonight.';

  @override
  String get paywallSubtitleElite =>
      'Your cosmic awareness is already open.\nStrengthen your enlightenment by upgrading your plan.';

  @override
  String get paywallSubtitleNew =>
      'Open the door to cosmic awareness.\nRemove all limits.';

  @override
  String get paywallFeature1 => '5 Fresh Soul Stones Daily';

  @override
  String get paywallFeature2 => 'Master Analysis Mode';

  @override
  String get paywallFeature3 => 'x3 Fast Aura Gain';

  @override
  String get paywallFeature4 => 'Unlimited Clinical Archive';

  @override
  String get paywallFeature5 => 'Ad-Free Seamless Experience';

  @override
  String get paywallPackageWeekly => 'Weekly Awakening';

  @override
  String get paywallPackageMonthly => 'Monthly Intuition';

  @override
  String get paywallPackageYearly => 'Yearly Enlightenment';

  @override
  String get paywallBtnCurrentPlan => 'Current Plan';

  @override
  String get paywallBtnManage => 'Manage from Store';

  @override
  String get paywallBtnUpgrade => 'Upgrade Plan';

  @override
  String get paywallBtnSubscribe => 'Unlock Elite';

  @override
  String get paywallSuccessUpgradeTitle => 'Enlightenment Upgraded';

  @override
  String get paywallSuccessTitle => 'Welcome to Enlightenment';

  @override
  String get paywallSuccessUpgradeSubtitle =>
      'Your plan has been successfully upgraded.';

  @override
  String get paywallSuccessSubtitle =>
      'You are now an Elite member. Cosmic limits have been removed for you.';

  @override
  String get paywallErrorTitle => 'Connection Error';

  @override
  String get paywallErrorMessage =>
      'Could not connect to the store or the transaction was canceled. Products may not yet be published on the App Store/Play Console. Please try again later.';

  @override
  String get paywallRestoreSuccess => 'Elite Restored';

  @override
  String get paywallRestoreSuccessSubtitle =>
      'Welcome back to cosmic awareness. Your limits have been removed.';

  @override
  String get paywallRestoreNoSub => 'No Active Subscription';

  @override
  String get paywallRestoreNoSubMessage =>
      'No active Crack Wish Elite membership found to restore. Please review the packages.';

  @override
  String get paywallRestore => 'Restore Purchases';

  @override
  String get paywallCurrentPlanBadge => 'CURRENT PLAN';

  @override
  String get paywallLegalTr =>
      'Crack Wish Elite is an auto-renewing subscription. Payment will be charged to your account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. You can manage and cancel your subscriptions in your App Store settings.';

  @override
  String get paywallOk => 'OK';
}
