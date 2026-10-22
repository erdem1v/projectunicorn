export const meta = {
  name: 'faz-c-step',
  description: 'Faz C tek adım: Sonnet kodlar, Haiku kapıları ve kareleri koşar, Opus kıdemli inceleme yapar (en çok bir düzeltme turu); commit ana oturumda',
  phases: [
    { title: 'Kod', detail: 'Sonnet, xhigh ya da max' },
    { title: 'Kapı', detail: 'Haiku, düşük' },
    { title: 'İnceleme', detail: 'Opus, yüksek, düzeltme hakkı' },
    { title: 'Yeniden kapı', detail: 'yalnız inceleme kodu değiştirdiyse' },
  ],
}

const S = args
const GIT = 'C:/Users/erdem/Desktop/Project Unicorn'
const ROOT = GIT + '/project-unicorn'
const CDE = `${ROOT}/docs/tasks/faz_cde`
const CT = `${CDE}/c_taslak`
// Tools (w1parity.py) live next to this script; per-run Godot APPDATA dirs go to args.scratch (the session's scratchpad).
const TOOLS = `${CT}/araclar`
const SP = S.scratch || `${TOOLS}/run`

const COMMON = `
Proje: Project Unicorn (Godot 4.6, yalnız GDScript; TR ve EN). Repo: ${ROOT}. Kurallar ${ROOT}/CLAUDE.md (§3, §5-§12), kod haritası ${ROOT}/docs/HARITA.md.
Faz C adımı: ${S.step}. Bağlayıcı kaynaklar, öncelik sırasıyla (üstteki alttakini ezer):
1. ${CDE}/ERDEM_KARARLAR_2026-10-20.md: "C ·" bölümleri (kararlar 1-16), "Genel kural" (dokunduğun ve okuduğun her yerde eski kod silinir ya da düzeltilir; olabildiğince basit, yeni sistem eklenmez), "Daha önce verilmiş". Erdem'in sözü PRD'yi ezer.
2. ${CT}/PLAN_C_E1.md (kararların adımlara işlendiği plan; BU ADIMIN bölümü, W1 metin değişiklikleri, kayıt notu, "benim kararım" çözümleri) — ÖNCE BUNU OKU
3. ${CDE}/ERDEM_QCD_CEVAP.md §1 ve §2.2; ${CDE}/PRD_FAZ_C_URUN_HESAP.md (görev; kabul ölçütleri §4.4, fikstürler §4.6)
4. ${CT}/PLAN_C.md (onaylı adım tablosu); ${CT}/C0v_ADIM_EKLERI.md (BU ADIMIN bölümü: gerçek adlar, dosya ve satırlar, smoke vakaları; "(C0q)" işaretli satırlar Q sonrası), ${CT}/C0q_TAZELEME.md §4, ${CT}/C0_HARITA.md
5. ${CDE}/RAPOR_Q.md §7 (Q'nun sözleşmesi: ProductQuality, SalesFinalizer.lose, şema 18); onaylı metinler ${CT}/W1_METINLER.json (id → tr/en, bayt bayt bağlanır); kararların değiştirdiği, eklediği ya da düşürdüğü öğeler ${CT}/W1_E1.json (aynı id W1'dekini ezer, "drop": true bağlanmaz)
6. UI adımında maket: ${CT}/C0m/C0M_KARELER.md ve png/ (görsel hedef; C1-C8 UI notları), ${ROOT}/CLAUDE.md §7 (UI/STYLE kanunu: yalnız token ve D_* yardımcıları)
${S.sources ? '7. Bu adıma özel: ' + S.sources : ''}
Ağaç kuralları: tek klasör, main. COMMIT ATMA, git add yapma, git checkout -- ve git stash YASAK. Yalnız bu adımın dosyalarına dokun. Sahipsiz farklar (project.godot, themes/*.tres, GDDs ya da docs altındaki başka oturumların farkı, docs/tasks, docs/strateji, tools/__pycache__) dokunulmaz. docs/ACIK_ISLER/ACIK_KARARLAR.md ve docs/ACIK_ISLER/ISLER.md'ye YAZMA (sahipleri yardımcı yönetmen ve Faz Q; açık maddeler sahip onayı olmadan silinmez, CLAUDE.md §3): o dosyalara girmesi gereken satırı summary_tr ya da risks_tr'de "ACIK_ISLER önerisi:" diye yaz.
CSV: localization/strings.csv'ye yalnız tam eşleşmeli bayt splice ile yaz (dosyayı baştan yazan betik yok); token'lar [a-z_]+ ve iki dilde aynı; metinde tire (— –) yok.
Godot: export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe; her koşu kendi APPDATA dizinini alır (${SP}/appdata_${S.step}_<ad>). Makinede bellek çok dar: aynı anda yalnız BİR oturum Godot koşar (ana oturum Faz Q ve Faz D'ye "kapı bende" dedi; Q'nun kapıları iki kez bellek yüzünden düştü). Bu adım aynı anda en çok BİR Godot süreci koşar. Her Godot koşusundan önce say: tasklist //FI "IMAGENAME eq Godot_v4.6.2-stable_win64_console.exe" //NH | grep -c Godot ; 1 ya da fazlaysa (başka oturum ya da Erdem oyunda) 60 sn bekle ve yeniden say, 15 dakikada inmezse Godot'suz işe geç ya da status blocked dön. xargs -P ile paralel smoke yok. Koşudan sonra kendi açtığın ve kapanmayan Godot süreci kalmasın.
AYNI AĞAÇTA PARALEL YAZAN VAR: Faz Q küçük adımlar commit'liyor, Faz D kendi şeridinde kod yazıyor. Ortak dosyalar: localization/strings.csv, scripts/debug/endgame_smoke.gd, scripts/debug/run_probe.gd, scripts/main/main.gd, scripts/systems/sprint_system.gd, scripts/systems/support_system.gd, scripts/systems/incident_system.gd, data/product/sprint.json, docs/HARITA.md, CLAUDE.md (§6 "Karar kâğıdı" ve "Söz olayı" paragrafları D'nin), GDDs/GUNCELLEMELER.md, motor md, _vocabulary.md. Kurallar:
- Paylaşılan dosyada yalnız kendi satırını ekle ya da değiştir; başkasının satırını silme, yeniden biçimleme, taşıma. Dosyayı baştan yazan betik yok: Edit aracı ya da tam eşleşmeli tek parça değiştirme; yazmadan hemen önce dosyayı yeniden oku.
- Başkasının yarım kodu yüzünden kırmızı çıkan koşu (hata senin satırında değilse) senin hatan değildir: o koda dokunma, kanıtıyla not et (risks_tr), sonra yeniden koş.
- class_name ekleme ya da silme gerekiyorsa önce "--import" ve bunu risks_tr'ye yaz.
- own_markers alanına paylaşılan dosyalardaki KENDİ değişikliklerinin tanıtıcılarını yaz (CSV anahtarları, smoke vaka adları, fonksiyon adları, json anahtarları, belge başlıkları); ana oturum commit'te hunk düzeyinde ayırır.`

