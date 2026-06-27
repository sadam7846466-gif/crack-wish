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
  String get dreamYes => 'YES';

  @override
  String get dreamNo => 'NO';

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
  String get dreamMetricUncertainty => 'Narrative\nUncertainty';

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

  @override
  String get coffeeLoading1 => 'Diving into the depths of the cup...';

  @override
  String get coffeeLoading2 =>
      'Symbols in the grounds are aligning with universal energy...';

  @override
  String get coffeeLoading3 => 'Your fate lines are being mapped...';

  @override
  String get coffeeLoading4 => 'Secrets are being revealed...';

  @override
  String get coffeeAiError =>
      'AI encountered an error while interpreting the reading.';

  @override
  String get coffeeGenericError => 'Something went wrong. Please try again.';

  @override
  String get coffeeNotifReady =>
      'You\'ll be notified when your reading is ready';

  @override
  String get coffeeCheckHistory => '  button to view it';

  @override
  String get coffeeWaitOrExplore => 'Wait here or explore the app';

  @override
  String get coffeeGoHome => 'Go to Home';

  @override
  String get coffeeSections => 'Cup Sections';

  @override
  String get coffeeSectionInside => 'Inside the Cup';

  @override
  String get coffeeSectionInsideDesc =>
      'Your inner world, thoughts, emotional state.';

  @override
  String get coffeeSectionEdge => 'Cup Edge';

  @override
  String get coffeeSectionEdgeDesc =>
      'Near future, news, messages, encounters.';

  @override
  String get coffeeSectionBottom => 'Cup Bottom';

  @override
  String get coffeeSectionBottomDesc =>
      'Lingering past issues, burdens, unresolved matters.';

  @override
  String get coffeeSectionSaucer => 'Saucer';

  @override
  String get coffeeSectionSaucerDesc => 'Wish, outcome, fate, final energy.';

  @override
  String get coffeeLoadingComment => 'Loading interpretation...';

  @override
  String get coffeeStoryTitle => 'The Story Told by the Grounds';

  @override
  String get coffeeSymbolsTitle => 'Symbols Seen in Your Reading';

  @override
  String get coffeeLove => 'Love & Relationships';

  @override
  String get coffeeCareer => 'Career & Finance';

  @override
  String get coffeeFamily => 'Family & Close Circle';

  @override
  String get coffeeNearFuture => 'Near Future';

  @override
  String get coffeeClosing => 'Final Words of Your Reading';

  @override
  String get coffeeShare => 'Share My Reading';

  @override
  String get coffeeRetryValidation => 'Go Back & Retake';

  @override
  String get coffeeRetry => 'Try Again';

  @override
  String get coffeeCancel => 'Cancel';

  @override
  String get coffeeSymbolLabel => 'Symbol';

  @override
  String get coffeeSymbolLoading => 'Loading...';

  @override
  String get coffeeTimelineSoon => 'Very Soon';

  @override
  String get coffeeImageError =>
      'Unable to detect clear coffee grounds in this image.';

  @override
  String get coffeeCosmicTitle => 'Cosmic Coffee Reading';

  @override
  String get coffeePremiumOnly => 'Premium Feature Only';

  @override
  String get coffeePremiumDesc =>
      'Coffee Reading is exclusive to elite members. Upgrade to Premium and uncover the secrets of your future with your Soul Stones.';

  @override
  String get coffeePremiumSimBtn => 'Go Premium (Simulation)';

  @override
  String get coffeePhotoSource => 'Photo Source';

  @override
  String get coffeeCamera => 'Camera';

  @override
  String get coffeeGallery => 'Gallery';

  @override
  String get coffeeStepCupInside => 'Inside the Cup';

  @override
  String get coffeeStepCupInsideDesc =>
      'Position the camera directly above the cup and capture the coffee grounds inside.';

  @override
  String get coffeeStepLeftProfile => 'Left Profile';

  @override
  String get coffeeStepLeftProfileDesc =>
      'Hold the cup by its handle and take a clear photo of just the left side.';

  @override
  String get coffeeStepRightProfile => 'Right Profile';

  @override
  String get coffeeStepRightProfileDesc =>
      'Now capture the right rear side of the cup from a well-lit angle.';

  @override
  String get coffeeStepSaucerSecret => 'Saucer\'s Secret';

  @override
  String get coffeeStepSaucerDesc =>
      'Finally, capture the saucer\'s wide surface with the grounds clearly visible.';

  @override
  String get coffeeStepSaucerBtn => 'Take Saucer Photo';

  @override
  String get coffeeHeaderTitle => 'COFFEE READING';

  @override
  String get coffeeLastReading => 'Your Last Reading';

  @override
  String coffeeLastReadingTime(String time) {
    return 'At $time • Expires at midnight';
  }

  @override
  String get coffeeNoReadingYet =>
      'You haven\'t had a reading yet.\nBrew a cup of coffee,\nand let the grounds whisper to you.';

  @override
  String get coffeeSoulStones => 'Your Soul Stones';

  @override
  String get coffeeSoulStoneEmpty => 'No Soul Stones left';

  @override
  String get coffeeSoulStoneRequired => 'Required for coffee reading analysis';

  @override
  String get coffeeSoulStoneCost => 'Each reading costs 1 Soul Stone';

  @override
  String get coffeeSoulStoneEliteActive =>
      'Elite perk: 5 Soul Stones refresh every night';

  @override
  String get coffeeSoulStoneElitePromo =>
      'Go Elite to earn 5 Soul Stones nightly';

  @override
  String get coffeeEliteSubscribe => 'Subscribe to Elite';

  @override
  String get coffeeRitualLabel => 'RITUAL';

  @override
  String get coffeeRitualTitle => 'Secrets of the Cup';

  @override
  String get coffeeRitualDesc =>
      'The grounds only speak to those who look closely. Follow the ritual for a true reading.';

  @override
  String get coffeeRitualStep1Title => 'Set Your Intention';

  @override
  String get coffeeRitualStep1Desc =>
      'As you sip, let a question or wish flow through your mind.';

  @override
  String get coffeeRitualStep2Title => 'Sip from One Side';

  @override
  String get coffeeRitualStep2Desc =>
      'Always drink from the same side to preserve the patterns.';

  @override
  String get coffeeRitualStep3Title => 'Flip It Over';

  @override
  String get coffeeRitualStep3Desc =>
      'Turn the cup upside down, let it cool, and gently open it.';

  @override
  String get coffeeRitualListenTitle => 'Listen to the Grounds\' Whisper';

  @override
  String coffeeStepLabel(String index, String title) {
    return 'Step $index: $title';
  }

  @override
  String get coffeeDiscoverFate => 'Discover Your Fate';

  @override
  String get coffeeNextStep => 'Next Step';

  @override
  String get coffeeCapture => 'Capture This Angle';

  @override
  String get coffeeValidationError =>
      'The grounds in the marked photos\ncould not be clearly identified.';

  @override
  String get coffeeCosmicMismatch => 'Cosmic Mismatch';

  @override
  String get coffeeCosmicCheck => 'COSMIC BOND CHECK';

  @override
  String get coffeeCosmicCheckDesc =>
      'Decoding the language of the grounds,\nlistening to fate\'s whispers...';

  @override
  String get coffeeRevealSecrets => 'Lift the Veil of Secrets';

  @override
  String get coffeeReadingInProgress => 'Reading the Grounds...';

  @override
  String get coffeeReadingWait =>
      'The doors of the future are opening, hold on.';

  @override
  String get coffeeRelationTitle => 'Your Relationship Status';

  @override
  String get coffeeRelationSubtitle =>
      'Set the foundation of your cosmic bond.';

  @override
  String get coffeeFocusTitle => 'What\'s on Your Mind?';

  @override
  String get coffeeFocusSubtitle =>
      'Choose an intention to deepen your reading.';

  @override
  String get coffeeMoodTitle => 'Your Mood?';

  @override
  String get coffeeMoodSubtitle => 'Feel the energy of your cup.';

  @override
  String get coffeeCosmicBondFormed => 'Cosmic Bond Formed';

  @override
  String get coffeeSecretsReady =>
      'The secrets of your cup are ready to be whispered...';

  @override
  String get coffeeNewReading => 'New Reading';

  @override
  String get coffeeAiPermission => 'AI coffee analysis permission';

  @override
  String get coffeeStoneCostInfo => 'Each analysis costs 1 Soul Stone';

  @override
  String get coffeeEliteRefillActive =>
      'Elite perk: 5 Soul Stones refresh every night';

  @override
  String get coffeeEliteRefillPromo => 'Go Elite to earn 5 Soul Stones nightly';

  @override
  String get coffeeEliteGetBtn => 'Get Elite';

  @override
  String get coffeeResultOnHome => 'View the result on the home page  ';

  @override
  String get onboardingStart => 'Let\'s Begin';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingContinueWithoutAccount => 'Continue without Account';

  @override
  String get onboardingFinish => 'Start Journey';

  @override
  String get onboardingNameHint => 'A Cosmic Name';

  @override
  String get onboardingNamePlaceholder => 'first_last';

  @override
  String get onboardingHandleHint => 'A Cosmic Handle';

  @override
  String get onboardingHandlePlaceholder => 'galaxy_traveler';

  @override
  String get onboardingGenderTitle => 'Gender';

  @override
  String get onboardingGenderFemale => 'Female';

  @override
  String get onboardingGenderMale => 'Male';

  @override
  String get onboardingGenderOther => 'Prefer not to say';

  @override
  String get onboardingStep1Title => 'What should we call you?';

  @override
  String get onboardingStep1Sub =>
      'By what name and vibration should the universe know you?';

  @override
  String get onboardingAvatarSelect => 'Select Your Avatar';

  @override
  String get onboardingStep2Title => 'The moment your soul entered...';

  @override
  String get onboardingStep2Sub =>
      'We need your basic details to calculate your astrological birth chart and personalized rituals.';

  @override
  String get onboardingBirthDateLabel => 'Birth Date';

  @override
  String get onboardingBirthTimeLabel => 'Birth Time';

  @override
  String get onboardingBirthLocationLabel => 'Birth City';

  @override
  String get onboardingTimeHint =>
      'If you know the exact time, enter for detailed analysis';

  @override
  String get onboardingLocationHint =>
      'Refine the calculation by selecting a city';

  @override
  String get onboardingUnknownTime => 'I don\'t know the exact time';

  @override
  String get onboardingPrivacyNote =>
      'Used exclusively to draw your personalized chart.';

  @override
  String get onboardingStep3Title => 'What is your focus?';

  @override
  String get onboardingStep3Sub =>
      'Which energy do you most want to grow or heal in your life right now?';

  @override
  String get onboardingFocusLabel => 'Focus (Multiple Choice)';

  @override
  String get onboardingFocusCareer => 'Career & Money';

  @override
  String get onboardingFocusLove => 'Love & Relationships';

  @override
  String get onboardingFocusPeace => 'Inner Peace';

  @override
  String get onboardingFocusLuck => 'Luck & Opportunities';

  @override
  String get onboardingRelLabel => 'Current relationship status:';

  @override
  String get onboardingRelSingle => 'Lonely Sky';

  @override
  String get onboardingRelComplicated => 'There\'s Someone...';

  @override
  String get onboardingRelTalking => 'Complicated';

  @override
  String get onboardingRelRelationship => 'Happy Bond';

  @override
  String get onboardingStep4Title =>
      'Your connection to the universe at night...';

  @override
  String get onboardingStep4Sub =>
      'How does your subconscious receive messages? Colors and dreams will give us clues.';

  @override
  String get onboardingDreamLabel => 'How often do you remember your dreams?';

  @override
  String get onboardingDreamOften => 'Often and Clearly';

  @override
  String get onboardingDreamSometimes => 'Sometimes';

  @override
  String get onboardingDreamRarely => 'Rarely';

  @override
  String get onboardingDreamNever => 'Never';

  @override
  String get onboardingAuraLabel =>
      'Your Soul\'s Aura (How do you feel today?)';

  @override
  String get onboardingStep5Title => 'Your dance with time...';

  @override
  String get onboardingStep5Sub =>
      'When is your energy highest? We will adjust your notifications accordingly.';

  @override
  String get onboardingSleepLabel => 'Your Sleep Pattern';

  @override
  String get onboardingSleepMorning => 'Morning Person';

  @override
  String get onboardingSleepNight => 'Night Owl';

  @override
  String get onboardingSleepIrregular => 'Irregular';

  @override
  String get onboardingSleepLittle => 'I Sleep Very Little';

  @override
  String get onboardingMatchLabel => 'Matching & Cosmic Connection';

  @override
  String get onboardingMatchDesc =>
      'I want to be open to connecting with synergistic profiles and special cosmic matches.';

  @override
  String get onboardingFinalTitle => 'Everything is ready...';

  @override
  String get onboardingFinalSub =>
      'You are about to find out what the stars have planned for you. Create your account and enter the cosmic universe.';

  @override
  String get onboardingAppleCreate => 'Create Account with Apple';

  @override
  String get onboardingGoogleCreate => 'Create Account with Google';

  @override
  String get onboardingErrorIncomplete =>
      'Welcome! Just a few steps left to complete your profile.';

  @override
  String get onboardingErrorFailed => 'Login failed. Please try again.';

  @override
  String onboardingErrorAlreadyExists(String provider) {
    return 'You already have a cosmic profile with this $provider account! Please use the \'Sign In\' option on the first page.';
  }

  @override
  String onboardingErrorDBRejected(String error) {
    return 'Registration rejected by the database:\n$error\nPlease contact support.';
  }

  @override
  String get onboardingErrorHandleTaken => 'This username is already taken';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifSubtitle => 'Choose which notifications you want to receive';

  @override
  String get notifAnnouncements => 'Announcements';

  @override
  String get notifAnnouncementsDesc => 'New features and updates';

  @override
  String get notifSounds => 'Sounds';

  @override
  String get notifSoundsDesc => 'Sound notification alerts';

  @override
  String get notifCookieAlarm => 'New Cookie Alarm';

  @override
  String get notifCookieAlarmDesc => 'When a new fortune cookie arrives';

  @override
  String get notifFriendAlarm => 'Friend Alarm';

  @override
  String get notifFriendAlarmDesc => 'New connections from the Owl Network';

  @override
  String get notifDailyReminder => 'Daily Reminders';

  @override
  String get notifDailyReminderDesc => 'Don\'t forget your daily cookie';

  @override
  String get accountTitle => 'Account Details';

  @override
  String get accountSubtitle => 'Personal info and account management';

  @override
  String get accountUsername => 'Username';

  @override
  String get accountLinkedEmail => 'Linked Email';

  @override
  String get accountSignInMethod => 'Sign-in Method';

  @override
  String get accountDeleteTitle => 'Delete Account';

  @override
  String get accountDeleteDesc =>
      'All your data will be permanently deleted.\nThis action cannot be undone.';

  @override
  String get accountDeleteCancel => 'Cancel';

  @override
  String get accountDeleteConfirm => 'Delete';

  @override
  String get accountDeletePermanent => 'Delete Account Permanently';

  @override
  String get welcomeTagline => 'The magic is within you.';

  @override
  String get welcomeAppleContinue => 'Continue with Apple';

  @override
  String get welcomeGoogleContinue => 'Continue with Google';

  @override
  String get moodGuideTitle => 'Mood Guide';

  @override
  String get moodAwarenessTitle => 'Emotional Awareness';

  @override
  String get moodAwarenessDesc =>
      'Choosing your mood makes your feelings concrete; this is the first step to finding inner balance and self-awareness.';

  @override
  String get moodCosmicTitle => 'Cosmic Frequency';

  @override
  String get moodCosmicDesc =>
      'Every emotion you pick on the wheel carries a frequency. The screen\'s aura aligns directly with your feelings.';

  @override
  String get moodHowToTitle => 'How to Use?';

  @override
  String get moodHowToDesc =>
      'Simply spin the wheel and pick the expression that best reflects your mood. Do not judge your feeling, just feel and accept it.';

  @override
  String get moodQuestionAlt => 'How\'s your mood today?';

  @override
  String get moodSpinHint => 'Spin the wheel, pick your mood ✨';

  @override
  String get bentoCoffeeTitle => 'Coffee Reading';

  @override
  String get bentoCoffeeDesc => 'Whispers of grounds';

  @override
  String get bentoUnexplored => 'This realm is waiting to be explored...';

  @override
  String get bentoSealed => 'Sealed';

  @override
  String get horoscopeDailyEnergy => 'Today\'s Energy';

  @override
  String get horoscopeWestern => 'Western Ast.';

  @override
  String get horoscopeAsian => 'Asian Wisdom';

  @override
  String get horoscopeMayan => 'Mayan Spirit';

  @override
  String get shareSaved => 'Saved ✓';

  @override
  String get shareDownload => 'Download';

  @override
  String get shareShare => 'Share';

  @override
  String get shareStory => 'Story';

  @override
  String get sharePost => 'Post';

  @override
  String get shareCookieText =>
      'This is what I got from the fortune cookie today! 🥠✨\n#CrackWish';

  @override
  String get shareCoffeeTitle => 'Coffee Reading';

  @override
  String get cookieLockedTitle => 'This special cookie is locked';

  @override
  String get cookieComingSoon => 'Coming Soon ✨';

  @override
  String get dreamWaitOrReturn =>
      'You can wait here or return to home page. We will notify you when it\'s ready, and you can read it from the \"My Dreams\" section.';

  @override
  String get dreamReturnHome => 'Return to Home Page';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileEditSubtitle => 'Edit name, zodiac and personal info';

  @override
  String get profileSearchHint => 'Search zodiac, city or birth date...';

  @override
  String get profileStoreUnavailable => 'Store link is unavailable.';

  @override
  String get profileMailNotFound =>
      'No mail app found. You can write to support@crackandwish.com';

  @override
  String get profileRitualCode => 'Ritual Code';

  @override
  String get profileRitualDesc =>
      'This code is your personal ritual identity. Share it with friends to invite them to the Owl Network.';

  @override
  String get profileRitualCopied => 'Ritual Code Copied ✨';

  @override
  String get profileRitualInfo => 'Share with friends, explore together!';

  @override
  String get profileShareCode => 'Share Code';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteDesc =>
      'All your data will be permanently deleted.\nThis action cannot be undone.';

  @override
  String get profileDeleteCancel => 'Cancel';

  @override
  String get profileDeleteConfirm => 'Delete Account';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutDesc =>
      'Sign out from your account safely.\nYour data will be preserved.';

  @override
  String get profileSignOutCancel => 'Cancel';

  @override
  String get profileSignOutConfirm => 'Sign Out';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileTermsOfUse => 'Terms of Use';

  @override
  String get profileGetElite => 'Get Elite';

  @override
  String get profileGetEliteSubtitle => 'Doorway to awareness';

  @override
  String get profileCosmicProfile => 'Cosmic Profile';

  @override
  String get profileCosmicSubtitle => 'Chart, Time and Location';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileNotificationSettings => 'Notification Settings';

  @override
  String get profileRestorePurchases => 'Restore Purchases';

  @override
  String get profileRestoreSuccess => 'Purchases restored successfully!';

  @override
  String get profileRestoreFail => 'No purchases found to restore.';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileShare => 'Share';

  @override
  String get profileRate => 'Rate';

  @override
  String get profileVersion => 'Version';

  @override
  String get profileCosmicName => 'Cosmic Name';

  @override
  String get profileSealProfile => 'Seal Profile';

  @override
  String get profileChooseAvatar => 'Choose your magical avatar.';

  @override
  String get profileStrengthenBonds => 'Strengthen Bonds';

  @override
  String get profileStrengthenBondsDesc =>
      'Expand the cosmic universe with friends.';

  @override
  String get profileEarnSoulStones => 'Earn +2 Soul Stones';

  @override
  String get profileCodeCopied => 'Code copied!';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileSupportExperience => 'Support & Experience';

  @override
  String get profileSeerNovice => 'Novice Seer';

  @override
  String get profileSeerApprentice => 'Apprentice Seer';

  @override
  String get profileSeer => 'Seer';

  @override
  String get profileSeerWise => 'Wise Seer';

  @override
  String get profileSeerMaster => 'Master Seer';

  @override
  String get profileSeerCosmic => 'Cosmic Seer';

  @override
  String get profileUploadFailed =>
      'Photo upload failed! Please check your connection.';

  @override
  String get profileCropTitle => 'Cosmic Crop';

  @override
  String get profileCropCancel => 'Cancel';

  @override
  String get profileCropDone => 'Done';

  @override
  String get moderationAdultContent =>
      'The energy of this image is not compatible with our Cosmic universe (Inappropriate Content).';

  @override
  String get moderationViolence =>
      'Please choose a calmer avatar that reflects your aura and does not weary the mind (Disturbing Content).';

  @override
  String get moderationTooLarge =>
      'The image is large enough to strain the cosmic network. Please select a photo under 5MB.';

  @override
  String get moderationInvalidFormat =>
      'Your photo could not be read by our magical scroll, format is corrupted.';

  @override
  String get moderationUnknown => 'An unknown cosmic fluctuation occurred.';

  @override
  String profileShareInvite(String code) {
    return 'Join the Crack&Wish universe! ✨\nMy Ritual Code: $code\n\nEnter this code to earn +1 Soul Stone, +50 Aura, and a surprise Premium Cookie!\nhttps://crackandwish.com';
  }

  @override
  String get profileShareApp =>
      'Discover your fortune with Crack&Wish! •✨\nCrack cookies, read tarot, interpret dreams.\n\nhttps://crackandwish.com';

  @override
  String get profileEliteYouAre => 'You are Elite';

  @override
  String get profileGoElite => 'Go Elite';

  @override
  String get profileEliteMystical => 'View mystical gates';

  @override
  String get profileEliteDoor => 'Door to awareness';

  @override
  String get profileMyCosmicProfile => 'My Cosmic Profile';

  @override
  String get profileCosmicDetails => 'Chart, Time, and Place Details';

  @override
  String get profileRestorePurchasesBtn => 'Restore Purchases';

  @override
  String get profileRestoreSubtitle => 'Restore your previous purchases';

  @override
  String get profileInviteFriends => 'Invite Friends';

  @override
  String get profileInviteFriendsDesc => 'Build cosmic bonds, earn together';

  @override
  String get cosmicChart => 'Cosmic Chart';

  @override
  String get cosmicWestern => 'WESTERN';

  @override
  String get cosmicAsian => 'ASIAN';

  @override
  String get cosmicMayan => 'MAYAN';

  @override
  String get cosmicRising => 'RISING';

  @override
  String get cosmicArrivalDate => 'ARRIVAL DATE';

  @override
  String get cosmicBirthTime => 'BIRTH TIME';

  @override
  String get cosmicTimeUnknown => 'Time Unknown';

  @override
  String get cosmicBirthPlace => 'BIRTH PLACE COORDINATES';

  @override
  String get cosmicCountry => 'Country';

  @override
  String get cosmicSelectCountry => 'Select Country';

  @override
  String get cosmicCityDistrict => 'City & District & Village';

  @override
  String get cosmicSelectDateFirst => 'Please select your birth date first.';

  @override
  String cosmicLockedDays(int days) {
    return 'Locked for $days Days';
  }

  @override
  String get cosmicSave => 'Save';

  @override
  String get cosmicSearchLocation => 'Search Exact Location';

  @override
  String get cosmicSearchHint => 'Enter village, district, etc...';

  @override
  String get cosmicAddFreeText => 'Add as free text';

  @override
  String get cosmicRequiresTime => 'Requires Time';

  @override
  String get badgeReady => 'READY';

  @override
  String get badgeNew => 'NEW';

  @override
  String get paywallLegal =>
      'Crack Wish Elite is an auto-renewing subscription. Payment will be charged to your account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. You can manage and cancel your subscriptions in your App Store settings.';

  @override
  String get cosmicSelect => 'Select';

  @override
  String get coffeeRelSingle => 'Single Soul';

  @override
  String get coffeeRelInLove => 'Heart is Full';

  @override
  String get coffeeRelEngaged => 'Engaged';

  @override
  String get coffeeRelMarried => 'Married';

  @override
  String get coffeeRelComplicated => 'Complicated';

  @override
  String get coffeeFocusLove => 'Love & Harmony';

  @override
  String get coffeeFocusCareer => 'Career & Finances';

  @override
  String get coffeeFocusHealing => 'Healing & Peace';

  @override
  String get coffeeFocusGeneral => 'General Future';

  @override
  String get coffeeFocusSurprise => 'Surprise Me';

  @override
  String get coffeeMoodPeaceful => 'Peaceful';

  @override
  String get coffeeMoodExcited => 'Excited';

  @override
  String get coffeeMoodAnxious => 'Anxious';

  @override
  String get coffeeMoodIndecisive => 'Indecisive';

  @override
  String get coffeeMoodEnergetic => 'Energetic';

  @override
  String get coffeeMoodMelancholic => 'Melancholic';

  @override
  String get coffeeAllPhotosRequired => 'Please take all photos!';

  @override
  String get coffeeNotEnoughStones => 'Not enough Soul Stones!';

  @override
  String coffeeSoulStoneCount(int count) {
    return '$count Soul Stones available';
  }

  @override
  String get coffeeUseSoulStone => 'Use 1 Soul Stone';

  @override
  String get languageSettingsSubtitle => 'Choose app language';

  @override
  String get cosmicSearchHintShort => 'Search...';

  @override
  String get cosmicAddThis => 'Add this';

  @override
  String get horoscopeWesternText =>
      'Stars align for your career. Take swift and decisive steps.';

  @override
  String get horoscopeAsianText =>
      'Water element is active. Your intuition is strong, just listen to your heart.';

  @override
  String get horoscopeMayanText =>
      'Tone 4 is active. A perfect day to establish order and plan your life.';

  @override
  String get horoscopeExplore => 'Explore';

  @override
  String get cookieDayCompleted => 'Day Completed';

  @override
  String get cookieSeeYouTomorrow => 'See you tomorrow with new cookies.';

  @override
  String get cookieRarityLegendary => 'Legendary';

  @override
  String get cookieRarityRare => 'Rare';

  @override
  String get cookiePremiumCollection => 'Premium Collection';

  @override
  String cookiePurchaseBtn(String price) {
    return 'Purchase ($price)';
  }

  @override
  String get cookieTapOutsideToClose => 'Tap outside to close';

  @override
  String get cookieAddedToCollection =>
      'Cookie successfully added to your collection!';

  @override
  String get cookiePremiumFallback => 'Premium Cookie';

  @override
  String get dreamSoulStoneRequired => 'Soul Stone Required';

  @override
  String get dreamSoulStoneRequiredDesc =>
      'Soul Stones are required for deep analysis.\n\nYou can earn Soul Stones by converting Aura points or with Elite subscription.';

  @override
  String get dreamGetElite => 'Get Elite';

  @override
  String get dreamClinicalGateTitle => 'Clinical Analysis Gate';

  @override
  String dreamClinicalGateDesc(int soulStones) {
    return 'Current Soul Stones: $soulStones\n\nThis clinical-level deep psychoanalysis costs 1 Soul Stone.';
  }

  @override
  String get dreamUseOneStone => 'Use 1 Stone';

  @override
  String get dreamDeepAnalysisBgPreparing =>
      'Deep Analysis is being prepared in the background. You will receive a notification when it is ready.';

  @override
  String get dreamYourSoulStones => 'Your Soul Stones';

  @override
  String dreamSoulStonesRemaining(int count) {
    return '$count Soul Stones remaining';
  }

  @override
  String get dreamSoulStonesEmpty => 'Out of Soul Stones';

  @override
  String get dreamRequiredForDeep => 'Required for Deep Analysis';

  @override
  String get dreamEachAnalysisCost => 'Each analysis costs 1 Soul Stone';

  @override
  String get dreamEliteRefillActive => 'Elite refills 5 Soul Stones nightly';

  @override
  String get dreamEliteRefillPromo => 'Get 5 daily Soul Stones with Elite';

  @override
  String get dreamWatchAd => 'Watch Ad';

  @override
  String get dreamBgAnalyzing =>
      'Your dream is being analyzed in the background. You will receive a notification when it is ready.';

  @override
  String get dreamDeepAnalysis => 'Deep Analysis';

  @override
  String get dreamDiscoverSecrets => 'Discover secrets';

  @override
  String get dreamDidYouKnow => 'Did you know?';

  @override
  String get dreamNeuroPsychAnalysis => 'NEURO-PSYCH ANALYSIS';

  @override
  String get dreamYourDream => 'YOUR DREAM';

  @override
  String get dreamEmotionalProfile => 'Emotional Profile';

  @override
  String get dreamEmotionalProfileSub =>
      'Psychological layers during the dream';

  @override
  String get dreamShadowSelf => 'Shadow Self';

  @override
  String get dreamShadowSelfSub =>
      'Suppressed and unexamined aspects of the subconscious';

  @override
  String get dreamRecurringPatterns => 'Recurring Patterns';

  @override
  String get dreamRecurringPatternsSub =>
      'Recurring loops and psychological blockages';

  @override
  String dreamSuggestedRitual(String title) {
    return 'Suggested Ritual: $title';
  }

  @override
  String get dreamSuggestedRitualSub =>
      'A specialized action to manage this dream\'s impact';

  @override
  String get dreamScienceNote => 'Science Note:';

  @override
  String get dreamWriteNewDream => 'Write a New Dream';

  @override
  String get dreamNoMonthDreams => 'No dreams written this month yet ✨';

  @override
  String get dreamMysteriousDream => 'Mysterious Dream';

  @override
  String get dreamStandardAnalysis => 'STANDARD ANALYSIS';

  @override
  String get dreamGeneralAnalysis => 'General Analysis';

  @override
  String get dreamPsychological => 'Psychological';

  @override
  String get dreamSpiritual2 => 'Spiritual';

  @override
  String get dreamAdvice => 'Advice';

  @override
  String get dreamDeepenedInsights => 'Deepened Insights';

  @override
  String get dreamEliteCreditsTitle => 'Elite Credits';

  @override
  String get dreamReadingCreditsTitle => 'Your Reading Credits';

  @override
  String dreamCreditsRemaining(int count) {
    return '$count credits remaining';
  }

  @override
  String get dreamDailyLimitReached => 'Daily limit reached';

  @override
  String get dreamZeroCredits => '0 credits remaining';

  @override
  String dreamDailyPremiumReads(int count) {
    return '$count daily Dream interpretations';
  }

  @override
  String get dreamNoAdsRequired => 'No need to watch ads';

  @override
  String get dreamCreditsResetNightly => 'Credits reset every night';

  @override
  String get dreamOneFreeDaily => '1 free interpretation every day';

  @override
  String dreamWatchAdsForCredits(int maxAds, int watched) {
    return 'Watch ads for $maxAds extra credits ($watched/$maxAds)';
  }

  @override
  String get dreamUnconsciousFrequencies => 'UNCONSCIOUS FREQUENCIES';

  @override
  String get dreamOrbEmotion => 'EMOTION';

  @override
  String get dreamOrbEntropy => 'ENTROPY';

  @override
  String get dreamOrbActivity => 'ACTIVITY';

  @override
  String get dreamOrbResidue => 'RESIDUE';

  @override
  String get dreamHighConfidence => 'High Confidence';

  @override
  String get dreamModerateConfidence => 'Moderate Confidence';

  @override
  String get dreamLowConfidence => 'Low Confidence';

  @override
  String get dreamCoreThematicPattern => 'CORE THEMATIC PATTERN';

  @override
  String get dreamMetricEmotionalLoad => 'Emotional\nLoad';

  @override
  String get dreamMetricEmotionalLoadDesc =>
      'How intensely your brain\'s emotional center was activated during this dream.';

  @override
  String get dreamMetricUncertaintyDesc =>
      'How illogical or inconsistent your dream narrative was.';

  @override
  String get dreamMetricRecentMemory => 'Recent\nConnection';

  @override
  String get dreamMetricRecentMemoryDesc =>
      'How much of your dream was influenced by recent real-life events.';

  @override
  String get dreamMetricAgency => 'Agency /\nControl';

  @override
  String get dreamMetricAgencyDesc =>
      'How much control you had over events in your dream.';

  @override
  String get dreamSeverityHigh => 'High';

  @override
  String get dreamSeverityNormal => 'Normal';

  @override
  String get dreamSeverityLow => 'Low';

  @override
  String get dreamCognitiveDistribution => 'COGNITIVE DISTRIBUTION';

  @override
  String get dreamTapToExpand => 'TAP TO EXPAND';

  @override
  String get dreamNeurologicalBasis => 'Neurological Basis';

  @override
  String get dreamEvidenceBase => 'EVIDENCE BASE';

  @override
  String get dreamRootCause => 'Root Cause';

  @override
  String get dreamAbsolutely => 'Absolutely';

  @override
  String get dreamMaybe => 'Maybe';

  @override
  String get dreamNotSure => 'Not Sure';

  @override
  String get dreamDreamEssence => 'DREAM ESSENCE';

  @override
  String get dreamClarifyingResponses => 'CLARIFYING RESPONSES';

  @override
  String get dreamCosmicRhythmSynced => 'Cosmic Rhythm Synced';

  @override
  String get dreamCosmicRhythmSyncedDesc =>
      'You will receive custom dream prompts based on your sleep cycle.';

  @override
  String get dreamSyncSleepData => 'Sync Sleep Data';

  @override
  String get dreamSyncSleepDataDesc =>
      'Allow it to detect when you wake up to ask about your deepest dream.';

  @override
  String get dreamAwarenessFallback =>
      'This awareness is the start of a new path. It is time to face it.';

  @override
  String get dreamExtractingEssence => 'Extracting dream essence...';

  @override
  String get dreamNoReasoning => 'No reasoning generated.';

  @override
  String get dreamNotAnalyzable =>
      'Are you sure this was a dream?\nPlease describe a real scene you experienced while sleeping.';

  @override
  String get owlTabFriends => 'My Friends';

  @override
  String get owlTabConnections => 'Connections';

  @override
  String get owlTabInbox => 'Inbox';

  @override
  String get owlSearchCosmic => 'Search cosmic universe...';

  @override
  String get owlSearchFriends => 'Search friends...';

  @override
  String get owlPhoneContacts => 'Phone Contacts';

  @override
  String get owlNoOneFoundCosmic => 'No one found in the cosmic universe.';

  @override
  String get owlFoundInCosmic => 'Found in Cosmic Universe';

  @override
  String get owlUnknownProfile => 'Unknown Profile';

  @override
  String owlFriendRequestSent(String name) {
    return 'Friend request sent to $name!';
  }

  @override
  String get owlRequestSentStatus => 'Sent';

  @override
  String get owlSendRequestAction => 'Send Request';

  @override
  String get owlConnectContacts => 'Connect Contacts';

  @override
  String get owlConnectContactsDesc =>
      'Find your friends instantly.\nYour contacts are NEVER stored on servers.';

  @override
  String get owlNoContactsFound =>
      'We Couldn\'t Find Anyone\nin the Crack&Wish Universe';

  @override
  String get owlNoContactsFoundDesc =>
      'You can start the cosmic energy by inviting them!';

  @override
  String get owlUnknown => 'Unknown';

  @override
  String get owlAppUserLabel => 'Crack&Wish User';

  @override
  String get owlInContactsLabel => 'In your contacts';

  @override
  String get owlNoFriendsYet => 'No friends yet';

  @override
  String get owlNoResultsFound => 'No results found';

  @override
  String get owlFriendRequests => 'Friend Requests';

  @override
  String get owlFriendsHeader => 'Your Friends';

  @override
  String get owlAcceptAction => 'Accept';

  @override
  String get owlRejectAction => 'Reject';

  @override
  String get owlInviteReward => '+2 Soul Stones';

  @override
  String owlInviteShareMessage(String username) {
    return 'Let\'s light up the darkness together! ✨\nJoin Crack Wish through my invitation link below, connect automatically, and win Start Rewards!\n\nMy Invitation Link:\nhttps://crackwish.com/invite/$username';
  }

  @override
  String get owlInviteFriends => 'Invite Friends';

  @override
  String get owlInviteFriendsDesc => 'Reflect the cosmic universe';

  @override
  String get owlNoLettersYet => 'No letters yet';

  @override
  String owlLetterSentNotification(String name) {
    return '$name sent a letter...';
  }

  @override
  String get owlOnItsWay => 'Owl is on its way 🕊️';

  @override
  String owlLetterCount(int count) {
    return '$count letters';
  }

  @override
  String owlUnreadCountBadge(int count) {
    return '$count New';
  }

  @override
  String get owlIUnderstand => 'I Understand';

  @override
  String get owlInviteHowTitle => 'How Would You Like to Invite?';

  @override
  String get owlInviteHowSubtitle =>
      'How do you want to send your cosmic key to this person?';

  @override
  String get owlInviteSendAsMessage => 'Send as message';

  @override
  String get owlInviteSMSSubtitle => 'Send via classic message';

  @override
  String get owlInviteOtherApps => 'Other Apps';

  @override
  String get owlInviteOtherAppsSubtitle => 'Instagram, TikTok, X, etc.';

  @override
  String get owlWhatsAppNotFound => 'WhatsApp not found';

  @override
  String get owlSMSNotFound => 'SMS app not found';

  @override
  String get owlDisconnectAction => 'Disconnect';

  @override
  String owlDisconnectConfirm(String name) {
    return 'Are you sure you want to break the magical bond with $name?';
  }

  @override
  String get owlDisconnectConfirmButton => 'Yes, Disconnect';

  @override
  String get owlCancel => 'Cancel';

  @override
  String get owlSendMagic => 'Send (Charmed)';

  @override
  String get owlSend => 'Send';

  @override
  String get owlCookieAdded => 'Cookie Added';

  @override
  String get owlAddCookie => 'Add Cookie';

  @override
  String get owlNoCookiesInCollection => 'No cookies in your collection';

  @override
  String get owlWriteLetterHint => 'Write your letter...';

  @override
  String get owlSendCookie => 'Send Cookie';

  @override
  String get zodiacMeasureHarmony => 'MEASURE COSMIC HARMONY';

  @override
  String get zodiacDiscoverEnergy =>
      'Discover your dual energy guided by the stars';

  @override
  String get zodiacChooseFriend => 'CHOOSE FRIEND';

  @override
  String get zodiacChooseFriendSubtitle =>
      'Select a friend to compare your cosmic energies';

  @override
  String get zodiacDiscoverYourself => 'Discover Yourself';

  @override
  String get zodiacCharacteristicAnalysis => 'CHARACTERISTIC ANALYSIS';

  @override
  String zodiacAbilityMap(String name) {
    return 'Ability map of $name';
  }

  @override
  String get zodiacPros => 'Advantages';

  @override
  String get zodiacCons => 'Challenges';

  @override
  String get zodiacAdvice => 'Advice';

  @override
  String get zodiacDailyWhisperSubtitle =>
      'Feel today\'s whisper and\nunravel the secrets of your spiritual portrait.';

  @override
  String get zodiacDailyWhisperHeadline =>
      'Today\'s message & spiritual portrait';

  @override
  String get zodiacOpenGuide => 'Open the Guide';

  @override
  String get zodiacNoFriends => 'No friends yet';

  @override
  String get zodiacSelect => 'SELECT';

  @override
  String get zodiacQuestCompleted => 'Quest Completed';

  @override
  String get zodiacQuestCompletedSubtitle =>
      'You are fully aligned with the rhythm of the universe.';

  @override
  String get zodiacRewardAura => 'Reward Earned:\n+4 AURA';

  @override
  String get zodiacStartNewQuest => 'START NEW QUEST';

  @override
  String zodiacDailyQuestTitle(int days) {
    return '$days-DAY QUEST';
  }

  @override
  String zodiacDailyQuestDesc(String weakness) {
    return 'Break Your Weakness: \"$weakness\"';
  }

  @override
  String zodiacQuestDayProgress(int current, int total) {
    return 'DAY $current / $total';
  }

  @override
  String get zodiacQuestTodayDiscovery => 'TODAY\'S DISCOVERY';

  @override
  String get zodiacQuestCompletedToday => 'COMPLETED TODAY';

  @override
  String get zodiacQuestCompleteNow => 'COMPLETE QUEST NOW';

  @override
  String get zodiacQuestMarkCompleted => 'I COMPLETED TODAY';

  @override
  String get zodiacLoveHarmony => 'LOVE HARMONY';

  @override
  String get zodiacFriendshipHarmony => 'FRIENDSHIP';

  @override
  String get zodiacCommunicationHarmony => 'COMMUNICATION & MIND';

  @override
  String get zodiacWorkHarmony => 'COLLABORATION';

  @override
  String get zodiacAdventureHarmony => 'ADVENTURE & FUN';

  @override
  String get zodiacViralDynamics => 'VIRAL DYNAMICS';

  @override
  String get zodiacDeepSynastryMap => 'DEEP SYNASTRY MAP';

  @override
  String zodiacSynastrySubtitle1(String name) {
    return 'The harmony between you and $name is not limited to Sun signs.';
  }

  @override
  String get zodiacSynastrySubtitle2 =>
      'Based on privacy, the cosmic algorithm cross-references astrological birth charts, Moon, and Rising phases behind the scenes, making this analysis completely unique to you.';

  @override
  String get zodiacDailyWhisperTitle => 'Today\'s Whisper';

  @override
  String get zodiacChooseSign => 'CHOOSE SIGN';

  @override
  String get zodiacCosmicGuide => 'YOUR COSMIC GUIDE';

  @override
  String get zodiacNew => 'NEW';

  @override
  String get zodiacCosmicHarmonyTitle => 'COSMIC HARMONY';

  @override
  String get zodiacAwesome => 'AWESOME';

  @override
  String get zodiacSpiritPortrait => 'Spiritual Portrait';

  @override
  String get onboardingFeatureStepTitle => 'What Awaits You?';

  @override
  String get onboardingFeatureStepSub =>
      'Are you ready to listen to the whispers of the universe and discover your destiny?';

  @override
  String get onboardingNameStepTitle => 'Let\'s Get to Know You';

  @override
  String get onboardingNameStepSub =>
      'Create your profile and determine your cosmic identity so that your soulmates can find you.';

  @override
  String get onboardingDateStepTitle => 'Cosmic Coordinate';

  @override
  String get onboardingDateStepSub =>
      'Choose the moment you were born for the basis of your astrological chart.';

  @override
  String get onboardingFocusStepTitle => 'Heart\'s Compass';

  @override
  String get onboardingFocusStepSub =>
      'Set your intention, let\'s map your path.';

  @override
  String get onboardingDreamStepTitle => 'Voice of Subconscious';

  @override
  String get onboardingDreamStepSub => 'How do your dreams reach you?';

  @override
  String get onboardingSleepStepTitle => 'Your Inner Compass';

  @override
  String get onboardingSleepStepSub =>
      'How do you find your way during destiny\'s turning points in your life?';

  @override
  String get onboardingFeatureAstrology => 'Personalized Astrology Chart';

  @override
  String get onboardingFeatureTarot => 'Guiding Tarot Journey';

  @override
  String get onboardingFeatureCoffee =>
      'Ancient Secrets of Coffee Fortune-Telling';

  @override
  String get onboardingFeatureDream => 'Subconscious Dream Analysis';

  @override
  String get onboardingFeatureZodiac =>
      'Mystic Chinese & Mayan Compatibilities';

  @override
  String get onboardingWelcomeTagline =>
      'Today my hopes are greater than my dreams.';

  @override
  String get onboardingFinalTagline => 'Click to secure your cosmic chart.';

  @override
  String get tarotShareText =>
      'The cards spoke to me like this! 🔮✨\n#CrackWish #Tarot';

  @override
  String get natalChartTitle => 'Birth Chart';

  @override
  String get natalChartCalculating => 'Calculating your birth chart...';

  @override
  String get natalChartSwipeHint => 'Swipe to Inspect';

  @override
  String get natalChartPlanetPositions => 'PLANET POSITIONS';

  @override
  String get natalChartAngularPoints => 'ANGULAR POINTS';

  @override
  String get natalChartAsc => 'ASC (Ascendant)';

  @override
  String get natalChartAscDesc =>
      'The mask you show to the outer world, your image, and your first impression.';

  @override
  String get natalChartMc => 'MC (Midheaven)';

  @override
  String get natalChartMcDesc =>
      'Your career, your public image, and your life goals.';

  @override
  String get natalChartDc => 'DC (Descendant)';

  @override
  String get natalChartDcDesc =>
      'The core traits you look for in relationships, marriage, and partnerships.';

  @override
  String get natalChartIc => 'IC (Imum Coeli)';

  @override
  String get natalChartIcDesc =>
      'Your roots, your family, your past, and your core security in your inner world.';

  @override
  String get natalChartTabPersonality => 'Main Personality Summary';

  @override
  String get natalChartTabLove => 'Love & Relationships';

  @override
  String get natalChartTabCareer => 'Career & Money';

  @override
  String get natalChartTabEmotional => 'Emotional Structure';

  @override
  String get natalChartTabStrengths => 'Strengths & Weaknesses';

  @override
  String natalChartHouse(String house) {
    return 'House $house';
  }

  @override
  String zodiacGreeting(String name) {
    return 'Hello $name,';
  }

  @override
  String get zodiacCosmicTraveler => 'Cosmic Traveler,';

  @override
  String get zodiacBirthDate => 'BIRTH DATE';

  @override
  String get zodiacStarsKnowYou => 'Let the stars know you';

  @override
  String get zodiacConfirm => 'CONFIRM';

  @override
  String get zodiacDiscoverYourselfBtn => 'DISCOVER YOURSELF';

  @override
  String get zodiacEliteRequiredDesc =>
      'You need an Elite subscription to discover deep astrological compatibility and viral dynamics with your friends.';

  @override
  String get zodiacEliteDiscoverBtn => 'Discover Elite Privileges';

  @override
  String get zodiacHubWestern => 'WESTERN ASTROLOGY';

  @override
  String get zodiacHubAsian => 'ASIAN ASTROLOGY';

  @override
  String get zodiacHubMayan => 'MAYAN ASTROLOGY';

  @override
  String get actionLater => 'Later';

  @override
  String get coffeeViewReading => 'View Reading';

  @override
  String get coffeeReadyTitleWithEmoji => '☕️ Your Reading is Ready!';

  @override
  String get wheelTask_w_c1 =>
      'Send a \"thinking of you\" message to a loved one';

  @override
  String get wheelTask_w_c2 =>
      'Say hello to someone you haven\'t spoken to in a while';

  @override
  String get wheelTask_w_c3 =>
      'Tell a family member how important they are today';

  @override
  String get wheelTask_w_c4 => 'Compliment someone next to you';

  @override
  String get wheelTask_w_c5 => 'Send a funny video to a friend';

  @override
  String get wheelTask_w_c6 => 'Thank someone today and explain why';

  @override
  String get wheelTask_w_s1 =>
      'Look in the mirror, smile at yourself, and hold for 10 seconds';

  @override
  String get wheelTask_w_s2 =>
      'Remember the last time you laughed out loud and smile again';

  @override
  String get wheelTask_w_s3 => 'Think of a funny memory and laugh out loud';

  @override
  String get wheelTask_w_s4 =>
      'Find and look at the funniest photo on your phone';

  @override
  String get wheelTask_w_s5 => 'Smile at the first person you see';

  @override
  String get wheelTask_w_s6 =>
      'Think of the funniest moment you experienced today';

  @override
  String get wheelTask_w_m1 => 'Stand up and stretch for 30 seconds';

  @override
  String get wheelTask_w_m2 => 'Walk around your room for 1 minute';

  @override
  String get wheelTask_w_m3 => 'Jump 10 times and say \"I can do it!\"';

  @override
  String get wheelTask_w_m4 =>
      'Raise your arms and do a Superman pose for 20 seconds';

  @override
  String get wheelTask_w_m5 =>
      'Roll your shoulders forward 5 times, then backward 5 times';

  @override
  String get wheelTask_w_m6 =>
      'Take a deep breath, open your arms wide, and hold for 10 seconds';

  @override
  String get wheelTask_w_mu1 =>
      'Play your favorite song and listen for 1 minute';

  @override
  String get wheelTask_w_mu2 =>
      'Play a random song and listen to the first 30 seconds';

  @override
  String get wheelTask_w_mu3 => 'Sing! Sing out loud as if no one is listening';

  @override
  String get wheelTask_w_mu4 =>
      'Listen to a song in a genre you haven\'t explored today';

  @override
  String get wheelTask_w_mu5 =>
      'Close your eyes and listen to the sounds around you for 30 seconds';

  @override
  String get wheelTask_w_mu6 =>
      'Tap a rhythm on the table with your finger for 15 seconds';

  @override
  String get wheelTask_w_g1 =>
      'Think of 1 thing you have today and say \"thank you\"';

  @override
  String get wheelTask_w_g2 => 'Count 3 small things that make you happy';

  @override
  String get wheelTask_w_g3 =>
      'Think of the best thing you ate today and remember its taste';

  @override
  String get wheelTask_w_g4 =>
      'Think of the best moment of your life for 10 seconds';

  @override
  String get wheelTask_w_g5 =>
      'Feel grateful for your health. Take a deep breath.';

  @override
  String get wheelTask_w_g6 => 'Feel grateful that the sun rose today';

  @override
  String get wheelTask_w_f1 => 'Jump 3 times and shout \"I can do it!\"';

  @override
  String get wheelTask_w_f2 =>
      'Make your funniest face and hold it for 5 seconds';

  @override
  String get wheelTask_w_f3 => 'Imitate an animal — which animal would you be?';

  @override
  String get wheelTask_w_f4 =>
      'Close your eyes and imagine you are flying for 10 seconds';

  @override
  String get wheelTask_w_f5 =>
      'Strike a superhero pose and hold it for 5 seconds';

  @override
  String get wheelTask_w_f6 => 'Walk like a robot for 10 steps';

  @override
  String get zodiacAccessWesternAdTitle => 'Daily Free Limit Reached';

  @override
  String get zodiacAccessWesternAdDesc =>
      'You can watch a short ad to re-enter Western Astrology.';

  @override
  String get zodiacAccessWatchAdBtn => 'Watch Ad';

  @override
  String get zodiacAccessGetEliteBtn => 'Get Elite';

  @override
  String get zodiacAccessGateTitle => 'Gate of Cosmic Wisdom';

  @override
  String zodiacAccessStoneCount(Object count) {
    return 'You have $count Soul Stones';
  }

  @override
  String get zodiacAccessPremiumInfo1 => 'Access permission to zodiac depths';

  @override
  String get zodiacAccessPremiumInfo2 =>
      'Each astrology chart consumes 1 Soul Stone';

  @override
  String get zodiacAccessPremiumInfo3Elite =>
      'Elite: Unlimited access with 1 Soul Stone per day';

  @override
  String get zodiacAccessPremiumInfo3Normal =>
      '1 Soul Stone is enough with Elite per day';

  @override
  String get zodiacAccessOneStoneBtn => '1 Soul Stone';

  @override
  String get onboardingTestSimulate =>
      'Test Mode: Simulating old account login...';

  @override
  String get onboardingTestAnon => 'Test Mode: Connecting anonymously...';

  @override
  String onboardingGoogleLoginFailed(Object error) {
    return 'Google Login Failed: $error';
  }

  @override
  String onboardingAppleLoginFailed(Object error) {
    return 'Apple Login Failed: $error';
  }

  @override
  String onboardingGoogleRegisterFailed(Object error) {
    return 'Google Registration Failed: $error';
  }

  @override
  String onboardingAppleRegisterFailed(Object error) {
    return 'Apple Registration Failed: $error';
  }

  @override
  String dreamDataError(Object error) {
    return 'Saved data error: $error';
  }

  @override
  String get onboardingBirthDateTitle => 'YOUR BIRTH DATE';

  @override
  String get onboardingSelectBirthDate => 'Select your birth date';

  @override
  String get onboardingBirthTimeTitle => 'BIRTH TIME (Optional)';

  @override
  String get onboardingBirthPlaceTitle => 'BIRTH PLACE (Optional)';

  @override
  String get onboardingPickerDateTitle => 'Select Birth Date';

  @override
  String get onboardingPickerTimeTitle => 'Select Birth Time';

  @override
  String get onboardingPickerDone => 'Done';

  @override
  String get onboardingLifeFocusSpiritual => 'Spiritual\nAwakening';

  @override
  String get onboardingLifeFocusCareer => 'Career &\nPersonal Power';

  @override
  String get onboardingLifeFocusLove => 'Love &\nCosmic Harmony';

  @override
  String get onboardingLifeFocusHealing => 'Healing &\nInner Peace';

  @override
  String get onboardingLifeFocusWealth => 'Wealth &\nAbundance';

  @override
  String get onboardingLifeFocusSurprise => 'Universe\'s\nSurprises';

  @override
  String get onboardingDreamMessenger => 'Messenger & Vivid Dreams';

  @override
  String get onboardingDreamChaotic => 'Surprising & Chaotic Events';

  @override
  String get onboardingDreamCalm => 'As Calm as the Clouds';

  @override
  String get onboardingSleepMindTitle => 'Light of the Mind';

  @override
  String get onboardingSleepMindDesc =>
      'I analyze events, weigh them with logic, and plan concrete steps.';

  @override
  String get onboardingSleepMindVal => 'Light of the Mind (Logic)';

  @override
  String get onboardingSleepHeartTitle => 'Whisper of the Heart';

  @override
  String get onboardingSleepHeartDesc =>
      'I listen to my inner voice, and always trust my feelings over logic.';

  @override
  String get onboardingSleepHeartVal => 'Whisper of the Heart (Intuition)';

  @override
  String get onboardingSleepUniverseTitle => 'Flow of the Universe';

  @override
  String get onboardingSleepUniverseDesc =>
      'I believe everything happens for a reason, and follow the universe\'s signs.';

  @override
  String get onboardingSleepUniverseVal => 'Flow of the Universe (Destiny)';

  @override
  String get linkAccountTitle => 'Link Account';

  @override
  String get linkGoogleAccount => 'Link Google Account';

  @override
  String get linkAppleAccount => 'Link Apple Account';

  @override
  String get linkAccountStarted => 'Account linking process started...';

  @override
  String get linkAccountFailed => 'Account linking failed';

  @override
  String get profileSignOutGuestDesc =>
      'Warning: If you sign out of a guest account, you will not be able to access this account again and all your data (Soul Stones, readings) will be PERMANENTLY LOST. Are you sure you want to sign out?';
}
