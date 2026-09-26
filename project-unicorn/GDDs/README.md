# GDDs — yürürlükteki tasarım belgeleri

Her GDD kendi modülünün kaynağıdır; başka bir belgenin bir bölümünü geçersiz kılan yerler tablodaki
not sütunundadır. Revizyon dosya adından ya da belge başlığından değil, belgenin içindeki durum
satırından (Status / YÜRÜRLÜK) okunur; bazı dosya adları ve başlıklar içerikle uyuşmaz.

## Olay motoru

[`GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`](<GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md>)
motorun yürürlükteki tek kaynağıdır. Kodun belgeden ayrıldığı her yer bu dosyanın §27'sine
yazılır. Belgenin .docx hâli ağaçtan kaldırıldı; git geçmişinde durur (`6e3e190`).

`GDD v2 — 11 · Events & Narrative.docx` olay içeriğini yönetir: ark yapısı, hacim, ses ve
söz dağarcığı yasası (§3). ch14 §2 motorun işini, yazılmış olayları ch11 §3'ün söz dağarcığı
yasasına göre doğru bağlamak olarak tanımlar.

## Yürürlükteki belgeler

| dosya | modül | revizyon (belgenin durum satırından) | not |
|---|---|---|---|
| `GDD v2 — 01 · The Run (spine).docx` | koşu omurgası | DIRECTOR-APPROVED 2026-08-20 | §4 → ch09; §5 yaşam maliyeti → Ekip §17.6; §1 demo kesim noktası ve §6 zorluk → ch14 §1–§2 |
| `GDD v2 — 02 · Founder & People Model.docx` | kurucu ve insan modeli | DIRECTOR-APPROVED 2026-08-20 | §2, §6 ve §10 → Ekip (§0.1, §17.6) |
| `GDD v2 — 03 · Product Lifecycle.docx` | Ürün | rev 6.1 · İNŞA SÜRÜMÜ · 2026-08-24 | gövde başlığı "GDD — ÜRÜN MODÜLÜ (rev 6 · İNŞA ADAYI)" der, YÜRÜRLÜK rev 6.1; §24 inşa notlarını taşır |
| `GDD v2 — 06 · Operations.docx` | operasyon | DIRECTOR-APPROVED 2026-08-20 | §1.2 destek kapasite formülü → Ekip §17.6 |
| `GDD v2 — 08 · Finance & Economy.docx` | finans ve ekonomi | DIRECTOR-APPROVED 2026-08-20 | |
| `GDD v2 — 09 · Funding & Investors.docx` | fonlama ve yatırımcılar | DIRECTOR-APPROVED 2026-08-20 | |
| `GDD v2 — 10 · Rivals & World.docx` | rakipler ve dünya | DIRECTOR-APPROVED 2026-08-20 | durum satırı: spec yazılmadan önce daha derin bir tasarım oturumu gerekir |
| `GDD v2 — 11 · Events & Narrative.docx` | olay içeriği ve anlatı | DIRECTOR-APPROVED 2026-08-20 | yukarıya bakın |
| `GDD v2 — 12 · UI Surfaces & ODA.docx` | UI yüzeyleri ve ODA | DIRECTOR-APPROVED 2026-08-20 | §1 Ar-Ge sekmesi → Ar-Ge §2; §8'deki enerji → Ekip §17.6 |
| `GDD v2 — 13 · Endings & Progression.docx` | sonlar ve ilerleme | DIRECTOR-APPROVED 2026-08-20 | |
| `GDD v2 — 14 · Scope (v1 _ EA _ Full).docx` | kapsam (v1 / EA / Full) | DIRECTOR-APPROVED 2026-08-20 | §3 Ar-Ge kilidi → Ar-Ge §2 |
| `GDD — EKİP MODÜLÜ vson.docx` | Ekip | rev 11 · İNŞA SÜRÜMÜ · 2026-08-23 | |
| `GDD — AR-GE MODÜLÜ .docx` | Ar-Ge | rev 1.7 · İNŞA SÜRÜMÜ · 2026-08-25 (YÜRÜRLÜK satırı); §2 ayrıca bir rev 1.8 hükmü taşır | başlık "rev 1 · İNŞA ADAYI" der |
| `GDD — SATIŞ MODÜLÜ (rev 6 · İNŞA SÜRÜMÜ).docx` | Satış | rev 6.1 · İNŞA SÜRÜMÜ (rev 6: 2026-08-26) | dosya adı rev 6 der; ch04'ün yerine geçer |
| `GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` | olay motoru | rev 2 · İNŞA SÜRÜMÜ · 2026-08-25 | yukarıya bakın |

Not sütunundaki "§n → X": o bölüm için X okunur.

v2 setinde 04, 05 ve 07 numaralı bölüm yoktur. Bir bölüm "chapter 04" (satış) ya da
"chapter 07" (ekip) diyorsa Satış ve Ekip GDD'leri okunur; bölüm numaraları eşleşmez.

## GDD olmayan belge

`MARKETING MODULE resarch.docx` bir araştırma girdisidir (DESIGN RESEARCH BRIEF #5), GDD değildir.
ch14 §4 pazarlama sistemini EA'ya koyar ve bu brief'i o iş için bekletir.

## Açık kararlar

GDD'nin kodla ya da başka bir GDD'yle çeliştiği ve sahibin henüz karar vermediği yerler:
[`../docs/ACIK_KARARLAR.md`](../docs/ACIK_KARARLAR.md).
