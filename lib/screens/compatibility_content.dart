class CompatibilityContent {
  final String dynamicText;
  final String pros;
  final String cons;
  final String advice;

  CompatibilityContent({
    required this.dynamicText,
    required this.pros,
    required this.cons,
    required this.advice,
  });

  static CompatibilityContent get(String category, int pct) {
    bool high = pct >= 75;
    bool mid = pct >= 50 && pct < 75;

    if (category == 'love') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "✨ Venüs'ün kutsaması üzerinizde! Aranızdaki tutku ve romantik çekim, evrenin ender uyuşmalarından biri. Adeta ruh eşi potansiyeli taşıyan, kelimelere dökülemeyecek kadar derin bir çekiminiz var.",
          pros: "Karşılıklı yoğun arzu, saf şefkat ve birbirinin ruhunu okuyabilme yeteneği.",
          cons: "Tutkunun ve bağlılığın getirdiği aşırı kıskançlık veya kaybetme korkusu.",
          advice: "Bu büyülü kozmik enerjiyi koruyun ama aidiyet duygunuzu saplantıya dönüştürmeyin.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "🔥 Isınmaya ve tutuşmaya hazır bir bağ! İlk görüşte sizi sarsan bir patlama olmasa da, zamanla tıpkı iyi bir şarap gibi demlenerek güçlenecek sağlam bir sevgi altyapınız var.",
          pros: "Güven veren, mantıklı ve gerçekçi bir sevgi temeli.",
          cons: "Ortama bazen sıradanlığın çökmesi ve romantizm ateşinin sönmeye yüz tutması.",
          advice: "Aradaki ateşi harlamak için ilişkinize daha fazla spontan sürprizler ve bilinmezlik katın.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "🌧️ Aşk dili söz konusu olduğunda frekanslarınız farklı galaksilerde! Birinizin romantizm anlayışı, diğerinin duvarlarına çarpıp geri dönebiliyor.",
          pros: "Farklılıklardan doğabilecek çok ilginç kişisel keşifler ve gelişim alanı.",
          cons: "Duygusal ihtiyaçların uyuşmaması ve sürekli kendini açıklama yorgunluğu.",
          advice: "Birbirinizin beklentilerini yargılamadan dinleyin; herkes kendi bildiği dilde sever.",
        );
      }
    } else if (category == 'friend') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "🛡️ İşte gerçek bir yoldaşlık! Bu uyum, sırtınızı gözünüz kapalı yaslayabileceğiniz, yıllar geçse de paslanmayacak 'o efsane' dostluklardan biri olmaya aday.",
          pros: "Sarsılmaz güven, sıfır yargılama ve her koşulda destekleyici enerji.",
          cons: "Birlikte çok rahat olduğunuz için dış dünyadan kopup izole bir ikili olma riski.",
          advice: "Dostluğunuzun gücünü dışarıya da yayın, kapalı devre bir kulüpte kalmayın.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "☕ Güzel, seviyeli ve keyifli bir arkadaşlık. Birbirinizin sırdaşı olmaktan ziyade, iyi vakit geçirmeyi ve sosyal anları paylaşmayı çok iyi başarıyorsunuz.",
          pros: "Gereksiz dramalardan uzak, hafif ve pozitif bir arkadaşlık.",
          cons: "En derin yaraları veya büyük krizleri paylaşırken yüzeyde kalma ihtimali.",
          advice: "Bağınızı derinleştirmek için sıradan sohbetlerin ötesine geçip zaaflarınızı paylaşın.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "❄️ Belki de sadece tanıdık kalmalısınız... Karakterleriniz ve eğlendiğiniz şeyler o kadar farklı ki, uzun süreli bir dostluk her iki tarafı da yorabilir.",
          pros: "Size tamamen yabancı olan farklı bir yaşam tarzına pencere açması.",
          cons: "Anlaşmazlıkların sık yaşanması ve ortak paydada buluşma zorluğu.",
          advice: "Gereksiz yere birbirinizi değiştirmeye çalışmayın, aradaki mesafeye saygı duyun.",
        );
      }
    } else if (category == 'comm') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "🧠 Telepatik bir zihin uyumu! Cümlelerinizi birbiriniz tamamlıyor, saatlerce konuşsanız da sıkılmıyorsunuz. İletişiminiz adeta bir beyin fırtınası şöleni.",
          pros: "Fikirlerin havada uçuşması, çok derin, felsefi ve ufuk açıcı sohbetler.",
          cons: "Fazla düşünüp tartışmaktan bazen eyleme geçmeyi unutmak.",
          advice: "Bu harika zihinsel uyumu yaratıcı veya pratik bir projeye dönüştürün.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "🗣️ Mantıklı ve seviyeli bir diyalog. Genellikle ne demek istediğinizi birbirinize anlatabiliyorsunuz, ancak bazen aynı kelimelere farklı anlamlar yükleyebilirsiniz.",
          pros: "Saygılı sınırların korunduğu, yapıcı geri bildirimler içeren iletişim.",
          cons: "Zaman zaman detaylarda boğulup asıl duygusal alt metni kaçırma riski.",
          advice: "Sadece mantıkla değil, bazen sezgilerle ve duygularla konuşmayı deneyin.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "🔇 Adeta farklı dilleri konuşan iki rasyonele benziyorsunuz. İletişim kanallarınızda yoğun bir parazit var; birinizin 'beyaz' dediğini diğeri 'siyah' anlıyor olabilir.",
          pros: "Farklı düşünce yapılarını ve algı biçimlerini sabırla idare etmeyi öğrenmek.",
          cons: "Sürekli yanlış anlaşılmalar, tartışmaların kolayca kavgaya dönüşmesi.",
          advice: "Cevap vermek için dinlemeyin, gerçekten anlamak için dinleyin.",
        );
      }
    } else if (category == 'work') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "💼 Zirveye giden mükemmel takım! Birinizin güçlü yönü, diğerinin zaafını kapatıyor. Birlikte kuracağınız bir iş veya proje, tam bir başarı makinesine dönüşebilir.",
          pros: "Eksikleri kusursuz kapatma, tam odak odaklılık ve güçlü ortak hedefler.",
          cons: "Sürekli iş modunda kalıp ilişkinin diğer boyutlarını mekanikleştirmek.",
          advice: "Başarılarınızı kutlamayı ve arada işten tamamen uzaklaşmayı ihmal etmeyin.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "📊 İşler tıkırında, görevler tamam. Birlikte çalışırken iş bölümünü netleştirdiğiniz sürece gayet verimli ve profesyonel bir ikili oluyorsunuz.",
          pros: "Sınırların ve sorumlulukların belirgin olduğu dengeli ve güvenli işbirliği.",
          cons: "Görev tanımları dışında çıkan krizlerde kimin inisiyatif alacağında bocalama.",
          advice: "Kriz anları için önceden kurallar belirleyin ve esnemeyi öğrenin.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "🚧 Aynı gemide birbirinden farklı yönlere kürek çekmek. Çalışma yöntemleriniz, risk alma eşiğiniz ve çalışma saatleriniz bile bir kaos yaratabilir.",
          pros: "En zor koşullarda sınırlarınızı test edip ne kadar tahammüllü olabileceğinizi görmek.",
          cons: "Liderlik çekişmeleri, yöntem çatışmaları ve sinir patlamaları.",
          advice: "Görev güçlerini tamamen bağımsız alanlara ayırın, ortak karar almaktan kaçının.",
        );
      }
    } else if (category == 'fun') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "🎢 Mükemmel bir çılgınlık partneri! İkiniz de hayattan keyif almanın yolunu biliyor ve birlikteyken enerjinizle etrafa neşe saçıyorsunuz.",
          pros: "Birlikte çocuklaşabilme, sınırları keşfetme ve muazzam bir spontanlık.",
          cons: "Eğlenceye fazla kapılıp sorumlulukları ve gerçek dünyayı unutmak.",
          advice: "Maceraya Evet demeye devam edin, ancak ayağınızın biri her zaman yere basssın.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "🎬 Klasik ve keyifli bir senaryo. Tatil planlarınızda, hafta sonu etkinliklerinizde büyük bir uyumsuzluk yaşanmaz, güvenceli bir eğlence anlayışınız var.",
          pros: "Ne yapacağınızın hep belli olduğu, problemsiz ve sürprizsiz aktiviteler.",
          cons: "Sürekli aynı şeyleri yapmanın getirdiği potansiyel sıkılganlık ve döngü.",
          advice: "Arada bir daha önce hiç denemediğiniz 'çılgınca' kabul edilen bir etkinlik yapın.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "🛋️ Biriniz dağa tırmanmak isterken diğeriniz bütün hafta sonunu pijamalarla geçirmek istiyor. Eğlence ve dinlenme anlayışlarınız tam bir savaş alanı.",
          pros: "Kendi başınıza yapmaya cesaret edemeyeceğiniz şeylere zorlanma fırsatı.",
          cons: "Sürekli bir tarafın fedakarlık yapması veya ayrı takılmaktan doğan kopukluk.",
          advice: "Ayrı ayrı da kaliteli zaman geçirebileceğinizi kabullenin, birbirinizi zorlamayın.",
        );
      }
    }

    return CompatibilityContent(
      dynamicText: "Kozmik enerjileriniz birbiri etrafında dans ediyor.",
      pros: "Güçlü bir farkındalık.",
      cons: "Kısmi uyumsuzluklar.",
      advice: "İçgüdülerinizi izleyin.",
    );
  }
}
