# Builds ekip.html and olay.html for direction 2 "Menajer Masası", revision 2 (after the art director's review).
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ART = "file:///" + os.path.normpath(os.path.join(HERE, "..", "art")).replace("\\", "/")
ME = "file:///" + HERE

FONTS = ("https://fonts.googleapis.com/css2?"
         "family=Barlow+Condensed:wght@500;600;700"
         "&family=IBM+Plex+Sans+Condensed:wght@400;500;600"
         "&family=IBM+Plex+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400"
         "&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;1,8..60,400;1,8..60,500"
         "&display=block")

CSS = r"""
:root{
  /* warm dark ramp: the office's own brown-black, not a cool slate */
  --shell:#14110E; --rail:#181512; --tick:#100E0B;
  --panel:#1E1B18; --panel2:#27231F; --panel3:#2E2924; --line:#3A342D; --line2:#4A4239;
  --ink:#E9E4DA; --ink2:#B3AA9E; --ink3:#9A9184;
  --amber:#F2B53A; --on-amber:#17130A;
  /* one value ramp, no red or orange: dim, light grey, ink, lime, green */
  --s1:#968D80; --s2:#BDB5A9; --s3:#E9E4DA; --s4:#9CC45A; --s5:#4FD27A;
  --pos:#4FD27A; --neg:#EC6A5E; --warn:#E8913A;
  --cond:'Barlow Condensed', sans-serif;
  --sans:'IBM Plex Sans', sans-serif;
  --sansc:'IBM Plex Sans Condensed', 'IBM Plex Sans', sans-serif;
  --serif:'Source Serif 4', serif;
}
*{box-sizing:border-box;margin:0;padding:0}
html,body{width:1920px;height:1080px;overflow:hidden;background:#100E0B}
body{font-family:var(--sans);color:var(--ink);font-variant-numeric:tabular-nums;-webkit-font-smoothing:antialiased}
svg{display:block}
.lbl{font-family:var(--cond);font-weight:600;font-size:14px;letter-spacing:.06em;text-transform:uppercase;color:var(--ink2);line-height:16px}
.grow{flex:1}

/* office */
.office{position:absolute;left:84px;top:54px;width:1836px;height:992px;filter:saturate(.85) brightness(.97)}

/* top bar */
.topbar{position:absolute;left:0;top:0;width:1920px;height:64px;background:var(--shell);border-bottom:1px solid var(--line);display:flex;align-items:stretch;z-index:50}
.brand{width:184px;flex:none;display:flex;align-items:center;gap:12px;padding-left:20px;border-right:1px solid var(--line)}
.brand .co{font-family:var(--cond);font-weight:700;font-size:20px;line-height:22px;color:var(--ink);letter-spacing:.01em}
.brand .ph{display:flex;align-items:center;gap:6px;margin-top:3px}
.brand .ph span{font-family:var(--cond);font-weight:600;font-size:13px;letter-spacing:.08em;color:var(--ink2);line-height:14px}
.brand .dot{width:6px;height:6px;border-radius:3px;background:var(--line2)}
.brand .dot.on{background:var(--ink)}
.met{display:grid;flex:none;padding:0 28px 0 24px;align-content:center;align-items:baseline;row-gap:0;
  grid-template-columns:40px auto 32px 58px auto 32px 1px 32px 52px auto 36px 52px auto;
  grid-template-rows:36px 20px}
.met .k{font-family:var(--cond);font-weight:600;font-size:14px;letter-spacing:.06em;color:var(--ink2);text-transform:uppercase;white-space:nowrap}
.met .kv{font-weight:600;font-size:30px;letter-spacing:-.01em;color:#FFFFFF;white-space:nowrap}
.met .v{font-weight:500;font-size:18px;color:var(--ink);white-space:nowrap}
.met .d{font-weight:500;font-size:15px;color:var(--pos);white-space:nowrap}
.met .u{font-size:13px;font-weight:400;color:var(--ink2);margin-left:3px}
.met .pos{color:var(--pos)}
.met .sep{grid-row:1 / span 2;grid-column:7;align-self:stretch;background:var(--line);margin:4px 0}
.day{flex:1;min-width:300px;display:flex;flex-direction:column;justify-content:center;padding:0 28px 0 28px;border-left:1px solid var(--line)}
.day .t{font-size:16px;font-weight:500;color:var(--ink);line-height:20px;white-space:nowrap}
.wk{display:flex;align-items:center;gap:10px;margin-top:9px}
.wk span{font-size:12px;color:var(--ink2);line-height:12px;flex:none}
.wk .tr{position:relative;flex:1;height:4px;background:var(--line2);border-radius:2px}
.wk .fi{position:absolute;left:0;top:0;height:4px;width:25%;background:var(--ink2);border-radius:2px}
.wk .tk{position:absolute;top:6px;width:1px;height:4px;background:var(--line2)}
.wk .mk{position:absolute;left:25%;top:-5px;width:2px;height:14px;margin-left:-1px;background:var(--ink);border-radius:1px}
.gate{display:none}
.tblock{flex:none;background:var(--panel2);border-left:1px solid var(--line);display:flex;align-items:center;gap:16px;padding:0 16px 0 20px}
.tblock .t{font-weight:600;font-size:22px;line-height:24px;letter-spacing:-.01em;color:var(--ink)}
.spd{display:flex;gap:4px}
.spd b{width:40px;height:32px;display:flex;align-items:center;justify-content:center;font-family:var(--cond);font-weight:700;font-size:16px;letter-spacing:.02em;border-radius:4px;color:var(--ink2);background:var(--panel3)}
.spd b.on{color:var(--ink);background:var(--panel2);box-shadow:inset 0 0 0 2px var(--amber)}
/* gate state: amber frame, amber dot, amber words, no fill */
.topbar.gated .gate{display:flex;flex:none;align-items:center;gap:14px;padding:0 24px 0 22px;border-left:1px solid var(--line)}
.topbar.gated .tg{display:flex;align-items:stretch;box-shadow:inset 0 0 0 2px var(--amber);background:var(--shell)}
.topbar.gated .tblock{background:transparent;border-left:1px solid var(--line)}
.topbar.gated .spd{opacity:.4}
.gdot{width:10px;height:10px;border-radius:5px;background:var(--amber);box-shadow:0 0 0 4px rgba(242,181,58,.22),0 0 0 9px rgba(242,181,58,.08)}
.gate .gl{font-family:var(--cond);font-weight:700;font-size:19px;line-height:20px;letter-spacing:.06em;color:var(--amber);text-transform:uppercase}
.gate .gs{font-size:13px;font-weight:500;line-height:16px;margin-top:3px;color:var(--ink2)}
.tg{display:flex;align-items:stretch}

/* rail */
.rail{position:absolute;left:0;top:64px;width:184px;height:976px;background:var(--rail);border-right:1px solid var(--line);padding-top:12px;z-index:40}
.ri{position:relative;height:48px;display:flex;align-items:center;gap:14px;padding:0 16px 0 20px}
.ri .ic{width:24px;height:24px;color:var(--ink3);flex:none}
.ri .ic svg{width:24px;height:24px}
.ri .nm{font-family:var(--cond);font-weight:600;font-size:17px;letter-spacing:.06em;text-transform:uppercase;color:var(--ink2);flex:1;line-height:20px}
.ri.on{background:var(--panel2)}
.ri.on::before{content:"";position:absolute;left:0;top:8px;bottom:8px;width:3px;background:var(--ink);border-radius:0 2px 2px 0}
.ri.on .nm{color:#FFFFFF}
.ri.on .ic{color:var(--ink)}
.ri.lock .ic,.ri.lock .lt{opacity:.45}
.ri .soon{display:block;font-family:var(--cond);font-weight:600;font-size:13px;letter-spacing:.08em;color:var(--ink3);line-height:14px;margin-top:1px}
.badge{min-width:22px;height:22px;border-radius:11px;background:var(--neg);color:#1B0F0D;font-weight:700;font-size:13px;display:flex;align-items:center;justify-content:center;padding:0 6px}
.rail .bottom{position:absolute;left:0;right:0;bottom:12px}

/* ticker */
.ticker{position:absolute;left:0;top:1040px;width:1920px;height:40px;background:var(--tick);border-top:1px solid var(--line);display:flex;align-items:center;z-index:50}
.ticker .tgl{width:56px;height:39px;flex:none;display:flex;align-items:center;justify-content:center;border-right:1px solid var(--line);color:var(--ink3)}
.ticker .run{flex:1;overflow:hidden;white-space:nowrap;font-size:14px;line-height:40px;padding-left:16px;-webkit-mask-image:linear-gradient(90deg,#000 0,#000 calc(100% - 64px),transparent 100%)}
.ticker .pub{font-weight:600;margin-right:8px}
.ticker .hl{color:var(--ink2)}
.ticker .sep{color:var(--ink3);white-space:pre}

/* floating office overlays, one family */
.float{background:rgba(30,27,24,.96);border:1px solid var(--line);border-radius:6px;box-shadow:0 10px 24px rgba(0,0,0,.42)}
.build{position:absolute;left:1576px;top:88px;width:320px;z-index:20}
.build .hd{display:flex;align-items:center;gap:10px;padding:12px 16px;border-bottom:1px solid var(--line)}
.build .hd b{font-family:var(--cond);font-weight:700;font-size:18px;letter-spacing:.02em}
.build .rw{display:flex;align-items:center;gap:10px;padding:10px 16px;border-bottom:1px solid var(--line)}
.build .rw .k{font-family:var(--cond);font-weight:600;font-size:14px;letter-spacing:.06em;color:var(--ink)}
.build .rw .v{font-size:14px;color:var(--ink2)}
.build .act{display:flex;align-items:center;gap:8px;padding:10px 16px;font-family:var(--cond);font-weight:600;font-size:14px;letter-spacing:.06em;color:var(--ink)}
.notice{position:absolute;left:1544px;top:968px;width:352px;height:52px;display:flex;align-items:center;gap:12px;padding:0 16px;z-index:20}
.notice .dt{width:10px;height:10px;border-radius:5px;background:var(--pos);box-shadow:0 0 0 3px rgba(79,210,122,.18)}
.notice .tgn{font-family:var(--cond);font-weight:600;font-size:14px;letter-spacing:.08em;color:var(--ink2)}
.notice .tx{font-size:15px;font-weight:500;color:var(--ink)}
.move{position:absolute;left:208px;top:976px;height:44px;display:flex;align-items:center;gap:10px;padding:0 16px 0 14px;font-size:15px;font-weight:500;z-index:20}

/* scrim: light overall dim plus a halo that ends 160 px from the window edge */
.veil{position:absolute;left:184px;top:64px;width:1736px;height:976px;z-index:10;background:rgba(16,14,11,.16)}
.halo{position:absolute;z-index:11;border-radius:8px;background:rgba(16,14,11,.6);box-shadow:0 0 110px 50px rgba(16,14,11,.55)}

/* window */
.win{position:absolute;background:var(--panel);border:1px solid var(--line2);border-radius:8px;box-shadow:0 32px 64px rgba(0,0,0,.55),0 8px 16px rgba(0,0,0,.38),0 1px 0 rgba(255,240,220,.05) inset;z-index:30;overflow:hidden}
.whd{background:var(--panel2);display:flex;align-items:center;padding:0 16px 0 24px;border-bottom:1px solid var(--line)}
.whd h1{font-family:var(--cond);font-weight:700;font-size:40px;line-height:40px;letter-spacing:.02em;text-transform:uppercase;color:#FFF}
.x{width:36px;height:36px;display:flex;align-items:center;justify-content:center;border-radius:4px;color:var(--ink2)}
.btn-primary{height:40px;display:flex;align-items:center;gap:8px;padding:0 20px 0 16px;background:var(--amber);color:var(--on-amber);border-radius:4px;font-family:var(--cond);font-weight:700;font-size:19px;letter-spacing:.03em;white-space:nowrap}
.btn-ghost{height:40px;display:flex;align-items:center;gap:8px;padding:0 16px;border:1px solid var(--line2);border-radius:4px;color:var(--ink);font-size:15px;font-weight:500;white-space:nowrap}
.tag{display:inline-flex;align-items:center;height:22px;padding:0 8px;border-radius:3px;font-family:var(--cond);font-weight:700;font-size:13px;letter-spacing:.07em;white-space:nowrap}
.tag.new{border:1px solid #6A5F52;color:#DCD4C8}
.tag.bad{background:rgba(236,106,94,.16);border:1px solid rgba(236,106,94,.6);color:#F49A90}
.face{width:32px;height:32px;border-radius:16px;background:#2E2924;box-shadow:0 0 0 1px var(--line2);overflow:hidden;flex:none}
.face img{width:100%;height:100%;display:block}
"""

