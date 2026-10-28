# İkon kâğıdı: ikon/page/index.html (görseller ikon/page/img/). Kaynak sicili araştırma iş akışının doğrulanmış çıktısından.
# Usage: build_page.py <S>
import html
import json
import sys

S = sys.argv[1]
d = json.load(open(S + "/research/results.json"))
src = {s["id"]: s for r in d["collected"].values() for s in r["sources"]}
chk = {c["id"]: c for v in d["verified"].values() for c in v["checks"]}
# Doğrulayıcının düzelttiği atıf (S3): görüntü Devlog #25'te.
src["S3"]["url"] = "https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2444779293765288700"
src["S3"]["published"] = "2018-08-17"
src["S3"]["title"] = "Startup Company – Devlog #25: Base Features ve Revenue Features"

E = html.escape


def low(t):
    return t.replace('İ', 'i').replace('I', 'ı').lower()


def tag(*ids):
    return "".join('<a class="s" href="#%s">[%s]</a>' % (i, i) for i in ids)


MODULES = [
    {
        "id": "onboarding", "name": "İlk Kullanım ve Erişim", "scope": "B2B ve B2C · hatları: Mobil uygulama, Yardım Merkezi",
        "rejected": "mezuniyet şapkası (world/training.svg)",
        "cands": [
            ("Açık kapı", "set dışı · Lucide <code>door-open</code>, dolguya çevrildi (kapı kanadı tam, kasa ve eşik 0,4)",
             "Giriş ve erişim. Ekranda başka hiçbir ikonla karışmıyor."),
            ("Giriş oku", "setten türetildi · <code>util/exit.svg</code> aynalandı (köşebent sağda, ok içeri giriyor)",
             "Setin kendi çizgisi. Oyunda Çıkış ikonunun eşi olduğu için \"çıkış\" ile karışabilir."),
            ("Telefon", "set dışı · Lucide <code>smartphone</code>, dolguya çevrildi",
             "Yalnız Mobil hattını anlatır, Yardım Merkezi'ni anlatmaz. 16 px'te boş bir levha gibi okunuyor."),
        ],
        "pick": 1,
        "why": "Kapı, \"ilk giriş ve erişim\" demeye en yakın; 16 px'te kapı olarak seçiliyor ve sol rayın hiçbir ikonuyla çakışmıyor. "
               "İlk kullanımı tek ikonla gösteren bir oyun ya da pano örneği bulunamadı; öneri bu yüzden görüş [GÖRÜŞ].",
    },
    {
        "id": "integrations", "name": "Entegrasyonlar", "scope": "yalnız B2B · hattı: Entegrasyonlar",
        "rejected": "komut satırı penceresi (dept/development.svg)",
        "cands": [
            ("Yapboz parçası", "set dışı · Lucide <code>puzzle</code>, dolguya çevrildi", "Eklenti ve entegrasyonun yerleşik işareti."),
            ("Fiş", "set dışı · Lucide <code>plug</code>, dolguya çevrildi", "Bağlanmak. Yapbozdan daha somut, daha az yerleşik."),
            ("Zincir halkası", "set dışı · Lucide <code>link-2</code>, dolguya çevrildi", "Bağlantı. Web'de çoğu zaman \"adres bağlantısı\" diye okunur."),
        ],
        "pick": 1,
        "why": "Yapboz, kütüphanelerde doğrudan \"integration\" ve \"plugin\" etiketini taşıyor ve Chrome'un eklenti düğmesi. "
               "Karşı örnek: Startup Company aynı glifi başka bir bileşen için kullanıyor.",
    },
    {
        "id": "growth", "name": "Büyüme", "scope": "yalnız B2C · hattı: Entegrasyonlar (paylaşma, davet)",
        "rejected": "daire içinde yukarı ok (stake/cash_in.svg)",
        "cands": [
            ("Filiz", "set dışı · Lucide <code>sprout</code>, dolguya çevrildi (zemin çizgisi 0,4)", "Büyüyen şey; ok ya da grafik yok."),
            ("İnsan grubu", "set içi · <code>rail/hr.svg</code>", "Kitle. Oyunlarda kullanıcı artışının ikonu, ama sol rayda EKİP'in ikonu."),
            ("Megafon", "set içi · <code>rail/marketing.svg</code>", "Pazarlama. Sol rayda PAZARLAMA'nın ikonu."),
        ],
        "pick": 1,
        "why": "Oyunlar kullanıcı artışını insan grubuyla çiziyor; ama aynı glif aynı ekranda EKİP'in ikonu (canlı karede yan yana duruyor). "
               "Megafon da PAZARLAMA'nın. Yükselen çizgi ve ok belirsiz bulunmuş ve yukarı ok reddedildi. Filiz çakışmasız ve oksuz; "
               "oyun ya da pano örneği yok, yalnız kütüphane geleneği [GÖRÜŞ].",
    },
    {
        "id": "revenue", "name": "Gelir", "scope": "yalnız B2C · ücretli plan",
        "rejected": "fiyat etiketi (skill/sales.svg)",
        "cands": [
            ("Daire içinde dolar", "set içi · <code>rail/finance.svg</code>", "Para. Sol rayda FİNANS'ın ikonu."),
            ("Banknot", "set dışı · Lucide <code>banknote</code>, dolguya çevrildi", "Gelen para. Şirket oyunlarının gelir ikonu."),
            ("Kredi kartı", "set dışı · Lucide <code>credit-card</code>, dolguya çevrildi", "Ödeme. Gelirden çok ödeme yöntemi okunur."),
        ],
        "pick": 2,
        "why": "Startup Company \"Revenue Features\" başlığını, Startup Panic kasayı banknotla çiziyor. Daire içinde dolar setin içinde, "
               "ama aynı ekranda FİNANS'ın ikonu.",
    },
]

