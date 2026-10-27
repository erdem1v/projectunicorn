---
name: neighbourhood-task-2026-10-10
description: "Erdem 2026-10-10 - zoom kilidi yetmedi; ev, İş hanı ve loft'un çevresine gerçek mahalle (plaza'daki kule alanı gibi), aynı sanat dili ya da daha iyisi; araştırma → yön seçimi → üretim"
metadata:
  node_type: memory
  type: project
  originSessionId: 04fc404d-9e0d-4eae-a33f-340be20dda0f
  modified: 2026-10-10T02:15:09.917Z
---

Erdem 2026-10-10: `e1d7da9` zoom-out kilidi boşluğu gizledi ama istediği bu değildi. İstek: uzaklaşınca mahalle
boş görünmesin; plaza'da etraf kulelerle dolu (bir plaza bölgesi gibi), ev, İş hanı ve loft'un etrafına da gerçekten
mahalle kurulsun, "benzer sanat diliyle, hatta daha iyisini". Plaza olduğu gibi kalır.

**Why:** zoom kilidi semptomu kesti; oyuncu dünyayı yapay bir ada gibi görüyor. Erdem'in ölçütü "gerçek mahalle".

**How to apply:** ortam tasarımın üç.js kaynağından (`tools/office3d/src`) dışa aktarılıyor; mahalle ek (additive)
bir dışa aktarım modülü olarak kurulmalı (src byte-identical kuralı, DESIGN_SOURCE.md'ye delta kaydı), aynı yapı
taşlarıyla. Sıra [[feedback-design-research-first]]: araştırma ve önizlemeli yönler → Erdem seçer → üretim.
Mahalle girince `OfficeCamera.LOCKS` yeniden ölçülüp gevşetilmeli (0,6 × fit'e dönebilir). Araştırma workflow'u
`wf_2d0a6598-50b` (oturum 04fc404d), scratch `nbh/`. Bağlantılı: [[render-ceiling-research-2026-10-10]],
[[feedback-bespoke-assets-over-packs]].

**UYGULANDI 2026-10-10, commit `210c2a8` (+ `4933bd5` uid), push YOK.** Erdem'in seçimi: ev = C (cami yerine apartman,
çay bahçesi masaları yok), İş hanı = A (dükkân şeritleri "metro/tramvay" gibi okunuyordu → yan sokaklarla bölündü, köşeler
iki katlı, tenteli), loft = A. `tools/office3d/neighbourhood.js` export sayfasında bake'ten önce; LOCKS üç yerde 0,6'ya döndü.
Vapur (şehir + loft) suyun ötesinden doğuyordu → `OfficeLighting.steer_ferry` iki uç arasında gidip gelir; loft'ta uçlar
(-100, 20), günde bir tur, öğlen loft'un önünde döner.
**Dışa aktarım tuzağı:** gerçek Chrome koşuları arasında GLB'ye gömülü PNG baytları değişebiliyor (4 koşudan 2'si);
commit'lenecek koşuda plaza/city/meet GLB'si HEAD ile aynı çıkana dek yinele. Status dizinini `rm -rf "$S"` ile silmek
güvenlik denetimine takılır: her koşuya yeni dizin ver. Loft'a eklenen zemin tabakası bake_nav kutusuna girince W bloğunun
içinde yürünebilir alan açtı → tabaka `L.bounds` dışında kesilir.
**Yol düzeltmeleri (Erdem iki kez "emin misin" dedi):** `81da8f3` blokları üretilen yollarda keser; `33a89e5` kavşağa
yükseltilmiş yama döşedi → YANLIŞ (8 cm basamak, mürekkep çizgisi = dikiş); `bcb6a05` doğru çözüm: yolu kesen tasarım
kaldırımı/meydanı kaldırılıp yol bantları çıkarılarak yeniden döşenir, ortası yolda kalan ağaç/lamba parçalarıyla kalkar,
loft'un iki sokağı fabrika bacasından kaydırıldı. **Ders:** göz kararı yetmez; hata ayıklama dışa aktarımı (modülün kopyası
yol/kaldırım/bina dikdörtgenlerini döker, `scratchpad/nbh/dbgroads/check2.py`) + 4K yerel çözünürlükte bölge bölge bakış.
Plan görünümü kadraj dışını da gösterir, yanıltır.
`28099ec`: bloklar tasarımın dar kaldırım şeritlerine de basmıyordu sanılıyordu, basıyordu (İş hanı 3, loft 1) → `kerbs` ile
kesilir. **Tam denetim betiği:** `scratchpad/nbh/dbgroads/neighbourhood_final.js` (modülün araçlı kopyası; bina boyutundaki
her parçayı yol bantlarına ve kaldırımlara karşı ölçer) — mahalleye dokunan her değişiklikten sonra bu sıfır vermeli.


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Mahalle task 2026-10-10](neighbourhood-task-2026-10-10.md) — zoom kilidi yetmedi; ev/İş hanı/loft çevresine gerçek mahalle (plaza gibi), aynı dil ya da daha iyisi; **UYGULANDI `210c2a8` (push yok)**: ev C (camisiz), İş hanı A (tramvay şeridi bölündü), loft A; vapur gidip gelir; dışa aktarım PNG bayt tuzağı
