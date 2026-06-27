// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Crack e desejo';

  @override
  String get language => 'Linguagem';

  @override
  String get selectLanguage => 'Selecione o idioma';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get turkish => 'turco';

  @override
  String get english => 'Inglês';

  @override
  String get close => 'Fechar';

  @override
  String languageValue(Object value) {
    return 'Selecionado:$value';
  }

  @override
  String get navHome => 'Lar';

  @override
  String get navCollection => 'Coleção';

  @override
  String get navProfile => 'Perfil';

  @override
  String get dailyCookieTitle => 'Biscoito Diário';

  @override
  String get dailyCookieSubtitle => 'Toque para tentar a sorte';

  @override
  String get luckyNumber => 'Número da sorte';

  @override
  String get luckyColor => 'Cor da Sorte';

  @override
  String get luckLabel => 'Sorte';

  @override
  String get todayFortune => 'A fortuna de hoje';

  @override
  String get shareButton => '📸 Compartilhe';

  @override
  String fortuneShareText(
    Object emoji,
    Object title,
    Object meaning,
    Object number,
    Object color,
    Object percent,
  ) {
    return '$emoji$title${meaning}Número da sorte:${number}Cor da Sorte:${color}Sorte:$percent%\n\nDo aplicativo Fortune Cookie 🥠';
  }

  @override
  String get themeSelectTitle => 'Selecione o tema';

  @override
  String themeSelected(Object value) {
    return 'Tema selecionado:$value';
  }

  @override
  String get themeGalleryTitle => 'Galeria de Temas';

  @override
  String get themeGalleryOpen => 'Ir para a lista de temas';

  @override
  String get themeGalleryLimited =>
      'A galeria temática está atualmente limitada a duas opções';

  @override
  String get statCookies => 'Biscoitos';

  @override
  String get statStreakDays => 'Dias consecutivos';

  @override
  String get statDreams => 'Sonhos';

  @override
  String get statMood => 'Humor';

  @override
  String get statTheme => 'Hoje...';

  @override
  String get statCollection => 'Meu biscoito';

  @override
  String get statTalisman => 'Talismã';

  @override
  String get moodGood => 'Bom';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodBad => 'Ruim';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodGreat => 'Ótimo';

  @override
  String get shortcutCollection => 'Coleção';

  @override
  String get shortcutHistory => 'História';

  @override
  String get shortcutFavorites => 'Favoritos';

  @override
  String get sectionShortcuts => 'Atalhos';

  @override
  String get sectionActivity => 'Atividade';

  @override
  String get menuBadges => 'Emblemas';

  @override
  String get menuBadgesSubtitle => 'Conquistas e níveis';

  @override
  String get menuSettings => 'Configurações';

  @override
  String get menuSettingsSubtitle => 'Notificações, tema, privacidade';

  @override
  String get menuHelpAbout => 'Ajuda e Sobre';

  @override
  String get menuHelpAboutSubtitle =>
      'Perguntas frequentes e informações sobre a versão';

  @override
  String get menuShare => 'Compartilhar';

  @override
  String get menuShareSubtitle => 'Compartilhe seu perfil com amigos';

  @override
  String get activityTarotOpenedTitle => 'Leitura de tarô aberta';

  @override
  String get activityTarotOpenedSubtitle => 'Hoje • Cartão: Estrela';

  @override
  String activityCookiesOpenedTitle(Object count) {
    return '${count}biscoitos quebrados';
  }

  @override
  String get activityCookiesOpenedSubtitle => 'Ontem • Novas mensagens abertas';

  @override
  String get activityDreamSavedTitle => 'Interpretação dos sonhos salva';

  @override
  String get activityDreamSavedSubtitle => '2 dias atrás';

  @override
  String get profileUserTitle => 'Usuário';

  @override
  String get profileSubtitle => 'Menos barulho, mais você';

  @override
  String get tagTarot => 'Tarô';

  @override
  String get tagDream => 'Sonhar';

  @override
  String get tagCollection => 'Coleção';

  @override
  String get zodiacTitle => '⭐ Leitura do Zodíaco';

  @override
  String zodiacDailyTitle(Object name) {
    return '$name- Leitura Diária';
  }

  @override
  String get zodiacDailyBody =>
      'Você tem sorte no amor esta semana! As oportunidades de carreira estão à sua porta – mantenha os olhos abertos. Sua energia está alta, use-a. É um momento perfeito para novos projetos. Suas habilidades de comunicação estão no auge, aproveite isso.';

  @override
  String get zodiacLove => 'Amor';

  @override
  String get zodiacCareer => 'Carreira';

  @override
  String get zodiacMoney => 'Dinheiro';

  @override
  String get zodiacHealth => 'Saúde';

  @override
  String get collectionTitle => 'Sua coleção';

  @override
  String get collectionSubtitle =>
      'Vestígios e recompensas do seu ritual diário';

  @override
  String get collectionNotYet => 'Ainda não';

  @override
  String get collectionFirstTime => 'Primeira vez';

  @override
  String get collectionTotalOpened => 'Total';

  @override
  String get collectionCookieDescription =>
      'Este biscoito acrescenta sorte e pequenas surpresas ao seu ritual. Quanto mais você abre, mais forte sua coleção se torna.';

  @override
  String get collectionSummaryTitle => 'Resumo da coleção';

  @override
  String get collectionSummaryTypes => 'Tipos únicos';

  @override
  String get collectionSummaryTotalOpened => 'Total aberto';

  @override
  String get collectionSummaryRare => 'Cru';

  @override
  String get collectionSummaryFooter =>
      'Cada biscoito tem uma história. Quanto mais você abre, mais rico fica.';

  @override
  String get rarityAll => 'Todos';

  @override
  String get rarityCommon => 'Comum';

  @override
  String get rarityRare => 'Cru';

  @override
  String get rarityLegendary => 'Lendário';

  @override
  String get collectionUndiscovered => 'Não descoberto';

  @override
  String get collectionNotFoundYet => 'A sorte não trouxe você aqui... ainda.';

  @override
  String get collectionEmptyTitle => 'Você ainda não abriu nenhum cookie';

  @override
  String collectionEmptySubtitle(Object count) {
    return '${count}cookies diferentes estão esperando por você. Abra o cookie de hoje para iniciar sua coleção.';
  }

  @override
  String get discoverTitle => 'Descobrir';

  @override
  String get discoverSubtitle => 'Explore novos recursos';

  @override
  String get discoverCategories => 'Categorias';

  @override
  String get categoryTarotTitle => 'Leitura de Tarô';

  @override
  String get categoryTarotDesc => 'Tarô de 3 cartas';

  @override
  String get categoryDreamTitle => 'Interpretação dos Sonhos';

  @override
  String get categoryDreamDesc => 'Descubra o significado dos seus sonhos';

  @override
  String get categoryZodiacTitle => 'Leitura do Zodíaco';

  @override
  String get categoryZodiacDesc => 'Mensagem das estrelas';

  @override
  String get categoryPersonalityTitle => 'Teste de Personalidade';

  @override
  String get categoryPersonalityDesc => '16 Personalidades';

  @override
  String get discoverDailySuggestionTitle => 'SUGESTÃO DE HOJE';

  @override
  String get discoverDailySuggestionHeadline =>
      'Você teve um sonho ontem à noite?';

  @override
  String get discoverDailySuggestionSubtitle =>
      'Interprete agora e aprenda seu significado!';

  @override
  String get dailySuggestionDreamHeadline =>
      'Você teve um sonho ontem à noite?';

  @override
  String get dailySuggestionDreamSubtitle =>
      'Interprete agora e aprenda seu significado!';

  @override
  String get dailySuggestionTarotHeadline => 'Já consultou seu tarô hoje?';

  @override
  String get dailySuggestionTarotSubtitle =>
      'Escolha 3 cartas e veja sua mensagem!';

  @override
  String get dailySuggestionZodiacHeadline =>
      'Já verificou sua leitura do zodíaco?';

  @override
  String get dailySuggestionZodiacSubtitle =>
      'Veja agora mesmo a energia de hoje!';

  @override
  String get dailySuggestionCoffeeHeadline => 'Você tomou café hoje?';

  @override
  String get dailySuggestionCoffeeSubtitle =>
      'Vire sua xícara, vamos ler sua sorte!';

  @override
  String get dailySuggestionAllDoneHeadline =>
      'Os rituais de hoje estão completos!';

  @override
  String get dailySuggestionAllDoneSubtitle =>
      'Volte amanhã para novos conteúdos.';

  @override
  String get discoverFeaturedTag => 'APRESENTOU';

  @override
  String get discoverFeaturedTitle => 'Leitura de tarô de 3 cartas';

  @override
  String get discoverFeaturedSubtitle =>
      'Explore seu passado, presente e futuro';

  @override
  String get ctaStart => 'Começar';

  @override
  String get homeGreeting => 'Olá! 👋';

  @override
  String get homeFeeling => 'Como você está se sentindo hoje?';

  @override
  String get quoteOfDayText =>
      'O menor passo que você dá hoje leva à maior vitória amanhã.';

  @override
  String get quoteOfDaySource => '- Frase do dia';

  @override
  String get dailyHoroscopeTitle => 'Áries';

  @override
  String get dailyHoroscopeSubtitle => 'Leitura de hoje';

  @override
  String get dailyHoroscopeBody =>
      'Você tem sorte no amor esta semana! As oportunidades de carreira estão à sua porta – mantenha os olhos abertos. Sua energia está alta, use-a.';

  @override
  String get aries => 'Áries';

  @override
  String get bentoTarotTitle => 'Tarô';

  @override
  String get bentoTarotDesc => 'Veja o seu futuro';

  @override
  String get bentoTarotBadge => 'POPULAR';

  @override
  String get bentoDreamTitle => 'Sonhar';

  @override
  String get bentoDreamDesc => 'Explore seu subconsciente';

  @override
  String get bentoDreamBadge => 'NOVO';

  @override
  String get bentoMotivationTitle => 'Humor';

  @override
  String get bentoMotivationDesc => 'Descubra o seu humor';

  @override
  String get bentoMotivationBadge => 'DIÁRIO';

  @override
  String get bentoZodiacTitle => 'Zodíaco';

  @override
  String get bentoZodiacDesc => 'Mensagem das estrelas';

  @override
  String get bentoZodiacBadge => 'DIÁRIO';

  @override
  String get moodQuestion => 'Como você está hoje?';

  @override
  String get dreamTitle => 'Conte o seu sonho';

  @override
  String get dreamTabNew => 'Novo sonho';

  @override
  String get dreamTabHistory => 'Meus sonhos';

  @override
  String get dreamAnalyzeButton => 'Interpretar sonho';

  @override
  String get dreamAnalyzeEstimate => '~ 5 segundos';

  @override
  String get dreamInterpretationTitle => 'Interpretação dos Sonhos';

  @override
  String get dreamNoHistory => 'Você ainda não tem nenhum sonho salvo';

  @override
  String get dreamDefaultTitle => 'Sonhar';

  @override
  String get dreamSpiritual => 'Espiritual';

  @override
  String get dreamEnriched => 'Interpretação Enriquecida';

  @override
  String get dreamEnriching => 'Enriquecedor...';

  @override
  String get dreamEnrich => 'Enriquecer';

  @override
  String get dreamShare => 'Compartilhar';

  @override
  String get dreamAnalyzing => 'Analisando sonho...';

  @override
  String get dreamAnalysisFailed =>
      'Não é possível gerar uma interpretação no momento.';

  @override
  String get dreamClarifyThreat =>
      'Houve uma sensação de ameaça ou medo no sonho?';

  @override
  String get dreamClarifyFamiliar => 'Essa cena parecia familiar do passado?';

  @override
  String get dreamClarifyEscape => 'Houve uma sensação de movimento ou fuga?';

  @override
  String get dreamClarifyAnxious => 'Você sentiu ansiedade ou ameaça no sonho?';

  @override
  String get dreamUnsure => 'Não tenho certeza';

  @override
  String get dreamYes => 'SIM';

  @override
  String get dreamNo => 'NÃO';

  @override
  String get dreamGeneral => 'Sonho Geral';

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
    return 'Título dos Sonhos:${title}Data:${date}Sonho:${text}Geral:${general}Psicológico:${psychology}Espiritual:${spiritual}Conselho:$advice#VSorte #Sonho';
  }

  @override
  String get scientificTitle => 'Análise Científica dos Sonhos';

  @override
  String get scientificDreamPromptTitle => 'Conte o seu sonho';

  @override
  String get scientificDreamHint =>
      'Escreva seu sonho como você se lembra dele...';

  @override
  String get scientificEmotionQuestion => 'Como você se sentiu quando acordou?';

  @override
  String get scientificEmotionHint => 'Escolha uma emoção';

  @override
  String get scientificClarityQuestion => 'Quão claro foi o sonho?';

  @override
  String get scientificDisclaimer =>
      'Esta análise é baseada em pesquisas em psicologia e neurociência. Não fornece resultados definitivos ou preditivos.';

  @override
  String get scientificLoading =>
      'Avaliação com base no sono REM e na neurociência';

  @override
  String get scientificResultsTitle => 'Interpretação dos Sonhos';

  @override
  String get scientificRecentPastTitle => 'Efeitos passados ​​recentes';

  @override
  String get scientificSaved => 'Sonho salvo';

  @override
  String get scientificSaveButton => 'Salve o sonho';

  @override
  String get cookieSpringWreath => 'Guirlanda de Primavera';

  @override
  String get cookieLuckyClover => 'Trevo da Sorte';

  @override
  String get cookieRoyalHearts => 'Corações Reais';

  @override
  String get cookieEvilEye => 'Mau-olhado';

  @override
  String get cookiePizzaParty => 'Festa da Pizza';

  @override
  String get cookieSakuraBloom => 'Sakura Flor';

  @override
  String get cookieBluePorcelain => 'Porcelana Azul';

  @override
  String get cookiePinkBlossom => 'Flor Rosa';

  @override
  String get cookieFortuneCat => 'Gato da Fortuna';

  @override
  String get cookieWildflower => 'Flores silvestres';

  @override
  String get cookieCupidRibbon => 'Fita Cupido';

  @override
  String get cookiePandaBamboo => 'Panda Bambu';

  @override
  String get cookieRamadanCute => 'Ramadã';

  @override
  String get cookieEnchantedForest => 'Floresta Encantada';

  @override
  String get cookieGoldenArabesque => 'Arabesco Dourado';

  @override
  String get cookieMidnightMosaic => 'Mosaico da meia-noite';

  @override
  String get cookiePearlLace => 'Renda Pérola';

  @override
  String get cookieGoldenSakura => 'Sakura Dourada';

  @override
  String get cookieDragonPhoenix => 'Dragão Fênix';

  @override
  String get cookieGoldBeasts => 'Bestas Douradas';

  @override
  String get emotionAnxiety => 'Ansioso';

  @override
  String get emotionFear => 'Com medo';

  @override
  String get emotionCalm => 'Calma';

  @override
  String get emotionHappy => 'Feliz';

  @override
  String get emotionSad => 'Triste';

  @override
  String get emotionConfusion => 'Incerto';

  @override
  String get emotionSurprise => 'Surpreso';

  @override
  String get dreamMoodQuestion => 'Como você se sentiu quando acordou?';

  @override
  String get dreamMetricEmotional => 'Carga Emocional';

  @override
  String get dreamMetricUncertainty => 'Narrativa\nIncerteza';

  @override
  String get dreamMetricRecentPast => 'Passado recente';

  @override
  String get dreamMetricBrain => 'Atividade cerebral';

  @override
  String get tarotShuffleHint => 'Arraste em um círculo para embaralhar';

  @override
  String get tarotEnergyDepletedTitle => 'Energia esgotada';

  @override
  String get tarotEnergyDepletedBody =>
      'Sua energia cósmica diária está esgotada.\nRecarregue para ver a verdade.';

  @override
  String get tarotEnergyDepletedSub =>
      'Seus cartões selecionados estão prontos, falta apenas um passo...';

  @override
  String get tarotWatchAd => 'Assistir ao anúncio e abrir';

  @override
  String tarotFreeRemaining(Object count) {
    return 'Livre restante hoje:$count';
  }

  @override
  String get socialFeedTitle => 'Alimentação silenciosa';

  @override
  String get feedTypeCookie => 'Biscoito';

  @override
  String get feedTagDailyCookie => 'O biscoito de hoje';

  @override
  String get feedTypeTarot => 'Tarô';

  @override
  String get feedTagThreeCard => 'Sorteio de 3 cartas';

  @override
  String get feedTypeDream => 'Sonhar';

  @override
  String get feedTagDreamMode => 'Modo sonho';

  @override
  String get feedTypeZodiac => 'Zodíaco';

  @override
  String get feedTagDailyEnergy => 'Energia diária';

  @override
  String get feedTypeMotivation => 'Motivação';

  @override
  String get feedTagMiniAction => 'Mini ação';

  @override
  String inviteShareMessage(String handle, String link) {
    return 'Você está pronto para uma jornada mística? Te espero no universo Crack&Wish! ✨\n\nMeu código de convite:${handle}Baixe agora:$link';
  }

  @override
  String get inviteShareSubject => 'Convite Crack&Wish';

  @override
  String get inviteSendButton => 'Convidar';

  @override
  String get inviteConnectButton => 'Conectar';

  @override
  String get inviteSentText => 'Enviado';

  @override
  String inviteRequestSent(String name) {
    return 'Solicitação enviada para$name!';
  }

  @override
  String get toastCoffeeReadyTitle => 'Sua leitura está pronta!';

  @override
  String get toastCoffeeReadyMessage =>
      'Os segredos da sua xícara foram revelados.';

  @override
  String get toastViewButton => 'Visualizar';

  @override
  String get toastDreamReadyTitle => 'Seu sonho é interpretado!';

  @override
  String get toastDreamReadyMessage =>
      'As mensagens do seu subconsciente foram decodificadas.';

  @override
  String get toastCoffeeReadyTitle2 => 'Sua leitura de café está pronta!';

  @override
  String get dreamFallbackTitle => 'Interpretação dos Sonhos';

  @override
  String get rewardWelcomeTitle => 'Bem-vindo ao Universo';

  @override
  String get rewardWelcomeDesc =>
      'Deixamos um pequeno presente para você começar sua jornada.';

  @override
  String get rewardReferralFallback => 'Um amigo';

  @override
  String get rewardReferralReceiverTitle => 'Um presente inesperado';

  @override
  String rewardReferralReceiverDesc(String inviter) {
    return '${inviter}convidou você aqui e deixou um presente de boas-vindas para você.';
  }

  @override
  String get rewardInviterTitle => 'Seu chamado foi ouvido!';

  @override
  String rewardInviterDescSingle(String name) {
    return '${name}se juntou ao universo. Você foi recompensado por ser um guia.';
  }

  @override
  String rewardInviterDescMultiple(String name, int count) {
    return '${name}e${count}mais amigos se juntaram ao universo. Você foi recompensado por ser um guia.';
  }

  @override
  String rewardInviterDescGeneric(int count) {
    return '${count}amigos se juntaram ao universo. Você foi recompensado por ser um guia.';
  }

  @override
  String birthdayTitleWithName(String name) {
    return 'Feliz aniversário,$name!';
  }

  @override
  String get birthdayTitle => 'Feliz aniversário!';

  @override
  String get birthdayDesc =>
      'Hoje é o dia sagrado em que sua alma veio a este mundo. O universo deixou um presente especial para você.';

  @override
  String get cookieReminderTitle => 'Você não quebrou um biscoito hoje';

  @override
  String get cookieReminderMessage =>
      'Sua mensagem diária da fortuna está esperando!';

  @override
  String get cookieReminderReward => '3 Esquerda';

  @override
  String achievementRewardStones(int count) {
    return '+${count}Pedras da Alma';
  }

  @override
  String achievementRewardAura(int count) {
    return '+${count}Aura';
  }

  @override
  String get rankUpTitle => 'Promoção Cósmica!';

  @override
  String rankUpMessage(String rank) {
    return 'Seu poder de aura aumentou. Novo título:$rank';
  }

  @override
  String get rankNovice => 'Vidente Novato';

  @override
  String get rankApprentice => 'Aprendiz de Vidente';

  @override
  String get rankSeer => 'Vidente';

  @override
  String get rankWise => 'Vidente Sábio';

  @override
  String get rankMaster => 'Mestre Vidente';

  @override
  String get rankCosmic => 'Vidente Cósmico';

  @override
  String get loginSubtitle =>
      'Sincronize com o guia da sua alma.\nLembre-se de seu passado, futuro e subconsciente.';

  @override
  String get loginAppleContinue => 'Continuar com a Apple';

  @override
  String get loginAppleSignIn => 'Faça login com a Apple';

  @override
  String get loginGoogleContinue => 'Continuar com o Google';

  @override
  String get loginGoogleSignIn => 'Faça login com o Google';

  @override
  String get loginGoogleFailed => 'Falha no login do Google';

  @override
  String get loginAppleFailed => 'Falha no login da Apple';

  @override
  String get loginNoAccountYet => 'Ainda não entrou no universo?';

  @override
  String get loginHaveAccount => 'Já tem uma conta?';

  @override
  String get loginSignUp => 'Inscrever-se';

  @override
  String get loginSignIn => 'Entrar';

  @override
  String get loginLegalPrefix => 'Ao continuar, você concorda com nossos';

  @override
  String get loginTermsOfUse => 'Termos de Uso';

  @override
  String get loginLegalAnd => 'e';

  @override
  String get loginPrivacyPolicy => 'política de Privacidade';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get homeSubtitle1 => 'Crack, leia, sorria.';

  @override
  String get homeSubtitle2 => 'Sorte no seu bolso.';

  @override
  String get homeSubtitle3 => 'Mensagem de hoje: Você.';

  @override
  String get homeSubtitle4 => 'Uma rachadura, uma surpresa.';

  @override
  String get homeSubtitle5 => 'Um pequeno biscoito, uma grande sensação.';

  @override
  String get homeSubtitle6 => 'Não é o destino, apenas uma dica doce.';

  @override
  String get homeSubtitle7 => 'O que sua sorte diz hoje?';

  @override
  String get homeSubtitle8 => 'Abra, descubra, siga em frente.';

  @override
  String get homeSubtitle9 => 'A sorte está a um toque de distância.';

  @override
  String get homeSubtitle10 => 'Um novo começo a cada rachadura.';

  @override
  String get homeSubtitle11 => 'Encontre sua mensagem.';

  @override
  String get homeSubtitle12 => 'Não é aleatório... só para você.';

  @override
  String get homeSubtitle13 => 'Quebre a sua sorte, aproveite o seu dia.';

  @override
  String get homeSubtitle14 => 'Pequenas profecias que fazem você sorrir.';

  @override
  String get homeSubtitle15 => 'Surpresas fazem bem.';

  @override
  String get homeMilestoneTitle => 'Foco incrível!';

  @override
  String homeMilestoneMessage(int count) {
    return 'Sua sequência diária atingiu${count}dias.';
  }

  @override
  String homeMilestoneSoulStone(int count) {
    return '+${count}Pedras da Alma';
  }

  @override
  String get homeGreetingMorning => 'Bom dia';

  @override
  String get homeGreetingAfternoon => 'Boa tarde';

  @override
  String get homeGreetingEvening => 'Boa noite';

  @override
  String get homeGreetingNight => 'Boa noite';

  @override
  String get homeTimeSubMorning => 'Mensagem fresca com seu café.';

  @override
  String get homeTimeSubAfternoon => 'Uma pausa mágica no seu dia.';

  @override
  String get homeTimeSubEvening => 'Uma doce profecia para relaxar.';

  @override
  String get homeTimeSubNight => 'As estrelas brilham para você esta noite.';

  @override
  String get paywallSubtitleElite =>
      'Sua consciência cósmica já está aberta.\nFortaleça sua iluminação atualizando seu plano.';

  @override
  String get paywallSubtitleNew =>
      'Abra a porta para a consciência cósmica.\nRemova todos os limites.';

  @override
  String get paywallFeature1 => '5 pedras frescas da alma diariamente';

  @override
  String get paywallFeature2 => 'Modo de análise mestre';

  @override
  String get paywallFeature3 => 'x3 Ganho Rápido de Aura';

  @override
  String get paywallFeature4 => 'Arquivo clínico ilimitado';

  @override
  String get paywallFeature5 => 'Experiência perfeita sem anúncios';

  @override
  String get paywallPackageWeekly => 'Despertar Semanal';

  @override
  String get paywallPackageMonthly => 'Intuição Mensal';

  @override
  String get paywallPackageYearly => 'Iluminação Anual';

  @override
  String get paywallBtnCurrentPlan => 'Plano Atual';

  @override
  String get paywallBtnManage => 'Gerenciar na loja';

  @override
  String get paywallBtnUpgrade => 'Plano de atualização';

  @override
  String get paywallBtnSubscribe => 'Desbloquear elite';

  @override
  String get paywallSuccessUpgradeTitle => 'Iluminação atualizada';

  @override
  String get paywallSuccessTitle => 'Bem-vindo ao Iluminismo';

  @override
  String get paywallSuccessUpgradeSubtitle =>
      'Seu plano foi atualizado com sucesso.';

  @override
  String get paywallSuccessSubtitle =>
      'Agora você é um membro Elite. Os limites cósmicos foram removidos para você.';

  @override
  String get paywallErrorTitle => 'Erro de conexão';

  @override
  String get paywallErrorMessage =>
      'Não foi possível conectar-se à loja ou a transação foi cancelada. Os produtos talvez ainda não tenham sido publicados na App Store/Play Console. Por favor, tente novamente mais tarde.';

  @override
  String get paywallRestoreSuccess => 'Elite Restaurada';

  @override
  String get paywallRestoreSuccessSubtitle =>
      'Bem-vindo de volta à consciência cósmica. Seus limites foram removidos.';

  @override
  String get paywallRestoreNoSub => 'Nenhuma assinatura ativa';

  @override
  String get paywallRestoreNoSubMessage =>
      'Nenhuma associação ativa do Crack Wish Elite foi encontrada para restaurar. Por favor, revise os pacotes.';

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallCurrentPlanBadge => 'PLANO ATUAL';

  @override
  String get paywallLegalTr =>
      'Crack Wish Elite é uma assinatura com renovação automática. O pagamento será cobrado em sua conta na confirmação da compra. A assinatura é renovada automaticamente, a menos que seja cancelada pelo menos 24 horas antes do final do período atual. Você pode gerenciar e cancelar suas assinaturas nas configurações da App Store.';

  @override
  String get paywallOk => 'OK';

  @override
  String get coffeeLoading1 => 'Mergulhando nas profundezas da xícara...';

  @override
  String get coffeeLoading2 =>
      'Os símbolos nos terrenos estão se alinhando com a energia universal...';

  @override
  String get coffeeLoading3 => 'Suas linhas de destino estão sendo mapeadas...';

  @override
  String get coffeeLoading4 => 'Segredos estão sendo revelados...';

  @override
  String get coffeeAiError => 'AI encontrou um erro ao interpretar a leitura.';

  @override
  String get coffeeGenericError =>
      'Algo deu errado. Por favor, tente novamente.';

  @override
  String get coffeeNotifReady =>
      'Você será notificado quando sua leitura estiver pronta';

  @override
  String get coffeeCheckHistory => 'botão para visualizá-lo';

  @override
  String get coffeeWaitOrExplore => 'Espere aqui ou explore o aplicativo';

  @override
  String get coffeeGoHome => 'Vá para casa';

  @override
  String get coffeeSections => 'Seções da Copa';

  @override
  String get coffeeSectionInside => 'Dentro da Copa';

  @override
  String get coffeeSectionInsideDesc =>
      'Seu mundo interior, pensamentos, estado emocional.';

  @override
  String get coffeeSectionEdge => 'Borda da Copa';

  @override
  String get coffeeSectionEdgeDesc =>
      'Futuro próximo, notícias, mensagens, encontros.';

  @override
  String get coffeeSectionBottom => 'Fundo do copo';

  @override
  String get coffeeSectionBottomDesc =>
      'Problemas persistentes do passado, fardos, assuntos não resolvidos.';

  @override
  String get coffeeSectionSaucer => 'Pires';

  @override
  String get coffeeSectionSaucerDesc =>
      'Desejo, resultado, destino, energia final.';

  @override
  String get coffeeLoadingComment => 'Carregando interpretação...';

  @override
  String get coffeeStoryTitle => 'A história contada pelo terreno';

  @override
  String get coffeeSymbolsTitle => 'Símbolos vistos em sua leitura';

  @override
  String get coffeeLove => 'Amor e Relacionamentos';

  @override
  String get coffeeCareer => 'Carreira e Finanças';

  @override
  String get coffeeFamily => 'Família e círculo próximo';

  @override
  String get coffeeNearFuture => 'Futuro próximo';

  @override
  String get coffeeClosing => 'Palavras finais de sua leitura';

  @override
  String get coffeeShare => 'Compartilhe minha leitura';

  @override
  String get coffeeRetryValidation => 'Voltar e retomar';

  @override
  String get coffeeRetry => 'Tente novamente';

  @override
  String get coffeeCancel => 'Cancelar';

  @override
  String get coffeeSymbolLabel => 'Símbolo';

  @override
  String get coffeeSymbolLoading => 'Carregando...';

  @override
  String get coffeeTimelineSoon => 'Muito em breve';

  @override
  String get coffeeImageError =>
      'Não foi possível detectar grãos de café claros nesta imagem.';

  @override
  String get coffeeCosmicTitle => 'Leitura Cósmica do Café';

  @override
  String get coffeePremiumOnly => 'Apenas recurso premium';

  @override
  String get coffeePremiumDesc =>
      'Coffee Reading é exclusivo para membros elite. Atualize para Premium e descubra os segredos do seu futuro com suas Soul Stones.';

  @override
  String get coffeePremiumSimBtn => 'Torne-se Premium (Simulação)';

  @override
  String get coffeePhotoSource => 'Fonte da foto';

  @override
  String get coffeeCamera => 'Câmera';

  @override
  String get coffeeGallery => 'Galeria';

  @override
  String get coffeeStepCupInside => 'Dentro da Copa';

  @override
  String get coffeeStepCupInsideDesc =>
      'Posicione a câmera diretamente acima da xícara e capture os grãos de café de dentro.';

  @override
  String get coffeeStepLeftProfile => 'Perfil esquerdo';

  @override
  String get coffeeStepLeftProfileDesc =>
      'Segure o copo pela alça e tire uma foto nítida apenas do lado esquerdo.';

  @override
  String get coffeeStepRightProfile => 'Perfil certo';

  @override
  String get coffeeStepRightProfileDesc =>
      'Agora capture a parte traseira direita do copo de um ângulo bem iluminado.';

  @override
  String get coffeeStepSaucerSecret => 'O Segredo do Pires';

  @override
  String get coffeeStepSaucerDesc =>
      'Finalmente, capture a ampla superfície do pires com os motivos claramente visíveis.';

  @override
  String get coffeeStepSaucerBtn => 'Tire uma foto do pires';

  @override
  String get coffeeHeaderTitle => 'LEITURA DE CAFÉ';

  @override
  String get coffeeLastReading => 'Sua última leitura';

  @override
  String coffeeLastReadingTime(String time) {
    return 'Às$time• Expira à meia-noite';
  }

  @override
  String get coffeeNoReadingYet =>
      'Você ainda não fez uma leitura.\nPrepare uma xícara de café,\ne deixe o terreno sussurrar para você.';

  @override
  String get coffeeSoulStones => 'Suas pedras da alma';

  @override
  String get coffeeSoulStoneEmpty => 'Não sobrou nenhuma Pedra da Alma';

  @override
  String get coffeeSoulStoneRequired =>
      'Necessário para análise de leitura de café';

  @override
  String get coffeeSoulStoneCost => 'Cada leitura custa 1 Pedra da Alma';

  @override
  String get coffeeSoulStoneEliteActive =>
      'Vantagem de elite: 5 Soul Stones são atualizadas todas as noites';

  @override
  String get coffeeSoulStoneElitePromo =>
      'Vá Elite para ganhar 5 Soul Stones todas as noites';

  @override
  String get coffeeEliteSubscribe => 'Inscreva-se na Elite';

  @override
  String get coffeeRitualLabel => 'RITUAL';

  @override
  String get coffeeRitualTitle => 'Segredos da Copa';

  @override
  String get coffeeRitualDesc =>
      'Os motivos só falam para quem olha de perto. Siga o ritual para uma leitura verdadeira.';

  @override
  String get coffeeRitualStep1Title => 'Defina sua intenção';

  @override
  String get coffeeRitualStep1Desc =>
      'Enquanto você bebe, deixe uma pergunta ou desejo fluir pela sua mente.';

  @override
  String get coffeeRitualStep2Title => 'Beba de um lado';

  @override
  String get coffeeRitualStep2Desc =>
      'Beba sempre do mesmo lado para preservar os padrões.';

  @override
  String get coffeeRitualStep3Title => 'Vire-o';

  @override
  String get coffeeRitualStep3Desc =>
      'Vire o copo de cabeça para baixo, deixe esfriar e abra com cuidado.';

  @override
  String get coffeeRitualListenTitle => 'Ouça o sussurro do terreno';

  @override
  String coffeeStepLabel(String index, String title) {
    return 'Etapa$index:$title';
  }

  @override
  String get coffeeDiscoverFate => 'Descubra o seu destino';

  @override
  String get coffeeNextStep => 'Próxima etapa';

  @override
  String get coffeeCapture => 'Capture este ângulo';

  @override
  String get coffeeValidationError =>
      'Os motivos nas fotos marcadas\nnão foi possível identificar claramente.';

  @override
  String get coffeeCosmicMismatch => 'Incompatibilidade Cósmica';

  @override
  String get coffeeCosmicCheck => 'VERIFICAÇÃO DE LIGAÇÃO CÓSMICA';

  @override
  String get coffeeCosmicCheckDesc =>
      'Decodificando a linguagem dos motivos,\nouvindo os sussurros do destino...';

  @override
  String get coffeeRevealSecrets => 'Levante o Véu dos Segredos';

  @override
  String get coffeeReadingInProgress => 'Lendo o terreno...';

  @override
  String get coffeeReadingWait =>
      'As portas do futuro estão se abrindo, espere.';

  @override
  String get coffeeRelationTitle => 'Seu status de relacionamento';

  @override
  String get coffeeRelationSubtitle =>
      'Estabeleça a base do seu vínculo cósmico.';

  @override
  String get coffeeFocusTitle => 'O que está em sua mente?';

  @override
  String get coffeeFocusSubtitle =>
      'Escolha uma intenção de aprofundar sua leitura.';

  @override
  String get coffeeMoodTitle => 'Seu humor?';

  @override
  String get coffeeMoodSubtitle => 'Sinta a energia da sua xícara.';

  @override
  String get coffeeCosmicBondFormed => 'Laço Cósmico Formado';

  @override
  String get coffeeSecretsReady =>
      'Os segredos da sua xícara estão prontos para serem sussurrados...';

  @override
  String get coffeeNewReading => 'Nova leitura';

  @override
  String get coffeeAiPermission => 'Permissão de análise de café AI';

  @override
  String get coffeeStoneCostInfo => 'Cada análise custa 1 Pedra da Alma';

  @override
  String get coffeeEliteRefillActive =>
      'Vantagem de elite: 5 Soul Stones são atualizadas todas as noites';

  @override
  String get coffeeEliteRefillPromo =>
      'Vá Elite para ganhar 5 Soul Stones todas as noites';

  @override
  String get coffeeEliteGetBtn => 'Obtenha Elite';

  @override
  String get coffeeResultOnHome => 'Veja o resultado na página inicial';

  @override
  String get onboardingStart => 'Vamos começar';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingContinueWithoutAccount => 'Hesap Açmadan Devam Et';

  @override
  String get onboardingFinish => 'Iniciar jornada';

  @override
  String get onboardingNameHint => 'Um Nome Cósmico';

  @override
  String get onboardingNamePlaceholder => 'primeiro_último';

  @override
  String get onboardingHandleHint => 'Um identificador cósmico';

  @override
  String get onboardingHandlePlaceholder => 'galaxy_traveler';

  @override
  String get onboardingGenderTitle => 'Gênero';

  @override
  String get onboardingGenderFemale => 'Fêmea';

  @override
  String get onboardingGenderMale => 'Macho';

  @override
  String get onboardingGenderOther => 'Prefiro não dizer';

  @override
  String get onboardingStep1Title => 'Como devemos chamá-lo?';

  @override
  String get onboardingStep1Sub =>
      'Por qual nome e vibração o universo deveria conhecer você?';

  @override
  String get onboardingAvatarSelect => 'Selecione seu avatar';

  @override
  String get onboardingStep2Title => 'No momento em que sua alma entrou...';

  @override
  String get onboardingStep2Sub =>
      'Precisamos de seus dados básicos para calcular seu mapa astrológico de nascimento e rituais personalizados.';

  @override
  String get onboardingBirthDateLabel => 'Data de nascimento';

  @override
  String get onboardingBirthTimeLabel => 'Hora do nascimento';

  @override
  String get onboardingBirthLocationLabel => 'Cidade natal';

  @override
  String get onboardingTimeHint =>
      'Se você sabe a hora exata, entre para análise detalhada';

  @override
  String get onboardingLocationHint =>
      'Refine o cálculo selecionando uma cidade';

  @override
  String get onboardingUnknownTime => 'não sei a hora exata';

  @override
  String get onboardingPrivacyNote =>
      'Usado exclusivamente para desenhar seu gráfico personalizado.';

  @override
  String get onboardingStep3Title => 'Qual é o seu foco?';

  @override
  String get onboardingStep3Sub =>
      'Qual energia você mais deseja que cresça ou cure em sua vida agora?';

  @override
  String get onboardingFocusLabel => 'Foco (múltipla escolha)';

  @override
  String get onboardingFocusCareer => 'Carreira e dinheiro';

  @override
  String get onboardingFocusLove => 'Amor e Relacionamentos';

  @override
  String get onboardingFocusPeace => 'Paz Interior';

  @override
  String get onboardingFocusLuck => 'Sorte e oportunidades';

  @override
  String get onboardingRelLabel => 'Status atual do relacionamento:';

  @override
  String get onboardingRelSingle => 'Céu solitário';

  @override
  String get onboardingRelComplicated => 'Há alguém...';

  @override
  String get onboardingRelTalking => 'Complicado';

  @override
  String get onboardingRelRelationship => 'Vínculo feliz';

  @override
  String get onboardingStep4Title => 'Sua conexão com o universo à noite...';

  @override
  String get onboardingStep4Sub =>
      'Como seu subconsciente recebe mensagens? Cores e sonhos nos darão pistas.';

  @override
  String get onboardingDreamLabel =>
      'Com que frequência você se lembra dos seus sonhos?';

  @override
  String get onboardingDreamOften => 'Frequentemente e Claramente';

  @override
  String get onboardingDreamSometimes => 'Às vezes';

  @override
  String get onboardingDreamRarely => 'Raramente';

  @override
  String get onboardingDreamNever => 'Nunca';

  @override
  String get onboardingAuraLabel =>
      'Aura da sua alma (como você se sente hoje?)';

  @override
  String get onboardingStep5Title => 'Sua dança com o tempo...';

  @override
  String get onboardingStep5Sub =>
      'Quando sua energia está mais alta? Ajustaremos suas notificações de acordo.';

  @override
  String get onboardingSleepLabel => 'Seu padrão de sono';

  @override
  String get onboardingSleepMorning => 'Pessoa matinal';

  @override
  String get onboardingSleepNight => 'Coruja Noturna';

  @override
  String get onboardingSleepIrregular => 'Irregular';

  @override
  String get onboardingSleepLittle => 'Eu durmo muito pouco';

  @override
  String get onboardingMatchLabel => 'Correspondência e Conexão Cósmica';

  @override
  String get onboardingMatchDesc =>
      'Quero estar aberto para me conectar com perfis sinérgicos e combinações cósmicas especiais.';

  @override
  String get onboardingFinalTitle => 'Está tudo pronto...';

  @override
  String get onboardingFinalSub =>
      'Você está prestes a descobrir o que as estrelas planejaram para você. Crie sua conta e entre no universo cósmico.';

  @override
  String get onboardingAppleCreate => 'Crie uma conta com a Apple';

  @override
  String get onboardingGoogleCreate => 'Criar conta com o Google';

  @override
  String get onboardingErrorIncomplete =>
      'Bem-vindo! Faltam apenas alguns passos para completar seu perfil.';

  @override
  String get onboardingErrorFailed =>
      'Falha no login. Por favor, tente novamente.';

  @override
  String onboardingErrorAlreadyExists(String provider) {
    return 'Você já tem um perfil cósmico com esta conta$provider! Por favor, use a opção \'Entrar\' na primeira página.';
  }

  @override
  String onboardingErrorDBRejected(String error) {
    return 'Cadastro rejeitado pela base de dados:${error}Entre em contato com o suporte.';
  }

  @override
  String get onboardingErrorHandleTaken =>
      'Este nome de usuário já está em uso';

  @override
  String get notifTitle => 'Notificações';

  @override
  String get notifSubtitle => 'Escolha quais notificações você deseja receber';

  @override
  String get notifAnnouncements => 'Anúncios';

  @override
  String get notifAnnouncementsDesc => 'Novos recursos e atualizações';

  @override
  String get notifSounds => 'Sons';

  @override
  String get notifSoundsDesc => 'Alertas de notificação sonora';

  @override
  String get notifCookieAlarm => 'Novo alarme de cookies';

  @override
  String get notifCookieAlarmDesc => 'Quando chega um novo biscoito da sorte';

  @override
  String get notifFriendAlarm => 'Alarme de amigo';

  @override
  String get notifFriendAlarmDesc => 'Novas conexões da Rede Coruja';

  @override
  String get notifDailyReminder => 'Lembretes diários';

  @override
  String get notifDailyReminderDesc => 'Não se esqueça do seu biscoito diário';

  @override
  String get accountTitle => 'Detalhes da conta';

  @override
  String get accountSubtitle => 'Informações pessoais e gerenciamento de conta';

  @override
  String get accountUsername => 'Nome de usuário';

  @override
  String get accountLinkedEmail => 'E-mail vinculado';

  @override
  String get accountSignInMethod => 'Método de login';

  @override
  String get accountDeleteTitle => 'Excluir conta';

  @override
  String get accountDeleteDesc =>
      'Todos os seus dados serão excluídos permanentemente.\nEsta ação não pode ser desfeita.';

  @override
  String get accountDeleteCancel => 'Cancelar';

  @override
  String get accountDeleteConfirm => 'Excluir';

  @override
  String get accountDeletePermanent => 'Excluir conta permanentemente';

  @override
  String get welcomeTagline => 'A magia está dentro de você.';

  @override
  String get welcomeAppleContinue => 'Continuar com a Apple';

  @override
  String get welcomeGoogleContinue => 'Continuar com o Google';

  @override
  String get moodGuideTitle => 'Guia de humor';

  @override
  String get moodAwarenessTitle => 'Consciência Emocional';

  @override
  String get moodAwarenessDesc =>
      'Escolher seu humor torna seus sentimentos concretos; este é o primeiro passo para encontrar equilíbrio interior e autoconsciência.';

  @override
  String get moodCosmicTitle => 'Frequência Cósmica';

  @override
  String get moodCosmicDesc =>
      'Cada emoção que você escolhe na roda carrega uma frequência. A aura da tela se alinha diretamente com seus sentimentos.';

  @override
  String get moodHowToTitle => 'Como usar?';

  @override
  String get moodHowToDesc =>
      'Basta girar a roda e escolher a expressão que melhor reflete o seu humor. Não julgue o seu sentimento, apenas sinta e aceite.';

  @override
  String get moodQuestionAlt => 'Como está seu humor hoje?';

  @override
  String get moodSpinHint => 'Gire a roda, escolha seu humor ✨';

  @override
  String get bentoCoffeeTitle => 'Leitura de café';

  @override
  String get bentoCoffeeDesc => 'Sussurros de motivos';

  @override
  String get bentoUnexplored =>
      'Este reino está esperando para ser explorado...';

  @override
  String get bentoSealed => 'Selado';

  @override
  String get horoscopeDailyEnergy => 'A energia de hoje';

  @override
  String get horoscopeWestern => 'Oeste Ocidental.';

  @override
  String get horoscopeAsian => 'Sabedoria Asiática';

  @override
  String get horoscopeMayan => 'Espírito Maia';

  @override
  String get shareSaved => 'Salvo ✓';

  @override
  String get shareDownload => 'Download';

  @override
  String get shareShare => 'Compartilhar';

  @override
  String get shareStory => 'História';

  @override
  String get sharePost => 'Publicar';

  @override
  String get shareCookieText =>
      'Isto é o que ganhei do biscoito da sorte hoje! 🥠✨\n#CrackWish';

  @override
  String get shareCoffeeTitle => 'Leitura de café';

  @override
  String get cookieLockedTitle => 'Este cookie especial está bloqueado';

  @override
  String get cookieComingSoon => 'Em breve ✨';

  @override
  String get dreamWaitOrReturn =>
      'Você pode esperar aqui ou retornar à página inicial. Iremos notificá-lo quando estiver pronto e você poderá lê-lo na seção \"Meus Sonhos\".';

  @override
  String get dreamReturnHome => 'Retornar à página inicial';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get profileEditSubtitle =>
      'Edite nome, zodíaco e informações pessoais';

  @override
  String get profileSearchHint =>
      'Pesquise zodíaco, cidade ou data de nascimento...';

  @override
  String get profileStoreUnavailable => 'O link da loja não está disponível.';

  @override
  String get profileMailNotFound =>
      'Nenhum aplicativo de e-mail encontrado. Você pode escrever para support@crackandwish.com';

  @override
  String get profileRitualCode => 'Código Ritual';

  @override
  String get profileRitualDesc =>
      'Este código é a sua identidade ritual pessoal. Compartilhe com amigos para convidá-los para a Rede Coruja.';

  @override
  String get profileRitualCopied => 'Código ritual copiado ✨';

  @override
  String get profileRitualInfo => 'Compartilhe com amigos, explorem juntos!';

  @override
  String get profileShareCode => 'Código de compartilhamento';

  @override
  String get profileDeleteAccount => 'Excluir conta';

  @override
  String get profileDeleteDesc =>
      'Todos os seus dados serão excluídos permanentemente.\nEsta ação não pode ser desfeita.';

  @override
  String get profileDeleteCancel => 'Cancelar';

  @override
  String get profileDeleteConfirm => 'Excluir conta';

  @override
  String get profileSignOut => 'Sair';

  @override
  String get profileSignOutDesc =>
      'Saia da sua conta com segurança.\nSeus dados serão preservados.';

  @override
  String get profileSignOutCancel => 'Cancelar';

  @override
  String get profileSignOutConfirm => 'Sair';

  @override
  String get profilePrivacyPolicy => 'política de Privacidade';

  @override
  String get profileTermsOfUse => 'Termos de Uso';

  @override
  String get profileGetElite => 'Obtenha Elite';

  @override
  String get profileGetEliteSubtitle => 'Porta para a consciência';

  @override
  String get profileCosmicProfile => 'Perfil Cósmico';

  @override
  String get profileCosmicSubtitle => 'Gráfico, hora e localização';

  @override
  String get profileSectionAccount => 'Conta';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileNotificationSettings => 'Configurações de notificação';

  @override
  String get profileRestorePurchases => 'Restaurar compras';

  @override
  String get profileRestoreSuccess => 'Compras restauradas com sucesso!';

  @override
  String get profileRestoreFail => 'Nenhuma compra encontrada para restaurar.';

  @override
  String get profileHelp => 'Ajuda';

  @override
  String get profileShare => 'Compartilhar';

  @override
  String get profileRate => 'Avaliar';

  @override
  String get profileVersion => 'Versão';

  @override
  String get profileCosmicName => 'Nome Cósmico';

  @override
  String get profileSealProfile => 'Perfil de vedação';

  @override
  String get profileChooseAvatar => 'Escolha seu avatar mágico.';

  @override
  String get profileStrengthenBonds => 'Fortalecer vínculos';

  @override
  String get profileStrengthenBondsDesc =>
      'Expanda o universo cósmico com amigos.';

  @override
  String get profileEarnSoulStones => 'Ganhe +2 Pedras da Alma';

  @override
  String get profileCodeCopied => 'Código copiado!';

  @override
  String get profileNotifications => 'Notificações';

  @override
  String get profileSupportExperience => 'Suporte e Experiência';

  @override
  String get profileSeerNovice => 'Vidente Novato';

  @override
  String get profileSeerApprentice => 'Aprendiz de Vidente';

  @override
  String get profileSeer => 'Vidente';

  @override
  String get profileSeerWise => 'Vidente Sábio';

  @override
  String get profileSeerMaster => 'Mestre Vidente';

  @override
  String get profileSeerCosmic => 'Vidente Cósmico';

  @override
  String get profileUploadFailed =>
      'Falha no upload da foto! Por favor, verifique sua conexão.';

  @override
  String get profileCropTitle => 'Colheita Cósmica';

  @override
  String get profileCropCancel => 'Cancelar';

  @override
  String get profileCropDone => 'Feito';

  @override
  String get moderationAdultContent =>
      'A energia desta imagem não é compatível com o nosso universo Cósmico (Conteúdo Inapropriado).';

  @override
  String get moderationViolence =>
      'Escolha um avatar mais calmo que reflita sua aura e não canse a mente (Conteúdo Perturbador).';

  @override
  String get moderationTooLarge =>
      'A imagem é grande o suficiente para sobrecarregar a rede cósmica. Selecione uma foto com menos de 5 MB.';

  @override
  String get moderationInvalidFormat =>
      'Sua foto não pôde ser lida pelo nosso pergaminho mágico, o formato está corrompido.';

  @override
  String get moderationUnknown => 'Ocorreu uma flutuação cósmica desconhecida.';

  @override
  String profileShareInvite(String code) {
    return 'Junte-se ao universo Crack&Wish! ✨\nMeu código ritual:${code}Digite este código para ganhar +1 Pedra da Alma, +50 Aura e um Biscoito Premium surpresa!\nhttps://crackandwish.com';
  }

  @override
  String get profileShareApp =>
      'Descubra sua fortuna com Crack&Wish! •✨\nQuebre biscoitos, leia tarô, interprete sonhos.\n\nhttps://crackandwish.com';

  @override
  String get profileEliteYouAre => 'Você é elite';

  @override
  String get profileGoElite => 'Vá para a elite';

  @override
  String get profileEliteMystical => 'Veja portões místicos';

  @override
  String get profileEliteDoor => 'Porta para a consciência';

  @override
  String get profileMyCosmicProfile => 'Meu Perfil Cósmico';

  @override
  String get profileCosmicDetails => 'Detalhes do gráfico, hora e local';

  @override
  String get profileRestorePurchasesBtn => 'Restaurar compras';

  @override
  String get profileRestoreSubtitle => 'Restaure suas compras anteriores';

  @override
  String get profileInviteFriends => 'Convide amigos';

  @override
  String get profileInviteFriendsDesc =>
      'Construa laços cósmicos, ganhe juntos';

  @override
  String get cosmicChart => 'Carta Cósmica';

  @override
  String get cosmicWestern => 'OCIDENTAL';

  @override
  String get cosmicAsian => 'ASIÁTICO';

  @override
  String get cosmicMayan => 'MAIA';

  @override
  String get cosmicRising => 'ASCENDENTE';

  @override
  String get cosmicArrivalDate => 'DATA DE CHEGADA';

  @override
  String get cosmicBirthTime => 'HORA DO NASCIMENTO';

  @override
  String get cosmicTimeUnknown => 'Tempo desconhecido';

  @override
  String get cosmicBirthPlace => 'COORDENADAS DO LOCAL DE NASCIMENTO';

  @override
  String get cosmicCountry => 'País';

  @override
  String get cosmicSelectCountry => 'Selecione o país';

  @override
  String get cosmicCityDistrict => 'Cidade, Distrito e Vila';

  @override
  String get cosmicSelectDateFirst =>
      'Selecione sua data de nascimento primeiro.';

  @override
  String cosmicLockedDays(int days) {
    return 'Bloqueado por${days}dias';
  }

  @override
  String get cosmicSave => 'Salvar';

  @override
  String get cosmicSearchLocation => 'Pesquisar localização exata';

  @override
  String get cosmicSearchHint => 'Digite aldeia, distrito, etc...';

  @override
  String get cosmicAddFreeText => 'Adicionar como texto livre';

  @override
  String get cosmicRequiresTime => 'Requer tempo';

  @override
  String get badgeReady => 'PREPARAR';

  @override
  String get badgeNew => 'NOVO';

  @override
  String get paywallLegal =>
      'Crack Wish Elite é uma assinatura com renovação automática. O pagamento será cobrado em sua conta na confirmação da compra. A assinatura é renovada automaticamente, a menos que seja cancelada pelo menos 24 horas antes do final do período atual. Você pode gerenciar e cancelar suas assinaturas nas configurações da App Store.';

  @override
  String get cosmicSelect => 'Selecione';

  @override
  String get coffeeRelSingle => 'Alma Única';

  @override
  String get coffeeRelInLove => 'O coração está cheio';

  @override
  String get coffeeRelEngaged => 'Noivo';

  @override
  String get coffeeRelMarried => 'Casado';

  @override
  String get coffeeRelComplicated => 'Complicado';

  @override
  String get coffeeFocusLove => 'Amor e Harmonia';

  @override
  String get coffeeFocusCareer => 'Carreira e Finanças';

  @override
  String get coffeeFocusHealing => 'Cura e Paz';

  @override
  String get coffeeFocusGeneral => 'Futuro Geral';

  @override
  String get coffeeFocusSurprise => 'Surpreenda-me';

  @override
  String get coffeeMoodPeaceful => 'Pacífico';

  @override
  String get coffeeMoodExcited => 'Excitado';

  @override
  String get coffeeMoodAnxious => 'Ansioso';

  @override
  String get coffeeMoodIndecisive => 'Indeciso';

  @override
  String get coffeeMoodEnergetic => 'Energético';

  @override
  String get coffeeMoodMelancholic => 'Melancólico';

  @override
  String get coffeeAllPhotosRequired => 'Por favor, tire todas as fotos!';

  @override
  String get coffeeNotEnoughStones => 'Não há Pedras da Alma suficientes!';

  @override
  String coffeeSoulStoneCount(int count) {
    return '${count}Pedras da Alma disponíveis';
  }

  @override
  String get coffeeUseSoulStone => 'Use 1 Pedra da Alma';

  @override
  String get languageSettingsSubtitle => 'Escolha o idioma do aplicativo';

  @override
  String get cosmicSearchHintShort => 'Procurar...';

  @override
  String get cosmicAddThis => 'Adicione isto';

  @override
  String get horoscopeWesternText =>
      'As estrelas se alinham para sua carreira. Dê passos rápidos e decisivos.';

  @override
  String get horoscopeAsianText =>
      'O elemento água está ativo. Sua intuição é forte, basta ouvir seu coração.';

  @override
  String get horoscopeMayanText =>
      'O tom 4 está ativo. Um dia perfeito para estabelecer ordem e planejar sua vida.';

  @override
  String get horoscopeExplore => 'Explorar';

  @override
  String get cookieDayCompleted => 'Dia concluído';

  @override
  String get cookieSeeYouTomorrow => 'Até amanhã com novos cookies.';

  @override
  String get cookieRarityLegendary => 'Lendário';

  @override
  String get cookieRarityRare => 'Cru';

  @override
  String get cookiePremiumCollection => 'Coleção Premium';

  @override
  String cookiePurchaseBtn(String price) {
    return 'Compra ($price)';
  }

  @override
  String get cookieTapOutsideToClose => 'Toque fora para fechar';

  @override
  String get cookieAddedToCollection =>
      'Cookie adicionado com sucesso à sua coleção!';

  @override
  String get cookiePremiumFallback => 'Biscoito Premium';

  @override
  String get dreamSoulStoneRequired => 'Pedra da Alma Necessária';

  @override
  String get dreamSoulStoneRequiredDesc =>
      'Soul Stones são necessárias para análises profundas.\n\nVocê pode ganhar Soul Stones convertendo pontos Aura ou com assinatura Elite.';

  @override
  String get dreamGetElite => 'Obtenha Elite';

  @override
  String get dreamClinicalGateTitle => 'Portão de Análises Clínicas';

  @override
  String dreamClinicalGateDesc(int soulStones) {
    return 'Pedras da Alma Atuais:${soulStones}Esta psicanálise profunda de nível clínico custa 1 Pedra da Alma.';
  }

  @override
  String get dreamUseOneStone => 'Use 1 pedra';

  @override
  String get dreamDeepAnalysisBgPreparing =>
      'A análise profunda está sendo preparada em segundo plano. Você receberá uma notificação quando estiver pronto.';

  @override
  String get dreamYourSoulStones => 'Suas pedras da alma';

  @override
  String dreamSoulStonesRemaining(int count) {
    return '${count}Pedras da Alma restantes';
  }

  @override
  String get dreamSoulStonesEmpty => 'Fora das Pedras da Alma';

  @override
  String get dreamRequiredForDeep => 'Necessário para análise profunda';

  @override
  String get dreamEachAnalysisCost => 'Cada análise custa 1 Pedra da Alma';

  @override
  String get dreamEliteRefillActive =>
      'Elite recarrega 5 Soul Stones todas as noites';

  @override
  String get dreamEliteRefillPromo => 'Obtenha 5 Soul Stones diárias com Elite';

  @override
  String get dreamWatchAd => 'Assistir ao anúncio';

  @override
  String get dreamBgAnalyzing =>
      'Seu sonho está sendo analisado em segundo plano. Você receberá uma notificação quando estiver pronto.';

  @override
  String get dreamDeepAnalysis => 'Análise Profunda';

  @override
  String get dreamDiscoverSecrets => 'Descubra segredos';

  @override
  String get dreamDidYouKnow => 'Você sabia?';

  @override
  String get dreamNeuroPsychAnalysis => 'ANÁLISE NEURO-PSIQUIA';

  @override
  String get dreamYourDream => 'SEU SONHO';

  @override
  String get dreamEmotionalProfile => 'Perfil Emocional';

  @override
  String get dreamEmotionalProfileSub => 'Camadas psicológicas durante o sonho';

  @override
  String get dreamShadowSelf => 'Eu Sombrio';

  @override
  String get dreamShadowSelfSub =>
      'Aspectos suprimidos e não examinados do subconsciente';

  @override
  String get dreamRecurringPatterns => 'Padrões recorrentes';

  @override
  String get dreamRecurringPatternsSub =>
      'Loops recorrentes e bloqueios psicológicos';

  @override
  String dreamSuggestedRitual(String title) {
    return 'Ritual Sugerido:$title';
  }

  @override
  String get dreamSuggestedRitualSub =>
      'Uma ação especializada para gerir o impacto deste sonho';

  @override
  String get dreamScienceNote => 'Nota científica:';

  @override
  String get dreamWriteNewDream => 'Escreva um novo sonho';

  @override
  String get dreamNoMonthDreams => 'Ainda não há sonhos escritos este mês ✨';

  @override
  String get dreamMysteriousDream => 'Sonho Misterioso';

  @override
  String get dreamStandardAnalysis => 'ANÁLISE PADRÃO';

  @override
  String get dreamGeneralAnalysis => 'Análise Geral';

  @override
  String get dreamPsychological => 'Psicológico';

  @override
  String get dreamSpiritual2 => 'Espiritual';

  @override
  String get dreamAdvice => 'Conselho';

  @override
  String get dreamDeepenedInsights => 'Insights aprofundados';

  @override
  String get dreamEliteCreditsTitle => 'Créditos Elite';

  @override
  String get dreamReadingCreditsTitle => 'Seus créditos de leitura';

  @override
  String dreamCreditsRemaining(int count) {
    return '${count}créditos restantes';
  }

  @override
  String get dreamDailyLimitReached => 'Limite diário atingido';

  @override
  String get dreamZeroCredits => '0 créditos restantes';

  @override
  String dreamDailyPremiumReads(int count) {
    return '${count}interpretações diárias dos sonhos';
  }

  @override
  String get dreamNoAdsRequired => 'Não há necessidade de assistir anúncios';

  @override
  String get dreamCreditsResetNightly => 'Créditos redefinidos todas as noites';

  @override
  String get dreamOneFreeDaily => '1 interpretação gratuita todos os dias';

  @override
  String dreamWatchAdsForCredits(int maxAds, int watched) {
    return 'Assista a anúncios de${maxAds}créditos extras ($watched/$maxAds)';
  }

  @override
  String get dreamUnconsciousFrequencies => 'FREQUÊNCIAS INCONSCIENTES';

  @override
  String get dreamOrbEmotion => 'EMOÇÃO';

  @override
  String get dreamOrbEntropy => 'ENTROPIA';

  @override
  String get dreamOrbActivity => 'ATIVIDADE';

  @override
  String get dreamOrbResidue => 'RESÍDUO';

  @override
  String get dreamHighConfidence => 'Alta confiança';

  @override
  String get dreamModerateConfidence => 'Confiança moderada';

  @override
  String get dreamLowConfidence => 'Baixa confiança';

  @override
  String get dreamCoreThematicPattern => 'PADRÃO TEMÁTICO PRINCIPAL';

  @override
  String get dreamMetricEmotionalLoad => 'Emocional\nCarregar';

  @override
  String get dreamMetricEmotionalLoadDesc =>
      'Com que intensidade o centro emocional do seu cérebro foi ativado durante esse sonho.';

  @override
  String get dreamMetricUncertaintyDesc =>
      'Quão ilógica ou inconsistente era a narrativa do seu sonho.';

  @override
  String get dreamMetricRecentMemory => 'Recente\nConexão';

  @override
  String get dreamMetricRecentMemoryDesc =>
      'Quanto do seu sonho foi influenciado por eventos recentes da vida real.';

  @override
  String get dreamMetricAgency => 'Agência /\nControle';

  @override
  String get dreamMetricAgencyDesc =>
      'Quanto controle você teve sobre os eventos do seu sonho.';

  @override
  String get dreamSeverityHigh => 'Alto';

  @override
  String get dreamSeverityNormal => 'Normal';

  @override
  String get dreamSeverityLow => 'Baixo';

  @override
  String get dreamCognitiveDistribution => 'DISTRIBUIÇÃO COGNITIVA';

  @override
  String get dreamTapToExpand => 'TOQUE PARA EXPANDIR';

  @override
  String get dreamNeurologicalBasis => 'Base Neurológica';

  @override
  String get dreamEvidenceBase => 'BASE DE EVIDÊNCIAS';

  @override
  String get dreamRootCause => 'Causa raiz';

  @override
  String get dreamAbsolutely => 'Absolutamente';

  @override
  String get dreamMaybe => 'Talvez';

  @override
  String get dreamNotSure => 'Não tenho certeza';

  @override
  String get dreamDreamEssence => 'ESSÊNCIA DE SONHO';

  @override
  String get dreamClarifyingResponses => 'ESCLARECENDO RESPOSTAS';

  @override
  String get dreamCosmicRhythmSynced => 'Ritmo Cósmico Sincronizado';

  @override
  String get dreamCosmicRhythmSyncedDesc =>
      'Você receberá avisos de sonhos personalizados com base no seu ciclo de sono.';

  @override
  String get dreamSyncSleepData => 'Sincronizar dados de sono';

  @override
  String get dreamSyncSleepDataDesc =>
      'Permita que ele detecte quando você acordar para perguntar sobre seu sonho mais profundo.';

  @override
  String get dreamAwarenessFallback =>
      'Essa consciência é o início de um novo caminho. É hora de enfrentar isso.';

  @override
  String get dreamExtractingEssence => 'Extraindo a essência dos sonhos...';

  @override
  String get dreamNoReasoning => 'Nenhum raciocínio gerado.';

  @override
  String get dreamNotAnalyzable =>
      'Tem certeza que isso foi um sonho?\nPor favor, descreva uma cena real que você vivenciou enquanto dormia.';

  @override
  String get owlTabFriends => 'Meus amigos';

  @override
  String get owlTabConnections => 'Conexões';

  @override
  String get owlTabInbox => 'Caixa de entrada';

  @override
  String get owlSearchCosmic => 'Pesquisar universo cósmico...';

  @override
  String get owlSearchFriends => 'Pesquisar amigos...';

  @override
  String get owlPhoneContacts => 'Contatos telefônicos';

  @override
  String get owlNoOneFoundCosmic =>
      'Ninguém foi encontrado no universo cósmico.';

  @override
  String get owlFoundInCosmic => 'Encontrado no Universo Cósmico';

  @override
  String get owlUnknownProfile => 'Perfil desconhecido';

  @override
  String owlFriendRequestSent(String name) {
    return 'Pedido de amizade enviado para$name!';
  }

  @override
  String get owlRequestSentStatus => 'Enviado';

  @override
  String get owlSendRequestAction => 'Enviar solicitação';

  @override
  String get owlConnectContacts => 'Conectar contatos';

  @override
  String get owlConnectContactsDesc =>
      'Encontre seus amigos instantaneamente.\nSeus contatos NUNCA são armazenados em servidores.';

  @override
  String get owlNoContactsFound =>
      'Não conseguimos encontrar ninguém\nno universo Crack&Wish';

  @override
  String get owlNoContactsFoundDesc =>
      'Você pode iniciar a energia cósmica convidando-os!';

  @override
  String get owlUnknown => 'Desconhecido';

  @override
  String get owlAppUserLabel => 'Usuário Crack&Wish';

  @override
  String get owlInContactsLabel => 'Nos seus contatos';

  @override
  String get owlNoFriendsYet => 'Ainda não há amigos';

  @override
  String get owlNoResultsFound => 'Nenhum resultado encontrado';

  @override
  String get owlFriendRequests => 'Pedidos de amizade';

  @override
  String get owlFriendsHeader => 'Seus amigos';

  @override
  String get owlAcceptAction => 'Aceitar';

  @override
  String get owlRejectAction => 'Rejeitar';

  @override
  String get owlInviteReward => '+2 Pedras da Alma';

  @override
  String owlInviteShareMessage(String username) {
    return 'Vamos iluminar a escuridão juntos! ✨\nJunte-se ao Crack Wish através do meu link de convite abaixo, conecte-se automaticamente e ganhe Start Rewards!\n\nLink do meu convite:\nhttps://crackwish.com/invite/$username';
  }

  @override
  String get owlInviteFriends => 'Convide amigos';

  @override
  String get owlInviteFriendsDesc => 'Reflita o universo cósmico';

  @override
  String get owlNoLettersYet => 'Nenhuma carta ainda';

  @override
  String owlLetterSentNotification(String name) {
    return '${name}enviou uma carta...';
  }

  @override
  String get owlOnItsWay => 'A Coruja está a caminho 🕊️';

  @override
  String owlLetterCount(int count) {
    return '${count}letras';
  }

  @override
  String owlUnreadCountBadge(int count) {
    return '${count}Novo';
  }

  @override
  String get owlIUnderstand => 'Eu entendo';

  @override
  String get owlInviteHowTitle => 'Como você gostaria de convidar?';

  @override
  String get owlInviteHowSubtitle =>
      'Como você deseja enviar sua chave cósmica para essa pessoa?';

  @override
  String get owlInviteSendAsMessage => 'Enviar como mensagem';

  @override
  String get owlInviteSMSSubtitle => 'Enviar por mensagem clássica';

  @override
  String get owlInviteOtherApps => 'Outros aplicativos';

  @override
  String get owlInviteOtherAppsSubtitle => 'Instagram, TikTok, X, etc.';

  @override
  String get owlWhatsAppNotFound => 'WhatsApp não encontrado';

  @override
  String get owlSMSNotFound => 'Aplicativo SMS não encontrado';

  @override
  String get owlDisconnectAction => 'Desconectar';

  @override
  String owlDisconnectConfirm(String name) {
    return 'Tem certeza de que deseja quebrar o vínculo mágico com$name?';
  }

  @override
  String get owlDisconnectConfirmButton => 'Sim, desconectar';

  @override
  String get owlCancel => 'Cancelar';

  @override
  String get owlSendMagic => 'Enviar (Encantado)';

  @override
  String get owlSend => 'Enviar';

  @override
  String get owlCookieAdded => 'Cookie adicionado';

  @override
  String get owlAddCookie => 'Adicionar biscoito';

  @override
  String get owlNoCookiesInCollection => 'Nenhum cookie em sua coleção';

  @override
  String get owlWriteLetterHint => 'Escreva sua carta...';

  @override
  String get owlSendCookie => 'Enviar biscoito';

  @override
  String get zodiacMeasureHarmony => 'MEDIR A HARMONIA CÓSMICA';

  @override
  String get zodiacDiscoverEnergy =>
      'Descubra sua dupla energia guiada pelas estrelas';

  @override
  String get zodiacChooseFriend => 'ESCOLHER AMIGO';

  @override
  String get zodiacChooseFriendSubtitle =>
      'Selecione um amigo para comparar suas energias cósmicas';

  @override
  String get zodiacDiscoverYourself => 'Descubra você mesmo';

  @override
  String get zodiacCharacteristicAnalysis => 'ANÁLISE CARACTERÍSTICA';

  @override
  String zodiacAbilityMap(String name) {
    return 'Mapa de habilidades de$name';
  }

  @override
  String get zodiacPros => 'Vantagens';

  @override
  String get zodiacCons => 'Desafios';

  @override
  String get zodiacAdvice => 'Conselho';

  @override
  String get zodiacDailyWhisperSubtitle =>
      'Sinta o sussurro de hoje e\ndesvende os segredos do seu retrato espiritual.';

  @override
  String get zodiacDailyWhisperHeadline =>
      'Mensagem de hoje e retrato espiritual';

  @override
  String get zodiacOpenGuide => 'Abra o guia';

  @override
  String get zodiacNoFriends => 'Ainda não há amigos';

  @override
  String get zodiacSelect => 'SELECIONAR';

  @override
  String get zodiacQuestCompleted => 'Missão concluída';

  @override
  String get zodiacQuestCompletedSubtitle =>
      'Você está totalmente alinhado com o ritmo do universo.';

  @override
  String get zodiacRewardAura => 'Recompensa ganha:\n+4 AURA';

  @override
  String get zodiacStartNewQuest => 'INICIAR NOVA MISSÃO';

  @override
  String zodiacDailyQuestTitle(int days) {
    return '$days- MISSÃO DO DIA';
  }

  @override
  String zodiacDailyQuestDesc(String weakness) {
    return 'Quebre sua fraqueza: \"$weakness\"';
  }

  @override
  String zodiacQuestDayProgress(int current, int total) {
    return 'DIA$current/$total';
  }

  @override
  String get zodiacQuestTodayDiscovery => 'A DESCOBERTA DE HOJE';

  @override
  String get zodiacQuestCompletedToday => 'CONCLUÍDO HOJE';

  @override
  String get zodiacQuestCompleteNow => 'COMPLETE A MISSÃO AGORA';

  @override
  String get zodiacQuestMarkCompleted => 'TERMINEI HOJE';

  @override
  String get zodiacLoveHarmony => 'AMOR HARMONIA';

  @override
  String get zodiacFriendshipHarmony => 'AMIZADE';

  @override
  String get zodiacCommunicationHarmony => 'COMUNICAÇÃO E MENTE';

  @override
  String get zodiacWorkHarmony => 'COLABORAÇÃO';

  @override
  String get zodiacAdventureHarmony => 'AVENTURA E DIVERSÃO';

  @override
  String get zodiacViralDynamics => 'DINÂMICA VIRAL';

  @override
  String get zodiacDeepSynastryMap => 'MAPA DE SINASTRIA PROFUNDA';

  @override
  String zodiacSynastrySubtitle1(String name) {
    return 'A harmonia entre você e${name}não se limita aos signos solares.';
  }

  @override
  String get zodiacSynastrySubtitle2 =>
      'Com base na privacidade, o algoritmo cósmico faz referências cruzadas de mapas astrológicos de nascimento, Lua e fases ascendentes nos bastidores, tornando esta análise completamente exclusiva para você.';

  @override
  String get zodiacDailyWhisperTitle => 'Sussurro de hoje';

  @override
  String get zodiacChooseSign => 'ESCOLHA O SINAL';

  @override
  String get zodiacCosmicGuide => 'SEU GUIA CÓSMICO';

  @override
  String get zodiacNew => 'NOVO';

  @override
  String get zodiacCosmicHarmonyTitle => 'HARMONIA CÓSMICA';

  @override
  String get zodiacAwesome => 'INCRÍVEL';

  @override
  String get zodiacSpiritPortrait => 'Retrato Espiritual';

  @override
  String get onboardingFeatureStepTitle => 'O que espera por você?';

  @override
  String get onboardingFeatureStepSub =>
      'Você está pronto para ouvir os sussurros do universo e descobrir o seu destino?';

  @override
  String get onboardingNameStepTitle => 'Vamos conhecer você';

  @override
  String get onboardingNameStepSub =>
      'Crie seu perfil e determine sua identidade cósmica para que suas almas gêmeas possam encontrá-lo.';

  @override
  String get onboardingDateStepTitle => 'Coordenada Cósmica';

  @override
  String get onboardingDateStepSub =>
      'Escolha o momento em que você nasceu como base do seu mapa astrológico.';

  @override
  String get onboardingFocusStepTitle => 'Bússola do Coração';

  @override
  String get onboardingFocusStepSub =>
      'Defina sua intenção, vamos mapear seu caminho.';

  @override
  String get onboardingDreamStepTitle => 'Voz do Subconsciente';

  @override
  String get onboardingDreamStepSub => 'Como seus sonhos chegam até você?';

  @override
  String get onboardingSleepStepTitle => 'Sua bússola interior';

  @override
  String get onboardingSleepStepSub =>
      'Como você encontra o seu caminho durante os momentos decisivos do destino em sua vida?';

  @override
  String get onboardingFeatureAstrology => 'Mapa astrológico personalizado';

  @override
  String get onboardingFeatureTarot => 'Guiando a jornada do Tarô';

  @override
  String get onboardingFeatureCoffee =>
      'Antigos segredos da adivinhação do café';

  @override
  String get onboardingFeatureDream => 'Análise Subconsciente dos Sonhos';

  @override
  String get onboardingFeatureZodiac =>
      'Compatibilidades místicas chinesas e maias';

  @override
  String get onboardingWelcomeTagline =>
      'Hoje minhas esperanças são maiores que meus sonhos.';

  @override
  String get onboardingFinalTagline => 'Clique para proteger seu mapa cósmico.';

  @override
  String get tarotShareText =>
      'As cartas falaram comigo assim! 🔮✨\n#CrackWish #Tarot';

  @override
  String get natalChartTitle => 'Mapa de Nascimento';

  @override
  String get natalChartCalculating => 'Calculando seu mapa astral...';

  @override
  String get natalChartSwipeHint => 'Deslize para inspecionar';

  @override
  String get natalChartPlanetPositions => 'POSIÇÕES DO PLANETA';

  @override
  String get natalChartAngularPoints => 'PONTOS ANGULARES';

  @override
  String get natalChartAsc => 'ASC (Ascendente)';

  @override
  String get natalChartAscDesc =>
      'A máscara que você mostra ao mundo exterior, sua imagem e sua primeira impressão.';

  @override
  String get natalChartMc => 'MC (Meio do Céu)';

  @override
  String get natalChartMcDesc =>
      'Sua carreira, sua imagem pública e seus objetivos de vida.';

  @override
  String get natalChartDc => 'DC (descendente)';

  @override
  String get natalChartDcDesc =>
      'As principais características que você procura em relacionamentos, casamento e parcerias.';

  @override
  String get natalChartIc => 'IC (Imum Coeli)';

  @override
  String get natalChartIcDesc =>
      'Suas raízes, sua família, seu passado e sua segurança central em seu mundo interior.';

  @override
  String get natalChartTabPersonality => 'Resumo Principal da Personalidade';

  @override
  String get natalChartTabLove => 'Amor e Relacionamentos';

  @override
  String get natalChartTabCareer => 'Carreira e dinheiro';

  @override
  String get natalChartTabEmotional => 'Estrutura Emocional';

  @override
  String get natalChartTabStrengths => 'Pontos fortes e fracos';

  @override
  String natalChartHouse(String house) {
    return 'Casa$house';
  }

  @override
  String zodiacGreeting(String name) {
    return 'Olá$name,';
  }

  @override
  String get zodiacCosmicTraveler => 'Viajante Cósmico,';

  @override
  String get zodiacBirthDate => 'DATA DE NASCIMENTO';

  @override
  String get zodiacStarsKnowYou => 'Deixe as estrelas conhecerem você';

  @override
  String get zodiacConfirm => 'CONFIRMAR';

  @override
  String get zodiacDiscoverYourselfBtn => 'DESCUBRA-SE';

  @override
  String get zodiacEliteRequiredDesc =>
      'Você precisa de uma assinatura Elite para descobrir profunda compatibilidade astrológica e dinâmica viral com seus amigos.';

  @override
  String get zodiacEliteDiscoverBtn => 'Descubra os privilégios Elite';

  @override
  String get zodiacHubWestern => 'ASTROLOGIA OCIDENTAL';

  @override
  String get zodiacHubAsian => 'ASTROLOGIA ASIÁTICA';

  @override
  String get zodiacHubMayan => 'ASTROLOGIA MAIA';

  @override
  String get actionLater => 'Mais tarde';

  @override
  String get coffeeViewReading => 'Ver leitura';

  @override
  String get coffeeReadyTitleWithEmoji => '☕️ Sua leitura está pronta!';

  @override
  String get wheelTask_w_c1 =>
      'Envie uma mensagem “pensando em você” para uma pessoa querida';

  @override
  String get wheelTask_w_c2 =>
      'Diga olá para alguém com quem você não fala há algum tempo';

  @override
  String get wheelTask_w_c3 =>
      'Diga a um membro da família o quão importante ele é hoje';

  @override
  String get wheelTask_w_c4 => 'Elogie alguém próximo a você';

  @override
  String get wheelTask_w_c5 => 'Envie um vídeo engraçado para um amigo';

  @override
  String get wheelTask_w_c6 => 'Agradeça a alguém hoje e explique por que';

  @override
  String get wheelTask_w_s1 =>
      'Olhe-se no espelho, sorria para si mesmo e segure por 10 segundos';

  @override
  String get wheelTask_w_s2 =>
      'Lembre-se da última vez que você riu alto e sorriu novamente';

  @override
  String get wheelTask_w_s3 => 'Pense em uma lembrança engraçada e ria alto';

  @override
  String get wheelTask_w_s4 =>
      'Encontre e veja a foto mais engraçada do seu telefone';

  @override
  String get wheelTask_w_s5 => 'Sorria para a primeira pessoa que você ver';

  @override
  String get wheelTask_w_s6 =>
      'Pense no momento mais engraçado que você viveu hoje';

  @override
  String get wheelTask_w_m1 => 'Levante-se e alongue-se por 30 segundos';

  @override
  String get wheelTask_w_m2 => 'Ande pelo seu quarto por 1 minuto';

  @override
  String get wheelTask_w_m3 => 'Pule 10 vezes e diga \"Eu consigo!\"';

  @override
  String get wheelTask_w_m4 =>
      'Levante os braços e faça uma pose de Superman por 20 segundos';

  @override
  String get wheelTask_w_m5 =>
      'Role os ombros para frente 5 vezes e depois para trás 5 vezes';

  @override
  String get wheelTask_w_m6 =>
      'Respire fundo, abra bem os braços e segure por 10 segundos';

  @override
  String get wheelTask_w_mu1 => 'Toque sua música favorita e ouça por 1 minuto';

  @override
  String get wheelTask_w_mu2 =>
      'Toque uma música aleatória e ouça os primeiros 30 segundos';

  @override
  String get wheelTask_w_mu3 =>
      'Cantar! Cante em voz alta como se ninguém estivesse ouvindo';

  @override
  String get wheelTask_w_mu4 =>
      'Ouça uma música de um gênero que você ainda não explorou hoje';

  @override
  String get wheelTask_w_mu5 =>
      'Feche os olhos e ouça os sons ao seu redor por 30 segundos';

  @override
  String get wheelTask_w_mu6 =>
      'Toque um ritmo na mesa com o dedo por 15 segundos';

  @override
  String get wheelTask_w_g1 =>
      'Pense em uma coisa que você tem hoje e diga “obrigado”';

  @override
  String get wheelTask_w_g2 => 'Conte 3 pequenas coisas que te fazem feliz';

  @override
  String get wheelTask_w_g3 =>
      'Pense na melhor coisa que você comeu hoje e lembre-se do sabor';

  @override
  String get wheelTask_w_g4 =>
      'Pense no melhor momento da sua vida por 10 segundos';

  @override
  String get wheelTask_w_g5 => 'Sinta-se grato pela sua saúde. Respire fundo.';

  @override
  String get wheelTask_w_g6 => 'Sinta-se grato porque o sol nasceu hoje';

  @override
  String get wheelTask_w_f1 => 'Pule 3 vezes e grite \"Eu consigo!\"';

  @override
  String get wheelTask_w_f2 =>
      'Faça sua cara mais engraçada e segure por 5 segundos';

  @override
  String get wheelTask_w_f3 => 'Imite um animal – que animal você seria?';

  @override
  String get wheelTask_w_f4 =>
      'Feche os olhos e imagine que você está voando por 10 segundos';

  @override
  String get wheelTask_w_f5 =>
      'Faça uma pose de super-herói e segure-a por 5 segundos';

  @override
  String get wheelTask_w_f6 => 'Ande como um robô por 10 passos';

  @override
  String get zodiacAccessWesternAdTitle => 'Limite gratuito diário alcançado';

  @override
  String get zodiacAccessWesternAdDesc =>
      'Você pode assistir a um pequeno anúncio para entrar novamente na Astrologia Ocidental.';

  @override
  String get zodiacAccessWatchAdBtn => 'Assistir ao anúncio';

  @override
  String get zodiacAccessGetEliteBtn => 'Obtenha Elite';

  @override
  String get zodiacAccessGateTitle => 'Portão da Sabedoria Cósmica';

  @override
  String zodiacAccessStoneCount(Object count) {
    return 'Você tem${count}Pedras da Alma';
  }

  @override
  String get zodiacAccessPremiumInfo1 =>
      'Permissão de acesso às profundezas do zodíaco';

  @override
  String get zodiacAccessPremiumInfo2 =>
      'Cada mapa astrológico consome 1 Pedra da Alma';

  @override
  String get zodiacAccessPremiumInfo3Elite =>
      'Elite: Acesso ilimitado com 1 Soul Stone por dia';

  @override
  String get zodiacAccessPremiumInfo3Normal =>
      '1 Soul Stone é suficiente com Elite por dia';

  @override
  String get zodiacAccessOneStoneBtn => '1 Pedra da Alma';

  @override
  String get onboardingTestSimulate =>
      'Modo de teste: Simulando login de conta antiga...';

  @override
  String get onboardingTestAnon => 'Modo de teste: Conectando anonimamente...';

  @override
  String onboardingGoogleLoginFailed(Object error) {
    return 'Falha no login do Google:$error';
  }

  @override
  String onboardingAppleLoginFailed(Object error) {
    return 'Falha no login da Apple:$error';
  }

  @override
  String onboardingGoogleRegisterFailed(Object error) {
    return 'Falha no registro do Google:$error';
  }

  @override
  String onboardingAppleRegisterFailed(Object error) {
    return 'Falha no registro da Apple:$error';
  }

  @override
  String dreamDataError(Object error) {
    return 'Erro de dados salvos:$error';
  }

  @override
  String get onboardingBirthDateTitle => 'SUA DATA DE NASCIMENTO';

  @override
  String get onboardingSelectBirthDate => 'Selecione sua data de nascimento';

  @override
  String get onboardingBirthTimeTitle => 'HORA DE NASCIMENTO (Opcional)';

  @override
  String get onboardingBirthPlaceTitle => 'LOCAL DE NASCIMENTO (Opcional)';

  @override
  String get onboardingPickerDateTitle => 'Selecione a data de nascimento';

  @override
  String get onboardingPickerTimeTitle => 'Selecione a hora do nascimento';

  @override
  String get onboardingPickerDone => 'Feito';

  @override
  String get onboardingLifeFocusSpiritual => 'Espiritual\nDespertar';

  @override
  String get onboardingLifeFocusCareer => 'Carreira e\nPoder Pessoal';

  @override
  String get onboardingLifeFocusLove => 'Amor e\nHarmonia Cósmica';

  @override
  String get onboardingLifeFocusHealing => 'Cura e\nPaz Interior';

  @override
  String get onboardingLifeFocusWealth => 'Riqueza e\nAbundância';

  @override
  String get onboardingLifeFocusSurprise => 'Universo\nSurpresas';

  @override
  String get onboardingDreamMessenger => 'Mensageiro e sonhos vívidos';

  @override
  String get onboardingDreamChaotic => 'Eventos surpreendentes e caóticos';

  @override
  String get onboardingDreamCalm => 'Tão calmo quanto as nuvens';

  @override
  String get onboardingSleepMindTitle => 'Luz da Mente';

  @override
  String get onboardingSleepMindDesc =>
      'Analiso eventos, peso-os com lógica e planejo passos concretos.';

  @override
  String get onboardingSleepMindVal => 'Luz da Mente (Lógica)';

  @override
  String get onboardingSleepHeartTitle => 'Sussurro do Coração';

  @override
  String get onboardingSleepHeartDesc =>
      'Eu ouço minha voz interior e sempre confio em meus sentimentos mais que na lógica.';

  @override
  String get onboardingSleepHeartVal => 'Sussurro do Coração (Intuição)';

  @override
  String get onboardingSleepUniverseTitle => 'Fluxo do Universo';

  @override
  String get onboardingSleepUniverseDesc =>
      'Acredito que tudo acontece por um motivo e sigo os sinais do universo.';

  @override
  String get onboardingSleepUniverseVal => 'Fluxo do Universo (Destino)';

  @override
  String get linkAccountTitle => 'Vincular conta';

  @override
  String get linkGoogleAccount => 'Vincular conta do Google';

  @override
  String get linkAppleAccount => 'Vincular conta da Apple';

  @override
  String get linkAccountStarted =>
      'Processo de vinculação de conta iniciado...';

  @override
  String get linkAccountFailed => 'Falha ao vincular a conta';

  @override
  String get profileSignOutGuestDesc =>
      'Aviso: Se você sair de uma conta de convidado, não poderá acessar esta conta novamente e todos os seus dados (Pedras da Alma, leituras) serão PERDIDOS PERMANENTEMENTE. Tem certeza de que deseja sair?';
}
