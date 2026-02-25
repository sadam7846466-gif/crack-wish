import re

with open('lib/screens/tarot_meanings.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add extra fields to class
text = text.replace('  final String directionTr;\n  final String directionEn;',
                    '  final String directionTr;\n  final String directionEn;\n\n  final String shadowTr;\n  final String shadowEn;\n  final String adviceTr;\n  final String adviceEn;\n  final int intensity;')

text = text.replace('    required this.directionTr,\n    required this.directionEn,\n  });',
                    '    required this.directionTr,\n    required this.directionEn,\n    required this.shadowTr,\n    required this.shadowEn,\n    required this.adviceTr,\n    required this.adviceEn,\n    required this.intensity,\n  });')


extras = {
    0: {"shadowTr": "'İhanet, aptallık'", "shadowEn": "'Betrayal, foolishness'", "adviceTr": "'Risk al'", "adviceEn": "'Take a risk'", "intensity": 4},
    1: {"shadowTr": "'Manipülasyon, kontrol'", "shadowEn": "'Manipulation, control'", "adviceTr": "'Gücünü kullan'", "adviceEn": "'Use your power'", "intensity": 5},
    2: {"shadowTr": "'Sırlar, soğukluk'", "shadowEn": "'Secrets, coldness'", "adviceTr": "'Sezgilerini dinle'", "adviceEn": "'Listen to intuition'", "intensity": 3},
    3: {"shadowTr": "'Bağımlılık, boğuculuk'", "shadowEn": "'Dependence, smothering'", "adviceTr": "'Şefkat göster'", "adviceEn": "'Show compassion'", "intensity": 4},
    4: {"shadowTr": "'Zorbalık, katılılık'", "shadowEn": "'Tyranny, rigidity'", "adviceTr": "'Sınır koy'", "adviceEn": "'Set boundaries'", "intensity": 5},
    5: {"shadowTr": "'Dar kafalılık'", "shadowEn": "'Narrow-mindedness'", "adviceTr": "'Öğren ve inan'", "adviceEn": "'Learn and believe'", "intensity": 3},
    6: {"shadowTr": "'Uyumsuzluk, yanlış seçim'", "shadowEn": "'Disharmony, wrong choice'", "adviceTr": "'Kalbinle seç'", "adviceEn": "'Choose with heart'", "intensity": 4},
    7: {"shadowTr": "'Acımasız hırs'", "shadowEn": "'Ruthless ambition'", "adviceTr": "'Odaklan'", "adviceEn": "'Focus'", "intensity": 5},
    8: {"shadowTr": "'Öfke, güçsüzlük'", "shadowEn": "'Anger, weakness'", "adviceTr": "'Sabırlı ol'", "adviceEn": "'Be patient'", "intensity": 4},
    9: {"shadowTr": "'İzolasyon, kaçış'", "shadowEn": "'Isolation, escape'", "adviceTr": "'İçine dön'", "adviceEn": "'Go inward'", "intensity": 3},
    10: {"shadowTr": "'Kontrol kaybı, kötü şans'", "shadowEn": "'Loss of control, bad luck'", "adviceTr": "'Akışa bırak'", "adviceEn": "'Let it flow'", "intensity": 5},
    11: {"shadowTr": "'Önyargı, haksızlık'", "shadowEn": "'Prejudice, unfairness'", "adviceTr": "'Objektif ol'", "adviceEn": "'Be objective'", "intensity": 4},
    12: {"shadowTr": "'Kurban rolü'", "shadowEn": "'Martyrdom'", "adviceTr": "'Bakış açını değiştir'", "adviceEn": "'Change perspective'", "intensity": 3},
    13: {"shadowTr": "'Korku, tutunma'", "shadowEn": "'Fear, clinging'", "adviceTr": "'Bırak'", "adviceEn": "'Let it go'", "intensity": 5},
    14: {"shadowTr": "'Dengesizlik, aşırılık'", "shadowEn": "'Imbalance, excess'", "adviceTr": "'Dengeyi bul'", "adviceEn": "'Find balance'", "intensity": 2},
    15: {"shadowTr": "'Bağımlılık, saplantı'", "shadowEn": "'Addiction, obsession'", "adviceTr": "'Zincirleri kır'", "adviceEn": "'Break the chains'", "intensity": 5},
    16: {"shadowTr": "'Kaos, yıkım'", "shadowEn": "'Chaos, destruction'", "adviceTr": "'Yeniden başla'", "adviceEn": "'Start over'", "intensity": 5},
    17: {"shadowTr": "'Gerçekdışılık, boş umut'", "shadowEn": "'Delusion, false hope'", "adviceTr": "'Umudu koru'", "adviceEn": "'Keep hope'", "intensity": 3},
    18: {"shadowTr": "'Kaygı, yanılsama'", "shadowEn": "'Anxiety, illusion'", "adviceTr": "'Korkunla yüzleş'", "adviceEn": "'Face your fear'", "intensity": 4},
    19: {"shadowTr": "'Ego, tükenmişlik'", "shadowEn": "'Ego, burnout'", "adviceTr": "'Neşeni paylaş'", "adviceEn": "'Share your joy'", "intensity": 4},
    20: {"shadowTr": "'Pişmanlık, red'", "shadowEn": "'Regret, denial'", "adviceTr": "'Affet ve uyan'", "adviceEn": "'Forgive and awaken'", "intensity": 5},
    21: {"shadowTr": "'Yarım kalma, gecikme'", "shadowEn": "'Incompletion, delay'", "adviceTr": "'Döngüyü tamamla'", "adviceEn": "'Complete the cycle'", "intensity": 4},
}

for card_id, data in extras.items():
    # Find directionEn: '...'
    pattern = rf'({card_id}\s*:\s*CardMeaning\([\s\S]*?directionEn\s*:\s*\'.*?\'\s*),'
    def repl(m):
        return m.group(1) + f",\n    shadowTr: {data['shadowTr']},\n    shadowEn: {data['shadowEn']},\n    adviceTr: {data['adviceTr']},\n    adviceEn: {data['adviceEn']},\n    intensity: {data['intensity']},"
    text = re.sub(pattern, repl, text, count=1)

with open('lib/screens/tarot_meanings.dart', 'w', encoding='utf-8') as f:
    f.write(text)
