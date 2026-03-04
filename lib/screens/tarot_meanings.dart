// lib/screens/tarot_meanings.dart
// 22 Büyük Arkana kartının anlamları ve yorum motoru

import 'dart:math';

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
    pastTr: 'Karttaki beyaz köpek gibi içgüdülerin seni korudu; uçurumun kenarında olsan bile heybendeki saf niyetle o cesur adımı attın.',
    pastEn: 'Like the white dog on the card, your instincts protected you; despite the cliff edge, you took that bold leap with pure intentions.',
    presentTr: 'Deli gibi uçuruma doğru yürüyen o figür sensin. Sırtındaki küçük heybeden başka bir şeye ihtiyacın yok; bilinmeyene güvenme zamanı.',
    presentEn: 'You are the figure walking toward the cliff. You need nothing but the small pouch on your back; it is time to trust the unknown.',
    directionTr: 'Ayaklarının altındaki uçuruma aldırma. Köpeğinin havlaması tehlikeyi değil, uyanışı simgeliyor. İlk adımı atmaktan korkma.',
    directionEn: 'Ignore the cliff beneath your feet. The dog barking symbolizes awakening, not danger. Do not fear taking the first step.',
  ),
  1: CardMeaning(
    id: 1,
    themeTr: 'İrade, yaratıcılık, ustalık',
    themeEn: 'Willpower, creativity, mastery',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Masadaki asa, kupa, kılıç ve tılsımı kullandın. Başının üzerindeki sonsuzluk işareti gibi, iradeni potansiyele çevirdin.',
    pastEn: 'You used the wand, cup, sword, and pentacle on the table. Like the infinity sign above you, you turned will into potential.',
    presentTr: 'Büyücünün masasındaki tüm elementler önünde duruyor. Bir elin göğü (fikri), diğeri yeri (eylemi) işaret ediyor. Yeteneklerini birleştir.',
    presentEn: 'All elements on the Magicians table lay before you. With one hand to the sky and one to the earth, merge your skills.',
    directionTr: 'Masadaki araçları izlemek yerine eline al. Büyücünün sonsuz odaklanmasıyla düşündüklerini gerçeğe dönüştür.',
    directionEn: 'Pick up the tools instead of just looking at them. Transform your thoughts into reality with the Magicians infinite focus.',
  ),
  2: CardMeaning(
    id: 2,
    themeTr: 'Sezgi, gizem, içsel bilgelik',
    themeEn: 'Intuition, mystery, inner wisdom',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Karanlık (B) ve aydınlık (J) sütunlar arasında oturdun. Dizindeki parşömen gibi sırlar açığa çıkaran bir evre yaşadın.',
    pastEn: 'You sat between the dark (B) and light (J) pillars. Like the scroll on his lap, it was a phase where secrets were revealed.',
    presentTr: 'Arkadaki narlarla süslü perde, henüz bilmediğin gizemleri saklıyor. Ayaklarının altındaki hilal gibi sezgilerine kulak ver.',
    presentEn: 'The pomegranate-adorned veil behind conceals mysteries you do not yet know. Listen to your intuition like the crescent at her feet.',
    directionTr: 'O iki siyah ve beyaz sütunun ortasından geç. Perdenin ardına bakmak için mantığı bırakıp kalbinin bilgeliğine güvenmelisin.',
    directionEn: 'Pass between the black and white pillars. To look behind the veil, leave logic and trust your hearts wisdom.',
  ),
  3: CardMeaning(
    id: 3,
    themeTr: 'Bereket, doğurganlık, şefkat',
    themeEn: 'Abundance, fertility, nurturing',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Başındaki on iki yıldızlı taç gibi, hayata büyük bir değer kattın. Çevrendeki buğday tarlaları ektiğin şefkatin sonucudur.',
    pastEn: 'Like the twelve-starred crown, you added immense value to life. The wheat fields around you are the result of the compassion you sowed.',
    presentTr: 'İmparatoriçe gibi rahat bir tahtta, ormanın ve suyun bereketi içindesin. Kendine ve etrafına sevgi ve bolluk enerjisi veriyorsun.',
    presentEn: 'Like the Empress on a comfortable throne, you are amidst the abundance of forest and water. You radiate love and abundance.',
    directionTr: 'Önündeki sararan buğdayları hasat etme zamanı. Yaratıcılığının doğurgan akışına izin ver, sevgiyle büyüt.',
    directionEn: 'It is time to harvest the golden wheat before you. Allow the fertile flow of your creativity to nurture with love.',
  ),
  4: CardMeaning(
    id: 4,
    themeTr: 'Otorite, yapı, düzen',
    themeEn: 'Authority, structure, order',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Koç başlı taş tahtın üzerindeki İmparator gibi, sınırları sen çizdin ve gri dağlar gibi sarsılmaz bir temel attın.',
    pastEn: 'Like the Emperor on the ram-headed stone throne, you drew the boundaries and built an unshakable foundation like the gray mountains.',
    presentTr: 'Üzerindeki kırmızı zırh savaşmaya hazır olduğunu, elindeki küre ise kontrolün sende olduğunu gösteriyor. Düzeni sağla.',
    presentEn: 'Your red armor shows you are ready to fight, the orb in your hand shows you have control. Establish order.',
    directionTr: 'Arkadaki çıplak kayaçlar gibi mantıklı ve katı olmalısın. Kuralları sen koy ve krallığını disiplinle yönet.',
    directionEn: 'Be logical and solid like the barren rocks behind. Set the rules and rule your kingdom with discipline.',
  ),
  5: CardMeaning(
    id: 5,
    themeTr: 'Gelenek, rehberlik, inanç sistemi',
    themeEn: 'Tradition, guidance, belief system',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Önündeki iki rahip gibi, bir bilgenin ya da sistemin rehberliğini dinledin. Çapraz duran iki anahtar sana eski kapıları açtı.',
    pastEn: 'Like the two priests before him, you listened to the guidance of a wise one or system. The crossed keys opened ancient doors.',
    presentTr: 'Aziz tahtında oturuyor ve bir eliyle hayır duası veriyor. Mevcut inançların, kuralların veya eğitimin seni şekillendiriyor.',
    presentEn: 'The Hierophant sits on his throne offering a blessing. Your current beliefs, rules, or education are shaping you.',
    directionTr: 'Ayaklarının önündeki anahtarları al. Öğrendiğin geleneklerden ders çıkar ama kendi içindeki o yüce inancı da bul.',
    directionEn: 'Take the keys at his feet. Learn from traditions but also find that supreme belief within yourself.',
  ),
  6: CardMeaning(
    id: 6,
    themeTr: 'Seçim, ilişki, uyum',
    themeEn: 'Choice, relationship, harmony',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Tıpkı Adem ile Havva ve arkalarındaki Bilgi Ağacı ile yılan gibi, masumiyetten çıkıp önemli bir seçim yapmak zorunda kaldın.',
    pastEn: 'Like Adam and Eve and the Tree of Knowledge with the snake, you stepped out of innocence and had to make an important choice.',
    presentTr: 'Yukarıdaki dev melek Rafael in kanatları altında, kalbin ve aklın omuz omuza. Bir yanda tutku, diğer yanda doğru değerler var.',
    presentEn: 'Under the wings of the giant angel Raphael, your heart and mind stand side by side. On one side is passion, the other, true values.',
    directionTr: 'Meleğin kutsadığı şekilde, sadece kendi ruhunla uyumlu olana yönel. Gözlerini kaçırma ve o gerçek seçimi yap.',
    directionEn: 'As the angel blesses, turn only to what aligns with your soul. Do not look away; make that true choice.',
  ),
  7: CardMeaning(
    id: 7,
    themeTr: 'İrade, zafer, ilerleme',
    themeEn: 'Willpower, victory, forward movement',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Arabayı çeken siyah ve beyaz iki sfenksi dizginledin. Zıt güçleri tek bir hedefe sürerek o zorlu yolu geçtin.',
    pastEn: 'You harnessed the black and white sphinxes pulling the chariot. You drove opposing forces to a single goal and passed that rocky road.',
    presentTr: 'Zırhın ve yıldızlı gölgeliğin altındasın. Önündeki sfenksler farklı yönlere gitmek istese de iradenle onları kontrol ediyorsun.',
    presentEn: 'You are under the armor and starry canopy. The sphinxes want to go different ways, but your will controls them.',
    directionTr: 'Asanın gücüyle zıtlıkları dengele. Arkandaki şehri bırak, gözünü hedefe dik ve dizginleri sıkı tutarak ilerle.',
    directionEn: 'Balance contradictions with the power of your wand. Leave the city behind, set your eyes on the goal, and ride forward.',
  ),
  8: CardMeaning(
    id: 8,
    themeTr: 'İç güç, sabır, cesaret',
    themeEn: 'Inner strength, patience, courage',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Vahşi bir aslanın çenesini şefkatle okşayan o kadın gibi, en zorlu duygularını veya krizlerini yumuşak bir sabırla yatıştırdın.',
    pastEn: 'Like the woman gently caressing the fierce lions jaw, you soothed your toughest emotions or crises with soft patience.',
    presentTr: 'Başının üstünde sonsuzluk işareti parlıyor. Kaba kuvvete ihtiyacın yok; içindeki o vahşi aslan, senin şefkatine boyun eğmiş durumda.',
    presentEn: 'The infinity sign shines above your head. You need no brute force; the wild lion within has bowed to your compassion.',
    directionTr: 'Düşmanlarını veya korkularını zorlayarak değil, aslanı evcilleştiren o narin ellerinle sevgi ve cesaretle aşacaksın.',
    directionEn: 'You will overcome enemies or fears not by forcing them, but with the gentle hands and love that tamed the lion.',
  ),
  9: CardMeaning(
    id: 9,
    themeTr: 'İçe dönüş, arayış, yalnızlık',
    themeEn: 'Introspection, seeking, solitude',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Karlı ve soğuk dağların zirvesinde tek başına yürüdün. Kalabalıkları geride bırakıp kendi fenerinin ışığına sığındın.',
    pastEn: 'You walked alone on the snowy, cold mountain peaks. Leaving crowds behind, you sought refuge in the light of your own lantern.',
    presentTr: 'Gri bir cüppe içinde sarsılmaz bir asaya dayanıyorsun. Elindeki yıldızlı fener, başkalarına değil, sadece senin önünü aydınlatıyor.',
    presentEn: 'In a gray cloak leaning on an unshakable staff, the starry lantern in your hand illuminates only your own path, no one elses.',
    directionTr: 'Zirvedeki yalnızlığını koru. Bilgelik dışarıdan gelmeyecek; karanlıkta asana yaslanıp fenerinin içindeki altı köşeli yıldıza bak.',
    directionEn: 'Maintain your solitude on the peak. Wisdom wont come from outside; lean on your staff in the dark and look at the star in your lantern.',
  ),
  10: CardMeaning(
    id: 10,
    themeTr: 'Kader, döngü, dönüm noktası',
    themeEn: 'Fate, cycle, turning point',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Çarkın üstündeki kılıçlı Sfenks hükmünü verdi, Anubis seni yukarı taşırken Yılan aşağı çekti. Hayatın büyük döngüsü seni buraya getirdi.',
    pastEn: 'The sword-wielding Sphinx passed judgment, Anubis carried you up while the Snake pulled you down. Lifes great cycle brought you here.',
    presentTr: 'Burç sembolleriyle dolu dev tekerlek durmaksızın dönüyor. İyi ya da kötü yok; şu an sadece kadersel bir değişimin tam merkezindesin.',
    presentEn: 'The giant wheel filled with zodiac symbols spins endlessly. There is no good or bad; you are directly at the center of fateful change.',
    directionTr: 'Çarkın üzerindeki yılan da, Anubis de dönmeye mecburdur. Kontrolü bırak, tekerlek dönerken merkeze odaklan ve değişimi kabul et.',
    directionEn: 'Both the snake and Anubis must turn with the wheel. Let go of control, focus on the center as it spins, and accept the change.',
  ),
  11: CardMeaning(
    id: 11,
    themeTr: 'Adalet, denge, doğruluk',
    themeEn: 'Justice, balance, truth',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'İki sütun arasındaki mor perdenin önünde oturan o yargıç gibi, ektiklerinin sonuçlarını tartan terazide kendi geçmişinle hesaplaştın.',
    pastEn: 'Like the judge sitting before the purple veil between two pillars, you reckoned with your past on the scales that weighed what you sowed.',
    presentTr: 'Bir elinde karar kılıcı yukarı kalkmış, diğer elindeki terazi kusursuz bir dengede. Gerçekler çıplak ve tüm yanılmalar kesilip atılıyor.',
    presentEn: 'One hand raises the sword of decision, the other elegantly balances the scales. Truths are bare and all illusions are cut away.',
    directionTr: 'Gözlerindeki bağı kendin çöz. İki ucu keskin kılıç adaleti sağlasın diye, terazinin ruhunu dinleyerek dürüstçe adım at.',
    directionEn: 'Untie the blindfold yourself. So the double-edged sword can bring justice, listen to the spirit of the scale and step honestly.',
  ),
  12: CardMeaning(
    id: 12,
    themeTr: 'Fedakârlık, bekleyiş, farklı bakış açısı',
    themeEn: 'Sacrifice, waiting, new perspective',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'T harfi şeklindeki canlı bir ağaca ayağından asıldın ama yüzün acı değil, huzur doluydu. Kendi isteğinle dünyayı baş aşağı gördün.',
    pastEn: 'You were hung by the foot on a T-shaped living tree, yet your face showed not pain, but peace. You willingly saw the world upside down.',
    presentTr: 'Başının etrafında asılı dururken bile alev alev yanan bir hale var. Hiçbir yere gitmiyorsun ama zihnin daha önce hiç olmadığı kadar aydınlık.',
    presentEn: 'There is a blazing halo around your head even as you hang suspended. You are going nowhere, but your mind is more luminous than ever.',
    directionTr: 'Ayağındaki ipi kesmeye çalışma. Serbest kalacağın o aydınlanma anına kadar dünyayı o farklı ve asılı perspektiften izlemeye devam et.',
    directionEn: 'Do not try to cut the rope on your foot. Observe the world from this hanging perspective until the enlightenment sets you free.',
  ),
  13: CardMeaning(
    id: 13,
    themeTr: 'Dönüşüm, kapanış, yenilenme',
    themeEn: 'Transformation, ending, renewal',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.ending,
    pastTr: 'Zırhlı bir iskelet beyaz atıyla ezip geçti; o eski kralın tacı düştü ve senin eski alışkanlıklarının hepsi yeryüzünden silindi.',
    pastEn: 'An armored skeleton rode its white horse over everything; the old kings crown fell and all your former habits were wiped from the earth.',
    presentTr: 'Ölüm şövalyesi karşında duruyor fakat ufukta iki kule arasından o parlak güneş doğmak üzere. Bu bir bitiş değil, ruhsal bir temizliktir.',
    presentEn: 'The Death knight stands before you, but on the horizon, a bright sun is rising between the towers. This is not an end, but a spirit purge.',
    directionTr: 'Atın önünde diz çöken çocuk gibi direnişi bırak. Yeni gün doğarken, ölü topraklarda açacak olan o mistik gülü (bayraktaki gül) kabul et.',
    directionEn: 'Drop the resistance like the child kneeling before the horse. As the new dawn nears, accept the mystic rose on the black flag.',
  ),
  14: CardMeaning(
    id: 14,
    themeTr: 'Denge, ılımlılık, sabır',
    themeEn: 'Balance, moderation, patience',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Kızıl kanatlı meleğin bir ayağı suda bir ayağı karadaydı; sen de zıt olan iki kupadaki suyu hiç dökmeden ustalıkla birbirine karıştırdın.',
    pastEn: 'The red-winged angel had one foot in water, one on land; you masterfully poured water between opposing cups without spilling a drop.',
    presentTr: 'Göğsünde aydınlık bir üçgen, alnında güneş mühürü olan melek senin yanında. Duygular(su) ile madde(kara) o muazzam ılımlılıkta buluşuyor.',
    presentEn: 'The angel with a luminous triangle on the chest and a sun symbol on the forehead is beside you. Emotion (water) and matter (earth) meet in grand moderation.',
    directionTr: 'Kupalar arası akan o mucizevi sıvıyı dökmemek için telaş etme. Arkadaki dağlara giden ince yolu bul, dengeyi bozmadan huzurla adımla.',
    directionEn: 'Do not rush lest you spill the miraculous liquid flowing between the cups. Find the thin path to the back mountains and walk smoothly.',
  ),
  15: CardMeaning(
    id: 15,
    themeTr: 'Bağımlılık, gölge, yüzleşme',
    themeEn: 'Attachment, shadow, confrontation',
    tone: CardTone.heavy,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Tahtında oturan boynuzlu ve yarasa kanatlı Şeytan ın tahtına prangalarla bağlandın. Ama zincirler o kadar boldu ki, sadece korkundan kaçmadın.',
    pastEn: 'You were chained to the throne of the horned, bat-winged Devil. But the chains were so loose, you only stayed bound out of fear.',
    presentTr: 'Kuyruklarında üzüm ve alev taşıyan kadın-erkek figürleri nefislerine yenilmiş. Karanlığın içinde körü körüne bir bağımlılıkta sıkışıp kalmış gibisin.',
    presentEn: 'The chained figures carry grapes and flames on their tails, surrendering to base desires. You seem stuck in a blind addiction in the dark.',
    directionTr: 'Boynundaki o gevşek zinciri ellerinle çıkarabilirsin! Şeytan asasını ne kadar kaldırmış olursa olsun, karanlık gölgende tutsak değilsin.',
    directionEn: 'You can lift that loose chain off your neck with your bare hands! No matter how high the Devil raises his torch, you are not a prisoner.',
  ),
  16: CardMeaning(
    id: 16,
    themeTr: 'Yıkım, kriz, ani değişim',
    themeEn: 'Destruction, crisis, sudden change',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.ending,
    pastTr: 'Karanlık gökte çakan o şiddetli şimşek sarı tacı devirdi ve üzerine güvendiğin o yüksek taş kule paramparça alevler içinde çöktü.',
    pastEn: 'The fierce lightning struck the yellow crown, and the high stone tower you relied on collapsed in flames and shattered ruins.',
    presentTr: 'İki figür alev alan kuleden tepeüstü aşağı düşüyor. Sahip olduğunu sandığın her inanç, kurduğun her plan büyük bir şokla yerle bir oluyor.',
    presentEn: 'Two figures are plunging headfirst from the burning tower. Every belief you held, every plan you built is crashing down in shock.',
    directionTr: 'Kül olan kuleyi kurtarmak için çabalama; yanıp kül olmasına izin ver. O yıldırım senin felaketin değil, yanılsamanı yok eden bir gerçektir.',
    directionEn: 'Do not fight to save the turning ash; let it burn entirely. That lightning is not your doom, but the truth destroying your illusions.',
  ),
  17: CardMeaning(
    id: 17,
    themeTr: 'Umut, ilham, iyileşme',
    themeEn: 'Hope, inspiration, healing',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Gecenin karanlığı dindi. Çıplak kadın figürü bir testiyi sulara, hislerine; diğerini toprağa, gerçeğe dökerek seni yaralarından arındırdı.',
    pastEn: 'The darkness faded. The naked woman poured one jug into the water (feelings) and one onto the earth (reality), washing your wounds clean.',
    presentTr: 'Tepede parlayan o devasa sekiz köşeli sarı yıldız, yedi küçük yıldızla birlikte yeryüzünü nuruna boğuyor. İçindeki o saf su nihayet akıyor.',
    presentEn: 'The giant eight-pointed yellow star above, joined by seven smaller stars, bathes the earth in pure light. Your inner pure water flows at last.',
    directionTr: 'Arkada ağaçtan uçmaya hazırlanan kutsal kuş İbis gibi ruhunu serbest bırak. Yıldızın ilham veren şifalı havuzundan sonsuza dek beslen.',
    directionEn: 'Free your soul like the sacred ibis bird preparing to fly from the tree behind. Feed forever from the Stars inspiring, healing pool.',
  ),
  18: CardMeaning(
    id: 18,
    themeTr: 'Yanılsama, korku, bilinçaltı',
    themeEn: 'Illusion, fear, subconscious',
    tone: CardTone.heavy,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Köpek ve kurt dolunaya doğru uluyordu; zihninin vahşi yanları uykudaydı ve sen karanlık sulardan sürünen kıskaca (kerevite) yenik düştün.',
    pastEn: 'The dog and wolf howled at the full moon; the wild sides of your mind slept as you succumbed to the crayfish crawling from the dark waters.',
    presentTr: 'Tam ayın sarı ışıkları altında o iki kule arasındaki yol tekinsiz. Neye inandığına dikkat et, her şey bir gölgeden ibaret olabilir.',
    presentEn: 'Under the yellow rays of the full moon, the path between the two towers feels eerie. Watch what you believe, everything might be a shadow.',
    directionTr: 'Suyun derinliklerindeki o ürkütücü kabuklu korkularını temsil eder. O dar, gölgeli yoldan iki kule arasını geçmek için korkularınla yüzleş.',
    directionEn: 'The creepy crustacean in the depths embodies your fears. To pass that narrow shadow path between the towers, face those fears directly.',
  ),
  19: CardMeaning(
    id: 19,
    themeTr: 'Başarı, canlılık, aydınlanma',
    themeEn: 'Success, vitality, enlightenment',
    tone: CardTone.soft,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Güneş bütün karanlıkları deldi. Çıplak, neşeli çocuk gri taş duvarın ardından beyaz atının üstünde ellerini açarak kucağına bir lütuf gibi indi.',
    pastEn: 'The sun pierced all darkness. Experiencing true joy, the naked playful child rode the white horse from behind the wall like a blessing.',
    presentTr: 'Arkadaki sarı ayçiçekleri sırtını sana değil o muazzam Güneş e dönmüş. Üzerinde hiçbir şey saklamaya gerek kalmayan parlayan bir ışıltı var.',
    presentEn: 'The yellow sunflowers behind face the magnificent Sun, not you. You are bathed in a shining light that requires hiding absolutely nothing.',
    directionTr: 'Çocuğun tuttuğu kırmızı zafer bayrağını sen devral. Gökyüzündeki neşeli Güneş gibi adımlarını aydınlat, kalbin ısınsın ve başarıya koş.',
    directionEn: 'Take the red banner of victory the child holds. Let your steps be illuminated like the joyful Sun, let your heart warm up, and run to success.',
  ),
  20: CardMeaning(
    id: 20,
    themeTr: 'Uyanış, yargı, çağrı',
    themeEn: 'Awakening, judgement, calling',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.awakening,
    pastTr: 'Cebrail (Gabriel) göklerden bulutlar arasında altın trompetini çaldı. Sen o sesi duydun ve geçmişte kapalı kaldığın tabutundan kollarını açıp çıktın.',
    pastEn: 'Gabriel blew his golden trumpet from the clouds. You heard the call and rose from the coffin where you were trapped in the past with open arms.',
    presentTr: 'Kollarını göğe doğru uzatmış o solgun bedenler yeniden can buluyor. Kendini yargılamayı bıraktın; şimdi gerçek ruhsal çağrına uyanıyorsun.',
    presentEn: 'Those pale figures reaching out to the sky are coming alive again. You have stopped judging yourself; now you awaken to your true calling.',
    directionTr: 'Trompetten sallanan o haçlı kırmızı bayrak senin nihaiDirilişini müjdeliyor. Eskiden öldü sandığın umutlar mezarından fışkıracak.',
    directionEn: 'The red-crossed flag swinging from the trumpet heralds your ultimate Resurrection. Hopes you thought dead will burst from their graves.',
  ),
  21: CardMeaning(
    id: 21,
    themeTr: 'Tamamlanma, bütünlük, zafer',
    themeEn: 'Completion, wholeness, triumph',
    tone: CardTone.soft,
    movement: CardMovement.motion,
    phase: CardPhase.completion,
    pastTr: 'Ovoil çelenk ve dört köşedeki aslan, boğa, kartal, melek ile dünya döngünü kapattın. O sonsuz dansçı gibi yolculuğu şaheserle noktaladın.',
    pastEn: 'You closed the cycle with the oval wreath and the lion, ox, eagle, and angel at the corners. Like the infinite dancer, your journey became a masterpiece.',
    presentTr: 'Yeşil çelenkin tam merkezinde, çıplak kadın iki elinde de denge asası tutarak zarifçe havada süzülüyor. Ruhsal ve maddi olan tam bir kusursuzlukta.',
    presentEn: 'Floating gracefully inside the green wreath, the naked woman holds wands of balance. The spiritual and physical are in absolute perfection.',
    directionTr: 'Kozmik dört element senin şahidindir. Çıkış da sensin, varış da. O mor kurdeleye dola ve tamamlanan bu eşsiz başyapıtını doya doya kutla!',
    directionEn: 'The four cosmic elements are your witnesses. You are the departure and the destination. Wrap in that purple ribbon and celebrate your masterpiece!',
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
  final List<String> promises;

  const TarotReading({
    required this.generalTheme,
    required this.pastInfluence,
    required this.presentEnergy,
    required this.directionAdvice,
    required this.closingMessage,
    required this.flowType,
    required this.flowLabel,
    required this.promises,
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

  // --- Pozisyon yorumları (her seferinde farklı ek cümle) ---
  final _posRng = Random();
  
  final pastInfluence = _variedPositionText(
    isTr ? m1.pastTr : m1.pastEn, 'past', flowType, isTr, _posRng,
  );
  final presentEnergy = _variedPositionText(
    isTr ? m2.presentTr : m2.presentEn, 'present', flowType, isTr, _posRng,
  );
  final directionAdvice = _variedPositionText(
    isTr ? m3.directionTr : m3.directionEn, 'direction', flowType, isTr, _posRng,
  );

  // --- Vaatler / Anahtar kelimeler (bir kere hesapla) ---
  final promises = _buildPromises(m1, m2, m3, isTr);

  // --- Kapanış mesajı (vaatlerle aynı kelimeleri kullanır) ---
  final closingMessage = _buildClosing(promises, flowType, isTr);

  return TarotReading(
    generalTheme: generalTheme,
    pastInfluence: pastInfluence,
    presentEnergy: presentEnergy,
    directionAdvice: directionAdvice,
    closingMessage: closingMessage,
    flowType: flowType,
    flowLabel: flowLabel,
    promises: promises,
  );
}

// --- Vaatler / Anahtar Kelimeler ---
List<String> _buildPromises(CardMeaning m1, CardMeaning m2, CardMeaning m3, bool isTr) {
  final rng = Random();
  final words1 = (isTr ? m1.themeTr : m1.themeEn).split(',').map((s) => s.trim()).toList();
  final words2 = (isTr ? m2.themeTr : m2.themeEn).split(',').map((s) => s.trim()).toList();
  final words3 = (isTr ? m3.themeTr : m3.themeEn).split(',').map((s) => s.trim()).toList();

  words1.shuffle(rng);
  words2.shuffle(rng);
  words3.shuffle(rng);

  String p1 = words1.first;
  String p2 = words2.first;
  String p3 = words3.first;

  if (p2 == p1 && words2.length > 1) p2 = words2[1];
  if ((p3 == p1 || p3 == p2) && words3.length > 1) p3 = words3[1];
  if ((p3 == p1 || p3 == p2) && words3.length > 2) p3 = words3[2];

  return [p1, p2, p3];
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

// --- Genel tema cümlesi (rastgele varyasyonlu) ---
final _themeRng = Random();

String _buildGeneralTheme(
  CardMeaning m1, CardMeaning m2, CardMeaning m3,
  String n1, String n2, String n3,
  FlowType flow, bool isTr,
) {
  List<String> pool;

  switch (flow) {
    case FlowType.harmonious:
      pool = isTr ? [
        '$n1, $n2 ve $n3 birlikte parlıyor. İçindeki ışığı korkusuzca yansıt.',
        '$n1 ışığı yakıyor, $n2 büyütüyor, $n3 önüne seriyor. Bu akış sana ait.',
        'Üç kart tek bir kalp atışı gibi: $n1 nabzı tutuyor, $n2 ritmi veriyor, $n3 şarkıyı söylüyor.',
        '$n1 toprağı hazırladı, $n2 tohumu ekti, $n3 çiçeği açtırdı. Hasat senin.',
        '$n1 ile $n2 el ele verdi, $n3 o bağı kutsuyor. Huzurun formülü önünde duruyor.',
        'Evren $n1 ile fısıldadı, $n2 ile dokundu, $n3 ile kucakladı. Şimdi sen konuş.',
      ] : [
        '$n1, $n2 and $n3 shine together. Reflect your inner light fearlessly.',
        '$n1 lights the spark, $n2 fans the flame, $n3 reveals the path. This flow is yours.',
        'Three cards beat as one heart: $n1 sets the pulse, $n2 gives the rhythm, $n3 sings the song.',
        '$n1 prepared the soil, $n2 planted the seed, $n3 bloomed the flower. The harvest is yours.',
        '$n1 and $n2 join hands, $n3 blesses the bond. The formula of peace stands before you.',
        'The universe whispered with $n1, touched with $n2, embraced with $n3. Now it is your turn to speak.',
      ];
      break;
    case FlowType.conflicting:
      pool = isTr ? [
        '$n1 sarsıyor, $n2 sınıyor ama $n3 çıkış yolunu gösteriyor.',
        '$n1 yıkıyor, $n2 sorgulatıyor, ama $n3 küllerin arasından altını buluyor.',
        '$n1 fırtınayı getirdi, $n2 dengeyi bozdu, $n3 gözünü açıyor. Dikkat et.',
        'Kartlar çatışıyor: $n1 ateşi, $n2 rüzgârı, $n3 ise o yangından doğacak yeni ormanı temsil ediyor.',
        '$n1 seni yere çaldı, $n2 yarana tuz bastı, ama $n3 ayağa kalkman gerektiğini hatırlatıyor.',
        '$n1 acıtıyor, $n2 zorluyorlar ama $n3 sana diyorlar ki: sen bundan büyüksün.',
      ] : [
        '$n1 shakes, $n2 tests, but $n3 reveals the way forward.',
        '$n1 destroys, $n2 questions, but $n3 finds gold among the ashes.',
        '$n1 brought the storm, $n2 broke the balance, $n3 opens your eyes. Pay attention.',
        'The cards clash: $n1 is the fire, $n2 is the wind, $n3 is the new forest born from that blaze.',
        '$n1 knocked you down, $n2 salted the wound, but $n3 reminds you to stand.',
        '$n1 hurts, $n2 pushes, but $n3 whispers: you are bigger than this.',
      ];
      break;
    case FlowType.transformative:
      pool = isTr ? [
        '$n1 bir kapıyı kapatıyor, $n2 seni dönüştürüyor, $n3 yeni bir başlangıç sunuyor.',
        '$n1 eski seni gömdü, $n2 seni yoğurdu, $n3 seni yeniden doğurdu. Tanışma zamanı.',
        'Eski sen $n1 ile öldü. $n2 cenaze töreni. $n3 ise yeni hayatın ilk nefesi.',
        '$n1 sayfayı yırttı, $n2 kalemi eline verdi, $n3 boş sayfayı önüne koydu. Yaz.',
        '$n1 kozayı ördü, $n2 içinde beklettti, $n3 kanatları açtırdı. Artık uç.',
        '$n1 geceyi getirdi, $n2 karanlıkta kaldırdı, $n3 şafağı söktürdü. Bu senin dönüşümün.',
      ] : [
        '$n1 closes a door, $n2 transforms you, $n3 offers a fresh start.',
        '$n1 buried the old you, $n2 reshaped you, $n3 birthed you anew. Time to meet yourself.',
        'The old you died with $n1. $n2 is the funeral. $n3 is the first breath of your new life.',
        '$n1 tore the page, $n2 handed you the pen, $n3 placed a blank page before you. Write.',
        '$n1 spun the cocoon, $n2 kept you waiting inside, $n3 unfurled the wings. Now fly.',
        '$n1 brought the night, $n2 held you in the dark, $n3 broke the dawn. This is your metamorphosis.',
      ];
      break;
  }

  return pool[_themeRng.nextInt(pool.length)];
}

// --- Pozisyon yorumlarına rastgele ek cümle ---
String _variedPositionText(
  String base, String position, FlowType flow, bool isTr, Random rng,
) {
  List<String> suffixes;

  if (position == 'past') {
    suffixes = isTr ? [
      ' Bu iz hâlâ sende yaşıyor.',
      ' O anın enerjisi bugün bile hissediliyor.',
      ' Geçmiş bitti ama dersi bitmedi.',
      ' O deneyim seni sen yapan parçalardan biri.',
      ' Geride bıraktığını sanıyorsun ama o seni bırakmadı.',
      ' Bu hatıra bir pusula gibi yön veriyor.',
      ' Orada bir şey öğrendin; şimdi hatırla.',
      ' Geçmişin gölgeleri aydınlığa dönüşmeyi bekliyor.',
    ] : [
      ' This mark still lives within you.',
      ' The energy of that moment is still felt today.',
      ' The past ended but its lesson did not.',
      ' That experience is one of the pieces that made you who you are.',
      ' You think you left it behind, but it never left you.',
      ' This memory guides you like a compass.',
      ' You learned something there; now remember.',
      ' The shadows of the past await their turn to become light.',
    ];
  } else if (position == 'present') {
    suffixes = isTr ? [
      ' Şu an tam da olman gereken yerdesin.',
      ' Bu enerji geçici değil; onu kullan.',
      ' Şimdi karar anı, dikkat et.',
      ' Bu an sana özel bir mesaj taşıyor.',
      ' Gözlerini aç, cevap önünde duruyor.',
      ' Bu enerji bir davet; kabul et ya da reddet.',
      ' Şimdiki an tek gerçek güç kaynağın.',
      ' Zamanın durduğu bu noktada, içine bak.',
    ] : [
      ' You are exactly where you need to be right now.',
      ' This energy is not temporary; use it.',
      ' Now is the moment of decision, pay attention.',
      ' This moment carries a special message for you.',
      ' Open your eyes, the answer stands before you.',
      ' This energy is an invitation; accept or decline.',
      ' The present moment is your only true source of power.',
      ' At this point where time stands still, look within.',
    ];
  } else {
    suffixes = isTr ? [
      ' Cesur ol, yol seni bekliyor.',
      ' Bu yön tek seçenek değil ama en doğrusu.',
      ' Adımını at; gerisini evren halledecek.',
      ' Geleceğin yazılmadı, onu sen yazıyorsun.',
      ' Bu kapıdan geçersen geri dönüşü olmayabilir. Ama o iyi bir şey.',
      ' Pusula kalbinde, harita ellerinde.',
      ' İleriye bak; geçmişe değil.',
      ' Yolun sonunda seni bekleyen, bugün hayal bile edemeyeceğin bir sen.',
    ] : [
      ' Be brave, the path awaits you.',
      ' This direction is not the only option, but the truest one.',
      ' Take your step; the universe will handle the rest.',
      ' Your future is not written, you are writing it.',
      ' If you pass through this door, there may be no return. But that is a good thing.',
      ' The compass is in your heart, the map in your hands.',
      ' Look forward, not backward.',
      ' At the end of the road awaits a version of you that today you cannot even imagine.',
    ];
  }

  return '$base ${suffixes[rng.nextInt(suffixes.length)]}';
}

// --- Kapanış mesajı (Kartların Gizli Fısıltısı — rastgele varyasyonlu) ---
final _closingRng = Random();

String _buildClosing(
  List<String> promises,
  FlowType flow, bool isTr,
) {
  final k1 = promises[0];
  final k2 = promises[1];
  final k3 = promises[2];

  List<String> pool;

  switch (flow) {
    case FlowType.harmonious:
      pool = isTr ? [
        '"$k1" seni buraya getirdi.\n"$k3" seni oraya götürecek.\nSadece güven.',
        '"$k1" bir kapıydı.\n"$k3" arkasındaki oda.\nSen zaten içindesin.',
        '"$k1" tohumdu.\n"$k2" toprak.\n"$k3" çiçek.\nKokla.',
        'Evren "$k1" dedi.\nSen "$k2" dedin.\n"$k3" cevap verdi.\nAnlaşma tamam.',
        '"$k1" sessizce geldi.\n"$k3" sessizce gidecek.\nArada sen varsın.\nVe bu yeterli.',
        '"$k1" ilk nefesindi.\n"$k2" yürüyüşün.\n"$k3" varış noktası.\nAma yol bitmedi.',
        'Biri sana "$k1" verdi.\nBiri "$k2" öğretti.\nŞimdi "$k3" sende.\nKullan.',
        '"$k3" sana bakıyor.\nGözlerinde "$k1" var.\nDudaklarında "$k2".\nDinle.',
      ] : [
        '"$k1" brought you here.\n"$k3" will take you there.\nJust trust.',
        '"$k1" was a door.\n"$k3" is the room behind it.\nYou are already inside.',
        '"$k1" was the seed.\n"$k2" was the soil.\n"$k3" is the bloom.\nBreathe it in.',
        'The universe said "$k1."\nYou said "$k2."\n"$k3" answered.\nThe deal is sealed.',
        '"$k1" came quietly.\n"$k3" will leave quietly.\nIn between, there is you.\nAnd that is enough.',
        '"$k1" was your first breath.\n"$k2" your walk.\n"$k3" your destination.\nBut the road goes on.',
        'Someone gave you "$k1."\nSomeone taught you "$k2."\nNow "$k3" is yours.\nUse it.',
        '"$k3" is watching you.\n"$k1" in its eyes.\n"$k2" on its lips.\nListen.',
      ];
      break;
    case FlowType.conflicting:
      pool = isTr ? [
        '"$k1" seni kırdı.\nAma "$k3" seni kuracak.\nHer yara bir kapıdır.',
        '"$k1" acıttı.\n"$k2" sordu: neden?\n"$k3" cevapladı: güçlenmek için.\nŞimdi bil.',
        'Kırıldın.\n"$k1" parçaladı.\n"$k2" dağıttı.\nAma "$k3" diyor ki:\nKırık yerlerden ışık girer.',
        '"$k1" bir yumruktu.\n"$k2" bir tokat.\n"$k3" uzanan bir el.\nTut.',
        'Acı "$k1" ile başladı.\n"$k2" ile derinleşti.\nAma "$k3"...\n"$k3" seni tanımlayacak olan.',
        '"$k1" geceydi.\n"$k2" fırtına.\nAma "$k3" şafak.\nVe şafak her zaman kazanır.',
        'Düştün.\n"$k1" itti.\n"$k2" izledi.\nAma "$k3" elini uzattı.\nYakala.',
        '"$k1" yakıyordu.\n"$k2" küllerdi.\n"$k3" anka kuşu.\nSen de öylesin.',
      ] : [
        '"$k1" broke you.\nBut "$k3" will rebuild you.\nEvery wound is a door.',
        '"$k1" hurt.\n"$k2" asked: why?\n"$k3" answered: to grow stronger.\nNow you know.',
        'You broke.\n"$k1" shattered.\n"$k2" scattered.\nBut "$k3" says:\nLight enters through the cracks.',
        '"$k1" was a punch.\n"$k2" was a slap.\n"$k3" is the hand reaching out.\nGrab it.',
        'Pain began with "$k1."\nDeepened with "$k2."\nBut "$k3"...\n"$k3" is what will define you.',
        '"$k1" was the night.\n"$k2" was the storm.\nBut "$k3" is the dawn.\nAnd dawn always wins.',
        'You fell.\n"$k1" pushed.\n"$k2" watched.\nBut "$k3" reached out.\nGrab on.',
        '"$k1" was burning.\n"$k2" was the ashes.\n"$k3" is the phoenix.\nSo are you.',
      ];
      break;
    case FlowType.transformative:
      pool = isTr ? [
        '"$k1" öldü.\n"$k3" doğuyor.\nSen de.',
        '"$k1" bitti.\nAma "$k3" başlıyor.\nFinaller her zaman yeni sezonların ilk sahnesidir.',
        'Eski sen "$k1" ile gömüldü.\n"$k2" mezar taşıydı.\n"$k3" diriliş.\nKalk.',
        '"$k1" son nefesiydi.\n"$k2" sessizlik.\n"$k3" ilk çığlık.\nYeniden doğdun.',
        '"$k1" yıktı.\n"$k2" temizledi.\n"$k3" inşa edecek.\nMimar sensin.',
        'Tırtıl "$k1" idi.\nKoza "$k2".\nKelebek "$k3".\nArtık uçabilirsin.',
        '"$k1" seni aldı.\n"$k2" seni değiştirdi.\n"$k3" seni geri verdi.\nAma farklı.\nÇok farklı.',
        '"$k1" bir vedaydı.\n"$k2" yolculuk.\n"$k3" yeni bir merhaba.\nGülümse.',
      ] : [
        '"$k1" died.\n"$k3" is being born.\nSo are you.',
        '"$k1" ended.\nBut "$k3" begins.\nFinales are always the opening scenes of new seasons.',
        'The old you was buried with "$k1."\n"$k2" was the tombstone.\n"$k3" is resurrection.\nRise.',
        '"$k1" was the last breath.\n"$k2" was silence.\n"$k3" is the first cry.\nYou are reborn.',
        '"$k1" demolished.\n"$k2" cleared the ground.\n"$k3" will build.\nYou are the architect.',
        'The caterpillar was "$k1."\nThe cocoon was "$k2."\nThe butterfly is "$k3."\nYou can fly now.',
        '"$k1" took you.\n"$k2" changed you.\n"$k3" gave you back.\nBut different.\nVery different.',
        '"$k1" was a goodbye.\n"$k2" the journey.\n"$k3" a new hello.\nSmile.',
      ];
      break;
  }

  return pool[_closingRng.nextInt(pool.length)];
}


// ============================================================
// Full Arcana — 7 Kart Yorum Motoru (Premium)
// ============================================================

/// 7 kartlık okumada her pozisyonun bilgisi
class FullCardReading {
  final String positionTitle;
  final String content;
  final String cardName;
  final int cardIndex;

  const FullCardReading({
    required this.positionTitle,
    required this.content,
    required this.cardName,
    required this.cardIndex,
  });
}

/// Element analizi sonucu
class ElementAnalysis {
  final Map<String, double> elements; // {'Ateş': 0.7, 'Su': 0.2, ...}
  final String dominantElement;
  final String dominantEmoji;
  final String dominantDescriptionTr;
  final String dominantDescriptionEn;

  const ElementAnalysis({
    required this.elements,
    required this.dominantElement,
    required this.dominantEmoji,
    required this.dominantDescriptionTr,
    required this.dominantDescriptionEn,
  });
}

/// Kart ilişki analizi
class CardRelation {
  final String card1Name;
  final String card2Name;
  final String relationTextTr;
  final String relationTextEn;
  final String emoji;

  const CardRelation({
    required this.card1Name,
    required this.card2Name,
    required this.relationTextTr,
    required this.relationTextEn,
    required this.emoji,
  });
}

/// Günlük ritüel önerisi
class RitualSuggestion {
  final String titleTr;
  final String titleEn;
  final String actionTr;
  final String actionEn;
  final String emoji;

  const RitualSuggestion({
    required this.titleTr,
    required this.titleEn,
    required this.actionTr,
    required this.actionEn,
    required this.emoji,
  });
}

class FullTarotReading {
  final String generalTheme;
  final List<FullCardReading> cardReadings; // 7 adet
  final String adviceParagraph;
  final String closingMessage;
  final FlowType flowType;
  final String flowLabel;
  final List<String> promises;
  // Premium özellikler
  final ElementAnalysis elementAnalysis;
  final List<CardRelation> cardRelations;
  final int cosmicScore;
  final String cosmicLabelTr;
  final String cosmicLabelEn;
  final String secretMessageTr;
  final String secretMessageEn;
  final RitualSuggestion ritualSuggestion;

  const FullTarotReading({
    required this.generalTheme,
    required this.cardReadings,
    required this.adviceParagraph,
    required this.closingMessage,
    required this.flowType,
    required this.flowLabel,
    required this.promises,
    required this.elementAnalysis,
    required this.cardRelations,
    required this.cosmicScore,
    required this.cosmicLabelTr,
    required this.cosmicLabelEn,
    required this.secretMessageTr,
    required this.secretMessageEn,
    required this.ritualSuggestion,
  });
}

/// 7 kart pozisyon başlıkları
List<String> _fullPositionsTr = [
  'Geçmiş',
  'Şimdi',
  'Gizli Etkiler',
  'Engeller',
  'Çevre',
  'Tavsiye',
  'Sonuç',
];

List<String> _fullPositionsEn = [
  'Past',
  'Present',
  'Hidden Influences',
  'Obstacles',
  'Environment',
  'Advice',
  'Outcome',
];

/// Pozisyona özgü yorum üretme (7 pozisyon)
String _fullPositionReading(CardMeaning meaning, int positionIndex, bool isTr, Random rng) {
  // Her pozisyon için base text + ek cümle
  String base;
  List<String> extras;

  switch (positionIndex) {
    case 0: // Geçmiş
      base = isTr ? meaning.pastTr : meaning.pastEn;
      extras = isTr ? [
        'Bu enerji seni bugüne taşıdı.',
        'Geçmişin gölgesi hâlâ üzerinde.',
        'O deneyim bugünkü gücünün kaynağı.',
        'Geride bıraktığını sandığın ama bırakamadığın bir iz.',
      ] : [
        'This energy carried you to today.',
        'The shadow of the past still lingers.',
        'That experience is the source of your present strength.',
        'A mark you thought you left behind, but never truly did.',
      ];
      break;
    case 1: // Şimdi
      base = isTr ? meaning.presentTr : meaning.presentEn;
      extras = isTr ? [
        'Şu an her şey bu kartın enerjisiyle titreşiyor.',
        'Bu enerji geçici değil, kucakla.',
        'Tam da olman gereken an burası.',
        'Şimdinin gücü ellerinde, kullan.',
      ] : [
        'Right now, everything vibrates with this cards energy.',
        'This energy is not fleeting, embrace it.',
        'This is exactly where you need to be.',
        'The power of now is in your hands, use it.',
      ];
      break;
    case 2: // Gizli Etkiler
      base = isTr ? meaning.directionTr : meaning.directionEn;
      extras = isTr ? [
        'Farkında olmadığın ama hayatını yönlendiren bir güç bu.',
        'Bilinçaltın sana bunu fısıldıyor, duymaya hazır ol.',
        'Görünmeyen iplerle bağlı olduğun bir enerji.',
        'Bu etki karanlıkta çalışıyor ama sonuçları aydınlıkta.',
        'Perdenin arkasındaki güç budur.',
      ] : [
        'A force you are unaware of, yet it steers your life.',
        'Your subconscious whispers this, be ready to listen.',
        'An energy you are invisibly tied to.',
        'This influence works in the dark, but results show in the light.',
        'This is the power behind the veil.',
      ];
      break;
    case 3: // Engeller
      base = isTr ? meaning.presentTr : meaning.presentEn;
      extras = isTr ? [
        'Bu engel aşılmak için var, korkma.',
        'Yolundaki taş, seni durdurmak için değil, güçlendirmek için orada.',
        'Her engel gizli bir öğretmendir.',
        'Karşına çıkan bu duvar, aslında bir kapı.',
        'Bu zorluk, dönüşümünün anahtarı.',
      ] : [
        'This obstacle exists to be overcome, do not fear.',
        'The stone in your path is there not to stop you, but to strengthen you.',
        'Every obstacle is a hidden teacher.',
        'The wall before you is actually a door.',
        'This challenge is the key to your transformation.',
      ];
      break;
    case 4: // Çevre
      base = isTr ? meaning.pastTr : meaning.pastEn;
      extras = isTr ? [
        'Çevrenden gelen bu enerji seni derinden etkiliyor.',
        'Etrafındaki insanlar bu kartın enerjisini taşıyor.',
        'Çevrenin sessiz etkisi hafife alınmamalı.',
        'Yakınlarından gelen bu titreşim, kararlarını şekillendiriyor.',
        'Dış dünyanın sana gönderdiği bir mesaj bu.',
      ] : [
        'This energy from your surroundings deeply affects you.',
        'People around you carry this cards energy.',
        'The silent influence of your environment should not be underestimated.',
        'This vibration from those close to you shapes your decisions.',
        'This is a message the outer world sends you.',
      ];
      break;
    case 5: // Tavsiye
      base = isTr ? meaning.directionTr : meaning.directionEn;
      extras = isTr ? [
        'Kartlar sana bunu yapmanı söylüyor, dinle.',
        'Bu tavsiye bir hediye, onu kabul et.',
        'Evrenin sana sunduğu yol haritası bu.',
        'Cesur ol ve bu kartın gösterdiği yöne yürü.',
        'Bu bilgelik doğrudan kaderin ağzından geliyor.',
      ] : [
        'The cards urge you to do this, listen.',
        'This advice is a gift, accept it.',
        'This is the roadmap the universe offers you.',
        'Be brave and walk in the direction this card shows.',
        'This wisdom comes straight from the mouth of destiny.',
      ];
      break;
    default: // Sonuç (6)
      base = isTr ? meaning.directionTr : meaning.directionEn;
      extras = isTr ? [
        'Yolculuğun sonu buraya çıkıyor.',
        'Kaderin nihai fısıltısı budur.',
        'Tüm kartlar bu sonuca işaret ediyor.',
        'Bu sonuç kaçınılmaz değil, seçimlerin belirleyecek.',
        'Evren sana bu kapıyı açık bırakıyor.',
      ] : [
        'Your journey leads to this destination.',
        'This is the final whisper of fate.',
        'All cards point to this outcome.',
        'This outcome is not inevitable, your choices will decide.',
        'The universe leaves this door open for you.',
      ];
      break;
  }

  final extra = extras[rng.nextInt(extras.length)];
  return '$base $extra';
}

/// 7 kart genel tema cümlesi (premium, daha derin)
String _buildFullGeneralTheme(List<CardMeaning> meanings, List<String> names, FlowType flow, bool isTr) {
  final rng = Random();
  final t0 = (isTr ? meanings[0].themeTr : meanings[0].themeEn).split(',').first.trim();
  final t6 = (isTr ? meanings[6].themeTr : meanings[6].themeEn).split(',').first.trim();
  List<String> pool;

  switch (flow) {
    case FlowType.harmonious:
      pool = isTr ? [
        'Yedi kart tek bir senfonide buluşuyor. Geçmişinde ${names[0]} bir temel attı, ${names[1]} bu temeli güçlendirdi. ${names[2]} farkında olmadığın bir enerjiyi harekete geçirdi. ${names[3]} yolundaki engelleri yumuşattı, ${names[4]} çevrenden desteği gösteriyor. ${names[5]} sana net bir tavsiye veriyor ve ${names[6]} tüm bu yolculuğun huzurlu bir sonuca ulaşacağını müjdeliyor.',
        'Kartlar sana huzurun resmini çiziyor. ${names[0]} fırçayı aldı ve $t0 ile başladı. ${names[1]} bugünün renklerini ekledi, ${names[2]} görünmeyen detayları ortaya çıkardı. ${names[3]} sınavı yumuşattı, ${names[4]} çevrendeki uyumu gösterdi. ${names[5]} son fırça darbesini vurdu ve ${names[6]} tabloyu asıyor. Bu sanat eseri senin.',
        '${names[0]} ışığı yaktı, ${names[1]} alevleri besledi. ${names[2]} karanlıkta saklanan gücü açığa çıkardı. ${names[3]} yolundaki taşları döşedi, ${names[4]} seni destekleyen rüzgâr oldu. ${names[5]} rehber olarak yolunu aydınlattı ve ${names[6]} seni eve götürüyor. $t6 ile taçlanan bu yolculuk kutlu.',
      ] : [
        'Seven cards unite in a single symphony. In your past, ${names[0]} laid a foundation and ${names[1]} strengthened it. ${names[2]} set an unseen force in motion. ${names[3]} softened the obstacles, ${names[4]} reveals support from your surroundings. ${names[5]} offers clear advice, and ${names[6]} heralds a peaceful conclusion.',
        'The cards paint a picture of peace. ${names[0]} took the brush, starting with $t0. ${names[1]} added todays colors, ${names[2]} revealed hidden details. ${names[3]} eased the trial, ${names[4]} showed harmony. ${names[5]} made the final stroke and ${names[6]} hangs the masterpiece. This art is yours.',
        '${names[0]} lit the light, ${names[1]} fed the flame. ${names[2]} unveiled hidden strength. ${names[3]} paved the way, ${names[4]} became the supporting wind. ${names[5]} illuminated your path and ${names[6]} takes you home. This journey crowned with $t6 is blessed.',
      ];
      break;
    case FlowType.conflicting:
      pool = isTr ? [
        'Yedi kart arasında bir fırtına esiyor. ${names[0]} geçmişten gelen şimşeği çaktırdı, ${names[1]} şimdiki gerginliği hissettiriyor. ${names[2]} perdenin arkasındaki çatışmayı ortaya çıkardı. ${names[3]} önüne koyduğu engel zorlu ama ${names[4]} çevrenden gelen güç seni taşıyor. ${names[5]} sana savaş planını veriyor ve ${names[6]} sonunda gökkuşağını vaat ediyor.',
        'Kartlar çatışıyor ama bir düzen var. ${names[0]} savaşın kökenini gösteriyor, ${names[1]} cepheyi çiziyor. ${names[2]} gizli müttefikleri açığa çıkardı. ${names[3]} asıl engeli işaret ediyor, ${names[4]} stratejik desteği gösteriyor. ${names[5]} son hamleyi fısıldıyor ve ${names[6]} zaferi müjdeliyor.',
        '${names[0]} bir kapıyı kapattı ama ${names[1]} yenisini açıyor. ${names[2]} göremediğin düşmanı gösterdi, ${names[3]} sınavını koydu. ${names[4]} seni çevreleyen enerji ile sınıyor. Ama ${names[5]} sana silah veriyor ve ${names[6]} seni galip çıkarıyor. Her çatışma bir büyüme fırsatı.',
      ] : [
        'A storm blows between seven cards. ${names[0]} struck lightning from the past, ${names[1]} brings present tension. ${names[2]} exposed the conflict behind the curtain. The obstacle ${names[3]} placed is tough, but ${names[4]} shows surrounding strength. ${names[5]} gives you the battle plan and ${names[6]} promises the rainbow.',
        'The cards clash, but theres an order. ${names[0]} shows the root of battle, ${names[1]} draws the front line. ${names[2]} revealed hidden allies. ${names[3]} marks the real obstacle, ${names[4]} shows strategic support. ${names[5]} whispers the final move and ${names[6]} heralds victory.',
        '${names[0]} closed a door but ${names[1]} opens a new one. ${names[2]} revealed the unseen enemy, ${names[3]} set the trial. ${names[4]} surrounding energy tests you. But ${names[5]} arms you and ${names[6]} declares you victorious. Every conflict is a growth opportunity.',
      ];
      break;
    case FlowType.transformative:
      pool = isTr ? [
        'Yedi kart bir metamorfoz çiziyor. ${names[0]} eski halini gösteriyor — $t0 seninle başladı. ${names[1]} dönüşümün şimdiki anını yansıtıyor. ${names[2]} bilinçaltında başlayan değişimi açığa çıkardı. ${names[3]} kırılma noktasını işaret ediyor, ${names[4]} çevrenin bu dönüşüme tepkisini gösteriyor. ${names[5]} yeni yolun haritasını çiziyor ve ${names[6]} kanatlarını açıyor. Dönüşümün muhteşem.',
        '${names[0]} eski seni gömdü, ${names[1]} yasını tuttu. ${names[2]} toprağın altında ne olduğunu fısıldadı. ${names[3]} kırılgan anı gösteriyor, ${names[4]} çevreden gelen yeni enerjiyi taşıyor. ${names[5]} kazma verdi ve ${names[6]} hazineyi ortaya çıkarıyor. $t6 artık senin.',
        'Kartların hikâyesi bir anka kuşu: ${names[0]} yanıyor, ${names[1]} alevleri hissediyor, ${names[2]} duman arasında bir şey parlıyor. ${names[3]} kül oluyor, ${names[4]} rüzgâr esiyor, ${names[5]} ilk kıvılcımı atıyor ve ${names[6]} küllerden yeniden doğuyor. Bu sen!',
      ] : [
        'Seven cards draw a metamorphosis. ${names[0]} shows your former self — $t0 began with you. ${names[1]} reflects the present moment. ${names[2]} revealed the subconscious shift. ${names[3]} marks the breaking point, ${names[4]} shows your environments reaction. ${names[5]} maps the new path and ${names[6]} unfurls the wings. Your transformation is magnificent.',
        '${names[0]} buried the old you, ${names[1]} mourned. ${names[2]} whispered what lies beneath. ${names[3]} shows the fragile moment, ${names[4]} carries new energy. ${names[5]} gave you the shovel and ${names[6]} reveals the treasure. $t6 is now yours.',
        'The cards tell the story of a phoenix: ${names[0]} burns, ${names[1]} feels the flames, ${names[2]} — something glimmers through the smoke. ${names[3]} becomes ash, ${names[4]} the wind blows, ${names[5]} sparks the first flame and ${names[6]} rises from the ashes. That is you!',
      ];
      break;
  }

  return pool[rng.nextInt(pool.length)];
}

/// 7 kart tavsiye paragrafı oluşturma
String _buildFullAdvice(List<CardMeaning> meanings, List<String> names, FlowType flow, bool isTr) {
  final rng = Random();
  List<String> pool;

  pool = isTr ? [
    '${names[5]} kartının tavsiyesini rehber al. ${names[3]} engelinin üstesinden ${names[2]}\'nin gizli bilgeliğiyle gel. ${names[6]} seni bekliyor.',
    'Geçmişindeki ${names[0]} artık bitti. Şimdiki ${names[1]} sana güç veriyor. ${names[5]}\'in gösterdiği yolu takip et ve ${names[6]}\'e ulaş.',
    'Çevrenden gelen ${names[4]} enerjisini hafife alma. ${names[5]} sana net bir yol çiziyor. ${names[3]} engelini aşmak için ${names[2]}\'nin sırlarını kullan.',
    'Bu yedi kart sana şunu söylüyor: ${names[0]}\'dan ders al, ${names[1]}\'i yaşa, ${names[2]}\'nin peşine düş, ${names[3]}\'ü aş, ${names[4]}\'den güç al, ${names[5]}\'e kulak ver ve ${names[6]}\'e yürü.',
  ] : [
    'Take ${names[5]}\'s advice as your guide. Overcome ${names[3]}\'s obstacle with ${names[2]}\'s hidden wisdom. ${names[6]} is waiting for you.',
    'The past of ${names[0]} is done. The present ${names[1]} gives you strength. Follow the path ${names[5]} shows and reach ${names[6]}.',
    'Don\'t underestimate the energy of ${names[4]} from your surroundings. ${names[5]} draws a clear path for you. Use ${names[2]}\'s secrets to overcome ${names[3]}.',
    'These seven cards tell you: learn from ${names[0]}, live ${names[1]}, pursue ${names[2]}, overcome ${names[3]}, draw strength from ${names[4]}, listen to ${names[5]}, and walk toward ${names[6]}.',
  ];

  return pool[rng.nextInt(pool.length)];
}

/// Full Arcana 7 kart kapanış mesajı
String _buildFullClosing(List<String> promises, FlowType flow, bool isTr) {
  final rng = Random();
  final k1 = promises[0];
  final k2 = promises[1];
  final k3 = promises.length > 2 ? promises[2] : k2;
  final k4 = promises.length > 3 ? promises[3] : k3;

  List<String> pool;

  switch (flow) {
    case FlowType.harmonious:
      pool = isTr ? [
        '"$k1" seni çağırıyor.\n"$k2" seni karşılıyor.\n"$k3" seni sarıyor.\n"$k4" seni tamamlıyor.\nEvren seninle dans ediyor.',
        'Yedi kartın fısıltısı tek bir kelimeye dönüşüyor:\n"$k1."\nVe bu kelime senin için yazıldı.',
        '"$k1" başlangıç.\n"$k2" yolculuk.\n"$k3" keşif.\n"$k4" zafer.\nBu hikâye senin.',
      ] : [
        '"$k1" calls you.\n"$k2" welcomes you.\n"$k3" embraces you.\n"$k4" completes you.\nThe universe dances with you.',
        'The whisper of seven cards becomes one word:\n"$k1."\nAnd this word was written for you.',
        '"$k1" is the beginning.\n"$k2" the journey.\n"$k3" the discovery.\n"$k4" the triumph.\nThis story is yours.',
      ];
      break;
    case FlowType.conflicting:
      pool = isTr ? [
        '"$k1" acıttı.\n"$k2" sorguladı.\n"$k3" sınadı.\nAma "$k4" diyor ki:\nHer fırtınadan sonra bir gökkuşağı var.',
        'Yedi kartın savaşı sona erdi.\n"$k1" yenilmedi.\n"$k2" güçlendi.\n"$k3" direndi.\n"$k4" kazandı.\nSen kazandın.',
        '"$k1" kırıldı.\n"$k2" döküldü.\nAma "$k3" ve "$k4" seni yeniden inşa ediyor.\nKırık yerlerden altın akar.',
      ] : [
        '"$k1" hurt.\n"$k2" questioned.\n"$k3" tested.\nBut "$k4" says:\nAfter every storm, there is a rainbow.',
        'The battle of seven cards has ended.\n"$k1" didn\'t lose.\n"$k2" grew stronger.\n"$k3" endured.\n"$k4" won.\nYou won.',
        '"$k1" broke.\n"$k2" spilled.\nBut "$k3" and "$k4" rebuild you.\nGold flows through the cracks.',
      ];
      break;
    case FlowType.transformative:
      pool = isTr ? [
        '"$k1" öldü.\n"$k2" gömüldü.\n"$k3" filizlendi.\n"$k4" çiçek açtı.\nBu senin yeniden doğuşun.',
        'Eski sen "$k1" ile vedalaştı.\n"$k2" yas tuttu.\n"$k3" yeni tohum ekti.\n"$k4" güneşi doğurdu.\nŞimdi yeni seni kutla.',
        '"$k1" son nefesti.\n"$k2" sessizlik.\n"$k3" ilk hareket.\n"$k4" yeni bir çığlık.\nYeniden doğdun.',
      ] : [
        '"$k1" died.\n"$k2" was buried.\n"$k3" sprouted.\n"$k4" bloomed.\nThis is your rebirth.',
        'The old you said goodbye to "$k1."\n"$k2" mourned.\n"$k3" planted new seeds.\n"$k4" birthed the sun.\nCelebrate the new you.',
        '"$k1" was the last breath.\n"$k2" silence.\n"$k3" first movement.\n"$k4" a new cry.\nYou are reborn.',
      ];
      break;
  }

  return pool[rng.nextInt(pool.length)];
}

// ============================================================
// Premium Analiz Fonksiyonları (Sadece Full Arcana)
// ============================================================

/// Element analizi — 7 kartın tonuna göre element dağılımı
ElementAnalysis _analyzeElements(List<CardMeaning> meanings) {
  int fire = 0, water = 0, air = 0, earth = 0;

  for (final m in meanings) {
    switch (m.tone) {
      case CardTone.soft:
        fire += 2; air += 1;
        break;
      case CardTone.heavy:
        water += 2; earth += 1;
        break;
      case CardTone.decision:
        air += 1; earth += 1;
        break;
    }
    switch (m.movement) {
      case CardMovement.motion:
        fire += 1;
        break;
      case CardMovement.stillness:
        earth += 1;
        break;
    }
    switch (m.phase) {
      case CardPhase.beginning:
      case CardPhase.awakening:
        fire += 1; air += 1;
        break;
      case CardPhase.ending:
      case CardPhase.neutral:
        water += 1; earth += 1;
        break;
      case CardPhase.completion:
        earth += 2;
        break;
    }
  }

  final total = (fire + water + air + earth).toDouble();
  final elements = {
    'Ateş': fire / total,
    'Su': water / total,
    'Hava': air / total,
    'Toprak': earth / total,
  };

  // Baskın element
  String dominant = 'Ateş';
  double maxVal = 0;
  elements.forEach((k, v) { if (v > maxVal) { maxVal = v; dominant = k; } });

  final emojis = {'Ateş': '🔥', 'Su': '💧', 'Hava': '🌬️', 'Toprak': '🌿'};
  final descTr = {
    'Ateş': 'Ateş baskın — aksiyon, tutku ve cesaret enerjin yüksek! Harekete geçme zamanı.',
    'Su': 'Su baskın — duygusal derinlik ve sezgi gücün dorukta. İç sesini dinle.',
    'Hava': 'Hava baskın — zihinsel berraklık ve iletişim enerjin güçlü. Düşün ve konuş.',
    'Toprak': 'Toprak baskın — istikrar ve pratiklik enerjin yüksek. Sağlam adımlar at.',
  };
  final descEn = {
    'Ateş': 'Fire dominant — your energy for action, passion and courage is high! Time to move.',
    'Su': 'Water dominant — your emotional depth and intuition are at their peak. Listen to your inner voice.',
    'Hava': 'Air dominant — your mental clarity and communication energy is strong. Think and speak.',
    'Toprak': 'Earth dominant — your stability and practicality energy is high. Take solid steps.',
  };

  return ElementAnalysis(
    elements: elements,
    dominantElement: dominant,
    dominantEmoji: emojis[dominant]!,
    dominantDescriptionTr: descTr[dominant]!,
    dominantDescriptionEn: descEn[dominant]!,
  );
}

/// Kart ilişki analizi — En güçlü 2-3 sinerji
List<CardRelation> _analyzeCardRelations(List<CardMeaning> meanings, List<String> names, bool isTr) {
  final relations = <CardRelation>[];
  final rng = Random();

  // İlişki tipleri
  final synergies = <Map<String, dynamic>>[];
  final usedTexts = <String>{};

  for (int i = 0; i < meanings.length; i++) {
    for (int j = i + 1; j < meanings.length; j++) {
      final m1 = meanings[i];
      final m2 = meanings[j];
      int score = 0;
      String typeTr = '';
      String typeEn = '';
      String emoji = '✨';

      // Aynı ton = güçlendirici
      if (m1.tone == m2.tone) {
        score += 3;
        if (m1.tone == CardTone.soft) {
          final opts = [
            {'tr': 'birbirinin ışığını güçlendiriyor — beraber parlıyorlar!', 'en': 'amplify each other\'s light — they shine together!', 'e': '☀️'},
            {'tr': 'aynı frekansta titreşiyor — güçlü bir rezonans!', 'en': 'vibrate at the same frequency — powerful resonance!', 'e': '💫'},
            {'tr': 'birlikte umut ve iyimserlik enerjisi taşıyor!', 'en': 'carry hope and optimism energy together!', 'e': '🌟'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        } else if (m1.tone == CardTone.heavy) {
          final opts = [
            {'tr': 'birlikte gölgelerin derinliğine iniyor — orada bir hazine var!', 'en': 'descend into the depth of shadows together — there\'s treasure there!', 'e': '🌑'},
            {'tr': 'karanlıkta birbirini buluyor — bu güç yabana atılmaz!', 'en': 'find each other in the dark — this power is not to be underestimated!', 'e': '🔮'},
            {'tr': 'ağır enerjileri birleştirip dönüştürüyor!', 'en': 'combine heavy energies and transform them!', 'e': '⚗️'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        } else {
          final opts = [
            {'tr': 'birlikte hassas bir denge kuruyor — uyum!', 'en': 'create a delicate balance together — harmony!', 'e': '⚖️'},
            {'tr': 'karar anında birbirini destekliyor — net bir yol çiziyor!', 'en': 'support each other at moments of decision — drawing a clear path!', 'e': '🧭'},
            {'tr': 'birlikte bir kavşak noktası oluşturuyor — seçim zamanı!', 'en': 'form a crossroads together — time to choose!', 'e': '🔀'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        }
      }

      // Zıt hareket = gerilim ama büyüme
      if (m1.movement != m2.movement) {
        score += 2;
        final opts = [
          {'tr': 'zıt yönlere çekiyor — bu gerilim seni büyütecek!', 'en': 'pull in opposite directions — this tension will grow you!', 'e': '⚡'},
          {'tr': 'biri ileri itiyor, diğeri bekletiyor — sabır ve cesaret arasında bir dans!', 'en': 'one pushes forward, the other holds still — a dance between patience and courage!', 'e': '🌪️'},
          {'tr': 'karşıt enerjiler — çatışma değil, denge arayışı!', 'en': 'opposing energies — not conflict, but a search for balance!', 'e': '🔄'},
          {'tr': 'farklı ritimler — bu kontrast sana yeni bir bakış açısı sunuyor!', 'en': 'different rhythms — this contrast offers you a new perspective!', 'e': '🎭'},
        ];
        final pick = opts[rng.nextInt(opts.length)];
        typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
      }

      // Aynı faz = eş zamanlı enerji
      if (m1.phase == m2.phase) {
        score += 2;
        if (m1.phase == CardPhase.beginning || m1.phase == CardPhase.awakening) {
          final opts = [
            {'tr': 'birlikte yeni bir sayfa açıyor — taze enerji!', 'en': 'open a new chapter together — fresh energy!', 'e': '🌅'},
            {'tr': 'beraber filizleniyor — bu başlangıç çok güçlü!', 'en': 'sprout together — this beginning is very powerful!', 'e': '🌱'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        } else if (m1.phase == CardPhase.completion || m1.phase == CardPhase.ending) {
          final opts = [
            {'tr': 'birlikte bir döngüyü kapatıyor — kapanan kapılar, açılan pencereler!', 'en': 'close a cycle together — closing doors, opening windows!', 'e': '🌙'},
            {'tr': 'beraber bir sonuca ulaşıyor — bu final güçlü!', 'en': 'reach a conclusion together — this finale is powerful!', 'e': '🏁'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        }
      }

      if (score >= 2 && typeTr.isNotEmpty && !usedTexts.contains(typeTr)) {
        usedTexts.add(typeTr);
        synergies.add({
          'i': i, 'j': j, 'score': score,
          'typeTr': typeTr, 'typeEn': typeEn, 'emoji': emoji,
        });
      }
    }
  }

  // Skora göre sırala, en iyi 3'ünü al
  synergies.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
  final top = synergies.take(3);

  for (final s in top) {
    final i = s['i'] as int;
    final j = s['j'] as int;
    relations.add(CardRelation(
      card1Name: names[i],
      card2Name: names[j],
      relationTextTr: '${names[i]} ve ${names[j]} ${s['typeTr']}',
      relationTextEn: '${names[i]} and ${names[j]} ${s['typeEn']}',
      emoji: s['emoji'] as String,
    ));
  }

  // En az 2 ilişki garanti et
  if (relations.length < 2) {
    final fallbackTr = [
      'birlikte yeni kapılar açıyor!',
      'sana gizli bir mesaj gönderiyor!',
      'enerjilerini birleştiriyor!',
    ];
    final fallbackEn = [
      'open new doors together!',
      'send you a hidden message!',
      'combine their energies!',
    ];
    while (relations.length < 2) {
      final idx = rng.nextInt(fallbackTr.length);
      relations.add(CardRelation(
        card1Name: names[rng.nextInt(3)],
        card2Name: names[4 + rng.nextInt(3)],
        relationTextTr: '${names[rng.nextInt(7)]} ve ${names[rng.nextInt(7)]} ${fallbackTr[idx]}',
        relationTextEn: '${names[rng.nextInt(7)]} and ${names[rng.nextInt(7)]} ${fallbackEn[idx]}',
        emoji: '✨',
      ));
    }
  }

  return relations;
}

/// Kozmik uyum skoru (0-100)
Map<String, dynamic> _calculateCosmicScore(List<CardMeaning> meanings, FlowType flow) {
  int score = 50; // base

  // FlowType bonusu
  switch (flow) {
    case FlowType.harmonious: score += 25; break;
    case FlowType.transformative: score += 15; break;
    case FlowType.conflicting: score += 5; break;
  }

  // Ton tutarlılığı
  final tones = meanings.map((m) => m.tone).toList();
  final brightCount = tones.where((t) => t == CardTone.soft).length;
  if (brightCount >= 5) score += 15;
  else if (brightCount >= 3) score += 8;

  // Hareket uyumu
  final forwardCount = meanings.where((m) => m.movement == CardMovement.motion).length;
  if (forwardCount >= 5) score += 10;
  else if (forwardCount >= 3) score += 5;

  score = score.clamp(15, 98);

  String labelTr, labelEn;
  if (score >= 85) { labelTr = 'Muhteşem Uyum'; labelEn = 'Magnificent Harmony'; }
  else if (score >= 70) { labelTr = 'Güçlü Uyum'; labelEn = 'Strong Harmony'; }
  else if (score >= 55) { labelTr = 'Dengeli Enerji'; labelEn = 'Balanced Energy'; }
  else if (score >= 40) { labelTr = 'Karışık Enerji'; labelEn = 'Mixed Energy'; }
  else { labelTr = 'Çatışmalı Enerji'; labelEn = 'Conflicting Energy'; }

  return {'score': score, 'labelTr': labelTr, 'labelEn': labelEn};
}

/// Gizli mesaj — 7 karttan çıkan sır
Map<String, String> _generateSecretMessage(List<CardMeaning> meanings, List<String> names, FlowType flow, bool isTr) {
  final rng = Random();
  final t0 = meanings[0].themeTr.split(',').first.trim();
  final t6 = meanings[6].themeTr.split(',').first.trim();
  final t0en = meanings[0].themeEn.split(',').first.trim();
  final t6en = meanings[6].themeEn.split(',').first.trim();

  final poolTr = [
    'Yedi kartın sessiz anlaşması şu: "$t0" ile başlayan yolculuğun "$t6" ile son bulmayacak — bu sadece bir başlangıç. Asıl hazine, bu iki nokta arasında saklı.',
    '${names[2]} sana kimsenin söylemediği bir gerçeği fısıldıyor: Engel sandığın şey, aslında seni koruyordu. ${names[6]} bunu kanıtlayacak.',
    'Kartlar bir sır paylaşıyor: ${names[0]} ile ${names[6]} aynı enerjinin iki yüzü. Biri seni tırtıl yapıyor, diğeri kelebek.',
    'Yedi kartın gizli mesajı şu: Şu an tam olman gereken yerdesin. ${names[5]} sana bunu hatırlatmak için geldi.',
    '${names[3]} engel değil, öğretmen. ${names[2]} sana bu dersin sırrını veriyor: "$t0" artık "$t6" olacak.',
  ];

  final poolEn = [
    'The silent pact of seven cards: the journey starting with "$t0en" won\'t end at "$t6en" — this is just the beginning. The real treasure is hidden between these two points.',
    '${names[2]} whispers a truth no one told you: what you thought was an obstacle was actually protecting you. ${names[6]} will prove this.',
    'The cards share a secret: ${names[0]} and ${names[6]} are two faces of the same energy. One makes you a caterpillar, the other a butterfly.',
    'The hidden message of seven cards: you are exactly where you need to be right now. ${names[5]} came to remind you of this.',
    '${names[3]} is not an obstacle, but a teacher. ${names[2]} gives you the secret of this lesson: "$t0en" will become "$t6en".',
  ];

  final idx = rng.nextInt(poolTr.length);
  return {'tr': poolTr[idx], 'en': poolEn[idx]};
}

/// Günlük ritüel önerisi — elementlere ve kartlara göre
RitualSuggestion _generateRitualSuggestion(ElementAnalysis elements, FlowType flow) {
  final rng = Random();

  final rituals = <Map<String, String>>[];

  switch (elements.dominantElement) {
    case 'Ateş':
      rituals.addAll([
        {'titleTr': 'Cesaret Ritüeli', 'titleEn': 'Courage Ritual', 'actionTr': 'Bugün bir kırmızı mum yak ve alevine bakarak cesaretini çağır. 3 dakika boyunca korkularını aleve ver.', 'actionEn': 'Light a red candle today and summon your courage by gazing at its flame. Give your fears to the fire for 3 minutes.', 'emoji': '🕯️'},
        {'titleTr': 'Aksiyon Adımı', 'titleEn': 'Action Step', 'actionTr': 'Bugün ertelediğin bir şeyi yap. Ne kadar küçük olursa olsun, harekete geç. Ateş enerjin seni destekliyor.', 'actionEn': 'Do something you\'ve been postponing today. No matter how small, take action. Your fire energy supports you.', 'emoji': '⚡'},
      ]);
      break;
    case 'Su':
      rituals.addAll([
        {'titleTr': 'Duygu Arınması', 'titleEn': 'Emotional Cleanse', 'actionTr': 'Bugün bir bardak suya niyetini fısılda ve yavaşça iç. Her yudumda duygularını temizle.', 'actionEn': 'Whisper your intention into a glass of water today and slowly drink it. Cleanse your emotions with each sip.', 'emoji': '🌊'},
        {'titleTr': 'İç Ses Meditasyonu', 'titleEn': 'Inner Voice Meditation', 'actionTr': 'Gözlerini kapat, 5 derin nefes al. İç sesinin sana ne söylediğini dinle. Su enerjin sezgilerini güçlendiriyor.', 'actionEn': 'Close your eyes, take 5 deep breaths. Listen to what your inner voice tells you. Your water energy strengthens intuition.', 'emoji': '🧘'},
      ]);
      break;
    case 'Hava':
      rituals.addAll([
        {'titleTr': 'Düşünce Temizliği', 'titleEn': 'Thought Cleanse', 'actionTr': 'Bugün 5 dakika pencereyi aç ve temiz havayı ciğerlerine doldur. Her nefeste eski düşünceleri bırak, yenilere yer aç.', 'actionEn': 'Open a window for 5 minutes today and fill your lungs with fresh air. Release old thoughts with each breath, make room for new ones.', 'emoji': '🍃'},
        {'titleTr': 'Kelime Gücü', 'titleEn': 'Power of Words', 'actionTr': 'Bugün birine söylemek isteyip söyleyemediğin bir şeyi yaz. Göndermek zorunda değilsin, sadece yaz.', 'actionEn': 'Write something today that you wanted to say to someone but couldn\'t. You don\'t have to send it, just write.', 'emoji': '✍️'},
      ]);
      break;
    default: // Toprak
      rituals.addAll([
        {'titleTr': 'Topraklama Ritüeli', 'titleEn': 'Grounding Ritual', 'actionTr': 'Bugün çıplak ayaklarınla toprağa veya çimenliğe bas. 3 dakika boyunca ayaklarından yükselen enerjiyi hisset.', 'actionEn': 'Stand barefoot on earth or grass today. Feel the energy rising from your feet for 3 minutes.', 'emoji': '🌱'},
        {'titleTr': 'Sağlam Adım', 'titleEn': 'Solid Step', 'actionTr': 'Bugün uzun süredir planladığın pratik bir adımı at. Bir listeye yaz, organize et. Toprak enerjin seni destekliyor.', 'actionEn': 'Take a practical step you\'ve been planning for a while. Write a list, organize. Your earth energy supports you.', 'emoji': '📋'},
      ]);
      break;
  }

  final chosen = rituals[rng.nextInt(rituals.length)];
  return RitualSuggestion(
    titleTr: chosen['titleTr']!,
    titleEn: chosen['titleEn']!,
    actionTr: chosen['actionTr']!,
    actionEn: chosen['actionEn']!,
    emoji: chosen['emoji']!,
  );
}

/// Ana fonksiyon: 7 kart okuma üret
FullTarotReading generateFullReading({
  required List<int> cardIds,  // 7 kart ID
  required List<String> cardNames,  // 7 kart ismi
  required bool isTr,
}) {
  final rng = Random();
  
  // Kartların anlamlarını al (Minor Arcana için fallback)
  final meanings = cardIds.map((id) {
    if (cardMeanings.containsKey(id)) return cardMeanings[id]!;
    // Minor Arcana kartları için varsayılan anlamlar üret
    return _getMinorArcanaMeaning(id, isTr);
  }).toList();

  // Akış tipi (ilk 3 karttan belirlenir)
  final flowType = _detectFlowType(meanings[0], meanings[1], meanings[2]);
  final flowLabel = _flowLabel(flowType, isTr);

  // Genel tema
  final generalTheme = _buildFullGeneralTheme(meanings, cardNames, flowType, isTr);

  // 7 kart yorumu
  final positions = isTr ? _fullPositionsTr : _fullPositionsEn;
  final cardReadings = <FullCardReading>[];
  for (int i = 0; i < 7; i++) {
    cardReadings.add(FullCardReading(
      positionTitle: positions[i],
      content: _fullPositionReading(meanings[i], i, isTr, rng),
      cardName: cardNames[i],
      cardIndex: cardIds[i],
    ));
  }

  // Vaatler / Anahtar kelimeler (7 karttan)
  final allThemes = meanings.map((m) => (isTr ? m.themeTr : m.themeEn).split(',').map((s) => s.trim()).toList()).toList();
  allThemes.forEach((l) => l.shuffle(rng));
  final promises = <String>[];
  final used = <String>{};
  for (final themeList in allThemes) {
    for (final word in themeList) {
      if (!used.contains(word.toLowerCase())) {
        promises.add(word);
        used.add(word.toLowerCase());
        break;
      }
    }
    if (promises.length >= 5) break;
  }
  while (promises.length < 4) promises.add(isTr ? 'dönüşüm' : 'transformation');

  // Tavsiye paragrafı
  final adviceParagraph = _buildFullAdvice(meanings, cardNames, flowType, isTr);

  // Kapanış mesajı
  final closingMessage = _buildFullClosing(promises, flowType, isTr);

  // ── Premium analizler ──
  final elementAnalysis = _analyzeElements(meanings);
  final cardRelations = _analyzeCardRelations(meanings, cardNames, isTr);
  final cosmicData = _calculateCosmicScore(meanings, flowType);
  final secretMsg = _generateSecretMessage(meanings, cardNames, flowType, isTr);
  final ritual = _generateRitualSuggestion(elementAnalysis, flowType);

  return FullTarotReading(
    generalTheme: generalTheme,
    cardReadings: cardReadings,
    adviceParagraph: adviceParagraph,
    closingMessage: closingMessage,
    flowType: flowType,
    flowLabel: flowLabel,
    promises: promises,
    elementAnalysis: elementAnalysis,
    cardRelations: cardRelations,
    cosmicScore: cosmicData['score'] as int,
    cosmicLabelTr: cosmicData['labelTr'] as String,
    cosmicLabelEn: cosmicData['labelEn'] as String,
    secretMessageTr: secretMsg['tr']!,
    secretMessageEn: secretMsg['en']!,
    ritualSuggestion: ritual,
  );
}

// ============================================================
// Minor Arcana Kart Anlamları (Generic)
// ============================================================

/// Minor Arcana suit bilgisi
(String suitTr, String suitEn, CardTone tone, CardMovement mov) _minorSuitInfo(int id) {
  if (id >= 22 && id < 36) return ('Kupalar', 'Cups', CardTone.soft, CardMovement.stillness);
  if (id >= 36 && id < 50) return ('Asalar', 'Wands', CardTone.decision, CardMovement.motion);
  if (id >= 50 && id < 64) return ('Kılıçlar', 'Swords', CardTone.heavy, CardMovement.motion);
  return ('Sikkeler', 'Pentacles', CardTone.decision, CardMovement.stillness);
}

/// Minor Arcana rank bilgisi
(String rankTr, String rankEn) _minorRankInfo(int id) {
  final inSuit = (id - 22) % 14;
  switch (inSuit) {
    case 0: return ('As', 'Ace');
    case 1: return ('İki', 'Two');
    case 2: return ('Üç', 'Three');
    case 3: return ('Dört', 'Four');
    case 4: return ('Beş', 'Five');
    case 5: return ('Altı', 'Six');
    case 6: return ('Yedi', 'Seven');
    case 7: return ('Sekiz', 'Eight');
    case 8: return ('Dokuz', 'Nine');
    case 9: return ('On', 'Ten');
    case 10: return ('Şövalye', 'Page');
    case 11: return ('Süvari', 'Knight');
    case 12: return ('Kraliçe', 'Queen');
    default: return ('Kral', 'King');
  }
}

/// Minor Arcana kartı için otomatik anlam üret
CardMeaning _getMinorArcanaMeaning(int id, bool isTr) {
  final (suitTr, suitEn, tone, mov) = _minorSuitInfo(id);
  final (rankTr, rankEn) = _minorRankInfo(id);
  final inSuit = (id - 22) % 14;

  // Suit'e göre temel temalar
  Map<String, List<String>> suitThemesTr = {
    'Kupalar': ['Duygular, sevgi, ilişkiler', 'İç huzur, empati, bağlılık', 'Sezgi, hayal gücü, şefkat'],
    'Asalar': ['Tutku, enerji, motivasyon', 'Yaratıcılık, cesaret, girişim', 'İlham, irade, büyüme'],
    'Kılıçlar': ['Zihin, doğruluk, mücadele', 'Karar, netlik, zorluk', 'Analiz, strateji, yüzleşme'],
    'Sikkeler': ['Maddi dünya, bolluk, pratiklik', 'Güvenlik, çalışkanlık, başarı', 'Zenginlik, sağlık, istikrar'],
  };
  Map<String, List<String>> suitThemesEn = {
    'Cups': ['Emotions, love, relationships', 'Inner peace, empathy, devotion', 'Intuition, imagination, compassion'],
    'Wands': ['Passion, energy, motivation', 'Creativity, courage, enterprise', 'Inspiration, willpower, growth'],
    'Swords': ['Mind, truth, struggle', 'Decision, clarity, challenge', 'Analysis, strategy, confrontation'],
    'Pentacles': ['Material world, abundance, practicality', 'Security, diligence, achievement', 'Wealth, health, stability'],
  };

  final rng = Random(id); // Sabit seed ile tutarlı sonuçlar
  final themeListTr = suitThemesTr[suitTr] ?? ['Enerji, denge, hareket'];
  final themeListEn = suitThemesEn[suitEn] ?? ['Energy, balance, movement'];
  final themeTr = themeListTr[rng.nextInt(themeListTr.length)];
  final themeEn = themeListEn[rng.nextInt(themeListEn.length)];

  // Rank'a göre faz
  CardPhase phase;
  if (inSuit == 0) phase = CardPhase.beginning;
  else if (inSuit == 9) phase = CardPhase.completion;
  else if (inSuit >= 4 && inSuit <= 6) phase = CardPhase.neutral;
  else if (inSuit >= 10) phase = CardPhase.awakening;
  else phase = CardPhase.neutral;

  // Suit + Rank bazlı yorumlar
  final pastTr = '$rankTr $suitTr geçmişte sana güçlü bir enerji taşıdı. Bu suit\'in özü olan ${themeTr.split(',').first.toLowerCase()} seni derinden etkiledi.';
  final pastEn = '$rankEn of $suitEn carried powerful energy to your past. The essence of this suit — ${themeEn.split(',').first.toLowerCase()} — deeply influenced you.';
  final presentTr = 'Şu an $rankTr $suitTr enerjisi seni sarıyor. ${themeTr.split(',').last.trim()} hayatının her alanında kendini hissettiriyor.';
  final presentEn = 'Right now, the energy of $rankEn of $suitEn surrounds you. ${themeEn.split(',').last.trim()} makes itself felt in every area of your life.';
  final directionTr = '$rankTr $suitTr sana yol gösteriyor: ${themeTr.split(',')[1].trim().toLowerCase()} ile hareket et. Bu kartın bilgeliği seni doğru yöne çekiyor.';
  final directionEn = '$rankEn of $suitEn guides your way: move with ${themeEn.split(',')[1].trim().toLowerCase()}. This cards wisdom pulls you in the right direction.';

  return CardMeaning(
    id: id,
    themeTr: themeTr,
    themeEn: themeEn,
    tone: tone,
    movement: mov,
    phase: phase,
    pastTr: pastTr,
    pastEn: pastEn,
    presentTr: presentTr,
    presentEn: presentEn,
    directionTr: directionTr,
    directionEn: directionEn,
  );
}
