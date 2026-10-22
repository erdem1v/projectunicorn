export const meta = {
  name: 'faz-b-chain',
  description: 'Faz B zinciri: ilk adımın kodu, sonra ilk adımın kapı+incelemesi ile sonraki adımların tam akışı paralel (Sonnet kod, Haiku kapı, Opus inceleme); commit ana oturumda',
  phases: [
    { title: 'Kod', detail: 'Sonnet, xhigh ya da max' },
    { title: 'Kapı', detail: 'Haiku, düşük' },
    { title: 'İnceleme', detail: 'Opus, yüksek, düzeltme hakkı' },
    { title: 'Yeniden kapı', detail: 'yalnız inceleme kodu değiştirdiyse' },
  ],
}

const ROOT = 'C:/Users/erdem/Desktop/Project Unicorn/project-unicorn'
const SP = 'C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5d19279e-6a73-4fd8-b7f8-dcb373bb1fc5/scratchpad'
const TASK = `${ROOT}/docs/tasks/faz_ab`

const PARALLEL = (S) => `
PARALEL ÇALIŞMA (Erdem'in isteği): bu adım aynı ağaçta şu adımlarla AYNI ANDA koşuyor: ${S.parallel}. Worktree yok, tek klasör. Kurallar:
- Yalnız bu adımın işine dokun. Paylaşılan dosyalarda (localization/strings.csv, scripts/debug/endgame_smoke.gd, run_probe.gd, sprint_probe.gd, main.gd, sprint_system.gd, incident_system.gd, effects.gd, chips.gd, lint.gd, data/product/sprint.json, docs/HARITA.md, CLAUDE.md, GDDs/GUNCELLEMELER.md, motor md, _vocabulary.md, EVENT_SIGNAL_MANIFEST.md) yalnız kendi satırlarını ekle ya da değiştir; başkasının satırını silme, yeniden biçimleme, taşıma. Dosyayı baştan yazan betik kullanma: Edit aracı ya da tam eşleşmeli tek parça değiştirme (CSV byte-span splice); yazmadan hemen önce dosyayı yeniden oku.
- Başka adımın yarım kodu yüzünden kırmızı çıkan koşu (hata senin dosyanda ya da satırında değilse) senin hatan değildir: o koda dokunma; kanıtıyla not et, Godot'suz işe geç, sonra yeniden koş.
- class_name ekleme ya da silme yok (paralel --import öbür koşuları bozar); gerekiyorsa var olan sınıfa static func koy ya da status blocked dön.
- Godot: makinede aynı anda en çok İKİ Godot süreci. Her Godot koşusundan önce say: tasklist //FI "IMAGENAME eq Godot_v4.6.2-stable_win64_console.exe" //NH | grep -c Godot ; 2 ya da fazlaysa Godot'suz işe geç ve sonra yeniden bak. Uzun koşuları (plausibility, run_gate, çok tohumlu ölçüm) tek seferde topla.
- --event-vocab ve gen_signal_manifest bütün ağacı yazar: adımın sonunda bir kez koş.
- İnceleme ve commit: git diff paylaşılan dosyalarda öbür adımların farkını da gösterir; yalnız bu adımın değişikliklerini incele ve düzelt. own_markers alanına paylaşılan dosyalardaki KENDİ değişikliklerinin tanıtıcılarını yaz (CSV anahtarları, smoke vaka adları, fonksiyon adları, json anahtarları, belge başlıkları); ana oturum commit'te hunk düzeyinde ayırır.`

