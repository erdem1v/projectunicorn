// Ofis seçim haritası — kurgusal minyatür şehir dioraması
import { towerMat, tickTowers } from './office-plaza-v2.js';
import { hipRoof } from './office-home.js';

let FT = null;
function facTex(H) {
  if (FT) return FT;
  const mk = (draw, w = 128, h = 128) => { const t = H.canvasTex(w, h, draw); t.wrapS = t.wrapT = H.THREE.RepeatWrapping; return t; };
  FT = {
    old: mk((x, w, h) => { x.fillStyle = '#f4efe7'; x.fillRect(0, 0, w, h); x.fillStyle = '#e2d9cb'; x.fillRect(0, h - 8, w, 8); x.fillStyle = '#ebe4d8'; x.fillRect(37, 19, 54, 83); x.fillStyle = '#39404d'; x.fillRect(42, 24, 44, 74); x.fillStyle = '#ebe4d8'; x.fillRect(62, 24, 4, 74); x.fillRect(42, 48, 44, 4); x.fillStyle = '#d6cdbd'; x.fillRect(33, 100, 62, 7); }),
    mid: mk((x, w, h) => { x.fillStyle = '#f1efea'; x.fillRect(0, 0, w, h); x.fillStyle = '#3a4250'; x.fillRect(0, 26, w, 70); x.fillStyle = '#d9d6cf'; for (let i = 0; i < 4; i++) x.fillRect(i * 32, 26, 4, 70); x.fillStyle = '#cfcac0'; x.fillRect(0, 96, w, 6); }),
    ware: mk((x, w, h) => { x.fillStyle = '#f0ebe4'; x.fillRect(0, 0, w, h); for (let y = 12; y < h; y += 16) { x.fillStyle = 'rgba(0,0,0,.07)'; x.fillRect(0, y, w, 3); } x.fillStyle = '#3a4250'; x.fillRect(24, 18, 80, 30); x.fillStyle = '#e6e0d6'; for (let i = 0; i < 5; i++) x.fillRect(24 + i * 20, 18, 3, 30); }),
    em: mk((x, w, h) => { x.fillStyle = '#000'; x.fillRect(0, 0, w, h); let s = 7; const R = () => (s = (s * 16807) % 2147483647) / 2147483647;
      for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++) if (R() < .45) { x.fillStyle = R() < .7 ? '#ffc98a' : '#ffe4b5'; x.fillRect(i * 64 + 21, j * 64 + 12, 22, 37); } }, 256, 256),
  };
  FT.em.repeat.set(.25, .25);
  return FT;
}
function sideGeo(T, w, h, d, bay, fl, ou, ov) {
  const hw = w / 2, hd = d / 2, hh = h / 2, P = [], N = [], U = [], I = [], nv = Math.max(1, Math.round(h / fl));
  for (const [ax, az, bx, bz, nx, nz] of [[-hw, hd, hw, hd, 0, 1], [hw, hd, hw, -hd, 1, 0], [hw, -hd, -hw, -hd, 0, -1], [-hw, -hd, -hw, hd, -1, 0]]) {
    const nu = Math.max(1, Math.round(Math.hypot(bx - ax, bz - az) / bay)), b = P.length / 3;
    P.push(ax, -hh, az, bx, -hh, bz, bx, hh, bz, ax, hh, az); for (let k = 0; k < 4; k++) N.push(nx, 0, nz);
    U.push(ou, ov, ou + nu, ov, ou + nu, ov + nv, ou, ov + nv); I.push(b, b + 1, b + 2, b, b + 2, b + 3);
  }
  const g = new T.BufferGeometry(); g.setAttribute('position', new T.Float32BufferAttribute(P, 3)); g.setAttribute('normal', new T.Float32BufferAttribute(N, 3)); g.setAttribute('uv', new T.Float32BufferAttribute(U, 2)); g.setIndex(I); return g;
}

