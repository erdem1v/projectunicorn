// Generic people/schedule builder + timeline for larger offices
import { ROLES, rng } from './office-sim-v2.js';
const FIRST = ['Ayşe', 'Mert', 'Zeynep', 'Can', 'Elif', 'Burak', 'Selin', 'Emre', 'Ece', 'Kerem', 'Derya', 'Onur', 'İpek', 'Berk', 'Gizem', 'Tolga', 'Melis', 'Kaan', 'Seda', 'Ozan', 'Buse', 'Arda', 'Naz', 'Efe', 'Defne', 'Barış', 'Ceren', 'Umut', 'Yasemin', 'Hakan', 'Pelin', 'Serkan', 'Aslı', 'Cem', 'Irmak', 'Volkan', 'Duygu', 'Alp', 'Nehir', 'Sinan'];
const LAST = ['Demir', 'Şahin', 'Arslan', 'Yıldız', 'Koç', 'Aydın', 'Öztürk', 'Çelik', 'Kılıç', 'Doğan', 'Aksoy', 'Polat', 'Erdem', 'Kurt', 'Özkan', 'Tekin', 'Bulut', 'Güneş', 'Acar', 'Uçar', 'Kaplan', 'Ekinci', 'Tan', 'Sarı'];
export function nameOf(id) { if (id === 0) return 'Deniz Kaya'; const f = FIRST[(id * 7) % FIRST.length], l = LAST[(id * 11 + Math.floor(id / FIRST.length)) % LAST.length]; return f + ' ' + l; }
const SKIN = [0xe8c3a0, 0xd4a37f, 0xb07a55, 0x8a5a3b, 0xf0d2b6], HAIR = [0x2b2522, 0x5a3b26, 0x8b6a45, 0x1c1c1c, 0x9a9a9a, 0x6e3b22];

