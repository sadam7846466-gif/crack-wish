// lib/screens/tarot_meanings.dart
// 22 Büyük Arkana kartının anlamları ve yorum motoru

/// Kart tonu
enum CardTone { heavy, soft, decision }

/// Hareket tipi
enum CardMovement { motion, stillness }

/// Yaşam fazı
enum CardPhase { beginning, ending, completion, awakening, neutral }

/// Akış tipi (3 kart arası)
enum FlowType { harmonious, conflicting, transformative }

class CardMeaning {
  final int id;

  // Tema
  final String themeTr;
  final String themeEn;

  // Ton / hareket / faz
  final CardTone tone;
  final CardMovement movement;
  final CardPhase phase;

  // Pozisyona göre anlamlar (Geçmiş / Şimdi / Yön)
  final String pastTr;
  final String pastEn;
  final String presentTr;
  final String presentEn;
  final String directionTr;
  final String directionEn;

  const CardMeaning({
    required this.id,
    required this.themeTr,
    required this.themeEn,
    required this.tone,
    required this.movement,
    required this.phase,
    required this.pastTr,
    required this.pastEn,
    required this.presentTr,
    required this.presentEn,
    required this.directionTr,
    required this.directionEn,
  });
}

// ============================================================
// 22 Büyük Arkana Kart Anlamları
// ============================================================
const Map<int, CardMeaning> cardMeanings = {
  0: CardMeaning(
    id: 0,
    themeTr: 'Yeni başlangıç, masumiyet, cesaret',
    themeEn: 'New beginning, innocence, courage',
    tone: CardTone.soft,
    movement: CardMovement.motion,
    phase: CardPhase.beginning,
    pastTr: 'Cesur bir adım attın, tanıdık düzeni geride bırakarak yolculuğa çıktın.',
    pastEn: 'You took a bold leap, leaving the familiar behind to begin a new journey.',
    presentTr: 'Şu an taze bir enerjiyle doluyorsun; bilinmeyene güvenme zamanı.',
    presentEn: 'You are filled with fresh energy right now; it is time to trust the unknown.',
    directionTr: 'Korkularını bırak ve kalbinin gösterdiği yöne doğru ilk adımı at.',
    directionEn: 'Release your fears and take the first step toward where your heart points.',
  ),
  1: CardMeaning(
    id: 1,
    themeTr: 'İrade, yaratıcılık, ustalık',
    themeEn: 'Willpower, creativity, mastery',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Elindeki kaynakları bilinçli şekilde kullandın ve bir şeyleri harekete geçirdin.',
    pastEn: 'You consciously used the resources at hand and set things in motion.',
    presentTr: 'Tüm araçlar önünde; odaklan ve niyetini netleştir.',
    presentEn: 'All the tools are before you; focus and clarify your intention.',
    directionTr: 'Düşünmekten çıkıp eyleme geç. Yaratıcı gücün seni taşıyacak.',
    directionEn: 'Move from thinking to doing. Your creative power will carry you.',
  ),
  2: CardMeaning(
    id: 2,
    themeTr: 'Sezgi, gizem, içsel bilgelik',
    themeEn: 'Intuition, mystery, inner wisdom',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'İçgüdülerine güvendiğin bir dönemden geçtin; sessizce doğru yolu hissettin.',
    pastEn: 'You went through a phase of trusting your instincts; you quietly sensed the right path.',
    presentTr: 'Cevaplar dışarıda değil, içinde. Sessizliğe kulak ver.',
    presentEn: 'The answers are not outside, they are within. Listen to the silence.',
    directionTr: 'Sabırlı ol ve sezgilerine güven. Henüz görünmeyenler kendini yakında gösterecek.',
    directionEn: 'Be patient and trust your intuition. What is unseen will soon reveal itself.',
  ),
  3: CardMeaning(
    id: 3,
    themeTr: 'Bereket, doğurganlık, şefkat',
    themeEn: 'Abundance, fertility, nurturing',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Beslediğin ve emek verdiğin bir dönem seni buraya getirdi.',
    pastEn: 'A period of nurturing and care brought you to this point.',
    presentTr: 'Hayatında büyüme ve bolluk enerjisi var. Şefkatle yaklaş.',
    presentEn: 'There is an energy of growth and abundance in your life. Approach with compassion.',
    directionTr: 'Kendine ve çevrene sevgiyle bak. Ektiğin tohumlar yakında meyve verecek.',
    directionEn: 'Look at yourself and your surroundings with love. Seeds you planted will soon bear fruit.',
  ),
  4: CardMeaning(
    id: 4,
    themeTr: 'Otorite, yapı, düzen',
    themeEn: 'Authority, structure, order',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Disiplinli ve kararlı bir tutumla sağlam temeller attın.',
    pastEn: 'You laid solid foundations with a disciplined and determined attitude.',
    presentTr: 'Hayatına düzen ve yapı getirme zamanı geldi. Sınırlarını belirle.',
    presentEn: 'It is time to bring order and structure to your life. Set your boundaries.',
    directionTr: 'Stratejik düşün, plan yap ve adım adım ilerle. Kontrol sende.',
    directionEn: 'Think strategically, make a plan, and advance step by step. You are in control.',
  ),
  5: CardMeaning(
    id: 5,
    themeTr: 'Gelenek, rehberlik, inanç sistemi',
    themeEn: 'Tradition, guidance, belief system',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Bir öğretiden, gelenekten ya da mentordan aldığın dersler seni şekillendirdi.',
    pastEn: 'Lessons from a teaching, tradition, or mentor shaped who you are.',
    presentTr: 'Değerlerini sorguluyorsun: hangisi sana ait, hangisi alışkanlık?',
    presentEn: 'You are questioning your values: which ones are truly yours, and which are just habits?',
    directionTr: 'Kendi iç rehberliğini bul. Kuralların ötesinde kendi hakikatini keşfet.',
    directionEn: 'Find your own inner guidance. Discover your truth beyond the rules.',
  ),
  6: CardMeaning(
    id: 6,
    themeTr: 'Seçim, ilişki, uyum',
    themeEn: 'Choice, relationship, harmony',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Önemli bir seçim yaptın; kalbinle aklın arasında bir denge buldun.',
    pastEn: 'You made an important choice; you found a balance between heart and mind.',
    presentTr: 'Bir karar anındasın. Kalbinin sesini dinle ama sonuçlarını da gör.',
    presentEn: 'You are at a crossroads. Listen to your heart but also see the consequences.',
    directionTr: 'Değerlerinle uyumlu seçimi yap. Doğru ilişki veya yol kendini gösterecek.',
    directionEn: 'Make the choice aligned with your values. The right relationship or path will reveal itself.',
  ),
  7: CardMeaning(
    id: 7,
    themeTr: 'İrade, zafer, ilerleme',
    themeEn: 'Willpower, victory, forward movement',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Kararlılığınla engelleri aştın; iradeni güçlü kullandın.',
    pastEn: 'With your determination, you overcame obstacles; you used your willpower strongly.',
    presentTr: 'Odaklan ve yol al. Engeller var ama iradenle aşabilirsin.',
    presentEn: 'Focus and move forward. There are obstacles, but you can overcome them with willpower.',
    directionTr: 'Şimdi durmak yok. Disiplinle ileri git, zafer yakın.',
    directionEn: 'No stopping now. Move forward with discipline; victory is near.',
  ),
  8: CardMeaning(
    id: 8,
    themeTr: 'İç güç, sabır, cesaret',
    themeEn: 'Inner strength, patience, courage',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Yumuşak ama kararlı bir güçle zorlu bir dönemi atlattın.',
    pastEn: 'With gentle but firm strength, you weathered a challenging period.',
    presentTr: 'Savaşmak değil, sakin kalmak gücün. Sabır en büyük silahın.',
    presentEn: 'Your power is not in fighting, but in staying calm. Patience is your greatest weapon.',
    directionTr: 'Kendine güven ve yumuşaklıkla ilerle. Gerçek güç korkuyu kabul etmektir.',
    directionEn: 'Trust yourself and move forward with gentleness. True strength is accepting fear.',
  ),
  9: CardMeaning(
    id: 9,
    themeTr: 'İçe dönüş, arayış, yalnızlık',
    themeEn: 'Introspection, seeking, solitude',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Bir dönem yalnız kaldın ve kendi içinde cevapları aradın.',
    pastEn: 'You spent a period alone, searching within yourself for answers.',
    presentTr: 'Gürültüden uzaklaş. İçsel rehberliğini bulman gereken bir an.',
    presentEn: 'Step away from the noise. This is a moment to find your inner guidance.',
    directionTr: 'Biraz geri çekil, düşün ve netleş. Cevap sessizlikte gizli.',
    directionEn: 'Pull back a little, reflect, and gain clarity. The answer is hidden in silence.',
  ),
  10: CardMeaning(
    id: 10,
    themeTr: 'Kader, döngü, dönüm noktası',
    themeEn: 'Fate, cycle, turning point',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Hayatında büyük bir dönüş yaşandı; kontrol edemediğin güçler devreye girdi.',
    pastEn: 'A major turning point occurred; forces beyond your control came into play.',
    presentTr: 'Değişim kapıda. Direnmek yerine akışa güven.',
    presentEn: 'Change is at the door. Trust the flow instead of resisting.',
    directionTr: 'Döngüyü kabul et. Her iniş bir çıkışın habercisi.',
    directionEn: 'Accept the cycle. Every descent heralds a rise.',
  ),
  11: CardMeaning(
    id: 11,
    themeTr: 'Adalet, denge, doğruluk',
    themeEn: 'Justice, balance, truth',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Geçmişte verdiğin kararların sonuçlarıyla yüzleşiyorsun.',
    pastEn: 'You are facing the consequences of decisions made in the past.',
    presentTr: 'Dürüstlük ve denge zamanı. Doğru olanı yap, sonuç gelecek.',
    presentEn: 'It is a time for honesty and balance. Do what is right, and the result will come.',
    directionTr: 'Adaletli ol. Kararlarını mantık ve vicdanla ver.',
    directionEn: 'Be fair. Make your decisions with logic and conscience.',
  ),
  12: CardMeaning(
    id: 12,
    themeTr: 'Fedakârlık, bekleyiş, farklı bakış açısı',
    themeEn: 'Sacrifice, waiting, new perspective',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Bir şeyden vazgeçtin veya beklemeyi seçtin; bu seni olgunlaştırdı.',
    pastEn: 'You gave something up or chose to wait; this matured you.',
    presentTr: 'Durağan görünse de bu an büyük bir iç dönüşüm yaşıyorsun.',
    presentEn: 'Though it seems stagnant, you are going through a profound inner transformation.',
    directionTr: 'Kontrolü bırak ve farklı açıdan bak. Teslim olmak bazen en güçlü hamle.',
    directionEn: 'Let go of control and look from a different angle. Surrendering is sometimes the strongest move.',
  ),
  13: CardMeaning(
    id: 13,
    themeTr: 'Dönüşüm, kapanış, yenilenme',
    themeEn: 'Transformation, ending, renewal',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.ending,
    pastTr: 'Bir dönem kesin olarak kapandı. Eski sen artık geride kaldı.',
    pastEn: 'A chapter has definitively closed. The old you is now left behind.',
    presentTr: 'Büyük bir dönüşümün ortasındasın. Biten şeylere tutunma.',
    presentEn: 'You are in the midst of a great transformation. Do not cling to what has ended.',
    directionTr: 'Eski düzeni bırak, yeniye yer aç. Her bitiş yeni bir doğuşun kapısı.',
    directionEn: 'Release the old order and make room for the new. Every ending is the door to a new birth.',
  ),
  14: CardMeaning(
    id: 14,
    themeTr: 'Denge, ılımlılık, sabır',
    themeEn: 'Balance, moderation, patience',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Dengeyi bulmak için çaba gösterdin; aşırılıklardan kaçındın.',
    pastEn: 'You worked to find balance, avoiding extremes.',
    presentTr: 'Orta yolu bul. Sabır ve ılımlılık şu anki anahtarın.',
    presentEn: 'Find the middle path. Patience and moderation are your current keys.',
    directionTr: 'Aşırıya kaçma. Küçük ve dengeli adımlar seni hedefe taşır.',
    directionEn: 'Do not go to extremes. Small, balanced steps will carry you to your goal.',
  ),
  15: CardMeaning(
    id: 15,
    themeTr: 'Bağımlılık, gölge, yüzleşme',
    themeEn: 'Attachment, shadow, confrontation',
    tone: CardTone.heavy,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Seni tutan bağlar, korkular veya alışkanlıklar vardı.',
    pastEn: 'There were bonds, fears, or habits that held you back.',
    presentTr: 'Gölgenle yüzleş. Seni bağlayan ne ise onu gör.',
    presentEn: 'Face your shadow. See what binds you.',
    directionTr: 'Zincirleri kır. Farkındalık ilk adım; bırakmak ikincisi.',
    directionEn: 'Break the chains. Awareness is the first step; letting go is the second.',
  ),
  16: CardMeaning(
    id: 16,
    themeTr: 'Yıkım, kriz, ani değişim',
    themeEn: 'Destruction, crisis, sudden change',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.ending,
    pastTr: 'Ani bir sarsıntı yaşandı; alışık olduğun yapı çöktü.',
    pastEn: 'A sudden upheaval occurred; the structure you were used to collapsed.',
    presentTr: 'Kaos gibi hissedebilir ama bu yıkım, yeniden inşa için gerekli.',
    presentEn: 'It may feel like chaos, but this destruction is necessary for rebuilding.',
    directionTr: 'Direnmek yerine bırak. Yıkıntılardan en güçlü yapı yükselir.',
    directionEn: 'Instead of resisting, let go. The strongest structures rise from the ruins.',
  ),
  17: CardMeaning(
    id: 17,
    themeTr: 'Umut, ilham, iyileşme',
    themeEn: 'Hope, inspiration, healing',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Zor bir dönemin ardından umut ışığı belirdi.',
    pastEn: 'After a difficult period, a light of hope appeared.',
    presentTr: 'Yenilenme enerjisi var. İyileşme süreci başladı.',
    presentEn: 'There is a renewal energy. The healing process has begun.',
    directionTr: 'Umudunu koru. Evren seni doğru yere yönlendiriyor.',
    directionEn: 'Hold on to your hope. The universe is guiding you to the right place.',
  ),
  18: CardMeaning(
    id: 18,
    themeTr: 'Yanılsama, korku, bilinçaltı',
    themeEn: 'Illusion, fear, subconscious',
    tone: CardTone.heavy,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Belirsizlik ve korkularla dolu bir dönemden geçtin.',
    pastEn: 'You went through a period full of uncertainty and fears.',
    presentTr: 'Her şey göründüğü gibi değil. Yanılsamaları gerçekten ayır.',
    presentEn: 'Not everything is as it seems. Separate illusions from reality.',
    directionTr: 'Korkularınla yüzleş. Karanlıktan geçmeden ışığa ulaşamazsın.',
    directionEn: 'Face your fears. You cannot reach the light without passing through the dark.',
  ),
  19: CardMeaning(
    id: 19,
    themeTr: 'Başarı, canlılık, aydınlanma',
    themeEn: 'Success, vitality, enlightenment',
    tone: CardTone.soft,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Parlak, enerjik ve başarılı bir dönem yaşadın.',
    pastEn: 'You experienced a bright, energetic, and successful period.',
    presentTr: 'Işık üzerinde. Enerji ve neşe seni sarıyor.',
    presentEn: 'The light is upon you. Energy and joy surround you.',
    directionTr: 'Parlamaya devam et. Özgüvenle ilerle; başarı senin hakkın.',
    directionEn: 'Keep shining. Move forward with confidence; success is your right.',
  ),
  20: CardMeaning(
    id: 20,
    themeTr: 'Uyanış, yargı, çağrı',
    themeEn: 'Awakening, judgement, calling',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.awakening,
    pastTr: 'Büyük bir uyanış yaşadın; geçmişi değerlendirip ders çıkardın.',
    pastEn: 'You experienced a great awakening; you evaluated the past and learned lessons.',
    presentTr: 'İçsel bir çağrı duyuyorsun. Kendini yargılama, affet ve yüksel.',
    presentEn: 'You hear an inner calling. Do not judge yourself; forgive and rise.',
    directionTr: 'Geçmişi affet ve kararını ver. Uyanışın seni yeni bir seviyeye taşıyacak.',
    directionEn: 'Forgive the past and make your decision. Your awakening will carry you to a new level.',
  ),
  21: CardMeaning(
    id: 21,
    themeTr: 'Tamamlanma, bütünlük, zafer',
    themeEn: 'Completion, wholeness, triumph',
    tone: CardTone.soft,
    movement: CardMovement.motion,
    phase: CardPhase.completion,
    pastTr: 'Uzun bir yolculuğu tamamladın; olgunlaşma ve bütünleşme yaşandı.',
    pastEn: 'You completed a long journey; growth and integration took place.',
    presentTr: 'Her şey yerli yerine oturuyor. Döngü tamamlanmak üzere.',
    presentEn: 'Everything is falling into place. The cycle is about to be completed.',
    directionTr: 'Başardığını kutla. Yeni bir döngü başlamak üzere; hazır ol.',
    directionEn: 'Celebrate your achievement. A new cycle is about to begin; be ready.',
  ),
};