export function buildCity(H) {
  const { THREE, V, PI, M, X, B, RB, Cy, grp, floorP, tree, car, bench, lampPost, winUnit, lowDark, groundMat, walkMat, roadMat, grassMat, lineMat, hazeMats, rng, canvasTex } = H;
  hazeMats.length = 0;
  const g = new THREE.Group(), nc = { cast: false }, low = [], posts = [], keep = [], towers = [], facMats = [], R = rng(2024), nE = o => (o.userData.noEdge = true, o);
  const BAND = M(0xefe2c8, { r: .8 }), ROOFS = [M(0xb5553a, { r: .9 }), M(0xa24b36, { r: .9 }), M(0xc0674a, { r: .9 })], FLAT = M(0x8e8a84, { r: .9 }), METAL = M(0x5d6470, { r: .7 }), STONE = M(0xcfc6b6, { r: .8 });
  const FTX = facTex(H), cache = {};
  const facM = (style, c) => { const k = style + c; if (cache[k]) return cache[k]; const m = M(c, { map: FTX[style], r: .9 }); if (style !== 'ware') { m.emissive.set(0xffc27a); m.emissiveMap = FTX.em; m.emissiveIntensity = 0; facMats.push(m); } return cache[k] = m; };
  const sched = (office) => office ? { on: 450 + R() * 70, off: 1070 + R() * 200, allNight: R() < .08 } : { on: 1040 + R() * 120, off: 1290 + R() * 140, allNight: R() < .06 };
  // diorama base: land block + water on the near sides
  const LX0 = -84, LX1 = 80, LZ0 = -80, LZ1 = 52, WX1 = 112, WZ1 = 86;
  B(g, LX0, LX1, -8, -1.2, LZ0, LZ1, M(0x6b5a4c, { r: 1 }));
  const wbase = M(0x2f5f78, { r: .9 }); B(g, LX0, WX1, -8, -1.35, LZ1, WZ1, wbase); B(g, LX1, WX1, -8, -1.35, LZ0, LZ1, wbase);
  B(g, LX0, LX1, -1.2, 0, LZ0, LZ1, STONE); nE(floorP(g, LX0, LX1, LZ0, LZ1, .002, groundMat, 4));
  const wtex = canvasTex(256, 256, (x, w, h) => { const gr = x.createLinearGradient(0, 0, w, h); gr.addColorStop(0, '#3e84a6'); gr.addColorStop(1, '#2d6c8c'); x.fillStyle = gr; x.fillRect(0, 0, w, h); const R2 = rng(31);
    for (let i = 0; i < 110; i++) { const px = R2() * w, py = R2() * h, l = 10 + R2() * 30; x.strokeStyle = R2() < .45 ? 'rgba(255,255,255,.55)' : 'rgba(150,205,228,.6)'; x.lineWidth = 2 + R2() * 1.5; x.beginPath(); x.moveTo(px, py); x.quadraticCurveTo(px + l / 2, py - 4, px + l, py); x.stroke(); } });
  wtex.wrapS = wtex.wrapT = THREE.RepeatWrapping; wtex.repeat.set(18, 10);
  const water = M(0xffffff, { map: wtex, r: .7 });
  nE(B(g, LX0, WX1, -1.36, -1.2, LZ1, WZ1, water, nc)); nE(B(g, LX1, WX1, -1.36, -1.2, LZ0, LZ1, water, nc));
  B(g, LX0, LX1, 0, .25, LZ1 - .35, LZ1, STONE, nc); B(g, LX1 - .35, LX1, 0, .25, LZ0, LZ1, STONE, nc);
  // roads + blocks
  const road = (x0, x1, z0, z1, alongX) => { nE(B(g, x0, x1, 0, .04, z0, z1, roadMat, nc));
    if (alongX) { const zc = (z0 + z1) / 2; for (let x = x0 + 1; x < x1 - 2; x += 6) nE(B(g, x, x + 2.6, .04, .05, zc - .12, zc + .12, lineMat, nc)); }
    else { const xc = (x0 + x1) / 2; for (let z = z0 + 1; z < z1 - 2; z += 6) nE(B(g, xc - .12, xc + .12, .04, .05, z, z + 2.6, lineMat, nc)); } };
  road(LX0, LX1, 40, 46, 1); road(LX0, LX1, -20, -14, 1); road(LX0, LX1, -66, -60, 1); road(LX0, -44, 5, 11, 1);
  road(-44, -38, LZ0, 40, 0); road(14, 20, -60, 40, 0); road(70, 76, LZ0, 40, 0);
  const blocks = [[LX0, -44, -60, -20], [LX0, -44, -14, 5], [LX0, -44, 11, 40], [-38, 14, -14, 40], [-38, 14, -60, -20], [20, 70, -14, 40], [20, 70, -60, -20], [76, LX1, LZ0, 40], [LX0, -44, LZ0, -66], [-38, 14, LZ0, -66], [20, 70, LZ0, -66], [LX0, LX1, 46, LZ1 - .35]];
  for (const [a, b, c, d] of blocks) nE(B(g, a, b, 0, .12, c, d, walkMat, nc));
  // generic buildings
  const gen = (x0, x1, z0, z1, style, floors, color) => {
    const fl = style === 'tower' ? 3.6 : 3.2, h = floors * fl, cx = (x0 + x1) / 2, cz = (z0 + z1) / 2, w = x1 - x0, d = z1 - z0;
    if (style === 'tower') { const sz = towerMat(H, towers, 0, w / 12, h / 28.8, R()), sx = towerMat(H, towers, 1, d / 12, h / 28.8, R());
      const me = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), [sx, sx, FLAT, FLAT, sz, sz]); me.position.set(cx, h / 2, cz); me.castShadow = me.receiveShadow = true; g.add(me);
      B(g, x0 + w * .2, x1 - w * .3, h, h + 1.8, z0 + d * .2, z1 - d * .3, METAL, nc); return; }
    const me = new THREE.Mesh(sideGeo(THREE, w, h, d, style === 'ware' ? 4 : 2.6, fl, Math.floor(R() * 4), Math.floor(R() * 4)), facM(style, color)); me.position.set(cx, h / 2, cz); me.castShadow = me.receiveShadow = true; g.add(me);
    if (style === 'old') { B(g, x0 - .2, x1 + .2, h - .25, h, z0 - .2, z1 + .2, BAND, nc); hipRoof(H, g, x0 - .4, x1 + .4, z0 - .4, z1 + .4, h, Math.min(w, d) * .2, ROOFS[Math.floor(R() * 3)]); B(g, x0 + w * .7, x0 + w * .7 + .7, h, h + Math.min(w, d) * .2 + .8, cz, cz + .7, facM(style, color)); }
    else if (style === 'ware') hipRoof(H, g, x0 - .3, x1 + .3, z0 - .3, z1 + .3, h, 2.4, METAL);
    else { B(g, x0, x1, h - .05, h + .05, z0, z1, FLAT, nc); for (const [a, b, c, e] of [[x0, x1, z0, z0 + .25], [x0, x1, z1 - .25, z1], [x0, x0 + .25, z0, z1], [x1 - .25, x1, z0, z1]]) B(g, a, b, h, h + .6, c, e, BAND, nc); RB(g, 2.2, 1.6, 2.2, x0 + w * .3, h + .8, z0 + d * .35, M(0x9aa0a6), .1); }
  };
  const OLD = [0xd9a896, 0xb9c4a0, 0xd8b77a, 0xcdbfa9, 0xc9b49a, 0xd6c7ae, 0xe0c9b0], MID = [0xbfb8ad, 0xa9a4a8, 0xc2b5a0, 0xd0c8bb], WARE = [0xb07a5c, 0xa8765c];
  let oi = 0; const old = (...a) => gen(...a, OLD[oi++ % OLD.length]);
  old(-83, -70, -58, -46, 'old', 5); old(-70, -58, -58, -46, 'old', 4); old(-58, -45, -58, -45, 'old', 5); old(-83, -70, -43, -21, 'old', 4); old(-70, -58.5, -43, -21, 'old', 6);
  old(-83, -67.5, -12, 3, 'old', 4);
  old(-83, -70, 13, 26, 'old', 4); old(-70, -57, 13, 26, 'old', 5); old(-57, -46, 13, 26, 'old', 3); old(-83, -66, 28, 38, 'old', 3); gen(-66, -46, 28, 38, 'mid', 4, MID[0]);
  gen(4, 13, -52, -40, 'tower', 9); gen(22, 40, -58, -42, 'mid', 7, MID[1]); gen(42, 68, -58, -44, 'tower', 11); gen(22, 38, -38, -22, 'mid', 5, MID[2]); old(40, 54, -40, -22, 'old', 4); gen(56, 68, -40, -22, 'ware', 2, WARE[0]);
  gen(22, 38, -12, 2, 'ware', 2, WARE[1]); gen(40, 54, -12, 2, 'mid', 3, MID[3]); gen(56, 68, -12, 2, 'ware', 2, WARE[0]);
  [[-82, -66, 'mid', 8], [-64, -50, 'tower', 14], [-48, -40, 'mid', 6], [-36, -20, 'tower', 18], [-18, -2, 'mid', 9], [0, 13, 'tower', 15], [21, 32, 'mid', 7], [34, 48, 'tower', 12], [50, 60, 'mid', 6], [62, 69, 'tower', 10]]
    .forEach(([a, b, s, f], i) => gen(a, b, -79, -68, s, f, MID[i % 4]));
  // park
  nE(floorP(g, -36, 12, -12, 38, .13, grassMat, 4));
  nE(B(g, -36, 12, .12, .15, 11.5, 14, walkMat, nc)); nE(B(g, -13.5, -11, .12, .15, -12, 38, walkMat, nc)); nE(B(g, -36, -13.5, .12, .15, 29, 31, walkMat, nc));
  Cy(g, 6.6, .14, -25, .12, 22, STONE, { sz: .62 }); nE(Cy(g, 6.1, .1, -25, .16, 22, M(0xffffff, { map: wtex, r: .6 }), { sz: .6, cast: false }));
  { const pv = grp(g, 3, .15, 24); for (const [a, b] of [[-2, -2], [2, -2], [-2, 2], [2, 2]]) Cy(pv, .12, 2.6, a, 1.3, b, X.walnut); B(pv, -2.3, 2.3, 0, .25, -2.3, 2.3, STONE); hipRoof(H, pv, -3, 3, -3, 3, 2.6, 1.6, ROOFS[1]); }
  for (let i = 0; i < 26; i++) { let x, z, t = 0; do { x = -34 + R() * 44; z = -10 + R() * 46; t++; } while (t < 30 && (Math.abs(z - 12.7) < 2.2 || Math.abs(x + 12.2) < 2.2 || (Math.hypot((x + 25) / .62, z - 22) < 8.5) || (Math.abs(x - 3) < 4 && Math.abs(z - 24) < 4))); tree(g, x, .13, z, 1.2 + R() * .5); }
  for (const [x, z, r] of [[-20, 10.6, 0], [-4, 10.6, 0], [-14.7, 20, PI / 2], [-14.7, 32, PI / 2]]) bench(g, x, .13, z, r);
  // quay promenade + street trees + lamps
  for (let x = LX0 + 4; x < LX1 - 2; x += 9) { tree(g, x, .12, 49, 1.1, true); if ((x | 0) % 2) bench(g, x + 4.5, .12, 50.4, PI); }
  for (let x = LX0 + 8; x < LX1; x += 18) lampPost(g, posts, x, .12, 47.2);
  for (const [x, z] of [[-40, -22], [-40, 2], [-40, 30], [16, -22], [16, 2], [16, 30], [72, -22], [72, 2], [72, 30], [-60, 4], [-20, -22], [40, -22]]) lampPost(g, posts, x + (x > 0 ? 3 : -3), .12, z);
  for (let z = -56; z < 38; z += 8) { tree(g, 78, .12, z, 1, true); }
  // OFFICE 1 — İş hanı (4 kat, sıva + krem bantlar)
  const hits = [];
  { const x0 = -66, x1 = -46, z0 = -12, z1 = 3, F = 3.3, top = 4 * F, fac = M(0xc98f6d, { r: .9 });
    B(g, x0, x1, 0, top, z0, z1, fac);
    for (let f = 1; f < 4; f++) B(g, x0 - .05, x1 + .05, f * F - .16, f * F, z0 - .05, z1 + .05, BAND, nc);
    B(g, x0 - .3, x1 + .3, top - .3, top + .1, z0 - .3, z1 + .3, BAND); hipRoof(H, g, x0 - .4, x1 + .4, z0 - .4, z1 + .4, top + .1, 3.2, ROOFS[0]);
    const gf = grp(g, x0, 0, z1), gr = grp(g, x1, 0, 0, PI / 2);
    for (let f = 0; f < 4; f++) { for (let u = .8; u + 1.6 <= 19.6; u += 2.4) { if (f === 0 && u > 1.8 && u < 5.8) continue; winUnit(gf, u, u + 1.6, f * F + .9, f * F + 2.5, low, sched(1), BAND); }
      for (let z = z0 + .8; z + 1.6 <= z1 - .2; z += 2.4) winUnit(gr, -(z + 1.6), -z, f * F + .9, f * F + 2.5, low, sched(1), BAND); }
    B(g, x0 + 2.2, x0 + 5.4, .12, 2.8, z1, z1 + .08, M(0x6e4a32, { r: .7 })); B(g, x0 + 1.9, x0 + 5.7, 2.9, 3.05, z1, z1 + 1.2, M(0x3a3632));
    hits.push({ id: 'ishani', box: new THREE.Box3(V(x0, 0, z0), V(x1, top + 3.3, z1)), anchor: V((x0 + x1) / 2, top + 3.4, (z0 + z1) / 2) }); }
  // OFFICE 2 — Plaza kulesi (cam cephe)
  { const x0 = -30, x1 = 2, z0 = -56, z1 = -32, h = 13 * 3.6, cx = (x0 + x1) / 2, cz = (z0 + z1) / 2, mull = M(0x2f343c, { r: .4, m: .3 });
    const sz = towerMat(H, towers, 0, 32 / 12, h / 28.8), sx = towerMat(H, towers, 1, 24 / 12, h / 28.8, .3);
    const me = new THREE.Mesh(new THREE.BoxGeometry(32, h, 24), [sx, sx, FLAT, FLAT, sz, sz]); me.position.set(cx, h / 2, cz); me.castShadow = me.receiveShadow = true; g.add(me);
    B(g, x0 - 2, x1 + 2, 0, 5.2, z0 - 2, z1 + 2, M(0x3a3f47, { r: .5 })); B(g, x0 - 2.2, x1 + 2.2, 5.2, 5.5, z0 - 2.2, z1 + 2.2, mull);
    B(g, x0 - .3, x1 + .3, h, h + 2.4, z0 - .3, z1 + .3, mull); B(g, cx + 6, cx + 7, h + 2.4, h + 12, cz - .5, cz + .5, mull);
    B(g, cx - 5, cx + 5, 3.4, 3.7, z1 + 2, z1 + 5, mull);
    nE(B(g, -36, 12, .12, .16, -30, -21, walkMat, nc)); Cy(g, 3.2, .5, -14, .4, -25.5, STONE); nE(Cy(g, 2.8, .1, -14, .62, -25.5, M(0xffffff, { map: wtex, r: .6 }), { cast: false })); Cy(g, .3, 1.6, -14, 1.2, -25.5, STONE);
    for (const x of [-34, -26, -2, 6]) tree(g, x, .16, -25, 1.1, true);
    hits.push({ id: 'plaza', box: new THREE.Box3(V(x0 - 2, 0, z0 - 2), V(x1 + 2, h + 3, z1 + 2)), anchor: V(cx, h + 4, cz) }); }
  // OFFICE 3 — Tuğla depo (kemerli çelik pencereler, baca)
  { const x0 = 22, x1 = 68, z0 = 4, z1 = 38, WH = 7.6, brick = M(0xa65a42, { r: .95 }), brickD = M(0x8a4a38, { r: .95 }), cap = M(0xd9cfbf, { r: .7 }), steel = M(0x26282c, { r: .6 });
    B(g, x0, x1, 0, WH, z0, z1, brick);
    for (let y = 1.2; y < WH; y += 1.2) { B(g, x0, x1, y, y + .05, z1, z1 + .02, brickD, nc); B(g, x1, x1 + .02, y, y + .05, z0, z1, brickD, nc); }
    B(g, x0 - .3, x1 + .3, WH, WH + .15, z0 - .3, z1 + .3, cap); hipRoof(H, g, x0 - .2, x1 + .2, z0 - .2, z1 + .2, WH + .15, 3.6, METAL);
    const arch = (gl, u0, u1, y0, y1) => { B(gl, u0 - .12, u1 + .12, y0 - .15, y0 - .05, 0, .14, cap, nc);
      const p = B(gl, u0, u1, y0, y1, .02, .03, lowDark, nc); p.userData.sched = sched(1); low.push(p);
      for (let u = u0; u <= u1 + .01; u += (u1 - u0) / 3) B(gl, u - .03, u + .03, y0, y1, .03, .07, steel, nc);
      for (let y = y0; y <= y1 + .01; y += (y1 - y0) / 4) B(gl, u0, u1, y - .03, y + .03, .03, .07, steel, nc);
      for (let i = 0; i < 3; i++) { const w = (u1 - u0) * (1 - i * .28) / 2, m = (u0 + u1) / 2, yy = y1 + i * .22; B(gl, m - w - .06, m + w + .06, yy, yy + .22, 0, .09, brickD, nc); } };
    const gf = grp(g, x0, 0, z1), gr = grp(g, x1, 0, 0, PI / 2);
    for (let u = 1.6; u + 2.2 < x1 - x0; u += 4.2) { arch(gf, u, u + 2.2, 4.4, 6.6); if (u < 28 || u > 33) arch(gf, u, u + 2.2, 1.0, 3.2); }
    for (let z = z0 + 1.6; z + 2.2 < z1; z += 4.2) { arch(gr, -(z + 2.2), -z, 4.4, 6.6); arch(gr, -(z + 2.2), -z, 1.0, 3.2); }
    B(g, x0 + 29.8, x0 + 33.8, .12, 3.8, z1, z1 + .1, M(0x3f6f7a, { r: .7 })); B(g, x0 + 29.4, x0 + 34.2, 3.8, 4.05, z1, z1 + .16, steel);
    Cy(g, 1.1, 21, x0 + 4, 10.5, z0 + 4, brick); Cy(g, 1.35, .6, x0 + 4, 21.1, z0 + 4, brickD); Cy(g, 1.25, .4, x0 + 4, 15, z0 + 4, brickD, nc);
    hits.push({ id: 'depo', box: new THREE.Box3(V(x0, 0, z0), V(x1, WH + 3.8, z1)), anchor: V((x0 + x1) / 2, WH + 5, (z0 + z1) / 2) }); }
  // Kurucunun evi (6 katlı eski apartman, köşe)
  { const x0 = -57, x1 = -45, z0 = -30.6, z1 = -21, F = 3.2, top = 6 * F, fac = M(0xd4ad8c, { r: .9 }), iron = M(0x1f2126, { r: .6 });
    B(g, x0, x1, 0, top, z0, z1, fac); for (let f = 1; f < 6; f++) B(g, x0 - .05, x1 + .05, f * F - .16, f * F, z0 - .05, z1 + .05, BAND, nc);
    B(g, x0 - .25, x1 + .25, top - .25, top, z0 - .25, z1 + .25, BAND); hipRoof(H, g, x0 - .4, x1 + .4, z0 - .4, z1 + .4, top, 2.6, ROOFS[2]);
    const gf = grp(g, x0, 0, z1), gr = grp(g, x1, 0, 0, PI / 2);
    for (let f = 0; f < 6; f++) { const y = f * F; for (const [a, b] of [[.8, 2.0], [3.4, 4.6], [6.3, 7.5], [8.5, 9.7], [10.5, 11.5]]) winUnit(gf, a, b, y + .85, y + 2.55, low, sched(0), BAND);
      for (const [a, b] of [[.8, 2.0], [3.6, 4.8], [6.0, 7.2], [8.0, 9.2]]) winUnit(gr, -(z0 + b), -(z0 + a), y + .85, y + 2.55, low, sched(0), BAND);
      if (f) { B(g, x0 + 2.6, x0 + 5.4, y - .18, y, z1, z1 + 1.1, BAND); B(g, x0 + 2.6, x0 + 5.4, y + .9, y + .98, z1 + 1.04, z1 + 1.1, iron, nc); for (let x = x0 + 2.7; x < x0 + 5.35; x += .3) B(g, x - .02, x + .02, y, y + .9, z1 + 1.05, z1 + 1.09, iron, nc); } }
    hits.push({ id: 'ev', box: new THREE.Box3(V(x0, 0, z0), V(x1, top + 2.6, z1)), anchor: V((x0 + x1) / 2, top + 3, (z0 + z1) / 2) }); }
  // selection frames + current marker
  const selM = M(0xffffff, { e: 0xfff4d6, ei: 1.2 }), frames = {};
  for (const h of hits) { const f = new THREE.Group(), b = h.box, pad = 1.2, y = .2, t = .35; f.visible = false;
    for (const [a, c, d, e] of [[b.min.x - pad, b.max.x + pad, b.min.z - pad, b.min.z - pad + t], [b.min.x - pad, b.max.x + pad, b.max.z + pad - t, b.max.z + pad], [b.min.x - pad, b.min.x - pad + t, b.min.z - pad, b.max.z + pad], [b.max.x + pad - t, b.max.x + pad, b.min.z - pad, b.max.z + pad]]) B(f, a, c, y, y + .12, d, e, selM, nc);
    g.add(f); keep.push(f); frames[h.id] = f; }
  const pinM = M(0xf4c430, { e: 0xf4c430, ei: .45, r: .5 }), pin = new THREE.Group(), oct = new THREE.Mesh(new THREE.OctahedronGeometry(2, 0), pinM);
  oct.scale.y = 1.6; oct.castShadow = true; pin.add(oct); pin.visible = false; g.add(pin); keep.push(pin);
  let pinBase = 0;
  // ferry + boats
  const ferry = grp(g, 0, -1.2, 70); keep.push(ferry);
  const fw = M(0xf4f1ea, { r: .6 }), fwin = M(0x2c3446, { r: .6, e: 0xffd9a0, ei: 0 });
  RB(ferry, 16, 1.6, 4.2, 0, .8, 0, fw, .5); B(ferry, -8, 8, .9, 1.1, -2.12, 2.12, M(0x2b3a55), nc); RB(ferry, 11, 1.5, 3.6, -.8, 2.35, 0, fw, .2);
  B(ferry, -6.2, 4.6, 2.2, 2.7, -1.82, 1.82, fwin, nc); RB(ferry, 5, .9, 2.6, -1.4, 3.55, 0, fw, .15); Cy(ferry, .45, 1.6, -3, 4.6, 0, M(0x2b2a2a));
  const boats = []; // export handle (tools/office3d)
  for (const [bx, bz, br] of [[-40, 60, .3], [20, 78, -.5], [96, 30, 1.2], [92, -40, 1.6]]) { const bt = grp(g, bx, -1.2, bz, br); boats.push(bt); RB(bt, 4.2, .7, 1.5, 0, .3, 0, M(0xf4f1ea, { r: .7 }), .3); B(bt, -2.1, 2.1, .45, .55, -.76, .76, M(0x2b5a88, { r: .8 }), nc); RB(bt, 1.4, .8, 1.1, -.5, 1.05, 0, M(0xe7e2d6, { r: .7 }), .1); }
  // moving cars
  const lanes = [[[LX0, 44.4], [LX1, 44.4]], [[LX1, 41.6], [LX0, 41.6]], [[LX0, -15.6], [LX1, -15.6]], [[LX1, -18.4], [LX0, -18.4]], [[LX1, -64.4], [LX0, -64.4]],
    [[-42.4, LZ0], [-42.4, 40]], [[-39.6, 40], [-39.6, LZ0]], [[71.6, LZ0], [71.6, 40]], [[18.4, 40], [18.4, -60]], [[LX0, 9.4], [-44, 9.4]]];
  const COLS = [0xc0583f, 0x3f6f7a, 0xe9e4da, 0x34384a, 0x6f9a7a, 0xd98c5f, 0x2d3a55];
  const cars = [];
  lanes.forEach(([a, b], i) => { for (let k = 0; k < (i < 4 ? 2 : 1); k++) { const hg = new THREE.Group(); hg.scale.setScalar(1.5); g.add(hg); keep.push(hg);
    car(hg, 0, 0, 0, 0, i % 3 === 1 && k ? 0xf2c230 : COLS[(i * 2 + k) % COLS.length], i % 3 === 1 && !!k);
    const dx = b[0] - a[0], dz = b[1] - a[1], len = Math.hypot(dx, dz); cars.push({ hg, a, dx, dz, len, v: 7 + R() * 4, ph: R() * len, ry: Math.atan2(-dz, dx) }); } });
  return {
    g, bounds: new THREE.Box3(V(LX0, -2, LZ0), V(WX1, 14, WZ1)), sunOff: V(40, 60, 50), fog: null, sky: [], sconces: [], panes: [], low, posts, fades: [], pool: [], env: 'cevre', keep,
    maxN: 0, spd: 3, noPeople: true, mapHits: hits,
    frames, pin, ferry, cars, boats, wtex, facMats, // export handles (tools/office3d)
    setMapState(s) { for (const id in frames) frames[id].visible = id === s.selected;
      const h = hits.find(q => q.id === s.current); pin.visible = !!h; if (h) { pin.position.set(h.anchor.x, 0, h.anchor.z); pinBase = h.anchor.y + 3.4; } },
    people: () => [], peopleCfg: () => ({ roles: [], meetings: [] }), spot: () => null, station: () => null, stations: [], connector: () => [],
    tick(time, dayK) {
      const now = performance.now() * .001, nk = 1 - dayK;
      tickTowers(towers, time, dayK);
      for (const m of facMats) m.emissiveIntensity = nk * 1.25;
      wtex.offset.set((now * .004) % 1, Math.sin(now * .25) * .01);
      ferry.position.x = LX0 - 10 + ((now * 3.4) % 140); fwin.emissiveIntensity = nk > .5 ? 1.4 : 0;
      for (const c of cars) { const s = ((now * c.v + c.ph) % c.len) / c.len; c.hg.position.set(c.a[0] + c.dx * s, .04, c.a[1] + c.dz * s); c.hg.rotation.y = c.ry; }
      if (pin.visible) { pin.position.y = pinBase + Math.sin(now * 2.2) * .7; pin.rotation.y = now * 1.1; }
    },
  };
}