TAGS = {
    "onboarding": ("S26", "S22", "S28", "S29", "S17", "S33"),
    "integrations": ("S34", "S36", "S39", "S43", "S38", "S2", "S5", "S21"),
    "growth": ("S3", "S15", "S17", "S1", "S16", "S35", "S27", "S45", "S46", "S48", "S24", "S31"),
    "revenue": ("S3", "S15", "S37", "S32", "S27", "S49", "S23"),
}

FINDINGS = {
    "onboarding": [
        "Panolarda ilk kullanım için yerleşik bir işaret yok: Pendo rehberleri konuşma balonuyla %s, Intercom giden mesajları kâğıt uçakla %s çiziyor." % (tag("S26"), tag("S22")),
        "Yardım merkezi Zendesk'te düz dolgulu kitap %s; eski sürümdeki soyut üçgenler okunmuyordu %s." % (tag("S28"), tag("S29")),
        "Startup Panic mobil uygulama özelliğini telefonla gösteriyor %s." % tag("S17"),
    ],
    "integrations": [
        "Material Symbols'ın <code>extension</code> ikonu (yapboz) \"integration\", \"plugin\", \"puzzle\" etiketlerini taşıyor %s; Font Awesome ve SF Symbols aynı glifi eklenti için kullanıyor %s." % (tag("S34"), tag("S36", "S39")),
        "Chrome eklenti menüsünün düğmesi yapboz %s. Tepki ikona değil, eklentilerin menüye gizlenmesineydi." % tag("S43"),
        "Fiş: Phosphor'da bağlı iki fiş %s; Startup Company'nin modül ızgarasında fiş var, API olduğu çıkarım, doğrulanmadı %s." % (tag("S38"), tag("S2")),
        "Karşı örnek: Startup Company yapbozu \"Semantic\" bileşeninde kullanıyor %s. Notion bağlantıları düğüm ağıyla gösteriyor %s." % (tag("S5"), tag("S21")),
    ],
    "growth": [
        "Startup Company kullanıcı artıran özellikleri insan grubuyla grupluyor %s; Startup Panic kullanıcıları yüzle %s, daveti kişi ve artıyla %s gösteriyor." % (tag("S3"), tag("S15"), tag("S17")),
        "Pazarlama iki oyunda megafon %s." % tag("S1", "S16"),
        "Yükselen çizgi Material'da ve Play Console'un \"Grow users\" bölümünde var %s; NN/g: <i>\"trendline icons are more ambiguous due to the lack of a standard\"</i> %s. Mad Games Tycoon 2'de yükselen grafik ikonunu oyuncular yanlış okumuş %s." % (tag("S35", "S27"), tag("S45"), tag("S46")),
        "Kutudan yukarı çıkan ok \"yükle\" diye okunuyor %s. Shopify \"Growth\"u hız göstergesiyle çiziyor %s." % (tag("S48"), tag("S24")),
        "Filiz için yalnız kütüphane örneği var %s; oyunda ya da panoda bulunamadı." % tag("S31"),
    ],
    "revenue": [
        "Startup Company \"Revenue Features\" başlığında banknot %s, Startup Panic kasada banknot destesi %s, Font Awesome para ikonunda banknot %s." % (tag("S3"), tag("S15"), tag("S37")),
        "Daire içinde dolar Lucide'de en yaygın okunan para ikonu %s." % tag("S32"),
        "Fiyat etiketi Play Console'da para kazanmanın ikonu %s, StoryGraph'ta içerik etiketi %s: iki anlamlı." % (tag("S27"), tag("S49")),
        "Stripe faturalamayı belge ve yenileme okuyla gösteriyor %s." % tag("S23"),
    ],
}

