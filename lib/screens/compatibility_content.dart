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

  static CompatibilityContent get(String category, int pct, {bool isTr = true}) {
    bool high = pct >= 75;
    bool mid = pct >= 50 && pct < 75;

    if (category == 'love') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Venüs'ün kutsaması üzerinizde! Aranızdaki tutku ve romantik çekim, evrenin ender uyuşmalarından biri. Adeta ruh eşi potansiyeli taşıyan, kelimelere dökülemeyecek kadar derin bir çekiminiz var."
              : "Venus's blessing is upon you! The passion and romantic attraction between you is one of the rare alignments of the universe. You have an attraction too deep for words, carrying soulmate potential.",
          pros: isTr
              ? "Karşılıklı yoğun arzu, saf şefkat ve birbirinin ruhunu okuyabilme yeteneği."
              : "Mutual intense desire, pure affection, and the ability to read each other's soul.",
          cons: isTr
              ? "Tutkunun ve bağlılığın getirdiği aşırı kıskançlık veya kaybetme korkusu."
              : "Extreme jealousy or fear of loss brought by passion and commitment.",
          advice: isTr
              ? "Bu büyülü kozmik enerjiyi koruyun ama aidiyet duygunuzu saplantıya dönüştürmeyin."
              : "Protect this magical cosmic energy, but do not turn your sense of belonging into an obsession.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Isınmaya ve tutuşmaya hazır bir bağ! İlk görüşte sizi sarsan bir patlama olmasa da, zamanla tıpkı iyi bir şarap gibi demlenerek güçlenecek sağlam bir sevgi altyapınız var."
              : "A bond ready to warm up and ignite! Although there is no explosive spark at first sight, you have a solid love foundation that will mature and strengthen over time, just like a good wine.",
          pros: isTr
              ? "Güven veren, mantıklı ve gerçekçi bir sevgi temeli."
              : "A reassuring, rational, and realistic foundation of love.",
          cons: isTr
              ? "Ortama bazen sıradanlığın çökmesi ve romantizm ateşinin sönmeye yüz tutması."
              : "Occasional mundane routine setting in and the fire of romance dying down.",
          advice: isTr
              ? "Aradaki ateşi harlamak için ilişkinize daha fazla spontan sürprizler ve bilinmezlik katın."
              : "To fan the flames, add more spontaneous surprises and mystery to your relationship.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Aşk dili söz konusu olduğunda frekanslarınız farklı galaksilerde! Birinizin romantizm anlayışı, diğerinin duvarlarına çarpıp geri dönebiliyor."
              : "When it comes to love language, your frequencies are in different galaxies! One's understanding of romance can bounce off the other's walls.",
          pros: isTr
              ? "Farklılıklardan doğabilecek çok ilginç kişisel keşifler ve gelişim alanı."
              : "Very interesting personal discoveries and growth areas that can arise from differences.",
          cons: isTr
              ? "Duygusal ihtiyaçların uyuşmaması ve sürekli kendini açıklama yorgunluğu."
              : "Mismatch of emotional needs and the fatigue of constantly explaining yourself.",
          advice: isTr
              ? "Birbirinizin beklentilerini yargılamadan dinleyin; herkes kendi bildiği dilde sever."
              : "Listen to each other's expectations without judgment; everyone loves in their own language.",
        );
      }
    } else if (category == 'friend') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "İşte gerçek bir yoldaşlık! Bu uyum, sırtınızı gözünüz kapalı yaslayabileceğiniz, yıllar geçse de paslanmayacak 'o efsane' dostluklardan biri olmaya aday."
              : "Here is a true companionship! This compatibility is candidate to be one of 'those legendary' friendships that you can lean on with your eyes closed and will not rust even if years pass.",
          pros: isTr
              ? "Sarsılmaz güven, sıfır yargılama ve her koşulda destekleyici enerji."
              : "Unshakeable trust, zero judgment, and supportive energy under all conditions.",
          cons: isTr
              ? "Birlikte çok rahat olduğunuz için dış dünyadan kopup izole bir ikili olma riski."
              : "Risk of isolating yourselves from the outer world because you are so comfortable together.",
          advice: isTr
              ? "Dostluğunuzun gücünü dışarıya da yayın, kapalı devre bir kulüpte kalmayın."
              : "Spread the power of your friendship to the outside, do not stay in a closed-circuit club.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Güzel, seviyeli ve keyifli bir arkadaşlık. Birbirinizin sırdaşı olmaktan ziyade, iyi vakit geçirmeyi ve sosyal anları paylaşmayı çok iyi başarıyorsunuz."
              : "A beautiful, respectful, and pleasant friendship. Rather than being each other's confidants, you succeed very well in having a good time and sharing social moments.",
          pros: isTr
              ? "Gereksiz dramalardan uzak, hafif ve pozitif bir arkadaşlık."
              : "A light and positive friendship, away from unnecessary drama.",
          cons: isTr
              ? "En derin yaraları veya büyük krizleri paylaşırken yüzeyde kalma ihtimali."
              : "The possibility of remaining on the surface when sharing the deepest wounds or major crises.",
          advice: isTr
              ? "Bağınızı derinleştirmek için sıradan sohbetlerin ötesine geçip zaaflarınızı paylaşın."
              : "To deepen your bond, go beyond ordinary conversations and share your vulnerabilities.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Belki de sadece tanıdık kalmalısınız... Karakterleriniz ve eğlendiğiniz şeyler o kadar farklı ki, uzun süreli bir dostluk her iki tarafı da yorabilir."
              : "Maybe you should just remain acquaintances... Your characters and the things you enjoy are so different that a long-term friendship can tire both sides.",
          pros: isTr
              ? "Size tamamen yabancı olan farklı bir yaşam tarzına pencere açması."
              : "Opening a window to a completely different lifestyle that is foreign to you.",
          cons: isTr
              ? "Anlaşmazlıkların sık yaşanması ve ortak paydada buluşma zorluğu."
              : "Frequent disagreements and difficulty finding common ground.",
          advice: isTr
              ? "Gereksiz yere birbirinizi değiştirmeye çalışmayın, aradaki mesafeye saygı duyun."
              : "Do not try to change each other unnecessarily, respect the distance between you.",
        );
      }
    } else if (category == 'comm') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Telepatik bir zihin uyumu! Cümlelerinizi birbiriniz tamamlıyor, saatlerce konuşsanız da sıkılmıyorsunuz. İletişiminiz adeta bir beyin fırtınası şöleni."
              : "A telepathic mind alignment! You complete each other's sentences, and you do not get bored even if you talk for hours. Your communication is like a brainstorming feast.",
          pros: isTr
              ? "Fikirlerin havada uçuşması, çok derin, felsefi ve ufuk açıcı sohbetler."
              : "Flying ideas, very deep, philosophical, and horizon-opening conversations.",
          cons: isTr
              ? "Fazla düşünüp tartışmaktan bazen eyleme geçmeyi unutmak."
              : "Sometimes forgetting to take action because of overthinking and discussing.",
          advice: isTr
              ? "Bu harika zihinsel uyumu yaratıcı veya pratik bir projeye dönüştürün."
              : "Turn this great mental harmony into a creative or practical project.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Mantıklı ve seviyeli bir diyalog. Genellikle ne demek istediğinizi birbirinize anlatabiliyorsunuz, ancak bazen aynı kelimelere farklı anlamlar yükleyebilirsiniz."
              : "A logical and respectful dialogue. You can usually explain what you mean to each other, but sometimes you can attach different meanings to the same words.",
          pros: isTr
              ? "Saygılı sınırların korunduğu, yapıcı geri bildirimler içeren iletişim."
              : "Communication containing constructive feedback, where respectful boundaries are preserved.",
          cons: isTr
              ? "Zaman zaman detaylarda boğulup asıl duygusal alt metni kaçırma riski."
              : "Risk of getting lost in details from time to time and missing the main emotional subtext.",
          advice: isTr
              ? "Sadece mantıkla değil, bazen sezgilerle ve duygularla konuşmayı deneyin."
              : "Try talking not only with logic, but sometimes with intuition and emotions.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Adeta farklı dilleri konuşan iki rasyonele benziyorsunuz. İletişim kanallarınızda yoğun bir parazit var; birinizin 'beyaz' dediğini diğeri 'siyah' anlıyor olabilir."
              : "You look like two rational people speaking different languages. There is intense static in your communication channels; what one calls 'white', the other might understand as 'black'.",
          pros: isTr
              ? "Farklı düşünce yapılarını ve algı biçimlerini sabırla idare etmeyi öğrenmek."
              : "Learning to patiently manage different thought structures and perception styles.",
          cons: isTr
              ? "Sürekli yanlış anlaşılmalar, tartışmaların kolayca kavgaya dönüşmesi."
              : "Constant misunderstandings, arguments easily turning into fights.",
          advice: isTr
              ? "Cevap vermek için dinlemeyin, gerçekten anlamak için dinleyin."
              : "Do not listen just to answer, listen to really understand.",
        );
      }
    } else if (category == 'work') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Zirveye giden mükemmel takım! Birinizin güçlü yönü, diğerinin zaafını kapatıyor. Birlikte kuracağınız bir iş veya proje, tam bir başarı makinesine dönüşebilir."
              : "The perfect team going to the top! The strength of one covers the weakness of the other. A business or project you establish together can turn into a complete success machine.",
          pros: isTr
              ? "Eksikleri kusursuz kapatma, tam odak odaklılık ve güçlü ortak hedefler."
              : "Perfect covering of deficiencies, complete focus orientation, and strong shared goals.",
          cons: isTr
              ? "Sürekli iş modunda kalıp ilişkinin diğer boyutlarını mekanikleştirmek."
              : "Remaining constantly in work mode and mechanizing other dimensions of the relationship.",
          advice: isTr
              ? "Başarılarınızı kutlamayı ve arada işten tamamen uzaklaşmayı ihmal etmeyin."
              : "Do not neglect to celebrate your achievements and get away from work completely once in a while.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "İşler tıkırında, görevler tamam. Birlikte çalışırken iş bölümünü netleştirdiğiniz sürece gayet verimli ve profesyonel bir ikili oluyorsunuz."
              : "Things are on track, tasks are complete. As long as you clarify the division of labor while working together, you become a very efficient and professional duo.",
          pros: isTr
              ? "Sınırların ve sorumlulukların belirgin olduğu dengeli ve güvenli işbirliği."
              : "Balanced and secure cooperation with clear boundaries and responsibilities.",
          cons: isTr
              ? "Görev tanımları dışında çıkan krizlerde kimin inisiyatif alacağında bocalama."
              : "Fumbling over who will take initiative in crises that go beyond job descriptions.",
          advice: isTr
              ? "Kriz anları için önceden kurallar belirleyin ve esnemeyi öğrenin."
              : "Set rules in advance for moments of crisis and learn to bend.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Aynı gemide birbirinden farklı yönlere kürek çekmek. Çalışma yöntemleriniz, risk alma eşiğiniz ve çalışma saatleriniz bile bir kaos yaratabilir."
              : "Rowing in different directions in the same boat. Your working methods, risk tolerance, and even working hours can create chaos.",
          pros: isTr
              ? "En zor koşullarda sınırlarınızı test edip ne kadar tahammüllü olabileceğinizi görmek."
              : "Testing your boundaries in the most difficult conditions to see how tolerant you can be.",
          cons: isTr
              ? "Liderlik çekişmeleri, yöntem çatışmaları ve sinir patlamaları."
              : "Leadership clashes, method conflicts, and temper tantrums.",
          advice: isTr
              ? "Görev güçlerini tamamen bağımsız alanlara ayırın, ortak karar almaktan kaçının."
              : "Separate the task areas into completely independent fields, avoid taking joint decisions.",
        );
      }
    } else if (category == 'fun') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Mükemmel bir çılgınlık partneri! İkiniz de hayattan keyif almanın yolunu biliyor ve birlikteyken enerjinizle etrafa neşe saçıyorsunuz."
              : "A perfect craziness partner! Both of you know how to enjoy life and when together, you radiate joy around with your energy.",
          pros: isTr
              ? "Birlikte çocuklaşabilme, sınırları keşfetme ve muazzam bir spontanlık."
              : "Being able to child play together, explore boundaries, and immense spontaneity.",
          cons: isTr
              ? "Eğlenceye fazla kapılıp sorumlulukları ve gerçek dünyayı unutmak."
              : "Getting too carried away with fun and forgetting responsibilities and the real world.",
          advice: isTr
              ? "Maceraya Evet demeye devam edin, ancak ayağınızın biri her zaman yere basssın."
              : "Keep saying Yes to adventure, but always keep one foot on the ground.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Klasik ve keyifli bir senaryo. Tatil planlarınızda, hafta sonu etkinliklerinizde büyük bir uyumsuzluk yaşanmaz, güvenceli bir eğlence anlayışınız var."
              : "A classic and pleasant scenario. No major mismatch is experienced in your holiday plans or weekend activities; you have a safe understanding of entertainment.",
          pros: isTr
              ? "Ne yapacağınızın hep belli olduğu, problemsiz ve sürprizsiz aktiviteler."
              : "Problem-free and surprise-free activities where what you will do is always known.",
          cons: isTr
              ? "Sürekli aynı şeyleri yapmanın getirdiği potansiyel sıkılganlık ve döngü."
              : "Potential boredom and loop brought by doing the same things constantly.",
          advice: isTr
              ? "Arada bir daha önce hiç denemediğiniz 'çılgınca' kabul edilen bir etkinlik yapın."
              : "Once in a while, do an activity considered 'crazy' that you have never tried before.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Biriniz dağa tırmanmak isterken diğeriniz bütün hafta sonunu pijamalarla geçirmek istiyor. Eğlence ve dinlenme anlayışlarınız tam bir savaş alanı."
              : "While one of you wants to climb a mountain, the other wants to spend the whole weekend in pajamas. Your understanding of entertainment and rest is a complete battlefield.",
          pros: isTr
              ? "Kendi başınıza yapmaya cesaret edemeyeceğiniz şeylere zorlanma fırsatı."
              : "Opportunity to be forced into things you wouldn't dare to do on your own.",
          cons: isTr
              ? "Sürekli bir tarafın fedakarlık yapması veya ayrı takılmaktan doğan kopukluk."
              : "Constant sacrifice of one side or disconnect arising from hanging out separately.",
          advice: isTr
              ? "Ayrı ayrı da kaliteli zaman geçirebileceğinizi kabullenin, birbirinizi zorlamayın."
              : "Accept that you can also spend quality time separately, do not force each other.",
        );
      }
    }

    return CompatibilityContent(
      dynamicText: isTr
          ? "Kozmik enerjileriniz birbiri etrafında dans ediyor."
          : "Your cosmic energies are dancing around each other.",
      pros: isTr ? "Güçlü bir farkındalık." : "Strong awareness.",
      cons: isTr ? "Kısmi uyumsuzluklar." : "Partial mismatches.",
      advice: isTr ? "İçgüdülerinizi izleyin." : "Follow your instincts.",
    );
  }

  static CompatibilityContent getAdvanced(String category, int pct, {bool isTr = true}) {
    bool high = pct >= 75;
    bool mid = pct >= 50 && pct < 75;

    if (category == 'karmic') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "İnanılmaz bir Karmik Düğüm! Ruhlarınız birbirini bu yaşamdan çok önce, bambaşka bir bedende tanıyordu. Karşılaşmanız tesadüf değil, evrenin eksik bir döngüyü tamamlama planı."
              : "An incredible Karmic Knot! Your souls knew each other long before this life, in a completely different body. Your meeting is not a coincidence, but the universe's plan to complete an incomplete cycle.",
          pros: isTr
              ? "Nedepsiz bir güven hissi ve birbirinizin açık yara bantı olabilme yeteneği."
              : "A feeling of trust without reason, and the ability to be each other's open band-aid.",
          cons: isTr
              ? "Geçmiş yaşamdan taşınan travmalar yüzünden sebepsiz korkular tetiklenebilir."
              : "Reasonless fears can be triggered due to traumas carried from past lives.",
          advice: isTr
              ? "Birbirinize zaman verin; ruhlarınızın tamamen hizalanması için her şeyi kelimelere dökmeye çalışmayın."
              : "Give each other time; do not try to put everything into words for your souls to align completely.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Hafif bir geçmiş yaşam kalıntısı! İkinizin enerjisi bir önceki döngüde çok kısa kesişmiş gibi hissediliyor. Burada yarım kalan bir dersi tamamlamak için tekrar bir araya geldiniz."
              : "A slight past-life trace! Your energy feels like it crossed very briefly in the previous cycle. You came together again to complete a lesson left unfinished here.",
          pros: isTr
              ? "Bazen birbirinizi okurken hissettiğiniz o dejavu hissi."
              : "That déjà vu feeling you sometimes feel when reading each other.",
          cons: isTr
              ? "Aralıklarla gelen anlamsız mesafelilik ve birbirini yanlış anlama potansiyeli."
              : "Meaningless distance coming at intervals and potential to misunderstand each other.",
          advice: isTr
              ? "İçinizdeki o ses 'bu kişiyi tanıyorum' diyorsa, ona güvenin ve yüzeye odaklanmayın."
              : "If that voice inside says 'I know this person', trust it and do not focus on the surface.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Yeni Başlayanlar İçin Karma! Birbirinizin hayatında tamamen yepyenisiniz. Geçmiş bağlarınız yok, temiz bir sayfa açıp tamamen sıfırdan bir etki alanı oluşturuyorsunuz."
              : "Karma for Beginners! You are completely brand new in each other's lives. You have no past ties, you open a clean page and form a completely fresh sphere of influence from scratch.",
          pros: isTr
              ? "Geçmiş yüklerden veya karmik cezalardan tamamen arınmış özgür bir ilişki."
              : "A free relationship completely purified from past burdens or karmic punishments.",
          cons: isTr
              ? "Bağ kurmak için doğal bir çekim yerine daha fazla efor ve yaşanmışlık gerekmesi."
              : "Requiring more effort and shared experience instead of a natural attraction to build a bond.",
          advice: isTr
              ? "Dünü boş verin, bu yaşamda birbirinize yepyeni ve temiz anılar hediye edin."
              : "Forget yesterday, gift each other brand new and clean memories in this life.",
        );
      }
    } else if (category == 'crisis') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Fırtınanın İçi! Bir kriz anında, dünyadaki her şey çökse bile sırt sırta verip o kaostan sağ çıkacak harika bir savaşçı dinamiğine sahipsiniz."
              : "Inside the Storm! In a moment of crisis, even if everything in the world collapses, you have a great warrior dynamic to stand back-to-back and survive that chaos.",
          pros: isTr
              ? "Panik anında bir kişinin liderliği ele alıp diğerini mükemmel dengelemesi."
              : "One person taking the lead and perfectly balancing the other in moments of panic.",
          cons: isTr
              ? "Kriz olmadığı zamanlarda savaşçı ruhun birbirinize yönelmesi riski."
              : "The risk of the warrior spirit turning towards each other when there is no crisis.",
          advice: isTr
              ? "Dışarıdaki savaşları aranızdaki bir meydan okumaya dönüştürmeyin."
              : "Do not turn the wars outside into a challenge between you.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Dengeleyici ama Tedirgin! Kriz anlarında ikinizden biri fazlasıyla soğukkanlı olurken, diğeri paniğe kapılabilir. Zıtlıklar birbirini dengeliyor ama zorlukla."
              : "Balancing but Anxious! In moments of crisis, one of you can be extremely cool-headed while the other panics. Contrasts balance each other but with difficulty.",
          pros: isTr
              ? "Bir tarafın rasyonelliği ile diğerinin duygusal deşarjını yaşayabilmesi."
              : "A side's rationality allowing the other to live their emotional discharge.",
          cons: isTr
              ? "Panik anlarında aynı frekansta tepki verememenin getirdiği kısa süreli yabancılaşma."
              : "Short-term alienation brought by not being able to react on the same frequency in moments of panic.",
          advice: isTr
              ? "Kriz anında sadece göz göze gelin, sözlerden çok frekanslarınıza güvenin."
              : "In moments of crisis just lock eyes, trust your frequencies more than words.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Alarm Durumu! Bir kriz olduğunda adeta yanıcı bir gaza dönüşüyorsunuz ve birbirinizi sakinleştirmek yerine felaket senaryolarını büyütüyorsunuz."
              : "Alarm Status! When a crisis occurs, you almost turn into a flammable gas and blow up the disaster scenarios instead of calming each other down.",
          pros: isTr
              ? "Çok güçlü hisler yaşadığınız için hayatı uçlarda çok canlı hissetmeniz."
              : "Feeling life very vividly on the edge because you experience very strong feelings.",
          cons: isTr
              ? "Birbirinizi paniğe sürükleyip en ufak sorunu büyük bir yangına çevirme eğilimi."
              : "Tendency to drag each other into panic and turn the smallest problem into a big fire.",
          advice: isTr
              ? "Kriz anlarında, çözüm aramadan önce birbirinizden kısa bir süre uzaklaşıp nefes alın."
              : "In moments of crisis, get away from each other for a short time and take a breath before looking for a solution.",
        );
      }
    } else if (category == 'telepathy') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Telepatik Ağ Aktif! Aynı anda aynı kelimeyi söylemek, tam mesaj atacakken mesaj almak... Sizin için iletişim kelimelere ihtiyaç duymuyor."
              : "Telepathic Network Active! Saying the same word at the same time, receiving a message just when you are about to message... Communication for you does not need words.",
          pros: isTr
              ? "Susarken bile tamamen anlaşılmanın o mucizevi huzuru."
              : "That miraculous peace of being completely understood even while silent.",
          cons: isTr
              ? "Nasıl olsa 'anlaşılıyorum' zannedip önemli şeyleri dile getirmeyi unutmak."
              : "Forgetting to express important things by assuming 'I am understood anyway'.",
          advice: isTr
              ? "Telepatiye çok güvenmeyin; evrende hala 'Seni seviyorum' sözünü duymak iyidir."
              : "Do not trust telepathy too much; it is still good to hear 'I love you' in the universe.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Kısmi Frekans! Bazen şaşırtıcı şekilde aynı şarkıyı aynı anda mırıldanabilirsiniz, ama çoğu zaman gerçek dünyadaki iletişim kanallarına bağımlısınız."
              : "Partial Frequency! Sometimes you can hum the same song at the same time in a surprising way, but most of the time you are dependent on real-world communication channels.",
          pros: isTr
              ? "Günlük hayatta denk gelen eğlenceli tesadüflerle şaşırma fırastı."
              : "Opportunity to be surprised by fun coincidences matching in daily life.",
          cons: isTr
              ? "Bazen birbirinizin zihnini okuduğunuzu sanarak yanlış genellemeler yapmak."
              : "Making wrong generalizations by thinking you read each other's mind sometimes.",
          advice: isTr
              ? "Sihre inanın ama yine de kelimelerle hislerinizi doğrulamayı ihmal etmeyin."
              : "Believe in magic but still do not neglect to confirm your feelings with words.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Cızırtılı Hat! Birbirinizin ne düşündüğünü asla tahmin edemiyorsunuz! Her mimik, her bakış bir gizem. Açık konuşmadıkça birbirinize uzaysı geleceksiniz."
              : "Static Line! You can never guess what each other is thinking! Every gesture, every look is a mystery. Unless you speak openly, you will seem alien to each other.",
          pros: isTr
              ? "Her gün yepyeni birini tanıyormuşsunuz hissinin getirdiği inanılmaz merak duygusu."
              : "An incredible sense of curiosity brought by the feeling of getting to know someone brand new every day.",
          cons: isTr
              ? "Gizemi yanlış yorumlamak ve 'artniyet' aramak."
              : "Misinterpreting the mystery and looking for 'ill intent'.",
          advice: isTr
              ? "Gizemleri çözmek için falcılara değil, açık uçlu sorulara odaklanın."
              : "To solve mysteries, focus on open-ended questions, not fortune tellers.",
        );
      }
    } else if (category == 'toxic') {
      if (high) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Şifa Bağlantısı! Aranızda hiçbir zehir yok. İkinizin birleşimi, ruhsal olarak detoks etkisi yaratıyor. Kıskançlık, manipülasyon veya kontrol sınırlarınızdan geçemiyor."
              : "Healing Connection! There is no poison between you. The combination of the two of you creates a detox effect spiritually. Jealousy, manipulation, or control cannot pass through your borders.",
          pros: isTr
              ? "Saf hisler, şeffaflık ve sağlıklı bir 'hayır' diyebilme özgürlüğü."
              : "Pure feelings, transparency, and a healthy freedom to say 'no'.",
          cons: isTr
              ? "Gereğinden fazla politik olmaya çalışıp bazen tutkuyu azaltmak."
              : "Trying to be overly diplomatic and sometimes reducing the passion.",
          advice: isTr
              ? "İlişkinizdeki bu doğal şifayı ve güven perdesini hiçbir şeyin delmesine izin vermeyin."
              : "Do not let anything pierce this natural healing and trust shield in your relationship.",
        );
      } else if (mid) {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Tatlı Sert! Biraz inatlaşma, biraz tatlı pasif agresyon... Birbirinizi zaman zaman çok iyi manipüle edebiliyorsunuz ama günün sonunda ipin ucunu bırakıyorsunuz."
              : "Bitter Sweet! A little stubbornness, a little sweet passive-aggression... You can manipulate each other very well from time to time, but at the end of the day, you let go of the rope.",
          pros: isTr
              ? "Küçük çatışmaların getirdiği tatlı heyecan ve akılda kalıcılık."
              : "Sweet excitement and memorability brought by small conflicts.",
          cons: isTr
              ? "Bu ufak iğnelemelerin zamanla birikip zehire dönme ihtimali."
              : "Possibility of these small sarcasms accumulating over time and turning into poison.",
          advice: isTr
              ? "Oyunlarınızı sadece eğlenmek için oynayın, sınırları zorlamak güç savaşına dönüşmesin."
              : "Play your games only for fun, letting pushing boundaries not turn into a power struggle.",
        );
      } else {
        return CompatibilityContent(
          dynamicText: isTr
              ? "Nükleer Uyarı! İkinizin haritası yan yana geldiğinde, aşırı uç noktalara basıyor ve birbirinizin en sert sınırlarını ihlal ediyorsunuz. Bu etkileşim patlamaya meyilli."
              : "Nuclear Warning! When your charts come side-by-side, you step on extreme points and violate each other's harshest boundaries. This interaction is prone to explosion.",
          pros: isTr
              ? "Değişimi inanılmaz hızlandırması ve ruhsal olarak size en büyük derslerinizi vermesi."
              : "Accelerating change incredibly and giving you your greatest lessons spiritually.",
          cons: isTr
              ? "Aşırı kıskançlık, ego savaşları veya tamamen birbirinin enerjisini emme hali."
              : "Extreme jealousy, ego wars, or completely draining each other's energy.",
          advice: isTr
              ? "Bu toksinleri birbirinizi yıpratmak için değil, kendinizdeki karanlık noktaları fark edip iyileştirmek için ayna niyetine kullanın."
              : "Use these toxins not to wear each other out, but as a mirror to notice and heal the dark points in yourself.",
        );
      }
    }

    return get(category, pct, isTr: isTr);
  }
}
