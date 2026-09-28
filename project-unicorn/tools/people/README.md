# Ofis insanları araçları

`assets/art/people/q22/` gövdeleri ham Quaternius dosyalarından üretilir; içe aktarma ayarları
betikle yazılır. Kaynaklar ve lisanslar: `assets/art/people/README.md`.

Gövdeleri yeniden üretmek (`project-unicorn/`'dan):

    for f in assets/art/people/raw/q22/*.gltf; do
        python tools/people/fix_rig.py "$f" "assets/art/people/q22/$(basename "${f%.gltf}").glb"
    done

`fix_rig.py` kendi çıktısını geri okur; kemik rest'i bind'ı geri almıyorsa, ayak baldırın altında
değilse ya da bir köşe kaydıysa sıfırdan farklı kodla çıkar.

Yeni bir gövde ya da klip paketi eklenince içe aktarma ayarları (humanoid retarget, BoneMap) yazılır,
sonra yeniden içe aktarılır:

    "$GODOT" --headless --path . -s res://tools/people/setup_import.gd
    "$GODOT" --headless --path . --import
