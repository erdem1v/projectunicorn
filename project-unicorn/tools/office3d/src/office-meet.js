// Meridian kulesi — en üst kat, cam yatırımcı toplantı odası (şehrin içinde)
import { buildCity } from './office-city-v2.js';

export const INV_LOOKS = {
  20: { name: 'Ekin Aksoy', skin: 0xe2b995, hair: 0x7c7a78, hs: 'part', beard: 2, style: 3, sleeve: 2, top: 0x2d3a52, inner: 0xf1eee8, bot: 0x2a2d33, legs: 0x2a2d33, shoe: 0x1b1c1f, h: 1.03, wd: 1.05 },
  21: { name: 'Barış Uçar', skin: 0xd4a37f, hair: 0x2b2522, hs: 'crop', glasses: 1, style: 1, sleeve: 2, top: 0xdfe7ef, tie: 0x6b2b3a, bot: 0x3a3f47, legs: 0x3a3f47, shoe: 0x5a3a24, sole: 0x3a2618, h: 1.0, wd: 1.0 },
  22: { name: 'Leyla Durmaz', skin: 0xf0d2b6, hair: 0x1c1c1c, hs: 'bob', style: 4, sleeve: 2, top: 0x8a4b3a, bot: 0x2a2a2e, legs: 0x2a2a2e, shoe: 0x2a2a2e, h: .96, wd: .93 },
};