const COMMON = (S) => `
Proje: Project Unicorn (Godot 4.6, yalnız GDScript; TR ve EN). Repo: ${ROOT}. Kurallar ${ROOT}/CLAUDE.md (§3, §5–§12), kod haritası ${ROOT}/docs/HARITA.md.
Faz B adımı: ${S.step}. Bağlayıcı kaynaklar, sırayla:
1. ${TASK}/PRD_FAZ_B_OLAYLAR.md (görev; kabul ölçütleri §4)
2. ${TASK}/b_taslak/YURUTUCU_NOTU_B.md (yürütücü notu: sahibin kararları, onaylı metnin bağlanması, ağaç ve commit kuralları, kapılar, bilinen tuzaklar) — ÖNCE BUNU OKU
3. C:/Users/erdem/.claude/plans/bu-task-devral-ve-fluttering-hearth.md (onaylı adım tablosu ve gerekçeli değişiklikler)
4. ${TASK}/b_taslak/B0v_ADIM_EKLERI.md (BU ADIMIN bölümü: Opus'un doğruladığı gerçek adlar ve çözümler; brief'le çelişirse bu kazanır), B0_HARITA.md (A'dan sonra tazelenmiş bağlantı haritası), B0_ESIKLER.md (eşikler, onay bekliyor), B0t_MAIL_SAATLERI.md (mail saatleri)
5. ${TASK}/RAPOR_A.md (Faz A'nın adlı okuma/yazma noktaları; B bunlardan başka yoldan A'nın deposuna ya da matrisine dokunmaz)
6. Onaylı metin dalgaları: ${TASK}/b_taslak/W1_OLAYLAR.json, W2_KAGITLAR.json, W3_SOZ_SURUM.json (metin bayt bayt bağlanır)
7. Tasarım girdisi: ${TASK}/ek/B_PLAN.md (PRD §0'daki geçersizler hariç)
Ağaç kuralları: tek klasör, main. COMMIT ATMA, git add yapma, git checkout -- YASAK. Yalnız bu adımın dosyalarına dokun. Sahipsiz farklar (project.godot, themes/*.tres, docs/mockups, docs/tasks/PRD_*, tools/__pycache__) dokunulmaz. Godot: export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe; her koşu kendi APPDATA dizinini alır (${SP}/appdata_${S.step}_<ad>). Makinede bellek dar (16 GB'ın ~2 GB'ı boş): ${S.parallel ? 'aynı anda en çok İKİ Godot süreci (aşağıdaki sayma kuralı);' : 'aynı anda en çok BİR Godot süreci;'} çok tohumlu ölçümde en çok iki paralel koşu; xargs -P ile paralel smoke yok.${S.parallel ? PARALLEL(S) : ''}`

const CODE_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['done', 'blocked'] },
    blocked_reason: { type: 'string' },
    files: { type: 'array', items: { type: 'string' } },
    summary_tr: { type: 'string' },
    new_smoke_cases: { type: 'array', items: { type: 'string' } },
    gates: { type: 'array', items: { type: 'string' }, description: 'koşulacak kapı komutlarının tam listesi, sırayla' },
    shots: { type: 'array', items: { type: 'string' }, description: 'ekranlı çekim komutları (TR ve EN), sırayla' },
    pending_constants: { type: 'array', items: { type: 'string' } },
    pending_texts: { type: 'array', items: { type: 'string' } },
    risks_tr: { type: 'string' },
    own_markers: { type: 'array', items: { type: 'string' } },
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
    byte_parity: { type: 'string' },
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
    acceptance_tr: { type: 'string', description: 'bu adımın PRD §4 maddeleri: ✅/⚠️/❌ + kanıt' },
    pending_tr: { type: 'string', description: 'onay bekleyen sabitler ve metinler' },
    block_reason_tr: { type: 'string' },
    own_markers: { type: 'array', items: { type: 'string' }, description: 'paylaşılan dosyalarda bu adımın değişikliklerinin tanıtıcıları' },
  },
  required: ['verdict', 'changed_code', 'files_to_commit', 'commit_message', 'acceptance_tr'],
}