ICON = {
  "logo": '<svg width="32" height="32" viewBox="0 0 32 32"><rect width="32" height="32" rx="6" fill="#E9E4DA"/><path d="M9.5 8 H14 V18 A2 2 0 0 0 18 18 V8 H22.5 V18.2 A6.5 6.5 0 0 1 9.5 18.2Z" fill="#181512"/></svg>',
  "urun": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.6 L20.6 7.3 L12 12 L3.4 7.3Z"/><path d="M3.4 8.6 L11.3 12.9 V21.6 L3.4 17.2Z" opacity=".72"/><path d="M12.7 12.9 L20.6 8.6 V17.2 L12.7 21.6Z" opacity=".45"/></svg>',
  "satis": '<svg viewBox="0 0 24 24" fill="currentColor"><path fill-rule="evenodd" d="M2.8 11.9 V4.3 A1.5 1.5 0 0 1 4.3 2.8 H11.9 L21.2 12.1 L12.1 21.2 Z M7.6 5.7 A1.9 1.9 0 1 0 7.6 9.5 A1.9 1.9 0 1 0 7.6 5.7Z"/></svg>',
  "ekip": '<svg viewBox="0 0 24 24" fill="currentColor"><circle cx="16.6" cy="7.2" r="2.9" opacity=".55"/><path d="M14.2 12.7 C15 12.3 15.8 12.1 16.6 12.1 C19.6 12.1 21.6 14.3 21.6 18.2 H17.2 C17 15.8 16 14 14.2 12.7Z" opacity=".55"/><circle cx="9" cy="8" r="3.6"/><path d="M2.4 20.4 C2.4 15.9 5.4 13.4 9 13.4 C12.6 13.4 15.6 15.9 15.6 20.4Z"/></svg>',
  "finans": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M4 16.4 V18.6 C4 20 7.6 21.2 12 21.2 C16.4 21.2 20 20 20 18.6 V16.4 C20 17.8 16.4 19 12 19 C7.6 19 4 17.8 4 16.4Z" opacity=".5"/><path d="M4 11.6 V13.8 C4 15.2 7.6 16.4 12 16.4 C16.4 16.4 20 15.2 20 13.8 V11.6 C20 13 16.4 14.2 12 14.2 C7.6 14.2 4 13 4 11.6Z" opacity=".72"/><ellipse cx="12" cy="7.6" rx="8" ry="3"/><path d="M4 7.9 V9 C4 10.4 7.6 11.6 12 11.6 C16.4 11.6 20 10.4 20 9 V7.9 C19.5 9.4 16.1 10.6 12 10.6 C7.9 10.6 4.5 9.4 4 7.9Z" opacity=".85"/></svg>',
  "kisisel": '<svg viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="7.6" r="4.2"/><path d="M3.8 21 C3.8 16.2 7.4 13.6 12 13.6 C16.6 13.6 20.2 16.2 20.2 21Z"/></svg>',
  "pazarlama": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M2.8 9.6 H7.4 L17.2 4.2 V19.8 L7.4 14.4 H2.8Z"/><path d="M5.6 14.9 H8.6 L10.2 20.4 H7.2Z" opacity=".7"/><path d="M19.4 9.2 A3.6 3.6 0 0 1 19.4 14.8" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>',
  "arge": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8.6 2.8 H15.4 V4.8 H14.2 V9.1 L20 18.6 A1.7 1.7 0 0 1 18.5 21.2 H5.5 A1.7 1.7 0 0 1 4 18.6 L9.8 9.1 V4.8 H8.6Z" opacity=".55"/><path d="M7.1 13.6 H16.9 L20 18.6 A1.7 1.7 0 0 1 18.5 21.2 H5.5 A1.7 1.7 0 0 1 4 18.6Z"/></svg>',
  "olaylar": '<svg viewBox="0 0 24 24" fill="currentColor"><rect x="2.8" y="5.2" width="18.4" height="14" rx="1.8" opacity=".55"/><path d="M2.8 7 A1.8 1.8 0 0 1 4.6 5.2 H19.4 A1.8 1.8 0 0 1 21.2 7 V7.6 L12 13.8 L2.8 7.6Z"/></svg>',
  "ayarlar": '<svg viewBox="0 0 24 24" fill="currentColor"><path fill-rule="evenodd" d="M19.11 9.32 L21.95 9.77 L21.95 14.23 L19.11 14.68 L18.92 15.14 L20.61 17.46 L17.46 20.61 L15.14 18.92 L14.68 19.11 L14.23 21.95 L9.77 21.95 L9.32 19.11 L8.86 18.92 L6.54 20.61 L3.39 17.46 L5.08 15.14 L4.89 14.68 L2.05 14.23 L2.05 9.77 L4.89 9.32 L5.08 8.86 L3.39 6.54 L6.54 3.39 L8.86 5.08 L9.32 4.89 L9.77 2.05 L14.23 2.05 L14.68 4.89 L15.14 5.08 L17.46 3.39 L20.61 6.54 L18.92 8.86Z M12 8.6 A3.4 3.4 0 1 0 12 15.4 A3.4 3.4 0 1 0 12 8.6Z"/></svg>',
  # skill heads (department glyphs, same family as the rail)
  "tasarim": '<svg viewBox="0 0 24 24"><defs><mask id="nibm"><rect width="24" height="24" fill="#fff"/><circle cx="12" cy="12.6" r="2" fill="#000"/><path d="M12 14 V22.5" stroke="#000" stroke-width="1.6"/></mask></defs><g mask="url(#nibm)" fill="currentColor"><path d="M12 22 L5.6 12.4 L8.3 5.6 H15.7 L18.4 12.4 Z"/><rect x="7.6" y="2" width="8.8" height="2.4" rx=".7"/></g></svg>',
  "kod": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6.5 L2.8 12 L8 17.5 M16 6.5 L21.2 12 L16 17.5 M13.6 4.6 L10.4 19.4"/></svg>',
  "test": '<svg viewBox="0 0 24 24" fill="currentColor"><circle cx="10.2" cy="10.2" r="7" opacity=".5"/><path d="M6.9 10.4 L9.3 12.8 L13.8 8" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"/><path d="M15.3 15.3 L21 21" stroke="currentColor" stroke-width="3" stroke-linecap="round"/></svg>',
  "kulak": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M4 13.4 A8 8 0 0 1 20 13.4 V14 H17.8 V13.4 A5.8 5.8 0 0 0 6.2 13.4 V14 H4Z"/><rect x="3" y="13" width="5" height="8" rx="1.6"/><rect x="16" y="13" width="5" height="8" rx="1.6"/></svg>',
  # traits
  "lider": '<svg viewBox="0 0 24 24" fill="currentColor"><rect x="4.6" y="2.8" width="2.2" height="18.6" rx="1"/><path d="M7.8 3.8 H19.6 L16.8 8.3 L19.6 12.8 H7.8Z"/></svg>',
  "iskolik": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M14.6 3 A9 9 0 1 0 21 16.2 A7.4 7.4 0 0 1 14.6 3Z"/></svg>',
  "sadik": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><circle cx="12" cy="5" r="2.2"/><path d="M12 7.2 V20.6 M7.6 10.4 H16.4 M4.4 13.2 A7.6 7.6 0 0 0 19.6 13.2"/></svg>',
  "titiz": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="M2.6 12.8 L6.6 16.8 L14.2 8.6"/><path d="M10.6 16.8 L21.4 6.2"/></svg>',
  "cabuk": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M13.8 2.4 L5.2 13.6 H11 L9.6 21.6 L18.8 9.8 H13Z"/></svg>',
  # misc
  "warn": '<svg viewBox="0 0 24 24"><path d="M12 2.8 L22.2 20.4 H1.8Z" fill="currentColor"/><path d="M12 9.2 V14.2" stroke="#2A1A17" stroke-width="2.4" stroke-linecap="round"/><circle cx="12" cy="17.2" r="1.35" fill="#2A1A17"/></svg>',
  "clock": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="8.6"/><path d="M12 7.2 V12 L15.4 14"/></svg>',
  "plus": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.8" stroke-linecap="round"><path d="M12 5 V19 M5 12 H19"/></svg>',
  "close": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M6 6 L18 18 M18 6 L6 18"/></svg>',
  "chev": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M9 5.5 L15.5 12 L9 18.5"/></svg>',
  "lock": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M7.4 10 V7.6 A4.6 4.6 0 0 1 16.6 7.6 V10" fill="none" stroke="currentColor" stroke-width="2.2"/><rect x="4.6" y="10" width="14.8" height="11" rx="2"/></svg>',
  "pause": '<svg viewBox="0 0 24 24" fill="currentColor"><rect x="6.2" y="4.6" width="4" height="14.8" rx="1"/><rect x="13.8" y="4.6" width="4" height="14.8" rx="1"/></svg>',
  "news": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M3 5.4 A1.4 1.4 0 0 1 4.4 4 H16.6 A1.4 1.4 0 0 1 18 5.4 V18.4 A1.6 1.6 0 0 0 19.6 20 H5 A2 2 0 0 1 3 18Z" opacity=".55"/><rect x="5.6" y="6.8" width="9.8" height="3.4" rx=".6"/><rect x="5.6" y="12" width="9.8" height="1.8" rx=".6"/><rect x="5.6" y="15.4" width="6.6" height="1.8" rx=".6"/><path d="M18.8 8.4 H21 V18.4 A1.6 1.6 0 0 1 19.4 20 A1.6 1.6 0 0 1 18.8 18.4Z"/></svg>',
  "shield": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.6 L20 5.6 V11.4 C20 16.2 16.6 19.8 12 21.4 C7.4 19.8 4 16.2 4 11.4 V5.6Z"/></svg>',
  "play": '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M7 4.6 L19.4 12 L7 19.4Z"/></svg>',
  "move": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3 V21 M3 12 H21 M12 3 L9.2 5.8 M12 3 L14.8 5.8 M12 21 L9.2 18.2 M12 21 L14.8 18.2 M3 12 L5.8 9.2 M3 12 L5.8 14.8 M21 12 L18.2 9.2 M21 12 L18.2 14.8"/></svg>',
}


