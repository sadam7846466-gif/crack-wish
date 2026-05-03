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
          dynamicText: "Venüs'ün kutsaması üzerinizde! Aranızdaki tutku ve romantik çekim, evrenin ender uyuşmalarından biri. Adeta ruh eşi potansiyeli taşıyan, kelimelere dökülemeyecek kadar derin bir çekiminiz var.",
          pros: "Karşılıklı yoğun arzu, saf şefkat ve birbirinin ruhunu okuyabilme yeteneği.",
          cons: "Tutkunun ve bağlılığın getirdiği aşırı kıskançlık veya kaybetme korkusu.",
          advice: "Bu büyülü kozmik enerjiyi koruyun ama aidiyet duygunuzu saplantıya dönüştürmeyin.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "Isınmaya ve tutuşmaya hazır bir bağ! İlk görüşte sizi sarsan bir patlama olmasa da, zamanla tıpkı iyi bir şarap gibi demlenerek güçlenecek sağlam bir sevgi altyapınız var.",
          pros: "Güven veren, mantıklı ve gerçekçi bir sevgi temeli.",
          cons: "Ortama bazen sıradanlığın çökmesi ve romantizm ateşinin sönmeye yüz tutması.",
          advice: "Aradaki ateşi harlamak için ilişkinize daha fazla spontan sürprizler ve bilinmezlik katın.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Aşk dili söz konusu olduğunda frekanslarınız farklı galaksilerde! Birinizin romantizm anlayışı, diğerinin duvarlarına çarpıp geri dönebiliyor.",
          pros: "Farklılıklardan doğabilecek çok ilginç kişisel keşifler ve gelişim alanı.",
          cons: "Duygusal ihtiyaçların uyuşmaması ve sürekli kendini açıklama yorgunluğu.",
          advice: "Birbirinizin beklentilerini yargılamadan dinleyin; herkes kendi bildiği dilde sever.",
        );
      }
    } else if (category == 'friend') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "İşte gerçek bir yoldaşlık! Bu uyum, sırtınızı gözünüz kapalı yaslayabileceğiniz, yıllar geçse de paslanmayacak 'o efsane' dostluklardan biri olmaya aday.",
          pros: "Sarsılmaz güven, sıfır yargılama ve her koşulda destekleyici enerji.",
          cons: "Birlikte çok rahat olduğunuz için dış dünyadan kopup izole bir ikili olma riski.",
          advice: "Dostluğunuzun gücünü dışarıya da yayın, kapalı devre bir kulüpte kalmayın.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "Güzel, seviyeli ve keyifli bir arkadaşlık. Birbirinizin sırdaşı olmaktan ziyade, iyi vakit geçirmeyi ve sosyal anları paylaşmayı çok iyi başarıyorsunuz.",
          pros: "Gereksiz dramalardan uzak, hafif ve pozitif bir arkadaşlık.",
          cons: "En derin yaraları veya büyük krizleri paylaşırken yüzeyde kalma ihtimali.",
          advice: "Bağınızı derinleştirmek için sıradan sohbetlerin ötesine geçip zaaflarınızı paylaşın.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Belki de sadece tanıdık kalmalısınız... Karakterleriniz ve eğlendiğiniz şeyler o kadar farklı ki, uzun süreli bir dostluk her iki tarafı da yorabilir.",
          pros: "Size tamamen yabancı olan farklı bir yaşam tarzına pencere açması.",
          cons: "Anlaşmazlıkların sık yaşanması ve ortak paydada buluşma zorluğu.",
          advice: "Gereksiz yere birbirinizi değiştirmeye çalışmayın, aradaki mesafeye saygı duyun.",
        );
      }
    } else if (category == 'comm') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "Telepatik bir zihin uyumu! Cümlelerinizi birbiriniz tamamlıyor, saatlerce konuşsanız da sıkılmıyorsunuz. İletişiminiz adeta bir beyin fırtınası şöleni.",
          pros: "Fikirlerin havada uçuşması, çok derin, felsefi ve ufuk açıcı sohbetler.",
          cons: "Fazla düşünüp tartışmaktan bazen eyleme geçmeyi unutmak.",
          advice: "Bu harika zihinsel uyumu yaratıcı veya pratik bir projeye dönüştürün.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "Mantıklı ve seviyeli bir diyalog. Genellikle ne demek istediğinizi birbirinize anlatabiliyorsunuz, ancak bazen aynı kelimelere farklı anlamlar yükleyebilirsiniz.",
          pros: "Saygılı sınırların korunduğu, yapıcı geri bildirimler içeren iletişim.",
          cons: "Zaman zaman detaylarda boğulup asıl duygusal alt metni kaçırma riski.",
          advice: "Sadece mantıkla değil, bazen sezgilerle ve duygularla konuşmayı deneyin.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Adeta farklı dilleri konuşan iki rasyonele benziyorsunuz. İletişim kanallarınızda yoğun bir parazit var; birinizin 'beyaz' dediğini diğeri 'siyah' anlıyor olabilir.",
          pros: "Farklı düşünce yapılarını ve algı biçimlerini sabırla idare etmeyi öğrenmek.",
          cons: "Sürekli yanlış anlaşılmalar, tartışmaların kolayca kavgaya dönüşmesi.",
          advice: "Cevap vermek için dinlemeyin, gerçekten anlamak için dinleyin.",
        );
      }
    } else if (category == 'work') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "Zirveye giden mükemmel takım! Birinizin güçlü yönü, diğerinin zaafını kapatıyor. Birlikte kuracağınız bir iş veya proje, tam bir başarı makinesine dönüşebilir.",
          pros: "Eksikleri kusursuz kapatma, tam odak odaklılık ve güçlü ortak hedefler.",
          cons: "Sürekli iş modunda kalıp ilişkinin diğer boyutlarını mekanikleştirmek.",
          advice: "Başarılarınızı kutlamayı ve arada işten tamamen uzaklaşmayı ihmal etmeyin.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "İşler tıkırında, görevler tamam. Birlikte çalışırken iş bölümünü netleştirdiğiniz sürece gayet verimli ve profesyonel bir ikili oluyorsunuz.",
          pros: "Sınırların ve sorumlulukların belirgin olduğu dengeli ve güvenli işbirliği.",
          cons: "Görev tanımları dışında çıkan krizlerde kimin inisiyatif alacağında bocalama.",
          advice: "Kriz anları için önceden kurallar belirleyin ve esnemeyi öğrenin.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Aynı gemide birbirinden farklı yönlere kürek çekmek. Çalışma yöntemleriniz, risk alma eşiğiniz ve çalışma saatleriniz bile bir kaos yaratabilir.",
          pros: "En zor koşullarda sınırlarınızı test edip ne kadar tahammüllü olabileceğinizi görmek.",
          cons: "Liderlik çekişmeleri, yöntem çatışmaları ve sinir patlamaları.",
          advice: "Görev güçlerini tamamen bağımsız alanlara ayırın, ortak karar almaktan kaçının.",
        );
      }
    } else if (category == 'fun') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "Mükemmel bir çılgınlık partneri! İkiniz de hayattan keyif almanın yolunu biliyor ve birlikteyken enerjinizle etrafa neşe saçıyorsunuz.",
          pros: "Birlikte çocuklaşabilme, sınırları keşfetme ve muazzam bir spontanlık.",
          cons: "Eğlenceye fazla kapılıp sorumlulukları ve gerçek dünyayı unutmak.",
          advice: "Maceraya Evet demeye devam edin, ancak ayağınızın biri her zaman yere basssın.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "Klasik ve keyifli bir senaryo. Tatil planlarınızda, hafta sonu etkinliklerinizde büyük bir uyumsuzluk yaşanmaz, güvenceli bir eğlence anlayışınız var.",
          pros: "Ne yapacağınızın hep belli olduğu, problemsiz ve sürprizsiz aktiviteler.",
          cons: "Sürekli aynı şeyleri yapmanın getirdiği potansiyel sıkılganlık ve döngü.",
          advice: "Arada bir daha önce hiç denemediğiniz 'çılgınca' kabul edilen bir etkinlik yapın.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Biriniz dağa tırmanmak isterken diğeriniz bütün hafta sonunu pijamalarla geçirmek istiyor. Eğlence ve dinlenme anlayışlarınız tam bir savaş alanı.",
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

  static CompatibilityContent getAdvanced(String category, int pct) {
    bool high = pct >= 75;
    bool mid = pct >= 50 && pct < 75;

    if (category == 'karmic') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "İnanılmaz bir Karmik Düğüm! Ruhlarınız birbirini bu yaşamdan çok önce, bambaşka bir bedende tanıyordu. Karşılaşmanız tesadüf değil, evrenin eksik bir döngüyü tamamlama planı.",
          pros: "Nedepsiz bir güven hissi ve birbirinizin açık yara bantı olabilme yeteneği.",
          cons: "Geçmiş yaşamdan taşınan travmalar yüzünden sebepsiz korkular tetiklenebilir.",
          advice: "Birbirinize zaman verin; ruhlarınızın tamamen hizalanması için her şeyi kelimelere dökmeye çalışmayın.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "Hafif bir geçmiş yaşam kalıntısı! İkinizin enerjisi bir önceki döngüde çok kısa kesişmiş gibi hissediliyor. Burada yarım kalan bir dersi tamamlamak için tekrar bir araya geldiniz.",
          pros: "Bazen birbirinizi okurken hissettiğiniz o dejavu hissi.",
          cons: "Aralıklarla gelen anlamsız mesafelilik ve birbirini yanlış anlama potansiyeli.",
          advice: "İçinizdeki o ses 'bu kişiyi tanıyorum' diyorsa, ona güvenin ve yüzeye odaklanmayın.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Yeni Başlayanlar İçin Karma! Birbirinizin hayatında tamamen yepyenisiniz. Geçmiş bağlarınız yok, temiz bir sayfa açıp tamamen sıfırdan bir etki alanı oluşturuyorsunuz.",
          pros: "Geçmiş yüklerden veya karmik cezalardan tamamen arınmış özgür bir ilişki.",
          cons: "Bağ kurmak için doğal bir çekim yerine daha fazla efor ve yaşanmışlık gerekmesi.",
          advice: "Dünü boş verin, bu yaşamda birbirinize yepyeni ve temiz anılar hediye edin.",
        );
      }
    } else if (category == 'crisis') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "Fırtınanın İçi! Bir kriz anında, dünyadaki her şey çökse bile sırt sırta verip o kaostan sağ çıkacak harika bir savaşçı dinamiğine sahipsiniz.",
          pros: "Panik anında bir kişinin liderliği ele alıp diğerini mükemmel dengelemesi.",
          cons: "Kriz olmadığı zamanlarda savaşçı ruhun birbirinize yönelmesi riski.",
          advice: "Dışarıdaki savaşları aranızdaki bir meydan okumaya dönüştürmeyin.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "Dengeleyici ama Tedirgin! Kriz anlarında ikinizden biri fazlasıyla soğukkanlı olurken, diğeri paniğe kapılabilir. Zıtlıklar birbirini dengeliyor ama zorlukla.",
          pros: "Bir tarafın rasyonelliği ile diğerinin duygusal deşarjını yaşayabilmesi.",
          cons: "Panik anlarında aynı frekansta tepki verememenin getirdiği kısa süreli yabancılaşma.",
          advice: "Kriz anında sadece göz göze gelin, sözlerden çok frekanslarınıza güvenin.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Alarm Durumu! Bir kriz olduğunda adeta yanıcı bir gaza dönüşüyorsunuz ve birbirinizi sakinleştirmek yerine felaket senaryolarını büyütüyorsunuz.",
          pros: "Çok güçlü hisler yaşadığınız için hayatı uçlarda çok canlı hissetmeniz.",
          cons: "Birbirinizi paniğe sürükleyip en ufak sorunu büyük bir yangına çevirme eğilimi.",
          advice: "Kriz anlarında, çözüm aramadan önce birbirinizden kısa bir süre uzaklaşıp nefes alın.",
        );
      }
    } else if (category == 'telepathy') {
      if (high) {
        return CompatibilityContent(
          dynamicText: "Telepatik Ağ Aktif! Aynı anda aynı kelimeyi söylemek, tam mesaj atacakken mesaj almak... Sizin için iletişim kelimelere ihtiyaç duymuyor.",
          pros: "Susarken bile tamamen anlaşılmanın o mucizevi huzuru.",
          cons: "Nasıl olsa 'anlaşılıyorum' zannedip önemli şeyleri dile getirmeyi unutmak.",
          advice: "Telepatiye çok güvenmeyin; evrende hala 'Seni seviyorum' sözünü duymak iyidir.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "Kısmi Frekans! Bazen şaşırtıcı şekilde aynı şarkıyı aynı anda mırıldanabilirsiniz, ama çoğu zaman gerçek dünyadaki iletişim kanallarına bağımlısınız.",
          pros: "Günlük hayatta denk gelen eğlenceli tesadüflerle şaşırma fırastı.",
          cons: "Bazen birbirinizin zihnini okuduğunuzu sanarak yanlış genellemeler yapmak.",
          advice: "Sihre inanın ama yine de kelimelerle hislerinizi doğrulamayı ihmal etmeyin.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Cızırtılı Hat! Birbirinizin ne düşündüğünü asla tahmin edemiyorsunuz! Her mimik, her bakış bir gizem. Açık konuşmadıkça birbirinize uzaysı geleceksiniz.",
          pros: "Her gün yepyeni birini tanıyormuşsunuz hissinin getirdiği inanılmaz merak duygusu.",
          cons: "Gizemi yanlış yorumlamak ve 'artniyet' aramak.",
          advice: "Gizemleri çözmek için falcılara değil, açık uçlu sorulara odaklanın.",
        );
      }
    } else if (category == 'toxic') {
      // Toxic de yüksek yüzde = AZ toksik, düşük yüzde = ÇOK toksik olsun veya tam tersi.
      // Ekranda yüksek "Uyum" puanı görünce Toksikliğin AZ olduğunu varsayalım.
      if (high) {
        return CompatibilityContent(
          dynamicText: "Şifa Bağlantısı! Aranızda hiçbir zehir yok. İkinizin birleşimi, ruhsal olarak detoks etkisi yaratıyor. Kıskançlık, manipülasyon veya kontrol sınırlarınızdan geçemiyor.",
          pros: "Saf hisler, şeffaflık ve sağlıklı bir 'hayır' diyebilme özgürlüğü.",
          cons: "Gereğinden fazla politik olmaya çalışıp bazen tutkuyu azaltmak.",
          advice: "İlişkinizdeki bu doğal şifayı ve güven perdesini hiçbir şeyin delmesine izin vermeyin.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: "Tatlı Sert! Biraz inatlaşma, biraz tatlı pasif agresyon... Birbirinizi zaman zaman çok iyi manipüle edebiliyorsunuz ama günün sonunda ipin ucunu bırakıyorsunuz.",
          pros: "Küçük çatışmaların getirdiği tatlı heyecan ve akılda kalıcılık.",
          cons: "Bu ufak iğnelemelerin zamanla birikip zehire dönme ihtimali.",
          advice: "Oyunlarınızı sadece eğlenmek için oynayın, sınırları zorlamak güç savaşına dönüşmesin.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: "Nükleer Uyarı! İkinizin haritası yan yana geldiğinde, aşırı uç noktalara basıyor ve birbirinizin en sert sınırlarını ihlal ediyorsunuz. Bu etkileşim patlamaya meyilli.",
          pros: "Değişimi inanılmaz hızlandırması ve ruhsal olarak size en büyük derslerinizi vermesi.",
          cons: "Aşırı kıskançlık, ego savaşları veya tamamen birbirinin enerjisini emme hali.",
          advice: "Bu toksinleri birbirinizi yıpratmak için değil, kendinizdeki karanlık noktaları fark edip iyileştirmek için ayna niyetine kullanın.",
        );
      }
    }

    return get(category, pct);
  }
}
