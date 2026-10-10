// The streets and blocks around the three offices that stand in a city grid (home, ishani, loft).
// The design draws the office and a few neighbours on a bare ground sheet; the game camera's widest zoom
// (0.6 x fit) shows far more. This module fills that frame. It runs after the place builder and before bake():
// it reads what the builder placed (an occupancy raster of its meshes), adds streets, blocks, trees, cars and
// lamps, and leaves every named node and every other place alone. Every random choice comes from a seeded
// stream, so the module adds no non-determinism of its own.
import { hipRoof } from './src/office-home.js';
import { SHARED } from './src/office-sim-v12.js';

// Palette from the design (office-home.js, office-city-v2.js, office-sim-v12.js). A few neutral prop and shading
// colours are our own: sand, white, wood, the cooler and car grey, the glass blues, SILL and the 0x6b5e50 shade.
const BAND = 0xefe2c8, METAL = 0x5d6470, FLAT = 0x8e8a84, STONE = 0xcfc6b6, PLASTER = 0xcdbfa9, TANK = 0x9aa0a6;
const TILES = [0xb5553a, 0xa24b36, 0xc0674a];
const AWNINGS = [0x3f6f7a, 0xc0583f, 0xd9a441, 0x6f8a7a];
const CARS = [0xc0583f, 0x6f9a7a, 0xf2c230, 0xd9d4c8, 0x2c3446];
const LAUNDRY = [0xffffff, 0x6f8a7a, 0xc0583f, 0xd9a441, 0x3f6f7a];
const GLASS = [0x8ea3c6, 0x46598a], FRAME = 0x3a3d42, SILL = 0xcdbfa6;

const walls = list => list.map(([kind, col]) => ({ kind, col }));

// Per place. Numbers marked (builder) are measured from the place builder's code, so they change when it does.
//  gy, floor, bay, shopFloor   street level, storey height, window bay, shop storey (builder)
//  frame   the 0.6 x fit camera frame at 21:9 on the ground, in axes a (toward the camera) and b (to the right):
//          its centre (cx, cz) and how far it reaches in a and b; nothing beyond it is seen up to 21:9
//  lot     the office plot [x0, x1, z0, z1]: distance from it sets which blocks cast shadows and carry rooftop life (builder)
//  area    extent of the occupancy raster
//  sheet   an extra ground sheet over area (y above gy, material), left out over the layout bounds: the builder's own
//          ground is walked there, and bake_nav.gd bakes every mesh inside them
//  reserve ground the builder already uses that no row may cover
//  road, walk, slab   half road width, walk width, [bottom, top] of walk and road above gy (builder)
//  ew, ns  streets along x and along z (builder); ex is the stretch the builder already paved, so no road or walk is
//          added there; dashEx the stretch without lane dashes (default ex); wN and wS the walk widths
//  palette wall kinds and colours the rows draw from
//  streams seeds: layout, props, rooftops, the landmark block
//  castR   how far from the lot a block or tree still casts a sun shadow
//  mixedRoofs and clutter   hip and flat roofs side by side; rooftop life on flat roofs
//  trees   street trees and, inside `lawn`, lawn trees; parked the share of kerb stations that hold a car, vans the
//          share of those that are a dolmus
const PLACES = {
  home: {
    gy: -9.6, floor: 3.2, bay: 2.3, shopFloor: 3.4, castR: 38,
    frame: { cx: -2.1, cz: -0.9, aTop: -56, aBot: 54.2, bMax: 74 },
    lot: [-1, 14.5, -1, 12],
    area: [-70, 82, -70, 79.6],
    road: 3, walk: 2.6, slab: { walk: [0, .12], road: [0, .04] },
    ew: [{ z: -43, x0: -70, x1: 80 }, { z: 15.6, x0: -70, x1: 80, ex: [-40, 52], dashEx: [-24, 42], wN: 2.75, wS: 2.5 }, { z: 57, x0: -70, x1: 80 }],
    ns: [{ x: -43, z0: -70, z1: 80 }, { x: 18, z0: -70, z1: 12.6, ex: [-40, 12.6], dashEx: [-24, 12.6] }, { x: 35, z0: -70, z1: 80 }, { x: 58.8, z0: -70, z1: 80 }],
    palette: walls([0xd9a896, 0xb9c4a0, 0xd8b77a, 0xcdbfa9, 0xc9b49a, 0xd9c3a3].map(c => ['apt', c])),
    streams: [303, 909, 404, 505],
    mixedRoofs: true, clutter: true, trees: { lawn: [-66, 74, -66, 69] }, parked: .6, vans: .09,
  },
  ishani: {
    gy: -6.6, floor: 3.3, bay: 2.6, shopFloor: 3.6, castR: 30,
    frame: { cx: 7.8, cz: 12.3, aTop: -82, aBot: 80, bMax: 108 },
    lot: [-12.5, 32, -24, 24.5],
    area: [-140, 170, -140, 200], sheet: { y: -.02, mat: 'groundMat' }, reserve: [-16.5, 23.5, 24.4, 56],
    road: 2.9, walk: 2.4, slab: { walk: [0, .12], road: [0, .04] },
    ew: [{ z: -70, x0: -120, x1: 150 }, { z: -42, x0: -120, x1: 150 }, { z: 21.35, x0: -120, x1: 150, ex: [-80, 110], wN: 2.95, wS: .01 },
      { z: 62, x0: -120, x1: 150 }, { z: 90, x0: -120, x1: 150 }],
    ns: [{ x: -64, z0: -110, z1: 130 }, { x: -32, z0: -110, z1: 130 }, { x: 26.35, z0: -110, z1: 24.5, ex: [-80, 24.5] },
      { x: 70, z0: -110, z1: 130 }, { x: 96, z0: -110, z1: 130 }],
    palette: walls([['stone', 0xcfc6b6], ['stone', 0xc9b49a], ['stone', 0xd6c7ae], ['stone', 0xcdbfa9], ['brick', 0xc0876a], ['brick', 0xb97a60], ['brick', 0xcfa585]]),
    streams: [101, 909],
    parked: .45,
  },
  loft: {
    gy: 0, floor: 3.3, bay: 2.4, shopFloor: 3.6,
    frame: { cx: 20.4, cz: 18.9, aTop: -112, aBot: 112, bMax: 148 },
    lot: [-16, 72, -26, 36],
    area: [-170, 190, -135, 49.3], sheet: { y: -.32, mat: 'walkMat' }, reserve: [-17, 47.5, -25, 35],
    road: 3.1, walk: 2.6, slab: { walk: [-.3, 0], road: [-.45, -.14] },
    ew: [{ z: -80, x0: -160, x1: 180 }, { z: -42, x0: -160, x1: 49.5 }, { z: -42, x0: 126, x1: 180 }, { z: 40.75, x0: -160, x1: 180, ex: [-60, 106], wN: 3.3, wS: 5 }],
    ns: [{ x: -76, z0: -130, z1: 40 }, { x: -34, z0: -130, z1: 40 }, { x: 52.75, z0: -130, z1: 40, ex: [-60, 44] }, { x: 132, z0: -130, z1: 40 }],
    palette: walls([['shed', 0xb07a5c], ['render', 0xcdbfa9], ['brick', 0xd7b08c], ['shed', 0xa8765c], ['render', 0xc9b49a], ['brick', 0xc07a5c],
      ['shed', 0xc2b5a0], ['render', 0xd6c7ae], ['brick', 0xd2a07a]]),
    streams: [101, 909],
    parked: .45,
  },
};