def ic(name, size=24, color=None):
    s = ICON[name]
    style = f'width:{size}px;height:{size}px;flex:none' + (f';color:{color}' if color else '')
    return f'<span style="display:inline-flex;{style}">{s.replace("<svg ", "<svg width=\"100%\" height=\"100%\" ", 1)}</span>'


def topbar(gate=False):
    gate_html = '''<div class="gate"><span class="gdot"></span><div><div class="gl">Cevap bekliyor</div><div class="gs">Frank'in teklifi</div></div></div>'''
    ticks = "".join(f'<i class="tk" style="left:{i * 12.5}%"></i>' for i in range(1, 8))
    return f'''<header class="topbar{" gated" if gate else ""}">
  <div class="brand">{ICON["logo"]}<div><div class="co">Unicorn Inc.</div>
    <div class="ph"><span>BOOTSTRAP</span><i class="dot on"></i><i class="dot"></i><i class="dot"></i></div></div></div>
  <div class="met">
    <span class="k">Kasa</span><span class="kv">$10.000</span><span></span>
    <span class="k">Runway</span><span class="v pos" style="font-weight:600">Artıda</span><span></span>
    <span class="sep"></span><span></span>
    <span class="k">MRR</span><span class="v">$4,0K</span><span></span>
    <span class="k">BURN</span><span class="v">$1,5K<span class="u">/ay</span></span>
    <span class="k">NET</span><span class="d">+$2,5K<span class="u">/ay</span></span><span></span>
    <span></span><span></span><span></span>
    <span></span>
    <span class="k">MARKA</span><span class="v">50</span><span></span>
    <span class="k">İTİBAR</span><span class="v">0</span>
  </div>
  <div class="day"><div class="t">Hafta 14 · Nisan 2026</div>
    <div class="wk"><span>09.00</span><div class="tr"><div class="fi"></div>{ticks}<div class="mk"></div></div><span>17.00</span></div></div>
  <div class="tg">
    {gate_html}
    <div class="tblock"><div class="t">11:00</div>
      <div class="spd"><b class="on">II</b><b>1x</b><b>2x</b><b>3x</b><b>4x</b></div></div>
  </div>
</header>'''