TITLE_TR = {"onboarding": "İlk Kullanım ve Erişim", "integrations": "Entegrasyonlar", "growth": "Büyüme", "revenue": "Gelir"}


def cand_card(m, i, c):
    k = i + 1
    name, origin, read = c
    rec = ' <span class="rec">önerim</span>' if m["pick"] == k else ""
    return f"""
    <figure class="cand{' picked' if m['pick'] == k else ''}">
      <div class="cand-head"><span class="k">Küme {k}</span><b>{E(name)}</b>{rec}</div>
      <div class="big"><img src="img/big_{m['id']}_{k}.png" alt="{E(name)}, 96 piksel" width="96" height="96"></div>
      <img class="row" src="img/row_{m['id']}_k{k}.png" alt="Oyunda: {E(TITLE_TR[m['id']])} satırı, küme {k}" width="576" height="76">
      <figcaption><span class="origin">{origin}</span><span>{E(read)}</span></figcaption>
    </figure>"""


sections = []
for m in MODULES:
    cards = "".join(cand_card(m, i, c) for i, c in enumerate(m["cands"]))
    findings = "".join(f"<li>{f}</li>" for f in FINDINGS[m["id"]])
    why = E(m["why"]).replace("[GÖRÜŞ]", '<span class="op">[GÖRÜŞ]</span>')
    sections.append(f"""
  <section id="m-{m['id']}">
    <h2>{E(m['name'])}</h2>
    <p class="scope">{E(m['scope'])} · reddedilen: {E(m['rejected'])}</p>
    <div class="baseline"><span>Bugün</span><img src="img/row_{m['id']}_k0.png" alt="Bugünkü iki harfli işaret" width="576" height="76"></div>
    <div class="cands">{cards}
    </div>
    <p class="pick"><b>Önerim: küme {m['pick']}, {E(low(m['cands'][m['pick'] - 1][0]))}.</b> {why}</p>
    <details><summary>Araştırmada bu modül için ne görüldü</summary><ul>{findings}</ul></details>
  </section>""")

cited = sorted({i for t in TAGS.values() for i in t} | {"S40"}, key=lambda s: int(s[1:]))
rows = []
for i in cited:
    s = src[i]
    v = chk.get(i, {}).get("verdict", "")
    vt = {"dogrulandi": "doğrulandı", "duzeltildi": "düzeltildi"}.get(v, v)
    rows.append(f"""<tr id="{i}"><td class="num">{i}</td><td><a href="{E(s['url'])}">{E(s['title'])}</a><br><span class="muted">{E(s['subject'])}</span></td>
<td>{E(s['publisher'][:60])}</td><td class="num">{E(s['published'][:10])}</td><td>{E(s['trust'])}</td><td><a href="{E(s['screenshot_url'])}">kare</a> · {vt}</td></tr>""")