// ============================================================
// Yorum Motoru
// ============================================================

class TarotReading {
  final String generalTheme;
  final String pastInfluence;
  final String presentEnergy;
  final String directionAdvice;
  final String closingMessage;
  final FlowType flowType;
  final String flowLabel;

  const TarotReading({
    required this.generalTheme,
    required this.pastInfluence,
    required this.presentEnergy,
    required this.directionAdvice,
    required this.closingMessage,
    required this.flowType,
    required this.flowLabel,
  });
}

TarotReading generateReading({
  required int card1Id,
  required int card2Id,
  required int card3Id,
  required String card1Name,
  required String card2Name,
  required String card3Name,
  required bool isTr,
}) {
  final m1 = cardMeanings[card1Id]!;
  final m2 = cardMeanings[card2Id]!;
  final m3 = cardMeanings[card3Id]!;

  // --- Akış tipi belirleme ---
  final flowType = _detectFlowType(m1, m2, m3);
  final flowLabel = _flowLabel(flowType, isTr);

  // --- Genel tema (hikaye cümlesi) ---
  final generalTheme = _buildGeneralTheme(
    m1, m2, m3, card1Name, card2Name, card3Name, flowType, isTr,
  );

  // --- Pozisyon yorumları ---
  final pastInfluence = isTr ? m1.pastTr : m1.pastEn;
  final presentEnergy = isTr ? m2.presentTr : m2.presentEn;
  final directionAdvice = isTr ? m3.directionTr : m3.directionEn;

  // --- Kapanış mesajı ---
  final closingMessage = _buildClosing(m1, m2, m3, flowType, isTr);

  return TarotReading(
    generalTheme: generalTheme,
    pastInfluence: pastInfluence,
    presentEnergy: presentEnergy,
    directionAdvice: directionAdvice,
    closingMessage: closingMessage,
    flowType: flowType,
    flowLabel: flowLabel,
  );
}