RAIL = [("urun", "Ürün", None), ("satis", "Satış", 1), ("ekip", "Ekip", 1), ("finans", "Finans", None),
        ("kisisel", "Kişisel", None), ("pazarlama", "Pazarlama", "lock"), ("arge", "Ar-Ge", None),
        ("olaylar", "Olaylar", None)]


def rail(active):
    rows = []
    for key, name, badge in RAIL:
        cls = "ri" + (" on" if key == active else "") + (" lock" if badge == "lock" else "")
        if badge == "lock":
            rows.append(f'<div class="{cls}"><span class="ic">{ICON[key]}</span><span class="nm"><span class="lt">{name}</span><span class="soon">YAKINDA</span></span></div>')
            continue
        right = f'<span class="badge">{badge}</span>' if badge else ""
        rows.append(f'<div class="{cls}"><span class="ic">{ICON[key]}</span><span class="nm">{name}</span>{right}</div>')
    return f'''<nav class="rail" lang="tr">
  {"".join(rows)}
  <div class="bottom"><div class="ri"><span class="ic">{ICON["ayarlar"]}</span><span class="nm">Ayarlar</span></div></div>
</nav>'''


PUBS = {"Sektör Telgrafı": "#7FB6DE", "Ekonomi Postası": "#E3A0BE", "TeknoGündem": "#6FC9B6", "Girişim Bülteni": "#BCA7E8"}
NEWS = [("Sektör Telgrafı", "Teknoloji kampüslerinde staj kontenjanları rekor kırdı."),
        ("Ekonomi Postası", "Sunucu kiralarında indirim sezonu; altyapı ekipleri pazarlıkta."),
        ("TeknoGündem", "Sanayi bölgelerinde dijital dönüşüm ihaleleri sıraya girdi."),
        ("Girişim Bülteni", "Melek yatırım ağları yeni dönem başvurularını açtı."),
        ("Sektör Telgrafı", "Yazılım ihracatçıları yeni pazar arayışında; fuar takvimi dolu."),
        ("Ekonomi Postası", "Ofis pazarında küçülme sürüyor; paylaşımlı katlar dolu."),
        ("TeknoGündem", "Teknoloji basınında değerleme sohbeti hiç bitmiyor."),
        ("Ekonomi Postası", "Tohum yatırımcıları takvim dolduruyor; erken aşamada trafik yoğun.")]


def ticker():
    items = []
    for i, (p, h) in enumerate(NEWS):
        if i:
            items.append('<span class="sep">   ·   </span>')
        items.append(f'<span class="pub" style="color:{PUBS[p]}">{p}</span><span class="hl">{h}</span>')
    return f'''<footer class="ticker">
  <div class="tgl">{ic("news", 20)}</div>
  <div class="run">{"".join(items)}</div>
</footer>'''