summary_rows = "".join(
    f"<tr><td>{E(m['name'])}</td><td><img src=\"img/big_{m['id']}_{m['pick']}.png\" alt=\"\" width=\"24\" height=\"24\" class=\"mini\"> "
    f"küme {m['pick']}: {E(low(m['cands'][m['pick'] - 1][0]))}</td><td>{', '.join(E(low(c[0])) for j, c in enumerate(m['cands']) if j + 1 != m['pick'])}</td></tr>"
    for m in MODULES)

page = f"""<title>Modül İkonu Adayları</title>
<meta name="claude:viewport-fit-sides" content="cover">
<style>
/* Erdem'in UE kareleri sayfasıyla aynı dil: kâğıt zemin, mürekkep, turuncu vurgu; oyun kareleri koyu adalar. */
:root {{
  --bg: #f6f3ee; --panel: #ffffff; --ink: #1f1b16; --ink-2: #5a524a; --line: #ddd5ca; --accent: #b4561c; --warn-bg: #fbecd9;
  --game: #1f1b16; --game-ink: #e9e4da; --pick: #2f7d4f;
  --f-body: system-ui, -apple-system, "Segoe UI", sans-serif;
}}
@media (prefers-color-scheme: dark) {{
  :root:not([data-theme="light"]) {{
    --bg: #171411; --panel: #211d19; --ink: #efe9e1; --ink-2: #a89e92; --line: #3a332c; --accent: #f0a35e; --warn-bg: #3a2a18;
    --game: #0f0d0b; --game-ink: #e9e4da; --pick: #6cc28f; color-scheme: dark;
  }}
}}
:root[data-theme="dark"] {{
  --bg: #171411; --panel: #211d19; --ink: #efe9e1; --ink-2: #a89e92; --line: #3a332c; --accent: #f0a35e; --warn-bg: #3a2a18;
  --game: #0f0d0b; --game-ink: #e9e4da; --pick: #6cc28f; color-scheme: dark;
}}
* {{ box-sizing: border-box; }}
body {{ margin: 0; background: var(--bg); color: var(--ink); font: 16px/1.55 var(--f-body); }}
main {{ max-width: 1180px; margin: 0 auto; padding-block: 32px 64px; padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); }}
h1, h2 {{ text-wrap: balance; }}
h1 {{ font-size: 30px; margin: 0 0 8px; }}
h2 {{ font-size: 22px; margin: 48px 0 4px; padding-top: 16px; border-top: 1px solid var(--line); }}
p, li {{ max-width: 78ch; }}
.lead {{ color: var(--ink-2); }}
.note {{ background: var(--warn-bg); padding: 12px 16px; border-radius: 6px; max-width: 78ch; }}
a {{ color: var(--accent); }}
a.s {{ text-decoration: none; font-size: 13px; font-variant-numeric: tabular-nums; }}
code {{ font-size: 0.9em; }}
.scope {{ color: var(--ink-2); margin: 0 0 12px; }}
.table-wrap {{ overflow-x: auto; }}
table {{ border-collapse: collapse; margin: 12px 0; width: 100%; font-size: 15px; }}
th, td {{ text-align: left; padding: 6px 10px; border-bottom: 1px solid var(--line); vertical-align: top; }}
th {{ color: var(--ink-2); font-weight: 600; }}
td.num {{ font-variant-numeric: tabular-nums; white-space: nowrap; }}
.muted {{ color: var(--ink-2); font-size: 13px; }}
img.mini {{ background: var(--game); border-radius: 4px; padding: 2px; vertical-align: middle; }}
.baseline {{ display: flex; align-items: center; gap: 12px; margin: 0 0 12px; flex-wrap: wrap; }}
.baseline span {{ color: var(--ink-2); font-size: 14px; min-width: 48px; }}
.baseline img {{ width: 288px; max-width: 100%; height: auto; image-rendering: pixelated; border-radius: 4px; }}
.cands {{ display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; }}
.cand {{ margin: 0; background: var(--panel); border: 1px solid var(--line); border-radius: 8px; padding: 10px; display: grid; gap: 8px; min-width: 0; }}
.cand.picked {{ border-color: var(--pick); box-shadow: inset 0 0 0 1px var(--pick); }}
.cand-head {{ display: flex; gap: 8px; align-items: baseline; flex-wrap: wrap; }}
.cand-head .k {{ font-size: 12px; letter-spacing: 0.06em; text-transform: uppercase; color: var(--ink-2); }}
.rec {{ font-size: 12px; color: var(--pick); font-weight: 600; letter-spacing: 0.04em; }}
.big {{ background: var(--game); border-radius: 6px; display: grid; place-items: center; padding: 14px 0; }}
.cand img.row {{ width: 100%; height: auto; image-rendering: pixelated; border-radius: 4px; display: block; }}
.cand figcaption {{ display: grid; gap: 4px; font-size: 14px; color: var(--ink-2); }}
.cand figcaption .origin {{ color: var(--ink); }}
.pick {{ margin: 14px 0 6px; }}
.op {{ color: var(--accent); font-size: 13px; }}
details {{ margin: 6px 0 0; }}
summary {{ cursor: pointer; color: var(--accent); }}
summary:focus-visible, a:focus-visible {{ outline: 2px solid var(--accent); outline-offset: 2px; }}
.frames figure {{ margin: 0 0 16px; }}
.frames img {{ width: 100%; height: auto; display: block; border-radius: 6px; image-rendering: pixelated; }}
.frames figcaption, .res figcaption {{ font-size: 14px; color: var(--ink-2); padding-top: 6px; }}
.full {{ display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 8px; margin: 8px 0 16px; }}
.full a {{ display: block; font-size: 13px; }}
.full img {{ width: 100%; height: auto; border-radius: 4px; display: block; }}
.res {{ display: grid; gap: 16px; }}
.res figure {{ margin: 0; background: var(--panel); border: 1px solid var(--line); border-radius: 8px; padding: 10px; min-width: 0; }}
.res img {{ max-width: 100%; height: auto; display: block; }}
.ok {{ color: var(--pick); font-weight: 600; }}
@media (max-width: 760px) {{
  .cands, .full {{ grid-template-columns: 1fr; }}
}}
</style>
<main>
  <h1>Modül ikonları: adaylar</h1>
  <p class="lead">Ürün penceresinin sol sütununda iki harfli işaretlerin (ÇK, İK, EN, GÜ, BÜ, GE) yerine gelecek ikonlar. Onaylı ikiler aynen kalıyor:
  Çekirdek küp <img src="img/big_core.png" alt="küp" width="24" height="24" class="mini">, Güven &amp; Ölçek kalkan <img src="img/big_trust.png" alt="kalkan" width="24" height="24" class="mini">.
  Kalan dört modülün her biri için üç aday var; her modülden birini seç. Seçilenleri URUN_ARAYUZU bağlar.</p>

  <div class="table-wrap"><table>
    <thead><tr><th>Modül</th><th>Önerim</th><th>Öbür adaylar</th></tr></thead>
    <tbody>{summary_rows}</tbody>
  </table></div>
  <p class="note">Kareler oyunun kendisinden: 1920×1080, TR, aday kümesi bir ortam değişkeniyle açılan bir prototipte (kod repoya girmedi). Küme <i>i</i>,
  her modülün <i>i</i>. adayı. Yakın planlar karenin sol sütunundan kırpıldı ve en yakın komşuyla 2× büyütüldü: 16 piksellik ikon oyundaki gibi.
  Satırın tamamına bakıldı: taşma yok, kesilme yok. Godot MCP'yle canlı oyunda da bakıldı (üç küme B2C, küme 1 B2B): ikonlar keskin, koyu zeminde seçiliyor.</p>
  {''.join(sections)}

  <h2>Oyunun içinde, dört kare yan yana</h2>
  <div class="frames">
    <figure><img src="img/cmp_a4_two_pm.webp" alt="B2B dünyası: bugünkü harfler ve üç küme" width="2570" height="796">
      <figcaption>B2B (<code>live:a4_two_pm</code>): talep satırlarında da modül işareti var. Soldan: bugün, küme 1, küme 2, küme 3. Taşma yok, kesilme yok.</figcaption></figure>
    <figure><img src="img/cmp_b2c_live.webp" alt="B2C dünyası: bugünkü harfler ve üç küme" width="2570" height="1028">
      <figcaption>B2C (<code>live:b2c_live</code>, geçmiş açık). Soldan: bugün, küme 1, küme 2, küme 3. Taşma yok, kesilme yok.</figcaption></figure>
  </div>
  <p>Tam kareler (sol ray ikonlarıyla birlikte; çakışmalar burada görünüyor):</p>
  <div class="full">
    {''.join(f'<a href="img/full_{w}_k{k}.webp"><img src="img/full_{w}_k{k}.webp" alt="{w} {lbl}" loading="lazy" width="1920" height="1080">{w.replace("live_", "")} · {lbl}</a>' for w in ["a4_two_pm", "b2c_live"] for k, lbl in [("0", "bugün"), ("1", "küme 1"), ("2", "küme 2"), ("3", "küme 3")])}
  </div>
  <p class="note">Aynı ekranda sol rayda duran ikonlarla çakışanlar: daire içinde dolar = FİNANS, insan grubu = EKİP, megafon = PAZARLAMA.
  Onaylı küp de ÜRÜN'ün ikonu, yani bu çakışma bir kez kabul edildi. Çakışmayan adaylar: kapı, giriş oku, telefon, yapboz, fiş, zincir, filiz, banknot, kredi kartı.</p>

  <h2>Araştırmadan iki kare</h2>
  <div class="res">
    <figure><img src="img/res_s3.webp" alt="Startup Company: Base Features insan grubu, Revenue Features banknot" width="860" height="90">
      <figcaption>Startup Company, geliştiricinin kendi ekranı: kullanıcı artıran özellikler insan grubuyla, gelir getirenler banknotla {tag("S3")}. Aynı banknot oyunda yatırım sekmesinde de duruyor.</figcaption></figure>
    <figure><img src="img/res_s43.webp" alt="Chrome araç çubuğunda yapboz biçimli eklenti düğmesi ve açılan Extensions menüsü" width="900" height="200">
      <figcaption>Chrome'un eklenti düğmesi yapboz parçası {tag("S43")}. Material Symbols aynı glifi "integration" ve "plugin" etiketiyle sunuyor {tag("S34")}.</figcaption></figure>
  </div>
  <p>Genel bulgu: NN/g'ye göre evrensel tanınan ikon çok az; <i>"a text label must be present alongside an icon"</i> {tag("S40")}. Bizim satırlarda modülün adı ikonun yanında
  durmaya devam ediyor; ikon adın yerine geçmiyor, satırı adı okumadan ayırt ettiriyor.</p>

  <h2>Notlar</h2>
  <ul>
    <li>Set dışı adaylar yalnız Lucide'den (ISC lisansı depoda: <code>assets/art/office/icons/LICENSE-lucide.txt</code>). Lucide çizgi ikonudur; setin düz dolgulu stiline bir betikle
    çevrildi: kapalı biçimler dolduruldu, içteki ayrıntılar delik oldu, ikincil parça 0,4 opaklıkta. Seçilirse SVG'yi URUN_ARAYUZU <code>assets/icons/</code>'a koyar.</li>
    <li>Giriş oku yeni çizim değil: <code>util/exit.svg</code>'nin köşebendi aynalandı, oku köşebendin içine kaydırıldı.</li>
    <li><code>assets/icons/</code>'un kaynağı hâlâ açık (PRD_ANA_MENU_ONBOARDING L4); set içi adaylar da bu açık kalemin altında.</li>
    <li>Kareler dizüstünde (Mac) çekildi. Mac'te pencere tam ekranda açıldığı için kopyaya <code>override.cfg</code> ile pencereli açılış verildi; kare boyutu böylece 1920×1080.</li>
  </ul>

  <h2>Kaynak sicili</h2>
  <p class="muted">Erişim 2026-10-28. Her kaynak bir ekran görüntüsüyle toplandı ve ayrı bir doğrulayıcı görüntüyü açıp ikonu ve kırpma bölgesini yeniden denetledi.</p>
  <div class="table-wrap"><table>
    <thead><tr><th>ID</th><th>Kaynak</th><th>Yayıncı</th><th>Yayın</th><th>Güven</th><th>Görüntü</th></tr></thead>
    <tbody>{''.join(rows)}</tbody>
  </table></div>
</main>
"""
open(S + "/ikon/page/index.html", "w").write(page)
print("ok", len(page))