// --- Akış tespiti ---
FlowType _detectFlowType(CardMeaning m1, CardMeaning m2, CardMeaning m3) {
  final tones = [m1.tone, m2.tone, m3.tone];
  final heavyCount = tones.where((t) => t == CardTone.heavy).length;
  final softCount = tones.where((t) => t == CardTone.soft).length;

  // Dönüşüm akışı: ending + soft veya awakening/completion varsa
  final phases = [m1.phase, m2.phase, m3.phase];
  final hasEnding = phases.contains(CardPhase.ending);
  final hasCompletion = phases.contains(CardPhase.completion);
  final hasAwakening = phases.contains(CardPhase.awakening);
  final hasBeginning = phases.contains(CardPhase.beginning);

  if (hasEnding && (hasCompletion || hasAwakening || softCount >= 1)) {
    return FlowType.transformative;
  }

  // Çatışma: 2+ ağır kart
  if (heavyCount >= 2) {
    return FlowType.conflicting;
  }

  // Uyumlu: 2+ yumuşak kart
  if (softCount >= 2) {
    return FlowType.harmonious;
  }

  // Dönüşüm: bitiş → başlangıç
  if (hasEnding && hasBeginning) {
    return FlowType.transformative;
  }

  // Varsayılan
  if (heavyCount >= 1 && softCount >= 1) {
    return FlowType.transformative;
  }

  return FlowType.harmonious;
}

