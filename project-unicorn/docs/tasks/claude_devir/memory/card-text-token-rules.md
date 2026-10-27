---
name: card-text-token-rules
description: "Kart metninde {slot} SCOPE SLOT ADIDIR ve {seam:...} kart sözdizimidir — strings.csv'ye giremez; ikisini karıştırmak ham token çizdirir"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 8f5a873a-93a2-4680-8f3c-605f37570c20
  modified: 2026-08-26T22:50:29.348Z
---

Olay kartı metnindeki süslü parantezlerin **iki ayrı dili** var ve ikisi de `strings.csv`'nin
adlandırılmış-yer-tutucu dilinden FARKLI. 2026-08-27 hotfix turunda beş anahtar ham token
çiziyordu, üçü de bu ayrımı bilmemekten.

**1. `{slot}` = SCOPE SLOT ADI, alan adı değil.** `presenter.gd:_interpolate` yalnız kartın
`scope` bloğunda TANIMLI slot adlarını değiştirir. B2B müşteri kartlarında slot `customer`'dır.
`{company}` diye bir slot YOKTUR ve o token ekrana `{company}` diye basılır. `{customer}` ve
`{customer.name}` çalışır.

**2. `{seam:ad.soyad}` KART sözdizimidir, CSV'ye KOYULAMAZ.** Regex `\{seam:([a-z_]+\.[a-z_]+)\}`
ve seam'ler slot'lardan ÖNCE çözülür (yani seam prose döndürüp içinde `{customer}` taşıyabilir).
Ama `loc_csv_integrity` bir CSV değerindeki `{seam:...}`'i **"stray brace" diye HAKLI OLARAK
REDDEDER** — CSV'nin token dili `[a-z_]+`, iki nokta yok.

**3. Gövde ya SAF ANAHTAR ya SAF PROSE'dur, karışım DEĞİL.** `_resolve_text` bir değeri ancak
TAMAMI `^[A-Z][A-Z0-9_]{2,}$` ise çevirir. Yani `"{customer}: BIR_ANAHTAR"` yazamazsın. Bir
gövdenin hem seam hem çeviri istemesi gerekiyorsa **prose kartın kendi `text.tr` / `text.en`
alanlarına taşınır** ve CSV satırı düşer — bir cümle, tek ev. (Motor yorumu bunu zaten söylüyor:
"New content writes prose inline; ported content keeps its key.")

**4. Kilitli satırın gerekçesi iki yerden gelebilir ve İKİSİ AYNI ŞEY DEĞİL.**
`text.locked_reasons[opt]` seçenek BAŞINA tek statik cümledir; koşul ağacındaki `reason` ise
KOŞUL başınadır. Üç koşullu bir `requires.all`'a tek gerekçe yazmak, hangi koşul reddederse
etsin aynı yalanı söyler — B2B söz satırı "bu hesaba verilmiş bir söz zaten açık" diyordu, oysa
reddeden koşul "adı konmuş bir talebi yok" idi. Motor bunu zaten destekliyor:
`EvCondition.reason_of` tek başarısız çocuğun gerekçesini yukarı taşır (iki çocuk düşerse
susar). Tek eksik cepheydi — `EventGate.condition_report` bağlamı düşürüyordu.

İlgili: [[strings-csv-surgery]], [[localization-tr-en-task]], [[project-unicorn-current-stage]]