const CODE_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['done', 'blocked'] },
    blocked_reason: { type: 'string' },
    files: { type: 'array', items: { type: 'string' } },
    summary_tr: { type: 'string' },
    deleted_old_code: { type: 'array', items: { type: 'string' }, description: 'Genel kural gereği silinen ya da düzeltilen eski kod, ad ad' },
    new_smoke_cases: { type: 'array', items: { type: 'string' } },
    falsification: { type: 'string', description: 'yeni vakaların kasıtlı bozulmada düştüğünün kanıtı' },
    gates: { type: 'array', items: { type: 'string' }, description: 'koşulacak kapı komutlarının tam listesi, sırayla' },
    shots: { type: 'array', items: { type: 'string' }, description: 'ekranlı çekim komutları (TR ve EN), sırayla' },
    csv_keys: { type: 'array', items: { type: 'string' }, description: 'eklenen, değişen, silinen CSV anahtarları (+/~/- önekiyle)' },
    w1_ids: { type: 'array', items: { type: 'string' }, description: 'bağlanan W1 öğeleri' },
    pending_constants: { type: 'array', items: { type: 'string' } },
    pending_texts: { type: 'array', items: { type: 'string' } },
    save_impact: { type: 'string', description: 'kayda giren yeni alan, varsayılanı, göç gerekip gerekmediği' },
    risks_tr: { type: 'string' },
    own_markers: { type: 'array', items: { type: 'string' }, description: 'paylaşılan dosyalardaki kendi değişikliklerinin tanıtıcıları' },
  },
  required: ['status', 'files', 'summary_tr', 'gates', 'shots'],
}
const GATE_SCHEMA = {
  type: 'object',
  properties: {
    all_green: { type: 'boolean' },
    results: { type: 'array', items: { type: 'object', properties: {
      cmd: { type: 'string' }, pass: { type: 'boolean' }, evidence: { type: 'string' } }, required: ['cmd', 'pass', 'evidence'] } },
    shots: { type: 'array', items: { type: 'object', properties: {
      png: { type: 'string' }, note_tr: { type: 'string' } }, required: ['png', 'note_tr'] } },
    w1_parity: { type: 'string' },
  },
  required: ['all_green', 'results'],
}
const REVIEW_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['approve', 'block'] },
    changed_code: { type: 'boolean' },
    fixes_tr: { type: 'string' },
    rerun: { type: 'array', items: { type: 'string' } },
    files_to_commit: { type: 'array', items: { type: 'string' } },
    commit_message: { type: 'string' },
    acceptance_tr: { type: 'string', description: 'bu adımın PRD §4.4 maddeleri ve Erdem kararları: ✅/⚠️/❌ + kanıt' },
    pending_tr: { type: 'string', description: 'onay bekleyen sabitler ve metinler' },
    block_reason_tr: { type: 'string' },
    own_markers: { type: 'array', items: { type: 'string' }, description: 'paylaşılan dosyalarda bu adımın değişikliklerinin tanıtıcıları (kod ajanınınkiler + incelemenin düzeltmeleri)' },
  },
  required: ['verdict', 'changed_code', 'files_to_commit', 'commit_message', 'acceptance_tr'],
}