String _flowLabel(FlowType flow, bool isTr) {
  switch (flow) {
    case FlowType.harmonious:
      return isTr ? '✨ Uyumlu Akış' : '✨ Harmonious Flow';
    case FlowType.conflicting:
      return isTr ? '⚡ Yüzleşme Akışı' : '⚡ Confrontation Flow';
    case FlowType.transformative:
      return isTr ? '🔄 Dönüşüm Akışı' : '🔄 Transformation Flow';
  }
}

// --- Genel tema cümlesi ---
String _buildGeneralTheme(
  CardMeaning m1, CardMeaning m2, CardMeaning m3,
  String n1, String n2, String n3,
  FlowType flow, bool isTr,
) {
  final theme2 = isTr ? m2.themeTr : m2.themeEn;

  switch (flow) {
    case FlowType.harmonious:
      return isTr
          ? '$n1, $n2 ve $n3 birlikte parlıyor. İçindeki ışığı korkusuzca yansıt.'
          : '$n1, $n2 and $n3 shine together. Reflect your inner light fearlessly.';
    case FlowType.conflicting:
      return isTr
          ? '$n1 sarsıyor, $n2 sınıyor ama $n3 çıkış yolunu gösteriyor.'
          : '$n1 shakes, $n2 tests, but $n3 reveals the way forward.';
    case FlowType.transformative:
      return isTr
          ? '$n1 bir kapıyı kapatıyor, $n2 seni dönüştürüyor, $n3 yeni bir başlangıç sunuyor.'
          : '$n1 closes a door, $n2 transforms you, $n3 offers a fresh start.';
  }
}

