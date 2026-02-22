#!/usr/bin/env python3

from PIL import Image
import os

BASE = "assets/images/tarot/tarot"
ORIG = "/tmp/tarot_clean"
TARGET_H = 512

CARDS = [
    ("The_Fool.png",           "The Fool"),
    ("The_Magician.png",       "The Magician"),
    ("The_High_Priestess.png", "The High Priestess"),
    ("The_Empress.png",        "The Empress"),
    ("The_Emperor.png",        "The Emperor"),
    ("The_Hierophant.png",     "The Hierophant"),
    ("The_Lovers.png",         "The Lovers"),
    ("The_Chariot.png",        "The Chariot"),
    ("Strength.png",           "Strength"),
    ("The_Hermit.png",         "The Hermit"),
    ("Wheel_of_Fortune.png",   "Wheel of Fortune"),
    ("Justice.png",            "Justice"),
    ("The_Hanged_Man.png",     "The Hanged Man"),
    ("Death.png",              "Death"),
    ("Temperance.png",         "Temperance"),
    ("The_Devil.png",          "The Devil"),
    ("The_Tower.png",          "The Tower"),
    ("The_Star.png",           "The Star"),
    ("The_Moon.png",           "The Moon"),
    ("The_Sun.png",            "The Sun"),
    ("Judgement.png",          "Judgement"),
    ("The_World.png",          "The World"),
]

def restore_card(out_filename, orig_name):
    orig_path = os.path.join(ORIG, orig_name + ".png")
    if not os.path.exists(orig_path):
        orig_path = os.path.join(ORIG, out_filename)
        
    if not os.path.exists(orig_path):
        print(f"  ✗ Bulunamadi: {orig_name}")
        return

    img = Image.open(orig_path).convert("RGBA")
    w, h = img.size
    ratio = TARGET_H / h
    new_w = int(w * ratio)
    img = img.resize((new_w, TARGET_H), Image.LANCZOS)
    
    # Just save it without overlay
    result = img.convert("RGB")
    out_path = os.path.join(BASE, out_filename)
    result.save(out_path, "PNG", optimize=True)
    print(f"  ✓ {out_filename} restored ({new_w}x{TARGET_H})")

if __name__ == "__main__":
    print("Kartlar temizleniyor...\n")
    for out_fn, orig_name in CARDS:
        restore_card(out_fn, orig_name)
    print("\nTamamlandi!")
