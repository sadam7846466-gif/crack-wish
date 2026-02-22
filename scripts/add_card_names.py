#!/usr/bin/env python3
"""22 Büyük Arkana kartlarına Türkçe isim yazar — temiz orijinallerden."""

from PIL import Image, ImageDraw, ImageFont
import os

BASE = "assets/images/tarot/tarot"
ORIG = "/tmp/tarot_clean"
TARGET_H = 512  # Hedef yükseklik

CARDS = [
    ("The_Fool.png",           "The Fool",           "DELİ"),
    ("The_Magician.png",       "The Magician",       "BÜYÜCÜ"),
    ("The_High_Priestess.png", "The High Priestess", "BAŞRAHİBE"),
    ("The_Empress.png",        "The Empress",        "İMPARATORİÇE"),
    ("The_Emperor.png",        "The Emperor",        "İMPARATOR"),
    ("The_Hierophant.png",     "The Hierophant",     "AZİZ"),
    ("The_Lovers.png",         "The Lovers",         "AŞIKLAR"),
    ("The_Chariot.png",        "The Chariot",        "SAVAŞ ARABASI"),
    ("Strength.png",           "Strength",           "GÜÇ"),
    ("The_Hermit.png",         "The Hermit",         "ERMİŞ"),
    ("Wheel_of_Fortune.png",   "Wheel of Fortune",   "KADER ÇARKI"),
    ("Justice.png",            "Justice",            "ADALET"),
    ("The_Hanged_Man.png",     "The Hanged Man",     "ASILAN ADAM"),
    ("Death.png",              "Death",              "ÖLÜM"),
    ("Temperance.png",         "Temperance",         "DENGE"),
    ("The_Devil.png",          "The Devil",          "ŞEYTAN"),
    ("The_Tower.png",          "The Tower",          "KULE"),
    ("The_Star.png",           "The Star",           "YILDIZ"),
    ("The_Moon.png",           "The Moon",           "AY"),
    ("The_Sun.png",            "The Sun",            "GÜNEŞ"),
    ("Judgement.png",          "Judgement",          "YARGI"),
    ("The_World.png",          "The World",          "DÜNYA"),
]

FONT_PATH = "/System/Library/Fonts/Supplemental/Georgia.ttf"
FONT_SIZE = 28  # Sabit font boyutu

def process_card(out_filename, orig_name, turkish_name):
    # Orijinal büyük dosyayı bul (boşluklu isimle)
    orig_path = os.path.join(ORIG, orig_name + ".png")
    if not os.path.exists(orig_path):
        # Alt çizgili ismi dene
        orig_path = os.path.join(ORIG, out_filename)
    if not os.path.exists(orig_path):
        print(f"  ✗ Bulunamadı: {orig_name}")
        return

    img = Image.open(orig_path).convert("RGBA")
    
    # Hedef boyuta küçült (oranı koru)
    w, h = img.size
    ratio = TARGET_H / h
    new_w = int(w * ratio)
    img = img.resize((new_w, TARGET_H), Image.LANCZOS)
    w, h = img.size
    
    # Overlay
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    # Sabit font
    font = ImageFont.truetype(FONT_PATH, FONT_SIZE)
    
    # Yazı pozisyonu — alt orta
    # İsim alanı: iç çerçeve alt (y ≈ %87) ile dış çerçeve alt (y ≈ %97) arası
    strip_top = int(h * 0.872)
    strip_bot = int(h * 0.968)
    center_y = (strip_top + strip_bot) // 2
    center_x = w // 2
    
    # Düz yazı, tam ortala (anchor=mm)
    draw.text((center_x, center_y), turkish_name, font=font, fill=(60, 40, 20, 255), anchor="mm")
    
    # Birleştir ve kaydet
    result = Image.alpha_composite(img, overlay).convert("RGB")
    out_path = os.path.join(BASE, out_filename)
    result.save(out_path, "PNG", optimize=True)
    print(f"  ✓ {turkish_name:16s} → {out_filename} ({w}x{h})")

if __name__ == "__main__":
    print("Kartlara Türkçe isim ekleniyor...\n")
    for out_fn, orig_name, tr_name in CARDS:
        process_card(out_fn, orig_name, tr_name)
    print("\nTamamlandı! ✨")