// cfg: { roles:[role of id1..], meetings:[{t,t1,r,ids,lab}], eat, cof, wc, booths, allHands:{t,t1}|null, founderMeet:[...] }
export function buildPeopleX(N, cfg) {
  const occ = {}, free = (k, a, b) => !(occ[k] || []).some(([x, y]) => a < y + 3 && b > x - 3), take = (k, a, b) => (occ[k] || (occ[k] = [])).push([a, b]);
  const ids = []; for (let i = 1; i <= N; i++) ids.push(i);
  const roleOf = id => id === 0 ? 'founder' : cfg.roles[id - 1];
  const late = { [Math.min(N, 5)]: 580, [Math.min(N, 12)]: 615 };
  const stayer = ids.find(i => roleOf(i) === 'dev');
  const onTime = ids.filter(i => !late[i]), R0 = rng(42), lv = ids.filter(i => i !== stayer);
  for (let i = lv.length - 1; i > 0; i--) { const j = Math.floor(R0() * (i + 1)); [lv[i], lv[j]] = [lv[j], lv[i]]; }
  const arr = {}, lvT = {};
  onTime.forEach((id, r) => { arr[id] = 510 + r * (60 / Math.max(1, onTime.length)) + rng(500 + id)() * 2; });
  Object.assign(arr, late);
  lv.forEach((id, r) => { lvT[id] = 1080 + r * (60 / Math.max(1, lv.length)) + rng(900 + id)() * 1.5; });
  if (stayer) lvT[stayer] = 1360;
  const eaters = []; { const R = rng(77), pool = ids.slice(); while (eaters.length < Math.min(cfg.eat, N) && pool.length) eaters.push(pool.splice(Math.floor(R() * pool.length), 1)[0]); }
  const P = [];
  const mk = (id, A, L) => {
    const role = roleOf(id), R = rng(1000 + id * 7919), W = ROLES[role].act, busy = [[742, 822]];
    const ev = [{ t: A, s: { k: 'desk' }, a: W, lab: A > 570 ? 'Geliş (geç)' : 'Geliş' }];
    const back = (t, lab = 'Masaya dönüş') => ev.push({ t, s: { k: 'desk' }, a: W, lab });
    for (const m of cfg.meetings) { const i = m.ids.indexOf(id); if (i < 0 || m.t < A + 5 || m.t1 > L) continue; busy.push([m.t - 8, m.t1 + 4]); ev.push({ t: m.t, s: { k: 'meet', r: m.r, i }, a: 'meeting', lab: m.lab }); back(m.t1); }
    if (cfg.allHands && id !== 0) { const h = cfg.allHands; busy.push([h.t - 12, h.t1 + 6]); ev.push({ t: h.t - 6 + R() * 4, s: { k: 'trib', i: id - 1 }, a: 'meeting', lab: 'Tüm ekip · tribün' }); back(h.t1 + R() * 3); }
    const ei = eaters.indexOf(id);
    if (id === 0) { ev.push({ t: 758, s: { k: 'out' }, a: 'out', lab: 'Öğle yemeği · dışarıda' }); back(812, 'Öğleden dönüş'); }
    else if (ei >= 0) { ev.push({ t: 748 + R() * 8, s: { k: 'eat', i: ei }, a: 'food', lab: 'Öğle yemeği · kafede' }); back(800 + R() * 10); }
    else { ev.push({ t: 746 + R() * 14, s: { k: 'out' }, a: 'out', lab: 'Öğle yemeği · dışarıda' }); back(800 + R() * 22, 'Öğleden dönüş'); }
    const brk = (type, dur, n, cnt, a, lab) => {
      if (!cnt) return;
      for (let q = 0; q < n; q++) for (let tries = 0; tries < 80; tries++) {
        const t = A + 25 + R() * (Math.min(L, 1070) - A - 55);
        if (busy.some(([x, y]) => t - 6 < y && t + dur + 6 > x)) continue;
        const k0 = Math.floor(R() * cnt); let k = -1;
        for (let j = 0; j < cnt; j++) { const kk = (k0 + j) % cnt; if (free(type + kk, t, t + dur + 10)) { k = kk; break; } }
        if (k < 0) continue;
        take(type + k, t, t + dur + 10); busy.push([t, t + dur]); ev.push({ t, s: { k: type, i: k }, a, lab }); back(t + dur); break;
      }
    };
    if (id === 0) {
      busy.push([895, 945]); ev.push({ t: 900, s: { k: 'desk' }, a: 'phone', full: 'Yatırımcı görüşmesi' }, { t: 940, s: { k: 'desk' }, a: 'plan', full: 'Ofiste · planlama' });
      for (const t0 of [600, 840, 990]) { if (busy.some(([x, y]) => t0 < y && t0 + 25 > x)) continue; busy.push([t0, t0 + 25]); const used = new Set();
        for (let j = 0; j < 3; j++) { let v = 1 + Math.floor(R() * N), gg = 0; while (used.has(v) && gg++ < 12) v = 1 + Math.floor(R() * N); used.add(v); ev.push({ t: t0 + j * 7, s: { k: 'visit', i: v - 1 }, a: 'visit', full: 'Masa ziyareti · ' + nameOf(v) }); }
        back(t0 + 21, 'Ofisine dönüş'); }
      if (cfg.allHands) { const h = cfg.allHands; busy.push([h.t - 10, h.t1 + 4]); ev.push({ t: h.t - 8, s: { k: 'present' }, a: 'meeting', full: 'Tüm ekip toplantısı · sunum' }); back(h.t1 + 2, 'Ofisine dönüş'); }
      ev.push({ t: 1250, s: { k: 'coffee', i: 0 }, a: 'coffee', lab: 'Akşam kahvesi' }); back(1258, 'Ofisine dönüş');
    }
    brk('coffee', 8, id === 0 ? 1 : 1 + (R() < .5 ? 1 : 0), cfg.cof, 'coffee', 'Kahve');
    brk('wc', 5, 1 + (R() < .45 ? 1 : 0), cfg.wc, 'wc', 'Tuvalet');
    if (role === 'sales') brk('booth', 18, 1 + (R() < .5 ? 1 : 0), cfg.booths, 'phone', 'Müşteri görüşmesi · telefon kabini');
    ev.push({ t: L, s: { k: 'out' }, a: 'home', lab: 'Çıkış' });
    ev.sort((a, b) => a.t - b.t);
    P.push({ id, role, name: nameOf(id), events: ev, lane: (((id * 37) % 9) - 4) * .08, skin: SKIN[id % 5], hair: HAIR[(id * 3) % 6] });
  };
  mk(0, 480, 1395);
  ids.forEach(id => mk(id, arr[id], lvT[id]));
  return P;
}