def overlays():
    return f'''<div class="build float">
  <div class="hd">{ic("urun", 20, "#B3AA9E")}<b>Unicorn Inc. v1</b></div>
  <div class="rw">{ic("shield", 16, "#B3AA9E")}<span class="k">DESTEK</span><span class="v">DOĞRULANMIŞ 0</span></div>
  <div class="act">{ic("play", 12, "#E9E4DA")}DÜZELTME BAŞLAT</div>
</div>
<div class="notice float"><span class="dt"></span><span class="tgn">NORDICA</span><span class="tx">Büyüme talebi masada</span></div>
<div class="move float">{ic("move", 18, "#B3AA9E")}Ofisi taşı</div>'''


MEASURE = r"""<script>
window.addEventListener('load',()=>{document.fonts.ready.then(()=>{
 const out=[];
 document.querySelectorAll('.win *').forEach(e=>{
   if(e.children.length===0 && e.textContent.trim() && e.scrollWidth>e.clientWidth+1 && getComputedStyle(e).display!=='inline'){
     out.push('overflow '+e.className+' "'+e.textContent.trim().slice(0,30)+'" '+e.scrollWidth+'>'+e.clientWidth);}
 });
 document.querySelectorAll('.cell').forEach(e=>{
   const r=e.getBoundingClientRect();
   e.querySelectorAll('*').forEach(c=>{const q=c.getBoundingClientRect(); if(q.width&&(q.right>r.right+0.5||q.left<r.left-0.5)) out.push('cellspill '+(e.dataset.c||'')+' '+c.className+' "'+c.textContent.trim().slice(0,24)+'" '+Math.round(q.left)+'-'+Math.round(q.right)+' in '+Math.round(r.left)+'-'+Math.round(r.right));});
 });
 const pre=document.createElement('pre');pre.id='report';pre.style.display='none';pre.textContent=out.join('\n')||'clean';document.body.appendChild(pre);
});});
</script>"""


def page(title, extra_css, body):
    html = f'''<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>{title}</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="{FONTS}" rel="stylesheet">
<style>{CSS}{extra_css}</style></head>
<body>
<img class="office" src="{ART}/office_game.png" alt="">
{body}
{MEASURE}
</body></html>'''
    if re.findall(r"[–—]", html):
        sys.exit("dash found")
    return html


# ---------------- EKIP ----------------
SK = ["Ürün", "Tasarım", "Yazılım", "Test", "Satış", "Müşteri İlişkileri", "Liderlik"]
SK_IC = ["urun", "tasarim", "kod", "test", "satis", "kulak"]
PEOPLE = {
    "elif": dict(name="Elif Demir", role="Ürün Yöneticisi", sk=[7, 6, 4, 4, 4, 4, 6], main=0, sec=1, task="Yapımda görev alıyor",
                 durum=("chip", "YENİ"), huy=("lider", "Gerçek lider"), maas="$9.800", moral=72),
    "deniz": dict(name="Deniz Arslan", role="UX/UI Designer", sk=[5, 6, 3, 3, 3, 3, 2], main=1, sec=0, task="Yapımda görev alıyor",
                  durum=None, huy=("iskolik", "İşkolik"), maas="$7.400", moral=38),
    "mert": dict(name="Mert Yıldız", role="Yazılım Mühendisi", sk=[4, 4, 8, 7, 4, 4, 3], main=2, sec=3, task="Yapımda görev alıyor",
                 durum=("text", "İzinde · 2 hafta kaldı"), huy=("sadik", "Sadık"), maas="$11.200", moral=61, away=True),
    "selin": dict(name="Selin Kaya", role="Test Mühendisi", sk=[3, 3, 4, 5, 3, 3, 1], main=3, sec=2, task="Test ediyor",
                  durum=("risk", "AYRILABİLİR"), huy=("titiz", "Titiz"), maas="$6.900", moral=22),
    "burak": dict(name="Burak Şahin", role="Satış Temsilcisi", sk=[3, 3, 3, 3, 6, 3, 2], main=4, sec=None, task="Satışta görev alıyor",
                  durum=("chip", "YENİ"), huy=("cabuk", "Çabuk kapar"), maas="$8.300", moral=55),
}
GROUPS = [("ÜRÜN & TASARIM", ["deniz", "elif"], [0, 1], "urun"),
          ("GELİŞTİRME EKİBİ", ["selin", "mert"], [2, 3], "kod"),
          ("SATIŞ", ["burak"], [4], "satis"),
          ("MÜŞTERİ İLİŞKİLERİ", [], [5], "kulak")]


def band(v):
    return "var(--s1)" if v <= 2 else "var(--s2)" if v <= 4 else "var(--s3)" if v <= 6 else "var(--s4)" if v <= 8 else "var(--s5)"


def moral_col(m):
    return "var(--neg)" if m < 35 else "var(--warn)" if m < 50 else "var(--pos)"


# face | name | 6 skills | liderlik | görev | deneyim | durum | huy | maaş | moral
WID = [44, 168, 46, 46, 46, 46, 46, 46, 70, 150, 68, 146, 128, 76, 128]
COLS = " ".join(f"{w}px" for w in WID)
XS = [0]
for _w in WID:
    XS.append(XS[-1] + _w)