// --- Kapanış mesajı ---
String _buildClosing(
  CardMeaning m1, CardMeaning m2, CardMeaning m3,
  FlowType flow, bool isTr,
) {
  switch (flow) {
    case FlowType.harmonious:
      return isTr
          ? '🌟 Evrenin kusursuz matematiği şu an seninle hizalanıyor. Kalbindeki o ince sese güven; çünkü adımların şu an gökyüzü tarafından destekleniyor.'
          : '🌟 The perfect geometry of the universe is aligning with you right now. Trust the subtle voice in your heart, for your steps are supported by the cosmos.';
    case FlowType.conflicting:
      return isTr
          ? '🔥 Fırtınaların ortasında savrulduğunu hissedebilirsin, fakat unutma; en güçlü çelik en harlı ateşte dövülür. Kendi gücüne uyanıyorsun.'
          : '🔥 You may feel tossed in the midst of storms, but remember; the strongest steel is forged in the fiercest fire. You are awakening to your own power.';
    case FlowType.transformative:
      return isTr
          ? '🦋 Kozanı yırtıp çıkmak acı verebilir; lakin birazdan kanatlarının aslında ne kadar görkemli olduğunu tüm dünya görecek.'
          : '🦋 Tearing through the cocoon may hurt; but soon, the whole world will witness just how magnificent your wings truly are.';
  }
}