phase('Kod')
const code = await agent(`${COMMON}

GÖREVİN: ${S.step} adımının kodunu yaz (sen Sonnet kod ajanısın).
${S.brief}

Kapı ve kabul: ${S.gates}
Görsel kabul: ${S.shots}

Çalışma biçimi:
- Önce PLAN_C_E1'in bu adım bölümünü, Erdem'in kararlarını, C0v ekinin bu adım bölümünü, PRD'nin ilgili kararlarını ve kabul maddelerini, HARITA'nın ilgili bölümünü ve dokunacağın dosyaları oku. Satır numaralarını HEAD'den doğrula.
- Kodu CLAUDE.md §8'e göre en kısa ve açık hâliyle yaz. Genel kural: dokunduğun ve okuduğun her yerde yerini alan ya da artık yanlış olan eski kodu, verisini, metnini ve smoke vakasını aynı adımda sil ya da düzelt (deleted_old_code'a ad ad yaz).
- Yeni smoke vakası yalnız çekirdek mantığa; falsification ile kanıtla (kasıtlı bozulmada düşer, geri al, geçer).
- Yalnız parse kontrolü ve hedefli vakalarını koş (tam kapıları Haiku koşacak). class_name eklediysen/sildiysen önce "$GODOT" --headless --path . --import.
- Belgeler: bu adımın HARITA satırı, CLAUDE.md §5/§6 cümlesi, motor md §27, GDDs/GUNCELLEMELER.md, sözlük (docs/design/localization_glossary.md), _vocabulary.md (--event-vocab), sinyal manifesti (python tools/gen_signal_manifest.py): dokunduğun neyse aynı adımda güncelle.
- Commit atma. Bitince değiştirdiğin bütün dosyaların listesini, koşulacak kapı komutlarını (tam ve sırayla; --event-lint, loc_residue, loc_csv_integrity, hedefli smoke vakaları, adımın kapıları, tools/run_gate.sh) ve ekranlı çekim komutlarını (TR ve EN) dön.
- Adım Erdem'in kararlarıyla, PLAN_C_E1'le ya da Q'nun gerçek koduyla çözülemeyecek biçimde çelişiyorsa status "blocked" ve nedenini dön; mekanik icat etme, onaysız sabit yazma (sabit PLAN_C_E1'de ya da PRD'de yoksa blocked).`,
  { label: `kod:${S.step}`, phase: 'Kod', model: 'sonnet', effort: S.effort || 'xhigh', schema: CODE_SCHEMA })

