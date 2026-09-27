// Perde 1 — kurucunun evi: eski bir apartmanın üst katında küçük daire
let ROOFG = null;
export function hipRoof(H, g, x0, x1, z0, z1, y, h, m) {
  const T = H.THREE;
  if (!ROOFG) { ROOFG = new T.ConeGeometry(Math.SQRT1_2, 1, 4); ROOFG.rotateY(Math.PI / 4); ROOFG.translate(0, .5, 0); }
  const me = new T.Mesh(ROOFG, m); me.scale.set(x1 - x0, h, z1 - z0); me.position.set((x0 + x1) / 2, y, (z0 + z1) / 2); me.castShadow = me.receiveShadow = true; g.add(me); return me;
}

export function buildHome(H) {
  const { THREE, V, PI, M, X, B, RB, Cy, grp, floorP, station, plant, sofaR, armchair, floorLamp, woodChair, bookshelf, coffeeMachine, kitchenRun, sink, fridge, toilet, tree, car, lampPost, winUnit, lowDark, groundMat, walkMat, roadMat, lineMat, poolMat, decal, rng, hazeMats } = H;
  hazeMats.length = 0;
  const g = new THREE.Group(), W = 12, D = 9.6, TH = 2.9, LOW = 1.05, FL = 3.2, GY = -3 * FL, nc = { cast: false };
  const FAC = M(0xd4ad8c, { r: .9 }), BAND = M(0xefe2c8, { r: .8 }), IRON = M(0x1f2126, { r: .6 }), SLAB = M(0x7d746a), CAP = X.cap || M(0x3a3632), DOORW = M(0x6e4a32, { r: .7 }), DARK = M(0x1b1c20, { r: 1 });
  const P = (x, y, z, face, pose, chain, zone = 'flat') => ({ pos: V(x, y, z), face, pose, zone, chain: chain.map(c => c.length === 3 ? V(c[0], c[1], c[2]) : V(c[0], 0, c[1])), floor: 0 });
  const low = [], posts = [], keep = [], nE = o => (o.userData.noEdge = true, o);
  // slab + floors (stair hole at x 9.7–11.8, z .2–3.0)
  for (const [a, b, c, d] of [[-.2, 9.7, -.2, D + .25], [11.8, W + .25, -.2, D + .25], [9.7, 11.8, 3.0, D + .25], [9.7, 11.8, -.2, .2]]) B(g, a, b, -.3, 0, c, d, SLAB, nc);
  floorP(g, 0, 4.0, 0, 3.4, .005, X.tile, 1.2); floorP(g, 4.0, 6.6, 0, 3.4, .006, X.tileB, 1.0); floorP(g, 0, W, 3.4, D, .005, X.oakF, 2.4);
  const terr = M(0xcdc5b8, { r: .8 });
  for (const [a, b, c, d] of [[6.6, 9.7, 0, 3.4], [9.7, 11.8, 3.0, 3.4], [11.8, W, 0, 3.4], [9.7, 11.8, 0, .2]]) floorP(g, a, b, c, d, .006, terr, 1.4);
  // full-height back (z=0) and party wall (x=0) — no windows on the party wall
  const holes = [[1.0, 2.2, 1.0, 2.3], [5.05, 5.65, 1.75, 2.3], [10.2, 11.2, 1.2, 2.5]];
  { let cur = -.2; for (const [a, b, y0, y1] of holes) { B(g, cur, a, 0, TH, -.2, 0, X.wall); B(g, a, b, 0, y0, -.2, 0, X.wall); B(g, a, b, y1, TH, -.2, 0, X.wall); cur = b; } B(g, cur, W + .25, 0, TH, -.2, 0, X.wall); }
  B(g, -.2, 0, 0, TH, 0, D + .25, X.wall);
  B(g, -.26, W + .3, TH, TH + .06, -.26, .02, CAP, nc); B(g, -.26, .02, TH, TH + .06, -.26, D + .3, CAP, nc);
  const backWin = (a, b, y0, y1, glass) => { const f = X.frame, t = .05;
    B(g, a, b, y0, y1, -.12, -.1, glass, nc);
    B(g, a - t, b + t, y0 - t, y0, -.1, -.02, f, nc); B(g, a - t, b + t, y1, y1 + t, -.1, -.02, f, nc); B(g, a - t, a, y0, y1, -.1, -.02, f, nc); B(g, b, b + t, y0, y1, -.1, -.02, f, nc);
    if (b - a > .8) { const m = (a + b) / 2; B(g, m - .02, m + .02, y0, y1, -.1, -.03, f, nc); }
    B(g, a - .08, b + .08, y0 - .06, y0, -.1, .1, X.stone, nc); };
  backWin(1.0, 2.2, 1.0, 2.3, lowDark); backWin(5.05, 5.65, 1.75, 2.3, M(0xdfe6e8, { r: .9 })); backWin(10.2, 11.2, 1.2, 2.5, lowDark);
  // cut interior walls (same height everywhere)
  const wx = (z, x0, x1, gaps = []) => { let cur = x0; for (const [a, b] of [...gaps, [x1, x1]]) { if (a - cur > .01) { B(g, cur, a, 0, LOW, z - .06, z + .06, X.wall); B(g, cur, a, LOW, LOW + .03, z - .06, z + .06, CAP, nc); } cur = b; } };
  const wz = (x, z0, z1, gaps = []) => { let cur = z0; for (const [a, b] of [...gaps, [z1, z1]]) { if (a - cur > .01) { B(g, x - .06, x + .06, 0, LOW, cur, a, X.wall); B(g, x - .06, x + .06, LOW, LOW + .03, cur, a, CAP, nc); } cur = b; } };
  wx(3.4, 4.0, W, [[5.75, 6.45], [7.35, 8.25]]); wz(4.0, 0, 3.4); wz(6.6, 0, 3.4); wz(7.4, 5.3, D - .12); wx(5.3, 7.4, W - .12, [[7.7, 8.6]]);
  // exterior cut walls (front z=D with balcony door, right x=W)
  for (const [a, b] of [[0, 3.4], [4.6, W - .12]]) B(g, a, b, 0, LOW, D - .12, D, X.wall);
  for (const [a, b] of [[-.2, 3.4], [4.6, W + .25]]) B(g, a, b, -.3, LOW, D, D + .25, FAC);
  B(g, -.2, 3.4, LOW, LOW + .05, D - .14, D + .3, BAND, nc); B(g, 4.6, W + .3, LOW, LOW + .05, D - .14, D + .3, BAND, nc);
  B(g, W - .12, W, 0, LOW, 0, D - .12, X.wall); B(g, W, W + .25, -.3, LOW, -.2, D, FAC); B(g, W - .14, W + .3, LOW, LOW + .05, -.2, D, BAND, nc);
  B(g, 3.4, 4.6, 0, .02, D - .12, D + .25, X.stone, nc);
  for (const [hx, s] of [[3.4, 1], [4.6, -1]]) { const lf = grp(g, hx, 0, D - .1, s * -1.25); B(lf, 0, s * .6, 0, LOW, -.025, .025, X.frame); B(lf, s * .08, s * .52, .35, LOW, -.012, .012, lowDark, nc); }
  // KITCHEN corner (open to salon)
  kitchenRun(g, .15, 3.0, 0, .1, false); fridge(g, 3.05, 3.8, 0, .1, .8);
  B(g, 2.3, 3.0, 1.55, 2.3, .1, .45, X.cabinet); B(g, 2.32, 2.98, 1.58, 2.27, .45, .47, X.cabinet, nc); B(g, 2.36, 2.39, 1.7, 1.95, .47, .5, X.chrome, nc);
  B(g, .15, .95, 1.62, 1.65, .1, .38, X.walnut); for (let i = 0; i < 4; i++) Cy(g, .05, .14 + (i % 2) * .04, .28 + i * .19, 1.72 + (i % 2) * .02, .24, [X.ceramic, M(0xc98b5a), X.ceramic, M(0x6f8a7a)][i], nc);
  B(g, .28, .92, .86, .88, .16, .62, X.black, nc); for (const bx of [.44, .76]) Cy(g, .09, .01, bx, .885, .38, M(0x2e3036), nc);
  { const steel = M(0xc9ccd1, { r: .45, m: .3 }), por = M(0xf4f1ea, { r: .6 }), red = M(0xb03a2e, { r: .7 });
    Cy(g, .12, .15, .44, .965, .38, steel); Cy(g, .06, .02, .44, 1.05, .38, steel, nc);
    Cy(g, .075, .11, .44, 1.115, .38, por); Cy(g, .03, .02, .44, 1.18, .38, red, nc); RB(g, .12, .025, .025, .56, 1.12, .38, por, .01, { rz: .5, cast: false });
    RB(g, .03, .1, .025, .3, 1.0, .38, IRON, .01, { cast: false }); }
  sink(g, 1.6, 0, .4); coffeeMachine(g, 2.55, .86, .35);
  Cy(g, .45, .04, 2.4, .74, 2.3, X.walnut); Cy(g, .05, .7, 2.4, .37, 2.3, X.metal); Cy(g, .24, .03, 2.4, .015, 2.3, X.metal);
  woodChair(g, 2.4, 0, 1.62, 0); woodChair(g, 2.4, 0, 2.98, PI);
  Cy(g, .1, .015, 2.25, .77, 2.2, X.ceramic, nc); Cy(g, .04, .09, 2.62, .805, 2.35, M(0xc98b5a), nc);
  // BATHROOM (opaque cut walls)
  toilet(g, 4.55, 0, .45);
  RB(g, .7, .8, .45, 5.35, .4, .28, X.cabinet, .02); RB(g, .74, .04, .5, 5.35, .82, .28, X.stone, .01); B(g, 5.12, 5.58, .8, .86, .12, .42, X.ceramic, nc);
  B(g, 5.05, 5.65, 1.1, 1.65, .01, .03, M(0xcfd8dc, { r: .2 }), nc);
  B(g, 5.8, 6.52, 0, .06, .05, .95, X.ceramic); B(g, 5.78, 5.8, .35, 2.0, .06, .95, M(0xe6ecee, { r: .9 })); B(g, 5.78, 6.54, 2.0, 2.02, .9, .92, X.chrome, nc);
  RB(g, .58, .82, .56, 6.24, .41, 2.0, M(0xf4f3ef, { r: .6 }), .03); Cy(g, .17, .03, 5.94, .5, 2.0, M(0x2e3036), { rz: PI / 2, cast: false });
  floorP(g, 4.95, 5.75, .6, 1.1, .012, M(0x9ec3c9, { r: 1 }), 1);
  // LANDING: old lift + stair down (outside the flat)
  var ELEV = { o: 0, panels: [], near: q => Math.abs(q.x - 7.8) < 1.2 && Math.abs(q.z - 3.4) < 1.3 };
  plant(g, 7.1, 0, .45, .8, 1); B(g, 8.4, 8.9, 1.3, 1.9, 0, .12, M(0x9aa0a6, { r: .6 }));
  for (let k = 0; k < 10; k++) { const top = -(k + 1) * .18, z1 = 3.0 - k * .28; B(g, 9.7, 11.8, -3.3, top, z1 - .28, z1, k % 2 ? X.stone : terr); }
  B(g, 9.6, 9.7, -3.3, 0, .2, 3.0, DARK, nc); B(g, 11.8, 11.9, -3.3, 0, .2, 3.0, DARK, nc); B(g, 9.6, 11.9, -3.3, 0, -.2, .2, DARK, nc);
  B(g, 9.62, 9.72, .95, 1.0, .2, 3.08, X.walnut);
  for (let z = .3; z < 3.0; z += .16) B(g, 9.655, 9.685, 0, .95, z - .012, z + .012, IRON, nc);
  floorP(g, 7.45, 8.15, 2.95, 3.3, .012, M(0x6b4e3a, { r: 1 }), 1);
  { const lf = grp(g, 8.25, 0, 3.4, 0); B(lf, -.9, 0, 0, LOW, -.03, .03, DOORW); for (const zz of [.06, -.06]) Cy(lf, .03, .05, -.8, .95, zz, M(0xc9a24a, { r: .3, m: .6 }), { rx: PI / 2, cast: false }); keep.push(lf); ELEV.panels.push({ m: lf, rot: true, p0: 0, d: 1.35 }); }
  // ANTRE
  B(g, 9.0, 10.3, 0, .9, 3.48, 3.85, X.walnut); B(g, 9.02, 10.28, .9, .93, 3.48, 3.87, X.stone, nc);
  Cy(g, .025, 1.75, 11.5, .875, 3.85, X.metal); Cy(g, .18, .02, 11.5, .01, 3.85, X.metal); RB(g, .3, .7, .12, 11.5, 1.35, 3.95, M(0x6f5a4a, { r: .9 }), .04);
  floorP(g, 8.7, 11.3, 4.0, 4.8, .012, X.rug2, 1);
  // BEDROOM
  B(g, 7.5, 9.7, 0, .32, 6.3, 7.9, X.walnut); B(g, 7.44, 7.58, 0, 1.0, 6.25, 7.95, X.walnut);
  RB(g, 2.1, .24, 1.52, 8.62, .44, 7.1, M(0xf2efe9, { r: .9 }), .06);
  RB(g, 1.4, .08, 1.58, 9.0, .6, 7.1, M(0x7a93b3, { r: .95 }), .04); RB(g, .42, .12, .58, 7.84, .62, 6.72, M(0xf7f5f0, { r: .9 }), .05); RB(g, .42, .12, .58, 7.84, .62, 7.48, M(0xf7f5f0, { r: .9 }), .05);
  for (const z of [5.75, 8.0]) { B(g, 7.5, 7.95, 0, .5, z, z + .45, X.walnut); Cy(g, .05, .02, 7.72, .51, z + .22, X.metal, nc); Cy(g, .012, .3, 7.72, .66, z + .22, X.metal, nc); Cy(g, .1, .14, 7.72, .85, z + .22, M(0xf1e6d0, { r: .8 }), { geo: H.CONEG, cast: false }); }
  RB(g, 1.25, 2.1, .6, 11.22, 1.05, 5.72, M(0xe9e4da, { r: .7 }), .02); B(g, 11.215, 11.225, .05, 2.05, 6.02, 6.03, M(0x9a948a), nc); for (const x of [11.13, 11.31]) B(g, x - .01, x + .01, .95, 1.2, 6.02, 6.05, X.chrome, nc);
  floorP(g, 9.9, 11.3, 6.5, 8.6, .012, X.rug2, 1.2);
  // SALON + work corner
  const st = station(g, 1.2, 0, 8.3, 0, false, 11);
  floorP(g, .35, 2.25, 7.55, 9.42, .012, X.rug, 1.2);
  { const notes = [0xf2d25c, 0xef8fa0, 0x8cc6e8, 0xa8d88a, 0xf2d25c, 0xf2d25c, 0xef8fa0, 0x8cc6e8, 0xf2d25c, 0xa8d88a, 0xf2d25c, 0xef8fa0].map(c => M(c, { r: .9 })), R = rng(5);
    notes.forEach((m, i) => { const z = 8.05 + (i % 4) * .28 + (R() - .5) * .05, y = 1.28 + Math.floor(i / 4) * .21 + (R() - .5) * .04; B(g, .005, .014, y, y + .085, z, z + .085, m, nc); }); }
  { const wb = M(0xf7f7f4, { r: .5 }), ink = M(0x2f5f8a, { r: .8 }), inkR = M(0xc0392b, { r: .8 });
    B(g, .005, .05, 1.12, 1.98, 6.32, 7.58, M(0xb9bdc2, { r: .5 })); B(g, .05, .06, 1.15, 1.95, 6.35, 7.55, wb, nc);
    for (const [y, z0, z1, m] of [[1.82, 6.5, 7.1, ink], [1.74, 6.5, 6.9, ink], [1.5, 6.5, 6.75, ink], [1.5, 6.95, 7.2, ink], [1.3, 6.5, 7.4, inkR]]) B(g, .06, .064, y, y + .014, z0, z1, m, nc);
    B(g, .06, .064, 1.36, 1.6, 6.5, 6.514, ink, nc); B(g, .06, .064, 1.36, 1.6, 6.736, 6.75, ink, nc); B(g, .06, .064, 1.36, 1.6, 6.95, 6.964, ink, nc); B(g, .06, .064, 1.36, 1.6, 7.186, 7.2, ink, nc);
    B(g, .005, .12, 1.09, 1.12, 6.5, 7.4, X.metal, nc); }
  bookshelf(grp(g, .05, 0, 5.65, PI / 2), 0, 1.8, 0, 0, .34, 2.0);
  sofaR(g, 6.92, 0, 7.4, -PI / 2, 2.3, X.fabricB);
  RB(g, .7, .04, 1.2, 5.55, .42, 7.4, X.walnut, .02); for (const [a, b] of [[5.28, 6.88], [5.82, 6.88], [5.28, 7.92], [5.82, 7.92]]) B(g, a - .02, a + .02, 0, .4, b - .02, b + .02, X.walnut);
  Cy(g, .045, .09, 5.45, .485, 7.1, X.ceramic, nc); RB(g, .22, .03, .3, 5.65, .455, 7.65, M(0x3f5a6e), .005, { ry: .3, cast: false });
  floorP(g, 4.7, 7.2, 6.0, 8.8, .011, X.rug2, 1.5);
  armchair(g, 3.2, 0, 7.3, PI / 2, X.fabricW); floorLamp(g, 6.95, 0, 5.95);
  plant(g, 2.75, 0, 9.25, .7, 1); plant(g, 6.9, 0, 9.05, .9, 0);
  const pool = [decal(g, 1.2, .02, 8.55, 3.2, 3.0, poolMat)];
  // BALCONIES + FACADE below (street side + side street)
  const rail = y => { B(g, 2.6, 5.4, y + .95, y + 1.0, D + 1.3, D + 1.36, IRON); B(g, 2.6, 5.4, y + .06, y + .1, D + 1.3, D + 1.36, IRON, nc);
    for (const x of [2.63, 5.37]) B(g, x - .03, x + .03, y + .95, y + 1.0, D + .25, D + 1.36, IRON);
    for (let x = 2.72; x < 5.3; x += .14) B(g, x - .011, x + .011, y + .1, y + .95, D + 1.31, D + 1.35, IRON, nc);
    for (const x of [2.63, 5.37]) for (let z = D + .38; z < D + 1.3; z += .14) B(g, x - .011, x + .011, y + .1, y + .95, z - .011, z + .011, IRON, nc); };
  B(g, 2.6, 5.4, -.18, 0, D + .25, D + 1.35, BAND); floorP(g, 2.6, 5.4, D + .25, D + 1.35, .004, X.tile, 1); rail(0);
  woodChair(g, 4.95, 0, D + .8, -PI / 2); Cy(g, .2, .025, 4.35, .7, D + .8, X.metal); Cy(g, .015, .7, 4.35, .35, D + .8, X.metal);
  plant(g, 2.85, 0, D + 1.1, .55, 1); plant(g, 3.15, 0, D + 1.1, .5, 0);
  B(g, -.2, W + .25, GY, -.3, D, D + .25, FAC); B(g, W, W + .25, GY, -.3, -.2, D + .25, FAC);
  const R = rng(4242), sch = () => ({ on: 1040 + R() * 120, off: 1290 + R() * 140, allNight: R() < .06 });
  const gf = grp(g, 0, 0, D + .25), gr = grp(g, W + .25, 0, 0, PI / 2);
  for (let f = 0; f < 3; f++) { const y = GY + f * FL;
    if (f > 0) { for (const [a, b] of [[.8, 2.0], [6.3, 7.5], [8.5, 9.7], [10.5, 11.5]]) winUnit(gf, a, b, y + .85, y + 2.55, low, sch(), BAND);
      winUnit(gf, 3.4, 4.6, y + .2, y + 2.6, low, sch(), BAND); B(g, 2.6, 5.4, y - .18, y, D + .25, D + 1.35, BAND); rail(y); if (f !== 2) plant(g, 5.0, y, D + 1.0, .5, 1); }
    for (const [a, b] of [[.8, 2.0], [3.6, 4.8], [6.0, 7.2], [8.0, 9.2]]) winUnit(gr, -b, -a, y + .85, y + 2.55, low, sch(), BAND);
    const yb = f === 0 ? y + FL : y + FL; B(g, -.2, W + .3, yb - .46, yb - .3, D + .25, D + .3, BAND, nc); B(g, W + .25, W + .3, yb - .46, yb - .3, -.2, D + .3, BAND, nc); }
  B(g, -.35, W + .45, GY + FL - .6, GY + FL - .3, D + .25, D + .45, BAND); B(g, W + .25, W + .45, GY + FL - .6, GY + FL - .3, -.2, D + .45, BAND);
  { const y = GY, shop = M(0x2c3446, { r: .6 }), awn = M(0x3f6f7a, { r: .8 });
    B(g, 6.0, 11.4, y + .35, y + 2.5, D + .25, D + .3, shop, nc); for (const x of [6.0, 7.8, 9.6, 11.4]) B(g, x - .04, x + .04, y + .3, y + 2.55, D + .25, D + .33, IRON, nc); B(g, 5.96, 11.44, y + .3, y + .38, D + .25, D + .34, IRON, nc);
    RB(g, 5.8, .06, 1.1, 8.7, y + 2.85, D + .8, awn, .02, { rx: .38 });
    B(g, .9, 2.1, y + .12, y + 2.35, D + .25, D + .32, DOORW); B(g, .9, 2.1, y + 2.45, y + 2.85, D + .25, D + .31, lowDark, nc); B(g, .82, 2.18, y + 2.35, y + 2.45, D + .25, D + .34, BAND, nc);
    B(g, .7, 2.3, y, y + .12, D + .25, D + .75, X.stone); winUnit(gf, 3.4, 4.6, y + .85, y + 2.55, low, sch(), BAND); }
  // street + neighbours
  nE(floorP(g, -70, W + 70, -70, D + 70, GY, groundMat, 4));
  nE(B(g, -40, W + 3.0, GY, GY + .12, D + .25, D + 3.0, walkMat, nc)); nE(B(g, W + .25, W + 3.0, GY, GY + .12, -40, D + 3.0, walkMat, nc));
  nE(B(g, -40, W + 40, GY, GY + .04, D + 3.0, D + 9.0, roadMat, nc)); nE(B(g, W + 3.0, W + 9.0, GY, GY + .04, -40, D + 3.0, roadMat, nc));
  for (let x = -24; x < W + 30; x += 3) nE(B(g, x, x + 1.4, GY + .04, GY + .05, D + 5.9, D + 6.1, lineMat, nc));
  for (let z = -24; z < D + 3; z += 3) nE(B(g, W + 5.9, W + 6.1, GY + .04, GY + .05, z, z + 1.4, lineMat, nc));
  nE(B(g, -40, W + 40, GY, GY + .12, D + 9.0, D + 11.5, walkMat, nc)); nE(B(g, W + 9.0, W + 11.5, GY, GY + .12, -40, D + 9.0, walkMat, nc));
  const roofM = [M(0xb5553a, { r: .9 }), M(0xa24b36, { r: .9 }), M(0xc0674a, { r: .9 })];
  const bld = (x0, x1, z0, z1, floors, col, faces, roof = 1, minF = 0) => { const m = M(col, { r: .9 }), top = GY + floors * FL, Rb = rng(Math.floor(x0 * 13 + z0 * 7 + 991));
    B(g, x0, x1, GY, top, z0, z1, m); B(g, x0 - .15, x1 + .15, top - .22, top, z0 - .15, z1 + .15, BAND, nc);
    if (roof) { hipRoof(H, g, x0 - .3, x1 + .3, z0 - .3, z1 + .3, top, 1.8, roofM[Math.floor(Rb() * 3)]); B(g, x0 + (x1 - x0) * .7, x0 + (x1 - x0) * .7 + .6, top, top + 2.5, (z0 + z1) / 2, (z0 + z1) / 2 + .6, m); }
    else { B(g, x0, x1, top, top + .5, z0, z0 + .2, BAND, nc); B(g, x0, x1, top, top + .5, z1 - .2, z1, BAND, nc); B(g, x1 - .2, x1, top, top + .5, z0, z1, BAND, nc); RB(g, 1.4, 1.2, 1.4, x0 + 2, top + .6, z0 + 2, M(0x9aa0a6), .1); }
    const sc = () => ({ on: 1040 + Rb() * 120, off: 1290 + Rb() * 140, allNight: Rb() < .06 });
    if (faces.includes('z')) { const gz = grp(g, 0, 0, z1); for (let f = minF; f < floors; f++) for (let x = x0 + .9; x + 1.2 <= x1 - .6; x += 2.3) winUnit(gz, x, x + 1.2, GY + f * FL + .85, GY + f * FL + 2.5, low, sc(), BAND); }
    if (faces.includes('x')) { const gx = grp(g, x1, 0, 0, PI / 2); for (let f = minF; f < floors; f++) for (let z = z0 + .9; z + 1.2 <= z1 - .6; z += 2.3) winUnit(gx, -(z + 1.2), -z, GY + f * FL + .85, GY + f * FL + 2.5, low, sc(), BAND); } };
  bld(-12, -.2, -.2, D + .25, 4, 0xc9b49a, 'z');
  bld(-24, -12, -.2, D + .25, 4, 0xb8c0b0, 'z');
  for (const [x0, x1, c] of [[-14, -2, 0xd9c3a3], [-2, 5, 0xc7a58a], [5, W + .25, 0xd6c7ae]]) bld(x0, x1, -16, -4.5, 4, c, x1 > W ? 'zx' : 'z', 1, 0);
  const AWN = [M(0x3f6f7a, { r: .8 }), M(0xc0583f, { r: .8 }), M(0xd9a441, { r: .8 }), M(0x6f8a7a, { r: .8 })];
  const shop = (x0, x1, z0, z1, c, side, i) => { const m = M(c, { r: .9 }), top = GY + 3.4;
    B(g, x0, x1, GY, top, z0, z1, m); B(g, x0 - .12, x1 + .12, top - .2, top, z0 - .12, z1 + .12, BAND, nc);
    for (const [a, b, cc, d] of [[x0, x1, z0, z0 + .2], [x0, x1, z1 - .2, z1], [x0, x0 + .2, z0, z1], [x1 - .2, x1, z0, z1]]) B(g, a, b, top, top + .45, cc, d, BAND, nc);
    RB(g, 1.2, 1.0, 1.2, x0 + (x1 - x0) * .3, top + .5, (z0 + z1) / 2, M(0x9aa0a6), .08); plant(g, x1 - 1.2, top, z1 - 1.2, .9, 1);
    if (side === 'z0') RB(g, x1 - x0 - .8, .06, 1.2, (x0 + x1) / 2, top - .7, z0 - .55, AWN[i % 4], .02, { rx: -.38 });
    else RB(g, 1.2, .06, z1 - z0 - .8, x0 - .55, top - .7, (z0 + z1) / 2, AWN[i % 4], .02, { rz: .38 }); };
  [[-16, -4, 0xd9a896], [-4, 6, 0xb9c4a0], [6, W + 9.2, 0xd8b77a]].forEach(([x0, x1, c], i) => shop(x0, x1, D + 11.5, D + 17, c, 'z0', i));
  [[-22, -8, 0xcdbfa9], [-8, 4, 0xd9a896], [4, D + 9.2, 0xb8a58e]].forEach(([z0, z1, c], i) => shop(W + 11.5, W + 17, z0, z1, c, 'x0', i + 1));
  tree(g, W + 14.5, GY + .12, D + 14.5, 1.1); tree(g, W + 19, GY + .12, D + 19, 1); tree(g, 2, GY + .12, D + 21, 1.1); tree(g, W + 21, GY + .12, 0, 1);
  tree(g, -3, GY + .12, D + 2.0, .9, true); tree(g, 8.5, GY + .12, D + 2.0, .9, true); tree(g, W + 2.0, GY + .12, 3, .9, true);
  lampPost(g, posts, 2, GY + .12, D + 2.6); lampPost(g, posts, W + 2.6, GY + .12, -3); lampPost(g, posts, -14, GY + .12, D + 2.6);
  car(g, -6, GY + .04, D + 4.2, 0, 0xc0583f); car(g, 3.5, GY + .04, D + 4.2, 0, 0x6f9a7a); car(g, W + 4.2, GY + .04, -6, PI / 2, 0xf2c230, true);
  // spots (founder only)
  const HUB = [5.0, 4.4];
  const DESK = P(1.2, 0, 8.3, 0, 'sit', [[1.2, 7.5], [2.6, 6.2], [4.2, 4.7], HUB]);
  const BAL = P(4.0, 0, D + .95, 0, 'stand', [[4.0, D - .5], [4.0, 5.2], HUB]);
  const KET = P(.62, 0, 1.15, PI, 'stand', [[.62, 3.7], HUB]);
  const EAT = P(2.4, 0, 2.95, PI, 'sit', [[2.4, 3.8], HUB]);
  const WC = P(4.55, 0, 1.05, 0, 'stand', [[5.4, 2.4], [6.1, 3.0], [6.1, 3.9], HUB]);
  const STAIR = P(10.75, -1.8, .36, PI, 'out', [[10.75, -.18, 2.86], [10.75, 0, 3.2], [7.8, 0, 3.2], [7.8, 0, 3.9], [5.0, 0, 4.4]]);
  const SY = GY + .12, DOOR = P(1.5, SY, D + 1.25, 0, 'stand', [[1.5, SY, D + 1.7]], 'street'), ENTER = P(1.5, SY, D + .45, PI, 'out', [[1.5, SY, D + 1.7]], 'street'), OUT = P(-30, SY, D + 1.7, -PI / 2, 'out', [[-29.5, SY, D + 1.7]], 'street');
  const BED = P(9.3, .7, 7.1, PI / 2, 'lie', [[10.2, 0, 7.1], [10.2, 0, 5.9], [8.15, 0, 5.9], [8.15, 0, 4.4], [5.0, 0, 4.4]]);
  const EV = [[-1, 'bed', 'sleep', 'Uyku'], [455, 'wc', 'wc', 'Banyo · sabah'], [468, 'ket', 'coffee', 'Çay demliyor'], [480, 'desk', 'plan', 'Masada · günün planı'], [545, 'desk', 'code', 'Masada · prototip'],
    [630, 'bal', 'coffee', 'Balkonda kahve'], [645, 'desk', 'research', 'Masada · kullanıcı notları'], [705, 'stairs', 'out', 'Merdivenden iniyor'], [709, 'door', 'out', 'Binadan çıkıyor'], [709.5, 'out', 'out', 'Yatırımcı toplantısı · dışarıda'], [778, 'door', 'out', 'Eve dönüyor'], [788, 'enter', 'out', 'Binaya giriyor'], [789, 'stairs', 'out', 'Merdivenden çıkıyor'], [790, 'eat', 'food', 'Öğle yemeği · mutfak'],
    [815, 'desk', 'code', 'Masada · prototip'], [905, 'wc', 'wc', 'Banyo'], [912, 'desk', 'code', 'Masada · prototip'], [990, 'bal', 'coffee', 'Balkonda mola'], [1005, 'desk', 'research', 'Masada · pazar araştırması'],
    [1080, 'stairs', 'out', 'Merdivenden iniyor'], [1084, 'door', 'out', 'Binadan çıkıyor'], [1084.5, 'out', 'out', 'Kurucu buluşması · dışarıda'], [1158, 'door', 'out', 'Eve dönüyor'], [1168, 'enter', 'out', 'Binaya giriyor'], [1169, 'stairs', 'out', 'Merdivenden çıkıyor'], [1170, 'eat', 'food', 'Akşam yemeği · mutfak'], [1195, 'desk', 'code', 'Masada · gece mesaisi'], [1290, 'ket', 'coffee', 'Gece çayı'],
    [1300, 'desk', 'code', 'Masada · gece mesaisi'], [1395, 'wc', 'wc', 'Banyo'], [1405, 'bed', 'sleep', 'Uyku']];
  const byK = { desk: DESK, bal: BAL, ket: KET, eat: EAT, wc: WC, out: OUT, bed: BED, stairs: STAIR, door: DOOR, enter: ENTER };
  return {
    g, bounds: new THREE.Box3(V(-1, -.5, -1), V(W + 2.5, TH, D + 2.2)).expandByPoint(V(1.5, GY, D + 2.0)).expandByPoint(V(-6, GY, D + 2.0)), sunOff: V(16, 30, 22), fog: { near: 150, far: 300 }, sky: [], sconces: [], panes: [], low, posts, fades: [], pool, env: 'cevre', keep,
    maxN: 1, spd: 3.2, elev: ELEV,
    people: () => [{ id: 0, role: 'founder', name: 'Deniz Kaya', lane: 0, events: EV.map(([t, k, a, full]) => ({ t, s: { k }, a, full })) }],
    peopleCfg: () => ({ roles: [], meetings: [], eat: 0, cof: 0, wc: 0, booths: 0 }),
    spot: (p, s) => byK[s.k] || DESK,
    station: () => st, stations: [st], connector: () => [],
  };
}
