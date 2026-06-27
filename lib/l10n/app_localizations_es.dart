// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Crack&Wish';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get turkish => 'Turco';

  @override
  String get english => 'Inglés';

  @override
  String get close => 'Cerrar';

  @override
  String languageValue(Object value) {
    return 'Seleccionado: $value';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navCollection => 'Colección';

  @override
  String get navProfile => 'Perfil';

  @override
  String get dailyCookieTitle => 'Galleta del Día';

  @override
  String get dailyCookieSubtitle => 'Toca para probar tu suerte';

  @override
  String get luckyNumber => 'Número de la Suerte';

  @override
  String get luckyColor => 'Color de la Suerte';

  @override
  String get luckLabel => 'Suerte';

  @override
  String get todayFortune => 'Fortuna de Hoy';

  @override
  String get shareButton => '📸 Compartir';

  @override
  String fortuneShareText(
    Object emoji,
    Object title,
    Object meaning,
    Object number,
    Object color,
    Object percent,
  ) {
    return '$emoji $title\n\n$meaning\n\nNúmero de la Suerte: $number\nColor de la Suerte: $color\nSuerte: $percent%\n\nDesde la app Galleta de la Fortuna 🥠';
  }

  @override
  String get themeSelectTitle => 'Seleccionar Tema';

  @override
  String themeSelected(Object value) {
    return 'Tema seleccionado: $value';
  }

  @override
  String get themeGalleryTitle => 'Galería de Temas';

  @override
  String get themeGalleryOpen => 'Ir a la lista de temas';

  @override
  String get themeGalleryLimited =>
      'La galería de temas está actualmente limitada a dos opciones';

  @override
  String get statCookies => 'Galletas';

  @override
  String get statStreakDays => 'Días de Racha';

  @override
  String get statDreams => 'Sueños';

  @override
  String get statMood => 'Ánimo';

  @override
  String get statTheme => 'Hoy...';

  @override
  String get statCollection => 'Mi Galleta';

  @override
  String get statTalisman => 'Talismán';

  @override
  String get moodGood => 'Bien';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodBad => 'Mal';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodGreat => 'Genial';

  @override
  String get shortcutCollection => 'Colección';

  @override
  String get shortcutHistory => 'Historial';

  @override
  String get shortcutFavorites => 'Favoritos';

  @override
  String get sectionShortcuts => 'Accesos Rápidos';

  @override
  String get sectionActivity => 'Actividad';

  @override
  String get menuBadges => 'Insignias';

  @override
  String get menuBadgesSubtitle => 'Logros y niveles';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get menuSettingsSubtitle => 'Notificaciones, tema, privacidad';

  @override
  String get menuHelpAbout => 'Ayuda y Acerca de';

  @override
  String get menuHelpAboutSubtitle =>
      'Preguntas frecuentes e información de versión';

  @override
  String get menuShare => 'Compartir';

  @override
  String get menuShareSubtitle => 'Comparte tu perfil con amigos';

  @override
  String get activityTarotOpenedTitle => 'Lectura de tarot abierta';

  @override
  String get activityTarotOpenedSubtitle => 'Hoy • Carta: Estrella';

  @override
  String activityCookiesOpenedTitle(Object count) {
    return '$count galletas abiertas';
  }

  @override
  String get activityCookiesOpenedSubtitle => 'Ayer • Nuevos mensajes abiertos';

  @override
  String get activityDreamSavedTitle => 'Interpretación de sueño guardada';

  @override
  String get activityDreamSavedSubtitle => 'Hace 2 días';

  @override
  String get profileUserTitle => 'Usuario';

  @override
  String get profileSubtitle => 'Menos ruido, más tú';

  @override
  String get tagTarot => 'Tarot';

  @override
  String get tagDream => 'Sueño';

  @override
  String get tagCollection => 'Colección';

  @override
  String get zodiacTitle => '⭐ Lectura del Zodíaco';

  @override
  String zodiacDailyTitle(Object name) {
    return '$name - Lectura Diaria';
  }

  @override
  String get zodiacDailyBody =>
      '¡Tienes suerte en el amor esta semana! Las oportunidades de carrera están a tu puerta—mantén los ojos abiertos. Tu energía está alta, úsala. Es un momento perfecto para nuevos proyectos. Tus habilidades de comunicación están en su punto máximo, aprovéchalo.';

  @override
  String get zodiacLove => 'Amor';

  @override
  String get zodiacCareer => 'Carrera';

  @override
  String get zodiacMoney => 'Dinero';

  @override
  String get zodiacHealth => 'Salud';

  @override
  String get collectionTitle => 'Tu Colección';

  @override
  String get collectionSubtitle => 'Huellas y recompensas de tu ritual diario';

  @override
  String get collectionNotYet => 'Aún no';

  @override
  String get collectionFirstTime => 'Primera vez';

  @override
  String get collectionTotalOpened => 'Total';

  @override
  String get collectionCookieDescription =>
      'Esta galleta añade suerte y pequeñas sorpresas a tu ritual. Cuantas más abras, más fuerte será tu colección.';

  @override
  String get collectionSummaryTitle => 'Resumen de Colección';

  @override
  String get collectionSummaryTypes => 'Tipos únicos';

  @override
  String get collectionSummaryTotalOpened => 'Total abiertos';

  @override
  String get collectionSummaryRare => 'Raro';

  @override
  String get collectionSummaryFooter =>
      'Cada galleta tiene una historia. Cuantas más abras, más rica se vuelve.';

  @override
  String get rarityAll => 'Todos';

  @override
  String get rarityCommon => 'Común';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityLegendary => 'Legendario';

  @override
  String get collectionUndiscovered => 'Sin descubrir';

  @override
  String get collectionNotFoundYet =>
      'La suerte aún no te ha traído aquí... todavía.';

  @override
  String get collectionEmptyTitle => 'Aún no has abierto ninguna galleta';

  @override
  String collectionEmptySubtitle(Object count) {
    return '$count galletas diferentes te esperan. Abre la galleta de hoy para iniciar tu colección.';
  }

  @override
  String get discoverTitle => 'Descubrir';

  @override
  String get discoverSubtitle => 'Explora nuevas funciones';

  @override
  String get discoverCategories => 'Categorías';

  @override
  String get categoryTarotTitle => 'Lectura de Tarot';

  @override
  String get categoryTarotDesc => 'Tarot de 3 Cartas';

  @override
  String get categoryDreamTitle => 'Interpretación de Sueños';

  @override
  String get categoryDreamDesc => 'Descubre el significado de tus sueños';

  @override
  String get categoryZodiacTitle => 'Lectura del Zodíaco';

  @override
  String get categoryZodiacDesc => 'Mensaje de las estrellas';

  @override
  String get categoryPersonalityTitle => 'Test de Personalidad';

  @override
  String get categoryPersonalityDesc => '16 Personalidades';

  @override
  String get discoverDailySuggestionTitle => 'SUGERENCIA DE HOY';

  @override
  String get discoverDailySuggestionHeadline => '¿Tuviste un sueño anoche?';

  @override
  String get discoverDailySuggestionSubtitle =>
      '¡Interprétalo ahora y descubre su significado!';

  @override
  String get dailySuggestionDreamHeadline => '¿Tuviste un sueño anoche?';

  @override
  String get dailySuggestionDreamSubtitle =>
      '¡Interprétalo ahora y descubre su significado!';

  @override
  String get dailySuggestionTarotHeadline => '¿Has consultado tu tarot hoy?';

  @override
  String get dailySuggestionTarotSubtitle =>
      '¡Elige 3 cartas y descubre tu mensaje!';

  @override
  String get dailySuggestionZodiacHeadline => '¿Ya revisaste tu horóscopo?';

  @override
  String get dailySuggestionZodiacSubtitle =>
      '¡Descubre la energía de hoy ahora mismo!';

  @override
  String get dailySuggestionCoffeeHeadline => '¿Tomaste café hoy?';

  @override
  String get dailySuggestionCoffeeSubtitle =>
      '¡Voltea tu taza, vamos a leer tu fortuna!';

  @override
  String get dailySuggestionAllDoneHeadline =>
      '¡Los rituales de hoy están completos!';

  @override
  String get dailySuggestionAllDoneSubtitle =>
      'Vuelve mañana para nuevo contenido.';

  @override
  String get discoverFeaturedTag => 'DESTACADO';

  @override
  String get discoverFeaturedTitle => 'Lectura de Tarot de 3 Cartas';

  @override
  String get discoverFeaturedSubtitle => 'Explora tu pasado, presente y futuro';

  @override
  String get ctaStart => 'Comenzar';

  @override
  String get homeGreeting => '¡Hola! 👋';

  @override
  String get homeFeeling => '¿Cómo te sientes hoy?';

  @override
  String get quoteOfDayText =>
      'El paso más pequeño que des hoy conduce a la victoria más grande de mañana.';

  @override
  String get quoteOfDaySource => '— Frase del Día';

  @override
  String get dailyHoroscopeTitle => 'Aries';

  @override
  String get dailyHoroscopeSubtitle => 'Lectura de Hoy';

  @override
  String get dailyHoroscopeBody =>
      '¡Tienes suerte en el amor esta semana! Las oportunidades de carrera están a tu puerta—mantén los ojos abiertos. Tu energía está alta, úsala.';

  @override
  String get aries => 'Aries';

  @override
  String get bentoTarotTitle => 'Tarot';

  @override
  String get bentoTarotDesc => 'Ve tu futuro';

  @override
  String get bentoTarotBadge => 'POPULAR';

  @override
  String get bentoDreamTitle => 'Sueño';

  @override
  String get bentoDreamDesc => 'Explora tu subconsciente';

  @override
  String get bentoDreamBadge => 'NUEVO';

  @override
  String get bentoMotivationTitle => 'Ánimo';

  @override
  String get bentoMotivationDesc => 'Descubre tu estado de ánimo';

  @override
  String get bentoMotivationBadge => 'DIARIO';

  @override
  String get bentoZodiacTitle => 'Zodíaco';

  @override
  String get bentoZodiacDesc => 'Mensaje de las estrellas';

  @override
  String get bentoZodiacBadge => 'DIARIO';

  @override
  String get moodQuestion => '¿Cómo estás hoy?';

  @override
  String get dreamTitle => 'Cuenta Tu Sueño';

  @override
  String get dreamTabNew => 'Nuevo Sueño';

  @override
  String get dreamTabHistory => 'Mis Sueños';

  @override
  String get dreamAnalyzeButton => 'Interpretar Sueño';

  @override
  String get dreamAnalyzeEstimate => '~ 5 seg';

  @override
  String get dreamInterpretationTitle => 'Interpretación del Sueño';

  @override
  String get dreamNoHistory => 'Aún no tienes sueños guardados';

  @override
  String get dreamDefaultTitle => 'Sueño';

  @override
  String get dreamSpiritual => 'Espiritual';

  @override
  String get dreamEnriched => 'Interpretación Enriquecida';

  @override
  String get dreamEnriching => 'Enriqueciendo...';

  @override
  String get dreamEnrich => 'Enriquecer';

  @override
  String get dreamShare => 'Compartir';

  @override
  String get dreamAnalyzing => 'Analizando sueño...';

  @override
  String get dreamAnalysisFailed =>
      'No se pudo generar una interpretación en este momento.';

  @override
  String get dreamClarifyThreat =>
      '¿Hubo una sensación de amenaza o miedo en el sueño?';

  @override
  String get dreamClarifyFamiliar =>
      '¿Esta escena te resultó familiar del pasado?';

  @override
  String get dreamClarifyEscape =>
      '¿Hubo una sensación de movimiento o escape?';

  @override
  String get dreamClarifyAnxious => '¿Sentiste ansiedad o amenaza en el sueño?';

  @override
  String get dreamUnsure => 'No estoy seguro';

  @override
  String get dreamYes => 'SÍ';

  @override
  String get dreamNo => 'NO';

  @override
  String get dreamGeneral => 'Sueño General';

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
    return 'Título del Sueño: $title\nFecha: $date\n\nSueño: $text\n\nGeneral: $general\nPsicológico: $psychology\nEspiritual: $spiritual\nConsejo: $advice\n\n#VLucky #Sueño';
  }

  @override
  String get scientificTitle => 'Análisis Científico de Sueños';

  @override
  String get scientificDreamPromptTitle => 'Cuenta Tu Sueño';

  @override
  String get scientificDreamHint => 'Escribe tu sueño tal como lo recuerdas...';

  @override
  String get scientificEmotionQuestion => '¿Cómo te sentiste al despertar?';

  @override
  String get scientificEmotionHint => 'Elige una emoción';

  @override
  String get scientificClarityQuestion => '¿Qué tan claro fue el sueño?';

  @override
  String get scientificDisclaimer =>
      'Este análisis se basa en investigación de psicología y neurociencia. No proporciona resultados definitivos ni predictivos.';

  @override
  String get scientificLoading =>
      'Evaluando según el sueño REM y la neurociencia';

  @override
  String get scientificResultsTitle => 'Interpretación del Sueño';

  @override
  String get scientificRecentPastTitle => 'Efectos del Pasado Reciente';

  @override
  String get scientificSaved => 'Sueño guardado';

  @override
  String get scientificSaveButton => 'Guardar Sueño';

  @override
  String get cookieSpringWreath => 'Corona de Primavera';

  @override
  String get cookieLuckyClover => 'Trébol de la Suerte';

  @override
  String get cookieRoyalHearts => 'Corazones Reales';

  @override
  String get cookieEvilEye => 'Ojo Turco';

  @override
  String get cookiePizzaParty => 'Fiesta de Pizza';

  @override
  String get cookieSakuraBloom => 'Flor de Sakura';

  @override
  String get cookieBluePorcelain => 'Porcelana Azul';

  @override
  String get cookiePinkBlossom => 'Flor Rosa';

  @override
  String get cookieFortuneCat => 'Gato de la Fortuna';

  @override
  String get cookieWildflower => 'Flor Silvestre';

  @override
  String get cookieCupidRibbon => 'Lazo de Cupido';

  @override
  String get cookiePandaBamboo => 'Panda Bambú';

  @override
  String get cookieRamadanCute => 'Ramadán';

  @override
  String get cookieEnchantedForest => 'Bosque Encantado';

  @override
  String get cookieGoldenArabesque => 'Arabesco Dorado';

  @override
  String get cookieMidnightMosaic => 'Mosaico de Medianoche';

  @override
  String get cookiePearlLace => 'Encaje de Perla';

  @override
  String get cookieGoldenSakura => 'Sakura Dorada';

  @override
  String get cookieDragonPhoenix => 'Dragón Fénix';

  @override
  String get cookieGoldBeasts => 'Bestias Doradas';

  @override
  String get emotionAnxiety => 'Ansioso';

  @override
  String get emotionFear => 'Asustado';

  @override
  String get emotionCalm => 'Tranquilo';

  @override
  String get emotionHappy => 'Feliz';

  @override
  String get emotionSad => 'Triste';

  @override
  String get emotionConfusion => 'Incierto';

  @override
  String get emotionSurprise => 'Sorprendido';

  @override
  String get dreamMoodQuestion => '¿Cómo te sentiste al despertar?';

  @override
  String get dreamMetricEmotional => 'Carga Emocional';

  @override
  String get dreamMetricUncertainty => 'Incertidumbre\nNarrativa';

  @override
  String get dreamMetricRecentPast => 'Pasado Reciente';

  @override
  String get dreamMetricBrain => 'Actividad Cerebral';

  @override
  String get tarotShuffleHint => 'Arrastra en círculo para barajar';

  @override
  String get tarotEnergyDepletedTitle => 'Energía Agotada';

  @override
  String get tarotEnergyDepletedBody =>
      'Tu energía cósmica diaria se ha agotado.\nRecarga para ver la verdad.';

  @override
  String get tarotEnergyDepletedSub =>
      'Tus cartas seleccionadas están listas, solo falta un paso...';

  @override
  String get tarotWatchAd => 'Ver Anuncio y Abrir';

  @override
  String tarotFreeRemaining(Object count) {
    return 'Gratis restantes hoy: $count';
  }

  @override
  String get socialFeedTitle => 'Feed Tranquilo';

  @override
  String get feedTypeCookie => 'Galleta';

  @override
  String get feedTagDailyCookie => 'Galleta del día';

  @override
  String get feedTypeTarot => 'Tarot';

  @override
  String get feedTagThreeCard => 'Tirada de 3 cartas';

  @override
  String get feedTypeDream => 'Sueño';

  @override
  String get feedTagDreamMode => 'Modo sueño';

  @override
  String get feedTypeZodiac => 'Zodíaco';

  @override
  String get feedTagDailyEnergy => 'Energía diaria';

  @override
  String get feedTypeMotivation => 'Motivación';

  @override
  String get feedTagMiniAction => 'Mini acción';

  @override
  String inviteShareMessage(String handle, String link) {
    return '¿Estás listo para un viaje místico? ¡Te espero en el universo de Crack&Wish! ✨\n\nMi código de invitación: $handle\nDescarga Ahora: $link';
  }

  @override
  String get inviteShareSubject => 'Invitación Crack&Wish';

  @override
  String get inviteSendButton => 'Invitar';

  @override
  String get inviteConnectButton => 'Conectar';

  @override
  String get inviteSentText => 'Enviado';

  @override
  String inviteRequestSent(String name) {
    return '¡Solicitud enviada a $name!';
  }

  @override
  String get toastCoffeeReadyTitle => '¡Tu Lectura Está Lista!';

  @override
  String get toastCoffeeReadyMessage =>
      'Los secretos en tu taza han sido revelados.';

  @override
  String get toastViewButton => 'Ver';

  @override
  String get toastDreamReadyTitle => '¡Tu Sueño Ha Sido Interpretado!';

  @override
  String get toastDreamReadyMessage =>
      'Los mensajes de tu subconsciente han sido decodificados.';

  @override
  String get toastCoffeeReadyTitle2 => '¡Tu Lectura de Café Está Lista!';

  @override
  String get dreamFallbackTitle => 'Interpretación del Sueño';

  @override
  String get rewardWelcomeTitle => 'Bienvenido al Universo';

  @override
  String get rewardWelcomeDesc =>
      'Dejamos un pequeño regalo para que comiences tu viaje.';

  @override
  String get rewardReferralFallback => 'Un amigo';

  @override
  String get rewardReferralReceiverTitle => 'Un Regalo Inesperado';

  @override
  String rewardReferralReceiverDesc(String inviter) {
    return '$inviter te invitó aquí y dejó un regalo de bienvenida para ti.';
  }

  @override
  String get rewardInviterTitle => '¡Tu Llamada Fue Escuchada!';

  @override
  String rewardInviterDescSingle(String name) {
    return '$name se unió al universo. Has sido recompensado por ser un guía.';
  }

  @override
  String rewardInviterDescMultiple(String name, int count) {
    return '$name y $count amigos más se unieron al universo. Has sido recompensado por ser un guía.';
  }

  @override
  String rewardInviterDescGeneric(int count) {
    return '$count amigos se unieron al universo. Has sido recompensado por ser un guía.';
  }

  @override
  String birthdayTitleWithName(String name) {
    return '¡Feliz Cumpleaños, $name!';
  }

  @override
  String get birthdayTitle => '¡Feliz Cumpleaños!';

  @override
  String get birthdayDesc =>
      'Hoy es el día sagrado en que tu alma llegó a este mundo. El universo dejó un regalo especial para ti.';

  @override
  String get cookieReminderTitle => 'Hoy No Abriste Una Galleta';

  @override
  String get cookieReminderMessage =>
      '¡Tu mensaje de fortuna diario te está esperando!';

  @override
  String get cookieReminderReward => 'Quedan 3';

  @override
  String achievementRewardStones(int count) {
    return '+$count Piedras del Alma';
  }

  @override
  String achievementRewardAura(int count) {
    return '+$count Aura';
  }

  @override
  String get rankUpTitle => '¡Ascenso Cósmico!';

  @override
  String rankUpMessage(String rank) {
    return 'Tu poder de aura aumentó. Nuevo título: $rank';
  }

  @override
  String get rankNovice => 'Vidente Novato';

  @override
  String get rankApprentice => 'Vidente Aprendiz';

  @override
  String get rankSeer => 'Vidente';

  @override
  String get rankWise => 'Vidente Sabio';

  @override
  String get rankMaster => 'Vidente Maestro';

  @override
  String get rankCosmic => 'Vidente Cósmico';

  @override
  String get loginSubtitle =>
      'Sincronízate con el guía de tu alma.\nRecuerda tu pasado, futuro y subconsciente.';

  @override
  String get loginAppleContinue => 'Continuar con Apple';

  @override
  String get loginAppleSignIn => 'Iniciar sesión con Apple';

  @override
  String get loginGoogleContinue => 'Continuar con Google';

  @override
  String get loginGoogleSignIn => 'Iniciar sesión con Google';

  @override
  String get loginGoogleFailed => 'Error de Inicio de Sesión con Google';

  @override
  String get loginAppleFailed => 'Error de Inicio de Sesión con Apple';

  @override
  String get loginNoAccountYet => '¿Aún no te has unido al universo?  ';

  @override
  String get loginHaveAccount => '¿Ya tienes una cuenta?  ';

  @override
  String get loginSignUp => 'Registrarse';

  @override
  String get loginSignIn => 'Iniciar Sesión';

  @override
  String get loginLegalPrefix => 'Al continuar, aceptas nuestros ';

  @override
  String get loginTermsOfUse => 'Términos de Uso';

  @override
  String get loginLegalAnd => ' y ';

  @override
  String get loginPrivacyPolicy => 'Política de Privacidad';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get homeSubtitle1 => 'Abre, Lee, Sonríe.';

  @override
  String get homeSubtitle2 => 'Suerte en tu bolsillo.';

  @override
  String get homeSubtitle3 => 'El mensaje de hoy: Tú.';

  @override
  String get homeSubtitle4 => 'Una galleta, una sorpresa.';

  @override
  String get homeSubtitle5 => 'Una pequeña galleta, un gran sentimiento.';

  @override
  String get homeSubtitle6 => 'No es destino, solo una dulce pista.';

  @override
  String get homeSubtitle7 => '¿Qué dice tu suerte hoy?';

  @override
  String get homeSubtitle8 => 'Abre, descubre, sigue adelante.';

  @override
  String get homeSubtitle9 => 'La suerte está a un toque de distancia.';

  @override
  String get homeSubtitle10 => 'Un nuevo comienzo con cada galleta.';

  @override
  String get homeSubtitle11 => 'Encuentra tu mensaje.';

  @override
  String get homeSubtitle12 => 'No es al azar… es solo para ti.';

  @override
  String get homeSubtitle13 => 'Abre tu suerte, aprovecha tu día.';

  @override
  String get homeSubtitle14 => 'Pequeñas profecías que te hacen sonreír.';

  @override
  String get homeSubtitle15 => 'Las sorpresas te sientan bien.';

  @override
  String get homeMilestoneTitle => '¡Enfoque Increíble!';

  @override
  String homeMilestoneMessage(int count) {
    return 'Tu racha diaria alcanzó $count días.';
  }

  @override
  String homeMilestoneSoulStone(int count) {
    return '+$count Piedras del Alma';
  }

  @override
  String get homeGreetingMorning => 'Buenos Días';

  @override
  String get homeGreetingAfternoon => 'Buenas Tardes';

  @override
  String get homeGreetingEvening => 'Buenas Tardes';

  @override
  String get homeGreetingNight => 'Buenas Noches';

  @override
  String get homeTimeSubMorning => 'Un mensaje fresco con tu café.';

  @override
  String get homeTimeSubAfternoon => 'Un descanso mágico en tu día.';

  @override
  String get homeTimeSubEvening => 'Una dulce profecía para relajarte.';

  @override
  String get homeTimeSubNight => 'Las estrellas brillan para ti esta noche.';

  @override
  String get paywallSubtitleElite =>
      'Tu conciencia cósmica ya está abierta.\nFortalece tu iluminación mejorando tu plan.';

  @override
  String get paywallSubtitleNew =>
      'Abre la puerta a la conciencia cósmica.\nElimina todos los límites.';

  @override
  String get paywallFeature1 => '5 Piedras del Alma Frescas Diarias';

  @override
  String get paywallFeature2 => 'Modo de Análisis Maestro';

  @override
  String get paywallFeature3 => 'x3 Ganancia Rápida de Aura';

  @override
  String get paywallFeature4 => 'Archivo Clínico Ilimitado';

  @override
  String get paywallFeature5 => 'Experiencia Sin Anuncios';

  @override
  String get paywallPackageWeekly => 'Despertar Semanal';

  @override
  String get paywallPackageMonthly => 'Intuición Mensual';

  @override
  String get paywallPackageYearly => 'Iluminación Anual';

  @override
  String get paywallBtnCurrentPlan => 'Plan Actual';

  @override
  String get paywallBtnManage => 'Gestionar desde la Tienda';

  @override
  String get paywallBtnUpgrade => 'Mejorar Plan';

  @override
  String get paywallBtnSubscribe => 'Desbloquear Elite';

  @override
  String get paywallSuccessUpgradeTitle => 'Iluminación Mejorada';

  @override
  String get paywallSuccessTitle => 'Bienvenido a la Iluminación';

  @override
  String get paywallSuccessUpgradeSubtitle =>
      'Tu plan ha sido mejorado exitosamente.';

  @override
  String get paywallSuccessSubtitle =>
      'Ahora eres miembro Elite. Los límites cósmicos han sido eliminados para ti.';

  @override
  String get paywallErrorTitle => 'Error de Conexión';

  @override
  String get paywallErrorMessage =>
      'No se pudo conectar a la tienda o la transacción fue cancelada. Los productos pueden no estar publicados aún. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get paywallRestoreSuccess => 'Elite Restaurado';

  @override
  String get paywallRestoreSuccessSubtitle =>
      'Bienvenido de vuelta a la conciencia cósmica. Tus límites han sido eliminados.';

  @override
  String get paywallRestoreNoSub => 'Sin Suscripción Activa';

  @override
  String get paywallRestoreNoSubMessage =>
      'No se encontró ninguna membresía activa de Crack Wish Elite para restaurar. Por favor, revisa los paquetes.';

  @override
  String get paywallRestore => 'Restaurar Compras';

  @override
  String get paywallCurrentPlanBadge => 'PLAN ACTUAL';

  @override
  String get paywallLegalTr =>
      'Crack Wish Elite es una suscripción de renovación automática. El pago se cargará a tu cuenta al confirmar la compra. La suscripción se renueva automáticamente a menos que se cancele al menos 24 horas antes del final del período actual. Puedes gestionar y cancelar tus suscripciones en los ajustes de la App Store.';

  @override
  String get paywallOk => 'OK';

  @override
  String get coffeeLoading1 =>
      'Sumergiéndose en las profundidades de la taza...';

  @override
  String get coffeeLoading2 =>
      'Los símbolos en los posos se alinean con la energía universal...';

  @override
  String get coffeeLoading3 =>
      'Tus líneas del destino están siendo trazadas...';

  @override
  String get coffeeLoading4 => 'Los secretos están siendo revelados...';

  @override
  String get coffeeAiError =>
      'La IA encontró un error al interpretar la lectura.';

  @override
  String get coffeeGenericError =>
      'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get coffeeNotifReady =>
      'Se te notificará cuando tu lectura esté lista';

  @override
  String get coffeeCheckHistory => '  botón para verlo';

  @override
  String get coffeeWaitOrExplore => 'Espera aquí o explora la app';

  @override
  String get coffeeGoHome => 'Ir al Inicio';

  @override
  String get coffeeSections => 'Secciones de la Taza';

  @override
  String get coffeeSectionInside => 'Interior de la Taza';

  @override
  String get coffeeSectionInsideDesc =>
      'Tu mundo interior, pensamientos, estado emocional.';

  @override
  String get coffeeSectionEdge => 'Borde de la Taza';

  @override
  String get coffeeSectionEdgeDesc =>
      'Futuro cercano, noticias, mensajes, encuentros.';

  @override
  String get coffeeSectionBottom => 'Fondo de la Taza';

  @override
  String get coffeeSectionBottomDesc =>
      'Asuntos persistentes del pasado, cargas, temas sin resolver.';

  @override
  String get coffeeSectionSaucer => 'Platillo';

  @override
  String get coffeeSectionSaucerDesc =>
      'Deseo, resultado, destino, energía final.';

  @override
  String get coffeeLoadingComment => 'Cargando interpretación...';

  @override
  String get coffeeStoryTitle => 'La Historia Contada por los Posos';

  @override
  String get coffeeSymbolsTitle => 'Símbolos Vistos en Tu Lectura';

  @override
  String get coffeeLove => 'Amor y Relaciones';

  @override
  String get coffeeCareer => 'Carrera y Finanzas';

  @override
  String get coffeeFamily => 'Familia y Círculo Cercano';

  @override
  String get coffeeNearFuture => 'Futuro Cercano';

  @override
  String get coffeeClosing => 'Palabras Finales de Tu Lectura';

  @override
  String get coffeeShare => 'Compartir Mi Lectura';

  @override
  String get coffeeRetryValidation => 'Volver y Repetir';

  @override
  String get coffeeRetry => 'Intentar de Nuevo';

  @override
  String get coffeeCancel => 'Cancelar';

  @override
  String get coffeeSymbolLabel => 'Símbolo';

  @override
  String get coffeeSymbolLoading => 'Cargando...';

  @override
  String get coffeeTimelineSoon => 'Muy Pronto';

  @override
  String get coffeeImageError =>
      'No se pudieron detectar posos de café claros en esta imagen.';

  @override
  String get coffeeCosmicTitle => 'Lectura Cósmica de Café';

  @override
  String get coffeePremiumOnly => 'Solo Función Premium';

  @override
  String get coffeePremiumDesc =>
      'La Lectura de Café es exclusiva para miembros Elite. Mejora a Premium y descubre los secretos de tu futuro con tus Piedras del Alma.';

  @override
  String get coffeePremiumSimBtn => 'Premium (Simulación)';

  @override
  String get coffeePhotoSource => 'Fuente de Foto';

  @override
  String get coffeeCamera => 'Cámara';

  @override
  String get coffeeGallery => 'Galería';

  @override
  String get coffeeStepCupInside => 'Interior de la Taza';

  @override
  String get coffeeStepCupInsideDesc =>
      'Coloca la cámara directamente sobre la taza y captura los posos de café del interior.';

  @override
  String get coffeeStepLeftProfile => 'Perfil Izquierdo';

  @override
  String get coffeeStepLeftProfileDesc =>
      'Sujeta la taza por el asa y toma una foto clara solo del lado izquierdo.';

  @override
  String get coffeeStepRightProfile => 'Perfil Derecho';

  @override
  String get coffeeStepRightProfileDesc =>
      'Ahora captura el lado trasero derecho de la taza desde un ángulo bien iluminado.';

  @override
  String get coffeeStepSaucerSecret => 'Secreto del Platillo';

  @override
  String get coffeeStepSaucerDesc =>
      'Finalmente, captura la superficie amplia del platillo con los posos claramente visibles.';

  @override
  String get coffeeStepSaucerBtn => 'Tomar Foto del Platillo';

  @override
  String get coffeeHeaderTitle => 'LECTURA DE CAFÉ';

  @override
  String get coffeeLastReading => 'Tu Última Lectura';

  @override
  String coffeeLastReadingTime(String time) {
    return 'A las $time • Expira a medianoche';
  }

  @override
  String get coffeeNoReadingYet =>
      'Aún no has tenido una lectura.\nPrepara una taza de café,\ny deja que los posos te susurren.';

  @override
  String get coffeeSoulStones => 'Tus Piedras del Alma';

  @override
  String get coffeeSoulStoneEmpty => 'No quedan Piedras del Alma';

  @override
  String get coffeeSoulStoneRequired =>
      'Necesarias para el análisis de lectura de café';

  @override
  String get coffeeSoulStoneCost => 'Cada lectura cuesta 1 Piedra del Alma';

  @override
  String get coffeeSoulStoneEliteActive =>
      'Beneficio Elite: 5 Piedras del Alma se recargan cada noche';

  @override
  String get coffeeSoulStoneElitePromo =>
      'Hazte Elite para ganar 5 Piedras del Alma cada noche';

  @override
  String get coffeeEliteSubscribe => 'Suscribirse a Elite';

  @override
  String get coffeeRitualLabel => 'RITUAL';

  @override
  String get coffeeRitualTitle => 'Secretos de la Taza';

  @override
  String get coffeeRitualDesc =>
      'Los posos solo hablan a quienes miran de cerca. Sigue el ritual para una lectura verdadera.';

  @override
  String get coffeeRitualStep1Title => 'Establece Tu Intención';

  @override
  String get coffeeRitualStep1Desc =>
      'Mientras bebes, deja que una pregunta o deseo fluya por tu mente.';

  @override
  String get coffeeRitualStep2Title => 'Bebe de Un Solo Lado';

  @override
  String get coffeeRitualStep2Desc =>
      'Siempre bebe del mismo lado para preservar los patrones.';

  @override
  String get coffeeRitualStep3Title => 'Voltéala';

  @override
  String get coffeeRitualStep3Desc =>
      'Voltea la taza boca abajo, déjala enfriar y ábrela suavemente.';

  @override
  String get coffeeRitualListenTitle => 'Escucha el Susurro de los Posos';

  @override
  String coffeeStepLabel(String index, String title) {
    return 'Paso $index: $title';
  }

  @override
  String get coffeeDiscoverFate => 'Descubre Tu Destino';

  @override
  String get coffeeNextStep => 'Siguiente Paso';

  @override
  String get coffeeCapture => 'Capturar Este Ángulo';

  @override
  String get coffeeValidationError =>
      'Los posos en las fotos marcadas\nno pudieron ser identificados claramente.';

  @override
  String get coffeeCosmicMismatch => 'Desajuste Cósmico';

  @override
  String get coffeeCosmicCheck => 'VERIFICACIÓN DE VÍNCULO CÓSMICO';

  @override
  String get coffeeCosmicCheckDesc =>
      'Decodificando el lenguaje de los posos,\nescuchando los susurros del destino...';

  @override
  String get coffeeRevealSecrets => 'Levanta el Velo de los Secretos';

  @override
  String get coffeeReadingInProgress => 'Leyendo los Posos...';

  @override
  String get coffeeReadingWait =>
      'Las puertas del futuro se están abriendo, espera.';

  @override
  String get coffeeRelationTitle => 'Tu Estado Sentimental';

  @override
  String get coffeeRelationSubtitle =>
      'Establece la base de tu vínculo cósmico.';

  @override
  String get coffeeFocusTitle => '¿Qué Tienes en Mente?';

  @override
  String get coffeeFocusSubtitle =>
      'Elige una intención para profundizar tu lectura.';

  @override
  String get coffeeMoodTitle => '¿Tu Estado de Ánimo?';

  @override
  String get coffeeMoodSubtitle => 'Siente la energía de tu taza.';

  @override
  String get coffeeCosmicBondFormed => 'Vínculo Cósmico Formado';

  @override
  String get coffeeSecretsReady =>
      'Los secretos de tu taza están listos para ser susurrados...';

  @override
  String get coffeeNewReading => 'Nueva Lectura';

  @override
  String get coffeeAiPermission => 'Permiso de análisis de café con IA';

  @override
  String get coffeeStoneCostInfo => 'Cada análisis cuesta 1 Piedra del Alma';

  @override
  String get coffeeEliteRefillActive =>
      'Beneficio Elite: 5 Piedras del Alma se recargan cada noche';

  @override
  String get coffeeEliteRefillPromo =>
      'Hazte Elite para ganar 5 Piedras del Alma cada noche';

  @override
  String get coffeeEliteGetBtn => 'Obtener Elite';

  @override
  String get coffeeResultOnHome => 'Ver el resultado en la página de inicio  ';

  @override
  String get onboardingStart => 'Comencemos';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingContinueWithoutAccount => 'Hesap Açmadan Devam Et';

  @override
  String get onboardingFinish => 'Iniciar Viaje';

  @override
  String get onboardingNameHint => 'Un Nombre Cósmico';

  @override
  String get onboardingNamePlaceholder => 'nombre_apellido';

  @override
  String get onboardingHandleHint => 'Un Usuario Cósmico';

  @override
  String get onboardingHandlePlaceholder => 'viajero_galaxia';

  @override
  String get onboardingGenderTitle => 'Género';

  @override
  String get onboardingGenderFemale => 'Femenino';

  @override
  String get onboardingGenderMale => 'Masculino';

  @override
  String get onboardingGenderOther => 'Prefiero no decir';

  @override
  String get onboardingStep1Title => '¿Cómo debemos llamarte?';

  @override
  String get onboardingStep1Sub =>
      '¿Con qué nombre y vibración debe conocerte el universo?';

  @override
  String get onboardingAvatarSelect => 'Selecciona Tu Avatar';

  @override
  String get onboardingStep2Title => 'El momento en que tu alma llegó...';

  @override
  String get onboardingStep2Sub =>
      'Necesitamos tus datos básicos para calcular tu carta astral y rituales personalizados.';

  @override
  String get onboardingBirthDateLabel => 'Fecha de Nacimiento';

  @override
  String get onboardingBirthTimeLabel => 'Hora de Nacimiento';

  @override
  String get onboardingBirthLocationLabel => 'Ciudad de Nacimiento';

  @override
  String get onboardingTimeHint =>
      'Si conoces la hora exacta, ingrésala para un análisis detallado';

  @override
  String get onboardingLocationHint =>
      'Refina el cálculo seleccionando una ciudad';

  @override
  String get onboardingUnknownTime => 'No conozco la hora exacta';

  @override
  String get onboardingPrivacyNote =>
      'Se usa exclusivamente para trazar tu carta personalizada.';

  @override
  String get onboardingStep3Title => '¿Cuál es tu enfoque?';

  @override
  String get onboardingStep3Sub =>
      '¿Qué energía deseas más crecer o sanar en tu vida ahora mismo?';

  @override
  String get onboardingFocusLabel => 'Enfoque (Opción Múltiple)';

  @override
  String get onboardingFocusCareer => 'Carrera y Dinero';

  @override
  String get onboardingFocusLove => 'Amor y Relaciones';

  @override
  String get onboardingFocusPeace => 'Paz Interior';

  @override
  String get onboardingFocusLuck => 'Suerte y Oportunidades';

  @override
  String get onboardingRelLabel => 'Estado sentimental actual:';

  @override
  String get onboardingRelSingle => 'Cielo Solitario';

  @override
  String get onboardingRelComplicated => 'Hay Alguien...';

  @override
  String get onboardingRelTalking => 'Complicado';

  @override
  String get onboardingRelRelationship => 'Vínculo Feliz';

  @override
  String get onboardingStep4Title =>
      'Tu conexión con el universo por la noche...';

  @override
  String get onboardingStep4Sub =>
      '¿Cómo recibe tu subconsciente los mensajes? Los colores y sueños nos darán pistas.';

  @override
  String get onboardingDreamLabel =>
      '¿Con qué frecuencia recuerdas tus sueños?';

  @override
  String get onboardingDreamOften => 'A Menudo y Claramente';

  @override
  String get onboardingDreamSometimes => 'A Veces';

  @override
  String get onboardingDreamRarely => 'Raramente';

  @override
  String get onboardingDreamNever => 'Nunca';

  @override
  String get onboardingAuraLabel =>
      'El Aura de Tu Alma (¿Cómo te sientes hoy?)';

  @override
  String get onboardingStep5Title => 'Tu danza con el tiempo...';

  @override
  String get onboardingStep5Sub =>
      '¿Cuándo es tu energía más alta? Ajustaremos tus notificaciones en consecuencia.';

  @override
  String get onboardingSleepLabel => 'Tu Patrón de Sueño';

  @override
  String get onboardingSleepMorning => 'Madrugador';

  @override
  String get onboardingSleepNight => 'Noctámbulo';

  @override
  String get onboardingSleepIrregular => 'Irregular';

  @override
  String get onboardingSleepLittle => 'Duermo Muy Poco';

  @override
  String get onboardingMatchLabel => 'Emparejamiento y Conexión Cósmica';

  @override
  String get onboardingMatchDesc =>
      'Quiero estar abierto a conectar con perfiles sinérgicos y coincidencias cósmicas especiales.';

  @override
  String get onboardingFinalTitle => 'Todo está listo...';

  @override
  String get onboardingFinalSub =>
      'Estás a punto de descubrir lo que las estrellas han planeado para ti. Crea tu cuenta y entra al universo cósmico.';

  @override
  String get onboardingAppleCreate => 'Crear Cuenta con Apple';

  @override
  String get onboardingGoogleCreate => 'Crear Cuenta con Google';

  @override
  String get onboardingErrorIncomplete =>
      '¡Bienvenido! Solo faltan unos pasos para completar tu perfil.';

  @override
  String get onboardingErrorFailed =>
      'Error de inicio de sesión. Por favor, inténtalo de nuevo.';

  @override
  String onboardingErrorAlreadyExists(String provider) {
    return '¡Ya tienes un perfil cósmico con esta cuenta de $provider! Por favor, usa la opción \'Iniciar Sesión\' en la primera página.';
  }

  @override
  String onboardingErrorDBRejected(String error) {
    return 'Registro rechazado por la base de datos:\n$error\nPor favor, contacta soporte.';
  }

  @override
  String get onboardingErrorHandleTaken =>
      'Este nombre de usuario ya está en uso';

  @override
  String get notifTitle => 'Notificaciones';

  @override
  String get notifSubtitle => 'Elige qué notificaciones quieres recibir';

  @override
  String get notifAnnouncements => 'Anuncios';

  @override
  String get notifAnnouncementsDesc => 'Nuevas funciones y actualizaciones';

  @override
  String get notifSounds => 'Sonidos';

  @override
  String get notifSoundsDesc => 'Alertas de notificación con sonido';

  @override
  String get notifCookieAlarm => 'Alarma de Nueva Galleta';

  @override
  String get notifCookieAlarmDesc =>
      'Cuando llega una nueva galleta de la fortuna';

  @override
  String get notifFriendAlarm => 'Alarma de Amigo';

  @override
  String get notifFriendAlarmDesc => 'Nuevas conexiones de la Red del Búho';

  @override
  String get notifDailyReminder => 'Recordatorios Diarios';

  @override
  String get notifDailyReminderDesc => 'No olvides tu galleta diaria';

  @override
  String get accountTitle => 'Detalles de la Cuenta';

  @override
  String get accountSubtitle => 'Información personal y gestión de cuenta';

  @override
  String get accountUsername => 'Nombre de Usuario';

  @override
  String get accountLinkedEmail => 'Email Vinculado';

  @override
  String get accountSignInMethod => 'Método de Inicio de Sesión';

  @override
  String get accountDeleteTitle => 'Eliminar Cuenta';

  @override
  String get accountDeleteDesc =>
      'Todos tus datos serán eliminados permanentemente.\nEsta acción no se puede deshacer.';

  @override
  String get accountDeleteCancel => 'Cancelar';

  @override
  String get accountDeleteConfirm => 'Eliminar';

  @override
  String get accountDeletePermanent => 'Eliminar Cuenta Permanentemente';

  @override
  String get welcomeTagline => 'La magia está dentro de ti.';

  @override
  String get welcomeAppleContinue => 'Continuar con Apple';

  @override
  String get welcomeGoogleContinue => 'Continuar con Google';

  @override
  String get moodGuideTitle => 'Guía de Ánimo';

  @override
  String get moodAwarenessTitle => 'Conciencia Emocional';

  @override
  String get moodAwarenessDesc =>
      'Elegir tu estado de ánimo hace tus sentimientos concretos; este es el primer paso para encontrar equilibrio interior y autoconocimiento.';

  @override
  String get moodCosmicTitle => 'Frecuencia Cósmica';

  @override
  String get moodCosmicDesc =>
      'Cada emoción que eliges en la rueda lleva una frecuencia. El aura de la pantalla se alinea directamente con tus sentimientos.';

  @override
  String get moodHowToTitle => '¿Cómo Usar?';

  @override
  String get moodHowToDesc =>
      'Simplemente gira la rueda y elige la expresión que mejor refleje tu estado de ánimo. No juzgues tu sentimiento, simplemente siéntelo y acéptalo.';

  @override
  String get moodQuestionAlt => '¿Cómo está tu ánimo hoy?';

  @override
  String get moodSpinHint => 'Gira la rueda, elige tu ánimo ✨';

  @override
  String get bentoCoffeeTitle => 'Lectura de Café';

  @override
  String get bentoCoffeeDesc => 'Susurros de los posos';

  @override
  String get bentoUnexplored => 'Este reino espera ser explorado...';

  @override
  String get bentoSealed => 'Sellado';

  @override
  String get horoscopeDailyEnergy => 'Energía de Hoy';

  @override
  String get horoscopeWestern => 'Ast. Occidental';

  @override
  String get horoscopeAsian => 'Sabiduría Asiática';

  @override
  String get horoscopeMayan => 'Espíritu Maya';

  @override
  String get shareSaved => 'Guardado ✓';

  @override
  String get shareDownload => 'Descargar';

  @override
  String get shareShare => 'Compartir';

  @override
  String get shareStory => 'Historia';

  @override
  String get sharePost => 'Publicar';

  @override
  String get shareCookieText =>
      '¡Esto es lo que me salió de la galleta de la fortuna hoy! 🥠✨\n#CrackWish';

  @override
  String get shareCoffeeTitle => 'Lectura de Café';

  @override
  String get cookieLockedTitle => 'Esta galleta especial está bloqueada';

  @override
  String get cookieComingSoon => 'Próximamente ✨';

  @override
  String get dreamWaitOrReturn =>
      'Puedes esperar aquí o volver a la página de inicio. Te notificaremos cuando esté listo, y podrás leerlo desde la sección \"Mis Sueños\".';

  @override
  String get dreamReturnHome => 'Volver a la Página de Inicio';

  @override
  String get profileEditProfile => 'Editar Perfil';

  @override
  String get profileEditSubtitle =>
      'Editar nombre, zodíaco e información personal';

  @override
  String get profileSearchHint =>
      'Buscar zodíaco, ciudad o fecha de nacimiento...';

  @override
  String get profileStoreUnavailable =>
      'El enlace de la tienda no está disponible.';

  @override
  String get profileMailNotFound =>
      'No se encontró app de correo. Puedes escribir a support@crackandwish.com';

  @override
  String get profileRitualCode => 'Código Ritual';

  @override
  String get profileRitualDesc =>
      'Este código es tu identidad ritual personal. Compártelo con amigos para invitarlos a la Red del Búho.';

  @override
  String get profileRitualCopied => 'Código Ritual Copiado ✨';

  @override
  String get profileRitualInfo => '¡Comparte con amigos, exploren juntos!';

  @override
  String get profileShareCode => 'Compartir Código';

  @override
  String get profileDeleteAccount => 'Eliminar Cuenta';

  @override
  String get profileDeleteDesc =>
      'Todos tus datos serán eliminados permanentemente.\nEsta acción no se puede deshacer.';

  @override
  String get profileDeleteCancel => 'Cancelar';

  @override
  String get profileDeleteConfirm => 'Eliminar Cuenta';

  @override
  String get profileSignOut => 'Cerrar Sesión';

  @override
  String get profileSignOutDesc =>
      'Cierra sesión de tu cuenta de forma segura.\nTus datos serán preservados.';

  @override
  String get profileSignOutCancel => 'Cancelar';

  @override
  String get profileSignOutConfirm => 'Cerrar Sesión';

  @override
  String get profilePrivacyPolicy => 'Política de Privacidad';

  @override
  String get profileTermsOfUse => 'Términos de Uso';

  @override
  String get profileGetElite => 'Obtener Elite';

  @override
  String get profileGetEliteSubtitle => 'Puerta hacia la conciencia';

  @override
  String get profileCosmicProfile => 'Perfil Cósmico';

  @override
  String get profileCosmicSubtitle => 'Carta, Hora y Ubicación';

  @override
  String get profileSectionAccount => 'Cuenta';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileNotificationSettings => 'Ajustes de Notificaciones';

  @override
  String get profileRestorePurchases => 'Restaurar Compras';

  @override
  String get profileRestoreSuccess => '¡Compras restauradas exitosamente!';

  @override
  String get profileRestoreFail => 'No se encontraron compras para restaurar.';

  @override
  String get profileHelp => 'Ayuda';

  @override
  String get profileShare => 'Compartir';

  @override
  String get profileRate => 'Calificar';

  @override
  String get profileVersion => 'Versión';

  @override
  String get profileCosmicName => 'Nombre Cósmico';

  @override
  String get profileSealProfile => 'Sellar Perfil';

  @override
  String get profileChooseAvatar => 'Elige tu avatar mágico.';

  @override
  String get profileStrengthenBonds => 'Fortalecer Vínculos';

  @override
  String get profileStrengthenBondsDesc =>
      'Expande el universo cósmico con amigos.';

  @override
  String get profileEarnSoulStones => 'Ganar +2 Piedras del Alma';

  @override
  String get profileCodeCopied => '¡Código copiado!';

  @override
  String get profileNotifications => 'Notificaciones';

  @override
  String get profileSupportExperience => 'Soporte y Experiencia';

  @override
  String get profileSeerNovice => 'Vidente Novato';

  @override
  String get profileSeerApprentice => 'Vidente Aprendiz';

  @override
  String get profileSeer => 'Vidente';

  @override
  String get profileSeerWise => 'Vidente Sabio';

  @override
  String get profileSeerMaster => 'Vidente Maestro';

  @override
  String get profileSeerCosmic => 'Vidente Cósmico';

  @override
  String get profileUploadFailed =>
      '¡Fallo al subir la foto! Por favor, verifica tu conexión.';

  @override
  String get profileCropTitle => 'Recorte Cósmico';

  @override
  String get profileCropCancel => 'Cancelar';

  @override
  String get profileCropDone => 'Listo';

  @override
  String get moderationAdultContent =>
      'La energía de esta imagen no es compatible con nuestro universo Cósmico (Contenido Inapropiado).';

  @override
  String get moderationViolence =>
      'Por favor, elige un avatar más tranquilo que refleje tu aura y no fatigue la mente (Contenido Perturbador).';

  @override
  String get moderationTooLarge =>
      'La imagen es lo suficientemente grande como para sobrecargar la red cósmica. Por favor, selecciona una foto de menos de 5MB.';

  @override
  String get moderationInvalidFormat =>
      'Tu foto no pudo ser leída por nuestro pergamino mágico, el formato está corrupto.';

  @override
  String get moderationUnknown =>
      'Ocurrió una fluctuación cósmica desconocida.';

  @override
  String profileShareInvite(String code) {
    return '¡Únete al universo de Crack&Wish! ✨\nMi Código Ritual: $code\n\n¡Ingresa este código para ganar +1 Piedra del Alma, +50 Aura y una Galleta Premium sorpresa!\nhttps://crackandwish.com';
  }

  @override
  String get profileShareApp =>
      '¡Descubre tu fortuna con Crack&Wish! ✨\nAbre galletas, lee tarot, interpreta sueños.\n\nhttps://crackandwish.com';

  @override
  String get profileEliteYouAre => 'Eres Elite';

  @override
  String get profileGoElite => 'Hazte Elite';

  @override
  String get profileEliteMystical => 'Ver puertas místicas';

  @override
  String get profileEliteDoor => 'Puerta hacia la conciencia';

  @override
  String get profileMyCosmicProfile => 'Mi Perfil Cósmico';

  @override
  String get profileCosmicDetails => 'Detalles de Carta, Hora y Lugar';

  @override
  String get profileRestorePurchasesBtn => 'Restaurar Compras';

  @override
  String get profileRestoreSubtitle => 'Restaurar tus compras anteriores';

  @override
  String get profileInviteFriends => 'Invitar Amigos';

  @override
  String get profileInviteFriendsDesc =>
      'Construye vínculos cósmicos, ganen juntos';

  @override
  String get cosmicChart => 'Carta Cósmica';

  @override
  String get cosmicWestern => 'OCCIDENTAL';

  @override
  String get cosmicAsian => 'ASIÁTICA';

  @override
  String get cosmicMayan => 'MAYA';

  @override
  String get cosmicRising => 'ASCENDENTE';

  @override
  String get cosmicArrivalDate => 'FECHA DE LLEGADA';

  @override
  String get cosmicBirthTime => 'HORA DE NACIMIENTO';

  @override
  String get cosmicTimeUnknown => 'Hora Desconocida';

  @override
  String get cosmicBirthPlace => 'COORDENADAS DEL LUGAR DE NACIMIENTO';

  @override
  String get cosmicCountry => 'País';

  @override
  String get cosmicSelectCountry => 'Seleccionar País';

  @override
  String get cosmicCityDistrict => 'Ciudad, Distrito y Pueblo';

  @override
  String get cosmicSelectDateFirst =>
      'Por favor, selecciona primero tu fecha de nacimiento.';

  @override
  String cosmicLockedDays(int days) {
    return 'Bloqueado por $days Días';
  }

  @override
  String get cosmicSave => 'Guardar';

  @override
  String get cosmicSearchLocation => 'Buscar Ubicación Exacta';

  @override
  String get cosmicSearchHint => 'Ingresa pueblo, distrito, etc...';

  @override
  String get cosmicAddFreeText => 'Agregar como texto libre';

  @override
  String get cosmicRequiresTime => 'Requiere Hora';

  @override
  String get badgeReady => 'LISTO';

  @override
  String get badgeNew => 'NUEVO';

  @override
  String get paywallLegal =>
      'Crack Wish Elite es una suscripción de renovación automática. El pago se cargará a tu cuenta al confirmar la compra. La suscripción se renueva automáticamente a menos que se cancele al menos 24 horas antes del final del período actual. Puedes gestionar y cancelar tus suscripciones en los ajustes de la App Store.';

  @override
  String get cosmicSelect => 'Seleccionar';

  @override
  String get coffeeRelSingle => 'Alma Solitaria';

  @override
  String get coffeeRelInLove => 'Corazón Lleno';

  @override
  String get coffeeRelEngaged => 'Comprometido';

  @override
  String get coffeeRelMarried => 'Casado';

  @override
  String get coffeeRelComplicated => 'Complicado';

  @override
  String get coffeeFocusLove => 'Amor y Armonía';

  @override
  String get coffeeFocusCareer => 'Carrera y Finanzas';

  @override
  String get coffeeFocusHealing => 'Sanación y Paz';

  @override
  String get coffeeFocusGeneral => 'Futuro General';

  @override
  String get coffeeFocusSurprise => 'Sorpréndeme';

  @override
  String get coffeeMoodPeaceful => 'Tranquilo';

  @override
  String get coffeeMoodExcited => 'Emocionado';

  @override
  String get coffeeMoodAnxious => 'Ansioso';

  @override
  String get coffeeMoodIndecisive => 'Indeciso';

  @override
  String get coffeeMoodEnergetic => 'Enérgico';

  @override
  String get coffeeMoodMelancholic => 'Melancólico';

  @override
  String get coffeeAllPhotosRequired => '¡Por favor, toma todas las fotos!';

  @override
  String get coffeeNotEnoughStones => '¡No hay suficientes Piedras del Alma!';

  @override
  String coffeeSoulStoneCount(int count) {
    return '$count Piedras del Alma disponibles';
  }

  @override
  String get coffeeUseSoulStone => 'Usar 1 Piedra del Alma';

  @override
  String get languageSettingsSubtitle => 'Elige el idioma de la app';

  @override
  String get cosmicSearchHintShort => 'Buscar...';

  @override
  String get cosmicAddThis => 'Agregar esto';

  @override
  String get horoscopeWesternText =>
      'Las estrellas se alinean para tu carrera. Da pasos rápidos y decisivos.';

  @override
  String get horoscopeAsianText =>
      'El elemento agua está activo. Tu intuición es fuerte, solo escucha tu corazón.';

  @override
  String get horoscopeMayanText =>
      'El Tono 4 está activo. Un día perfecto para establecer orden y planificar tu vida.';

  @override
  String get horoscopeExplore => 'Explorar';

  @override
  String get cookieDayCompleted => 'Día Completado';

  @override
  String get cookieSeeYouTomorrow => 'Nos vemos mañana con nuevas galletas.';

  @override
  String get cookieRarityLegendary => 'Legendario';

  @override
  String get cookieRarityRare => 'Raro';

  @override
  String get cookiePremiumCollection => 'Colección Premium';

  @override
  String cookiePurchaseBtn(String price) {
    return 'Comprar ($price)';
  }

  @override
  String get cookieTapOutsideToClose => 'Toca fuera para cerrar';

  @override
  String get cookieAddedToCollection =>
      '¡Galleta agregada exitosamente a tu colección!';

  @override
  String get cookiePremiumFallback => 'Galleta Premium';

  @override
  String get dreamSoulStoneRequired => 'Piedra del Alma Requerida';

  @override
  String get dreamSoulStoneRequiredDesc =>
      'Se requieren Piedras del Alma para el análisis profundo.\n\nPuedes ganar Piedras del Alma convirtiendo puntos de Aura o con la suscripción Elite.';

  @override
  String get dreamGetElite => 'Obtener Elite';

  @override
  String get dreamClinicalGateTitle => 'Puerta de Análisis Clínico';

  @override
  String dreamClinicalGateDesc(int soulStones) {
    return 'Piedras del Alma actuales: $soulStones\n\nEste psicoanálisis profundo de nivel clínico cuesta 1 Piedra del Alma.';
  }

  @override
  String get dreamUseOneStone => 'Usar 1 Piedra';

  @override
  String get dreamDeepAnalysisBgPreparing =>
      'El Análisis Profundo se está preparando en segundo plano. Recibirás una notificación cuando esté listo.';

  @override
  String get dreamYourSoulStones => 'Tus Piedras del Alma';

  @override
  String dreamSoulStonesRemaining(int count) {
    return '$count Piedras del Alma restantes';
  }

  @override
  String get dreamSoulStonesEmpty => 'Sin Piedras del Alma';

  @override
  String get dreamRequiredForDeep => 'Necesarias para el Análisis Profundo';

  @override
  String get dreamEachAnalysisCost => 'Cada análisis cuesta 1 Piedra del Alma';

  @override
  String get dreamEliteRefillActive =>
      'Elite recarga 5 Piedras del Alma cada noche';

  @override
  String get dreamEliteRefillPromo =>
      'Obtén 5 Piedras del Alma diarias con Elite';

  @override
  String get dreamWatchAd => 'Ver Anuncio';

  @override
  String get dreamBgAnalyzing =>
      'Tu sueño se está analizando en segundo plano. Recibirás una notificación cuando esté listo.';

  @override
  String get dreamDeepAnalysis => 'Análisis Profundo';

  @override
  String get dreamDiscoverSecrets => 'Descubre secretos';

  @override
  String get dreamDidYouKnow => '¿Sabías que?';

  @override
  String get dreamNeuroPsychAnalysis => 'ANÁLISIS NEURO-PSICOLÓGICO';

  @override
  String get dreamYourDream => 'TU SUEÑO';

  @override
  String get dreamEmotionalProfile => 'Perfil Emocional';

  @override
  String get dreamEmotionalProfileSub => 'Capas psicológicas durante el sueño';

  @override
  String get dreamShadowSelf => 'Yo Sombra';

  @override
  String get dreamShadowSelfSub =>
      'Aspectos suprimidos e inexplorados del subconsciente';

  @override
  String get dreamRecurringPatterns => 'Patrones Recurrentes';

  @override
  String get dreamRecurringPatternsSub =>
      'Bucles recurrentes y bloqueos psicológicos';

  @override
  String dreamSuggestedRitual(String title) {
    return 'Ritual Sugerido: $title';
  }

  @override
  String get dreamSuggestedRitualSub =>
      'Una acción especializada para gestionar el impacto de este sueño';

  @override
  String get dreamScienceNote => 'Nota Científica:';

  @override
  String get dreamWriteNewDream => 'Escribir un Nuevo Sueño';

  @override
  String get dreamNoMonthDreams => 'Aún no se han escrito sueños este mes ✨';

  @override
  String get dreamMysteriousDream => 'Sueño Misterioso';

  @override
  String get dreamStandardAnalysis => 'ANÁLISIS ESTÁNDAR';

  @override
  String get dreamGeneralAnalysis => 'Análisis General';

  @override
  String get dreamPsychological => 'Psicológico';

  @override
  String get dreamSpiritual2 => 'Espiritual';

  @override
  String get dreamAdvice => 'Consejo';

  @override
  String get dreamDeepenedInsights => 'Perspectivas Profundizadas';

  @override
  String get dreamEliteCreditsTitle => 'Créditos Elite';

  @override
  String get dreamReadingCreditsTitle => 'Tus Créditos de Lectura';

  @override
  String dreamCreditsRemaining(int count) {
    return '$count créditos restantes';
  }

  @override
  String get dreamDailyLimitReached => 'Límite diario alcanzado';

  @override
  String get dreamZeroCredits => '0 créditos restantes';

  @override
  String dreamDailyPremiumReads(int count) {
    return '$count interpretaciones de Sueños diarias';
  }

  @override
  String get dreamNoAdsRequired => 'No necesitas ver anuncios';

  @override
  String get dreamCreditsResetNightly => 'Los créditos se reinician cada noche';

  @override
  String get dreamOneFreeDaily => '1 interpretación gratis cada día';

  @override
  String dreamWatchAdsForCredits(int maxAds, int watched) {
    return 'Ve anuncios para $maxAds créditos extra ($watched/$maxAds)';
  }

  @override
  String get dreamUnconsciousFrequencies => 'FRECUENCIAS INCONSCIENTES';

  @override
  String get dreamOrbEmotion => 'EMOCIÓN';

  @override
  String get dreamOrbEntropy => 'ENTROPÍA';

  @override
  String get dreamOrbActivity => 'ACTIVIDAD';

  @override
  String get dreamOrbResidue => 'RESIDUO';

  @override
  String get dreamHighConfidence => 'Alta Confianza';

  @override
  String get dreamModerateConfidence => 'Confianza Moderada';

  @override
  String get dreamLowConfidence => 'Baja Confianza';

  @override
  String get dreamCoreThematicPattern => 'PATRÓN TEMÁTICO CENTRAL';

  @override
  String get dreamMetricEmotionalLoad => 'Carga\nEmocional';

  @override
  String get dreamMetricEmotionalLoadDesc =>
      'Cuán intensamente se activó el centro emocional de tu cerebro durante este sueño.';

  @override
  String get dreamMetricUncertaintyDesc =>
      'Cuán ilógica o inconsistente fue la narrativa de tu sueño.';

  @override
  String get dreamMetricRecentMemory => 'Conexión\nReciente';

  @override
  String get dreamMetricRecentMemoryDesc =>
      'Cuánto de tu sueño fue influenciado por eventos recientes de la vida real.';

  @override
  String get dreamMetricAgency => 'Agencia /\nControl';

  @override
  String get dreamMetricAgencyDesc =>
      'Cuánto control tuviste sobre los eventos en tu sueño.';

  @override
  String get dreamSeverityHigh => 'Alto';

  @override
  String get dreamSeverityNormal => 'Normal';

  @override
  String get dreamSeverityLow => 'Bajo';

  @override
  String get dreamCognitiveDistribution => 'DISTRIBUCIÓN COGNITIVA';

  @override
  String get dreamTapToExpand => 'TOCA PARA EXPANDIR';

  @override
  String get dreamNeurologicalBasis => 'Base Neurológica';

  @override
  String get dreamEvidenceBase => 'BASE DE EVIDENCIA';

  @override
  String get dreamRootCause => 'Causa Raíz';

  @override
  String get dreamAbsolutely => 'Absolutamente';

  @override
  String get dreamMaybe => 'Tal Vez';

  @override
  String get dreamNotSure => 'No Estoy Seguro';

  @override
  String get dreamDreamEssence => 'ESENCIA DEL SUEÑO';

  @override
  String get dreamClarifyingResponses => 'RESPUESTAS CLARIFICADORAS';

  @override
  String get dreamCosmicRhythmSynced => 'Ritmo Cósmico Sincronizado';

  @override
  String get dreamCosmicRhythmSyncedDesc =>
      'Recibirás indicaciones de sueño personalizadas basadas en tu ciclo de sueño.';

  @override
  String get dreamSyncSleepData => 'Sincronizar Datos de Sueño';

  @override
  String get dreamSyncSleepDataDesc =>
      'Permítele detectar cuándo despiertas para preguntarte sobre tu sueño más profundo.';

  @override
  String get dreamAwarenessFallback =>
      'Esta conciencia es el inicio de un nuevo camino. Es hora de enfrentarlo.';

  @override
  String get dreamExtractingEssence => 'Extrayendo la esencia del sueño...';

  @override
  String get dreamNoReasoning => 'No se generó razonamiento.';

  @override
  String get dreamNotAnalyzable =>
      '¿Estás seguro de que fue un sueño?\nPor favor, describe una escena real que experimentaste mientras dormías.';

  @override
  String get owlTabFriends => 'Mis Amigos';

  @override
  String get owlTabConnections => 'Conexiones';

  @override
  String get owlTabInbox => 'Bandeja';

  @override
  String get owlSearchCosmic => 'Buscar universo cósmico...';

  @override
  String get owlSearchFriends => 'Buscar amigos...';

  @override
  String get owlPhoneContacts => 'Contactos del Teléfono';

  @override
  String get owlNoOneFoundCosmic =>
      'No se encontró a nadie en el universo cósmico.';

  @override
  String get owlFoundInCosmic => 'Encontrado en el Universo Cósmico';

  @override
  String get owlUnknownProfile => 'Perfil Desconocido';

  @override
  String owlFriendRequestSent(String name) {
    return '¡Solicitud de amistad enviada a $name!';
  }

  @override
  String get owlRequestSentStatus => 'Enviado';

  @override
  String get owlSendRequestAction => 'Enviar Solicitud';

  @override
  String get owlConnectContacts => 'Conectar Contactos';

  @override
  String get owlConnectContactsDesc =>
      'Encuentra a tus amigos al instante.\nTus contactos NUNCA se almacenan en servidores.';

  @override
  String get owlNoContactsFound =>
      'No Pudimos Encontrar a Nadie\nen el Universo Crack&Wish';

  @override
  String get owlNoContactsFoundDesc =>
      '¡Puedes iniciar la energía cósmica invitándolos!';

  @override
  String get owlUnknown => 'Desconocido';

  @override
  String get owlAppUserLabel => 'Usuario de Crack&Wish';

  @override
  String get owlInContactsLabel => 'En tus contactos';

  @override
  String get owlNoFriendsYet => 'Aún no hay amigos';

  @override
  String get owlNoResultsFound => 'No se encontraron resultados';

  @override
  String get owlFriendRequests => 'Solicitudes de Amistad';

  @override
  String get owlFriendsHeader => 'Tus Amigos';

  @override
  String get owlAcceptAction => 'Aceptar';

  @override
  String get owlRejectAction => 'Rechazar';

  @override
  String get owlInviteReward => '+2 Piedras del Alma';

  @override
  String owlInviteShareMessage(String username) {
    return '¡Iluminemos la oscuridad juntos! ✨\nÚnete a Crack Wish a través de mi enlace de invitación, conéctate automáticamente y ¡gana Recompensas de Inicio!\n\nMi Enlace de Invitación:\nhttps://crackwish.com/invite/$username';
  }

  @override
  String get owlInviteFriends => 'Invitar Amigos';

  @override
  String get owlInviteFriendsDesc => 'Refleja el universo cósmico';

  @override
  String get owlNoLettersYet => 'Aún no hay cartas';

  @override
  String owlLetterSentNotification(String name) {
    return '$name envió una carta...';
  }

  @override
  String get owlOnItsWay => 'El búho va en camino 🕊️';

  @override
  String owlLetterCount(int count) {
    return '$count cartas';
  }

  @override
  String owlUnreadCountBadge(int count) {
    return '$count Nuevos';
  }

  @override
  String get owlIUnderstand => 'Entendido';

  @override
  String get owlInviteHowTitle => '¿Cómo Te Gustaría Invitar?';

  @override
  String get owlInviteHowSubtitle =>
      '¿Cómo quieres enviar tu llave cósmica a esta persona?';

  @override
  String get owlInviteSendAsMessage => 'Enviar como mensaje';

  @override
  String get owlInviteSMSSubtitle => 'Enviar por mensaje clásico';

  @override
  String get owlInviteOtherApps => 'Otras Apps';

  @override
  String get owlInviteOtherAppsSubtitle => 'Instagram, TikTok, X, etc.';

  @override
  String get owlWhatsAppNotFound => 'WhatsApp no encontrado';

  @override
  String get owlSMSNotFound => 'App de SMS no encontrada';

  @override
  String get owlDisconnectAction => 'Desconectar';

  @override
  String owlDisconnectConfirm(String name) {
    return '¿Estás seguro de que quieres romper el vínculo mágico con $name?';
  }

  @override
  String get owlDisconnectConfirmButton => 'Sí, Desconectar';

  @override
  String get owlCancel => 'Cancelar';

  @override
  String get owlSendMagic => 'Enviar (Encantado)';

  @override
  String get owlSend => 'Enviar';

  @override
  String get owlCookieAdded => 'Galleta Agregada';

  @override
  String get owlAddCookie => 'Agregar Galleta';

  @override
  String get owlNoCookiesInCollection => 'No hay galletas en tu colección';

  @override
  String get owlWriteLetterHint => 'Escribe tu carta...';

  @override
  String get owlSendCookie => 'Enviar Galleta';

  @override
  String get zodiacMeasureHarmony => 'MEDIR LA ARMONÍA CÓSMICA';

  @override
  String get zodiacDiscoverEnergy =>
      'Descubre tu energía dual guiada por las estrellas';

  @override
  String get zodiacChooseFriend => 'ELEGIR AMIGO';

  @override
  String get zodiacChooseFriendSubtitle =>
      'Selecciona un amigo para comparar sus energías cósmicas';

  @override
  String get zodiacDiscoverYourself => 'Descúbrete';

  @override
  String get zodiacCharacteristicAnalysis => 'ANÁLISIS DE CARACTERÍSTICAS';

  @override
  String zodiacAbilityMap(String name) {
    return 'Mapa de habilidades de $name';
  }

  @override
  String get zodiacPros => 'Ventajas';

  @override
  String get zodiacCons => 'Desafíos';

  @override
  String get zodiacAdvice => 'Consejo';

  @override
  String get zodiacDailyWhisperSubtitle =>
      'Siente el susurro de hoy y\ndesvela los secretos de tu retrato espiritual.';

  @override
  String get zodiacDailyWhisperHeadline =>
      'Mensaje de hoy y retrato espiritual';

  @override
  String get zodiacOpenGuide => 'Abrir la Guía';

  @override
  String get zodiacNoFriends => 'Aún no hay amigos';

  @override
  String get zodiacSelect => 'SELECCIONAR';

  @override
  String get zodiacQuestCompleted => 'Misión Completada';

  @override
  String get zodiacQuestCompletedSubtitle =>
      'Estás completamente alineado con el ritmo del universo.';

  @override
  String get zodiacRewardAura => 'Recompensa Obtenida:\n+4 AURA';

  @override
  String get zodiacStartNewQuest => 'INICIAR NUEVA MISIÓN';

  @override
  String zodiacDailyQuestTitle(int days) {
    return 'MISIÓN DE $days DÍAS';
  }

  @override
  String zodiacDailyQuestDesc(String weakness) {
    return 'Rompe Tu Debilidad: \"$weakness\"';
  }

  @override
  String zodiacQuestDayProgress(int current, int total) {
    return 'DÍA $current / $total';
  }

  @override
  String get zodiacQuestTodayDiscovery => 'DESCUBRIMIENTO DE HOY';

  @override
  String get zodiacQuestCompletedToday => 'COMPLETADO HOY';

  @override
  String get zodiacQuestCompleteNow => 'COMPLETAR MISIÓN AHORA';

  @override
  String get zodiacQuestMarkCompleted => 'COMPLETÉ HOY';

  @override
  String get zodiacLoveHarmony => 'ARMONÍA DE AMOR';

  @override
  String get zodiacFriendshipHarmony => 'AMISTAD';

  @override
  String get zodiacCommunicationHarmony => 'COMUNICACIÓN Y MENTE';

  @override
  String get zodiacWorkHarmony => 'COLABORACIÓN';

  @override
  String get zodiacAdventureHarmony => 'AVENTURA Y DIVERSIÓN';

  @override
  String get zodiacViralDynamics => 'DINÁMICAS VIRALES';

  @override
  String get zodiacDeepSynastryMap => 'MAPA DE SINASTRÍA PROFUNDA';

  @override
  String zodiacSynastrySubtitle1(String name) {
    return 'La armonía entre tú y $name no se limita a los signos solares.';
  }

  @override
  String get zodiacSynastrySubtitle2 =>
      'Basándose en la privacidad, el algoritmo cósmico cruza cartas astrales, fases lunares y ascendentes en segundo plano, haciendo este análisis completamente único para ti.';

  @override
  String get zodiacDailyWhisperTitle => 'Susurro de Hoy';

  @override
  String get zodiacChooseSign => 'ELEGIR SIGNO';

  @override
  String get zodiacCosmicGuide => 'TU GUÍA CÓSMICA';

  @override
  String get zodiacNew => 'NUEVO';

  @override
  String get zodiacCosmicHarmonyTitle => 'ARMONÍA CÓSMICA';

  @override
  String get zodiacAwesome => 'INCREÍBLE';

  @override
  String get zodiacSpiritPortrait => 'Retrato Espiritual';

  @override
  String get onboardingFeatureStepTitle => '¿Qué Te Espera?';

  @override
  String get onboardingFeatureStepSub =>
      '¿Estás listo para escuchar los susurros del universo y descubrir tu destino?';

  @override
  String get onboardingNameStepTitle => 'Vamos a Conocerte';

  @override
  String get onboardingNameStepSub =>
      'Crea tu perfil y determina tu identidad cósmica para que tus almas gemelas puedan encontrarte.';

  @override
  String get onboardingDateStepTitle => 'Coordenada Cósmica';

  @override
  String get onboardingDateStepSub =>
      'Elige el momento en que naciste para la base de tu carta astrológica.';

  @override
  String get onboardingFocusStepTitle => 'Brújula del Corazón';

  @override
  String get onboardingFocusStepSub =>
      'Establece tu intención, mapeemos tu camino.';

  @override
  String get onboardingDreamStepTitle => 'Voz del Subconsciente';

  @override
  String get onboardingDreamStepSub => '¿Cómo te llegan tus sueños?';

  @override
  String get onboardingSleepStepTitle => 'Tu Brújula Interior';

  @override
  String get onboardingSleepStepSub =>
      '¿Cómo encuentras tu camino durante los puntos de inflexión del destino en tu vida?';

  @override
  String get onboardingFeatureAstrology => 'Carta Astrológica Personalizada';

  @override
  String get onboardingFeatureTarot => 'Viaje de Tarot Guiado';

  @override
  String get onboardingFeatureCoffee =>
      'Secretos Ancestrales de la Lectura de Café';

  @override
  String get onboardingFeatureDream => 'Análisis de Sueños del Subconsciente';

  @override
  String get onboardingFeatureZodiac =>
      'Compatibilidades Místicas Chinas y Mayas';

  @override
  String get onboardingWelcomeTagline =>
      'Hoy mis esperanzas son más grandes que mis sueños.';

  @override
  String get onboardingFinalTagline =>
      'Haz clic para asegurar tu carta cósmica.';

  @override
  String get tarotShareText =>
      '¡Las cartas me hablaron así! 🔮✨\n#CrackWish #Tarot';

  @override
  String get natalChartTitle => 'Carta Natal';

  @override
  String get natalChartCalculating => 'Calculando tu carta natal...';

  @override
  String get natalChartSwipeHint => 'Desliza para Inspeccionar';

  @override
  String get natalChartPlanetPositions => 'POSICIONES PLANETARIAS';

  @override
  String get natalChartAngularPoints => 'PUNTOS ANGULARES';

  @override
  String get natalChartAsc => 'ASC (Ascendente)';

  @override
  String get natalChartAscDesc =>
      'La máscara que muestras al mundo exterior, tu imagen y tu primera impresión.';

  @override
  String get natalChartMc => 'MC (Medio Cielo)';

  @override
  String get natalChartMcDesc =>
      'Tu carrera, tu imagen pública y tus metas de vida.';

  @override
  String get natalChartDc => 'DC (Descendente)';

  @override
  String get natalChartDcDesc =>
      'Los rasgos esenciales que buscas en relaciones, matrimonio y asociaciones.';

  @override
  String get natalChartIc => 'IC (Fondo del Cielo)';

  @override
  String get natalChartIcDesc =>
      'Tus raíces, tu familia, tu pasado y tu seguridad fundamental en tu mundo interior.';

  @override
  String get natalChartTabPersonality => 'Resumen de Personalidad Principal';

  @override
  String get natalChartTabLove => 'Amor y Relaciones';

  @override
  String get natalChartTabCareer => 'Carrera y Dinero';

  @override
  String get natalChartTabEmotional => 'Estructura Emocional';

  @override
  String get natalChartTabStrengths => 'Fortalezas y Debilidades';

  @override
  String natalChartHouse(String house) {
    return 'Casa $house';
  }

  @override
  String zodiacGreeting(String name) {
    return 'Hola $name,';
  }

  @override
  String get zodiacCosmicTraveler => 'Viajero Cósmico,';

  @override
  String get zodiacBirthDate => 'FECHA DE NACIMIENTO';

  @override
  String get zodiacStarsKnowYou => 'Deja que las estrellas te conozcan';

  @override
  String get zodiacConfirm => 'CONFIRMAR';

  @override
  String get zodiacDiscoverYourselfBtn => 'DESCÚBRETE';

  @override
  String get zodiacEliteRequiredDesc =>
      'Necesitas una suscripción Elite para descubrir la compatibilidad astrológica profunda y las dinámicas virales con tus amigos.';

  @override
  String get zodiacEliteDiscoverBtn => 'Descubre los Privilegios Elite';

  @override
  String get zodiacHubWestern => 'ASTROLOGÍA OCCIDENTAL';

  @override
  String get zodiacHubAsian => 'ASTROLOGÍA ASIÁTICA';

  @override
  String get zodiacHubMayan => 'ASTROLOGÍA MAYA';

  @override
  String get actionLater => 'Más Tarde';

  @override
  String get coffeeViewReading => 'Ver Lectura';

  @override
  String get coffeeReadyTitleWithEmoji => '☕️ ¡Tu Lectura Está Lista!';

  @override
  String get wheelTask_w_c1 =>
      'Envía un mensaje de \"estoy pensando en ti\" a un ser querido';

  @override
  String get wheelTask_w_c2 =>
      'Saluda a alguien con quien no has hablado en un tiempo';

  @override
  String get wheelTask_w_c3 => 'Dile a un familiar lo importante que es hoy';

  @override
  String get wheelTask_w_c4 => 'Hazle un cumplido a alguien que esté a tu lado';

  @override
  String get wheelTask_w_c5 => 'Envía un video gracioso a un amigo';

  @override
  String get wheelTask_w_c6 => 'Agradece a alguien hoy y explícale por qué';

  @override
  String get wheelTask_w_s1 =>
      'Mírate al espejo, sonríete y mantén la sonrisa 10 segundos';

  @override
  String get wheelTask_w_s2 =>
      'Recuerda la última vez que reíste a carcajadas y vuelve a sonreír';

  @override
  String get wheelTask_w_s3 =>
      'Piensa en un recuerdo gracioso y ríe en voz alta';

  @override
  String get wheelTask_w_s4 =>
      'Busca y mira la foto más graciosa en tu teléfono';

  @override
  String get wheelTask_w_s5 => 'Sonríe a la primera persona que veas';

  @override
  String get wheelTask_w_s6 =>
      'Piensa en el momento más gracioso que viviste hoy';

  @override
  String get wheelTask_w_m1 => 'Levántate y estírate durante 30 segundos';

  @override
  String get wheelTask_w_m2 => 'Camina por tu habitación durante 1 minuto';

  @override
  String get wheelTask_w_m3 => 'Salta 10 veces y di \"¡Yo puedo!\"';

  @override
  String get wheelTask_w_m4 =>
      'Levanta los brazos y haz una pose de Superhéroe durante 20 segundos';

  @override
  String get wheelTask_w_m5 =>
      'Gira los hombros hacia adelante 5 veces, luego hacia atrás 5 veces';

  @override
  String get wheelTask_w_m6 =>
      'Respira profundo, abre los brazos y mantén la posición 10 segundos';

  @override
  String get wheelTask_w_mu1 => 'Pon tu canción favorita y escúchala 1 minuto';

  @override
  String get wheelTask_w_mu2 =>
      'Pon una canción al azar y escucha los primeros 30 segundos';

  @override
  String get wheelTask_w_mu3 =>
      '¡Canta! Canta en voz alta como si nadie te escuchara';

  @override
  String get wheelTask_w_mu4 =>
      'Escucha una canción de un género que no hayas explorado hoy';

  @override
  String get wheelTask_w_mu5 =>
      'Cierra los ojos y escucha los sonidos a tu alrededor durante 30 segundos';

  @override
  String get wheelTask_w_mu6 =>
      'Golpea un ritmo en la mesa con tu dedo durante 15 segundos';

  @override
  String get wheelTask_w_g1 =>
      'Piensa en 1 cosa que tienes hoy y di \"gracias\"';

  @override
  String get wheelTask_w_g2 => 'Cuenta 3 pequeñas cosas que te hacen feliz';

  @override
  String get wheelTask_w_g3 =>
      'Piensa en lo mejor que comiste hoy y recuerda su sabor';

  @override
  String get wheelTask_w_g4 =>
      'Piensa en el mejor momento de tu vida durante 10 segundos';

  @override
  String get wheelTask_w_g5 => 'Agradece por tu salud. Respira profundo.';

  @override
  String get wheelTask_w_g6 => 'Agradece que el sol salió hoy';

  @override
  String get wheelTask_w_f1 => 'Salta 3 veces y grita \"¡Yo puedo!\"';

  @override
  String get wheelTask_w_f2 => 'Haz tu cara más graciosa y mantenla 5 segundos';

  @override
  String get wheelTask_w_f3 => 'Imita un animal — ¿qué animal serías?';

  @override
  String get wheelTask_w_f4 =>
      'Cierra los ojos e imagina que estás volando durante 10 segundos';

  @override
  String get wheelTask_w_f5 =>
      'Haz una pose de superhéroe y mantenla 5 segundos';

  @override
  String get wheelTask_w_f6 => 'Camina como un robot durante 10 pasos';

  @override
  String get zodiacAccessWesternAdTitle => 'Límite Diario Gratuito Alcanzado';

  @override
  String get zodiacAccessWesternAdDesc =>
      'Puedes ver un anuncio corto para volver a entrar a la Astrología Occidental.';

  @override
  String get zodiacAccessWatchAdBtn => 'Ver Anuncio';

  @override
  String get zodiacAccessGetEliteBtn => 'Obtener Elite';

  @override
  String get zodiacAccessGateTitle => 'Puerta de la Sabiduría Cósmica';

  @override
  String zodiacAccessStoneCount(Object count) {
    return 'Tienes $count Piedras del Alma';
  }

  @override
  String get zodiacAccessPremiumInfo1 =>
      'Permiso de acceso a las profundidades del zodíaco';

  @override
  String get zodiacAccessPremiumInfo2 =>
      'Cada carta astrológica consume 1 Piedra del Alma';

  @override
  String get zodiacAccessPremiumInfo3Elite =>
      'Elite: Acceso ilimitado con 1 Piedra del Alma por día';

  @override
  String get zodiacAccessPremiumInfo3Normal =>
      '1 Piedra del Alma es suficiente con Elite por día';

  @override
  String get zodiacAccessOneStoneBtn => '1 Piedra del Alma';

  @override
  String get onboardingTestSimulate =>
      'Modo de Prueba: Simulando inicio de sesión con cuenta antigua...';

  @override
  String get onboardingTestAnon => 'Modo de Prueba: Conectando anónimamente...';

  @override
  String onboardingGoogleLoginFailed(Object error) {
    return 'Error de Inicio de Sesión con Google: $error';
  }

  @override
  String onboardingAppleLoginFailed(Object error) {
    return 'Error de Inicio de Sesión con Apple: $error';
  }

  @override
  String onboardingGoogleRegisterFailed(Object error) {
    return 'Error de Registro con Google: $error';
  }

  @override
  String onboardingAppleRegisterFailed(Object error) {
    return 'Error de Registro con Apple: $error';
  }

  @override
  String dreamDataError(Object error) {
    return 'Error de datos guardados: $error';
  }

  @override
  String get onboardingBirthDateTitle => 'TU FECHA DE NACIMIENTO';

  @override
  String get onboardingSelectBirthDate => 'Selecciona tu fecha de nacimiento';

  @override
  String get onboardingBirthTimeTitle => 'HORA DE NACIMIENTO (Opcional)';

  @override
  String get onboardingBirthPlaceTitle => 'LUGAR DE NACIMIENTO (Opcional)';

  @override
  String get onboardingPickerDateTitle => 'Seleccionar Fecha de Nacimiento';

  @override
  String get onboardingPickerTimeTitle => 'Seleccionar Hora de Nacimiento';

  @override
  String get onboardingPickerDone => 'Listo';

  @override
  String get onboardingLifeFocusSpiritual => 'Despertar\nEspiritual';

  @override
  String get onboardingLifeFocusCareer => 'Carrera y\nPoder Personal';

  @override
  String get onboardingLifeFocusLove => 'Amor y\nArmonía Cósmica';

  @override
  String get onboardingLifeFocusHealing => 'Sanación y\nPaz Interior';

  @override
  String get onboardingLifeFocusWealth => 'Riqueza y\nAbundancia';

  @override
  String get onboardingLifeFocusSurprise => 'Sorpresas\ndel Universo';

  @override
  String get onboardingDreamMessenger => 'Mensajero y Sueños Vívidos';

  @override
  String get onboardingDreamChaotic => 'Eventos Sorprendentes y Caóticos';

  @override
  String get onboardingDreamCalm => 'Tan Tranquilo Como las Nubes';

  @override
  String get onboardingSleepMindTitle => 'Luz de la Mente';

  @override
  String get onboardingSleepMindDesc =>
      'Analizo los eventos, los evalúo con lógica y planeo pasos concretos.';

  @override
  String get onboardingSleepMindVal => 'Luz de la Mente (Lógica)';

  @override
  String get onboardingSleepHeartTitle => 'Susurro del Corazón';

  @override
  String get onboardingSleepHeartDesc =>
      'Escucho mi voz interior y siempre confío en mis sentimientos por encima de la lógica.';

  @override
  String get onboardingSleepHeartVal => 'Susurro del Corazón (Intuición)';

  @override
  String get onboardingSleepUniverseTitle => 'Flujo del Universo';

  @override
  String get onboardingSleepUniverseDesc =>
      'Creo que todo sucede por una razón y sigo las señales del universo.';

  @override
  String get onboardingSleepUniverseVal => 'Flujo del Universo (Destino)';

  @override
  String get linkAccountTitle => 'Vincular cuenta';

  @override
  String get linkGoogleAccount => 'Vincular cuenta de Google';

  @override
  String get linkAppleAccount => 'Vincular cuenta de Apple';

  @override
  String get linkAccountStarted =>
      'Proceso de vinculación de cuenta iniciado...';

  @override
  String get linkAccountFailed => 'Error al vincular la cuenta';

  @override
  String get profileSignOutGuestDesc =>
      'Advertencia: Si cierra la sesión de una cuenta de invitado, no podrá volver a acceder a esta cuenta y todos sus datos (Piedras de Alma, lecturas) se PERDERÁN PERMANENTEMENTE. ¿Está seguro de que desea cerrar la sesión?';
}
