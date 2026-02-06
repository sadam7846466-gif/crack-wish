/// Rüya sırasında hissedilen duygular
enum Emotion {
  anxiety('Kaygılı', 'Tedirgin, huzursuz'),
  fear('Korkmuş', 'Endişeli, dehşete düşmüş'),
  calm('Huzurlu', 'Sakin, rahat'),
  happiness('Mutlu', 'Neşeli, keyifli'),
  sadness('Üzgün', 'Kederli, melankolik'),
  confusion('Belirsiz', 'Duygum net değil, emin değilim');

  final String label;
  final String description;

  const Emotion(this.label, this.description);
}