const hex = c => '#' + c.toString(16).padStart(6, '0');

// What is left of [a0, a1] after removing the cut intervals.
function cutOut(a0, a1, cuts) {
  let segs = [[a0, a1]];
  for (const [c0, c1] of cuts) {
    segs = segs.flatMap(([s0, s1]) => [[s0, Math.min(s1, c0)], [Math.max(s0, c1), s1]].filter(([p, q]) => q - p > .01));
  }
  return segs;
}

const geometry = (T, pos, nor, uv, idx) => {
  const g = new T.BufferGeometry();
  g.setAttribute('position', new T.Float32BufferAttribute(pos, 3));
  g.setAttribute('normal', new T.Float32BufferAttribute(nor, 3));
  g.setAttribute('uv', new T.Float32BufferAttribute(uv, 2));
  g.setIndex(idx);
  return g;
};

// Four walls with one window tile per `bay` metres across and per `fl` metres up; (ou, ov) staggers the pattern.
function wallGeometry(T, w, h, d, bay, fl, ou, ov) {
  const hw = w / 2, hd = d / 2, hh = h / 2, pos = [], nor = [], uv = [], idx = [], rows = Math.max(1, Math.round(h / fl));
  for (const [ax, az, bx, bz, nx, nz] of [[-hw, hd, hw, hd, 0, 1], [hw, hd, hw, -hd, 1, 0], [hw, -hd, -hw, -hd, 0, -1], [-hw, -hd, -hw, hd, -1, 0]]) {
    const cols = Math.max(1, Math.round(Math.hypot(bx - ax, bz - az) / bay)), b = pos.length / 3;
    pos.push(ax, -hh, az, bx, -hh, bz, bx, hh, bz, ax, hh, az);
    for (let k = 0; k < 4; k++) nor.push(nx, 0, nz);
    uv.push(ou, ov, ou + cols, ov, ou + cols, ov + rows, ou, ov + rows);
    idx.push(b, b + 1, b + 2, b, b + 2, b + 3);
  }
  return geometry(T, pos, nor, uv, idx);
}

// Every rect [x0, x1, z0, z1] as boxes between y0 and y1 in ONE mesh (tops only without `sides`). Street slabs stay
// out of the ink pass (noEdge), which also keeps bake() from merging them, so one mesh per kind keeps the node count down.
function slabMesh(T, G, rects, y0, y1, mat, sides = true) {
  const pos = [], nor = [], uv = [], idx = [];
  const quad = (a, b, c, d, n) => {
    const i = pos.length / 3;
    pos.push(...a, ...b, ...c, ...d);
    for (let k = 0; k < 4; k++) nor.push(...n);
    uv.push(0, 0, 1, 0, 1, 1, 0, 1);
    idx.push(i, i + 1, i + 2, i, i + 2, i + 3);
  };
  for (const [x0, x1, z0, z1] of rects) {
    quad([x0, y1, z1], [x1, y1, z1], [x1, y1, z0], [x0, y1, z0], [0, 1, 0]);
    if (!sides) continue;
    quad([x0, y0, z1], [x1, y0, z1], [x1, y1, z1], [x0, y1, z1], [0, 0, 1]);
    quad([x1, y0, z0], [x0, y0, z0], [x0, y1, z0], [x1, y1, z0], [0, 0, -1]);
    quad([x1, y0, z1], [x1, y0, z0], [x1, y1, z0], [x1, y1, z1], [1, 0, 0]);
    quad([x0, y0, z0], [x0, y0, z1], [x0, y1, z1], [x0, y1, z0], [-1, 0, 0]);
  }
  const mesh = new T.Mesh(geometry(T, pos, nor, uv, idx), mat);
  mesh.receiveShadow = true;
  mesh.userData.noEdge = true;
  G.add(mesh);
}

