---
name: artifact-page-verification
description: "Etkileşimli artifact sayfası yayınlamadan önce iki kapı: new Function(script) derleme + başsız Chrome --dump-dom ile gerçek render; TR kesme işareti tek tırnaklı JS dizesini kırar"
metadata:
  type: reference
---

2026-10-07: P1 parodi tuvalinin tur 1 sürümü yayınlandığı günden beri BOŞ çiziliyordu. Oracle kartı
`oc.innerHTML = '...NetSuite'i...'` tek tırnaklı dizeydi, Türkçe ek kesmesi dizeyi kapattı → bütün betik SyntaxError,
kart da seçim paneli de yok. Önceki kontrol yalnız parantez sayıyordu, yakalamadı.

- **Kapı 1:** `node -e "new Function(fs.readFileSync('index.html','utf8').match(/<script>([\s\S]*)<\/script>/)[1])"` —
  derleme hatasını satırıyla verir.
- **Kapı 2 (çalışma anı):** sayfayı doctype + `window.onerror → body[data-err]` ile sar, `chrome.exe --headless=new
  --user-data-dir=<scratchpad>/chrome_prof --virtual-time-budget=5000 --dump-dom file:///...` → kart/düğme sayısını ve
  `data-err`'i grep'le. Chrome eklentisi bağlı değilken de çalışır.
- Kaçış işini heredoc'ta yapma (ters eğik çizgi kaybolur, [[bash-heredoc-backslash-hazard]]); Edit aracıyla düzelt.
- TR metni JS'e gömülecekse çift tırnak ya da JSON.stringify ile göm; tek tırnak + Türkçe ek = kırık.

İlgili: [[browser-render-rig-hazards]] · [[rival-world-prd-2026-10-02]]