EKIP_CSS = r"""
.ekip{left:208px;top:88px;width:1304px}
.ekip .whd{height:84px}
.ekip .whd h1{margin-right:36px}
.kpi{display:flex;flex-direction:column;padding:0 28px;border-left:1px solid var(--line)}
.kpi .v{font-weight:600;font-size:26px;line-height:30px;color:var(--ink);margin-top:2px}
.legend{display:flex;flex-direction:column;padding:0 28px;border-left:1px solid var(--line);margin-right:12px}
.legend .rg{display:flex;gap:16px;margin-top:6px}
.legend b{font-weight:600;font-size:17px;line-height:24px}
.ctl{height:64px;display:flex;align-items:center;padding:0 24px;border-bottom:1px solid var(--line);gap:12px}
.tabs{display:flex;height:64px;gap:28px;align-items:stretch}
.tab{display:flex;align-items:center;font-family:var(--cond);font-weight:600;font-size:18px;letter-spacing:.07em;color:var(--ink2);position:relative}
.tab.on{color:#FFF}
.tab.on::after{content:"";position:absolute;left:0;right:0;bottom:-1px;height:2px;background:var(--ink)}
.chip-h{height:40px;display:flex;align-items:center;gap:8px;padding:0 14px;border:1px solid var(--line2);border-radius:4px;font-size:15px;color:var(--ink)}
.body{padding:16px 24px 20px}
.risk{height:52px;display:flex;align-items:center;gap:12px;padding:0 12px 0 14px;background:#2B1A17;border:1px solid #6E3129;border-radius:6px;margin-bottom:8px}
.risk .nm{font-weight:600;font-size:16px;color:#FFF}
.risk .mo{display:flex;align-items:baseline;gap:6px;margin-left:4px}
.risk .mo .k{font-family:var(--cond);font-weight:600;font-size:14px;letter-spacing:.06em;color:#F2A49C}
.risk .mo .v{font-weight:700;font-size:18px;color:var(--neg)}
.risk .go{margin-left:auto;color:#F2A49C}
.grid{display:grid;grid-template-columns:""" + COLS + r""";align-items:center}
.th{height:56px;border-bottom:1px solid var(--line);position:relative;align-items:end;padding-bottom:9px}
.th .h{font-family:var(--cond);font-weight:600;font-size:14px;letter-spacing:.05em;text-transform:uppercase;color:var(--ink2);line-height:16px;white-space:nowrap}
.th .c{text-align:center}
.th .gi{display:flex;justify-content:center;color:var(--ink2);padding-bottom:0}
.th .span{position:absolute;top:6px;height:22px;border-bottom:1px solid var(--line2);text-align:center}
.th .span .h{line-height:16px}
.tip{position:absolute;z-index:5;background:#0F0D0B;border:1px solid var(--line2);border-radius:4px;padding:0 10px;height:30px;display:flex;align-items:center;font-size:13px;color:var(--ink);white-space:nowrap;box-shadow:0 6px 14px rgba(0,0,0,.45)}
.tip::before{content:"";position:absolute;left:50%;top:-6px;margin-left:-6px;border:6px solid transparent;border-top:0;border-bottom-color:var(--line2)}
.grp{height:40px;display:flex;align-items:flex-end;padding-bottom:7px;gap:10px;font-family:var(--cond);font-weight:600;font-size:15px;letter-spacing:.07em;color:var(--ink)}
.grp::after{content:"";flex:1;height:1px;background:var(--line);margin-bottom:5px}
.rows{position:relative}
.row{height:40px;border-bottom:1px solid rgba(58,52,45,.75);position:relative}
.who .n{font-weight:600;font-size:15px;line-height:18px;color:#FFF;white-space:nowrap}
.who .r{font-family:var(--sansc);font-size:13px;color:var(--ink2);line-height:16px;margin-top:1px;white-space:nowrap}
.sk{text-align:center;font-size:16px;font-weight:500;line-height:40px;height:40px;position:relative}
.sk.main{font-weight:700}
.sk.main::after{content:"";position:absolute;left:50%;bottom:6px;width:16px;height:2px;margin-left:-8px;background:currentColor;border-radius:1px}
.sk.sec{font-weight:600}
.band{position:absolute;top:0;bottom:0;background:rgba(233,228,218,.07);pointer-events:none}
.lead{border-left:1px solid var(--line)}
.task{font-family:var(--sansc);font-size:15px;color:var(--ink);padding-left:16px;white-space:nowrap}
.xp{display:flex;align-items:center;gap:8px;padding-left:4px}
.xp .tr{width:32px;height:4px;border-radius:2px;background:var(--line2)}
.xp span{font-size:14px;color:var(--ink2)}
.durum{padding-left:4px;white-space:nowrap;font-family:var(--sansc);font-size:15px;color:var(--ink)}
.huy{display:flex;align-items:center;gap:8px;padding-left:4px;white-space:nowrap}
.huy .bx{width:26px;height:26px;border-radius:5px;background:var(--panel3);border:1px solid var(--line2);display:flex;align-items:center;justify-content:center;color:var(--ink);flex:none}
.huy .tx{font-family:var(--sansc);font-size:13px;color:var(--ink2)}
.maas{text-align:right;font-size:15px;font-weight:400;color:var(--ink);padding-right:16px}
.mor{display:flex;align-items:center;gap:10px}
.mor .v{width:26px;text-align:right;font-weight:700;font-size:16px}
.mor .tr{position:relative;width:92px;height:6px;border-radius:3px;background:var(--line2)}
.mor .fi{position:absolute;left:0;top:0;height:6px;border-radius:3px}
.mor .nt{position:absolute;top:-3px;width:1px;height:12px;background:#8A8174}
/* on leave: dim only the face, numbers and bars; words go to secondary ink and stay readable */
.row.away .face, .row.away .sk, .row.away .xp .tr, .row.away .mor{opacity:.45}
.row.away .face{filter:grayscale(.8)}
.row.away .who .n, .row.away .task, .row.away .maas, .row.away .huy .bx{color:var(--ink2)}
.empty{height:52px;display:flex;align-items:center;gap:16px;padding-left:4px}
.empty .t{font-size:15px;color:var(--ink2)}
.btn-ghost.sm{height:34px;font-family:var(--cond);font-weight:600;font-size:17px;letter-spacing:.03em;padding:0 14px 0 10px}
"""


def ekip_rows():
    out = []
    th = ['<div></div>', '<div class="h">Çalışan</div>']
    for i in range(6):
        th.append(f'<div class="gi">{ic(SK_IC[i], 20)}</div>')
    th.append('<div class="h c lead" style="align-self:stretch;display:flex;align-items:flex-end;justify-content:center">Liderlik</div>')
    th += ['<div class="h" style="padding-left:16px">Görev</div>', '<div class="h" style="padding-left:4px">Deneyim</div>',
           '<div class="h" style="padding-left:4px">Durum</div>', '<div class="h" style="padding-left:4px">Huy</div>',
           '<div class="h" style="text-align:right;padding-right:16px">Maaş</div>', '<div class="h">Moral</div>']
    span = f'<div class="span" style="left:{XS[2] + 6}px;width:{XS[8] - XS[2] - 12}px"><span class="h">Roller</span></div>'
    mi_c = (XS[7] + XS[8]) // 2
    tip = f'<div class="tip" style="left:{mi_c - 66}px;top:62px;width:132px;justify-content:center">Müşteri İlişkileri</div>'
    out.append(f'<div class="grid th">{"".join(th)}{span}{tip}</div>')
    for gname, members, cols, gic in GROUPS:
        out.append(f'<div class="grp">{ic(gic, 18, "#9A9184")}{gname}</div>')
        if not members:
            out.append(f'''<div class="empty"><span class="t">Henüz kimse yok</span>
  <div class="btn-ghost sm">{ic("plus", 16)}İşe alım başlat</div></div>''')
            continue
        bands = "".join(f'<div class="band" style="left:{XS[2 + c]}px;width:{WID[2 + c]}px"></div>' for c in cols)
        rows = []
        for key in members:
            p = PEOPLE[key]
            cells = [f'<div class="cell" data-c="face"><div class="face"><img src="{ME}/face_{key}.png" alt=""></div></div>',
                     f'<div class="cell who" data-c="who"><div class="n">{p["name"]}</div><div class="r">{p["role"]}</div></div>']
            for i, v in enumerate(p["sk"]):
                cls = "sk" + (" main" if i == p["main"] else "") + (" sec" if i == p["sec"] else "") + (" lead" if i == 6 else "")
                cells.append(f'<div class="{cls}" style="color:{band(v)}">{v}</div>')
            cells.append(f'<div class="cell task" data-c="task">{p["task"]}</div>')
            cells.append('<div class="cell xp" data-c="xp"><div class="tr"></div><span>%0</span></div>')
            d = p["durum"]
            if d is None:
                cells.append('<div class="durum"></div>')
            elif d[0] == "chip":
                cells.append(f'<div class="cell durum" data-c="durum"><span class="tag new">{d[1]}</span></div>')
            elif d[0] == "risk":
                cells.append(f'<div class="cell durum" data-c="durum"><span class="tag bad">{d[1]}</span></div>')
            else:
                cells.append(f'<div class="cell durum" data-c="durum"><span>{d[1]}</span></div>')
            cells.append(f'<div class="cell huy" data-c="huy"><span class="bx">{ic(p["huy"][0], 16)}</span><span class="tx">{p["huy"][1]}</span></div>')
            cells.append(f'<div class="cell maas" data-c="maas">{p["maas"]}</div>')
            m = p["moral"]
            col = moral_col(m)
            cells.append(f'''<div class="cell mor" data-c="mor"><span class="v" style="color:{col}">{m}</span><div class="tr"><div class="fi" style="width:{m}%;background:{col}"></div><div class="nt" style="left:35%"></div></div></div>''')
            rows.append(f'<div class="grid row{" away" if p.get("away") else ""}">{"".join(cells)}</div>')
        out.append(f'<div class="rows">{bands}{"".join(rows)}</div>')
    return "\n".join(out)


