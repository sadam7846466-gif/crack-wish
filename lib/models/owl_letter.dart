
class OwlLetter {
  final String id;
  final String contentTr;
  final String contentEn;
  final bool fromOwl; // true = baykuştan gelen, false = kullanıcının yazdığı
  final DateTime createdAt;
  final DateTime? openAt; // Geleceğe mektup için açılma tarihi
  final bool isRead;

  OwlLetter({
    required this.id,
    required this.contentTr,
    required this.contentEn,
    required this.fromOwl,
    required this.createdAt,
    this.openAt,
    this.isRead = false,
  });

  String content(String locale) => locale == 'tr' ? contentTr : contentEn;

  OwlLetter copyWith({bool? isRead}) {
    return OwlLetter(
      id: id,
      contentTr: contentTr,
      contentEn: contentEn,
      fromOwl: fromOwl,
      createdAt: createdAt,
      openAt: openAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contentTr': contentTr,
        'contentEn': contentEn,
        'fromOwl': fromOwl,
        'createdAt': createdAt.toIso8601String(),
        'openAt': openAt?.toIso8601String(),
        'isRead': isRead,
      };

  factory OwlLetter.fromJson(Map<String, dynamic> json) => OwlLetter(
        id: json['id'] as String,
        contentTr: json['contentTr'] as String,
        contentEn: json['contentEn'] as String,
        fromOwl: json['fromOwl'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        openAt: json['openAt'] != null
            ? DateTime.parse(json['openAt'] as String)
            : null,
        isRead: json['isRead'] as bool? ?? false,
      );
}

/// Baykuşun getirdiği ilham mektupları havuzu
class OwlLetterPool {
  static const List<Map<String, String>> letters = [
    {
      'tr': 'Bugün sana bir sır vereyim: Şans, cesaretini gördükçe seni daha çok buluyor. Küçük bir adım at, gerisini ben hallederim. 🦉',
      'en': 'Here\'s a secret: Luck finds you more when it sees your courage. Take a small step, I\'ll handle the rest. 🦉',
    },
    {
      'tr': 'Yıldızlar bu gece senin için hizalandı. Ama unutma, en parlak yıldız kendi içinde. Bugün kendine inan. ✨',
      'en': 'The stars aligned for you tonight. But remember, the brightest star is within you. Believe in yourself today. ✨',
    },
    {
      'tr': 'Rüzgâr değişiyor, hissediyor musun? Yeni bir başlangıç kapında. Gözlerini aç ve fırsatı yakala. 🌬️',
      'en': 'The wind is changing, can you feel it? A new beginning is at your door. Open your eyes and seize the opportunity. 🌬️',
    },
    {
      'tr': 'Bazen en güzel mektuplar sessizce gelir. Bu da onlardan biri. Bugün sakin ol, her şey yolunda. 💌',
      'en': 'Sometimes the most beautiful letters arrive quietly. This is one of them. Be calm today, everything is fine. 💌',
    },
    {
      'tr': 'Gecenin en karanlık anı, şafaktan hemen öncedir. Eğer zorluk yaşıyorsan, ışık çok yakın. 🌅',
      'en': 'The darkest moment of the night is just before dawn. If you\'re struggling, the light is very close. 🌅',
    },
    {
      'tr': 'Sana uzak diyarlardan haber getirdim: Sevdiklerin seni düşünüyor. Bugün birine güzel bir söz söyle. 💕',
      'en': 'I brought you news from distant lands: Your loved ones are thinking of you. Say something kind to someone today. 💕',
    },
    {
      'tr': 'Bilgelik her zaman büyük kitaplarda bulunmaz. Bazen bir baykuşun mektubunda gizlidir: Bugün sabırlı ol. 📖',
      'en': 'Wisdom isn\'t always found in big books. Sometimes it\'s hidden in an owl\'s letter: Be patient today. 📖',
    },
    {
      'tr': 'Ay bu gece parlak. Bu enerjiyi kullan, hayallerini düşün ve bir dilek tut. Evren dinliyor. 🌙',
      'en': 'The moon is bright tonight. Use this energy, think of your dreams and make a wish. The universe is listening. 🌙',
    },
    {
      'tr': 'Uzun zamandır taşıdığın bir yük var, biliyorum. Bugün onu bırakmana izin ver. Özgürlük seni bekliyor. 🕊️',
      'en': 'You\'ve been carrying a burden for a long time, I know. Allow yourself to let it go today. Freedom awaits you. 🕊️',
    },
    {
      'tr': 'Her gün bir mucize. Bugün gözlerini aç ve etrafındaki küçük güzellikleri fark et. Şükret. 🌸',
      'en': 'Every day is a miracle. Open your eyes today and notice the small beauties around you. Be grateful. 🌸',
    },
    {
      'tr': 'Kanatlarımla dünyayı dolaştım ve şunu öğrendim: En büyük hazine, kendini tanımaktır. Bugün içine bak. 🗝️',
      'en': 'I traveled the world with my wings and learned this: The greatest treasure is knowing yourself. Look within today. 🗝️',
    },
    {
      'tr': 'Bugün bir kapı kapanırsa üzülme. Ben sana pencereden girdim, değil mi? Yeni yollar açılacak. 🚪',
      'en': 'Don\'t be sad if a door closes today. I came through the window, didn\'t I? New paths will open. 🚪',
    },
    {
      'tr': 'Sana bir sır daha: Gülümsemen bulaşıcı. Bugün birine gülümse, zincirleme bir mutluluk başlat. 😊',
      'en': 'Another secret: Your smile is contagious. Smile at someone today and start a chain of happiness. 😊',
    },
    {
      'tr': 'Dün geçti, yarın henüz gelmedi. Elinde sadece bugün var. Onu değerli kıl. ⏳',
      'en': 'Yesterday is gone, tomorrow hasn\'t come yet. You only have today. Make it precious. ⏳',
    },
    {
      'tr': 'Gece uçuşlarımda seni gördüm. Uyurken bile güçlüsün. Bu güce güven, bugün harikalar yaratabilirsin. 💪',
      'en': 'I saw you during my night flights. You\'re strong even in your sleep. Trust this strength, you can create wonders today. 💪',
    },
    {
      'tr': 'Doğa hiç acele etmez, ama her şeyi başarır. Sen de kendine zaman tanı. Mükemmellik sabırla gelir. 🌿',
      'en': 'Nature never hurries, yet accomplishes everything. Give yourself time too. Perfection comes with patience. 🌿',
    },
    {
      'tr': 'Bu mektupla sana bir parça ay ışığı gönderiyorum. Karanlıkta bile yolunu bulacaksın. 🌟',
      'en': 'With this letter, I\'m sending you a piece of moonlight. You\'ll find your way even in the dark. 🌟',
    },
    {
      'tr': 'Bilge bir baykuş olarak söylüyorum: Hata yapmaktan korkma. Her hata, bir bilgelik tohumu taşır. 🌱',
      'en': 'As a wise owl, I tell you: Don\'t fear making mistakes. Every mistake carries a seed of wisdom. 🌱',
    },
    {
      'tr': 'Bugün senin günün. Bunu hisset, buna inan. Evren bugün senin yanında. 🎯',
      'en': 'Today is your day. Feel it, believe it. The universe is on your side today. 🎯',
    },
    {
      'tr': 'Kanatlarım yorulsa da sana mektup getirmeye devam edeceğim. Çünkü sen buna değersin. Her zaman. 💛',
      'en': 'Even if my wings get tired, I\'ll keep bringing you letters. Because you\'re worth it. Always. 💛',
    },
    {
      'tr': 'Ormandaki en yaşlı ağaç bile bir zamanlar küçük bir tohumdu. Büyük hayallerini küçümseme. 🌳',
      'en': 'Even the oldest tree in the forest was once a tiny seed. Don\'t underestimate your big dreams. 🌳',
    },
    {
      'tr': 'Sessizlik bazen en güçlü cevaptır. Bugün biraz sessizliğe izin ver, cevaplar seni bulacak. 🤫',
      'en': 'Silence is sometimes the most powerful answer. Allow some silence today, the answers will find you. 🤫',
    },
    {
      'tr': 'Bir nehir asla geriye akmaz. Sen de geçmişe takılma, ileriye bak. En güzel günlerin önünde. 🏞️',
      'en': 'A river never flows backward. Don\'t dwell on the past, look forward. Your best days are ahead. 🏞️',
    },
    {
      'tr': 'Bu gece sana rüyanda ipuçları bırakacağım. Yarın uyanınca ilk hissine güven. 🔮',
      'en': 'I\'ll leave clues in your dreams tonight. When you wake up tomorrow, trust your first feeling. 🔮',
    },
    {
      'tr': 'Sevgi vermek, sevgi almaktan daha büyük bir hediye. Bugün birine beklenmedik bir iyilik yap. 🎁',
      'en': 'Giving love is a greater gift than receiving it. Do an unexpected kindness for someone today. 🎁',
    },
    {
      'tr': 'Fırtınalar geçici, gökkuşakları kalıcıdır. Zorluklara diğer gözle bak, güzellik ortaya çıkar. 🌈',
      'en': 'Storms are temporary, rainbows are lasting. Look at difficulties differently, beauty will emerge. 🌈',
    },
    {
      'tr': 'Kalbinin sesini duyuyor musun? O sana doğru yolu gösteriyor. Bugün mantığı değil, kalbi dinle. ❤️',
      'en': 'Can you hear your heart? It\'s showing you the right path. Listen to your heart today, not just logic. ❤️',
    },
    {
      'tr': 'Bilgelik demek her şeyi bilmek değil, neyi bilmediğini bilmektir. Bugün yeni bir şey öğren. 🎓',
      'en': 'Wisdom doesn\'t mean knowing everything, but knowing what you don\'t know. Learn something new today. 🎓',
    },
    {
      'tr': 'Su gibi ol: Engellerin üzerinden değil, etrafından geç. Esneklik en büyük güç. 💧',
      'en': 'Be like water: Go around obstacles, not over them. Flexibility is the greatest strength. 💧',
    },
    {
      'tr': 'Bu mektubu aldığında gülümse. Çünkü evrenin sana gönderdiği bir işaret bu. İyi şeyler geliyor. 🦉✨',
      'en': 'Smile when you receive this letter. Because it\'s a sign the universe sent you. Good things are coming. 🦉✨',
    },
  ];
}