// timeline with stair-aware walking
function mkPath(a, b, lane, L) {
  const mid = [...a.chain, ...L.connector(a, b), ...[...b.chain].reverse()].map(v => { const c = v.clone(); c.z += lane; return c; });
  const raw = [a.pos.clone(), ...mid, b.pos.clone()], pts = [raw[0]];
  for (let i = 1; i < raw.length; i++) if (raw[i].distanceTo(pts[pts.length - 1]) > .01) pts.push(raw[i]);
  const cum = [0]; for (let i = 1; i < pts.length; i++) cum.push(cum[i - 1] + pts[i].distanceTo(pts[i - 1]));
  return { pts, cum, len: Math.max(.01, cum[cum.length - 1]) };
}
export function buildTLX(p, L, spd) {
  let cur = L.spot(p, { k: 'out' });
  const tl = [{ type: 'stay', t0: -1e9, spot: cur, act: 'home' }];
  for (const e of p.events) {
    const sp = L.spot(p, e.s), last = tl[tl.length - 1];
    if (sp === cur) { tl.push({ type: 'stay', t0: Math.max(e.t, last.t0 + .01), spot: sp, act: e.a }); continue; }
    if ((sp.zone || '') !== (cur.zone || '')) { tl.push({ type: 'stay', t0: Math.max(e.t, last.t0 + .01), spot: sp, act: e.a }); cur = sp; continue; }
    const start = Math.max(e.t, last.t0 + .5), path = mkPath(cur, sp, p.lane, L), dur = path.len / spd;
    tl.push({ type: 'walk', t0: start, t1: start + dur, ...path, act: e.a }, { type: 'stay', t0: start + dur, spot: sp, act: e.a });
    cur = sp;
  }
  return tl;
}
export function evalTLX(tl, t, r) {
  let lo = 0, hi = tl.length - 1;
  while (lo < hi) { const mid = (lo + hi + 1) >> 1; if (tl[mid].t0 <= t) lo = mid; else hi = mid - 1; }
  const s = tl[lo]; r.idx = lo; r.act = s.act;
  if (s.type === 'stay') { r.pos.copy(s.spot.pos); r.face = s.spot.face; r.pose = s.spot.pose; r.hidden = s.spot.pose === 'out'; r.walking = false; r.spot = s.spot; return r; }
  const u = Math.min(1, Math.max(0, (t - s.t0) / (s.t1 - s.t0))), d = u * s.len;
  let i = 0; while (i < s.cum.length - 2 && s.cum[i + 1] < d) i++;
  const a = s.pts[i], b = s.pts[i + 1], k = (d - s.cum[i]) / Math.max(1e-6, s.cum[i + 1] - s.cum[i]);
  r.pos.lerpVectors(a, b, k);
  const hz = Math.hypot(b.x - a.x, b.z - a.z);
  r.vert = Math.abs(b.y - a.y) > .01 && hz < .05;
  r.face = r.vert ? 0 : Math.atan2(b.x - a.x, b.z - a.z);
  r.pose = 'walk'; r.hidden = false; r.walking = true; r.d = d; r.spot = null;
  return r;
}