async function stepCode(S) {
const code = await agent(`${COMMON(S)}

GÖREVİN: ${S.step} adımının kodunu yaz (sen Sonnet kod ajanısın).
${S.brief}

Kapı ve kabul: ${S.gates}
Görsel kabul: ${S.shots}

Çalışma biçimi:
- Önce yürütücü notunu, PRD'nin bu adımla ilgili kararlarını ve kabul maddelerini, haritanın ilgili bölümünü ve dokunacağın dosyaları oku.
- Kodu CLAUDE.md §8'e göre en kısa ve açık hâliyle yaz; yerini alan kodu aynı adımda sil; yeni smoke vakasını falsification ile kanıtla.
- Yalnız parse kontrolü ve gerekirse bir hedefli vaka koş (tam kapıları Haiku koşacak). class_name eklediysen/sildiysen önce "$GODOT" --headless --path . --import.
- Belgeler: bu adımın HARITA satırı, CLAUDE.md §5/§6 cümlesi, motor md §27, _vocabulary.md (--event-vocab), sinyal manifesti (python tools/gen_signal_manifest.py) — dokunduğun neyse aynı adımda güncelle.
- Commit atma. Bitince değiştirdiğin bütün dosyaların listesini, koşulacak kapı komutlarını (tam ve sırayla) ve ekranlı çekim komutlarını (TR ve EN) dön.
- Adım PRD'yle ya da A'nın gerçek koduyla çözülemeyecek biçimde çelişiyorsa status "blocked" ve nedenini dön; mekanik icat etme.`,
  { label: `kod:${S.step}`, phase: 'Kod', model: 'sonnet', effort: S.effort || 'xhigh', schema: CODE_SCHEMA })

return code

}

