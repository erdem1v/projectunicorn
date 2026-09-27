import * as THREE from 'https://esm.sh/three@0.160.0';
import { EffectComposer } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/RenderPass.js';
import { GTAOPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/GTAOPass.js';
import { UnrealBloomPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/OutputPass.js';

const V = (x, y, z) => new THREE.Vector3(x, y, z);
const PI = Math.PI;
const SPEED = 3.5, RATE = 1.5, FH = 20;

export const ROLES = {
  dev: { name: 'Yazılım', color: 0x5b7aa6, act: 'code' },
  pm: { name: 'Ürün', color: 0x7d9a6c, act: 'research' },
  des: { name: 'Tasarım', color: 0xa47898, act: 'design' },
  sales: { name: 'Satış', color: 0xb97a58, act: 'phone' },
  qa: { name: 'Test', color: 0x5d9896, act: 'test' },
  founder: { name: 'Kurucu', color: 0xf0b429, act: 'plan' },
};
const ORDER = ['dev','pm','dev','sales','des','dev','qa','sales','dev','qa','pm','dev','des','sales','dev','qa','pm','des','sales','dev'];
const NAMES = ['Deniz Kaya','Ayşe Demir','Mert Şahin','Zeynep Arslan','Can Yıldız','Elif Koç','Burak Aydın','Selin Öztürk','Emre Çelik','Ece Kılıç','Kerem Doğan','Derya Aksoy','Onur Polat','Melis Erdem','Barış Kurt','İpek Güneş','Tolga Uçar','Gizem Tekin','Umut Bulut','Sena Yalçın','Arda Korkmaz'];
const SKIN = [0xe8c3a0, 0xd4a37f, 0xb07a55, 0x8a5a3b, 0xf0d2b6];
const HAIR = [0x2b2522, 0x5a3b26, 0x8b6a45, 0x1c1c1c, 0x9a9a9a, 0x6e3b22];
const ACT_LABEL = { code: 'Kod yazıyor', research: 'Araştırıyor', design: 'Çizim yapıyor', phone: 'Müşteriyle görüşüyor', test: 'Test ediyor', plan: 'Planlama yapıyor', coffee: 'Kahve molası', wc: 'Tuvalette', meeting: 'Toplantıda', food: 'Yemek yiyor' };
const SHORT = { code: 'kod', research: 'araştırma', design: 'çizim', phone: 'görüşmeler', test: 'test', plan: 'planlama' };
const ICON = { code: 'code', test: 'test', research: 'research', plan: 'research', design: 'design', phone: 'phone', coffee: 'coffee', wc: 'wc', meeting: 'meeting', food: 'food' };

const fmt = m => { m = Math.round(m); const h = Math.floor(m / 60) % 24, mm = m % 60; return String(h).padStart(2, '0') + ':' + String(mm).padStart(2, '0'); };
export const fmtTime = fmt;
function rng(seed) { return function () { seed |= 0; seed = seed + 0x6D2B79F5 | 0; let t = Math.imul(seed ^ seed >>> 15, 1 | seed); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; }; }
const sm = (a, b, x) => { const t = Math.min(1, Math.max(0, (x - a) / (b - a))); return t * t * (3 - 2 * t); };

// ---------- schedule (layout independent) ----------
function buildPeople(N) {
  const occ = {};
  const free = (k, a, b) => !(occ[k] || []).some(([x, y]) => a < y + 3 && b > x - 3);
  const take = (k, a, b) => (occ[k] || (occ[k] = [])).push([a, b]);
  const ids = []; for (let i = 1; i <= N; i++) ids.push(i);
  const onTime = ids.filter(i => i !== 5 && i !== 8);
  const R0 = rng(42);
  const lv = ids.filter(i => i !== 1);
  for (let i = lv.length - 1; i > 0; i--) { const j = Math.floor(R0() * (i + 1)); [lv[i], lv[j]] = [lv[j], lv[i]]; }
  const meetIds = ids.filter(i => ['dev', 'pm', 'des'].includes(ORDER[i - 1])).slice(0, 6);
  const eaters = [3, 4].filter(i => i <= N);
  const P = [];
  const mk = (id, A, L, extra) => {
    const role = id === 0 ? 'founder' : ORDER[id - 1];
    const R = rng(1000 + id * 7919), W = ROLES[role].act;
    const busy = [[742, 822]];
    const ev = [{ t: A, s: { k: 'desk' }, a: W, lab: A > 570 ? 'Geliş (geç)' : 'Geliş' }];
    const mi = meetIds.indexOf(id);
    if (mi >= 0) { busy.push([652, 712]); ev.push({ t: 660, s: { k: 'meet', i: mi }, a: 'meeting', lab: 'Toplantı · ürün, yazılım, tasarım' }, { t: 705, s: { k: 'desk' }, a: W, lab: 'Masaya dönüş' }); }
    const ei = eaters.indexOf(id);
    if (ei >= 0) ev.push({ t: 750 + ei * 4, s: { k: 'eat', i: ei }, a: 'food', lab: 'Öğle yemeği · mutfakta' }, { t: 806 + R() * 6, s: { k: 'desk' }, a: W, lab: 'Masaya dönüş' });
    else ev.push({ t: id === 0 ? 758 : 748 + R() * 12, s: { k: 'out' }, a: 'out', lab: 'Öğle yemeği · dışarıda' }, { t: id === 0 ? 812 : 800 + R() * 25, s: { k: 'desk' }, a: W, lab: 'Öğleden dönüş' });
    if (extra) extra(ev, busy);
    const brk = (type, dur, n, cnt, lab) => {
      for (let q = 0; q < n; q++) for (let tries = 0; tries < 80; tries++) {
        const t = A + 25 + R() * (L - A - 55);
        if (busy.some(([a, b]) => t - 6 < b && t + dur + 6 > a)) continue;
        const k0 = Math.floor(R() * cnt); let k = -1;
        for (let j = 0; j < cnt; j++) { const kk = (k0 + j) % cnt; if (free(type + kk, t, t + dur + 10)) { k = kk; break; } }
        if (k < 0) continue;
        take(type + k, t, t + dur + 10); busy.push([t, t + dur]);
        ev.push({ t, s: { k: type, i: k }, a: type, lab }, { t: t + dur, s: { k: 'desk' }, a: W, lab: 'Masaya dönüş' });
        break;
      }
    };
    brk('coffee', 8, id === 0 ? 2 : 1 + (R() < .5 ? 1 : 0), 4, 'Kahve');
    brk('wc', 5, 1 + (R() < .45 ? 1 : 0), 2, 'Tuvalet');
    ev.push({ t: L, s: { k: 'out' }, a: 'home', lab: 'Çıkış' });
    ev.sort((a, b) => a.t - b.t);
    P.push({ id, role, name: NAMES[id], events: ev, lane: (((id * 37) % 9) - 4) * .09, skin: SKIN[id % SKIN.length], hair: HAIR[(id * 3) % HAIR.length] });
  };
  mk(0, 480, 1395, (ev, busy) => { busy.push([895, 945]); ev.push({ t: 900, s: { k: 'desk' }, a: 'phone', full: 'Yatırımcı görüşmesi' }, { t: 940, s: { k: 'desk' }, a: 'plan', full: 'Masada · planlama' }); });
  const arr = {}, lvT = {};
  onTime.forEach((id, r) => { arr[id] = 510 + r * (60 / Math.max(1, onTime.length)) + rng(500 + id)() * 3; });
  if (N >= 5) arr[5] = 580; if (N >= 8) arr[8] = 615;
  lv.forEach((id, r) => { lvT[id] = 1080 + r * (60 / Math.max(1, lv.length)) + rng(900 + id)() * 2; });
  lvT[1] = 1360;
  ids.forEach(id => mk(id, arr[id], lvT[id]));
  return P;
}

// ---------- geometry helpers ----------
const BOXG = new THREE.BoxGeometry(1, 1, 1), CYLG = new THREE.CylinderGeometry(1, 1, 1, 14), CONEG = new THREE.CylinderGeometry(.45, 1, 1, 12), ICOG = new THREE.IcosahedronGeometry(1, 0);
const BODYG = new THREE.CapsuleGeometry(.21, .36, 4, 10), HEADG = new THREE.IcosahedronGeometry(.18, 1), HAIRG = new THREE.SphereGeometry(.19, 10, 6, 0, PI * 2, 0, PI * .55);
const RINGF = new THREE.RingGeometry(.42, .56, 32), RINGS = new THREE.RingGeometry(.6, .7, 32);
const C = { slab: 0x9b958c, carpet: 0xbfc1ba, corridor: 0xd3cdc2, wood: 0xc4ad8c, tile: 0xdad9d2, tile2: 0xcfd8d8, lounge: 0xc9c2b4, wall: 0xe7e2d9, cap: 0x5e5953, desk: 0xdccfb8, fdesk: 0x7a5a40, leg: 0x5b5955, chair: 0x3e424a, dark: 0x2a2d33, counter: 0xc8ccc9, ctop: 0xeeeeea, fridge: 0xe6e6e1, plant: 0x6f8f68, pot: 0xa9765d, sofa: 0x7f889c, meetT: 0x9a8266, wc: 0xf3f3ef, stall: 0xa7b6bb, shelf: 0x8a735c, rug: 0xa56f58, ground: 0x6f726e, part: 0xd9d4ca, shaft: 0x5d636b, mat: 0x4a4d52, edge: 0x8f8a82 };
const MC = {};
const mat = c => MC[c] || (MC[c] = new THREE.MeshStandardMaterial({ color: c, roughness: .88 }));
const winMat = new THREE.MeshBasicMaterial({ color: 0xdfe9ee });
const glassMat = new THREE.MeshStandardMaterial({ color: 0xbfd3dc, transparent: true, opacity: .18, roughness: .1, depthWrite: false });
const ceilMat = new THREE.MeshStandardMaterial({ color: 0xf3efe6, emissive: 0xfff1d6, emissiveIntensity: 1 });

function B(g, x0, x1, y0, y1, z0, z1, c, o = {}) {
  const m = new THREE.Mesh(BOXG, o.m || mat(c));
  m.scale.set(Math.max(.001, x1 - x0), Math.max(.001, y1 - y0), Math.max(.001, z1 - z0));
  m.position.set((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2);
  m.castShadow = o.cast !== false; m.receiveShadow = true; g.add(m); return m;
}
const Bc = (g, w, h, d, x, y, z, c, o) => B(g, x - w / 2, x + w / 2, y - h / 2, y + h / 2, z - d / 2, z + d / 2, c, o);
function Cy(g, r, h, x, y, z, c, o = {}) {
  const m = new THREE.Mesh(o.geo || CYLG, o.m || mat(c)); m.scale.set(r, h, r); m.position.set(x, y, z);
  m.castShadow = o.cast !== false; m.receiveShadow = true; g.add(m); return m;
}
function chair(g, x, y, z, face) {
  const s = new THREE.Group(); s.position.set(x, y, z); s.rotation.y = face; g.add(s);
  Bc(s, .46, .07, .46, 0, .44, -.05, C.chair); Bc(s, .44, .44, .06, 0, .72, -.29, C.chair);
  Cy(s, .035, .4, 0, .21, -.05, C.leg); Bc(s, .5, .04, .07, 0, .03, -.05, C.leg); Bc(s, .07, .04, .5, 0, .03, -.05, C.leg);
  return s;
}
function station(g, x, y, z, face, big) {
  const s = new THREE.Group(); s.position.set(x, y, z); s.rotation.y = face; g.add(s);
  chair(s, 0, 0, 0, 0);
  const w = big ? 2.1 : 1.35, z0 = .45, z1 = big ? 1.3 : 1.05;
  B(s, -w / 2, w / 2, .70, .75, z0, z1, big ? C.fdesk : C.desk);
  B(s, -w / 2, -w / 2 + .05, 0, .70, z0 + .03, z1 - .03, C.leg); B(s, w / 2 - .05, w / 2, 0, .70, z0 + .03, z1 - .03, C.leg);
  const screenMat = new THREE.MeshStandardMaterial({ color: 0x151a22, emissive: 0x9cc6ff, emissiveIntensity: 0, roughness: .4 });
  const lampMat = new THREE.MeshStandardMaterial({ color: 0xe9dfcc, emissive: 0xffb25e, emissiveIntensity: 0, roughness: .6 });
  const mons = big ? [-.2, .45] : [.08];
  for (const mx of mons) {
    Bc(s, .06, .16, .06, mx, .83, z1 - .12, C.dark); Bc(s, .58, .36, .04, mx, 1.08, z1 - .12, C.dark);
    const p = new THREE.Mesh(BOXG, screenMat); p.scale.set(.53, .31, .01); p.position.set(mx, 1.08, z1 - .145); s.add(p);
  }
  Bc(s, .42, .02, .14, .05, .76, z0 + .14, C.dark);
  const lx = -w / 2 + .17, lz = z1 - .14;
  Cy(s, .08, .03, lx, .765, lz, C.leg); Bc(s, .025, .34, .025, lx, .93, lz, C.leg);
  Cy(s, .12, .13, lx, 1.12, lz, 0, { m: lampMat, geo: CONEG });
  s.updateMatrixWorld(true);
  return { screenMat, lampMat, lampPos: s.localToWorld(V(lx, 1.0, lz - .1)), screenPos: s.localToWorld(V(mons[0], 1.15, z1 - .55)) };
}
function plant(g, x, y, z, k = 1) {
  Cy(g, .2 * k, .36 * k, x, y + .18 * k, z, C.pot);
  const f = new THREE.Mesh(ICOG, mat(C.plant)); f.scale.set(.4 * k, .55 * k, .4 * k); f.position.set(x, y + .75 * k, z); f.castShadow = true; g.add(f);
}
function sofa(g, x0, x1, z0, z1, y) {
  B(g, x0, x1, y, y + .42, z0, z1, C.sofa); B(g, x0, x1, y + .42, y + .85, z0, z0 + .22, C.sofa);
  B(g, x0, x0 + .2, y + .42, y + .62, z0, z1, C.sofa); B(g, x1 - .2, x1, y + .42, y + .62, z0, z1, C.sofa);
}
const S = (x, y, z, face, pose, chain, floor = 0) => ({ pos: V(x, y, z), face, pose, chain: chain.map(([a, b]) => V(a, y, b)), floor });

// ---------- Layout A: isometric floor plan ----------
function buildA(big) {
  const g = new THREE.Group(), D = 15, nIs = big ? 5 : 2, fx = 3 + nIs * 4.6 + 1.4, W = Math.max(20, Math.ceil(fx + 4));
  const TH = 2.8, LOW = 1.05, EXT = .45, nc = { cast: false };
  B(g, -.2, W + .2, -.3, 0, -.2, D + .2, C.slab, nc);
  B(g, 0, W, 0, .01, 6, D, C.carpet, nc);
  B(g, 0, W, 0, .014, 6, 8.2, C.corridor, nc);
  B(g, 0, 8, 0, .01, 0, 6, C.wood, nc); B(g, 8, 15, 0, .01, 0, 6, C.tile, nc); B(g, 15, 20, 0, .01, 0, 6, C.tile2, nc);
  if (W > 20) B(g, 20, W, 0, .01, 0, 6, C.lounge, nc);
  const segs = (a0, a1, gaps) => { const out = []; let cur = a0; for (const [a, b] of gaps) { out.push([cur, a]); cur = b; } out.push([cur, a1]); return out.filter(([a, b]) => b - a > .01); };
  const wallX = (z, x0, x1, h, gaps = [], t = .18) => { for (const [a, b] of segs(x0, x1, gaps)) { B(g, a, b, 0, h, z - t / 2, z + t / 2, C.wall); B(g, a, b, h, h + .03, z - t / 2, z + t / 2, C.cap, nc); } };
  const wallZ = (x, z0, z1, h, gaps = [], t = .18) => { for (const [a, b] of segs(z0, z1, gaps)) { B(g, x - t / 2, x + t / 2, 0, h, a, b, C.wall); B(g, x - t / 2, x + t / 2, h, h + .03, a, b, C.cap, nc); } };
  wallX(0, -.09, W + .09, TH); wallZ(0, 0, D, TH, [[6.2, 7.8]]); B(g, -.09, .09, 2.3, TH, 6.2, 7.8, C.wall);
  wallX(D, -.09, W + .09, EXT); wallZ(W, 0, D, EXT);
  wallX(6, 0, 20, LOW, [[3.4, 4.6], [9.9, 11.1], [16.9, 18.1]]); wallZ(8, 0, 6, LOW); wallZ(15, 0, 6, LOW); if (W > 20) wallZ(20, 0, 6, LOW);
  const pane = (x0, x1, y0, y1, z0, z1) => B(g, x0, x1, y0, y1, z0, z1, 0, { m: winMat, cast: false });
  pane(1.2, 6.8, 1.0, 2.3, .09, .12); pane(8.6, 12.6, 1.5, 2.4, .09, .12); pane(15.8, 19.2, 1.8, 2.4, .09, .12);
  for (let x = 21; x < W - 2; x += 3.2) pane(x, x + 2.4, 1, 2.3, .09, .12);
  pane(.09, .12, 1, 2.3, 1, 5); pane(.09, .12, 1, 2.3, 9, 14);
  B(g, -1.3, 0, 0, .015, 6.3, 7.7, C.mat, nc);
  // meeting
  B(g, 2, 6, .72, .77, 2.4, 3.6, C.meetT); Cy(g, .08, .72, 3, .36, 3, C.leg); Cy(g, .08, .72, 5, .36, 3, C.leg);
  const meet = [];
  [2.7, 4, 5.3].forEach(x => meet.push(S(x, 0, 1.7, 0, 'sit', [[x, 1.0], [1.2, 1.0], [1.2, 5.2], [4, 5.2], [4, 7]])));
  [2.7, 4, 5.3].forEach(x => meet.push(S(x, 0, 4.3, PI, 'sit', [[x, 5.2], [4, 5.2], [4, 7]])));
  meet.forEach(s => chair(g, s.pos.x, 0, s.pos.z, s.face)); plant(g, 7.3, 0, .7);
  // kitchen
  B(g, 8.2, 12.8, 0, .9, .1, .8, C.counter); B(g, 8.2, 12.8, .9, .94, .1, .82, C.ctop);
  Bc(g, .35, .4, .35, 9.2, 1.14, .4, C.dark); B(g, 13.1, 14.1, 0, 1.95, .1, .9, C.fridge);
  Cy(g, .55, .04, 13.6, .74, 3.6, C.wood); Cy(g, .06, .72, 13.6, .36, 3.6, C.leg);
  const cof = [9.2, 10.1, 11.0, 11.9].map(x => S(x, 0, 1.45, PI, 'stand', [[10.5, 5.3], [10.5, 7]]));
  const eat = [S(12.85, 0, 3.6, PI / 2, 'sit', [[12.85, 5.0], [10.5, 5.3], [10.5, 7]]), S(14.35, 0, 3.6, -PI / 2, 'sit', [[14.35, 5.0], [10.5, 5.3], [10.5, 7]])];
  eat.forEach(s => chair(g, s.pos.x, 0, s.pos.z, s.face));
  // toilet
  wallZ(17.5, 0, 2.6, 1.0, [], .08); wallX(2.6, 15, 20, 1.0, [[15.7, 16.8], [18.2, 19.3]], .08);
  Bc(g, .4, .42, .55, 16.25, .21, .4, C.wc); Bc(g, .4, .42, .55, 18.75, .21, .4, C.wc); B(g, 19.2, 19.9, 0, .85, 3.4, 4.4, C.wc);
  const wcs = [16.25, 18.75].map(x => S(x, 0, 1.3, 0, 'stand', [[x, 3.4], [17.5, 4.9], [17.5, 7]]));
  // open office
  const desks = [], st = { desk: [] };
  for (let k = 0; k < nIs; k++) {
    const cx = 3 + k * 4.6;
    const seats = [[cx - .7, 9.9, 0, [[cx - .7, 7]]], [cx + .7, 9.9, 0, [[cx + .7, 7]]], [cx - .7, 12.1, PI, [[cx - .7, 13.2], [cx - 2.3, 13.2], [cx - 2.3, 7]]], [cx + .7, 12.1, PI, [[cx + .7, 13.2], [cx + 2.3, 13.2], [cx + 2.3, 7]]]];
    for (const [x, z, f, ch] of seats) { desks.push(S(x, 0, z, f, 'sit', ch)); st.desk.push(station(g, x, 0, z, f, false)); }
  }
  const fs = S(fx, 0, 10.0, 0, 'sit', [[fx, 7]]);
  B(g, fx - 2, fx + 2, 0, .02, 8.9, 12.8, C.rug, nc);
  st.founder = station(g, fx, 0, 10, 0, true);
  plant(g, fx + 2.6, 0, 9.4); plant(g, fx + 2.6, 0, 12.4, 1.2); plant(g, .8, 0, 14.2); plant(g, W - .8, 0, 14.2);
  if (W > 20) { sofa(g, 22, 25, .3, 1.2, 0); sofa(g, 26.5, 29.5, .3, 1.2, 0); Cy(g, .5, .35, 23.5, .175, 2.5, C.wood); Cy(g, .5, .35, 28, .175, 2.5, C.wood); plant(g, W - .8, 0, .8); plant(g, 20.8, 0, .8); }
  const out = S(-2.2, 0, 7, PI / 2, 'out', [[-.3, 7]]);
  const all = [...st.desk, st.founder];
  return {
    g, bounds: new THREE.Box3(V(-1, 0, 0), V(W, 2.8, D)), sunOff: V(16, 30, 22),
    spot(p, s) {
      switch (s.k) {
        case 'desk': return p.id === 0 ? fs : desks[p.id - 1];
        case 'meet': return meet[s.i % 6]; case 'eat': return eat[s.i % 2];
        case 'coffee': return cof[s.i % 4]; case 'wc': return wcs[s.i % 2];
        default: return out;
      }
    },
    station: p => p.id === 0 ? st.founder : st.desk[p.id - 1],
    stations: all, connector: () => [],
  };
}

// ---------- Layout B: side section ----------
function buildB(big) {
  const g = new THREE.Group(), H = 3.4, W = 37, F = big ? 3 : 1, Dz = 5, nc = { cast: false };
  const plans = [
    [[0, 5, 'lobby'], [5, 21, 'office'], [21, 28, 'meet'], [28, 34, 'kitchen'], [34, 37, 'wc']],
    [[0, 5, 'lobby'], [5, 29, 'office'], [29, 34, 'coffee'], [34, 37, 'wc']],
    [[0, 5, 'lobby'], [5, 14, 'boss'], [14, 37, 'lounge']],
  ];
  const floorC = { lobby: 0xc9c3b8, office: C.carpet, meet: C.wood, kitchen: C.tile, wc: C.tile2, coffee: C.tile, boss: 0xb49a7c, lounge: C.lounge };
  const wallC = { lobby: 0xdcd6cc, office: 0xe4dfd6, meet: 0xd5dade, kitchen: 0xe6dccb, wc: 0xd6e0e0, coffee: 0xe6dccb, boss: 0xd9cdbd, lounge: 0xd8dcd2 };
  B(g, -40, W + 40, -3, -.3, -8, 14, C.ground, nc);
  for (let f = 0; f < F; f++) {
    const y = f * H;
    if (f === 0) B(g, -.2, W + .2, -.3, 0, -.2, Dz, C.edge, nc);
    else { B(g, -.2, 1.8, y - .3, y, -.2, Dz, C.edge, nc); B(g, 3.4, W + .2, y - .3, y, -.2, Dz, C.edge, nc); }
    for (const [x0, x1, type] of plans[f]) {
      B(g, x0, x1, y, y + .01, 0, Dz, floorC[type], nc);
      B(g, x0, x1, y, y + H - .3, -.2, 0, wallC[type], nc);
      for (let cx = x0 + 2.2; cx < x1 - 1; cx += 4) B(g, cx - .7, cx + .7, y + H - .36, y + H - .32, 1.8, 2.8, 0, { m: ceilMat, cast: false });
      if (x0 > 0) { B(g, x0 - .07, x0 + .07, y, y + H - .3, 0, 3.1, C.part); B(g, x0 - .07, x0 + .07, y + 2.3, y + H - .3, 3.1, Dz, C.part); }
      const wy0 = type === 'kitchen' || type === 'coffee' ? 1.55 : type === 'wc' ? 1.9 : 1.0;
      for (let x = Math.max(x0 + .9, type === 'lobby' ? 3.8 : 0); x + 1.3 <= x1 - .6; x += 2.2) B(g, x, x + 1.3, y + wy0, y + 2.4, .01, .04, 0, { m: winMat, cast: false });
    }
    if (f === 0) { B(g, -.2, 0, y, y + H - .3, 0, 3.1, C.wall); B(g, -.2, 0, y + 2.3, y + H - .3, 3.1, Dz, C.wall); B(g, -1.3, -.2, 0, .015, 3.1, 4.8, C.mat, nc); }
    else B(g, -.2, 0, y, y + H - .3, 0, Dz, C.wall);
    B(g, W, W + .2, y, y + H - .3, 0, Dz, C.wall);
    B(g, 1.8, 3.4, y + 2.3, y + 2.4, 1.3, 1.45, C.dark);
    plant(g, .7, y, .8);
  }
  B(g, -.3, W + .3, F * H - .3, F * H + .05, -.3, Dz + .1, C.edge, nc);
  B(g, 1.8, 3.4, 0, F * H - .3, -.2, .02, C.shaft, nc);
  B(g, 1.75, 1.85, 0, F * H - .3, 1.35, 1.45, C.dark); B(g, 3.35, 3.45, 0, F * H - .3, 1.35, 1.45, C.dark);
  B(g, 1.85, 3.35, 0, F * H - .3, 1.38, 1.42, 0, { m: glassMat, cast: false });
  B(g, 3.8, 4.8, 0, 1.0, 1.8, 2.6, C.desk);
  const st = { desk: [] }, desks = [], cof = [[], [], []], wcs = [[], []];
  const row = (y, n, f) => { for (let j = 0; j < n; j++) { const x = 6 + j * 1.8; desks.push(S(x, y, 2.2, PI / 2, 'sit', [[x, 3.9]], f)); st.desk.push(station(g, x, y, 2.2, PI / 2, false)); } };
  row(0, 8, 0);
  let fs;
  if (!big) { fs = S(19.4, 0, 1.4, 0, 'sit', [[20.75, 1.4], [20.75, 3.9]], 0); st.founder = station(g, 19.4, 0, 1.4, 0, true); B(g, 17.9, 20.9, 0, .02, .4, 3.0, C.rug, nc); }
  else { Bc(g, .8, .9, .6, 19.6, .45, 1.0, C.fridge); plant(g, 20.4, 0, .6); }
  // meeting
  B(g, 22.6, 26.4, .72, .77, 1.7, 2.7, C.meetT); Cy(g, .08, .72, 23.4, .36, 2.2, C.leg); Cy(g, .08, .72, 25.6, .36, 2.2, C.leg);
  B(g, 23.5, 25.5, 1.3, 2.3, .01, .06, C.dark, nc);
  const meet = [];
  [23.2, 24.5, 25.8].forEach(x => meet.push(S(x, 0, 1.1, 0, 'sit', [[22.2, 1.1], [22.2, 3.9]], 0)));
  [23.2, 24.5, 25.8].forEach(x => meet.push(S(x, 0, 3.25, PI, 'sit', [[x, 3.9]], 0)));
  meet.forEach(s => chair(g, s.pos.x, 0, s.pos.z, s.face));
  // kitchen
  B(g, 28.2, 31.6, 0, .9, .05, .7, C.counter); B(g, 28.2, 31.6, .9, .94, .05, .72, C.ctop); Bc(g, .35, .4, .35, 28.8, 1.14, .35, C.dark);
  B(g, 31.8, 32.7, 0, 1.95, .05, .85, C.fridge);
  Cy(g, .45, .04, 32.95, .74, 2.4, C.wood); Cy(g, .06, .72, 32.95, .36, 2.4, C.leg);
  [28.8, 29.6, 30.4, 31.2].forEach(x => cof[0].push(S(x, 0, 1.3, PI, 'stand', [[x, 3.9]], 0)));
  const eat = [S(32.25, 0, 2.4, PI / 2, 'sit', [[32.25, 3.9]], 0), S(33.6, 0, 2.4, -PI / 2, 'sit', [[33.6, 3.9]], 0)];
  eat.forEach(s => chair(g, s.pos.x, 0, s.pos.z, s.face));
  const wcRoom = (f) => { const y = f * H; B(g, 35.5, 35.58, y, y + 1.9, 0, 2.2, C.stall); [34.85, 36.25].forEach(x => { Bc(g, .4, .42, .5, x, y + .21, .35, C.wc); wcs[f].push(S(x, y, 1.1, 0, 'stand', [[x, 3.9]], f)); }); };
  wcRoom(0);
  if (big) {
    const y1 = H, y2 = 2 * H;
    row(y1, 12, 1); wcRoom(1);
    B(g, 29.2, 31.9, y1, y1 + .9, .05, .7, C.counter); Bc(g, .35, .4, .35, 29.6, y1 + 1.12, .35, C.dark);
    [29.6, 30.3, 31.0, 31.7].forEach(x => cof[1].push(S(x, y1, 1.3, PI, 'stand', [[x, 3.9]], 1)));
    sofa(g, 32.2, 33.8, .3, 1.1, y1);
    fs = S(9.5, y2, 1.4, 0, 'sit', [[11.3, 1.4], [11.3, 3.9]], 2); st.founder = station(g, 9.5, y2, 1.4, 0, true);
    B(g, 7.2, 11.8, y2, y2 + .02, .4, 3.2, C.rug, nc); B(g, 5.4, 7.0, y2, y2 + 2.0, .05, .5, C.shelf); plant(g, 12.8, y2, .7, 1.2);
    B(g, 14.4, 17.6, y2, y2 + .9, .05, .7, C.counter); Bc(g, .35, .4, .35, 14.9, y2 + 1.12, .35, C.dark);
    [14.9, 15.6, 16.3, 17.0].forEach(x => cof[2].push(S(x, y2, 1.3, PI, 'stand', [[x, 3.9]], 2)));
    sofa(g, 20, 23, .3, 1.2, y2); sofa(g, 26, 29, .3, 1.2, y2); Cy(g, .5, .35, 21.5, y2 + .175, 2.4, C.wood); Cy(g, .5, .35, 27.5, y2 + .175, 2.4, C.wood);
    B(g, 32, 35, y2, y2 + 2.0, .05, .5, C.shelf); plant(g, 24.5, y2, .7); plant(g, 36, y2, .7, 1.2);
  }
  const out = S(-1.8, 0, 3.9, PI / 2, 'out', [[.5, 3.9]], 0);
  const floorOf = p => big ? (p.id === 0 ? 2 : p.id <= 8 ? 0 : 1) : 0;
  return {
    g, bounds: new THREE.Box3(V(-2, 0, 0), V(W + .5, F * H, Dz)), sunOff: V(-12, 26, 30),
    spot(p, s) {
      const f = floorOf(p);
      switch (s.k) {
        case 'desk': return p.id === 0 ? fs : desks[p.id - 1];
        case 'meet': return meet[s.i % 6]; case 'eat': return eat[s.i % 2];
        case 'coffee': return cof[f][s.i % 4];
        case 'wc': return wcs[f === 0 ? 0 : 1][s.i % 2];
        default: return out;
      }
    },
    station: p => p.id === 0 ? st.founder : st.desk[p.id - 1],
    stations: [...st.desk, st.founder],
    connector: (a, b) => a.floor === b.floor ? [] : [V(2.6, a.floor * H, 3.9), V(2.6, a.floor * H, .8), V(2.6, b.floor * H, .8), V(2.6, b.floor * H, 3.9)],
  };
}

// ---------- timelines ----------
function mkPath(a, b, lane, L) {
  const mid = [...a.chain, ...L.connector(a, b), ...[...b.chain].reverse()].map(v => { const c = v.clone(); c.z += lane; return c; });
  const raw = [a.pos.clone(), ...mid, b.pos.clone()], pts = [raw[0]];
  for (let i = 1; i < raw.length; i++) if (raw[i].distanceTo(pts[pts.length - 1]) > .01) pts.push(raw[i]);
  const cum = [0]; for (let i = 1; i < pts.length; i++) cum.push(cum[i - 1] + pts[i].distanceTo(pts[i - 1]));
  return { pts, cum, len: Math.max(.01, cum[cum.length - 1]) };
}
function buildTL(p, L, spd = SPEED) {
  let cur = L.spot(p, { k: 'out' });
  const tl = [{ type: 'stay', t0: -1e9, spot: cur, act: 'home' }];
  for (const e of p.events) {
    const sp = L.spot(p, e.s), last = tl[tl.length - 1];
    if (sp === cur) { tl.push({ type: 'stay', t0: Math.max(e.t, last.t0 + .01), spot: sp, act: e.a }); continue; }
    const start = Math.max(e.t, last.t0 + .5), path = mkPath(cur, sp, p.lane, L), dur = path.len / spd;
    tl.push({ type: 'walk', t0: start, t1: start + dur, ...path, act: e.a });
    tl.push({ type: 'stay', t0: start + dur, spot: sp, act: e.a });
    cur = sp;
  }
  return tl;
}
function evalTL(tl, t, r) {
  let lo = 0, hi = tl.length - 1;
  while (lo < hi) { const mid = (lo + hi + 1) >> 1; if (tl[mid].t0 <= t) lo = mid; else hi = mid - 1; }
  const s = tl[lo]; r.idx = lo; r.act = s.act;
  if (s.type === 'stay') { r.pos.copy(s.spot.pos); r.face = s.spot.face; r.pose = s.spot.pose; r.hidden = s.spot.pose === 'out'; r.walking = false; r.spot = s.spot; return r; }
  const u = Math.min(1, Math.max(0, (t - s.t0) / (s.t1 - s.t0))), d = u * s.len;
  let i = 0; while (i < s.cum.length - 2 && s.cum[i + 1] < d) i++;
  const a = s.pts[i], b = s.pts[i + 1], k = (d - s.cum[i]) / Math.max(1e-6, s.cum[i + 1] - s.cum[i]);
  r.pos.lerpVectors(a, b, k);
  r.vert = Math.abs(b.y - a.y) > .01;
  r.face = r.vert ? 0 : Math.atan2(b.x - a.x, b.z - a.z);
  r.pose = 'walk'; r.hidden = false; r.walking = true; r.d = d; r.spot = null;
  return r;
}

// ---------- icons ----------
function iconTex(kind) {
  const c = document.createElement('canvas'); c.width = c.height = 128; const x = c.getContext('2d');
  const col = { coffee: '#8a5a3c', wc: '#3f7fb0', meeting: '#6d5aa0', food: '#4f8a4f' }[kind] || '#2f3440';
  const circ = (cx, cy, r) => { x.beginPath(); x.arc(cx, cy, r, 0, PI * 2); };
  x.fillStyle = 'rgba(0,0,0,.28)'; circ(64, 68, 52); x.fill();
  x.fillStyle = '#f6f3ee'; circ(64, 62, 52); x.fill();
  x.strokeStyle = col; x.lineWidth = 5; circ(64, 62, 49); x.stroke();
  x.strokeStyle = x.fillStyle = col; x.lineWidth = 10; x.lineCap = 'round'; x.lineJoin = 'round';
  x.beginPath();
  switch (kind) {
    case 'code': x.moveTo(50, 42); x.lineTo(32, 62); x.lineTo(50, 82); x.moveTo(78, 42); x.lineTo(96, 62); x.lineTo(78, 82); x.stroke(); break;
    case 'research': x.arc(58, 56, 18, 0, PI * 2); x.moveTo(71, 69); x.lineTo(88, 86); x.stroke(); break;
    case 'design': x.save(); x.translate(64, 62); x.rotate(PI / 4); x.fillRect(-9, -34, 18, 44); x.beginPath(); x.moveTo(-9, 14); x.lineTo(9, 14); x.lineTo(0, 32); x.closePath(); x.fill(); x.restore(); break;
    case 'phone': x.lineWidth = 8; x.moveTo(36, 42); x.lineTo(92, 42); x.lineTo(92, 76); x.lineTo(60, 76); x.lineTo(46, 90); x.lineTo(46, 76); x.lineTo(36, 76); x.closePath(); x.stroke(); x.beginPath(); [52, 64, 76].forEach(cx => { x.moveTo(cx + 4, 59); x.arc(cx, 59, 4, 0, PI * 2); }); x.fill(); break;
    case 'test': x.lineWidth = 12; x.moveTo(40, 64); x.lineTo(57, 81); x.lineTo(90, 45); x.stroke(); break;
    case 'coffee': x.fillRect(38, 52, 38, 32); x.lineWidth = 7; x.beginPath(); x.arc(80, 66, 9, -PI / 2, PI / 2); x.stroke(); x.beginPath(); x.lineWidth = 5; x.moveTo(48, 44); x.quadraticCurveTo(54, 38, 48, 30); x.moveTo(62, 44); x.quadraticCurveTo(68, 38, 62, 30); x.stroke(); break;
    case 'wc': x.moveTo(64, 30); x.bezierCurveTo(74, 46, 86, 58, 86, 72); x.arc(64, 72, 22, 0, PI, false); x.bezierCurveTo(42, 58, 54, 46, 64, 30); x.fill(); break;
    case 'meeting': circ(47, 50, 10); x.fill(); circ(81, 50, 10); x.fill(); x.beginPath(); x.arc(47, 84, 17, PI, 0); x.fill(); x.beginPath(); x.arc(81, 84, 17, PI, 0); x.fill(); break;
    case 'food': x.lineWidth = 8; x.arc(72, 64, 20, 0, PI * 2); x.stroke(); x.beginPath(); x.lineWidth = 6; x.moveTo(40, 40); x.lineTo(40, 88); x.moveTo(33, 40); x.lineTo(33, 54); x.moveTo(47, 40); x.lineTo(47, 54); x.moveTo(33, 55); x.lineTo(47, 55); x.stroke(); break;
  }
  const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; t.anisotropy = 4; return t;
}
let ICON_MATS = null;
function iconMats() {
  if (ICON_MATS) return ICON_MATS;
  const full = {}, dim = {};
  for (const k of ['code', 'research', 'design', 'phone', 'test', 'coffee', 'wc', 'meeting', 'food']) {
    const tex = iconTex(k);
    full[k] = new THREE.SpriteMaterial({ map: tex, depthTest: false, toneMapped: false, color: 0xd2d2d2 });
    dim[k] = new THREE.SpriteMaterial({ map: tex, depthTest: false, toneMapped: false, opacity: .6, transparent: true, color: 0xd2d2d2 });
  }
  return ICON_MATS = { full, dim };
}

// ---------- characters ----------
function makeChar(p, pick) {
  const root = new THREE.Group(), inner = new THREE.Group(); root.add(inner);
  const isF = p.id === 0;
  const bodyM = new THREE.MeshStandardMaterial({ color: ROLES[p.role].color, roughness: .8, emissive: isF ? 0x6b4a00 : 0x000000, emissiveIntensity: isF ? .45 : 0 });
  const legM = mat(isF ? 0x3b3326 : 0x3a3d44), skinM = mat(p.skin), hairM = mat(p.hair);
  const mk = (geo, m, sx, sy, sz, x, y, z, parent) => { const me = new THREE.Mesh(geo, m); me.scale.set(sx, sy, sz); me.position.set(x, y, z); me.castShadow = true; me.userData.pid = p.id; parent.add(me); pick.push(me); return me; };
  const piv = (x, y) => { const g = new THREE.Group(); g.position.set(x, y, 0); inner.add(g); return g; };
  const lL = piv(-.09, .52), lR = piv(.09, .52);
  mk(BOXG, legM, .13, .5, .15, 0, -.25, 0, lL); mk(BOXG, legM, .13, .5, .15, 0, -.25, 0, lR);
  mk(BODYG, bodyM, 1, 1, 1, 0, .86, 0, inner);
  const aL = piv(-.27, 1.12), aR = piv(.27, 1.12);
  mk(BOXG, bodyM, .09, .44, .1, 0, -.2, 0, aL); mk(BOXG, bodyM, .09, .44, .1, 0, -.2, 0, aR);
  const head = piv(0, 1.38);
  mk(HEADG, skinM, 1, 1, 1, 0, 0, 0, head); mk(HAIRG, hairM, 1, 1, 1, 0, .02, -.015, head);
  if (isF) root.scale.setScalar(1.12);
  const sprite = new THREE.Sprite(iconMats().full.code); sprite.renderOrder = 10; root.add(sprite);
  const ring = new THREE.Mesh(RINGF, new THREE.MeshBasicMaterial({ color: 0xf0b429, transparent: true, opacity: .9, depthWrite: false, toneMapped: false }));
  ring.rotation.x = -PI / 2; ring.position.y = .03; ring.visible = isF; root.add(ring);
  const selRing = new THREE.Mesh(RINGS, new THREE.MeshBasicMaterial({ color: 0xffffff, transparent: true, opacity: .95, depthWrite: false, toneMapped: false }));
  selRing.rotation.x = -PI / 2; selRing.position.y = .035; selRing.visible = false; root.add(selRing);
  return { root, inner, lL, lR, aL, aR, head, sprite, ring, selRing };
}

// ---------- main ----------
export function createOffice(el, cb = {}) {
  const renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setPixelRatio(Math.min(2, window.devicePixelRatio || 1));
  renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.toneMapping = THREE.ACESFilmicToneMapping; renderer.toneMappingExposure = 1.05;
  const canvas = renderer.domElement; canvas.style.cssText = 'display:block;width:100%;height:100%;touch-action:none;cursor:grab';
  el.appendChild(canvas);
  const scene = new THREE.Scene(); scene.background = new THREE.Color(0xd3d6d3);
  const cam = new THREE.OrthographicCamera(-1, 1, 1, -1, .1, 600);
  let composer = null, gtao = null, bloom = null;
  try {
    const w0 = Math.max(1, el.clientWidth), h0 = Math.max(1, el.clientHeight);
    composer = new EffectComposer(renderer);
    composer.addPass(new RenderPass(scene, cam));
    try { gtao = new GTAOPass(scene, cam, w0, h0); gtao.updateGtaoMaterial({ radius: .55, distanceExponent: 1.5, thickness: 1.5, scale: 1.4, samples: 16 }); gtao.blendIntensity = .9; composer.addPass(gtao); } catch (e) { console.warn('AO off', e); gtao = null; }
    bloom = new UnrealBloomPass(new THREE.Vector2(w0, h0), .3, .55, .9); composer.addPass(bloom);
    composer.addPass(new OutputPass());
  } catch (e) { console.warn('postfx off', e); composer = null; }
  const hemi = new THREE.HemisphereLight(0xffffff, 0x8a8070, 1); scene.add(hemi);
  const amb = new THREE.AmbientLight(0xfff3e0, .6); scene.add(amb);
  const sun = new THREE.DirectionalLight(0xfff4e6, 2); sun.castShadow = true; sun.shadow.mapSize.set(4096, 4096); sun.shadow.bias = -.0004; sun.shadow.normalBias = .03;
  scene.add(sun); scene.add(sun.target);
  const lamps = [0, 1].map(() => { const l = new THREE.PointLight(0xffb468, 0, 7, 1.6); scene.add(l); return l; });
  const screens = [0, 1].map(() => { const l = new THREE.PointLight(0x8fb8ff, 0, 4, 1.8); scene.add(l); return l; });

  let mode = 'A', big = false, count = 8, angle = 35, time = 475, playing = true, speed = 1, clock = 0, sel = null;
  const opts = { icons: true, founder: true, fx: true };
  let L = null, chars = [], pick = [], target = V(0, 0, 0), zoom = 1, fitZoom = 1;
  const COL = { day: new THREE.Color(0xd3d6d3), night: new THREE.Color(0x12151b), dusk: new THREE.Color(0xd9b69a), hd: new THREE.Color(0xffffff), hn: new THREE.Color(0x5a6a90), wd: new THREE.Color(0xdfe9ee), wn: new THREE.Color(0x1c2638), wdu: new THREE.Color(0xf0c49a), sl: new THREE.Color(0xffc890), sh: new THREE.Color(0xfff4e6) };

  function size() { return { w: Math.max(1, el.clientWidth), h: Math.max(1, el.clientHeight) }; }
  function frustum() { const { w, h } = size(), a = w / h; cam.left = -FH * a / 2; cam.right = FH * a / 2; cam.top = FH / 2; cam.bottom = -FH / 2; }
  function camOff() {
    if (mode === 'A') { const el2 = angle * PI / 180, az = PI / 4; return V(Math.sin(az) * Math.cos(el2), Math.sin(el2), Math.cos(az) * Math.cos(el2)).multiplyScalar(120); }
    const e = 8 * PI / 180; return V(0, Math.sin(e), Math.cos(e)).multiplyScalar(120);
  }
  function placeCam() { cam.position.copy(target).add(camOff()); cam.lookAt(target); cam.zoom = zoom; frustum(); cam.updateProjectionMatrix(); cam.updateMatrixWorld(); }
  function fitView() {
    const b = L.bounds; b.getCenter(target); zoom = 1; placeCam();
    let mnx = 1e9, mxx = -1e9, mny = 1e9, mxy = -1e9;
    for (let i = 0; i < 8; i++) { const v = V(i & 1 ? b.max.x : b.min.x, i & 2 ? b.max.y : b.min.y, i & 4 ? b.max.z : b.min.z).applyMatrix4(cam.matrixWorldInverse); mnx = Math.min(mnx, v.x); mxx = Math.max(mxx, v.x); mny = Math.min(mny, v.y); mxy = Math.max(mxy, v.y); }
    const right = V(1, 0, 0).applyQuaternion(cam.quaternion), up = V(0, 1, 0).applyQuaternion(cam.quaternion);
    target.addScaledVector(right, (mnx + mxx) / 2).addScaledVector(up, (mny + mxy) / 2);
    const { w, h } = size(); zoom = fitZoom = Math.min(FH * (w / h) / (mxx - mnx), FH / (mxy - mny)) * .9;
    placeCam();
  }
  function clearChars() { for (const c of chars) scene.remove(c.m.root); chars = []; pick = []; }
  function rebuildPeople() {
    clearChars();
    for (const p of buildPeople(count)) {
      const m = makeChar(p, pick); scene.add(m.root);
      chars.push({ p, m, tl: buildTL(p, L), deskSpot: L.spot(p, { k: 'desk' }), r: { pos: V(0, 0, 0) } });
    }
    if (sel != null && !chars.find(c => c.p.id === sel)) { sel = null; }
  }
  function rebuildLayout() {
    if (L) { scene.remove(L.g); L.g.traverse(o => { if (o.material && o.material !== winMat && !Object.values(MC).includes(o.material) && o.material !== ceilMat && o.material !== glassMat) o.material.dispose(); }); }
    L = mode === 'A' ? buildA(big) : buildB(big); scene.add(L.g);
    const c = L.bounds.getCenter(V(0, 0, 0)), s = L.bounds.getSize(V(0, 0, 0)), r = Math.max(s.x, s.y, s.z) * .75 + 4;
    sun.position.copy(c).add(L.sunOff); sun.target.position.copy(c);
    Object.assign(sun.shadow.camera, { left: -r, right: r, top: r, bottom: -r, near: 1, far: 140 }); sun.shadow.camera.updateProjectionMatrix();
    rebuildPeople(); fitView();
  }

  const tmpC = new THREE.Color();
  function update() {
    const f = time < 425 || time > 1165 ? 0 : Math.sin(PI * (time - 425) / 740);
    const inter = sm(440, 470, time) * (1 - sm(1142, 1160, time));
    const dusk = f > 0 ? 1 - sm(0, .3, f) : 0;
    scene.background.lerpColors(COL.night, COL.day, Math.sqrt(f)).lerp(COL.dusk, dusk * .55);
    hemi.intensity = .16 + .95 * f; hemi.color.lerpColors(COL.hn, COL.hd, f);
    sun.intensity = 2.6 * f; sun.color.lerpColors(COL.sl, COL.sh, Math.min(1, f * 2));
    amb.intensity = .7 * inter;
    winMat.color.lerpColors(COL.wn, COL.wd, Math.sqrt(f)).lerp(COL.wdu, dusk * .7);
    ceilMat.emissiveIntensity = inter * 1.3;
    if (bloom) { bloom.strength = .22 + .75 * (1 - Math.sqrt(f)); bloom.threshold = .95; }
    for (const s of L.stations) { s.lampMat.emissiveIntensity = 0; s.screenMat.emissiveIntensity = 0; }
    lamps.forEach(l => l.intensity = 0); screens.forEach(l => l.intensity = 0);
    const { h } = size(), ppu = h * zoom / FH, iconS = Math.max(.6, 26 / ppu);
    const IM = iconMats();
    for (const c of chars) {
      const r = evalTL(c.tl, time, c.r), m = c.m, clk = clock + c.p.id * 1.37;
      m.root.visible = !r.hidden;
      if (r.hidden) continue;
      m.root.position.copy(r.pos); m.root.rotation.y = r.face;
      m.inner.position.y = 0; m.inner.rotation.z = 0; m.head.rotation.set(0, 0, 0);
      let lx = 0, rx = 0, al = 0, ar = 0;
      if (r.walking) {
        if (!r.vert) { const ph = r.d * 4.2; lx = Math.sin(ph) * .6; rx = -lx; al = -lx * .7; ar = lx * .7; m.inner.position.y = Math.abs(Math.cos(ph)) * .05; m.inner.rotation.z = Math.sin(ph) * .05; }
      } else if (r.pose === 'sit') {
        lx = rx = -PI / 2; m.inner.position.y = -.05; const a = r.act;
        if (a === 'code' || a === 'test' || a === 'design') { al = -1.25 + Math.sin(clk * 13) * .09; ar = -1.25 + Math.sin(clk * 13 + 1.9) * .09; m.head.rotation.x = .12; }
        else if (a === 'research' || a === 'plan') { al = ar = -1.05; m.head.rotation.x = .1 + Math.sin(clk * 1.3) * .07; m.head.rotation.y = Math.sin(clk * .5) * .2; }
        else if (a === 'phone') { al = -1.0; ar = -2.75; m.head.rotation.z = .12; m.head.rotation.y = Math.sin(clk * .9) * .25; }
        else if (a === 'meeting') { al = ar = -.8; m.head.rotation.y = Math.sin(clk * .6) * .5; }
        else if (a === 'food') { al = -1.0; ar = -1.1 - Math.max(0, Math.sin(clk * 2.2)) * 1.0; }
      } else if (r.act === 'coffee') { ar = -1.2 - Math.max(0, Math.sin(clk * 1.1)) * .9; al = -.2; m.head.rotation.y = Math.sin(clk * .4) * .4; }
      m.lL.rotation.x = lx; m.lR.rotation.x = rx; m.aL.rotation.x = al; m.aR.rotation.x = ar;
      const ic = ICON[r.act];
      if (opts.icons && ic) {
        m.sprite.visible = true; m.sprite.material = (r.walking ? IM.dim : IM.full)[ic];
        const s = iconS / m.root.scale.x; m.sprite.scale.set(s, s, 1); m.sprite.position.y = (r.pose === 'sit' ? 1.62 : 1.72) + s * .55;
      } else m.sprite.visible = false;
      m.ring.visible = c.p.id === 0 && opts.founder;
      m.selRing.visible = c.p.id === sel;
      const st = L.station(c.p);
      if (st && r.spot === c.deskSpot) {
        const lampOn = time > 1050 || f < .35;
        st.lampMat.emissiveIntensity = lampOn ? 2.4 : 0;
        st.screenMat.emissiveIntensity = inter > .5 && f > .3 ? .6 : 1.5;
        if (c.p.id <= 1 && time > 1100) {
          lamps[c.p.id].position.copy(st.lampPos); lamps[c.p.id].intensity = 5;
          screens[c.p.id].position.copy(st.screenPos); screens[c.p.id].intensity = 1.6;
        }
      }
    }
  }

  function info() {
    if (sel == null) return null;
    const c = chars.find(c => c.p.id === sel); if (!c) return null;
    const r = evalTL(c.tl, time, { pos: V(0, 0, 0) });
    let cur;
    if (r.hidden) cur = r.act === 'out' ? 'Öğle yemeğinde (dışarıda)' : r.idx === 0 ? 'Henüz gelmedi' : 'Eve gitti';
    else cur = (r.walking ? 'Yürüyor → ' : '') + ACT_LABEL[r.act];
    let ci = -1; c.p.events.forEach((e, i) => { if (e.t <= time) ci = i; });
    const items = c.p.events.map((e, i) => ({
      time: fmt(e.t), label: e.full || (e.s.k === 'desk' ? e.lab + ' · ' + SHORT[e.a] : e.lab),
      bg: i === ci ? 'rgba(255,255,255,.10)' : 'transparent', fw: i === ci ? '600' : '400', op: i <= ci ? '1' : '.72',
    }));
    return { id: c.p.id, name: c.p.name, role: ROLES[c.p.role].name, color: '#' + ROLES[c.p.role].color.toString(16).padStart(6, '0'), current: cur, items };
  }

  // input
  const ray = new THREE.Raycaster(), ndc = new THREE.Vector2();
  function pickAt(e) {
    const r = canvas.getBoundingClientRect();
    ndc.set(((e.clientX - r.left) / r.width) * 2 - 1, -((e.clientY - r.top) / r.height) * 2 + 1);
    ray.setFromCamera(ndc, cam);
    const vis = pick.filter(m => { const c = chars.find(c => c.p.id === m.userData.pid); return c && c.m.root.visible; });
    const hit = ray.intersectObjects(vis, false)[0];
    return hit ? hit.object.userData.pid : null;
  }
  let drag = null;
  const onDown = e => { drag = { x: e.clientX, y: e.clientY, sx: e.clientX, sy: e.clientY }; canvas.setPointerCapture(e.pointerId); canvas.style.cursor = 'grabbing'; };
  const onMove = e => {
    if (drag) {
      const dx = e.clientX - drag.x, dy = e.clientY - drag.y; drag.x = e.clientX; drag.y = e.clientY;
      const { h } = size(), upp = FH / (zoom * h);
      const right = V(1, 0, 0).applyQuaternion(cam.quaternion), up = V(0, 1, 0).applyQuaternion(cam.quaternion);
      target.addScaledVector(right, -dx * upp).addScaledVector(up, dy * upp); placeCam();
    } else canvas.style.cursor = pickAt(e) != null ? 'pointer' : 'grab';
  };
  const onUp = e => {
    if (drag && Math.hypot(e.clientX - drag.sx, e.clientY - drag.sy) < 5) { sel = pickAt(e); cb.onSelect && cb.onSelect(info()); }
    drag = null; canvas.style.cursor = 'grab';
  };
  const onWheel = e => {
    e.preventDefault();
    const r = canvas.getBoundingClientRect(), nx = ((e.clientX - r.left) / r.width) * 2 - 1, ny = -((e.clientY - r.top) / r.height) * 2 + 1;
    const zo = zoom, zn = Math.min(fitZoom * 7, Math.max(fitZoom * .6, zoom * Math.exp(-e.deltaY * .0015)));
    const { w, h } = size(), hw = FH * (w / h) / 2, hh = FH / 2;
    const right = V(1, 0, 0).applyQuaternion(cam.quaternion), up = V(0, 1, 0).applyQuaternion(cam.quaternion);
    target.addScaledVector(right, nx * hw * (1 / zo - 1 / zn)).addScaledVector(up, ny * hh * (1 / zo - 1 / zn));
    zoom = zn; placeCam();
  };
  canvas.addEventListener('pointerdown', onDown); canvas.addEventListener('pointermove', onMove); canvas.addEventListener('pointerup', onUp);
  canvas.addEventListener('wheel', onWheel, { passive: false });
  const ro = new ResizeObserver(() => { const { w, h } = size(); renderer.setSize(w, h, false); if (composer) { composer.setSize(w, h); } placeCam(); });
  ro.observe(el);
  { const { w, h } = size(); renderer.setSize(w, h, false); }

  rebuildLayout();
  let raf, lastNow = performance.now(), lastTick = 0;
  function frame(now) {
    raf = requestAnimationFrame(frame);
    const dt = Math.min(.1, (now - lastNow) / 1000); lastNow = now;
    if (playing) { time += dt * speed * RATE; clock += dt * speed; if (time >= 1440) { time = 1440; playing = false; } }
    update(); if (composer && opts.fx) composer.render(); else renderer.render(scene, cam);
    if (now - lastTick > 100) { lastTick = now; cb.onTick && cb.onTick({ time, playing, sel: info() }); }
  }
  raf = requestAnimationFrame(frame);

  return {
    setMode(m) { if (m !== mode) { mode = m; rebuildLayout(); } },
    setBig(b) { big = b; count = b ? 20 : 8; rebuildLayout(); },
    setCount(n) { count = Math.max(1, Math.min(big ? 20 : 8, n)); rebuildPeople(); },
    setAngle(a) { angle = a; placeCam(); },
    setTime(t) { time = t; },
    setPlaying(p) { playing = p; if (p && time >= 1440) time = 420; },
    setSpeed(s) { speed = s; },
    setOptions(o) { Object.assign(opts, o); },
    fit() { fitView(); },
    select(id) { sel = id; },
    destroy() { cancelAnimationFrame(raf); ro.disconnect(); renderer.dispose(); canvas.remove(); },
  };
}

export { buildPeople, buildTL, evalTL, iconMats, makeChar, ICON, ACT_LABEL, SHORT, fmt, rng, sm };