if (!code || code.status !== 'done') return { stage: 'code', code }

phase('Kapı')
const gateCmds = (code.gates || []).concat(S.extra_gates || [])
const w1cmd = (code.w1_ids || []).length
  ? `python -I "${TOOLS}/w1parity.py" "${ROOT}" --w1 "${CT}/W1_METINLER.json" --override "${CT}/W1_E1.json" --override "${CT}/W2_METINLER.json" --ids ${code.w1_ids.join(',')}`
  : ''
const gates = await agent(`${COMMON}

GÖREVİN: ${S.step} adımının kapılarını ve ekran çekimlerini koşmak (sen Haiku kapı ajanısın). KOD DEĞİŞTİRME, dosya düzenleme, commit yok. Yalnız komut koş ve sonucu dürüstçe raporla.
Kapı komutları (sırayla, project-unicorn/ dizininden, her Godot koşusu ayrı APPDATA ile):
${gateCmds.map((c, i) => `${i + 1}. ${c}`).join('\n')}
${w1cmd ? `W1 metin eşliği: ${w1cmd} (PARITY satırını ve MISSING satırlarını w1_parity alanına yaz)` : 'W1 metin eşliği: bu adımda yok'}
Ekranlı çekimler (sırayla, paralel değil, pencereli; PNG'ler APPDATA altındaki "Godot/app_userdata/Project Unicorn/" dizinine iner):
${(code.shots || []).map((c, i) => `${i + 1}. ${c}`).join('\n') || '(yok)'}
Kurallar:
- Her komutun çıktısını "Parse Error|Compile Error|Failed to instantiate|SCRIPT ERROR|ERROR:" için de tara; smoke PASS tek başına yetmez.
- Bir komut FAIL verirse dur deme: listedeki öbürlerini de koş, hepsini raporla.
- Her komutu ÖN PLANDA koş ve bitmesini bekle (Bash timeout'u en çok 600000 ms; daha uzun komutu parçalara böl). Arka plana atıp sonucunu beklemeden dönmek YASAK: koşulmamış kapı raporu geçersizdir.
- Her PNG için tam yolu ve bir cümlelik gözlemi yaz (öğe yerinde mi, metin taşıyor ya da kesiliyor mu, dil doğru mu, tire var mı). PNG'yi Read ile aç ve gerçekten bak.
- evidence alanında sonucu kanıtlayan satırları (ör. "SMOKE PASS ...", "RUN OK", hata satırları) kısaca alıntıla.`,
  { label: `kapı:${S.step}`, phase: 'Kapı', model: 'haiku', effort: 'low', schema: GATE_SCHEMA })

