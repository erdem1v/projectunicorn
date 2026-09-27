// Ofis 2 — Levent plaza, tam kat
let TT = null;
function towerTex(H) {
  if (TT) return TT;
  const mk = (night, seed) => H.canvasTex(256, 256, (x, w, h) => {
    const R = H.rng(seed), cw = 32, ch = 32;
    x.fillStyle = night ? '#0c1220' : '#7f97b0'; x.fillRect(0, 0, w, h);
    for (let fy = 0; fy < 8; fy++) for (let cx = 0; cx < 8; cx++) {
      const X0 = cx * cw, Y0 = fy * ch;
      if (night) { const r = R(); x.fillStyle = r < .22 ? '#ffd9a0' : r < .34 ? '#dfe8ff' : r < .4 ? '#8fa6c9' : '#141d33'; }
      else { const r = R(); x.fillStyle = r < .25 ? '#b9cadb' : r < .5 ? '#93aac2' : '#86a0ba'; }
      x.fillRect(X0 + 2, Y0 + 7, cw - 3, ch - 8);
      if (!night) { x.fillStyle = 'rgba(255,255,255,.18)'; x.fillRect(X0 + 2, Y0 + 7, (cw - 3) * .35, ch - 8); }
    }
    x.fillStyle = night ? '#05080f' : '#3d4a5c';
    for (let fy = 0; fy < 8; fy++) x.fillRect(0, fy * ch, w, 6);
    for (let cx = 0; cx < 8; cx++) x.fillRect(cx * cw, 0, 2, h);
  });
  TT = { day: [mk(0, 1), mk(0, 2)], night: [mk(1, 3), mk(1, 4)] };
  return TT;
}
export function towerMat(H, list, v, rx, ry, ox = 0) {
  const T = towerTex(H), d = T.day[v % 2].clone(), n = T.night[v % 2].clone();
  for (const t of [d, n]) { t.needsUpdate = true; t.repeat.set(rx, ry); t.offset.set(ox, 0); }
  const m = new H.THREE.MeshBasicMaterial({ map: d }); m.userData.d = d; m.userData.n = n; list.push(m); return m;
}
export function tickTowers(list, time, dayK) {
  const night = time > 1110 || time < 450;
  for (const m of list) { const t = night ? m.userData.n : m.userData.d; if (m.map !== t) { m.map = t; m.needsUpdate = true; } m.color.setScalar(night ? 1 : .55 + .45 * dayK); }
}
export const SP = (V, x, y, z, face, pose, chain) => ({ pos: V(x, y, z), face, pose, chain: chain.map(c => c.length === 3 ? V(c[0], c[1], c[2]) : V(c[0], y, c[1])), floor: 0 });
// island of 2 facing rows; chainFor(x, z, face) -> chain
export function makeIsland(H, g, cx, cz, n, sp, y, chainFor, desks, visits, st) {
  const { B, M, station, V } = H;
  for (const [z, f] of [[cz - 1.1, 0], [cz + 1.1, Math.PI]]) for (let j = 0; j < n; j++) {
    const x = cx + (j - (n - 1) / 2) * sp, ch = chainFor(x, z, f), dz = f === 0 ? -1 : 1;
    desks.push(SP(V, x, y, z, f, 'sit', ch));
    visits.push(SP(V, x + .32, y, z + dz * .82, f, 'stand', ch));
    st.desk.push(station(g, x, y, z, f, false, desks.length + Math.round(cx * 7)));
  }
  B(g, cx - n * sp / 2, cx + n * sp / 2, y + .74, y + 1.12, cz - .012, cz + .012, M(0xc9cfd3, { r: .9 }), { cast: false });
}

