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