async function stepRest(S, code) {
const gateCmds = (code.gates || []).concat(S.extra_gates || [])
const gates = await agent(`${COMMON(S)}

GÖREVİN: ${S.step} adımının kapılarını ve ekran çekimlerini koşmak (sen Haiku kapı ajanısın). KOD DEĞİŞTİRME, dosya düzenleme, commit yok. Yalnız komut koş ve sonucu dürüstçe raporla.
Kapı komutları (sırayla, project-unicorn/ dizininden, her Godot koşusu ayrı APPDATA ile):
${gateCmds.map((c, i) => `${i + 1}. ${c}`).join('\n')}
Ekranlı çekimler (sırayla, paralel değil; PNG'ler APPDATA altındaki "Godot/app_userdata/Project Unicorn/" dizinine iner):
${(code.shots || []).map((c, i) => `${i + 1}. ${c}`).join('\n') || '(yok)'}
Kurallar:
- Her komutun çıktısını "Parse Error|Compile Error|Failed to instantiate|SCRIPT ERROR|ERROR:" için de tara; smoke PASS tek başına yetmez.
- Bir komut FAIL verirse dur deme: listedeki öbürlerini de koş, hepsini raporla.
- Her komutu ÖN PLANDA koş ve bitmesini bekle (Bash timeout'u en çok 600000 ms; daha uzun komutu parçalara böl, ör. vaka listesini birkaç çağrıya). Arka plana atıp sonucunu beklemeden dönmek YASAK: koşulmamış kapı raporu geçersizdir.
- Onaylı metin bayt eşliği: listede textparity.py komutu varsa onun PARITY satırını (ve MISSING satırlarını) byte_parity alanına koy; yoksa "bu adımda yok" yaz.
- Her PNG için tam yolu ve bir cümlelik gözlemi yaz (öğe yerinde mi, metin taşıyor ya da kesiliyor mu, dil doğru mu). PNG'yi Read ile aç ve gerçekten bak.
- evidence alanında sonucu kanıtlayan satırları (ör. "SMOKE PASS ...", "PROBE END", hata satırları) kısaca alıntıla.`,
  { label: `kapı:${S.step}`, phase: 'Kapı', model: 'haiku', effort: 'low', schema: GATE_SCHEMA })

const review = await agent(`${COMMON(S)}

GÖREVİN: ${S.step} adımının kıdemli incelemesi (sen Opus kıdemli geliştiricisin; düzeltme hakkın var, en çok BİR düzeltme turu).
Kod ajanının özeti: ${code.summary_tr}
Değişen dosyalar: ${(code.files || []).join(', ')}
Yeni smoke vakaları: ${(code.new_smoke_cases || []).join(', ') || '(yok)'}
Onay bekleyen sabitler (kod ajanına göre): ${(code.pending_constants || []).join('; ') || '(yok)'}
Kod ajanının riskleri: ${code.risks_tr || '(yok)'}
Kod ajanının paylaşılan dosyalardaki tanıtıcıları: ${(code.own_markers || []).join(', ') || '(yok)'}
Kapı raporu (Haiku): ${JSON.stringify(gates)}

Yap:
1. git diff -- <dosyalar> ile diff'i oku (yalnız bu adımın dosyaları; ağaçta başka fark varsa ona dokunma). Ekran PNG'lerini Read ile aç.
2. CLAUDE.md §9 sorularını sor: en kısa ve açık doğru hâli mi; HARITA'daki yardımcı yeniden mi yazılmış; gereksiz soyutlama, savunma, tarihçe yorumu, ölü kod var mı; write-through ve UI/STYLE kanunu; onaylı metin bayt bayt mı bağlanmış; "onay bekliyor" sabitleri tek ayar sabitinde ve [WORKING] işaretli mi.
3. Bu adımın PRD §4 kabul maddelerini tek tek değerlendir (✅/⚠️/❌ + kanıt: dosya:satır, vaka adı, çıktı satırı). Tahmin yazma.
4. Hatalı ya da daha iyi yazılabilir yer, kırmızı kapı ya da kötü ekran varsa KENDİN düzelt (tek tur). Düzelttiysen changed_code=true ve yeniden koşulması gereken kapı komutlarını rerun'a yaz.
5. Kapı kırmızı kalıyorsa ve tek turda düzelemiyorsa verdict=block ve nedenini yaz; commit önermeyeceksin.
6. files_to_commit: yalnız bu adımın dosyaları (sahipsiz farklar ve docs/tasks/faz_ab hariç). commit_message: "Faz B ${S.step}: <ne değişti, oyuncu ne görür>"; metin taşıyorsa sonuna "TR/EN onay bekliyor", sabit taşıyorsa "sabitler onay bekliyor"; Türkçe, tek paragraf başlık + gerekirse kısa gövde.
Commit ATMA.`,
  { label: `inceleme:${S.step}`, phase: 'İnceleme', model: 'opus', effort: 'high', schema: REVIEW_SCHEMA })

let regate = null
if (review && review.verdict === 'approve' && review.changed_code && (review.rerun || []).length) {
  regate = await agent(`${COMMON(S)}

GÖREVİN: İncelemenin düzeltmesinden sonra ${S.step} adımının şu kapılarını yeniden koşmak (Haiku kapı ajanı; KOD DEĞİŞTİRME):
${review.rerun.map((c, i) => `${i + 1}. ${c}`).join('\n')}
Aynı tarama kuralları (Parse Error|Compile Error|Failed to instantiate|SCRIPT ERROR|ERROR:). Ekranlı koşular sırayla.`,
    { label: `yeniden-kapı:${S.step}`, phase: 'Yeniden kapı', model: 'haiku', effort: 'low', schema: GATE_SCHEMA })
}

return { step: S.step, code, gates, review, regate }
}

const [FIRST, ...NEXT] = args.steps
const firstCode = await stepCode(FIRST)
if (!firstCode || firstCode.status !== 'done') return { [FIRST.step]: { step: FIRST.step, code: firstCode } }
log(`${FIRST.step} kodu bitti; ${FIRST.step} kapı+inceleme ve ${NEXT.map(n => n.step).join(', ')} paralel başlıyor`)
const results = await parallel([
  () => stepRest(FIRST, firstCode),
  ...NEXT.map(S => () => stepCode(S).then(code => (code && code.status === 'done') ? stepRest(S, code) : { step: S.step, code })),
])
const out = {}
results.forEach((r, k) => { out[k === 0 ? FIRST.step : NEXT[k - 1].step] = r })
return out