export function buildPlaza(H) {
  const { THREE, V, PI, M, X, B, RB, Cy, grp, floorP, station, wcSign, confPhone, poolTable, arcade, foosball, tv, armchair, sofaR, officeChair, woodChair, plant, sofa, coffeeMachine, kitchenRun, sink, fridge, toilet, printer, waterCooler, unicorn, whiteboard, glassDoor, decal, poolMat, fLampMat, CONEG, hazeMat, hazeMats, rng } = H;
  hazeMats.length = 0;
  const g = new THREE.Group(), W = 32, D = 23, TH = 2.9, SZ = 10.9, nc = { cast: false }, P = (...a) => SP(V, ...a);
  const towers = [];
  B(g, -.3, W + .3, -.35, 0, -.3, D + .3, X.edge, nc);
  floorP(g, 0, W, 0, D, .005, X.carpet, 2);
  floorP(g, 11.5, 19.5, 6.5, 10.4, .008, M(0xd9d3c7, { r: .3 }), 2);
  floorP(g, 0, 8.4, 9.9, D, .008, X.oakF, 2.4);
  floorP(g, 0, 11.5, 0, 6.5, .008, X.oakF, 2.4); floorP(g, 19.5, W, 0, 7.5, .008, X.oakF, 2.4);
  const segs = (a0, a1, gaps) => { const out = []; let cur = a0; for (const [a, b] of gaps) { out.push([cur, a]); cur = b; } out.push([cur, a1]); return out.filter(([a, b]) => b - a > .01); };
  const glassX = (z, x0, x1, h, gaps = []) => { for (const [a, b] of segs(x0, x1, gaps)) { B(g, a, b, .05, h, z - .012, z + .012, X.glass, nc); B(g, a, b, 0, .05, z - .03, z + .03, X.frame); B(g, a, b, h, h + .05, z - .03, z + .03, X.frame); const n = Math.max(1, Math.round((b - a) / 1.2)); for (let i = 0; i <= n; i++) { const x = a + (b - a) * i / n; B(g, x - .025, x + .025, 0, h, z - .03, z + .03, X.frame); } } };
  const glassZ = (x, z0, z1, h) => { B(g, x - .012, x + .012, .05, h, z0, z1, X.glass, nc); B(g, x - .03, x + .03, 0, .05, z0, z1, X.frame); B(g, x - .03, x + .03, h, h + .05, z0, z1, X.frame); const n = Math.max(1, Math.round((z1 - z0) / 1.2)); for (let i = 0; i <= n; i++) { const z = z0 + (z1 - z0) * i / n; B(g, x - .03, x + .03, 0, h, z - .025, z + .025, X.frame); } };
  const wallX = (z, x0, x1, h, gaps = [], m = X.wall) => { for (const [a, b] of segs(x0, x1, gaps)) { B(g, a, b, 0, h, z - .09, z + .09, m); B(g, a, b, h, h + .03, z - .09, z + .09, X.cap, nc); } };
  const wallZ = (x, z0, z1, h, m = X.wall) => { B(g, x - .09, x + .09, 0, h, z0, z1, m); B(g, x - .09, x + .09, h, h + .03, z0, z1, X.cap, nc); };
  // curtain walls (back + left), cut sills (front + right)
  const mull = M(0x2f343c, { r: .4, m: .6 });
  const curtainX = (x0, x1) => { B(g, x0, x1, 0, TH, -.02, .02, X.glass, nc); B(g, x0, x1, TH, TH + .12, -.1, .06, mull); B(g, x0, x1, 0, .1, -.1, .06, mull); for (let x = x0; x <= x1 + .01; x += 1.5) B(g, x - .03, x + .03, 0, TH, -.1, .06, mull); };
  curtainX(0, 11.5); curtainX(21, W);
  B(g, -.02, .02, 0, TH, 0, D, X.glass, nc); B(g, -.1, .06, TH, TH + .12, 0, D, mull); B(g, -.1, .06, 0, .1, 0, D, mull); for (let z = 0; z <= D + .01; z += 1.5) B(g, -.1, .06, 0, TH, z - .03, z + .03, mull);
  B(g, -.3, W + .3, 0, .5, D, D + .3, mull); B(g, W, W + .3, 0, .5, -.3, D + .3, mull);
  for (let x = 1.5; x < W; x += 1.5) B(g, x - .03, x + .03, .5, .75, D + .05, D + .12, mull, nc); for (let z = 1.5; z < D; z += 1.5) B(g, W + .05, W + .12, .5, .75, z - .03, z + .03, mull, nc);
  // core: elevators + WC
  const clad = M(0x5b4a3e, { r: .5 });
  wallX(6.5, 11.5, 21, TH, [[12.2, 13.4], [14.2, 15.4], [19.6, 20.5]], clad); wallZ(11.5, 0, 6.5, TH, clad); wallZ(21, 0, 6.5, TH, clad); wallX(.09, 11.5, 21, TH, [], clad); wcSign(g, 19.0, 2.0, 6.6, 0, 20.75);
  B(g, 11.5, 15.95, TH - .02, TH + .03, 0, 6.5, M(0x3a332e), nc); wallZ(15.95, 0, 6.5, TH, X.wall);
  B(g, 11.6, 15.9, .01, TH - .02, 5.2, 6.35, X.black, nc);
  const elP = [];
  for (const [a, b] of [[12.2, 13.4], [14.2, 15.4]]) { const m = (a + b) / 2;
    B(g, a - .08, b + .08, 2.3, 2.42, 6.38, 6.62, X.chrome, nc); B(g, a - .08, a, 0, 2.3, 6.38, 6.62, X.chrome, nc); B(g, b, b + .08, 0, 2.3, 6.38, 6.62, X.chrome, nc);
    const l = B(g, a, m, .01, 2.3, 6.47, 6.53, X.alu), r = B(g, m, b, .01, 2.3, 6.47, 6.53, X.alu);
    elP.push({ m: l, p0: l.position.x, d: -.58 }, { m: r, p0: r.position.x, d: .58 });
    B(g, m - .18, m + .18, 2.5, 2.58, 6.6, 6.64, M(0x9fd3ff, { e: 0x9fd3ff, ei: 1.2 }), nc); }
  floorP(g, 16.05, 20.9, 0, 6.4, .01, X.tileB, 1.2);
  for (const x of [17.2, 18.4, 19.6]) B(g, x - .03, x + .03, .1, 1.9, 0, 1.7, X.laminate);
  for (const [a, b] of [[16.05, 16.35], [17.05, 17.75], [18.25, 18.95], [19.45, 20.15], [20.65, 20.9]]) B(g, a, b, .1, 1.9, 1.66, 1.72, X.laminate);
  const wcs = [];
  for (const x of [16.6, 17.8, 19.0, 20.2]) { toilet(g, x, 0, .4); wcs.push(P(x, 0, 1.25, 0, 'stand', [[x, 2.6], [20.05, 2.6], [20.05, SZ]])); }
  RB(g, .55, .85, 3.2, 16.35, .425, 4.4, X.cabinet, .02); RB(g, .6, .04, 3.3, 16.35, .87, 4.4, X.stone, .01);
  for (const z of [3.4, 4.4, 5.4]) { Cy(g, .16, .05, 16.4, .9, z, X.ceramic); Cy(g, .012, .2, 16.15, .98, z, X.chrome); } B(g, 16.06, 16.08, 1.2, 2.1, 3.0, 5.8, M(0xcfd8de, { r: .05, m: .9 }), nc);
  // reception
  RB(g, .4, 1.05, 2.6, 17.8, .525, 8.9, M(0xe9e4da, { r: .6 }), .03); RB(g, .55, .04, 2.7, 17.82, 1.07, 8.9, X.walnut, .01);
  plant(g, 11.95, 0, 7.05, 1.1, 2); plant(g, 19.2, 0, 6.95, .9, 1);
  const desks = [], visits = [], st = { desk: [] };
  desks.push(P(19.1, 0, 8.9, -PI / 2, 'sit', [[19.7, 8.9], [19.7, SZ]])); visits.push(P(18.9, 0, 10.35, -PI / 2, 'stand', [[18.9, SZ]]));
  st.desk.push(station(g, 19.1, 0, 8.9, -PI / 2, false, 3));
  // meeting rooms A, B
  const rooms = { A: [], B: [], board: [] };
  const meetRoom = (key, x0, x1, door) => {
    const cx = (x0 + x1) / 2; RB(g, 3.2, .05, 1.0, cx, .74, 3.2, X.walnut, .02); confPhone(g, cx, .77, 3.2); for (const lx of [cx - 1.2, cx + 1.2]) B(g, lx - .04, lx + .04, 0, .72, 2.9, 3.5, X.metal);
    for (const dx of [-1.1, 0, 1.1]) rooms[key].push(P(cx + dx, 0, 2.3, 0, 'sit', [[cx + dx, 1.2], [x0 + .55, 1.2], [x0 + .55, 5.4], [door, 5.4], [door, SZ]]));
    for (const dx of [-1.1, 0, 1.1]) rooms[key].push(P(cx + dx, 0, 4.1, PI, 'sit', [[cx + dx, 5.4], [door, 5.4], [door, SZ]]));
    rooms[key].forEach(s => officeChair(g, s.pos.x, 0, s.pos.z, s.face, X.fabricW));
  };
  meetRoom('A', 0, 5.6, 4.8); meetRoom('B', 5.6, 11.5, 10.7);
  glassX(6.5, 0, 11.5, 2.6, [[4.3, 5.3], [10.2, 11.2]]); glassZ(5.6, 0, 6.5, 2.6); glassDoor(g, 5.3, 6.5, PI - .9); glassDoor(g, 11.2, 6.5, PI - .9);
  plant(g, .6, 0, .6, .9, 1); plant(g, 6.2, 0, .6, .9, 2);
  // board room
  RB(g, 4.2, .06, 1.2, 24.2, .74, 3.25, X.walnut, .02); for (const lx of [22.6, 25.8]) B(g, lx - .05, lx + .05, 0, .72, 2.9, 3.6, X.metal); confPhone(g, 24.2, .77, 3.25);
  rooms.board.push(P(26.6, 0, 3.25, -PI / 2, 'sit', [[26.6, 5.5], [21.9, 5.5], [21.9, SZ]]));
  for (let j = 0; j < 4; j++) { const x = 22.8 + j * .95; rooms.board.push(P(x, 0, 2.2, 0, 'sit', [[x, 1.2], [21.6, 1.2], [21.6, 5.5], [21.9, 5.5], [21.9, SZ]]), P(x, 0, 4.3, PI, 'sit', [[x, 5.5], [21.9, 5.5], [21.9, SZ]])); }
  rooms.board.forEach(s => officeChair(g, s.pos.x, 0, s.pos.z, s.face, M(0x2a211b, { r: .6 })));
  glassX(6.5, 21, 27, 2.6, [[21.4, 22.4]]); glassDoor(g, 22.4, 6.5, PI - .9); tv(g, 24.2, 1.5, .12, 1.8);
  plant(g, 21.5, 0, .6, .9, 2);
  // founder corner office
  glassZ(27, 0, 7.5, 2.6); glassX(7.5, 27, W, 2.6, [[27.4, 28.4]]); glassDoor(g, 28.4, 7.5, PI - .9);
  floorP(g, 27.5, 31.6, .5, 7.0, .014, X.rug, 1.5);
  const fs = P(29.8, 0, 1.4, 0, 'sit', [[28.2, 1.4], [28.2, 6.9], [27.9, 6.9], [27.9, SZ]]);
  st.founder = station(g, 29.8, 0, 1.4, 0, true, 99);
  RB(g, 2.4, .75, .4, 29.9, .375, .32, X.walnut, .02);
  { const T = .75; for (let i = 0; i < 4; i++) B(g, 28.85 + i * .045, 28.89 + i * .045, T, T + .2 + (i % 2) * .03, .2, .44, X.books[i]);
    plant(g, 29.5, T, .32, .34, 1); unicorn(g, 30.3, T, .32, 0);
    const fr = grp(g, 30.9, T, .3); fr.rotation.x = -.18; RB(fr, .3, .4, .03, 0, .2, 0, X.walnut, .008); B(fr, -.12, .12, .04, .36, .016, .02, X.paper, nc); B(fr, -.1, -.04, .13, .138, .021, .024, M(0xc0583f), nc); }
  armchair(g, 29.2, 0, 3.85, PI, M(0x4a2e22, { r: .6 })); armchair(g, 30.4, 0, 3.85, PI, M(0x4a2e22, { r: .6 }));
  whiteboard(g, 27.35, 0, 4.6, PI / 2); plant(g, 31.5, 0, 6.9, 1, 2);
  Cy(g, .14, .03, 27.55, .015, .55, X.metal); Cy(g, .02, 1.6, 27.55, .8, .55, X.metal); Cy(g, .22, .26, 27.55, 1.68, .55, fLampMat, { geo: CONEG });
  const pool = [decal(g, 29.5, .03, 3.6, 4.6, 6.4, poolMat)];
  // phone booths
  const booths = [], felt = M(0x5d6b5a, { r: 1 });
  for (let i = 0; i < 4; i++) { const z0 = 9.4 + i * 1.5, z1 = z0 + 1.5, zc = (z0 + z1) / 2, x0 = 30.4, x1 = 31.9, dz0 = zc - .05;
    B(g, x0, x1, 0, .04, z0, z1, X.frame, nc);
    for (const [a, b, c, d] of [[x0, x1, z0, z0 + .04], [x0, x1, z1 - .04, z1], [x0, x0 + .04, z0, z1], [x1 - .04, x1, z0, z1]]) B(g, a, b, 2.3, 2.36, c, d, X.frame, nc);
    B(g, x1 - .06, x1, 0, .95, z0, z1, felt); B(g, x1 - .012, x1, .95, 2.3, z0 + .03, z1 - .03, X.glass, nc);
    B(g, x0, x1, .04, .95, z0, z0 + .03, felt); B(g, x0, x1, .04, .95, z1 - .03, z1, felt); B(g, x0, x1, .95, 2.3, z0, z0 + .012, X.glass, nc); B(g, x0, x1, .95, 2.3, z1 - .012, z1, X.glass, nc);
    for (const [xx, zz] of [[x1, z0], [x1, z1], [x0, z0], [x0, z1]]) B(g, xx - .02, xx + .02, 0, 2.36, zz - .02, zz + .02, X.frame);
    B(g, x0, x0 + .012, .04, 2.3, z0 + .03, dz0, X.glass, nc); B(g, x0 - .02, x0 + .02, 0, 2.3, dz0 - .02, dz0 + .02, X.frame);
    { const d = grp(g, x0, 0, z1 - .03, PI / 2); B(d, -.006, .006, .04, 2.26, -.67, 0, X.glass, nc); B(d, -.02, .02, .04, 2.26, -.67, -.64, X.frame); B(d, -.05, -.02, .95, 1.25, -.6, -.58, X.chrome); }
    RB(g, .5, .45, 1.2, x1 - .31, .225, zc, felt, .04); RB(g, .12, .45, 1.2, x1 - .1, .68, zc, felt, .04);
    B(g, x0 + .15, x1 - .6, .72, .75, z0 + .03, z0 + .33, X.walnut);
    booths.push(P(x1 - .36, 0, zc, -PI / 2, 'sit', [[x0 + .35, zc + .25], [x0 - .5, zc + .25], [29.6, zc + .25], [29.6, SZ]])); }
  // cafe
  const kg = grp(g, 0, 0, 0, PI / 2);
  kitchenRun(kg, -15.2, -10.4, 0, .1, false); coffeeMachine(kg, -11.2, .89, .38); coffeeMachine(kg, -12.4, .89, .38); sink(kg, -14.4, 0, .45); fridge(kg, -16.3, -15.4, 0, .1, .85);
  const cof = [10.9, 11.8, 12.7, 13.6].map(z => P(1.35, 0, z, -PI / 2, 'stand', [[2.3, z], [2.3, SZ]]));
  const eat = [];
  for (const tz of [12.7, 15.9]) for (const tx of [3.9]) {
    RB(g, 1.4, .04, .8, tx, .74, tz, X.deskTop, .015); for (const [a, b] of [[-.6, -.3], [.6, -.3], [-.6, .3], [.6, .3]]) Cy(g, .02, .72, tx + a, .36, tz + b, X.metal);
    for (const dx of [-.4, .4]) { eat.push(P(tx + dx, 0, tz - .7, 0, 'sit', [[tx + dx, tz - 1.8], [5.45, tz - 1.8], [5.45, SZ]]), P(tx + dx, 0, tz + .7, PI, 'sit', [[tx + dx, tz + 1.8], [5.45, tz + 1.8], [5.45, SZ]])); }
  }
  eat.forEach(s => woodChair(g, s.pos.x, 0, s.pos.z, s.face));
  poolTable(g, 5.4, 0, 19.4, 0); arcade(g, 6.95, 0, 11.9, 0, 0x2b2f6b); arcade(g, 7.8, 0, 11.9, 0, 0x6b2b4a); foosball(g, 6.3, 0, 22.1, 0);
  sofaR(g, .55, 0, 18.7, PI / 2, 2.4, X.fabricG); RB(g, .6, .04, 1.1, 1.75, .4, 18.7, X.walnut, .02); armchair(g, 2.85, 0, 18.7, -PI / 2, X.fabricW); plant(g, .6, 0, 21.4, 1.1, 2); plant(g, 8.0, 0, 14.2, 1, 1);
  // department islands
  const aisles = [10.6, 16.6, 22.6, 28.6];
  const chainFor = (cz) => (x, z, f) => { const ax = aisles.reduce((a, b) => Math.abs(b - x) < Math.abs(a - x) ? b : a);
    if (cz < 16 && f === 0) return [[x, SZ]];
    const az = cz < 16 ? 16.15 : f === 0 ? 16.15 : 21.6; return [[x, az], [ax, az], [ax, SZ]]; };
  for (const cz of [13.1, 19.2]) for (const cx of [13.6, 19.6, 25.6]) makeIsland(H, g, cx, cz, 3, 1.4, 0, chainFor(cz), desks, visits, st);
 plant(g, 31.4, 0, 22.4, 1.1, 2); plant(g, 31.4, 0, 19.2, .9, 0); plant(g, 16.6, 0, 22.5, .9, 1); plant(g, 22.6, 0, 22.5, .9, 0);
  // outside: our tower below + plaza forest
  const TOP = -60;
  { const mz = new THREE.Mesh(new THREE.PlaneGeometry(W + .6, -TOP), towerMat(H, towers, 0, (W + .6) / 12, -TOP / 28.8)); mz.position.set(W / 2, TOP / 2 - .35, D + .31); g.add(mz);
    const mx = new THREE.Mesh(new THREE.PlaneGeometry(D + .6, -TOP), towerMat(H, towers, 1, (D + .6) / 12, -TOP / 28.8, .3)); mx.rotation.y = PI / 2; mx.position.set(W + .31, TOP / 2 - .35, D / 2); g.add(mx);
    B(g, -.3, W + .3, -.75, -.35, D + .3, D + .36, mull, nc); B(g, W + .3, W + .36, -.75, -.35, -.3, D + .3, mull, nc); }
  const R = rng(515);
  const tower = (x, z, s, top, v) => { const h = top - TOP, sm = towerMat(H, towers, v, s / 12, h / 28.8, R()), rm = hazeMat(0x8e949c);
    const me = new THREE.Mesh(new THREE.BoxGeometry(s, h, s), [sm, sm, rm, rm, sm, sm]); me.position.set(x, TOP + h / 2, z); me.userData.noEdge = false; g.add(me);
    B(g, x - s * .3, x + s * .15, top, top + 1.4 + R() * 2, z - s * .25, z + s * .2, rm, nc); if (R() < .5) B(g, x - s * .5, x + s * .5, top, top + .6, z - s * .5, z + s * .5, hazeMat(0x5d6470), nc); };
  [[-16, -24, 16, 58, 0], [8, -34, 18, 84, 1], [30, -22, 13, 36, 0], [50, -38, 20, 66, 1], [-40, -6, 18, 46, 1], [-26, 18, 13, 22, 0], [-50, 26, 16, 70, 0], [-24, -52, 20, 96, 1], [72, -20, 14, 30, 0],
   [52, 8, 16, -14, 1], [50, 36, 18, -26, 0], [22, 44, 16, -18, 1], [-6, 46, 18, -32, 0], [76, 30, 16, -8, 1], [34, 70, 20, -40, 0], [-30, 56, 14, -22, 1]].forEach(a => tower(...a));
  const OUT = P(12.8, 0, 5.6, 0, 'out', [[12.8, SZ]]);
  const byK = { A: rooms.A, B: rooms.B, board: rooms.board };
  const roles = ['sales', ...[['dev'], ['dev'], ['pm'], ['sales'], ['qa'], ['des']].flatMap(([r]) => Array(6).fill(r))];
  return {
    g, bounds: new THREE.Box3(V(-2, -7, -1), V(W + 2, 3, D + 2)), sunOff: V(16, 30, 22), fog: { near: 138, far: 205 }, sky: [], sconces: [], panes: [], low: [], posts: [], fades: [], pool, env: 'cevre',
    maxN: desks.length, spd: 3.2,
    peopleCfg: N => { const f = a => a.filter(i => i <= N);
      return { roles, eat: 8, cof: 4, wc: 4, booths: 4, allHands: null, meetings: [
        { t: 600, t1: 645, r: 'board', ids: [0, ...f([2, 8, 14, 20, 26, 32])], lab: 'Yönetim toplantısı' },
        { t: 660, t1: 705, r: 'A', ids: f([15, 16, 3, 4, 33, 34]), lab: 'Toplantı · ürün, yazılım, tasarım' },
        { t: 660, t1: 705, r: 'B', ids: f([17, 18, 9, 10, 35, 36]), lab: 'Toplantı · ürün, yazılım, tasarım' },
        { t: 870, t1: 915, r: 'B', ids: f([21, 22, 23, 24, 25, 1]), lab: 'Satış toplantısı' },
        { t: 960, t1: 1000, r: 'A', ids: f([27, 28, 29, 5, 11]), lab: 'Test planlama' }] }; },
    spot(p, s) { switch (s.k) { case 'desk': return p.id === 0 ? fs : desks[p.id - 1]; case 'visit': return visits[s.i % visits.length]; case 'meet': { const r = byK[s.r]; return r[s.i % r.length]; } case 'eat': return eat[s.i % eat.length]; case 'coffee': return cof[s.i % cof.length]; case 'wc': return wcs[s.i % wcs.length]; case 'booth': return booths[s.i % booths.length]; default: return OUT; } },
    elev: { o: 0, panels: elP, near: q => Math.abs(q.x - 13.8) < 2.2 && Math.abs(q.z - 7.0) < 1.6 },
    station: p => p.id === 0 ? st.founder : st.desk[p.id - 1], stations: [...st.desk, st.founder], connector: () => [],
    tick(time, dayK) { tickTowers(towers, time, dayK); },
  };
}
