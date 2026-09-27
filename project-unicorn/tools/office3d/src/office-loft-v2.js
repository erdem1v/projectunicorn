// Ofis 3 — Karaköy, dönüştürülmüş depo (zemin + asma kat) — v2 ferah yerleşim
import { SP, makeIsland } from './office-plaza-v2.js';

export function buildLoft(H) {
  const { THREE, V, PI, M, X, TEX, B, RB, Cy, grp, floorP, station, wcSign, confPhone, armchair, barCart, floorLamp, sofaR, poolTable, arcade, foosball, pingPong, beanBag, officeChair, plant, sofa, bookshelf, coffeeMachine, kitchenRun, fridge, toilet, unicorn, whiteboard, glassDoor, decal, poolMat, hazeMat, brickMat, hazeMats, rng, canvasTex, sconce, tree, car, bench, lampPost, winUnit, lowDark, walkMat, roadMat, lineMat, CONEG } = H;
  hazeMats.length = 0;
  const g = new THREE.Group(), W = 46, D = 34, MY = 3.6, WH = 7.6, MZ = 7, VZ = 5.7, HZ = 21, SZ = 31.6, SX = 22.5, nc = { cast: false }, P = (...a) => SP(V, ...a);
  const brick = M(0xa65a42, { r: .95 }), brickD = M(0x8a4a38, { r: .95 }), steel = M(0x26282c, { r: .6 }), conc = M(0xbdb5a8, { r: .8 }), cap = M(0xd9cfbf, { r: .7 }), oak = X.deskTop;
  const low = [], posts = [], sc = [], keep = [];
  // shell
  B(g, -.3, W + .3, -.5, 0, -.3, D + .3, M(0x7d746a), nc);
  floorP(g, 0, W, 0, D, .005, conc, 3);
  B(g, -.3, 0, -.5, WH, -.3, D + .3, brick); B(g, -.3, W + .3, -.5, WH, -.3, 0, brick);
  B(g, -.36, .02, WH, WH + .12, -.36, D + .3, cap, nc); B(g, -.36, W + .36, WH, WH + .12, -.36, .02, cap, nc);
  for (let y = 1.2; y < WH; y += 1.2) { B(g, 0, .02, y, y + .05, 0, D, brickD, nc); B(g, 0, W, y, y + .05, 0, .02, brickD, nc); }
  const DX0 = 43.2, DX1 = 44.8;
  B(g, -.3, DX0, -.5, .9, D, D + .3, brick); B(g, DX1, W + .3, -.5, .9, D, D + .3, brick);
  B(g, -.36, DX0, .9, 1.0, D - .04, D + .34, cap, nc); B(g, DX1, W + .36, .9, 1.0, D - .04, D + .34, cap, nc); B(g, DX0, DX1, -.02, .02, D, D + .3, steel, nc);
  B(g, W, W + .3, -.5, .9, -.3, D + .3, brick); B(g, W - .04, W + .34, .9, 1.0, -.3, D + .34, cap, nc);
  B(g, W, W + .3, MY - .25, MY + .9, -.3, MZ + 1.1, brick); B(g, W - .04, W + .34, MY + .9, MY + 1.0, -.3, MZ + 1.1, cap, nc);
  const win = (x0, x1, y0, y1) => { B(g, x0 - .12, x1 + .12, y0 - .15, y0 - .05, 0, .14, cap);
    keep.push(B(g, x0, x1, y0, y1, .02, .03, lowDark, nc));
    for (let x = x0; x <= x1 + .01; x += (x1 - x0) / 3) B(g, x - .03, x + .03, y0, y1, .03, .07, steel, nc);
    for (let y = y0; y <= y1 + .01; y += (y1 - y0) / 4) B(g, x0, x1, y - .03, y + .03, .03, .07, steel, nc);
    for (let i = 0; i < 3; i++) { const w = (x1 - x0) * (1 - i * .28) / 2, m = (x0 + x1) / 2, yy = y1 + i * .22; B(g, m - w - .06, m + w + .06, yy, yy + .22, 0, .09, brickD, nc); } };
  for (let x = 1.6; x + 2 < W; x += 4.2) win(x, x + 2.2, MY + .8, WH - 1.0);
  // mezzanine (slab casts shadow; partition closes the void behind the kitchen)
  B(g, 0, W, MY - .25, MY, 0, MZ, M(0x6f6258)); floorP(g, 0, W, 0, MZ, MY + .005, X.oakF, 2.4);
  B(g, 0, W, MY - .5, MY, MZ - .12, MZ + .1, steel);
  for (const x of [7.3, 15.3, 29.7, 44.2]) B(g, x - .12, x + .12, 0, MY - .5, MZ - .13, MZ + .11, steel);
  const rail = (x0, x1) => { B(g, x0, x1, MY, MY + 1.05, MZ - .07, MZ - .03, X.glass, nc); B(g, x0, x1, MY + 1.05, MY + 1.1, MZ - .1, MZ, steel); };
  rail(0, 19.35); rail(25.65, 36.8);
  B(g, 7, W, 0, MY - .25, 5.0, 5.1, X.wall);
  // WC
  const wallX = (z, x0, x1, h, gaps = []) => { let cur = x0; for (const [a, b] of [...gaps, [x1, x1]]) { if (a - cur > .01) B(g, cur, a, 0, h, z - .08, z + .08, X.wall); cur = b; } };
  wallX(7, 0, 7, MY - .25, [[5.6, 6.6]]); B(g, 6.92, 7.08, 0, MY - .25, 0, 7, X.wall);
  floorP(g, 0, 7, 0, 7, .01, X.tileB, 1.2);
  const wcs = [1.2, 2.6, 4.0].map(x => { toilet(g, x, 0, .4); B(g, x + .66, x + .72, .1, 1.9, 0, 1.7, X.laminate); return P(x, 0, 1.25, 0, 'stand', [[x, 2.6], [6.1, 2.6], [6.1, 7.8], [8.2, 7.8], [8.2, HZ]]); });
  RB(g, .55, .85, 2.2, 6.5, .425, 4.2, X.cabinet, .02); RB(g, .6, .04, 2.3, 6.5, .87, 4.2, X.stone, .01);
  { const dr = grp(g, 6.55, 0, 6.88, PI / 2); B(dr, 0, 1.0, 0, 2.2, -.03, .03, X.walnut); B(dr, .85, .9, .95, 1.05, -.07, .07, X.chrome); }
  wcSign(g, 4.6, 2.0, 7.09, 0, 6.82);
  // phone booths under the mezzanine
  const booths = [], felt = M(0x5d6b5a, { r: 1 });
  for (let i = 0; i < 4; i++) { const x0 = 8.9 + i * 1.4, x1 = x0 + 1.4, xc = (x0 + x1) / 2, z0 = 5.15, z1 = 6.85, dx = xc - .05;
    B(g, x0 - .03, x0 + .03, 0, 2.3, z0, z1, felt); B(g, x0, x1, 2.3, 2.36, z0, z1, steel, nc); B(g, x0, x1, 0, .04, z0, z1, steel, nc);
    B(g, x0 + .03, dx, .04, 2.3, z1 - .012, z1, X.glass, nc); B(g, dx - .02, dx + .02, 0, 2.3, z1 - .03, z1 + .01, steel);
    { const d = grp(g, x1 - .03, 0, z1, 0); B(d, -.006, .006, .04, 2.26, 0, .62, X.glass, nc); B(d, -.02, .02, .04, 2.26, .59, .62, steel); B(d, -.06, -.02, .95, 1.25, .5, .52, X.chrome); }
    RB(g, 1.2, .45, .45, xc, .225, z0 + .27, felt, .04); RB(g, 1.2, .45, .12, xc, .68, z0 + .07, felt, .04);
    B(g, x0 + .03, x0 + .33, .72, .75, z0 + .55, z1 - .15, X.walnut);
    booths.push(P(xc, 0, z0 + .36, 0, 'sit', [[xc + .3, z1 - .35], [xc + .3, 7.8], [8.2, 7.8], [8.2, HZ]])); }
  B(g, 14.47, 14.53, 0, 2.3, 5.15, 6.85, felt);
  // tribune (amphitheatre) + stair + stage with open forum
  const DOWN = [[SX, .45, 13.0], [SX, 0, 13.4], [17.6, 0, 14.4], [17.6, 0, HZ]];
  const trib = [], cush = [M(0xc98b5a, { r: 1 }), M(0x6f8a7a, { r: 1 }), M(0xd9c3a3, { r: 1 })];
  for (let k = 0; k < 8; k++) { const yt = (k + 1) * .45, zb = 13 - k * .75, za = zb - .75, sh = k * .55, xa = 15.5 + sh, xb = 29.5 - sh;
    B(g, xa, xb, 0, yt, za, zb, k % 2 ? oak : X.oakF); B(g, xa - .12, xa, 0, yt + .06, za, zb, steel); B(g, xb, xb + .12, 0, yt + .06, za, zb, steel); B(g, xa, xb, yt - .03, yt, zb - .02, zb + .01, steel, nc);
    if (k < 7) { const n = Math.floor((xb - xa - .4) / .8); for (let i = 0; i < n; i++) { const x = xa + .6 + i * .8; if (Math.abs(x - SX) < .55) continue; const zs = zb - .32;
      if ((i + k) % 3 !== 1) B(g, x - .26, x + .26, yt, yt + .05, zs - .22, zs + .2, cush[(i + k) % 3], nc);
      trib.push(P(x, yt - .46, zs, 0, 'sit', [[x, yt, zs], [SX, yt, zs], ...DOWN])); } } }
  for (let k = 0; k < 8; k++) { const yt = (k + 1) * .45, zb = 13 - k * .75; for (let i = 0; i < 3; i++) B(g, SX - .3, SX + .3, yt - .45 + i * .15, yt - .45 + (i + 1) * .15, zb - .75 + i * .25, zb - .75 + (i + 1) * .25, M(0x3a3632, { r: .8 }), nc); }
  B(g, 18.5, 26.5, 0, .2, 15.6, 17.8, M(0x2a2725, { r: .8 })); B(g, 18.5, 26.5, .2, .22, 15.6, 17.8, oak, nc);
  RB(g, .55, 1.1, .4, SX, .75, 16.2, X.walnut, .02);
  for (const x of [18.9, 26.1]) { Cy(g, .04, 1.4, x, .9, 17.4, steel); RB(g, .34, .5, .3, x, 1.8, 17.4, M(0x1b1d22, { r: .7 }), .03); }
  const PRES = P(SX, .22, 16.9, PI, 'stand', [[SX, 0, 18.4], [SX, 0, HZ]]);
  // kitchen (against partition) + dining
  kitchenRun(g, 31, 40.6, 0, 5.1, true); fridge(g, 40.8, 41.7, 0, 5.1, 5.95); fridge(g, 41.8, 42.7, 0, 5.1, 5.95);
  B(g, 31, 40.6, .86, 1.6, 5.1, 5.11, X.tile, nc); coffeeMachine(g, 32.2, .86, 5.4); coffeeMachine(g, 33.6, .86, 5.4); plant(g, 45.3, 0, 5.7, 1.1, 2);
  const cof = [31.8, 33.0, 34.2, 35.4, 36.6].map(x => P(x, 0, 6.35, PI, 'stand', [[x, 7.2], [30.6, 7.2], [30.6, HZ]]));
  RB(g, 10, .06, 1.0, 37.3, .74, 9.5, X.walnut, .02); for (const x of [32.9, 41.7]) B(g, x - .05, x + .05, 0, .72, 9.1, 9.9, steel);
  for (const z of [8.5, 10.5]) { RB(g, 10, .06, .36, 37.3, .45, z, oak, .02); for (const x of [32.7, 41.9]) B(g, x - .04, x + .04, 0, .43, z - .14, z + .14, steel); }
  const eat = [];
  for (let j = 0; j < 9; j++) { const x = 33.1 + j * 1.05; eat.push(P(x, 0, 8.5, 0, 'sit', [[x, 7.6], [30.6, 7.6], [30.6, HZ]]), P(x, 0, 10.5, PI, 'sit', [[x, 11.5], [30.6, 11.5], [30.6, HZ]])); }
  // game zone
  plant(g, 45.3, 0, 12.8, 1.1, 2); plant(g, 45.3, 0, 19.8, 1, 0);
  floorP(g, 33.6, 39.4, 27.2, 31.2, .012, X.rug2, 1.5); sofaR(g, 34.1, 0, 29.2, PI / 2, 2.6, X.fabricB); RB(g, .7, .04, 1.2, 35.4, .4, 29.2, X.walnut, .02); armchair(g, 36.8, 0, 28.4, -PI / 2, X.fabricG); armchair(g, 36.8, 0, 30.0, -PI / 2, X.fabricG); plant(g, 39.0, 0, 27.6, 1, 2); plant(g, 33.9, 0, 31.0, .9, 1);

  // meeting rooms (party-wall side)
  const rooms = { r1: [], r2: [], r3: [], board: [] };
  ['r1', 'r2', 'r3'].forEach((key, i) => { const z0 = 8.2 + i * 6, z1 = z0 + 6, zc = (z0 + z1) / 2, dz = z1 - .55;
    floorP(g, 0, 7.5, z0, z1, .01, X.oakF, 2.4);
    B(g, 7.49, 7.51, .05, 2.6, z0, z1 - 1.0, X.glass, nc); B(g, 7.47, 7.53, 2.6, 2.65, z0, z1, steel); B(g, 7.47, 7.53, 0, .05, z0, z1 - 1.0, steel);
    for (let z = z0; z <= z1 - 1 + .01; z += 1.25) B(g, 7.47, 7.53, 0, 2.6, z - .025, z + .025, steel);
    glassDoor(g, 7.5, z1 - .1, PI / 2 + .9);
    B(g, 0, 7.5, .05, 2.6, z0 - .012, z0 + .012, X.glass, nc); B(g, 0, 7.5, 2.6, 2.65, z0 - .03, z0 + .03, steel); B(g, 0, 7.5, 0, .05, z0 - .03, z0 + .03, steel);
    RB(g, 1.0, .05, 3.2, 3.6, .74, zc, X.walnut, .02); confPhone(g, 3.6, .77, zc); for (const z of [zc - 1.2, zc + 1.2]) B(g, 3.3, 3.9, 0, .72, z - .04, z + .04, steel);
    for (const d of [-1.1, 0, 1.1]) rooms[key].push(P(2.3, 0, zc + d, PI / 2, 'sit', [[1.3, zc + d], [1.3, dz], [8.2, dz], [8.2, HZ]]), P(4.9, 0, zc + d, -PI / 2, 'sit', [[6.8, zc + d], [6.8, dz], [8.2, dz], [8.2, HZ]]));
    plant(g, .6, 0, z0 + .6, .9, i % 3); sconce(sc, g, .1, 2.3, zc, PI / 2);
  });
  B(g, 0, 7.5, .05, 2.6, 26.188, 26.212, X.glass, nc); B(g, 0, 7.5, 2.6, 2.65, 26.17, 26.23, steel);
  // lounge nook
  floorP(g, .3, 6.8, 26.8, 33.2, .012, X.rug2, 1.5);
  sofaR(g, .55, 0, 29.8, PI / 2, 2.6, X.fabricG); RB(g, .7, .04, 1.2, 1.9, .4, 29.8, X.walnut, .02); armchair(g, 3.3, 0, 29.8, -PI / 2, X.fabricW);
  floorLamp(g, .6, 0, 27.4); plant(g, .6, 0, 32.9, 1.1, 2); plant(g, 6.6, 0, 33.0, 1, 0);
  // islands
  const aisles = [8.2, 15.8, 24.0, 32.2, 40.4], desks = [], visits = [], st = { desk: [] };
  const near = x => aisles.reduce((a, b) => Math.abs(b - x) < Math.abs(a - x) ? b : a);
  const chainFor = cz => (x, z, f) => { const ax = near(x);
    if (cz < 20) { const xa = x < 37.3 ? 33.6 : 41.0; return f === 0 ? [[x, 13.3], [xa, 13.3], [xa, HZ]] : [[x, HZ]]; }
    if (cz < 26) return f === 0 ? [[x, HZ]] : [[x, 26.3], [ax, 26.3], [ax, HZ]];
    return f === 0 ? [[x, 26.3], [ax, 26.3], [ax, HZ]] : [[x, SZ], [ax, SZ], [ax, HZ]]; };
  for (const [cx, cz] of [[11.7, 23.6], [19.9, 23.6], [28.1, 23.6], [36.3, 23.6], [11.7, 29.0], [19.9, 29.0], [28.1, 29.0], [37.3, 16.2]]) makeIsland(H, g, cx, cz, 4, 1.4, 0, chainFor(cz), desks, visits, st);
  for (const x of [9.2, 15.8, 24, 32.2]) plant(g, x, 0, 33.3, 1, 1);
  // reception / security desk at the entrance
  const rx = 43.6; RB(g, 3.4, 1.05, .5, rx, .525, 30.1, M(0xe9e4da, { r: .6 }), .03); RB(g, 3.5, .04, .62, rx, 1.07, 30.12, X.walnut, .01);
  desks.push(P(rx, 0, 28.7, 0, 'sit', [[rx, 27.6], [40.4, 27.6], [40.4, HZ]])); visits.push(P(rx - .9, 0, 28.9, 0, 'stand', [[40.4, 28.9], [40.4, HZ]]));
  st.desk.push(station(g, rx, 0, 28.7, 0, false, 777));
  for (const x of [42.9, 45.1]) RB(g, .16, 1.0, .9, x, .5, 32.6, M(0x3a3d44, { r: .6 }), .02);
  B(g, 43.0, 43.7, .78, .8, 32.55, 32.57, X.glass, nc); B(g, 44.3, 45.0, .78, .8, 32.55, 32.57, X.glass, nc); plant(g, 45.4, 0, 27.4, 1.1, 2);
  // mezzanine: VP offices, lounge, board room, founder
  const gl = (x0, x1, z) => { B(g, x0, x1, MY + .05, MY + 2.6, z - .012, z + .012, X.glass, nc); B(g, x0, x1, MY + 2.6, MY + 2.65, z - .03, z + .03, steel); B(g, x0, x1, MY, MY + .05, z - .03, z + .03, steel); };
  const glZ = (x, z0, z1) => { B(g, x - .012, x + .012, MY + .05, MY + 2.6, z0, z1, X.glass, nc); B(g, x - .03, x + .03, MY + 2.6, MY + 2.65, z0, z1, steel); };
  const up = (...pts) => [...pts, [SX, MY, MZ - .6], [SX, MY, MZ + .3], ...DOWN];
  const vpDesk = [];
  for (let i = 0; i < 4; i++) { const x0 = i * 3.25, x1 = x0 + 3.25, xc = (x0 + x1) / 2, dx = x0 + .7;
    gl(x0 + 1.2, x1, VZ); gl(x0, x0 + .25, VZ); glZ(x1, 0, VZ); glassDoor(grp(g, 0, MY, 0), x0 + 1.2, VZ, PI - .9);
    vpDesk.push([xc, [[x0 + .8, 3.2], [x0 + .8, VZ - .5], [dx, VZ - .5], ...up([dx, MZ - .6])]]);
    if (i === 0) { RB(g, x1 - x0 - .6, .7, .42, xc, MY + .35, .3, X.walnut, .015); plant(g, x1 - .5, MY + .7, .3, .5, 1); }
    if (i === 1) { sofa(g, x0 + .3, x0 + 1.9, .15, .95, MY, X.fabricW); floorP(g, x0 + .3, x1 - .3, .1, 2.1, MY + .012, X.rug2, 1.2); plant(g, x1 - .5, MY, .5, .9, 2); }
    if (i === 2) { bookshelf(g, x0 + .35, x0 + 1.6, MY, .08, .4, 1.0); floorLamp(g, x1 - .5, MY, .5); armchair(g, xc + .9, MY, 4.9, PI, M(0x3f5a6e, { r: .8 })); }
    if (i === 3) { whiteboard(g, x1 - .05, MY, 2.2, -PI / 2); plant(g, x0 + .5, MY, .5, .8, 0); } }
  sofa(g, 14.6, 17.6, .4, 1.3, MY, X.fabricB); sofa(g, 26.4, 29.4, .4, 1.3, MY, X.fabricW); floorP(g, 14.4, 29.6, .3, 5.2, MY + .012, X.rug2, 1.5);
  RB(g, 1.4, .04, .7, 16.1, MY + .4, 2.8, X.walnut, .02); RB(g, 1.4, .04, .7, 27.9, MY + .4, 2.8, X.walnut, .02); plant(g, 14.0, MY, 4.9, 1, 2); plant(g, 29.9, MY, 4.9, 1, 1);
  armchair(g, 16.1, MY, 4.25, PI, X.fabricG); armchair(g, 27.9, MY, 4.25, PI, X.fabricG);
  arcade(g, 19.6, MY, .5, 0, 0x2b2f6b); arcade(g, 20.4, MY, .5, 0, 0x6b2b4a); arcade(g, 21.2, MY, .5, 0, 0x2b5a4a); foosball(g, 23.8, MY, .75, 0);
  poolTable(g, 22.0, MY, 2.4, 0); pingPong(g, 22.0, MY, 4.55, 0); beanBag(g, 18.5, MY, 2.6, 0xc98b5a, -PI / 2); beanBag(g, 25.5, MY, 2.6, 0x6f8a7a, PI / 2);
  for (const [px, pz, pc] of [[14.8, 2.8, 0xc98b5a], [17.4, 2.8, 0x6f8a7a], [26.6, 2.8, 0xd9c3a3], [29.2, 2.8, 0xc98b5a]]) { Cy(g, .26, .4, px, MY + .2, pz, M(pc, { r: 1 })); Cy(g, .27, .04, px, MY + .41, pz, M(pc, { r: 1 }), nc); }
  gl(31.9, 36.8, VZ); gl(30.5, 30.9, VZ); glZ(30.5, 0, VZ); glassDoor(grp(g, 0, MY, 0), 31.9, VZ, PI - .9);
  RB(g, 4.2, .06, 1.2, 33.65, MY + .74, 2.8, X.walnut, .02); for (const x of [32.0, 35.3]) B(g, x - .05, x + .05, MY, MY + .72, 2.45, 3.15, steel); confPhone(g, 33.65, MY + .77, 2.8);
  for (let j = 0; j < 4; j++) { const x = 32.2 + j * .95; rooms.board.push(P(x, MY, 1.8, 0, 'sit', up([x, .9], [31.1, .9], [31.1, 5.1], [31.4, 5.1], [31.4, MZ - .6])), P(x, MY, 3.8, PI, 'sit', up([x, 5.1], [31.4, 5.1], [31.4, MZ - .6]))); }
  Object.values(rooms).forEach(r => r.forEach(s => officeChair(g, s.pos.x, s.pos.y, s.pos.z, s.face, s.pos.y > 1 ? M(0x2a211b, { r: .7 }) : X.fabricW)));
  glZ(36.8, 0, 5.8); B(g, 36.788, 36.812, MY + 2.3, MY + 2.6, 5.8, 6.9, X.glass, nc); glassDoor(grp(g, 0, MY, 0), 36.8, 5.85, -PI / 2 + .9);
  B(g, 36.8, W, MY + .05, MY + 2.6, 6.88, 6.91, X.glass, nc); B(g, 36.8, W, MY + 2.6, MY + 2.65, 6.86, 6.93, steel); B(g, 36.8, W, MY, MY + .05, 6.86, 6.93, steel);
  floorP(g, 37.4, 45.4, .6, 6.4, MY + .014, X.rug, 1.5);
  const fx = 41.4, fs = P(fx, MY, 3.0, 0, 'sit', [[39.7, 3.0], [39.7, 6.35], [36.3, 6.35], ...up([36.3, MZ - .6])]);
  st.founder = station(g, fx, MY, 3.0, 0, true, 99);
  RB(g, 3.4, .75, .42, fx, MY + .375, .32, X.walnut, .02);
  { const T = MY + .75; for (let i = 0; i < 5; i++) B(g, fx - 1.5 + i * .06, fx - 1.45 + i * .06, T, T + .26 + (i % 2) * .04, .18, .46, X.books[i % 4]);
    plant(g, fx - .6, T, .32, .38, 1); unicorn(g, fx + .2, T, .32, 0);
    const fr = grp(g, fx + 1.0, T, .3); fr.rotation.x = -.18; RB(fr, .4, .5, .03, 0, .25, 0, X.walnut, .008); B(fr, -.16, .16, .05, .45, .016, .02, X.paper, nc); B(fr, -.12, -.02, .14, .15, .021, .024, M(0xc0583f), nc); }
  armchair(g, fx - .6, MY, 5.1, PI, M(0x4a2e22, { r: .6 })); armchair(g, fx + .6, MY, 5.1, PI, M(0x4a2e22, { r: .6 }));
  sofaR(g, 45.35, MY, 3.0, -PI / 2, 2.2, M(0x3d2a1f, { r: .6 })); barCart(g, 45.3, MY, 5.4, -PI / 2);
  whiteboard(g, 37.1, MY, 2.6, PI / 2); plant(g, 45.4, MY, .6, 1, 2); floorLamp(g, 37.4, MY, .6);
  const pool = [decal(g, fx, MY + .03, 3.2, 6.4, 6.0, poolMat)];
  for (const x of [4.8, 9.0, 17.4, 25.8, 34.2, 42.6]) sconce(sc, g, x, MY + 2.4, .1);
  vpDesk.forEach(([xc, ch]) => { desks.push(P(xc, MY, 3.2, 0, 'sit', ch)); visits.push(P(xc + .32, MY, 2.38, 0, 'stand', ch)); st.desk.push(station(g, xc, MY, 3.2, 0, false, 500 + desks.length)); });
  // street, quay, Bosphorus
  const nE = o => (o.userData.noEdge = true, o), R = rng(909);
  nE(B(g, -60, W + 3.5, -.3, 0, D + .3, D + 3.5, walkMat, nc)); nE(B(g, W + .3, W + 3.5, -.3, 0, -60, D + 3.5, walkMat, nc));
  nE(B(g, -60, W + 60, -.45, -.14, D + 3.5, D + 10, roadMat, nc)); nE(B(g, W + 3.5, W + 10, -.45, -.14, -60, D + 10, roadMat, nc));
  for (let x = -30; x < W + 40; x += 3) nE(B(g, x, x + 1.4, -.14, -.13, D + 6.65, D + 6.85, lineMat, nc));
  nE(B(g, -60, W + 80, -.3, 0, D + 10, D + 15, walkMat, nc)); B(g, -60, W + 80, -1.2, 0, D + 15, D + 15.35, cap, nc);
  nE(B(g, W + 10, W + 80, -.3, 0, -60, D + 10, walkMat, nc));
  const wtex = canvasTex(256, 256, (x, w, h) => { const gr = x.createLinearGradient(0, 0, w, h); gr.addColorStop(0, '#3e84a6'); gr.addColorStop(1, '#2d6c8c'); x.fillStyle = gr; x.fillRect(0, 0, w, h); const R2 = rng(31);
    for (let i = 0; i < 110; i++) { const px = R2() * w, py = R2() * h, l = 10 + R2() * 30; x.strokeStyle = R2() < .45 ? 'rgba(255,255,255,.55)' : 'rgba(150,205,228,.6)'; x.lineWidth = 2 + R2() * 1.5; x.beginPath(); x.moveTo(px, py); x.quadraticCurveTo(px + l / 2, py - 4, px + l, py); x.stroke(); } });
  wtex.repeat.set(44, 26);
  nE(B(g, -120, W + 160, -1.4, -1.2, D + 15.35, D + 200, M(0xffffff, { map: wtex, r: .7 }), nc)); B(g, -60, W + 80, -1.2, -1.18, D + 15.35, D + 15.75, M(0xeef5f7, { r: 1 }), nc);
  for (const [bx, bz, br] of [[6, D + 27, .3], [31, D + 34, -.5], [58, D + 24, .9]]) { const bt = grp(g, bx, -1.2, bz, br); RB(bt, 4.2, .7, 1.5, 0, .3, 0, M(0xf4f1ea, { r: .7 }), .3); B(bt, -2.1, 2.1, .45, .55, -.76, .76, M(0x2b5a88, { r: .8 }), nc); RB(bt, 1.4, .8, 1.1, -.5, 1.05, 0, M(0xe7e2d6, { r: .7 }), .1); B(bt, -.9, -.1, 1.0, 1.2, -.56, .56, M(0x2c3446, { r: .6 }), nc); }
  for (let x = -12; x < W + 30; x += 7) { tree(g, x, 0, D + 12.4, 1.0); lampPost(g, posts, x + 3.5, 0, D + 14.2); }
  bench(g, 2, 0, D + 11.2, PI); bench(g, 16, 0, D + 11.2, PI); bench(g, 30, 0, D + 11.2, PI);
  for (let x = -6; x < W - 4; x += 6.5) tree(g, x + 1.5, 0, D + 2.3, .95, true);
  for (let z = -4; z < D; z += 6) tree(g, W + 2.2, 0, z, .95, true);
  lampPost(g, posts, 6, 0, D + 3.0); lampPost(g, posts, 24, 0, D + 3.0); lampPost(g, posts, W + 3.0, 0, 12);
  for (const [x, c, t] of [[-8, 0xc0583f], [3, 0x3f6f7a], [12.5, 0xf2c230, 1], [27, 0xe9e4da], [36, 0x34384a]]) car(g, x, -.14, D + 4.4, 0, c, !!t);
  car(g, W + 4.4, -.14, 4, PI / 2, 0x6f9a7a); car(g, W + 8.8, -.14, 16, -PI / 2, 0xf2c230, true);
  const ferry = grp(g, 0, -1.2, D + 40); keep.push(ferry);
  const fw = M(0xf4f1ea, { r: .6 }), fwin = M(0x2c3446, { r: .6, e: 0xffd9a0, ei: 0 });
  RB(ferry, 16, 1.6, 4.2, 0, .8, 0, fw, .5); B(ferry, -8, 8, .9, 1.1, -2.12, 2.12, M(0x2b3a55), nc); RB(ferry, 11, 1.5, 3.6, -.8, 2.35, 0, fw, .2);
  B(ferry, -6.2, 4.6, 2.2, 2.7, -1.82, 1.82, fwin, nc); RB(ferry, 5, .9, 2.6, -1.4, 3.55, 0, fw, .15); Cy(ferry, .45, 1.6, -3, 4.6, 0, M(0x2b2a2a));
  const nb = (x0, x1, z0, z1, h, c, face) => { const m = brickMat(c, (x1 - x0) / 2.4, (h + .3) / 1.5); B(g, x0, x1, -.3, h, z0, z1, m, nc); B(g, x0 - .15, x1 + .15, h, h + .4, z0 - .15, z1 + .15, hazeMat(0xe6dccb), nc);
    const bnd = M(0xe6dccb, { r: .8 }), f0 = face === 'z' ? 0 : 2, gz = grp(g, 0, 0, z1);
    for (let f = f0; f * 3.3 + 2.5 < h; f++) for (let x = x0 + .9; x + 1.4 <= x1 - .6; x += 2.4) if (f > 0 || h < 5) winUnit(gz, x, x + 1.4, f * 3.3 + .9, f * 3.3 + 2.5, low, { on: 450 + R() * 70, off: 1060 + R() * 240, allNight: R() < .1 }, bnd); };
  nb(-16, -.3, -.3, D + .3, 13.2, 0xd7b08c, 'z');
  nE(B(g, -16, W + 3.5, -.3, 0, -6.3, -.3, walkMat, nc)); for (let x = -14; x < W; x += 9) lampPost(g, posts, x, 0, -5.8);
  { const shop = M(0x2c3446, { r: .6 }); B(g, -14.6, -1.6, .2, 2.6, D + .3, D + .34, shop, nc); B(g, -15, -1.2, 2.7, 2.95, D + .3, D + 1.4, M(0x3f6f7a), nc); }
  nb(-16, 4, -22, -6.3, 16.5, 0xc07a5c, 'z'); nb(4, 20, -18, -6.3, 11.6, 0xd2a07a, 'z'); nb(20, W + .3, -24, -6.3, 14.8, 0xb5694f, 'z');
  nb(W + 10, W + 26, -26, D + 2, 9.9, 0xcf9d78, 'z');
  { const tw = hazeMat(0xc2b5a0); Cy(g, 4.2, 34, -30, 17, -50, tw, { cast: false }); Cy(g, 4.6, 1.2, -30, 32, -50, hazeMat(0xe6dccb), { cast: false }); const cone = new THREE.Mesh(CONEG, hazeMat(0x4f5e6b)); cone.scale.set(4.6, 7, 4.6); cone.position.set(-30, 37.5, -50); g.add(cone); }
  const OUT = P(W + 6, 0, D + 2, 0, 'out', [[44.0, D + 1.4], [44.0, SZ], [40.4, SZ], [40.4, HZ]]);
  const roles = [...['dev', 'dev', 'dev', 'pm', 'des', 'sales', 'sales', 'qa'].flatMap(r => Array(8).fill(r)), 'sales', 'dev', 'pm', 'des', 'sales'];
  return {
    g, bounds: new THREE.Box3(V(-4, -.5, -1), V(W + 6, WH, D + 12)), sunOff: V(16, 30, 22), fog: { near: 150, far: 300 }, sky: [], sconces: sc, panes: [], low, posts, fades: [], pool, env: 'cevre', keep,
    maxN: desks.length, spd: 3.6,
    ferry, wtex, // export handles (tools/office3d)
    peopleCfg: N => { const f = a => a.filter(i => i <= N);
      return { roles, eat: 16, cof: 5, wc: 3, booths: 4, allHands: { t: 1020, t1: 1050 }, meetings: [
        { t: 600, t1: 645, r: 'board', ids: [0, ...f([66, 67, 68, 69, 1, 33, 41])], lab: 'Yönetim toplantısı' },
        { t: 660, t1: 705, r: 'r1', ids: f([25, 26, 2, 3, 33, 34]), lab: 'Toplantı · ürün, yazılım, tasarım' },
        { t: 660, t1: 705, r: 'r2', ids: f([27, 28, 10, 11, 35, 36]), lab: 'Toplantı · ürün, yazılım, tasarım' },
        { t: 660, t1: 705, r: 'r3', ids: f([29, 30, 18, 19, 37, 38]), lab: 'Toplantı · ürün, yazılım, tasarım' },
        { t: 870, t1: 915, r: 'r1', ids: f([42, 43, 44, 45, 46, 47]), lab: 'Satış toplantısı' },
        { t: 900, t1: 945, r: 'r2', ids: f([49, 50, 51, 52, 53, 54]), lab: 'Satış · müşteri planı' },
        { t: 960, t1: 1000, r: 'r3', ids: f([57, 58, 59, 4, 12, 20]), lab: 'Test planlama' }] }; },
    spot(p, s) { switch (s.k) { case 'desk': return p.id === 0 ? fs : desks[p.id - 1]; case 'visit': return visits[s.i % visits.length]; case 'meet': { const r = rooms[s.r]; return r[s.i % r.length]; } case 'eat': return eat[s.i % eat.length]; case 'coffee': return cof[s.i % cof.length]; case 'wc': return wcs[s.i % wcs.length]; case 'booth': return booths[s.i % booths.length]; case 'trib': return trib[s.i % trib.length]; case 'present': return PRES; default: return OUT; } },
    elev: null,
    station: p => p.id === 0 ? st.founder : st.desk[p.id - 1], stations: [...st.desk, st.founder], connector: () => [],
    tick(time) { ferry.position.x = -80 + ((time * .45) % 200); wtex.offset.set((time * .0015) % 1, Math.sin(time * .02) * .02); fwin.emissiveIntensity = time > 1110 || time < 450 ? 1.4 : 0; },
  };
}