export const ANCHOR_LOOKS = {
  20: { name: 'Selim Karaca', skin: 0xd9b28f, hair: 0x3a3a3a, hs: 'buzz', beard: 2, style: 3, sleeve: 2, top: 0x1f2329, inner: 0xe9e6df, bot: 0x1f2329, legs: 0x1f2329, shoe: 0x111214, h: 1.04, wd: 1.06 },
  21: { name: 'Defne Yalın', skin: 0xe8c3a0, hair: 0x2b2522, hs: 'pony', style: 3, sleeve: 2, top: 0x2a2d33, inner: 0xf1eee8, bot: 0x2a2d33, legs: 0x2a2d33, shoe: 0x17181b, h: .97, wd: .93 },
  22: { name: 'Murat Tunç', skin: 0xc79b78, hair: 0x9a9a9a, hs: 'quiff', glasses: 1, style: 8, sleeve: 2, top: 0x4a4f57, inner: 0xeef1f4, bot: 0x3a3f47, legs: 0x3a3f47, shoe: 0x1b1c1f, h: 1.02, wd: 1.04 },
};
export function buildMeet(H, o = {}) {
  const LK = o.fund === 'anchor' ? ANCHOR_LOOKS : INV_LOOKS;
  const { THREE, V, PI, M, X, B, RB, Cy, grp, floorP, plant, armchair, officeChair, floorLamp, credenza, artFrame, decal, poolMat, CONEG } = H;
  const city = buildCity(H, { meetRoom: true }), MER = city.meridian;
  const g = new THREE.Group(); city.g.position.set(-MER.x0, -MER.top, -MER.z0); g.add(city.g);
  const W = MER.x1 - MER.x0, D = MER.z1 - MER.z0, TH = 3.3, nc = { cast: false }, keep = [...city.keep];
  const mull = M(0x2a2f36, { r: .4, m: .3 }), stone = M(0xd8d2c6, { r: .7 }), wal = X.walnut, alu = M(0xc9ccd1, { r: .5 }), brass = M(0xb89456, { r: .4, m: .4 });
  const P = (x, z, face, pose, chain) => ({ pos: V(x, 0, z), face, pose, chain: chain.map(c => V(c[0], 0, c[1])), floor: 0 });
  // slab + floor
  B(g, -.3, W + .3, -.35, 0, -.3, D + .3, stone); floorP(g, .01, W - .01, .01, D - .01, .004, X.oakF, 2.4);
  const TX = 7.0, TZ = 6.2, TL = 4.4, TW = 1.3, TY = .76;
  floorP(g, TX - 3.1, TX + 3.1, TZ - 2.5, TZ + 2.5, .012, X.rug2, 1.6);
  // back curtain walls (city behind), front walls cut low
  const cwX = (x, z0, z1) => { B(g, x - .015, x + .015, .1, TH - .12, z0, z1, X.glass, nc); B(g, x - .06, x + .06, TH - .12, TH, z0, z1, mull, nc); B(g, x - .06, x + .06, 0, .1, z0, z1, mull, nc); for (let z = z0; z <= z1 + .01; z += (z1 - z0) / Math.round((z1 - z0) / 1.5)) B(g, x - .05, x + .05, 0, TH, z - .04, z + .04, mull, nc); };
  const cwZ = (z, x0, x1) => { B(g, x0, x1, .1, TH - .12, z - .015, z + .015, X.glass, nc); B(g, x0, x1, TH - .12, TH, z - .06, z + .06, mull, nc); B(g, x0, x1, 0, .1, z - .06, z + .06, mull, nc); for (let x = x0; x <= x1 + .01; x += (x1 - x0) / Math.round((x1 - x0) / 1.5)) B(g, x - .04, x + .04, 0, TH, z - .05, z + .05, mull, nc); };
  cwX(0, 3.2, D); cwZ(0, 3.2, W);
  const lowX = (x, z0, z1) => { B(g, x - .015, x + .015, .1, 1.0, z0, z1, X.glass, nc); B(g, x - .05, x + .05, 1.0, 1.06, z0, z1, mull); B(g, x - .06, x + .06, 0, .1, z0, z1, mull, nc); for (let z = z0; z <= z1 + .01; z += 1.5) B(g, x - .035, x + .035, 0, 1.0, z - .03, z + .03, mull, nc); };
  const lowZ = (z, x0, x1) => { B(g, x0, x1, .1, 1.0, z - .015, z + .015, X.glass, nc); B(g, x0, x1, 1.0, 1.06, z - .05, z + .05, mull); B(g, x0, x1, 0, .1, z - .06, z + .06, mull, nc); for (let x = x0; x <= x1 + .01; x += 1.5) B(g, x - .03, x + .03, 0, 1.0, z - .035, z + .035, mull, nc); };
  lowX(W, 0, D); lowZ(D, 0, W);
  // core with lift (far corner)
  const coreM = M(0x5a4636, { r: .75 });
  B(g, 0, 3.2, 0, TH, 0, 3.2, coreM); B(g, -.02, 3.22, TH, TH + .06, -.02, 3.22, mull, nc);
  B(g, .8, 2.2, 0, 2.45, 3.2, 3.23, M(0x121316, { r: 1 }), nc); B(g, .74, 2.26, 2.45, 2.55, 3.2, 3.26, brass, nc); B(g, .74, .8, 0, 2.45, 3.2, 3.26, brass, nc); B(g, 2.2, 2.26, 0, 2.45, 3.2, 3.26, brass, nc);
  const dl = grp(g, 1.15, 0, 3.235), dr = grp(g, 1.85, 0, 3.235); for (const d of [dl, dr]) B(d, -.35, .35, 0, 2.45, -.012, .012, brass); keep.push(dl, dr);
  const elev = { o: 0, panels: [{ m: dl, ax: 'x', p0: 1.15, d: -.68 }, { m: dr, ax: 'x', p0: 1.85, d: .68 }], near: q => Math.abs(q.x - 1.5) < 1.1 && q.z > 2.4 && q.z < 5.4 };
  artFrame(g, 3.23, 1.65, 1.6, PI / 2, 1.5, 1.0, 0x9a6a3a);
  plant(g, 3.75, 0, .55, 1.1, 2);
  // credenza against the back glass
  credenza(g, 4.9, 9.3, 0, .14, .6); plant(g, 5.3, .7, .37, .45, 1); Cy(g, .09, .32, 8.6, .86, .37, M(0x2f5f6e, { r: .4 })); for (let i = 0; i < 4; i++) B(g, 6.6 + i * .07, 6.65 + i * .07, .7, .96 + (i % 2) * .04, .22, .5, X.books[i % 4]);
  // table
  RB(g, TL, .06, TW, TX, TY - .03, TZ, wal, .03);
  for (const x of [TX - 1.4, TX + 1.4]) { B(g, x - .1, x + .1, 0, TY - .06, TZ - .42, TZ + .42, mull); B(g, x - .06, x + .06, 0, .03, TZ - .5, TZ + .5, mull); }
  const zF = TZ - TW / 2 - .5, zN = TZ + TW / 2 + .5;
  const SEAT = { 22: P(TX - 1.4, zF, 0, 'sit', [[TX - 1.4, 3.95]]), 20: P(TX, zF, 0, 'sit', [[TX, 3.95]]), 21: P(TX + 1.4, zF, 0, 'sit', [[TX + 1.4, 3.95]]), 0: P(TX, zN, PI, 'sit', [[TX, 8.4], [4.2, 8.4]]) };
  const OUTM = P(1.5, 2.9, 0, 'out', [[1.5, 4.1]]);
  for (const k in SEAT) { const s = SEAT[k]; officeChair(g, s.pos.x, 0, s.pos.z, s.face, M(0x2a211b, { r: .6 })); }
  officeChair(g, TX - 1.4, 0, zN, PI, M(0x2a211b, { r: .6 })); officeChair(g, TX + 1.4, 0, zN, PI, M(0x2a211b, { r: .6 }));
  // table props
  Cy(g, .065, .24, TX, TY + .12, TZ, X.glass, nc); for (const [x, z] of [[TX - 1.25, TZ - .25], [TX + .15, TZ - .3], [TX + 1.55, TZ - .25], [TX + .2, TZ + .32]]) Cy(g, .035, .1, x, TY + .05, z, X.glass, nc);
  const paper = X.paper, ink = M(0x2f5f8a, { r: .8 }), red = M(0xc0583f, { r: .8 });
  for (const [dx, dz, r] of [[0, 0, .12], [.26, .06, -.2]]) { const pg = grp(g, TX + 1.4 + dx, TY + .002, TZ - .3 + dz, r); B(pg, -.105, .105, 0, .003, -.15, .15, paper, nc); for (let i = 0; i < 5; i++) { const hh = [.05, .08, .07, .11, .09][i]; B(pg, -.07 + i * .032, -.05 + i * .032, .003, .005, .06 - hh, .06, i === 4 ? red : ink, nc); } }
  B(g, TX - 1.62, TX - 1.3, TY, TY + .012, TZ - .42, TZ - .14, M(0xf3e6b8, { r: .9 }), nc);
  Cy(g, .042, .085, TX + .38, TY + .042, TZ - .28, X.ceramic, nc);
  const scrM = M(0x0b0d10, { e: 0x9fd0ff, ei: 0 });
  RB(g, .34, .016, .24, TX, TY + .008, TZ + .3, alu, .006, nc);
  { const lid = grp(g, TX, TY + .016, TZ + .18); lid.rotation.x = -.32; RB(lid, .34, .23, .012, 0, .115, 0, alu, .006, nc); B(lid, -.155, .155, .012, .218, .006, .009, scrM, nc); }
  const pen = new THREE.Mesh(new THREE.CylinderGeometry(.006, .006, .15, 8), M(0x1b1d22, { r: .5 })); pen.castShadow = false; g.add(pen); keep.push(pen);
  const penA = { p: V(TX - 1.53, TY + .07, TZ - .3), r: new THREE.Euler(.35, 0, -.75) }, penB = { p: V(TX - 1.2, TY + .007, TZ - .12), r: new THREE.Euler(0, .5, PI / 2) };
  let penK = 0, penT = 0; pen.position.copy(penA.p); pen.rotation.copy(penA.r);
  // pendants + lounge
  const lampM = M(0xf3e9d8, { r: .7, e: 0xffc27a, ei: 0 });
  for (const x of [TX - 1.4, TX, TX + 1.4]) { B(g, x - .006, x + .006, 2.3, TH, TZ - .006, TZ + .006, mull, nc); Cy(g, .2, .16, x, 2.24, TZ, lampM, { geo: CONEG, cast: false }); }
  floorP(g, 9.2, 11.7, 9.2, 11.7, .012, X.rug, 1.2);
  armchair(g, 9.8, 0, 10.9, PI * .75, M(0x3d2a1f, { r: .6 })); armchair(g, 11.0, 0, 9.7, PI * .75 + PI / 2 - .2, M(0x3d2a1f, { r: .6 }));
  Cy(g, .3, .04, 10.8, .48, 10.8, wal); Cy(g, .04, .46, 10.8, .23, 10.8, mull); floorLamp(g, 11.5, 0, 11.4);
  plant(g, 11.5, 0, .55, 1.15, 2); plant(g, .6, 0, 11.4, 1.1, 1); plant(g, .55, 0, 3.8, .9, 0);
  const MST = { lampMat: lampM, screenMat: scrM, lampPos: V(TX, 2.2, TZ), screenPos: V(TX, 1.0, TZ + .1) };
  const pool = [decal(g, TX, .02, TZ, 6.4, 4.4, poolMat)];
  const mk = (id, role, name, look) => ({ id, role, name, lane: 0, look, events: [{ t: -1, s: { k: 'seat' }, a: 'meeting', full: 'Meridian görüşmesi' }] });
  return {
    g, bounds: new THREE.Box3(V(-.4, -.4, -.4), V(W + .4, TH, D + .4)), sunOff: V(16, 30, 22), fog: o.night ? { near: 150, far: 430 } : { near: 132, far: 330 },
    sky: [], sconces: [], panes: [], low: city.low, posts: city.posts, fades: [], pool, env: 'cevre', keep, elev,
    maxN: 4, spd: 3,
    people: () => [mk(0, 'founder', 'Deniz Kaya'), mk(20, 'inv', LK[20].name, LK[20]), mk(21, 'inv', LK[21].name, LK[21]), mk(22, 'inv', LK[22].name, LK[22])],
    peopleCfg: () => ({ roles: [], meetings: [] }),
    spot: (p, s) => s.k === 'out' ? OUTM : (SEAT[p.id] || SEAT[0]),
    station: p => p.id === 0 ? MST : null, stations: [MST], connector: () => [],
    table: V(TX, TY, TZ),
    pen, penA, penB, // export handles (tools/office3d)
    penDrop() { penT = 1; }, penHold() { penT = 0; penK = 0; pen.position.copy(penA.p); pen.rotation.copy(penA.r); },
    tick(time, dayK) {
      city.tick(time, dayK);
      if (penK !== penT) { penK = Math.min(1, penK + .06); const e = penK * penK; pen.position.lerpVectors(penA.p, penB.p, e); pen.position.y += Math.sin(penK * PI) * .03; pen.rotation.set(penA.r.x + (penB.r.x - penA.r.x) * e, penA.r.y + (penB.r.y - penA.r.y) * e, penA.r.z + (penB.r.z - penA.r.z) * e); }
    },
  };
}