def legend():
    rng = [("1-2", "s1"), ("3-4", "s2"), ("5-6", "s3"), ("7-8", "s4"), ("9-10", "s5")]
    return '<div class="legend"><span class="lbl">Roller</span><div class="rg">' + "".join(f'<b style="color:var(--{c})">{t}</b>' for t, c in rng) + '</div></div>'


def ekip_page():
    win = f'''<section class="win ekip" lang="tr">
  <div class="whd">
    <h1>Ekip</h1>
    <div class="kpi"><span class="lbl">Çalışan</span><span class="v">5</span></div>
    <div class="kpi"><span class="lbl">Ortalama moral</span><span class="v">50</span></div>
    <div class="kpi"><span class="lbl">Aylık maaş yükü</span><span class="v">$43.600</span></div>
    <div class="grow"></div>
    {legend()}
    <div class="x">{ic("close", 20)}</div>
  </div>
  <div class="ctl">
    <div class="tabs"><div class="tab on">KADRO</div><div class="tab">GÖREVLER</div></div>
    <div class="grow"></div>
    <div class="chip-h">{ic("clock", 18, "#B3AA9E")}09:00 ile 17:00 arası</div>
    <div class="btn-primary">{ic("plus", 18)}İşe alım başlat</div>
  </div>
  <div class="body">
    <div class="risk">{ic("warn", 22, "#EC6A5E")}<div class="face"><img src="{ME}/face_selin.png" alt=""></div>
      <span class="nm">Selin Kaya</span><span class="mo"><span class="k">MORAL</span><span class="v">22</span></span>
      <span class="tag bad" style="margin-left:4px">AYRILABİLİR</span>
      <span class="go">{ic("chev", 20)}</span></div>
    {ekip_rows()}
  </div>
</section>'''
    body = f'''<div class="veil"></div>
<div class="halo" id="halo"></div>
{overlays()}
{win}
{topbar(False)}
{rail("ekip")}
{ticker()}
<script>(function(){{var w=document.querySelector('.win'),h=document.getElementById('halo');h.style.left=w.offsetLeft+'px';h.style.top=w.offsetTop+'px';h.style.width=w.offsetWidth+'px';h.style.height=w.offsetHeight+'px';}})()</script>'''
    return page("Ekip", EKIP_CSS, body)


# ---------------- OLAY: Olaylar inbox with the must-respond message open ----------------
TOPIC = {"MENTOR": "#C9A8E6", "SATIŞ": "#6FC9B6", "EKİP": "#7FB6DE"}

OLAY_CSS = r"""
.inbox{left:208px;top:88px;width:1240px}
.inbox .whd{height:64px}
.inbox .whd h1{font-size:36px;line-height:36px}
.ib{display:flex;align-items:stretch}
.list{width:400px;flex:none;border-right:1px solid var(--line);background:#1A1714}
.lgh{height:40px;display:flex;align-items:center;padding:0 20px;border-bottom:1px solid var(--line)}
.msg{position:relative;height:100px;padding:14px 20px 0 24px;border-bottom:1px solid var(--line)}
.msg .l3{font-size:14px;line-height:20px;color:var(--ink2);margin-top:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.msg.on{background:var(--panel2)}
.msg.on::before{content:"";position:absolute;left:0;top:10px;bottom:10px;width:3px;background:var(--ink);border-radius:0 2px 2px 0}
.msg .l1{display:flex;align-items:center;height:20px}
.msg .snd{font-size:13px;color:var(--ink2);line-height:16px}
.pill{margin-left:auto;display:inline-flex;align-items:center;height:20px;padding:0 7px;border-radius:3px;font-family:var(--cond);font-weight:700;font-size:13px;letter-spacing:.07em;border:1px solid currentColor;background:color-mix(in srgb, currentColor 12%, transparent)}
.msg .l2{display:flex;align-items:center;gap:10px;margin-top:4px;height:24px}
.msg .sub{font-size:16px;font-weight:600;color:var(--ink);white-space:nowrap}
.msg .gd{width:8px;height:8px;border-radius:4px;background:var(--amber);box-shadow:0 0 0 3px rgba(242,181,58,.2);flex:none}
.msg .tm{margin-left:auto;font-size:13px;color:var(--ink2)}
.msg .mv{font-weight:700;font-size:15px;color:var(--neg)}
.pane{flex:1;padding:28px 32px 28px 32px;display:flex;flex-direction:column}
.top{display:flex;gap:32px}
.col{flex:1;min-width:0}
.meta{display:flex;align-items:center;gap:10px;height:20px}
.pane h2{font-family:var(--cond);font-weight:700;font-size:36px;line-height:40px;letter-spacing:.03em;text-transform:uppercase;color:#FFF;margin-top:10px}
.from{display:flex;align-items:center;gap:10px;margin-top:8px;padding-bottom:18px;border-bottom:1px solid var(--line)}
.from .n{font-weight:600;font-size:16px;color:var(--ink)}
.from .r{font-size:15px;color:var(--ink2)}
.rel{font-family:var(--cond);font-weight:700;font-size:13px;letter-spacing:.08em;color:var(--ink);border:1px solid #6A5F52;border-radius:3px;padding:0 7px;line-height:20px}
.col p{font-size:17px;line-height:26px;color:var(--ink);margin-top:16px}
.col p + p{margin-top:2px}
.q{text-wrap:pretty;font-family:var(--serif);font-size:21px;line-height:31px;color:var(--ink);margin-top:18px}
.col p.end{margin-top:16px}
.por{width:256px;height:320px;flex:none;position:relative;overflow:hidden;border-radius:6px;border:1px solid var(--line2);background:#16120F}
.por img{position:absolute;left:-38px;top:-4px;width:334px;height:418px}
.dec{margin-top:24px}
.perm{display:flex;align-items:center;gap:10px;height:20px;margin-bottom:12px}
.perm span{font-size:14px;color:var(--ink2)}
.oa{display:flex;align-items:center;height:104px;padding:0 20px 0 24px;background:var(--panel2);border:1px solid var(--line2);border-radius:6px}
.fxi{display:flex;flex-direction:column}
.fxi .k{font-family:var(--cond);font-weight:600;font-size:14px;letter-spacing:.07em;color:var(--ink2);line-height:16px}
.fxi .v{display:flex;align-items:center;gap:10px;font-weight:700;font-size:36px;line-height:44px;letter-spacing:-.01em;white-space:nowrap;margin-top:2px}
.fxsep{color:var(--ink3);font-size:28px;margin:18px 22px 0}
.go{margin-left:auto;height:56px;width:184px;display:flex;align-items:center;justify-content:center;background:var(--amber);color:var(--on-amber);border-radius:4px;font-family:var(--cond);font-weight:700;font-size:24px;letter-spacing:.03em}
.ob{display:flex;align-items:center;gap:12px;height:56px;margin-top:8px;padding:0 20px 0 24px;border:1px solid var(--line);border-radius:6px;background:var(--panel)}
.ob .dim{display:flex;align-items:center;gap:12px;opacity:.5}
.ob .n{font-family:var(--cond);font-weight:700;font-size:22px;letter-spacing:.03em;color:var(--ink)}
.ob .why{margin-left:auto;font-size:15px;color:var(--ink2)}
"""


