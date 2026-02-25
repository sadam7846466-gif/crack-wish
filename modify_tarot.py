import re

# Read the file
with open('lib/screens/tarot_meanings.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Define extra mappings for each card ID (0-21)
extras = {
    0: {"shadowTr": "'Gerçeklerden Kaçış'", "shadowEn": "'Escaping Reality'", "adviceTr": "'Cesaret Et'", "adviceEn": "'Take the Leap'", "intensity": 4},
    1: {"shadowTr": "'Manipülasyon, Kibir'", "shadowEn": "'Manipulation, Arrogance'", "adviceTr": "'Zihnini Odakla'", "adviceEn": "'Focus Your Mind'", "intensity": 5},
    2: {"shadowTr": "'Sır saklama, İzolasyon'", "shadowEn": "'Secrecy, Isolation'", "adviceTr": "'İç Sesini Dinle'", "adviceEn": "'Listen to Inner Voice'", "intensity": 3},
    3: {"shadowTr": "'Aşırı Koruyuculuk'", "shadowEn": "'Over-protectiveness'", "adviceTr": "'Şefkat Göster'", "adviceEn": "'Show Compassion'", "intensity": 4},
    4: {"shadowTr": "'Otoriterlik, İnatçılık'", "shadowEn": "'Authoritarianism, Stubbornness'", "adviceTr": "'Sınırlarını Çiz'", "adviceEn": "'Set Your Boundaries'", "intensity": 5},
    5: {"shadowTr": "'Kalıplara Sıkışmak'", "shadowEn": "'Stuck in Dogma'", "adviceTr": "'Öğren ve Öğret'", "adviceEn": "'Learn and Teach'", "intensity": 3},
    6: {"shadowTr": "'Kararsızlık, Bağımlılık'", "shadowEn": "'Indecision, Dependency'", "adviceTr": "'Kalbinle Seç'", "adviceEn": "'Choose with Heart'", "intensity": 4},
    7: {"shadowTr": "'Kontrol Hastalığı, Çatışma'", "shadowEn": "'Control Freak, Conflict'", "adviceTr": "'İradeyi Kullan'", "adviceEn": "'Use Willpower'", "intensity": 5},
    8: {"shadowTr": "'Öfke Patlamaları, Kendinden Şüphe'", "shadowEn": "'Outbursts, Self-Doubt'", "adviceTr": "'Sabırlı ve Nazik Ol'", "adviceEn": "'Be Patient and Gentle'", "intensity": 4},
    9: {"shadowTr": "'İçe Kapanma, Yalnızlık Korkusu'", "shadowEn": "'Isolation, Fear of Loneliness'", "adviceTr": "'Kendine Vakit Ayır'", "adviceEn": "'Take Time for Yourself'", "intensity": 3},
    10: {"shadowTr": "'Kurban Psikolojisi, Direnç'", "shadowEn": "'Victim Mentality, Resistance'", "adviceTr": "'Akışa Uyum Sağla'", "adviceEn": "'Adapt to the Flow'", "intensity": 5},
    11: {"shadowTr": "'Katı Yargılar, Adaletsizlik'", "shadowEn": "'Harsh Judgments, Inequity'", "adviceTr": "'Objektif Karar Ver'", "adviceEn": "'Make Objective Decisions'", "intensity": 4},
    12: {"shadowTr": "'Boşuna Fedakarlık, Kurban Rolü'", "shadowEn": "'Pointless Sacrifice, Martyrdom'", "adviceTr": "'Bakış Açını Değiştir'", "adviceEn": "'Change Your Perspective'", "intensity": 3},
    13: {"shadowTr": "'Bitişleri Kabullenememe, Tutunma'", "shadowEn": "'Inability to Accept Endings, Clinging'", "adviceTr": "'Geçmişi Serbest Bırak'", "adviceEn": "'Release the Past'", "intensity": 5},
    14: {"shadowTr": "'Dengesizlik, Aşırılık'", "shadowEn": "'Imbalance, Extremes'", "adviceTr": "'Orta Yolu Bul'", "adviceEn": "'Find the Middle Path'", "intensity": 2},
    15: {"shadowTr": "'Maddi Bağımlılık, Toksik Bağlar'", "shadowEn": "'Material Addiction, Toxic Bonds'", "adviceTr": "'Zincirlerinden Kurtul'", "adviceEn": "'Break Your Chains'", "intensity": 5},
    16: {"shadowTr": "'Kaos, Beklenmedik Yıkım'", "shadowEn": "'Chaos, Unexpected Ruin'", "adviceTr": "'Eskiyi Yeniden Yapılandır'", "adviceEn": "'Rebuild from the Old'", "intensity": 5},
    17: {"shadowTr": "'Aşırı Hayalperestlik, Umutsuzluk'", "shadowEn": "'Over-idealism, Hopelessness'", "adviceTr": "'Geleceğe İnan'", "adviceEn": "'Believe in the Future'", "intensity": 3},
    18: {"shadowTr": "'Korkuya Esir Olma, Kaygı'", "shadowEn": "'Captive to Fear, Anxiety'", "adviceTr": "'Sezgilerini İzle, Korkuyla Yüzleş'", "adviceEn": "'Follow Intuition, Face Fear'", "intensity": 4},
    19: {"shadowTr": "'Kibir, Tükenmişlik (Burnout)'", "shadowEn": "'Arrogance, Burnout'", "adviceTr": "'Parla ve Neşeyi Paylaş'", "adviceEn": "'Shine and Share Joy'", "intensity": 4},
    20: {"shadowTr": "'Kendini Yargılama, Suçluluk'", "shadowEn": "'Self-Judgment, Guilt'", "adviceTr": "'Geçmişi Affet, Yeniden Doğ'", "adviceEn": "'Forgive Past, Rebirth'", "intensity": 5},
    21: {"shadowTr": "'Tamamlanmamış İşler, Gecikme'", "shadowEn": "'Unfinished Business, Delay'", "adviceTr": "'Bütünlüğü Kutla, Kapanışı Yap'", "adviceEn": "'Celebrate Wholeness, Close Chapter'", "intensity": 4},
}

# Update CardMeaning class definition
class_def_pattern = r'(class CardMeaning \{)(.*?)(const CardMeaning \{)(.*?)(\);)'
def update_class_def(match):
    before = match.group(2)
    init_vars = match.group(4)
    
    new_fields = """
  // Metadata & Engine Fields
  final String shadowTr;
  final String shadowEn;
  final String adviceTr;
  final String adviceEn;
  final int intensity; // 1-5
"""
    new_before = before.rstrip() + new_fields + "\n  "
    
    new_init = init_vars.rstrip() + ",\n    required this.shadowTr,\n    required this.shadowEn,\n    required this.adviceTr,\n    required this.adviceEn,\n    required this.intensity,\n  "
    
    return match.group(1) + new_before + match.group(3) + new_init + match.group(5)

text = re.sub(class_def_pattern, update_class_def, text, flags=re.DOTALL)


# Update each instance in the dictionary
def update_card(match):
    id_str = match.group(1)
    card_id = int(id_str)
    content = match.group(2)
    
    if card_id in extras:
        data = extras[card_id]
        content = content.rstrip()
        if content.endswith(','):
            content = content[:-1]
        
        new_content = f"{content},\n    shadowTr: {data['shadowTr']},\n    shadowEn: {data['shadowEn']},\n    adviceTr: {data['adviceTr']},\n    adviceEn: {data['adviceEn']},\n    intensity: {data['intensity']},\n  "
        return f"{id_str}: CardMeaning({new_content})"
    return match.group(0)

# Pattern to catch id: X, content matching up to );
card_pattern = r'(\d+):\s*CardMeaning\((.*?)\)'
text = re.sub(card_pattern, update_card, text, flags=re.DOTALL)


with open('lib/screens/tarot_meanings.dart', 'w', encoding='utf-8') as f:
    f.write(text)

