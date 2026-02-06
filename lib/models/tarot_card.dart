class TarotCard {
  final String id;
  final String nameTr;
  final String nameEn;
  final String? assetPath;
  final String emoji;
  final String past;
  final String present;
  final String future;

  TarotCard({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    this.assetPath,
    required this.emoji,
    required this.past,
    required this.present,
    required this.future,
  });

  static List<TarotCard> getDeck() {
    return [
      // 0
      TarotCard(
        id: 'fool',
        nameTr: 'Aptal',
        nameEn: 'The Fool',
        assetPath: 'assets/images/tarot/(The Fool).png',
        emoji: '🃏',
        past: 'Geçmişte risk aldın, deneme yanılmaların oldu.',
        present: 'Şu anda yeni bir başlangıcın eşiğindesin, sezgine güven.',
        future: 'Yakında beklenmedik fırsatlar çıkacak, esnek kal.',
      ),
      // 1
      TarotCard(
        id: 'magician',
        nameTr: 'Büyücü',
        nameEn: 'The Magician',
        assetPath: 'assets/images/tarot/(The Magician).png',
        emoji: '🧙‍♂️',
        past: 'Geçmişte yaratıcı gücünü fark ettin.',
        present: 'Şu anda elindeki araçlar hedeflerin için yeterli.',
        future: 'Yakında fikirlerini gerçeğe dönüştürecek fırsatlar gelecek.',
      ),
      // 2
      TarotCard(
        id: 'high_priestess',
        nameTr: 'Başrahibe',
        nameEn: 'The High Priestess',
        assetPath: 'assets/images/tarot/(The High Priestess).png',
        emoji: '🕯️',
        past: 'Geçmişte iç sesine kulak vermen gerekti.',
        present: 'Şu anda sezgilerin güçlü, sakin kal ve gözlemle.',
        future: 'Yakında gizli bilgiler açığa çıkacak, sabırlı ol.',
      ),
      // 3
      TarotCard(
        id: 'empress',
        nameTr: 'İmparatoriçe',
        nameEn: 'The Empress',
        assetPath: 'assets/images/tarot/(The Empress).png',
        emoji: '👸',
        past: 'Geçmişte bereket ve üretkenlik dönemleri yaşadın.',
        present: 'Şu anda yaratıcılığın ve destekleyici enerjin yüksek.',
        future: 'Yakında projelerin meyve verecek, bolluk artacak.',
      ),
      // 4
      TarotCard(
        id: 'emperor',
        nameTr: 'İmparator',
        nameEn: 'The Emperor',
        assetPath: 'assets/images/tarot/(The Emperor).png',
        emoji: '🧿',
        past: 'Geçmişte düzen kurma ve sorumluluk alma devrindeydin.',
        present: 'Şu anda disiplin ve yapı başarıyı getirecek.',
        future: 'Yakında liderlik rolün güçlenecek, sağlam adım at.',
      ),
      // 5
      TarotCard(
        id: 'hierophant',
        nameTr: 'Başrahip',
        nameEn: 'The Hierophant',
        assetPath: 'assets/images/tarot/(The Hierophant).png',
        emoji: '📜',
        past: 'Geçmişte gelenekler ve öğrenme önemliydi.',
        present: 'Şu anda rehberlik alman ya da vermen gereken zaman.',
        future: 'Yakında bilgi ve inançlar üzerinden kararlar alacaksın.',
      ),
      // 6
      TarotCard(
        id: 'lovers',
        nameTr: 'Aşıklar',
        nameEn: 'The Lovers',
        assetPath: 'assets/images/tarot/(The Lovers).png',
        emoji: '❤️',
        past: 'Geçmişte ilişkilerde önemli seçimler yaptın.',
        present: 'Şu anda uyum ve değerler dengesini düşünüyorsun.',
        future: 'Yakında kalp ve akıl arasında net bir karar vereceksin.',
      ),
      // 7
      TarotCard(
        id: 'chariot',
        nameTr: 'Savaş Arabası',
        nameEn: 'The Chariot',
        assetPath: 'assets/images/tarot/(The Chariot).png',
        emoji: '🛡️',
        past: 'Geçmişte kararlılık gösterip ilerledin.',
        present: 'Şu anda kontrol sende; yönünü netleştir.',
        future: 'Yakında hızlanma ve zafer fırsatı doğacak.',
      ),
      // 8
      TarotCard(
        id: 'strength',
        nameTr: 'Güç',
        nameEn: 'Strength',
        assetPath: 'assets/images/tarot/(Strength).png',
        emoji: '🦁',
        past: 'Geçmişte sabır ve cesaret sınandı.',
        present: 'Şu anda sakin güç ve nezaketle ilerlemen gerek.',
        future: 'Yakında içsel gücünle zorlukları aşacaksın.',
      ),
      // 9
      TarotCard(
        id: 'hermit',
        nameTr: 'Münzevi',
        nameEn: 'The Hermit',
        assetPath: 'assets/images/tarot/(The Hermit).png',
        emoji: '🏔️',
        past: 'Geçmişte geri çekilip düşünmeye ihtiyaç duydun.',
        present: 'Şu anda içe dönüp ışığını bulma zamanı.',
        future: 'Yakında iç rehberliğinle yeni bir yol bulacaksın.',
      ),
      // 10
      TarotCard(
        id: 'wheel_of_fortune',
        nameTr: 'Kader Çarkı',
        nameEn: 'Wheel of Fortune',
        assetPath: 'assets/images/tarot/(Wheel of Fortune).png',
        emoji: '🎡',
        past: 'Geçmişte beklenmedik dönüşler yaşadın.',
        present: 'Şu anda döngü değişiyor; akışa uyum sağla.',
        future: 'Yakında şans senden yana dönecek, fırsatları yakala.',
      ),
      // 11
      TarotCard(
        id: 'justice',
        nameTr: 'Adalet',
        nameEn: 'Justice',
        assetPath: 'assets/images/tarot/(Justice).png',
        emoji: '⚖️',
        past: 'Geçmişte adil kararlar gündemindeydi.',
        present: 'Şu anda denge ve dürüstlük kritik.',
        future: 'Yakında hakkaniyet yerini bulacak, sonuçları göreceksin.',
      ),
      // 12
      TarotCard(
        id: 'hanged_man',
        nameTr: 'Asılan Adam',
        nameEn: 'The Hanged Man',
        assetPath: 'assets/images/tarot/(The Hanged Man).png',
        emoji: '🪢',
        past: 'Geçmişte beklemek ve fedakârlık yapmak zorunda kaldın.',
        present: 'Şu anda bakış açını değiştirmen gerekebilir.',
        future: 'Yakında duraksama sona erecek, yeni bir anlayış kazanacaksın.',
      ),
      // 13
      TarotCard(
        id: 'death',
        nameTr: 'Ölüm',
        nameEn: 'Death',
        assetPath: 'assets/images/tarot/(Death).png',
        emoji: '💀',
        past: 'Geçmişte bitişler seni dönüştürdü.',
        present: 'Şu anda kapanış ve arınma sürecindesin.',
        future: 'Yakında yeni bir başlangıç için yer açılacak.',
      ),
      // 14
      TarotCard(
        id: 'temperance',
        nameTr: 'Denge',
        nameEn: 'Temperance',
        assetPath: 'assets/images/tarot/(Temperance).png',
        emoji: '⚗️',
        past: 'Geçmişte aşırılıkları dengelemeye çalıştın.',
        present: 'Şu anda ölçülülük ve uyum arıyorsun.',
        future: 'Yakında sabır ve denge sayesinde istikrar bulacaksın.',
      ),
      // 15
      TarotCard(
        id: 'devil',
        nameTr: 'Şeytan',
        nameEn: 'The Devil',
        assetPath: 'assets/images/tarot/(The Devil).png',
        emoji: '😈',
        past: 'Geçmişte bağımlılık veya kısıtlayıcı kalıplar yaşadın.',
        present: 'Şu anda seni tutan bağları fark etmen gerek.',
        future: 'Yakında farkındalıkla bu bağları kırma şansı gelecek.',
      ),
      // 16
      TarotCard(
        id: 'tower',
        nameTr: 'Yıkılan Kule',
        nameEn: 'The Tower',
        assetPath: 'assets/images/tarot/(The Tower).png',
        emoji: '🏰',
        past: 'Geçmişte ani sarsıntılar yaşadın.',
        present: 'Şu anda beklenmedik bir değişim kapıda.',
        future: 'Yakında eski yapı yıkılıp yerine yenisi kurulacak.',
      ),
      // 17
      TarotCard(
        id: 'star',
        nameTr: 'Yıldız',
        nameEn: 'The Star',
        assetPath: 'assets/images/tarot/(The Star).png',
        emoji: '🌟',
        past: 'Geçmişte umut aradığın zor dönemler oldu.',
        present: 'Şu anda iyileşme ve umut enerjisi hakim.',
        future: 'Yakında ilham ve rehberlik bulacaksın.',
      ),
      // 18
      TarotCard(
        id: 'moon',
        nameTr: 'Ay',
        nameEn: 'The Moon',
        assetPath: 'assets/images/tarot/(The Moon).png',
        emoji: '🌙',
        past: 'Geçmişte belirsizlikler ve korkularla yüzleştin.',
        present: 'Şu anda sisli bir süreçtesin, sezgine güven.',
        future: 'Yakında gizli olan açığa çıkacak, netlik gelecek.',
      ),
      // 19
      TarotCard(
        id: 'sun',
        nameTr: 'Güneş',
        nameEn: 'The Sun',
        assetPath: 'assets/images/tarot/(The Sun).png',
        emoji: '☀️',
        past: 'Geçmişte başarı ve neşe dönemlerin oldu.',
        present: 'Şu anda canlılık ve bolluk enerjisi yükseliyor.',
        future: 'Yakında parlak bir dönem ve mutluluk seni bekliyor.',
      ),
      // 20
      TarotCard(
        id: 'judgement',
        nameTr: 'Mahkeme',
        nameEn: 'Judgement',
        assetPath: 'assets/images/tarot/(Judgement).png',
        emoji: '🎺',
        past: 'Geçmişte hesaplaşma veya yeniden değerlendirme yaşadın.',
        present: 'Şu anda çağrıyı duyman ve harekete geçmen gerek.',
        future: 'Yakında önemli bir uyanış ve karar aşaması gelecek.',
      ),
      // 21
      TarotCard(
        id: 'world',
        nameTr: 'Dünya',
        nameEn: 'The World',
        assetPath: 'assets/images/tarot/(The World).png',
        emoji: '🌍',
        past: 'Geçmişte döngüleri tamamlayıp olgunlaştın.',
        present: 'Şu anda tamamlama ve bütünlük enerjisindesin.',
        future: 'Yakında büyük bir tamamlanma ve yeni bir döngü başlayacak.',
      ),
    ];
  }
}