def olay_page():
    up = '<svg width="24" height="24" viewBox="0 0 24 24"><path d="M12 3.6 L20.4 13.2 H15.4 V20.6 H8.6 V13.2 H3.6Z" fill="#4FD27A"/></svg>'
    # pie with the slice pulled out: equity handed over, a cost, not a danger
    pie = ('<svg width="28" height="28" viewBox="0 0 28 28">'
           '<path d="M13 15 L21.66 10 A10 10 0 1 1 13 5 Z" fill="#E9E4DA"/>'
           '<path d="M14.6 12.3 L14.6 2.3 A10 10 0 0 1 23.26 7.3 Z" fill="#E9E4DA"/></svg>')
    mv = '<span class="tm" style="display:flex;gap:6px;align-items:baseline"><span class="lbl" style="font-size:13px">MORAL</span><span class="mv">22</span></span>'
    msgs = [
        dict(on=True, snd="Frank Köseoğlu", topic="MENTOR", sub="Frank'in teklifi", gate=True, right='<span class="tm">11:00</span>',
             pre="Ürün para kazandırmaya başladı."),
        dict(snd="Selin Kaya", topic="EKİP", sub='<span class="tag bad">AYRILABİLİR</span>', right=mv,
             pre="Test Mühendisi · Test ediyor"),
        dict(snd="Ege Sigorta", topic="SATIŞ", sub='<span class="tag bad">RİSK ALTINDA</span>', right='<span class="tm">$1,0K/ay</span>',
             pre='<i>Sebep: sık kesinti şikayeti</i>'),
        dict(snd="Nordica", topic="SATIŞ", sub="Büyüme talebi masada", right='<span class="tm">$2,0K/ay</span>',
             pre='<i>Başka departmana yaymak istiyor.</i>'),
    ]
    rows = []
    for m in msgs:
        c = TOPIC[m["topic"]]
        gd = '<span class="gd"></span>' if m.get("gate") else ""
        rows.append(f'''<div class="msg{" on" if m.get("on") else ""}">
  <div class="l1"><span class="snd">{m["snd"]}</span><span class="pill" style="color:{c}">{m["topic"]}</span></div>
  <div class="l2">{gd}<span class="sub">{m["sub"]}</span>{m["right"]}</div>
  <div class="l3">{m["pre"]}</div></div>''')
    win = f'''<section class="win inbox" lang="tr">
  <div class="whd"><h1>Olaylar</h1><div class="grow"></div><div class="x">{ic("close", 20)}</div></div>
  <div class="ib">
    <div class="list">
      <div class="lgh"><span class="lbl">Hafta 14 · Nisan 2026</span></div>
      {"".join(rows)}
    </div>
    <div class="pane">
      <div class="top">
        <div class="col">
          <div class="meta"><span class="pill" style="color:{TOPIC["MENTOR"]};margin-left:0">MENTOR</span><span class="lbl">Karar · Hafta 14 · Nisan 2026</span></div>
          <h2>Frank'in teklifi</h2>
          <div class="from"><span class="n">Frank Köseoğlu</span><span class="r">Operating Partner</span><span class="rel">NÖTR</span></div>
          <p>Ürün para kazandırmaya başladı.</p>
          <p>Arayan yine Frank.</p>
          <div class="q">"Buraya kadar kendi birikimin ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?"</div>
          <p class="end">Cevap bekliyor.</p>
        </div>
        <div class="por"><img src="{ART}/frank.png" alt=""></div>
      </div>
      <div class="dec">
        <div class="perm">{ic("pause", 16, "#B3AA9E")}<span>Seçim kalıcıdır · Oyun duraklatıldı</span></div>
        <div class="oa">
          <div class="fxi"><span class="k">NAKİT</span><span class="v" style="color:#4FD27A">{up}+$25K</span></div>
          <span class="fxsep">·</span>
          <div class="fxi"><span class="k">FRANK'E</span><span class="v" style="color:#E9E4DA">{pie}%4 HİSSE</span></div>
          <div class="go">Kabul et</div>
        </div>
        <div class="ob"><span class="dim">{ic("lock", 18, "#B3AA9E")}<span class="n">Reddet</span></span><span class="why">Zor modda açılır.</span></div>
      </div>
    </div>
  </div>
</section>'''
    body = f'''<div class="veil"></div>
<div class="halo" id="halo"></div>
{overlays()}
{win}
{topbar(True)}
{rail("olaylar")}
{ticker()}
<script>(function(){{var w=document.querySelector('.win'),h=document.getElementById('halo');h.style.left=w.offsetLeft+'px';h.style.top=w.offsetTop+'px';h.style.width=w.offsetWidth+'px';h.style.height=w.offsetHeight+'px';}})()</script>'''
    return page("Frank'in teklifi", OLAY_CSS, body)


if __name__ == "__main__":
    with open(os.path.join(HERE, "ekip.html"), "w", encoding="utf-8") as f:
        f.write(ekip_page())
    with open(os.path.join(HERE, "olay.html"), "w", encoding="utf-8") as f:
        f.write(olay_page())
    print("ok")