phase('İnceleme')
const review = await agent(`${COMMON}

GÖREVİN: ${S.step} adımının kıdemli incelemesi (sen Opus kıdemli geliştiricisin; düzeltme hakkın var, en çok BİR düzeltme turu).
Kod ajanının özeti: ${code.summary_tr}
Değişen dosyalar: ${(code.files || []).join(', ')}
Silinen eski kod: ${(code.deleted_old_code || []).join('; ') || '(yok)'}
Yeni smoke vakaları: ${(code.new_smoke_cases || []).join(', ') || '(yok)'}; falsification: ${code.falsification || '(yok)'}
CSV anahtarları: ${(code.csv_keys || []).join(', ') || '(yok)'}
Kayıt etkisi: ${code.save_impact || '(yok)'}
Onay bekleyen sabitler (kod ajanına göre): ${(code.pending_constants || []).join('; ') || '(yok)'}
Kod ajanının riskleri: ${code.risks_tr || '(yok)'}
Kapı raporu (Haiku): ${JSON.stringify(gates)}

Yap:
1. git diff -- <dosyalar> ile diff'i oku (yalnız bu adımın dosyaları; ağaçta başka fark varsa ona dokunma). Ekran PNG'lerini Read ile aç.
2. CLAUDE.md §9 sorularını sor: en kısa ve açık doğru hâli mi; HARITA'daki yardımcı yeniden mi yazılmış; gereksiz soyutlama, savunma, tarihçe yorumu, ölü kod var mı; write-through ve UI/STYLE kanunu; W1 metni bayt bayt mı bağlanmış; "onay bekliyor" sabitleri tek ayar sabitinde ve işaretli mi.
3. Erdem'in kararları ve Genel kural: bu adımın kararları harfiyen uygulanmış mı; dokunulan yerde eski kod (ve onu okuyan metin, smoke, belge) kalmış mı? Kalmışsa sil ya da düzelt.
4. Bu adımın PRD §4.4 kabul maddelerini ve PLAN_C_E1 kapılarını tek tek değerlendir (✅/⚠️/❌ + kanıt: dosya:satır, vaka adı, çıktı satırı). Tahmin yazma.
5. Hatalı ya da daha iyi yazılabilir yer, kırmızı kapı ya da kötü ekran varsa KENDİN düzelt (tek tur). Düzelttiysen changed_code=true ve yeniden koşulması gereken kapı komutlarını rerun'a yaz.
6. Kapı kırmızı kalıyorsa ve tek turda düzelemiyorsa verdict=block ve nedenini yaz; commit önermeyeceksin.
7. files_to_commit: yalnız bu adımın dosyaları (sahipsiz farklar ve docs/tasks hariç). Paylaşılan dosyalarda Faz Q'nun farkı da görünür: git diff'te yalnız bu adımın hunk'larını incele ve düzelt, own_markers'a bu adımın tanıtıcılarını yaz (kod ajanının own_markers'ı: ${(code.own_markers || []).join(', ') || '(yok)'}). commit_message: "Faz C ${S.step}: <ne değişti, oyuncu ne görür>"; metin taşıyorsa sonuna "TR/EN onay bekliyor", sabit taşıyorsa "sabitler onay bekliyor"; Türkçe, tek paragraf.
Commit ATMA.`,
  { label: `inceleme:${S.step}`, phase: 'İnceleme', model: 'opus', effort: 'high', schema: REVIEW_SCHEMA })

let regate = null
if (review && review.verdict === 'approve' && review.changed_code && (review.rerun || []).length) {
  phase('Yeniden kapı')
  regate = await agent(`${COMMON}

GÖREVİN: İncelemenin düzeltmesinden sonra ${S.step} adımının şu kapılarını yeniden koşmak (Haiku kapı ajanı; KOD DEĞİŞTİRME):
${review.rerun.map((c, i) => `${i + 1}. ${c}`).join('\n')}
Aynı tarama kuralları (Parse Error|Compile Error|Failed to instantiate|SCRIPT ERROR|ERROR:). Ekranlı koşular sırayla; PNG'leri Read ile aç.`,
    { label: `yeniden-kapı:${S.step}`, phase: 'Yeniden kapı', model: 'haiku', effort: 'low', schema: GATE_SCHEMA })
}

return { step: S.step, code, gates, review, regate }
