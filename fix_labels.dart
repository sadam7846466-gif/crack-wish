import 'dart:io';

void main() {
  File file = File('lib/screens/tarot_meanings.dart');
  String content = file.readAsStringSync();

  final Map<String, String> replacements = {
    "'Evren sana yol gösteriyor'": "'Evrenin yol göstericiliği'",
    "'Ektiğin sevgi geri dönüyor'": "'Geri dönen sevgin'",
    "'Verdiğin kat kat geri geliyor'": "'Geri dönen emeklerin'",
    "'Bolluk bereket seninle'": "'Seninle olan bolluk'",
    "'Üretkenliğin çiçek açar'": "'Çiçek açan üretkenliğin'",
    "'Dişil enerjini kucakla'": "'Kucaklanan dişil enerjin'",
    "'Zarafetinle koruyorsun'": "'Koruyan zarafetin'",
    "'Kalbinle liderlik et'": "'Kalpten gelen liderliğin'",
    "'Güç ve sevgi birleşiyor'": "'Birleşen güç ve sevgin'",
    "'Rehberliğe kulak ver'": "'Dinlenen rehberliğin'",
    "'Yıldızlar sana bakıyor'": "'Sana bakan yıldızlar'",
    "'Kaderin seni çağırıyor'": "'Seni çağıran kaderin'",
    "'Cevap dışarıda değil'": "'İçindeki cevaplar'",
    "'Sessizlikte bilgelik var'": "'Sessizlikteki bilgeliğin'",
    "'Yaşadıkların seni bilge yaptı'": "'Seni bilge yapan deneyimlerin'",
    "'Geçmişin değerlendiriliyor'": "'Değerlendirilen geçmişin'",
    "'Bırakmak kazanmaktır'": "'Kazandıran teslimiyetin'",
    "'Kontrol yanılsamasını bırak'": "'Bırakılan kontrol yanılsaman'",
    "'Değişim kaçınılmaz'": "'Kaçınılmaz değişimin'",
    "'Bitiş aslında doğuş'": "'Doğuş olan bitişin'",
    "'Kapanan kapı yeni yol açar'": "'Açılan yeni yolların'",
    "'Alışkanlıklarını bırak'": "'Bırakılan alışkanlıkların'",
    "'Yeni kurallar geliyor'": "'Gelen yeni kuralların'",
    "'Korkularla yüzleşme zamanı'": "'Korkularla yüzleşmen'",
    "'Gerçeǧe bakma cesareti'": "'Gerçeğe bakan cesaretin'",
    "'Özgürlük cesaret ister'": "'Cesaret isteyen özgürlüğün'",
    "'Işık sana yöneliyor'": "'Sana yönelen ışığın'",
    "'Saflığın geri dönüyor'": "'Geri dönen saflığın'",
    "'Neşeye izin ver'": "'İzin verilen neşen'",
    "'Doğru yöne bakıyorsun'": "'Doğru yöne bakışın'",
    "'Güneş seni çağırıyor'": "'Seni çağıran güneşin'",
    "'Durdurulamaz bir güçtesin'": "'Durdurulamaz gücün'",
    "'Özgürce ilerliyorsun'": "'Özgürce ilerleyişin'",
    "'Eylemlerin tartılıyor'": "'Tartılan eylemlerin'",
    "'Kalbin coşkuyla doluyor'": "'Coşkuyla dolan kalbin'",
    "'Duygusal zenginlik akıyor'": "'Akan duygusal zenginliğin'",
    "'Kaçırdığın fırsatlar var'": "'Kaçırdığın fırsatların'",
    "'Umut hep arkada duruyor'": "'Arkada bekleyen umudun'",
    "'Gerçek hedefin hangisi?'": "'Sorgulanan gerçek hedefin'",
    "'Güvenli limanın seni bekliyor'": "'Seni bekleyen güvenli limanın'",
    "'Beklenmedik bir mesaj geliyor'": "'Gelen beklenmedik mesajın'",
    "'Romantik bir haberci geliyor'": "'Gelen romantik haberci'",
    "'Duyguların seni yönlendiriyor'": "'Seni yönlendiren duyguların'",
    "'Kazandın ama neyi kaybettin?'": "'Bedeli ödenmiş zaferin'",
    "'Büyüme potansiyelin çok yüksek'": "'Yüksek büyüme potansiyelin'",
    "'Adım adım hedefine yürüyorsun'": "'Hedefe doğru adımların'",
    "'İlhamının kaynağı burada'": "'İlhamının kaynağı'",
    "'Duyguların akışta'": "'Akan duyguların'",
    "'Eskiler savrulup gidiyor'": "'Savrulan eskiler'",
    "'Evren kapı açıyor'": "'Evrenin açtığı kapı'",
    "'Kazandın ama neyi kaybettin?'": "'Bedeli ödenmiş zaferin'"
  };

  replacements.forEach((key, value) {
    content = content.replaceAll(key, value);
  });

  file.writeAsStringSync(content);
}
