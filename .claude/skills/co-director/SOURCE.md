# Source

Bu skill Project Unicorn için Claude tarafından 2026-10-20'de yazıldı. Hiçbir depo kurulmadı, hiçbir betik
çalıştırılmadı. **Metin kopyalanmadı; fikirler kendi sözlerimizle, Türkçe ve projeye göre yeniden yazıldı.**
Okuma raporu ve gerekçeler: oturum 3ef3b847 scratchpad'i, `skills/2a_codirector.md`.

## Lisanslar

Üç deponun `LICENSE` dosyası 2026-10-20'de `raw.githubusercontent.com/<depo>/main/LICENSE` üzerinden okundu:

| Depo | Lisans | Telif satırı |
|---|---|---|
| https://github.com/tronghieu/agent-skills | MIT | Copyright (c) 2026 Hieu T. Luu |
| https://github.com/fagemx/gstack-game | MIT | Copyright (c) 2026 fagemx |
| https://github.com/obra/superpowers | MIT | Copyright (c) 2025 Jesse Vincent |

Üçü de ticari kullanıma izin veriyor. Metin alınmadığı için lisans metninin kopyası gerekmiyor; atıf burada.

## Hangi fikir nereden

| Bu skill'de | Kaynak | Kaynaktaki yer |
|---|---|---|
| §3 iddia etiketleri (`[BOŞLUK]` `[SIÇRAMA]` `[VARSAYIM]` `[DEĞERLENDİREMEM]` `[GÖRÜŞ]`), "hiç görüş ve değerlendiremem yoksa şüphelen" | tronghieu | `skills/critical-thinking/SKILL.md` (GAP, LEAP, ASSUME, CANNOT-ASSESS, OPINION) |
| §3 alıntı çapası (bulgu harfi harfine alıntıyla) | tronghieu | `critical-thinking/SKILL.md`, "Fabricated findings" |
| Commit-first (önce kendi yargını al): **alınmadı** | tronghieu | Erdem'e her denetimde fazladan soru demek; §4'teki "soru zamanı" kuralıyla çelişir |
| §3 kaynak sicili, güven sınıfları, `A#` varsayım tablosu, türetilmiş sayı formülü, öz-kontrol (kaynak yoğunlaşması, tek kaynağa çok iş) | tronghieu | `skills/market-researcher/references/citation-schema.md` |
| §3 şüpheci doğrulama turu, 2 kat çelişkiyi ortalamama, araç sırası (arama → okuma → tarayıcı), "masa başı araştırma sinyal verir" | tronghieu | `skills/market-researcher/SKILL.md` (Non-negotiables, Tool economy, Verification pass) |
| §4 üç gerçek seçenek ve "yapma / bekle", "ne yapmayacağız", "bu kararı değiştirmiyorsa kes" | tronghieu | `skills/strategy-board/SKILL.md` (Non-negotiables) |
| §5 pre-mortem kuralları (tam ve somut başarısızlık, kanıtı / aktörü / bağımlılığı vuran yollar, en erken uyarı, bir şeyi değiştirmeyen pre-mortem boşa) | tronghieu | `skills/strategy-board/checklists/pre-mortem.md` |
| §4 öncül sorgusu ("neden bu, neden şimdi"), 2-3 alternatif ve öneri | fagemx | `skills/game-direction/SKILL.md` Phase 0 (0A, 0D) |
| §6 kapsam hesabı (kişi-hafta × verim 0,6-0,8, %20-30 tampon, açık > 0 ise kesme), kesme sırası, "kesileni gerekçesiyle yaz" | fagemx | `game-direction/SKILL.md` Section 2 |
| §6 risk matrisi ve Tespit sütunu, "sonra düzeltiriz önlem değil" | fagemx | `game-direction/SKILL.md` Section 3 |
| §6 kilometre taşı kapıları ve "atlanan kapıyı işaretle" (kapılar kendi takvimimize göre yeniden yazıldı) | fagemx | `game-direction/SKILL.md` Section 4 |
| §6 göl / okyanus testi | fagemx | `skills/game-review/references/risk.md` (Scope Risk) |
| §6 ve referans playtest planı: hipotez + ölçü + eşik, üçgenleme (1/2/3 kaynak), şiddet × sıklık, önyargı listesi | fagemx | `skills/playtest/SKILL.md` Section 1, `playtest/references/analysis-framework.md` |
| §2 "Onay yalnız gösterdiğin şeyi kapsar", plan için taze inceleme ve soruları üç yığına ayırma, iş büyürse dur ve boyu yükselt | obra | `skills/brainstorming/SKILL.md` (Red Flags, Builder check, Size the Work) |
| §2 öz-inceleme: kapsama, karar vermeyen satır, orantı | obra | `skills/writing-plans/SKILL.md` (Self-Review) |
| §9 kanıtsız "bitti" yok, "olmalı / muhtemelen" uyarı kelimeleri, ajan raporu kanıt değil | obra | `skills/verification-before-completion/SKILL.md` |
| Referans: gelen incelemeyi doğrula, yanlışsa gerekçeyle reddet | obra | `skills/receiving-code-review/SKILL.md` |

## Projenin kendisinden

Adım tablosu sütunları, model rolleri, inceleme ve düzeltme sınırı, başarısızları da araştırma, sade karar
sorusu ve kapanış üçlüsü, oynanış merceği ve %90 çıtası, PRD ne diyorsa yap, görsel işte önce araştırma ve tek
önce/sonra çifti, sanat yönünde dönem kilidi dersi, gizli gider yok, ölçek merceği, WebSearch bütçesi: Erdem'in
hafızadaki `feedback-*` kuralları ve `websearch-session-budget`. İki katlı "bitti", zevk kararının koddan önce
alınması ve takvim: `project-unicorn/docs/strateji/EL_KITABI.md`.

## Bilerek alınmayanlar

- tronghieu `market-researcher/SKILL.md`: Write korumasını kabuk heredoc'uyla aşma talimatı ("Tool economy"
  altındaki harness satırı). `strategy-board`: `npx skills add` kurulum önerisi. Betikler (`init-*.sh`) ve
  çalışma klasörü yapısı.
- fagemx: `~/.gstack` preamble'ı ve telemetri, Codex ikinci görüş çağrısı, F2P / mobil bölümleri (D1/D7/D30,
  IAP, gacha), kaynaksız kıyas sayıları (örneğin oturum süreleri, elde tutma eşikleri), "Voice" bölümündeki yasak
  kelime listesi (Erdem'in "mekanik kelime yasağı yok" kuralına ters).
- obra: SessionStart hook'u ve bağlama enjekte edilen metin, "%1 ihtimal bile varsa skill'i çağırmak zorundasın"
  dili, görsel yardımcı sunucusu, alt ajan güdümlü geliştirme döngüsü (token kuralıyla çelişir).
- Lisansı ticari kullanıma izin vermeyen depolardan (Stanestane/game-design-skills-bundle, PolyForm
  Noncommercial; deanpeters/Product-Manager-Skills, CC BY-NC-SA 4.0) metin ya da yapı alınmadı. Pre-mortem
  gibi genel yöntemler bu depolara ait değildir; burada tronghieu kaynağından ve kendi sözlerimizle yer alır.