export default function neighbourhood(id, L, H) {
  const P = PLACES[id];
  if (!P) return;
  const T = H.THREE, { M, rng, canvasTex, X } = H, G = L.g;
  const { gy: GY, floor: FL, bay: BAY, shopFloor: SF } = P, { cx: CX, cz: CZ, aTop, aBot, bMax } = P.frame;
  const [R, R2, R3, R4] = P.streams.map(seed => rng(seed));
  const mix = (a, b, t) => new T.Color(a).lerp(new T.Color(b), t).getHex();
  const pick = (list, r = R) => list[Math.floor(r() * list.length)];

  const m = {
    band: M(BAND, { r: .8 }), metal: M(METAL, { r: .7 }), flat: M(FLAT, { r: .9 }), stone: M(STONE, { r: .8 }), plaster: M(PLASTER, { r: .9 }),
    tank: M(TANK, { r: .6 }), bark: M(0x6b4e3a, { r: .9 }), iron: M(0x1f2126, { r: .6 }), pole: M(0x3b3f4c, { r: .6 }),
    glass: M(0x3a4a66, { r: .1 }), dark: M(0x1f2229, { r: .6 }), sand: M(0xe6d3a3, { r: .9 }), water: M(0x7fb3c9, { r: .4 }),
    slide: M(0xc0583f, { r: .6 }), cooler: M(0xd9d4c8, { r: .6 }), panel: M(0x2c3446, { r: .25, m: .2 }), white: M(0xefe9dc, { r: .5 }),
    roofDark: M(0x3a3d42, { r: .6 }), wood: M(0xb08a62, { r: .9 }),
  };
  const tiles = TILES.map(c => M(c, { r: .9 })), awnings = AWNINGS.map(c => M(c, { r: .8 })), laundry = LAUNDRY.map(c => M(c, { r: .9 }));

  const BOX = new T.BoxGeometry(1, 1, 1), ICO = new T.IcosahedronGeometry(1, 1), CYL6 = new T.CylinderGeometry(.75, 1, 1, 6);
  const CYL8 = new T.CylinderGeometry(1, 1, 1, 8), CYL10 = new T.CylinderGeometry(1, 1, 1, 10), CYL12 = new T.CylinderGeometry(1, 1, 1, 12);
  const CONE8 = new T.ConeGeometry(1, 1, 8), CONE10 = new T.ConeGeometry(1, 1, 10);
  const bx = (x0, x1, y0, y1, z0, z1, mat, cast = false) => H.B(G, x0, x1, y0, y1, z0, z1, mat, { cast });
  const part = (geo, mat, x, y, z, sx, sy, sz, cast = false, ry = 0, rx = 0, rz = 0) => {
    const mesh = new T.Mesh(geo, mat);
    mesh.position.set(x, y, z);
    mesh.scale.set(sx, sy, sz);
    mesh.rotation.set(rx, ry, rz);
    mesh.castShadow = cast;
    mesh.receiveShadow = true;
    G.add(mesh);
    return mesh;
  };
  const flatPatch = (x0, x1, z0, z1, y, mat) => { H.floorP(G, x0, x1, z0, z1, y, mat, 4).userData.noEdge = true; };

  // ---------- occupancy of what the builder placed: bit 1 solid, 2 street or low flat, 4 tree ----------
  const [ax0, ax1, az0, az1] = P.area, NX = Math.ceil(ax1 - ax0), NZ = Math.ceil(az1 - az0), occ = new Uint8Array(NX * NZ);
  const scan = (x0, x1, z0, z1, visit) => {
    const i1 = Math.min(NX - 1, Math.floor(x1 - ax0)), j1 = Math.min(NZ - 1, Math.floor(z1 - az0));
    for (let i = Math.max(0, Math.floor(x0 - ax0)); i <= i1; i++) for (let j = Math.max(0, Math.floor(z0 - az0)); j <= j1; j++) if (visit(i * NZ + j)) return true;
    return false;
  };
  const mark = (x0, x1, z0, z1, bit = 1) => scan(x0, x1, z0, z1, k => { occ[k] |= bit; });
  const isFree = (x0, x1, z0, z1) => !scan(x0, x1, z0, z1, k => occ[k] & 1);
  const cellAt = (x, z) => { const i = Math.floor(x - ax0), j = Math.floor(z - az0); return i >= 0 && i < NX && j >= 0 && j < NZ ? occ[i * NZ + j] : 0; };
  G.updateMatrixWorld(true);
  const box = new T.Box3();
  G.traverse(o => {
    if (!o.isMesh || o.material === H.groundMat) return;
    box.setFromObject(o);
    if (box.max.x - box.min.x > 150 || box.max.y - box.min.y > 60) return;
    mark(box.min.x, box.max.x, box.min.z, box.max.z, box.max.y < GY + .2 ? 2 : 1);
  });

  // ---------- the frame ----------
  const visible = (x0, x1, z0, z1, height = 0) => {
    const corners = [[x0, z0], [x1, z0], [x0, z1], [x1, z1]], a = corners.map(([x, z]) => x - CX + z - CZ), b = corners.map(([x, z]) => x - CX - z + CZ);
    return Math.max(...a) >= aTop && Math.min(...a) <= aBot + height * .95 && Math.max(...b) >= -bMax && Math.min(...b) <= bMax;
  };
  const [lx0, lx1, lz0, lz1] = P.lot;
  const nearLot = (x, z) => Math.hypot(Math.max(lx0 - x, 0, x - lx1), Math.max(lz0 - z, 0, z - lz1));

  // ---------- facades: one material per wall kind and colour, windows painted into the tile ----------
  // A night map lights a share of the tiles.
  const facadeOf = new Map(), nightOf = {};
  const nightMap = (seed, share, panes, tint) => {
    let s = seed;
    const r = () => (s = (s * 16807) % 2147483647) / 2147483647;
    const t = canvasTex(256, 256, (x, w, h) => {
      x.fillStyle = '#000';
      x.fillRect(0, 0, w, h);
      for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++) {
        if (r() >= share) continue;
        x.fillStyle = tint(r);
        for (const [fx, fy, fw, fh] of panes) x.fillRect(i * 64 + 64 * fx, j * 64 + 64 * fy, 64 * fw, 64 * fh);
      }
    });
    t.repeat.set(.25, .25);
    return t;
  };
  const SHOP_PANES = [[.08, .3, .6, .5], [.73, .3, .19, .5]];
  const NIGHT = {
    window: () => nightMap(11, .4, [[.24, .27, .52, .5]], r => r() < .7 ? '#ffc98a' : '#ffe4b5'),
    shed: () => nightMap(23, .5, [[.08, .3, .84, .5]], () => '#ffd9a0'),
    shop: () => nightMap(23, .5, SHOP_PANES, () => '#ffd9a0'),
  };
  const paneGlass = (x, a, c, w, h) => {
    const g = x.createLinearGradient(0, c, 0, c + h);
    g.addColorStop(0, hex(GLASS[0]));
    g.addColorStop(1, hex(GLASS[1]));
    x.fillStyle = hex(FRAME);
    x.fillRect(a - 3, c - 3, w + 6, h + 6);
    x.fillStyle = g;
    x.fillRect(a, c, w, h);
  };
  const drawWall = {
    window(x, w, h, col, kind) {
      if (kind === 'brick') {
        x.fillStyle = hex(mix(col, 0x3a2a22, .25));
        for (let y = 0; y < h; y += 8) x.fillRect(0, y, w, 1.5);
        for (let r = 0; r * 8 < h; r++) for (let k = (r % 2) * 16; k < w; k += 32) x.fillRect(k, r * 8, 1.5, 8);
      } else if (kind !== 'apt') {
        x.fillStyle = hex(mix(col, 0x6b5e50, .14));
        x.fillRect(0, h - 5, w, 5);
        if (kind === 'stone') x.fillRect(0, 0, w, 3);
      }
      const [fa, fb, fc, fd] = kind === 'apt' ? [.24, .76, .22, .73] : [.21, .79, .24, .73], a = w * fa, b = w * fb, c = h * fc, d = h * fd;
      x.fillStyle = hex(SILL);
      x.fillRect(a - 5, d, b - a + 10, 5);
      paneGlass(x, a, c, b - a, d - c);
      x.fillStyle = hex(FRAME);
      x.fillRect((a + b) / 2 - 1.5, c, 3, d - c);
      x.fillRect(a, c + (d - c) * .28 - 1.5, b - a, 3);
    },
    shed(x, w, h, col) {
      x.fillStyle = hex(mix(col, 0x3a2a22, .18));
      for (let k = 0; k < w; k += 8) x.fillRect(k, 0, 1.5, h);
      x.fillStyle = hex(FRAME);
      x.fillRect(w * .06, h * .4, w * .88, h * .3);
      paneGlass(x, w * .08, h * .43, w * .84, h * .24);
      x.fillStyle = hex(FRAME);
      for (let k = 1; k < 6; k++) x.fillRect(w * .08 + k * w * .84 / 6 - 1, h * .43, 2, h * .24);
    },
    // One storefront per tile: fascia, display window, door, stall riser.
    shop(x, w, h, col) {
      x.fillStyle = hex(mix(col, 0x6b5e50, .22));
      x.fillRect(0, 0, w, h * .2);
      x.fillStyle = hex(SILL);
      x.fillRect(w * .06, h * .8, w * .88, 5);
      for (const [fx, fy, fw, fh] of SHOP_PANES) paneGlass(x, w * fx, h * fy, w * fw, h * fh);
      x.fillStyle = hex(FRAME);
      for (const k of [1, 2]) x.fillRect(w * (.08 + .2 * k) - 1.5, h * .3, 3, h * .5);
    },
  };
  const facade = (kind, col) => {
    const key = kind + col;
    if (facadeOf.has(key)) return facadeOf.get(key);
    const night = kind === 'shed' || kind === 'shop' ? kind : 'window', draw = drawWall[kind] || drawWall.window;
    const tex = canvasTex(kind === 'shop' ? 256 : 128, 128, (x, w, h) => { x.fillStyle = hex(col); x.fillRect(0, 0, w, h); draw(x, w, h, col, kind); });
    const mat = M(0xffffff, { map: tex, r: .9 });
    mat.emissive.set(0xffc27a);
    mat.emissiveMap = nightOf[night] ||= NIGHT[night]();
    mat.emissiveIntensity = 0; // the export freezes the day; Godot drives 'facade' materials by name at night
    facadeOf.set(key, mat);
    return mat;
  };

  // ---------- streets ----------
  const RH = P.road, WK = P.walk, [walkLo, walkHi] = P.slab.walk, [roadLo, roadHi] = P.slab.road;
  const FOOT = GY + walkHi, CAR = GY + roadHi;
  const roads = [], walks = [], dashes = [];
  const corridor = c => [c - RH - WK, c + RH + WK];
  const roadsNS = P.ns.map(s => [s.x - RH, s.x + RH]), roadsEW = P.ew.map(s => [s.z - RH, s.z + RH]);
  for (const [streets, alongX] of [[P.ew, true], [P.ns, false]]) for (const s of streets) {
    const c = alongX ? s.z : s.x, [a0, a1] = alongX ? [s.x0, s.x1] : [s.z0, s.z1], across = alongX ? roadsNS : roadsEW;
    // p..q along the street, lo..hi across it
    const rect = (p, q, lo, hi) => alongX ? [p, q, lo, hi] : [lo, hi, p, q];
    const wn = s.wN || WK, ws = s.wS || WK, [d0, d1] = s.dashEx || s.ex || [0, 0];
    for (const [p, q] of s.ex ? cutOut(a0, a1, [s.ex]) : [[a0, a1]]) {
      roads.push(rect(p, q, c - RH, c + RH));
      for (const [u, v] of cutOut(p, q, across)) walks.push(rect(u, v, c - RH - wn, c - RH), rect(u, v, c + RH, c + RH + ws));
    }
    for (let t = a0 + 3; t < a1 - 2; t += 3) {
      if (s.ex && t >= d0 && t < d1 || across.some(([a, b]) => t + 1.4 > a - .5 && t < b + .5)) continue;
      dashes.push(rect(t, t + 1.4, c - .1, c + .1));
    }
  }
  for (const [x0, x1, z0, z1] of roads.concat(walks)) mark(x0, x1, z0, z1, 2);
  const shown = ([x0, x1, z0, z1]) => visible(x0, x1, z0, z1);
  slabMesh(T, G, roads.filter(shown), GY + roadLo, GY + roadHi, H.roadMat);
  slabMesh(T, G, walks.filter(shown), GY + walkLo, GY + walkHi, H.walkMat);
  slabMesh(T, G, dashes.filter(shown), CAR, CAR + .01, H.lineMat, false);
  if (P.reserve) mark(...P.reserve);
  // The builder's ground sheet ends short of the frame at ishani and is missing on the loft's land side.
  if (P.sheet) {
    const { min, max } = L.bounds;
    for (const [x0, x1, z0, z1] of [[ax0, min.x, az0, az1], [max.x, ax1, az0, az1], [min.x, max.x, az0, min.z], [min.x, max.x, max.z, az1]])
      flatPatch(x0, x1, z0, z1, GY + P.sheet.y, H[P.sheet.mat]);
  }

  // ---------- props ----------
  // Cheaper than H.tree, H.car, H.bench and H.lampPost (flat boxes, six-sided trunks, a few icospheres): hundreds of
  // these stand in the frame.
  const tree = (x, z, k, cast = false) => {
    if (!visible(x - 2, x + 2, z - 2, z + 2, 6) || cellAt(x, z) & 5) return;
    part(CYL6, m.bark, x, FOOT + k, z, .14 * k, 2 * k, .14 * k, cast);
    if (cast) {
      part(ICO, X.leaves[1], x, FOOT + 2.5 * k, z, 1.1 * k, .95 * k, 1.1 * k, true);
      part(ICO, X.leaves[R() < .5 ? 0 : 2], x + .5 * k, FOOT + 2.1 * k, z + .3 * k, .65 * k, .55 * k, .65 * k, true);
    } else part(ICO, X.leaves[R() < .3 ? 0 : 1], x, FOOT + 2.4 * k, z, 1.2 * k, k, 1.2 * k);
    mark(x - .6, x + .6, z - .6, z + .6, 4);
  };
  const cypress = (x, z, h) => {
    if (cellAt(x, z) & 5) return;
    part(CONE8, X.leaves[0], x, FOOT + h / 2, z, .6, h, .6);
    mark(x - .5, x + .5, z - .5, z + .5, 4);
  };
  // A car, or a dolmus (the small shared minibus), standing along x or z; it parks only where nothing solid stands.
  const VEHICLE = { car: { seen: 2, clear: 1.4, size: 1.2 }, van: { seen: 3, clear: 2.4, size: 2.4 } };
  const vehicle = (kind, x, z, alongX, color) => {
    const { seen, clear, size } = VEHICLE[kind], van = kind === 'van', body = M(color, { r: van ? .35 : .3, m: .1 });
    if (!visible(x - seen, x + seen, z - seen, z + seen, 2) || !isFree(x - clear, x + clear, z - clear, z + clear)) return false;
    const piece = (c, y, lx, ly, lz, mat) => part(BOX, mat, x + (alongX ? c : 0), CAR + y, z + (alongX ? 0 : c), alongX ? lx : lz, ly, alongX ? lz : lx);
    if (van) {
      piece(0, .62, 4.4, .78, 1.7, body); piece(-.1, 1.22, 3.9, .5, 1.62, m.glass); piece(-.1, 1.5, 3.7, .08, 1.5, body);
      piece(0, .2, 4.2, .24, 1.5, m.dark); piece(2.05, .5, .2, .22, 1.5, m.dark);
    } else {
      piece(0, .36, 2.1, .34, .9, body); piece(-.12, .66, 1.2, .32, .84, m.glass); piece(-.12, .84, 1.05, .04, .8, body); piece(0, .2, 2, .16, .8, m.dark);
    }
    mark(x - size, x + size, z - size, z + size);
    return true;
  };
  const lamp = (x, z, glow) => {
    if (!visible(x - 1, x + 1, z - 1, z + 1, 4)) return;
    part(CYL6, m.pole, x, FOOT + 1.6, z, .06, 3.2, .06);
    part(BOX, SHARED.postMat, x, FOOT + 3.25, z, .3, .18, .3);
    if (glow) H.decal(G, x, FOOT + .02, z, 4.5, 4.5, SHARED.streetGlow);
  };
  // An awning tilts out over `side` (z0, z1, x0 or x1) of the box.
  const awning = (side, x0, x1, z0, z1, y, mat) => {
    const out = side[1] === '0' ? -1 : 1;
    if (side[0] === 'z') part(BOX, mat, (x0 + x1) / 2, y, out < 0 ? z0 - .55 : z1 + .55, x1 - x0 - .8, .06, 1.2, false, 0, out * .38);
    else part(BOX, mat, out < 0 ? x0 - .55 : x1 + .55, y, (z0 + z1) / 2, 1.2, .06, z1 - z0 - .8, false, 0, 0, -out * .38);
  };

  // ---------- rooftops ----------
  const parapet = (x0, x1, z0, z1, top) => {
    bx(x0, x1, top, top + .05, z0, z1, m.flat);
    for (const [a, b, c, e] of [[x0, x1, z0, z0 + .22], [x0, x1, z1 - .22, z1], [x0, x0 + .22, z0, z1], [x1 - .22, x1, z0, z1]]) bx(a, b, top, top + .5, c, e, m.band);
  };
  // What stands on the flat roof of a block of flats: water tank, solar heater, dish, stair house, aerial, cooler, wash line.
  const roofProp = (kind, x, z, top, wall, cast) => {
    const y = top + .05;
    if (kind === 'tank') {
      bx(x - .55, x + .55, y, y + .3, z - .55, z + .55, m.flat);
      part(CYL10, m.tank, x, y + .9, z, .55, 1.2, .55, cast);
      part(CYL10, m.metal, x, y + 1.55, z, .6, .1, .6);
    } else if (kind === 'solar') {
      bx(x - .7, x - .6, y, y + .45, z - .1, z, m.metal);
      bx(x + .6, x + .7, y, y + .45, z - .1, z, m.metal);
      part(BOX, m.panel, x, y + .75, z + .15, 1.7, .07, 1.3, false, 0, .55);
      part(CYL8, m.white, x, y + 1.35, z - .5, .26, 1.5, .26, false, 0, 0, Math.PI / 2);
    } else if (kind === 'dish') {
      bx(x - .04, x + .04, y, y + 1, z - .04, z + .04, m.metal);
      part(CONE10, m.cooler, x, y + 1.15, z + .12, .5, .22, .5, false, 0, Math.PI - .55);
    } else if (kind === 'stair') {
      bx(x - 1.1, x + 1.1, y, y + 2.3, z - 1, z + 1, M(wall, { r: .9 }), cast);
      bx(x - 1.25, x + 1.25, y + 2.3, y + 2.5, z - 1.15, z + 1.15, m.band);
      bx(x - .45, x + .45, y, y + 1.75, z + 1, z + 1.04, m.roofDark);
    } else if (kind === 'aerial') {
      bx(x - .03, x + .03, y, y + 3, z - .03, z + .03, m.metal);
      for (const [h, w] of [[2.9, .8], [2.45, .65], [2, .5]]) bx(x - w, x + w, y + h, y + h + .04, z - .02, z + .02, m.metal);
    } else if (kind === 'ac') {
      bx(x - .45, x + .45, y, y + .55, z - .22, z + .22, m.cooler);
      bx(x - .38, x + .38, y + .15, y + .45, z + .22, z + .25, m.roofDark);
    } else {
      bx(x - 2, x - 1.94, y, y + 1.7, z - .03, z + .03, m.metal);
      bx(x + 1.94, x + 2, y, y + 1.7, z - .03, z + .03, m.metal);
      bx(x - 2, x + 2, y + 1.62, y + 1.66, z - .01, z + .01, m.metal);
      for (let k = 0; k < 4; k++) bx(x - 1.6 + k * .95, x - 1.6 + k * .95 + .55, y + .78, y + 1.62, z - .015, z + .015, pick(laundry, R3));
    }
  };
  const roofClutter = (x0, x1, z0, z1, top, wall, dist) => {
    const w = x1 - x0, d = z1 - z0, nx = Math.max(1, Math.floor((w - 2.6) / 3.3)), nz = Math.max(1, Math.floor((d - 2.6) / 3.3)), slots = [];
    for (let i = 0; i < nx; i++) for (let j = 0; j < nz; j++) slots.push([x0 + 1.3 + (i + .5) * (w - 2.6) / nx, z0 + 1.3 + (j + .5) * (d - 2.6) / nz]);
    for (let i = slots.length - 1; i > 0; i--) { const j = Math.floor(R3() * (i + 1)); [slots[i], slots[j]] = [slots[j], slots[i]]; }
    let stair = false, line = false;
    for (let s = 0, n = Math.min(slots.length, w * d < 80 ? 1 : 1 + Math.floor(R3() * 3)); s < n; s++) {
      const r = R3();
      let kind = r < .26 ? 'tank' : r < .5 ? 'solar' : r < .64 ? 'dish' : r < .76 ? 'aerial' : r < .84 ? 'ac' : r < .93 ? 'stair' : 'line';
      if (kind === 'stair' && (stair || w < 9 || d < 9)) kind = 'tank';
      if (kind === 'line' && (line || w < 9)) kind = 'dish';
      stair ||= kind === 'stair';
      line ||= kind === 'line';
      roofProp(kind, ...slots[s], top, wall, dist < 30 && (kind === 'tank' || kind === 'stair'));
    }
  };

  // ---------- buildings ----------
  // Blocks of flats are kept for the balcony pass; shopfronts take the first three wall colours of the palette.
  const flats = [], shopWalls = P.palette.slice(0, 3);
  // `r` is the stream a block draws from: the layout stream, or a landmark's own so that adding or removing the
  // landmark never moves its neighbours. `cuts` are stretches along x that stay open (a street, the end of a row): the
  // block stands only outside them, and an east face that meets one gets an awning like every other shop front. All the
  // draws are made for the whole block, so a cut never moves the blocks after it. Returns the block's footprint, or
  // nothing where the ground is taken.
  function building({ x0, x1, z0, z1, fl, col, kind, roof, cast, shop, sides = [], r = R, cuts = [] }) {
    if (!isFree(x0 + 1.05, x1 - 1.05, z0 + 1.05, z1 - 1.05)) return;
    const up = shop ? fl - 1 : fl, y0 = GY + (shop ? SF : 0), top = y0 + up * FL, ou = Math.floor(r() * 4), ov = Math.floor(r() * 4);
    const skin = shop && facade('shop', pick(shopWalls, r).col), first = shop && Math.floor(r() * 4), tile = roof === 'flat' ? 0 : Math.floor(r() * 3);
    for (const [a0, a1] of cutOut(x0, x1, cuts).filter(([p, q]) => q - p >= 3)) {
      const w = a1 - a0, d = z1 - z0, cx = (a0 + a1) / 2, cz = (z0 + z1) / 2;
      if (up > 0) part(wallGeometry(T, w, up * FL, d, BAY, FL, ou, ov), facade(kind, col), cx, y0 + up * FL / 2, cz, 1, 1, 1, cast);
      if (shop) {
        // One storefront per 7 m or so; each carries its own awning on the faces that front a street or a lane.
        const unit = Math.max(w, d) / Math.ceil(Math.max(w, d) / 7);
        part(wallGeometry(T, w, SF, d, unit, SF, ou, 0), skin, cx, GY + SF / 2, cz, 1, 1, 1, cast);
        for (const side of cuts.some(([c0]) => Math.abs(c0 - a1) < .01) ? [...sides, 'x1'] : sides) {
          const along = side[0] === 'z' ? w : d, n = Math.ceil(along / 7), len = along / n;
          for (let k = 0; k < n; k++) {
            const span = side[0] === 'z' ? [a0 + k * len, a0 + (k + 1) * len, z0, z1] : [a0, a1, z0 + k * len, z0 + (k + 1) * len];
            awning(side, ...span, GY + SF - .7, awnings[(first + k) % 4]);
          }
        }
      }
      bx(a0 - .15, a1 + .15, top - .22, top, z0 - .15, z1 + .15, m.band);
      if (roof === 'flat') {
        parapet(a0, a1, z0, z1, top);
        const dist = nearLot(cx, cz);
        if (P.clutter) roofClutter(a0, a1, z0, z1, top, col, dist);
        else if (dist < 40) {
          part(CYL10, m.metal, a0 + w * .3, top + 1.05, z0 + d * .35, .6, 1, .6, cast);
          bx(a1 - 2.2, a1 - 1.1, top + .05, top + .9, z1 - 2.2, z1 - 1.1, m.tank);
        }
      } else {
        const rh = Math.max(1.6, Math.min(2.4, Math.min(w, d) * .16));
        hipRoof(H, G, a0 - .3, a1 + .3, z0 - .3, z1 + .3, top, rh, roof === 'metal' ? m.metal : tiles[tile]).castShadow = cast;
        bx(a0 + w * .7, a0 + w * .7 + .6, top, top + rh + .7, cz, cz + .6, m.plaster);
      }
      mark(a0, a1, z0, z1);
    }
    return { x0, x1, z0, z1, fl };
  }
  // Buildings side by side along `axis` between r0 and r1, spanning p0..p1 across; neighbours never share a wall colour.
  // o: castR shadow reach, brickMax thins out brick, shop storefronts with awnings on `sides`, cuts the passages of an
  // x row (see building), up the position along the row whose block stands one floor higher, gapEvery/gap passages
  // between blocks, flat the share of flat roofs (places with mixed roofs).
  function row(axis, r0, r1, p0, p1, f0, f1, o) {
    const widths = [], pal = P.palette, cuts = o.cuts && [...o.cuts, [r1, Infinity]];
    for (let acc = 0; acc < r1 - r0 - 7;) { const w = Math.min(r1 - r0 - acc, 9 + Math.floor(R() * 7)); widths.push(w); acc += w; }
    if (widths.length > 1 && widths.at(-1) < 8) widths[widths.length - 2] += widths.pop();
    let cur = r0, prev = Math.floor(R() * pal.length);
    for (const [i, w] of widths.entries()) {
      if (o.gapEvery && i && i % o.gapEvery === 0) cur += o.gap;
      const a0 = cur, a1 = Math.min(r1, cur + w);
      cur = a1;
      if (a1 - a0 < 6) continue;
      prev = (prev + 1 + Math.floor(R() * (pal.length - 2))) % pal.length;
      if (o.brickMax && pal[prev].kind === 'brick' && R() < .5) prev = 0;
      const fl = f0 + Math.floor(R() * (f1 - f0 + 1)) + (o.up >= a0 && o.up < a1 ? 1 : 0);
      const [x0, x1, z0, z1] = axis === 'x' ? [a0, a1, p0, p1] : [p0, p1, a0, a1];
      if (!visible(x0, x1, z0, z1, fl * FL + 2)) continue;
      const { kind, col } = pal[prev], dist = nearLot((x0 + x1) / 2, (z0 + z1) / 2);
      const roof = P.mixedRoofs ? (R() < o.flat ? 'flat' : 'tile') : kind === 'shed' ? 'metal' : 'flat';
      const block = building({ x0, x1, z0, z1, fl, col, kind, roof, cast: dist < (o.castR ?? P.castR), shop: o.shop, sides: o.sides, cuts });
      if (block && !o.shop) flats.push(block);
    }
  }
  // Rows of blocks between the streets of a district; the row on a block's south edge faces the street the camera sees.
  function district({ zSpan, xSpan, zStop, top, per, max, brickMax, castR }) {
    const edges = (centres, a0, a1) => {
      const out = [];
      let cur = a0;
      for (const [p, q] of centres.map(corridor).sort((s, t) => s[0] - t[0])) { if (p > cur + 14) out.push([cur, p]); cur = Math.max(cur, q); }
      if (a1 > cur + 14) out.push([cur, a1]);
      return out;
    };
    // The block that meets the builder's own street ends where that street starts, not at a generated walk.
    const zBlocks = edges([...new Set(P.ew.map(s => s.z))], ...zSpan).map(([p, q]) => q > zStop && q - zStop < 1 ? [p, zStop] : [p, q]);
    const depth = 15, o = { brickMax, castR }, floors = (x, z) => Math.max(2, Math.min(max, Math.round(top - (x - CX + z - CZ) / per)));
    for (const [z0, z1] of zBlocks) for (const [x0, x1] of edges(P.ns.map(s => s.x), ...xSpan)) {
      const zc = (z0 + z1) / 2, xc = (x0 + x1) / 2, f = floors(xc, z1 - depth / 2);
      row('x', x0, x1, Math.max(z0, z1 - depth), z1, f, Math.min(max, f + 1), o);
      if (x1 - x0 >= 27) { const f3 = floors(x1 - depth / 2, zc); row('z', z0, Math.max(z0, z1 - depth), Math.max(x0, x1 - depth), x1, f3, Math.min(max, f3 + 1), o); }
      if (z1 - z0 >= 27) { const f2 = floors(xc, z0 + depth / 2); row('x', x0, x1, z0, z0 + depth, f2, Math.min(max, f2 + 1), o); }
    }
  }
  // Balconies with a rail and a wash line or an air conditioner, on the two faces the camera sees.
  const balconies = ({ x0, x1, z0, z1, fl }, r = R, r2 = R3) => {
    for (const alongX of [true, false]) {
      const len = alongX ? x1 - x0 : z1 - z0, n = Math.max(1, Math.round(len / BAY));
      for (let f = 1; f < fl; f++) for (let i = 1; i < n - 1; i += 3) {
        const c = alongX ? x0 + (i + .5) / n * len : z1 - (i + .5) / n * len, y = GY + f * FL + .72;
        // a: along the face, b: out from the wall, y: up from the slab
        const put = (a0, a1, y0, y1, b0, b1, mat) => alongX ? bx(c + a0, c + a1, y + y0, y + y1, z1 + b0, z1 + b1, mat) : bx(x1 + b0, x1 + b1, y + y0, y + y1, c + a0, c + a1, mat);
        put(-.8, .8, 0, .12, 0, .9, m.band);
        put(-.8, .8, .12, 1, .84, .9, m.metal);
        if (r() < .35) put(-.3, .3, .35, 1, .8, .83, pick(laundry, r));
        else if (r2() < .16) put(.15, .75, .12, .6, .3, .65, m.cooler);
      }
    }
  };

  // ---------- home's landmarks: park, school with pitch, market ----------
  const bench = (x, z, alongX) => {
    if (alongX) { bx(x - .7, x + .7, GY + .45, GY + .5, z - .2, z + .2, m.iron); bx(x - .7, x + .7, GY + .5, GY + .9, z - .22, z - .17, m.iron); }
    else { bx(x - .2, x + .2, GY + .45, GY + .5, z - .7, z + .7, m.iron); bx(x - .22, x - .17, GY + .5, GY + .9, z - .7, z + .7, m.iron); }
  };
  function park(x0, x1, z0, z1) {
    const cx = (x0 + x1) / 2, cz = (z0 + z1) / 2;
    flatPatch(x0 + .6, x1 - .6, z0 + .6, z1 - .6, GY + .03, H.grassMat);
    flatPatch(cx - 1, cx + 1, z0 + .6, z1 - .6, GY + .05, H.walkMat);
    flatPatch(x0 + .6, x1 - .6, cz - 1, cz + 1, GY + .05, H.walkMat);
    part(CYL12, m.stone, cx, GY + .3, cz, 2.2, .6, 2.2);
    part(CYL12, m.water, cx, GY + .62, cz, 1.9, .06, 1.9);
    part(CYL10, m.stone, cx, GY + 1, cz, .35, 1.4, .35);
    mark(cx - 2.5, cx + 2.5, cz - 2.5, cz + 2.5, 4);
    for (const [px, pz] of [[x0 + 3, z0 + 3], [x1 - 3, z0 + 3], [x0 + 3, z1 - 3], [x1 - 3, z1 - 3], [x0 + 3, cz - 5], [x1 - 3, cz + 5], [cx - 5, z0 + 3], [cx + 5, z1 - 3], [x0 + 3, cz + 5], [x1 - 3, cz - 5]]) tree(px, pz, 1.25, nearLot(px, pz) < P.castR);
    for (const [bxx, bzz, along] of [[cx - 3.5, cz - 2.6, true], [cx + 3.5, cz + 2.6, true], [cx - 2.6, cz + 3.5, false], [cx + 2.6, cz - 3.5, false]]) bench(bxx, bzz, along);
    // Playground on the south lawn: sandbox, swing set, slide.
    bx(x1 - 7.2, x1 - 3.2, GY + .03, GY + .35, z1 - 5, z1 - 1.6, m.sand);
    const sx = x0 + 3, sz = z1 - 7.2, lx = x1 - 2.4, lz = z1 - 9;
    for (const dx of [-1.3, 1.3]) for (const dz of [-1, 1]) part(BOX, m.iron, sx + dx, GY + 1.28, sz + dz * .25, .1, 2.5, .1, false, 0, -dz * .2);
    bx(sx - 1.4, sx + 1.4, GY + 2.4, GY + 2.5, sz - .06, sz + .06, m.iron);
    for (const dx of [-.55, .55]) { bx(sx + dx - .01, sx + dx + .01, GY + .6, GY + 2.4, sz - .01, sz + .01, m.iron); bx(sx + dx - .22, sx + dx + .22, GY + .55, GY + .6, sz - .12, sz + .12, m.slide); }
    bx(lx - .3, lx + .3, GY + .03, GY + 2, lz - .3, lz + .3, m.slide);
    part(BOX, m.slide, lx, GY + 1, lz + 1.5, .8, .08, 2.8, false, 0, .62);
    bx(lx - .35, lx + .35, GY + 1.95, GY + 2.05, lz - .35, lz + .35, m.metal);
    mark(sx - 1.6, sx + 1.6, sz - 1.5, sz + 1.5);
    mark(lx - 1, lx + 1, lz - 1, lz + 3.2);
    for (const [qx, qz] of [[x0 + 1.2, z0 + 1.3], [x1 - 1.2, z0 + 1.3], [x0 + 1.2, z1 - 1.3], [x1 - 1.2, z1 - 1.3]]) cypress(qx, qz, 6.5);
    mark(x0, x1, z0, z1);
  }
  // U-shaped school, three floors, flat roof; its yard is the football pitch.
  function school(x0, x1, z0, z1) {
    const fl = 3, col = 0xbfb8ad;
    for (const [a0, a1, b0, b1] of [[x0, x1, z0, z0 + 9], [x0, x0 + 8, z0 + 9, z1], [x1 - 8, x1, z0 + 9, z1]]) {
      part(wallGeometry(T, a1 - a0, fl * FL, b1 - b0, BAY, FL, 1, 1), facade('apt', col), (a0 + a1) / 2, GY + fl * FL / 2, (b0 + b1) / 2, 1, 1, 1, true);
      parapet(a0, a1, b0, b1, GY + fl * FL);
      bx(a0 - .15, a1 + .15, GY + fl * FL - .22, GY + fl * FL, b0 - .15, b1 + .15, m.band);
    }
    bx(x0 + 3, x0 + 3.12, GY + fl * FL, GY + fl * FL + 7, z0 + 3, z0 + 3.12, m.metal);
    bx(x0 + 3.12, x0 + 4.6, GY + fl * FL + 5.2, GY + fl * FL + 6.4, z0 + 3, z0 + 3.03, awnings[1]);
    mark(x0, x1, z0, z1);
  }
  function pitch(x0, x1, z0, z1) {
    const y = GY + .04, t = .12, cx = (x0 + x1) / 2;
    flatPatch(x0, x1, z0, z1, GY + .03, H.grassMat);
    const line = (a, b, c, d) => { bx(a, b, y, y + .01, c, d, H.lineMat).userData.noEdge = true; };
    line(x0 + 1, x1 - 1, z0 + 1, z0 + 1 + t); line(x0 + 1, x1 - 1, z1 - 1 - t, z1 - 1);
    line(x0 + 1, x0 + 1 + t, z0 + 1, z1 - 1); line(x1 - 1 - t, x1 - 1, z0 + 1, z1 - 1);
    line(x0 + 1, x1 - 1, (z0 + z1) / 2 - t / 2, (z0 + z1) / 2 + t / 2);
    for (const gz of [z0 + 1, z1 - 1]) {
      bx(cx - 1.8, cx - 1.7, GY + .03, GY + 1.6, gz - .05, gz + .05, m.iron);
      bx(cx + 1.7, cx + 1.8, GY + .03, GY + 1.6, gz - .05, gz + .05, m.iron);
      bx(cx - 1.8, cx + 1.8, GY + 1.55, GY + 1.65, gz - .05, gz + .05, m.iron);
    }
    mark(x0, x1, z0, z1);
  }
  // Open-air stalls along a north-south walk: awning, counter, crates.
  function stalls(x, z0, z1) {
    mark(x - .2, x + 2.8, z0 - .2, z1 + 3);
    for (let z = z0; z < z1; z += 5.2) {
      part(BOX, pick(awnings), x + 1.1, GY + 2.2, z + 1.4, 2.2, .08, 2.4, false, 0, 0, -.18);
      bx(x + .3, x + .4, GY + .12, GY + 2.2, z + .3, z + .4, m.iron);
      bx(x + .3, x + .4, GY + .12, GY + 2, z + 2.5, z + 2.6, m.iron);
      bx(x + .3, x + 1.5, GY + .12, GY + .9, z + .5, z + 2.3, m.wood);
      for (let k = 0; k < 3; k++) bx(x + 1.7, x + 2.2, GY + .12, GY + .5, z + .4 + k * .7, z + .8 + k * .7, pick(laundry));
    }
  }

  // ---------- layouts ----------
  const LAYOUT = {
    // Tall blocks north and west of the lot (behind it from the camera), low shops and three-floor rows south and
    // east so nothing hides the flat; a park, a block of flats, a school with its pitch and a market.
    home() {
      const D = 12.6, tall = { flat: .45 }, shops = { flat: 1, shop: true };
      row('x', -37.4, 12.25, -37.4, -37.4 + D, 5, 6, tall);
      row('x', 40.6, 53.2, -37.4, -37.4 + D, 3, 4, tall);
      row('x', -48.6, 76, -48.6 - D, -48.6, 6, 7, tall);
      row('z', -66, 76, -61.2, -48.6, 5, 6, tall);
      park(-37.4, -24.8, -24.8, 9.85);
      const landmark = building({ x0: -36.8, x1: -22.3, z0: 22.4, z1: 22.4 + D, fl: 4, col: 0xd9c3a3, kind: 'apt', roof: 'tile', cast: true, r: R4 });
      row('x', 21.2, 29.4, 21.1, 26.6, 1, 1, { ...shops, sides: ['z0'] });
      row('x', 40.6, 53.2, 21.1, 26.6, 1, 1, { ...shops, sides: ['z0'] });
      row('z', -37.4, -22, 23.5, 29, 1, 1, { ...shops, sides: ['x0'] });
      row('x', -22, 29.4, 36.4, 49, 3, 3, { ...tall, gapEvery: 3, gap: 4 });
      row('x', 40.6, 53.2, 36.4, 49, 3, 3, tall);
      school(40.8, 53, -24.4, -4.8);
      pitch(41, 53, -3.2, 9.4);
      stalls(29.4, -20, 8);
      for (const b of flats) if (b.fl >= 3 && nearLot((b.x0 + b.x1) / 2, (b.z0 + b.z1) / 2) < 60) balconies(b);
      if (landmark) balconies(landmark, R4, R4);
    },
    // Brick and stone rows in a grid, with shop rows on the south side of the main street.
    ishani() {
      // The shop strips stop at the cross streets; the shop at the corner of the x = 70 street and the one at the end by
      // the office stand two floors.
      const shops = { shop: true, sides: ['z0', 'z1'], cuts: P.ns.map(st => corridor(st.x)) };
      row('x', 32, 140, 26.8, 32.3, 1, 1, { ...shops, up: 60 });
      row('x', -100, -17, 26.8, 32.3, 1, 1, { ...shops, up: -20 });
      district({ zSpan: [-112, 120], xSpan: [-128, 140], zStop: 15.25, top: 3.5, per: 22, max: 6, brickMax: true, castR: 34 });
    },
    // Warehouses, brick and render rows on the land side of the quay.
    loft() {
      district({ zSpan: [-136, 49.3], xSpan: [-168, 188], zStop: 34.3, top: 3.4, per: 28, max: 5, castR: 40 });
    },
  };
  LAYOUT[id]();

  // ---------- street life ----------
  // Positions along every street, in the order the streams are drawn: street by street, each side, each station.
  function* stations(start, step, sides) {
    for (const [streets, alongX] of [[P.ew, true], [P.ns, false]]) {
      for (const s of streets) for (const side of sides) for (let p = (alongX ? s.x0 : s.z0) + start; p < (alongX ? s.x1 : s.z1); p += step) yield { s, side, p, alongX };
    }
  }
  const at = ({ s, side, p, alongX }, off) => alongX ? [p, s.z + side * off] : [s.x + side * off, p];
  const crossing = ({ p, alongX }, margin) => (alongX ? roadsNS : roadsEW).some(([a, b]) => p > a - margin && p < b + margin);

  if (P.trees) {
    for (const st of stations(4, 8.5, [-1, 1])) {
      if (crossing(st, 1.5)) continue;
      const [x, z] = at(st, RH + WK * .5), shift = R2() * 1.2, k = .9 + R2() * .25;
      tree(x + (st.alongX ? shift : 0), z + (st.alongX ? 0 : shift), k, nearLot(x, z) < P.castR);
    }
    const [x0, x1, z0, z1] = P.trees.lawn;
    for (let i = 0; i < 300; i++) {
      const x = x0 + R2() * (x1 - x0), z = z0 + R2() * (z1 - z0);
      if (isFree(x - 1.5, x + 1.5, z - 1.5, z + 1.5) && !(cellAt(x, z) & 6)) tree(x, z, .9 + R2() * .4);
    }
  }
  for (const st of stations(5, 6.5, [-1, 1])) {
    if (R2() > P.parked || crossing(st, 3)) continue;
    const [x, z] = at(st, RH - 1.3), color = pick(CARS, R2);
    if (!(P.vans && R3() < P.vans && vehicle('van', x, z, st.alongX, color))) vehicle('car', x, z, st.alongX, color);
  }
  let lit = 0;
  for (const st of stations(9, 22, [1])) {
    if (crossing(st, 2)) continue;
    lamp(...at(st, RH + .1), st.alongX && nearLot(st.p, st.s.z) < 28 && lit++ < 8);
  }

  L.facMats = [...facadeOf.values()];
}
