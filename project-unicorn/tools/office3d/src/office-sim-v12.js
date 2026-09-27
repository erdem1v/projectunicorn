import * as THREE from 'https://esm.sh/three@0.160.0';
import { EffectComposer } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/RenderPass.js';
import { GTAOPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/GTAOPass.js';
import { UnrealBloomPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/UnrealBloomPass.js';
import { ShaderPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/ShaderPass.js';
import { FXAAShader } from 'https://esm.sh/three@0.160.0/examples/jsm/shaders/FXAAShader.js';
import { OutputPass } from 'https://esm.sh/three@0.160.0/examples/jsm/postprocessing/OutputPass.js';
import { GLTFLoader } from 'https://esm.sh/three@0.160.0/examples/jsm/loaders/GLTFLoader.js';
import { clone as skClone } from 'https://esm.sh/three@0.160.0/examples/jsm/utils/SkeletonUtils.js';
import { RoomEnvironment } from 'https://esm.sh/three@0.160.0/examples/jsm/environments/RoomEnvironment.js';
import { RoundedBoxGeometry } from 'https://esm.sh/three@0.160.0/examples/jsm/geometries/RoundedBoxGeometry.js';
import { mergeGeometries } from 'https://esm.sh/three@0.160.0/examples/jsm/utils/BufferGeometryUtils.js';
import { buildPeopleX, buildTLX, evalTLX } from './people-x.js';
import { buildPlaza } from './office-plaza-v2.js';
import { buildLoft } from './office-loft-v2.js';
import { buildHome } from './office-home.js';
import { buildCity } from './office-city.js';
import { ROLES, buildPeople, buildTL, evalTL, iconMats, makeChar as makeCapsule, ICON, ACT_LABEL, SHORT, fmt, rng, sm } from './office-sim-v2.js';

const V = (x = 0, y = 0, z = 0) => new THREE.Vector3(x, y, z);
const PI = Math.PI, SPEED = 2.4, RATE = 1.5, FH = 20;

// ---------- materials & textures ----------
const ALL = new Set(); const track = m => (ALL.add(m), m);
const MK = {};
function M(c, o = {}) {
  const k = [c, o.r, o.m, o.map && o.map.uuid, o.t, o.e].join('|'); if (MK[k]) return MK[k];
  const m = new THREE.MeshStandardMaterial({ color: c, roughness: Math.max(o.r ?? .8, o.t != null ? 0 : .6), metalness: Math.min(o.m ?? 0, .1), map: o.map || null });
  if (o.t != null) { m.transparent = true; m.opacity = o.t; m.depthWrite = false; }
  if (o.e != null) { m.emissive.set(o.e); m.emissiveIntensity = o.ei ?? 1; }
  return MK[k] = track(m);
}
function canvasTex(w, h, draw) {
  const c = document.createElement('canvas'); c.width = w; c.height = h; draw(c.getContext('2d'), w, h);
  const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; t.wrapS = t.wrapT = THREE.RepeatWrapping; t.anisotropy = 8; return t;
}
function makeTex() {
  const R = rng(11);
  const planks = (hue, sat, lig) => canvasTex(512, 512, (x, w, h) => {
    const rows = 8, rh = h / rows;
    for (let r = 0; r < rows; r++) {
      let px = -R() * w * .6;
      while (px < w) { const pw = w * (.45 + R() * .5); x.fillStyle = `hsl(${hue + (R() - .5) * 4},${sat}%,${lig + (R() - .5) * 9}%)`; x.fillRect(px, r * rh, pw, rh); x.fillStyle = 'rgba(40,25,10,.3)'; x.fillRect(px, r * rh, 1.5, rh); px += pw; }
      x.fillStyle = 'rgba(40,25,10,.3)'; x.fillRect(0, r * rh, w, 1.2);
    }
    for (let i = 0; i < 1400; i++) { const y = R() * h, x0 = R() * w; x.strokeStyle = `rgba(70,45,20,${.03 + R() * .07})`; x.lineWidth = .6 + R() * .8; x.beginPath(); x.moveTo(x0, y); x.bezierCurveTo(x0 + 30, y + (R() - .5) * 3, x0 + 60, y + (R() - .5) * 3, x0 + 90 + R() * 80, y + (R() - .5) * 2); x.stroke(); }
  });
  const noise = (base, amt, n, grid) => canvasTex(256, 256, (x, w, h) => {
    x.fillStyle = base; x.fillRect(0, 0, w, h);
    for (let i = 0; i < n; i++) { const v = R() < .5 ? 0 : 255; x.fillStyle = `rgba(${v},${v},${v},${R() * amt})`; x.fillRect(R() * w, R() * h, 1 + R() * 2, 1 + R() * 2); }
    if (grid) { x.strokeStyle = 'rgba(0,0,0,.10)'; x.lineWidth = 2; for (let i = 0; i <= w; i += w / grid) { x.beginPath(); x.moveTo(i, 0); x.lineTo(i, h); x.stroke(); x.beginPath(); x.moveTo(0, i); x.lineTo(w, i); x.stroke(); } }
  });
  const tiles = (base, grout, n) => canvasTex(256, 256, (x, w, h) => {
    x.fillStyle = grout; x.fillRect(0, 0, w, h); const s = w / n;
    for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) { x.fillStyle = base; x.fillRect(i * s + 2, j * s + 2, s - 4, s - 4); const l = (R() - .5); x.fillStyle = l > 0 ? `rgba(255,255,255,${l * .25})` : `rgba(0,0,0,${-l * .12})`; x.fillRect(i * s + 2, j * s + 2, s - 4, s - 4); }
  });
  const grain = (hue, sat, lig) => canvasTex(512, 256, (x, w, h) => {
    x.fillStyle = `hsl(${hue},${sat}%,${lig}%)`; x.fillRect(0, 0, w, h);
    for (let i = 0; i < 600; i++) { const y = R() * h; x.strokeStyle = `rgba(60,35,15,${.03 + R() * .08})`; x.lineWidth = .5 + R() * 1.5; x.beginPath(); x.moveTo(0, y); for (let xx = 0; xx <= w; xx += 32) x.lineTo(xx, y + Math.sin(xx * .02 + i) * 2); x.stroke(); }
  });
  const windows = () => canvasTex(128, 256, (x, w, h) => {
    x.fillStyle = '#000'; x.fillRect(0, 0, w, h);
    for (let j = 6; j < h - 8; j += 16) for (let i = 6; i < w - 6; i += 14) if (R() < .12) { x.fillStyle = R() < .7 ? '#b89a70' : '#8fa0bf'; x.fillRect(i, j, 8, 9); }
  });
  return { oak: planks(33, 38, 60), carpet: noise('#c4c7cb', .22, 9000, 4), tile: tiles('#ebe9e3', '#b9b7b1', 4), deskOak: grain(35, 35, 74), walnut: grain(24, 35, 34), fabric: noise('#e2e2e2', .3, 6000, 0), concrete: noise('#d6d4ce', .22, 7000, 0), windows: windows() };
}
let X = null, TEX = null;
const winMat = new THREE.MeshBasicMaterial({ color: 0xdfe9ee });
const ceilMat = track(new THREE.MeshStandardMaterial({ color: 0xf3efe6, emissive: 0xfff1d6, emissiveIntensity: 1 }));
function initMats() {
  if (X) return; TEX = makeTex();
  X = {
    wall: M(0xece8e1, { r: .92 }), cap: M(0x4a4640), base: M(0x5a5650, { r: .6 }),
    oakF: M(0xffffff, { map: TEX.oak, r: .5 }), carpet: M(0x9aa2ab, { map: TEX.carpet, r: .98 }), tile: M(0xffffff, { map: TEX.tile, r: .3 }), tileB: M(0xdce6e8, { map: TEX.tile, r: .3 }),
    concrete: M(0xffffff, { map: TEX.concrete, r: .92 }), ground: M(0x9a9892, { map: TEX.concrete, r: .95 }), edge: M(0x7c7974, { map: TEX.concrete, r: .9 }),
    deskTop: M(0xffffff, { map: TEX.deskOak, r: .45 }), walnut: M(0xffffff, { map: TEX.walnut, r: .4 }),
    metal: M(0x2b2d31, { r: .35, m: .7 }), alu: M(0xb8bcc0, { r: .3, m: .85 }), chrome: M(0xdadde0, { r: .12, m: 1 }),
    black: M(0x1b1c1f, { r: .35 }), plasticG: M(0x9ea3a8, { r: .5 }), plasticW: M(0xe9e9e6, { r: .45 }),
    fabric: M(0x3b3f47, { map: TEX.fabric, r: .95 }), fabricB: M(0x6e7a8c, { map: TEX.fabric, r: .95 }), fabricW: M(0xb3a996, { map: TEX.fabric, r: .95 }), fabricG: M(0x6f7d6a, { map: TEX.fabric, r: .95 }),
    glass: M(0xcfe0e6, { r: .05, m: .1, t: .18 }), ceramic: M(0xf4f4f1, { r: .2 }), stone: M(0xdcd9d2, { r: .3 }), cabinet: M(0xe9e6df, { r: .5 }),
    terracotta: M(0xb27455, { r: .8 }), potW: M(0xeeebe5, { r: .4 }), soil: M(0x3a2c22, { r: 1 }),
    leaves: [M(0x4f7a45, { r: .7 }), M(0x3f6b3a, { r: .7 }), M(0x6a8f55, { r: .7 })],
    rug: M(0xa06c55, { map: TEX.fabric, r: 1 }), rug2: M(0x5f6c7a, { map: TEX.fabric, r: 1 }), paper: M(0xf7f6f2, { r: .9 }),
    books: [0x7d4b3a, 0x3f5a6e, 0xb49a5c, 0x5d6b4a, 0x8a8f96, 0x6a4a6a, 0xc9c1b0].map(c => M(c, { r: .8 })),
    laminate: M(0xb9c4c7, { r: .5 }), frame: M(0x3a3d42, { r: .4, m: .6 }), shaft: M(0x4a4f56, { r: .6 }),
  };
}

// ---------- geometry helpers ----------
const BOXG = new THREE.BoxGeometry(1, 1, 1), CYLG = new THREE.CylinderGeometry(1, 1, 1, 20), CONEG = new THREE.CylinderGeometry(.45, 1, 1, 16), SPHG = new THREE.SphereGeometry(1, 16, 12), ICOG = new THREE.IcosahedronGeometry(1, 1);
const RBG = {};
const rbg = (w, h, d, r) => { const k = [w, h, d, r].map(v => v.toFixed(3)).join(); return RBG[k] || (RBG[k] = new RoundedBoxGeometry(w, h, d, 3, Math.max(.001, Math.min(r, Math.min(w, h, d) / 2 - .001)))); };
function B(g, x0, x1, y0, y1, z0, z1, m, o = {}) {
  const me = new THREE.Mesh(BOXG, m); me.scale.set(Math.max(.001, x1 - x0), Math.max(.001, y1 - y0), Math.max(.001, z1 - z0));
  me.position.set((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2); me.castShadow = o.cast !== false && Math.max(x1 - x0, y1 - y0, z1 - z0) >= .45; me.receiveShadow = true; g.add(me); return me;
}
function RB(g, w, h, d, x, y, z, m, r = .02, o = {}) {
  const me = new THREE.Mesh(rbg(w, h, d, r), m); me.position.set(x, y, z); if (o.ry) me.rotation.y = o.ry; if (o.rx) me.rotation.x = o.rx; if (o.rz) me.rotation.z = o.rz;
  me.castShadow = o.cast !== false && Math.max(w, h, d) >= .45; me.receiveShadow = true; g.add(me); return me;
}
function Cy(g, r, h, x, y, z, m, o = {}) {
  const me = new THREE.Mesh(o.geo || CYLG, m); me.scale.set(r, h, o.sz ? r * o.sz : r); me.position.set(x, y, z); if (o.rz) me.rotation.z = o.rz; if (o.rx) me.rotation.x = o.rx;
  me.castShadow = o.cast !== false && Math.max(r * 2, h) >= .45; me.receiveShadow = true; g.add(me); return me;
}
const grp = (g, x, y, z, ry = 0) => { const s = new THREE.Group(); s.position.set(x, y, z); s.rotation.y = ry; g.add(s); return s; };
function floorP(g, x0, x1, z0, z1, y, m, tile) {
  const w = x1 - x0, d = z1 - z0, geo = new THREE.PlaneGeometry(w, d); geo.rotateX(-PI / 2);
  const uv = geo.attributes.uv; for (let i = 0; i < uv.count; i++) uv.setXY(i, uv.getX(i) * w / tile, uv.getY(i) * d / tile);
  const me = new THREE.Mesh(geo, m); me.position.set((x0 + x1) / 2, y, (z0 + z1) / 2); me.receiveShadow = true; g.add(me); return me;
}
const S = (x, y, z, face, pose, chain, floor = 0) => ({ pos: V(x, y, z), face, pose, chain: chain.map(([a, b]) => V(a, y, b)), floor });

// ---------- props ----------
let TIER = 1;
const TIERS = {
  0: { desk: () => X.deskTop, chair: () => M(0x3f5a6e, { r: .8 }), cab: () => X.cabinet, mons: [.3], bigMons: [.3], mw: .56 },
  1: { desk: () => X.deskTop, chair: () => X.fabric, cab: () => X.cabinet, mons: [.1], bigMons: [-.28, .36], mw: .62 },
  2: { desk: () => M(0xf1efe9, { r: .5 }), chair: () => M(0x2f3a48, { r: .7 }), cab: () => M(0x3b4048, { r: .6 }), mons: [-.32, .32], bigMons: [-.5, 0, .5], mw: .6 },
  3: { desk: () => X.walnut, chair: () => M(0x1c1e22, { r: .35, m: .1 }), cab: () => X.walnut, mons: [-.44, 0, .44], bigMons: [-.6, 0, .6], mw: .42 },
};
let WCT = null;
function wcSign(g, x, y, z, ry = 0, fx = null) {
  const tex = WCT || (WCT = canvasTex(256, 256, (c, w, h) => { c.fillStyle = '#2c4a6e'; c.fillRect(0, 0, w, h); c.fillStyle = '#ffffff';
    const fig = (cx, skirt) => { c.beginPath(); c.arc(cx, 62, 20, 0, 6.29); c.fill(); if (skirt) { c.beginPath(); c.moveTo(cx, 88); c.lineTo(cx - 34, 172); c.lineTo(cx + 34, 172); c.fill(); c.fillRect(cx - 14, 172, 10, 46); c.fillRect(cx + 4, 172, 10, 46); } else { c.fillRect(cx - 24, 88, 48, 86); c.fillRect(cx - 22, 174, 18, 44); c.fillRect(cx + 4, 174, 18, 44); } };
    fig(70, false); fig(186, true); c.fillRect(126, 36, 5, 186); }));
  const mat = M(0xffffff, { map: tex, r: .9, e: 0xffffff, ei: .3 }); mat.emissiveMap = tex; const back = M(0x1b2b40, { r: .8 });
  const s = grp(g, x, y, z, ry); RB(s, .52, .52, .02, 0, 0, .01, back, .01, { cast: false });
  const p = new THREE.Mesh(PLANEG, mat); p.scale.set(.46, .46, 1); p.position.z = .022; p.userData.noEdge = true; s.add(p);
}
function sofaR(g, x, y, z, ry, len = 2.4, m) { const s = grp(g, x, y, z, ry), d = .9, x0 = -len / 2, x1 = len / 2; m = m || X.fabricB;
  RB(s, len, .22, d, 0, .2, 0, m, .04); RB(s, .16, .55, d, x0 + .08, .36, 0, m, .05); RB(s, .16, .55, d, x1 - .08, .36, 0, m, .05);
  const n = Math.max(2, Math.round((len - .32) / .7)), cw = (len - .32) / n;
  for (let i = 0; i < n; i++) { const cx = x0 + .16 + cw * (i + .5); RB(s, cw - .02, .13, d - .24, cx, .375, .09, m, .05); RB(s, cw - .02, .42, .18, cx, .62, -d / 2 + .13, m, .06, { rx: -.12 }); } }
function pingPong(g, x, y, z, ry) { const s = grp(g, x, y, z, ry), wh = M(0xf4f1ea, { r: .9 }); RB(s, 2.74, .04, 1.525, 0, .74, 0, M(0x2f5f8a, { r: .8 }), .01); B(s, -1.37, 1.37, .761, .764, -.012, .012, wh, { cast: false }); B(s, -.012, .012, .76, .92, -.84, .84, M(0x1b1d22, { r: .9 }), { cast: false }); for (const [a, b] of [[-1.1, -.6], [1.1, -.6], [-1.1, .6], [1.1, .6]]) B(s, a - .04, a + .04, 0, .72, b - .04, b + .04, X.metal); RB(s, .16, .02, .15, -.7, .775, .3, M(0xc0392b, { r: .7 }), .01, { cast: false }); RB(s, .16, .02, .15, .8, .775, -.35, M(0x1b1d22, { r: .7 }), .01, { cast: false }); }
function beanBag(g, x, y, z, c, ry = 0) { const m = M(c, { r: 1 }); const a = new THREE.Mesh(ICOG, m); a.scale.set(.42, .28, .42); a.position.set(x, y + .26, z); a.castShadow = a.receiveShadow = true; g.add(a); const b = new THREE.Mesh(ICOG, m); b.scale.set(.32, .2, .2); b.position.set(x - Math.sin(ry) * .22, y + .5, z - Math.cos(ry) * .22); b.rotation.y = ry; b.castShadow = true; g.add(b); }
function monLayout(n, w, a, gap = .02) {
  if (n === 1) return [[.1, 0, 0]];
  const h = w / 2, cx = (n === 2 ? gap / 2 : h + gap) + h * Math.cos(a), dz = -h * Math.sin(a);
  return n === 2 ? [[-cx, dz, -a], [cx, dz, a]] : [[-cx, dz, -a], [0, 0, 0], [cx, dz, a]];
}
function monitorUnit(s, x, z, ry, kind, w, sm) {
  const mg = grp(s, x, 0, z, ry), nc = { cast: false }, SIL = M(0xc6c9ce, { r: .6 }), BEZ = M(0x111317, { r: .7 });
  const scr = (sw, sh, y, zz) => { const p = new THREE.Mesh(PLANEG, sm); p.scale.set(sw, sh, 1); p.rotation.y = PI; p.position.set(0, y, zz); p.userData.noEdge = true; mg.add(p); };
  if (kind === 1) { RB(mg, .22, .014, .16, 0, .76, .03, X.metal, .006, nc); B(mg, -.02, .02, .76, 1.0, .035, .06, X.metal, nc); RB(mg, w, .36, .03, 0, 1.12, 0, X.black, .01, nc); scr(w - .04, .32, 1.12, -.016); }
  else if (kind === 2) { const h = w * .62, yc = .84 + h / 2; RB(mg, w, h, .024, 0, yc, 0, SIL, .012, nc); B(mg, -w / 2 + .008, w / 2 - .008, yc - h / 2 + h * .2, yc + h / 2 - .008, -.013, -.012, BEZ, nc); scr(w - .04, h * .8 - .04, yc + h * .1, -.0135); RB(mg, .15, .2, .014, 0, .85, .07, SIL, .005, { rx: -.3, cast: false }); RB(mg, .18, .008, .16, 0, .757, .085, SIL, .004, nc); }
  else { const h = w * .6, yc = .84 + h / 2; RB(mg, w, h, .018, 0, yc, 0, SIL, .008, nc); B(mg, -w / 2 + .004, w / 2 - .004, yc - h / 2 + .004, yc + h / 2 - .004, -.0102, -.009, BEZ, nc); scr(w - .03, h - .03, yc, -.0108); RB(mg, .12, .24, .012, 0, .86, .06, SIL, .004, { rx: -.28, cast: false }); RB(mg, .16, .008, .15, 0, .757, .075, SIL, .004, nc); }
}
function confPhone(g, x, y, z) { const s = grp(g, x, y, z, 0); const m = M(0x22252b, { r: .4 }); for (let i = 0; i < 3; i++) { const a = i * PI * 2 / 3; RB(s, .1, .03, .24, Math.sin(a) * .1, .015, Math.cos(a) * .1, m, .01, { ry: a }); } Cy(s, .08, .04, 0, .02, 0, m); Cy(s, .03, .01, 0, .045, 0, M(0x0b0d10, { e: 0x3fd07a, ei: .8 })); }
function armchair(g, x, y, z, face, m) { const s = grp(g, x, y, z, face); m = m || M(0x6b3f2e, { map: TEX.fabric, r: .6 }); RB(s, .74, .18, .7, 0, .38, 0, m, .05); RB(s, .74, .34, .16, 0, .66, -.28, m, .05, { rx: -.1 }); for (const a of [-.32, .32]) RB(s, .1, .28, .66, a, .52, 0, m, .03); RB(s, .72, .3, .7, 0, .16, 0, X.walnut, .03); for (const [a, b] of [[-.3, -.28], [.3, -.28], [-.3, .28], [.3, .28]]) Cy(s, .02, .12, a, .06, b, X.walnut); }
function barCart(g, x, y, z, ry) { const s = grp(g, x, y, z, ry); for (const yy of [.3, .8]) RB(s, .7, .03, .4, 0, yy, 0, M(0x2a2620, { r: .3 }), .01); for (const [a, b] of [[-.33, -.18], [.33, -.18], [-.33, .18], [.33, .18]]) Cy(s, .012, .82, a, .41, b, M(0xc9a15a, { r: .3, m: .7 })); for (const [a, b] of [[-.3, -.18], [.3, -.18], [-.3, .18], [.3, .18]]) Cy(s, .03, .03, a, .015, b, X.black, { rx: PI / 2 }); const amber = M(0xb5651d, { r: .1, t: .8 }), green = M(0x2e5d3a, { r: .1, t: .85 }); Cy(s, .04, .26, -.2, .95, -.08, amber); Cy(s, .045, .3, -.06, .97, .06, green); Cy(s, .035, .22, .08, .93, -.06, amber); for (let i = 0; i < 3; i++) Cy(s, .03, .08, .2 + i * .07, .86, .1 - i * .06, M(0xdfe8ee, { r: .05, t: .5 })); Cy(s, .1, .12, .18, .88, -.1, X.chrome); }
function poolTable(g, x, y, z, ry) { const s = grp(g, x, y, z, ry); RB(s, 2.5, .3, 1.4, 0, .74, 0, X.walnut, .04); B(s, -1.13, 1.13, .89, .9, -.58, .58, M(0x2e6b48, { r: 1 }), { cast: false }); for (const [a, b] of [[-1.13, -.58], [1.13, -.58], [-1.13, .58], [1.13, .58], [0, -.58], [0, .58]]) Cy(s, .06, .011, a, .895, b, X.black, { cast: false }); for (const [a, b] of [[-1.05, -.5], [1.05, -.5], [-1.05, .5], [1.05, .5]]) B(s, a - .12, a + .12, 0, .6, b - .12, b + .12, X.walnut); for (const [a, b, c] of [[.3, .1, 0xf4f1ea], [-.4, -.15, 0xc0392b], [-.5, .1, 0x2c3e50], [.6, -.3, 0xf1c40f]]) { const m = new THREE.Mesh(ICOG, M(c, { r: .2 })); m.scale.setScalar(.04); m.position.set(a, .93, b); s.add(m); } RB(s, 1.4, .02, .02, .3, .92, .45, M(0xd9b382, { r: .6 }), .005, { ry: .1 }); }
function arcade(g, x, y, z, ry, c = 0x2b2f6b) { const s = grp(g, x, y, z, ry); const m = M(c, { r: .5 }); RB(s, .7, 1.75, .8, 0, .875, 0, m, .03); B(s, -.3, .3, 1.15, 1.6, .41, .43, M(0x0b0d14, { e: 0x4dd9ff, ei: .9 }), { cast: false }); RB(s, .68, .22, .3, 0, .95, .32, m, .02, { rx: .3 }); for (const a of [-.15, .15]) Cy(s, .03, .06, a, 1.02, .38, M(0xe63946, { r: .3 })); B(s, -.32, .32, 1.7, 1.85, .2, .44, M(0xf4c542, { e: 0xf4c542, ei: .5 }), { cast: false }); }
function foosball(g, x, y, z, ry) { const s = grp(g, x, y, z, ry); RB(s, 1.4, .3, .8, 0, .78, 0, X.walnut, .03); B(s, -.63, .63, .93, .94, -.33, .33, M(0x3a7d44, { r: 1 }), { cast: false }); for (const [a, b] of [[-.55, -.3], [.55, -.3], [-.55, .3], [.55, .3]]) B(s, a - .05, a + .05, 0, .64, b - .05, b + .05, X.black); for (let i = 0; i < 6; i++) { const xx = -.5 + i * .2; Cy(s, .012, 1.1, xx, 1.0, 0, X.chrome, { rx: PI / 2 }); for (let j = 0; j < 2; j++) RB(s, .05, .12, .04, xx, .98, -.2 + j * .4, M(i % 2 ? 0xc0392b : 0x2c5aa0, { r: .5 }), .01); } }
function credenza(g, x0, x1, y, z0, z1) { RB(g, x1 - x0, .7, z1 - z0, (x0 + x1) / 2, y + .35, (z0 + z1) / 2, X.walnut, .015); const n = Math.round((x1 - x0) / .6); for (let i = 0; i < n; i++) { const a = x0 + (x1 - x0) * (i + .5) / n; B(g, a - .12, a + .12, y + .32, y + .35, z1, z1 + .02, X.chrome, { cast: false }); } }
function artFrame(g, x, y, z, ry, w = 1.0, h = .7, c = 0xc0583f) { const s = grp(g, x, y, z, ry); RB(s, w, h, .04, 0, 0, 0, X.walnut, .008); B(s, -w / 2 + .05, w / 2 - .05, -h / 2 + .05, h / 2 - .05, .02, .025, X.paper, { cast: false }); const R = rng(Math.floor(x * 7 + z * 3)); for (let i = 0; i < 3; i++) { const cw = (.15 + R() * .3) * w, chh = (.15 + R() * .3) * h; B(s, -w / 2 + .1 + R() * (w - .2 - cw), -w / 2 + .1 + R() * (w - .2 - cw) + cw, -h / 2 + .1 + R() * (h - .2 - chh), -h / 2 + .1 + R() * (h - .2 - chh) + chh, .026, .03, M([c, 0x3f6f7a, 0xe2c58f][i], { r: .8 }), { cast: false }); } }
function floorLamp(g, x, y, z) { Cy(g, .14, .03, x, y + .015, z, X.metal); Cy(g, .02, 1.6, x, y + .8, z, X.metal); Cy(g, .22, .26, x, y + 1.68, z, fLampMat, { geo: CONEG }); }
function officeChair(g, x, y, z, face, m) {
  const c = grp(g, x, y, z, face); m = m || X.fabric;
  for (let i = 0; i < 5; i++) {
    const a = i * PI * 2 / 5, leg = new THREE.Mesh(BOXG, X.metal); leg.scale.set(.035, .03, .27); leg.position.set(Math.sin(a) * .13, .07, Math.cos(a) * .13); leg.rotation.y = a; leg.castShadow = true; c.add(leg);
    const cs = new THREE.Mesh(SPHG, X.black); cs.scale.setScalar(.028); cs.position.set(Math.sin(a) * .26, .028, Math.cos(a) * .26); c.add(cs);
  }
  Cy(c, .025, .34, 0, .24, 0, X.chrome);
  RB(c, .5, .08, .48, 0, .46, 0, m, .035);
  RB(c, .46, .52, .06, 0, .82, -.25, m, .03, { rx: -.08 });
  B(c, -.02, .02, .45, .6, -.26, -.22, X.metal);
  for (const sx of [-1, 1]) { B(c, sx * .26 - .015, sx * .26 + .015, .46, .64, -.06, -.03, X.metal); RB(c, .05, .03, .26, sx * .26, .655, .02, X.black, .012); }
  return c;
}
function woodChair(g, x, y, z, face) {
  const c = grp(g, x, y, z, face);
  RB(c, .42, .04, .42, 0, .45, 0, X.walnut, .015); RB(c, .4, .3, .03, 0, .78, -.2, X.walnut, .012, { rx: -.06 });
  for (const [a, b] of [[-.17, -.17], [.17, -.17], [-.17, .17], [.17, .17]]) Cy(c, .016, .45, a, .225, b, X.metal);
  for (const a of [-.17, .17]) Cy(c, .014, .35, a, .62, -.19, X.metal);
}
function plant(g, x, y, z, k = 1, type = 0) {
  const R = rng(Math.floor(x * 131 + z * 71 + y * 7));
  if (type === 1) {
    Cy(g, .16 * k, .3 * k, x, y + .15 * k, z, X.terracotta); Cy(g, .145 * k, .01, x, y + .3 * k, z, X.soil, { cast: false });
    for (let i = 0; i < 9; i++) { const h = (.45 + R() * .4) * k, a = R() * PI * 2; const me = RB(g, .07 * k, h, .014, x + Math.sin(a) * .05, y + .3 * k + h / 2, z + Math.cos(a) * .05, X.leaves[i % 3], .006, { ry: a, rx: (R() - .5) * .3 }); me.rotation.z = (R() - .5) * .3; }
    return;
  }
  if (type === 2) {
    Cy(g, .24 * k, .5 * k, x, y + .25 * k, z, X.potW); Cy(g, .22 * k, .01, x, y + .5 * k, z, X.soil, { cast: false });
    Cy(g, .025 * k, 1.1 * k, x, y + 1.05 * k, z, X.shelf || M(0x6b5140));
    for (let i = 0; i < 8; i++) { const me = new THREE.Mesh(ICOG, X.leaves[i % 3]); const s = (.2 + R() * .14) * k; me.scale.set(s, s * .8, s); me.position.set(x + (R() - .5) * .5 * k, y + (1.35 + R() * .55) * k, z + (R() - .5) * .5 * k); me.castShadow = true; g.add(me); }
    return;
  }
  Cy(g, .22 * k, .42 * k, x, y + .21 * k, z, X.potW); Cy(g, .2 * k, .01, x, y + .42 * k, z, X.soil, { cast: false });
  for (let i = 0; i < 7; i++) { const me = new THREE.Mesh(ICOG, X.leaves[i % 3]); const s = (.16 + R() * .12) * k; me.scale.set(s, s * .85, s); me.position.set(x + (R() - .5) * .34 * k, y + (.6 + R() * .4) * k, z + (R() - .5) * .34 * k); me.castShadow = true; g.add(me); }
}
function sofa(g, x0, x1, z0, z1, y, m) {
  m = m || X.fabricB; const w = x1 - x0, d = z1 - z0, cx = (x0 + x1) / 2, cz = (z0 + z1) / 2;
  RB(g, w, .22, d, cx, y + .2, cz, m, .04);
  RB(g, .16, .55, d, x0 + .08, y + .36, cz, m, .05); RB(g, .16, .55, d, x1 - .08, y + .36, cz, m, .05);
  const n = Math.max(2, Math.round((w - .32) / .7)), cw = (w - .32) / n;
  for (let i = 0; i < n; i++) { const x = x0 + .16 + cw * (i + .5); RB(g, cw - .02, .13, d - .24, x, y + .375, cz + .09, m, .05); RB(g, cw - .02, .42, .18, x, y + .62, z0 + .13, m, .06, { rx: -.12 }); }
  for (const [a, b] of [[x0 + .1, z0 + .1], [x1 - .1, z0 + .1], [x0 + .1, z1 - .1], [x1 - .1, z1 - .1]]) Cy(g, .025, .09, a, y + .045, b, X.metal);
}
function bookshelf(g, x0, x1, y, z0, z1, h) {
  const R = rng(Math.floor(x0 * 97 + y * 13)), m = X.walnut, t = .03;
  B(g, x0, x0 + t, y, y + h, z0, z1, m); B(g, x1 - t, x1, y, y + h, z0, z1, m); B(g, x0, x1, y, y + .06, z0, z1, m); B(g, x0, x1, y + h - t, y + h, z0, z1, m);
  const n = Math.max(2, Math.round(h / .38));
  for (let s = 0; s < n; s++) {
    const sy = y + .06 + s * (h - .09) / n; if (s > 0) B(g, x0, x1, sy - .02, sy, z0, z1, m, { cast: false });
    let bx = x0 + t + .01;
    while (bx < x1 - t - .08) { const bw = .025 + R() * .04; if (R() < .82) { const bh = (.18 + R() * .1) * Math.min(1, (h - .09) / n / .32); B(g, bx, bx + bw, sy, sy + bh, z0 + .03, z1 - .04, X.books[Math.floor(R() * X.books.length)], { cast: false }); } else bx += .06; bx += bw + .003; }
  }
}
// window on a wall plane; group local: plane xy facing +z
let PANES = [];
function windowLocal(g, u0, u1, y0, y1) {
  { const geo = new THREE.PlaneGeometry(u1 - u0, y1 - y0), uv = geo.attributes.uv, pos = geo.attributes.position;
    const pane = new THREE.Mesh(geo, winMat); pane.position.set((u0 + u1) / 2, (y0 + y1) / 2, .015); g.add(pane); PANES.push(pane); }
  const t = .05;
  B(g, u0 - t, u1 + t, y0 - t, y0, 0, .06, X.frame); B(g, u0 - t, u1 + t, y1, y1 + t, 0, .06, X.frame);
  B(g, u0 - t, u0, y0, y1, 0, .06, X.frame); B(g, u1, u1 + t, y0, y1, 0, .06, X.frame);
  const n = Math.max(1, Math.round((u1 - u0) / 1.2)); for (let i = 1; i < n; i++) { const u = u0 + (u1 - u0) * i / n; B(g, u - .02, u + .02, y0, y1, 0, .05, X.frame); }
  B(g, u0 - .08, u1 + .08, y0 - .09, y0 - .04, 0, .16, X.stone);
}
const winBack = (g, x0, x1, y0, y1, z) => windowLocal(grp(g, 0, 0, z), x0, x1, y0, y1);
const winLeft = (g, z0, z1, y0, y1, x) => windowLocal(grp(g, x, 0, 0, PI / 2), -z1, -z0, y0, y1);
function coffeeMachine(g, x, y, z) {
  RB(g, .34, .42, .36, x, y + .21, z, X.black, .03); RB(g, .26, .08, .06, x, y + .34, z + .19, X.chrome, .01);
  B(g, x - .1, x + .1, y, y + .02, z + .05, z + .2, X.chrome); Cy(g, .035, .08, x, y + .06, z + .12, X.ceramic);
}
function kitchenRun(g, x0, x1, y, z0, uppers = true) {
  const n = Math.round((x1 - x0) / .6), w = (x1 - x0) / n, cab = TIERS[TIER].cab(), gapM = M(0x1d1f23, { r: 1 });
  B(g, x0, x1, y + .1, y + .82, z0, z0 + .56, cab);
  for (let i = 0; i < n; i++) { const cx = x0 + w * (i + .5); B(g, cx - w / 2 + .015, cx + w / 2 - .015, y + .13, y + .8, z0 + .56, z0 + .6, cab); B(g, cx - .1, cx + .1, y + .7, y + .715, z0 + .61, z0 + .63, X.chrome, { cast: false }); if (i) B(g, cx - w / 2 - .004, cx - w / 2 + .004, y + .13, y + .8, z0 + .59, z0 + .605, gapM, { cast: false });
    if (uppers) { B(g, cx - w / 2 + .006, cx + w / 2 - .006, y + 1.6, y + 2.3, z0, z0 + .34, cab); B(g, cx - w / 2 + .015, cx + w / 2 - .015, y + 1.63, y + 2.27, z0 + .34, z0 + .375, cab); B(g, cx - .08, cx + .08, y + 1.68, y + 1.695, z0 + .38, z0 + .4, X.chrome, { cast: false }); } }
  B(g, x0, x1, y, y + .1, z0 + .05, z0 + .56, X.black, { cast: false });
  RB(g, x1 - x0 + .02, .04, .64, (x0 + x1) / 2, y + .84, z0 + .32, TIER === 3 ? X.stone : TIER === 2 ? M(0xe8e6e0, { r: .3 }) : X.stone, .01);
  B(g, x0, x1, y + .89, y + 1.58, z0, z0 + .012, X.tile, { cast: false });
}
function sink(g, x, y, z) { B(g, x - .28, x + .28, y + .885, y + .895, z - .2, z + .2, X.chrome, { cast: false }); B(g, x - .25, x + .25, y + .8, y + .886, z - .18, z + .18, X.metal, { cast: false }); Cy(g, .014, .28, x, y + 1.02, z - .24, X.chrome); B(g, x - .012, x + .012, y + 1.15, y + 1.17, z - .25, z - .1, X.chrome); }
function fridge(g, x0, x1, y, z0, z1) { const cx = (x0 + x1) / 2, w = x1 - x0, body = TIER <= 1 ? M(0xe9e7e1, { r: .7 }) : M(0xb9bdc2, { r: .7 });
  RB(g, w, 1.9, z1 - z0, cx, y + 1.0, (z0 + z1) / 2, body, .03); B(g, x0, x1, y, y + .1, z0 + .05, z1 - .05, X.black, { cast: false });
  B(g, x0 + .02, x1 - .02, y + .12, y + 1.28, z1, z1 + .02, body); B(g, x0 + .02, x1 - .02, y + 1.32, y + 1.88, z1, z1 + .02, body); B(g, x0 + .02, x1 - .02, y + 1.28, y + 1.32, z1 - .01, z1 + .01, M(0x1d1f23, { r: 1 }), { cast: false });
  B(g, x0 + .08, x0 + .11, y + .55, y + 1.2, z1 + .02, z1 + .06, X.chrome); B(g, x0 + .08, x0 + .11, y + 1.4, y + 1.8, z1 + .02, z1 + .06, X.chrome);
 }
function toilet(g, x, y, z) { Cy(g, .19, .38, x, y + .19, z + .05, X.ceramic, { sz: 1.25 }); Cy(g, .2, .03, x, y + .395, z + .05, X.plasticW, { sz: 1.25 }); RB(g, .38, .38, .17, x, y + .58, z - .2, X.ceramic, .03); }
function tv(g, x, y, z, w = 1.6) { RB(g, w, w * .57, .05, x, y, z, X.black, .01); const s = new THREE.Mesh(BOXG, M(0x0e1116, { r: .2, e: 0x2a3b55, ei: .5 })); s.scale.set(w - .06, w * .57 - .06, .005); s.position.set(x, y, z + .026); g.add(s); }
function printer(g, x, y, z) { RB(g, .6, .55, .5, x, y + .275, z, X.plasticW, .03); RB(g, .5, .08, .1, x, y + .45, z + .25, X.plasticG, .02); B(g, x - .2, x + .2, y + .56, y + .57, z - .12, z + .12, X.paper); }
function waterCooler(g, x, y, z) { RB(g, .32, .95, .32, x, y + .475, z, X.plasticW, .03); Cy(g, .13, .4, x, y + 1.15, z, M(0xa9cfe6, { r: .05, t: .6 })); }
function pendant(g, cx, yc, len, z = 2.3) {
  for (const dx of [-len / 2 + .1, len / 2 - .1]) Cy(g, .004, .5, cx + dx, yc - .25, z, X.metal, { cast: false });
  RB(g, len, .05, .16, cx, yc - .52, z, X.metal, .02, { cast: false }); B(g, cx - len / 2 + .03, cx + len / 2 - .03, yc - .552, yc - .545, z - .06, z + .06, ceilMat, { cast: false });
}
function station(g, x, y, z, face, big, seed) {
  const s = grp(g, x, y, z, face), R = rng(seed * 31 + 7);
  const T = TIERS[TIER]; officeChair(s, 0, 0, -.02, 0, big ? M(0x2a211b, { map: TEX.fabric, r: .6 }) : T.chair());
  const w = big ? 2.0 : 1.4, z0 = .42, z1 = big ? 1.25 : 1.05, zc = (z0 + z1) / 2, d = z1 - z0;
  RB(s, w, .035, d, 0, .735, zc, big ? X.walnut : T.desk(), .012);
  for (const sx of [-1, 1]) { const lx = sx * (w / 2 - .1); B(s, lx - .03, lx + .03, 0, .72, zc - .03, zc + .03, X.metal); B(s, lx - .03, lx + .03, 0, .03, z0 + .04, z1 - .04, X.metal); B(s, lx - .025, lx + .025, .69, .72, z0 + .05, z1 - .05, X.metal); }
  B(s, -w / 2 + .1, w / 2 - .1, .66, .7, zc - .02, zc + .02, X.metal);
  const screenMat = track(new THREE.MeshStandardMaterial({ color: 0x0d1016, emissive: 0x9cc6ff, emissiveIntensity: 0, roughness: .7 }));
  const lampMat = track(new THREE.MeshStandardMaterial({ color: 0xfff2dc, emissive: 0xffb25e, emissiveIntensity: 0, roughness: .5 }));
  const [mn, mw, ma] = TIER === 0 ? [1, .56, 0] : TIER === 1 ? (big ? [2, .6, .12] : [1, .62, 0]) : TIER === 2 ? (big ? [2, .72, .14] : [2, .58, .14]) : (big ? [3, .6, .42] : [3, .46, .42]);
  const zm = z1 - .17, lay = TIER === 0 ? [[.3, 0, 0]] : monLayout(mn, mw, ma), nc = { cast: false };
  lay.forEach(([mx, dz, ry]) => monitorUnit(s, mx, zm + dz, ry, TIER || 1, mw, screenMat));
  if (TIER === 0) { RB(s, .34, .016, .24, -.33, .752, z0 + .3, X.alu || X.metal, .006, nc); const lp = grp(s, -.33, .76, z0 + .42); lp.rotation.x = -.28; RB(lp, .34, .23, .012, 0, .115, 0, X.alu || X.metal, .006, nc);
    const sp = new THREE.Mesh(PLANEG, screenMat); sp.scale.set(.31, .2, 1); sp.rotation.y = PI; sp.position.set(0, .115, -.007); sp.userData.noEdge = true; lp.add(sp); }
  RB(s, .42, .016, .13, .06, .76, z0 + .16, X.plasticG, .006, nc); RB(s, .06, .025, .1, .36, .763, z0 + .18, X.plasticG, .012, nc);
  if (R() < .7) Cy(s, .04, .1, -w / 2 + .42, .8, z0 + .2, R() < .5 ? X.ceramic : M(0x3f5a6e, { r: .7 }), nc);
  if (R() < .6) RB(s, .21, .006, .297, -.28, .756, z0 + .3, X.paper, .001, { ry: (R() - .5) * .5, cast: false });
  if (big) { RB(s, .25, .03, .33, .75, .768, z0 + .22, M(0x5b2f26, { r: .6 }), .005, { ry: .2, cast: false }); plant(s, .9, .75, z1 - .12, .4, 1); }
  const lx = TIER === 0 ? w / 2 - .07 : TIER === 1 ? -w / 2 + .16 : -w / 2 + .08, lz = TIER <= 1 ? z1 - .1 : z1 - .05, la = TIER <= 1 ? .18 : .13;
  Cy(s, .07, .02, lx, .763, lz, X.metal, nc); B(s, lx - .012, lx + .012, .77, 1.12, lz - .012, lz + .012, X.metal, nc); B(s, lx - .01, lx + .01, 1.11, 1.13, lz - la, lz, X.metal, nc);
  Cy(s, .1, .1, lx, 1.08, lz - la, lampMat, { geo: CONEG, cast: false });
  s.updateMatrixWorld(true);
  const mid = lay[Math.floor(lay.length / 2)];
  return { screenMat, lampMat, lampPos: s.localToWorld(V(lx, .98, lz - la - .04)), screenPos: s.localToWorld(V(mid[0], 1.05, zm - .45)) };
}

const PLANEG = new THREE.PlaneGeometry(1, 1);
const groundMat = new THREE.MeshBasicMaterial({ color: 0xa7b38f }), walkMat = new THREE.MeshBasicMaterial({ color: 0xd8ccb6 });
const G_DAY = new THREE.Color(0xa7b38f), G_NIGHT = new THREE.Color(0x151a36), W_DAY = new THREE.Color(0xd8ccb6), W_NIGHT = new THREE.Color(0x232848);
const glowTex = canvasTex(128, 128, (x, w, h) => { const g = x.createRadialGradient(64, 64, 0, 64, 64, 64); g.addColorStop(0, 'rgba(255,214,160,0.9)'); g.addColorStop(.45, 'rgba(255,190,130,0.35)'); g.addColorStop(1, 'rgba(255,170,110,0)'); x.fillStyle = g; x.fillRect(0, 0, w, h); });
const glowMat = new THREE.MeshBasicMaterial({ map: glowTex, transparent: true, depthWrite: false, blending: THREE.AdditiveBlending, toneMapped: false, opacity: 0 });
const sconceMat = track(new THREE.MeshStandardMaterial({ color: 0xf3e6cf, emissive: 0xffc88a, emissiveIntensity: 0 }));
function sconce(list, g, x, y, z, ry = 0) {
  const s = grp(g, x, y, z, ry);
  RB(s, .24, .14, .08, 0, 0, .04, sconceMat, .02); B(s, -.03, .03, -.1, -.07, 0, .03, X.metal);
  const p = new THREE.Mesh(PLANEG, glowMat); p.scale.set(1.7, 2.3, 1); p.position.set(0, -.15, .012); p.renderOrder = 2; s.add(p);
  list.push(s); return s;
}

// ---------- Layout A ----------
function buildA(big) {
  const g = new THREE.Group(), D = 15, nIs = big ? 5 : 2, fx = 3 + nIs * 4.6 + 1.4, W = Math.max(20, Math.ceil(fx + 4));
  const TH = 2.8, LOW = 1.05, EXT = .45, nc = { cast: false };
  floorP(g, -60, W + 60, -60, D + 300, -.3, groundMat, 4).userData.noEdge = true;
  hazeMats.length = 0;
  B(g, -.25, W + .25, -.3, 0, -.25, D + .25, X.edge, nc);
  floorP(g, 0, W, 8.2, D, .005, X.carpet, 2);
  floorP(g, 0, W, 6, 8.2, .006, X.oakF, 2.4); floorP(g, 0, 8, 0, 6, .006, X.oakF, 2.4);
  floorP(g, 8, 15, 0, 6, .006, X.tile, 1.2); floorP(g, 15, 20, 0, 6, .006, X.tileB, 1.2);
  if (W > 20) floorP(g, 20, W, 0, 6, .006, X.oakF, 2.4);
  const segs = (a0, a1, gaps) => { const out = []; let cur = a0; for (const [a, b] of gaps) { out.push([cur, a]); cur = b; } out.push([cur, a1]); return out.filter(([a, b]) => b - a > .01); };
  const wallX = (z, x0, x1, h, gaps = [], t = .18) => { for (const [a, b] of segs(x0, x1, gaps)) { B(g, a, b, 0, h, z - t / 2, z + t / 2, X.wall); B(g, a, b, h, h + .03, z - t / 2, z + t / 2, X.cap, nc); B(g, a, b, 0, .08, z - t / 2 - .012, z + t / 2 + .012, X.base, nc); } };
  const wallZ = (x, z0, z1, h, gaps = [], t = .18) => { for (const [a, b] of segs(z0, z1, gaps)) { B(g, x - t / 2, x + t / 2, 0, h, a, b, X.wall); B(g, x - t / 2, x + t / 2, h, h + .03, a, b, X.cap, nc); B(g, x - t / 2 - .012, x + t / 2 + .012, 0, .08, a, b, X.base, nc); } };
  const glassX = (z, x0, x1, h, gaps = []) => { for (const [a, b] of segs(x0, x1, gaps)) { B(g, a, b, .05, h, z - .012, z + .012, X.glass, nc); B(g, a, b, 0, .05, z - .03, z + .03, X.frame); B(g, a, b, h, h + .05, z - .03, z + .03, X.frame); const n = Math.max(1, Math.round((b - a) / 1.2)); for (let i = 0; i <= n; i++) { const x = a + (b - a) * i / n; B(g, x - .025, x + .025, 0, h, z - .03, z + .03, X.frame); } } };
  const glassZ = (x, z0, z1, h) => { B(g, x - .012, x + .012, .05, h, z0, z1, X.glass, nc); B(g, x - .03, x + .03, 0, .05, z0, z1, X.frame); B(g, x - .03, x + .03, h, h + .05, z0, z1, X.frame); const n = Math.max(1, Math.round((z1 - z0) / 1.2)); for (let i = 0; i <= n; i++) { const z = z0 + (z1 - z0) * i / n; B(g, x - .03, x + .03, 0, h, z - .025, z + .025, X.frame); } };
  wallX(0, -.09, W + .09, TH); wallZ(0, 0, D, TH);
  wallX(D, -.09, W + .09, EXT); wallZ(W, 0, D, EXT);
  const core = M(0x5a6275, { r: .6 }); B(g, .09, 1.35, 0, 2.8, 6.02, 8.18, core); B(g, .09, 1.37, 2.8, 2.84, 6.0, 8.2, X.cap, nc);
  B(g, 1.35, 1.36, .01, 2.25, 6.45, 7.75, X.black, nc);
  B(g, 1.35, 1.43, 0, 2.35, 6.33, 6.45, X.frame); B(g, 1.35, 1.43, 0, 2.35, 7.75, 7.87, X.frame); B(g, 1.35, 1.43, 2.25, 2.37, 6.33, 7.87, X.frame);
  const elL = B(g, 1.37, 1.39, .01, 2.25, 6.45, 7.1, X.alu), elR = B(g, 1.37, 1.39, .01, 2.25, 7.1, 7.75, X.alu);
  B(g, 1.36, 1.44, 2.46, 2.56, 6.92, 7.28, M(0x9fd3ff, { e: 0x9fd3ff, ei: 1.2 }), nc);
  floorP(g, 1.4, 3.2, 6.25, 7.95, .012, X.rug2, 1.5); plant(g, 1.75, 0, 8.55, .8, 1);
  glassX(6, 0, 8, 2.4, [[3.4, 4.6]]); glassZ(8, 0, 6, 2.4);
  wallX(6, 8, 20, LOW, [[9.9, 11.1], [16.9, 18.1]]); wallZ(15, 0, 6, LOW); if (W > 20) wallZ(20, 0, 6, LOW);
  winLeft(g, 1, 5, .9, 2.3, .09); winLeft(g, 9, 14, .9, 2.3, .09); winBack(g, 15.8, 19.2, 1.8, 2.4, .09);
  for (let x = 21; x < W - 2.2; x += 3.2) winBack(g, x, x + 2.4, 1, 2.3, .09);
  B(g, -1.3, 0, 0, .015, 6.3, 7.7, M(0x3d4045, { map: TEX.fabric, r: 1 }), nc);
  B(g, .06, .96, 0, 2.25, 7.74, 7.8, X.walnut); Cy(g, .02, .02, .85, 1.05, 7.72, X.chrome, { rx: PI / 2 });
  Cy(g, .02, 1.75, .45, .875, 5.5, X.metal); Cy(g, .2, .02, .45, .01, 5.5, X.metal); for (let i = 0; i < 4; i++) Cy(g, .012, .16, .45 + Math.sin(i * PI / 2) * .08, 1.68, 5.5 + Math.cos(i * PI / 2) * .08, X.metal, { rz: Math.sin(i * PI / 2) * .8, rx: Math.cos(i * PI / 2) * .8 });
  // meeting
  RB(g, 4.2, .05, 1.3, 4, .74, 3, X.walnut, .02); for (const lx of [2.8, 5.2]) B(g, lx - .04, lx + .04, 0, .72, 2.6, 3.4, X.metal);
  const meet = [];
  [2.7, 4, 5.3].forEach(x => meet.push(S(x, 0, 1.7, 0, 'sit', [[x, 1.0], [1.2, 1.0], [1.2, 5.2], [4, 5.2], [4, 7]])));
  [2.7, 4, 5.3].forEach(x => meet.push(S(x, 0, 4.3, PI, 'sit', [[x, 5.2], [4, 5.2], [4, 7]])));
  meet.forEach(s => officeChair(g, s.pos.x, 0, s.pos.z, s.face, X.fabricW));
  B(g, 2.4, 5.6, 0, .5, .1, .5, X.walnut); tv(g, 4, 1.45, .13); plant(g, 7.3, 0, .7, 1, 2); plant(g, .7, 0, .7, .9, 1);
  // kitchen
  kitchenRun(g, 8.2, 12.8, 0, .1); coffeeMachine(g, 9.2, .89, .38); sink(g, 11.9, 0, .45);
  for (let i = 0; i < 3; i++) Cy(g, .038, .09, 9.75 + i * .12, .935, .5, X.ceramic);
  fridge(g, 13.15, 14.05, 0, .1, .85);
  Cy(g, .55, .035, 13.6, .745, 3.6, X.deskTop); Cy(g, .05, .7, 13.6, .37, 3.6, X.metal); Cy(g, .3, .025, 13.6, .012, 3.6, X.metal);
  const cof = [9.2, 10.1, 11.0, 11.9].map(x => S(x, 0, 1.45, PI, 'stand', [[10.5, 5.3], [10.5, 7]]));
  const eat = [S(12.85, 0, 3.6, PI / 2, 'sit', [[12.85, 5.0], [10.5, 5.3], [10.5, 7]]), S(14.35, 0, 3.6, -PI / 2, 'sit', [[14.35, 5.0], [10.5, 5.3], [10.5, 7]]),
    S(9.2, 0, 3.72, 0, 'sit', [[10.5, 5.3], [10.5, 7]]), S(9.2, 0, 5.08, PI, 'sit', [[10.5, 5.3], [10.5, 7]])];
  RB(g, .9, .04, .72, 9.2, .74, 4.4, X.deskTop, .015); for (const [a, b] of [[8.82, 4.1], [9.58, 4.1], [8.82, 4.7], [9.58, 4.7]]) Cy(g, .02, .72, a, .36, b, X.metal);
  eat.forEach(s => woodChair(g, s.pos.x, 0, s.pos.z, s.face)); plant(g, 14.4, 0, 5.4, .8, 0);
  // toilet
  B(g, 17.46, 17.54, .12, 1.6, 0, 2.6, X.laminate);
  for (const [a, b] of segs(15, 20, [[15.7, 16.8], [18.2, 19.3]])) B(g, a, b, .12, 1.6, 2.56, 2.64, X.laminate);
  toilet(g, 16.25, 0, .4); toilet(g, 18.75, 0, .4);
  RB(g, .6, .85, 1.0, 19.55, .425, 3.9, X.cabinet, .02); RB(g, .45, .05, .5, 19.55, .87, 3.9, X.ceramic, .02); Cy(g, .012, .2, 19.75, .98, 3.9, X.chrome);
  const wcs = [16.25, 18.75].map(x => S(x, 0, 1.3, 0, 'stand', [[x, 3.4], [17.5, 4.9], [17.5, 7]]));
  // open office
  const desks = [], st = { desk: [] };
  for (let k = 0; k < nIs; k++) {
    const cx = 3 + k * 4.6;
    const seats = [[cx - .7, 9.9, 0, [[cx - .7, 7]]], [cx + .7, 9.9, 0, [[cx + .7, 7]]], [cx - .7, 12.1, PI, [[cx - .7, 13.2], [cx - 2.3, 13.2], [cx - 2.3, 7]]], [cx + .7, 12.1, PI, [[cx + .7, 13.2], [cx + 2.3, 13.2], [cx + 2.3, 7]]]];
    for (const [x, z, f, ch] of seats) { desks.push(S(x, 0, z, f, 'sit', ch)); st.desk.push(station(g, x, 0, z, f, false, desks.length)); }
    B(g, cx - 1.3, cx + 1.3, .74, 1.12, 10.99, 11.01, M(0xc9cfd3, { map: TEX.fabric, r: .9 }), nc);
  }
  const fs = S(fx, 0, 10.0, 0, 'sit', [[fx, 7]]);
  floorP(g, fx - 2, fx + 2, 8.9, 12.8, .012, X.rug, 1.5);
  st.founder = station(g, fx, 0, 10, 0, true, 99);
  plant(g, fx + 2.2, 0, 9.4, 1, 2); plant(g, fx - 1.8, 0, 12.4, 1.1, 0);
  B(g, fx + .5, fx + 2.0, 0, .6, 12.1, 12.55, X.walnut);
  waterCooler(g, W - .6, 0, 8.9); printer(g, W - .7, 0, 11.4); plant(g, .8, 0, 14.2, 1, 1); plant(g, W - .7, 0, 14.2, 1, 0);
  if (W > 20) { sofa(g, 21.8, 24.8, .3, 1.2, 0); sofa(g, 26.3, 29.3, .3, 1.2, 0, X.fabricG); RB(g, 1.2, .04, .6, 23.3, .4, 2.3, X.walnut, .02); RB(g, 1.2, .04, .6, 27.8, .4, 2.3, X.walnut, .02); floorP(g, 21.5, 30, .2, 3.3, .012, X.rug2, 1.5); plant(g, W - .7, 0, .7, 1, 2); plant(g, 20.7, 0, .7, .9, 1); bookshelf(g, 25, 26.1, 0, .1, .45, 1.8); }
  const sc = [];
  sconce(sc, g, 1.6, 2.2, .1); sconce(sc, g, 6.4, 2.2, .1);
  for (let x = 23.8; x < W - 2; x += 3.2) sconce(sc, g, x, 2.2, .1);
  sconce(sc, g, .1, 2.55, 3, PI / 2); sconce(sc, g, .1, 2.2, 8.4, PI / 2); sconce(sc, g, .1, 2.2, 14.5, PI / 2); sconce(sc, g, .1, 2.55, 11.5, PI / 2);
  const out = S(-2.2, 0, 7, PI / 2, 'out', [[-.3, 7]]);
  return {
    sconces: sc,
    g, bounds: new THREE.Box3(V(-1, 0, 0), V(W, 2.8, D)), sunOff: V(16, 30, 22), fog: false,
    spot(p, s) { switch (s.k) { case 'desk': return p.id === 0 ? fs : desks[p.id - 1]; case 'meet': return meet[s.i % 6]; case 'eat': return eat[s.i % 2]; case 'coffee': return cof[s.i % 4]; case 'wc': return wcs[s.i % 2]; default: return out; } },
    station: p => p.id === 0 ? st.founder : st.desk[p.id - 1], stations: [...st.desk, st.founder], connector: () => [], sky: [],
  };
}

// ---------- art direction ----------
let BWALL = null;
const BW = () => BWALL || (BWALL = Object.fromEntries(Object.entries({ lobby: 0xdcd6cc, office: 0xe6e2da, meet: 0xd3d9de, kitchen: 0xe6dccb, wc: 0xd6e0e0, coffee: 0xe6dccb, boss: 0x5b6570, lounge: 0xd8dcd2 }).map(([k, c]) => [k, track(new THREE.MeshStandardMaterial({ color: c, roughness: .92 }))])));
export const ART = {
  real: { label: 'Gerçekçi', g: { sat: 1, con: 1, lift: [0, 0, 0], gain: [1, 1, 1], sh: [1, 1, 1], hi: [1, 1, 1], vig: 0, grain: 0, tilt: 0 }, exp: 1, bloom: 1, day: 0xcfd6db, dusk: 0xd9ae90, night: 0x10131a, sun: 0xfff4e6, low: 0xffc890, sunY: 1, wall: 0xece8e1, carpet: 0x9aa2ab, motes: 0,
    bw: { lobby: 0xdcd6cc, office: 0xe6e2da, meet: 0xd3d9de, kitchen: 0xe6dccb, wc: 0xd6e0e0, coffee: 0xe6dccb, boss: 0x5b6570, lounge: 0xd8dcd2 } },
  golden: { label: 'Altın saat', g: { sat: 1.12, con: 1.1, lift: [.025, .012, .035], gain: [1.05, 1.0, .93], sh: [.9, .97, 1.1], hi: [1.1, 1.0, .88], vig: .5, grain: .035, tilt: 0 }, exp: 1.05, bloom: 1.6, day: 0xe6c7a2, dusk: 0xe3956a, night: 0x1a1422, sun: 0xffc284, low: 0xff9a5a, sunY: .55, wall: 0xf1e3cc, carpet: 0xa28f80, motes: 1,
    bw: { lobby: 0xecd9c0, office: 0xf0e2cb, meet: 0xe2d5c4, kitchen: 0xf2d9b2, wc: 0xe3dccf, coffee: 0xf2d9b2, boss: 0x6a4a3a, lounge: 0xe9d8bd } },
  pastel: { label: 'Pastel diorama', g: { sat: 1.22, con: .9, lift: [.06, .055, .08], gain: [1, 1, 1], sh: [1, .98, 1.05], hi: [1.03, 1, .97], vig: .2, grain: .012, tilt: 7 }, exp: 1.12, bloom: 1.1, day: 0xbfdde6, dusk: 0xf2c1c8, night: 0x2a2745, sun: 0xfff2e4, low: 0xffc6b0, sunY: .9, wall: 0xf6eee8, carpet: 0xb4c9cb, motes: 0,
    bw: { lobby: 0xf3d9c9, office: 0xdbe9e0, meet: 0xd8dff2, kitchen: 0xf6e4b8, wc: 0xcfe8eb, coffee: 0xf6e4b8, boss: 0xecc8c8, lounge: 0xe1eacf } },
  lofi: { label: 'Lo-fi gece', g: { sat: .8, con: 1.16, lift: [.035, .02, .075], gain: [1, .96, 1.03], sh: [.88, .9, 1.18], hi: [1.12, 1.0, .86], vig: .6, grain: .07, tilt: 0 }, exp: .95, bloom: 2.2, day: 0x98a1b6, dusk: 0xa47a8c, night: 0x0b0c18, sun: 0xdcd6ff, low: 0xc98aa8, sunY: .7, wall: 0xd6d1d2, carpet: 0x696c82, motes: .6,
    bw: { lobby: 0xc9c3cf, office: 0xd2cfd6, meet: 0xbcc3d6, kitchen: 0xd6c9c0, wc: 0xc3d0d3, coffee: 0xd6c9c0, boss: 0x3e3a52, lounge: 0xc6ccc2 } },
};
const GradeShader = {
  uniforms: { tDiffuse: { value: null }, uRes: { value: new THREE.Vector2(1, 1) }, uTime: { value: 0 }, uSat: { value: 1 }, uCon: { value: 1 }, uVig: { value: 0 }, uGrain: { value: 0 }, uTilt: { value: 0 },
    uLift: { value: new THREE.Vector3() }, uGain: { value: new THREE.Vector3(1, 1, 1) }, uSh: { value: new THREE.Vector3(1, 1, 1) }, uHi: { value: new THREE.Vector3(1, 1, 1) } },
  vertexShader: 'varying vec2 vUv; void main(){ vUv=uv; gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0); }',
  fragmentShader: `uniform sampler2D tDiffuse; uniform vec2 uRes; uniform float uTime,uSat,uCon,uVig,uGrain,uTilt; uniform vec3 uLift,uGain,uSh,uHi; varying vec2 vUv;
  float rand(vec2 c){ return fract(sin(dot(c,vec2(12.9898,78.233)))*43758.5453); }
  void main(){
    vec3 c = texture2D(tDiffuse, vUv).rgb;
    if (uTilt > 0.0) { float r = smoothstep(.16, .5, abs(vUv.y - .52)) * uTilt; vec3 acc = c; for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float rr = sqrt(float(i + 1) / 16.0) * r; acc += texture2D(tDiffuse, vUv + vec2(cos(a), sin(a)) * rr / uRes).rgb; } c = acc / 17.0; }
    float l = dot(c, vec3(.2126, .7152, .0722));
    c = mix(c * uSh, c * uHi, smoothstep(0.0, 1.0, l));
    c = mix(vec3(l), c, uSat);
    c = (c - .5) * uCon + .5;
    c = c * uGain + uLift * (1.0 - c);
    vec2 q = vUv - .5; c *= 1.0 - uVig * dot(q, q) * 2.0;
    c += (rand(vUv * uRes + fract(uTime)) - .5) * uGrain;
    gl_FragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
  }`,
};

// ---------- ink / ligne-claire direction ----------
Object.assign(ROLES.dev, { color: 0x4f7fd1 }); Object.assign(ROLES.pm, { color: 0x5fae6e }); Object.assign(ROLES.des, { color: 0xc768a8 });
Object.assign(ROLES.sales, { color: 0xe58a3a }); Object.assign(ROLES.qa, { color: 0x3fb3b0 }); Object.assign(ROLES.founder, { color: 0xf4c430 });
ART.ink = { label: 'Mürekkep', g: { sat: 1.08, con: 1.05, lift: [0, 0, 0], gain: [1, 1, 1], sh: [.96, .97, 1.05], hi: [1.03, 1, .97], vig: .22, grain: 0, tilt: 0 }, exp: 1.0, bloom: 1.2, day: 0xcfd6db, dusk: 0xd9ae90, night: 0x10131a, sun: 0xfff4e6, low: 0xffc890, sunY: 1, wall: 0xf1e6d2, carpet: 0x86a3a2, motes: 0,
  bw: { lobby: 0xe9d9bf, office: 0xf1e6d2, meet: 0xc9dcd6, kitchen: 0xf2d49b, wc: 0xcfe3df, coffee: 0xf2d49b, boss: 0x3f4a5c, lounge: 0xe7c9b3 } };
const PAL = { wall: 0xf1e6d2, cap: 0x2b2a35, base: 0x3d3a48, oakF: 0xd9a877, carpet: 0x86a3a2, tile: 0xece5d6, tileB: 0xcfe3df, concrete: 0xd8ccb6, ground: 0xa7b38f, edge: 0x8b7e70, deskTop: 0xe8cfa4, walnut: 0x7a4b36, metal: 0x3b3f4c, alu: 0xbcc2c9, chrome: 0xe3e6ea, black: 0x262633, plasticG: 0x9aa0ab, plasticW: 0xf2efe8, fabric: 0x3c4a63, fabricB: 0xd98c5f, fabricW: 0xe2c58f, fabricG: 0x6f9a7a, glass: 0x9fd3d0, ceramic: 0xfbf8f2, stone: 0xefe9dd, cabinet: 0xf4ede0, terracotta: 0xc8744f, potW: 0xf6f1e7, soil: 0x4a3426, rug: 0xc0583f, rug2: 0x3f6f7a, paper: 0xfffdf6, laminate: 0x9fc4c0, frame: 0x34384a, shaft: 0x4a4f66 };
function applyPalette() {
  for (const k in PAL) if (X[k]) { X[k].color.set(PAL[k]); X[k].map = null; X[k].needsUpdate = true; }
  [0x4d8a57, 0x2f6b4f, 0x88b35a].forEach((c, i) => X.leaves[i].color.set(c));
  [0xc0583f, 0x3f6f7a, 0xe2b04a, 0x5d7f4a, 0x34384a, 0x9a5a8a, 0xefe2c8].forEach((c, i) => X.books[i] && X.books[i].color.set(c));
}
const GRAD = (() => { const t = new THREE.DataTexture(new Uint8Array([95, 175, 255]), 3, 1, THREE.RedFormat); t.minFilter = t.magFilter = THREE.NearestFilter; t.needsUpdate = true; return t; })();
const TOON = new WeakMap(), SYNC = new Map();
function toToon(m) {
  if (!m || !m.isMeshStandardMaterial) return m;
  let t = TOON.get(m);
  if (!t) { t = new THREE.MeshToonMaterial({ color: m.color.clone(), gradientMap: GRAD, emissive: m.emissive.clone(), emissiveIntensity: m.emissiveIntensity, emissiveMap: m.emissiveMap || null, map: m.map || null, transparent: m.transparent, opacity: m.opacity, depthWrite: m.depthWrite, side: m.side }); TOON.set(m, t); }
  if (m.emissive.getHex() !== 0 || m.emissiveMap) SYNC.set(t, m);
  return t;
}
function toonify(root, noEdge) {
  root.traverse(o => {
    if (o.isSprite || o.isPoints) { noEdge.push(o); return; }
    if (!o.isMesh) return;
    o.material = toToon(o.material);
    if (o.material.transparent || o.userData.noEdge) noEdge.push(o);
  });
}
const CS = [
  [420, { top: 0x6f8fc7, bot: 0xf6c7a8, sun: 0xffb38a, si: .9, hs: 0x8aa0d8, hg: 0xc9a18a, hi: .9, win: 0xf7d2b8 }],
  [540, { top: 0x8cc3e8, bot: 0xf3e7d3, sun: 0xfff0d8, si: 2.1, hs: 0x9fc0e6, hg: 0xd8c3a5, hi: 1.0, win: 0xe9f3f6 }],
  [780, { top: 0x79b8e6, bot: 0xe8f1ef, sun: 0xffffff, si: 2.4, hs: 0xa9cbe8, hg: 0xd6c9b0, hi: 1.05, win: 0xf0f6f7 }],
  [1050, { top: 0x7a9fd6, bot: 0xffc98f, sun: 0xffb46a, si: 2.3, hs: 0x9aa6d8, hg: 0xe0a47c, hi: .95, win: 0xffd9a8 }],
  [1150, { top: 0x4f5aa8, bot: 0xff8f6b, sun: 0xff7a4d, si: 1.1, hs: 0x7f78b8, hg: 0xc98a78, hi: .8, win: 0xff9e7a }],
  [1200, { top: 0x1f2a5c, bot: 0x6a5a9a, sun: 0x9fb4ff, si: .35, hs: 0x5a6ad0, hg: 0x4a3f7a, hi: 1.0, win: 0x3a4a86 }],
  [1320, { top: 0x0c1026, bot: 0x26306a, sun: 0x8fa6ff, si: .45, hs: 0x4656c0, hg: 0x362c66, hi: .9, win: 0x1f2a5e }],
  [1440, { top: 0x0c1026, bot: 0x26306a, sun: 0x8fa6ff, si: .45, hs: 0x4656c0, hg: 0x362c66, hi: .9, win: 0x1f2a5e }],
].map(([t, o]) => [t, Object.fromEntries(Object.entries(o).map(([k, v]) => [k, typeof v === 'number' && k !== 'si' && k !== 'hi' ? new THREE.Color(v) : v]))]);
const CSV = { top: new THREE.Color(), bot: new THREE.Color(), sun: new THREE.Color(), hs: new THREE.Color(), hg: new THREE.Color(), win: new THREE.Color(), si: 0, hi: 0 };
function csAt(t) {
  let i = 0; while (i < CS.length - 2 && CS[i + 1][0] <= t) i++;
  const [t0, a] = CS[i], [t1, b] = CS[i + 1], k = sm(0, 1, (t - t0) / (t1 - t0));
  for (const c of ['top', 'bot', 'sun', 'hs', 'hg', 'win']) CSV[c].lerpColors(a[c], b[c], k);
  CSV.si = a.si + (b.si - a.si) * k; CSV.hi = a.hi + (b.hi - a.hi) * k; return CSV;
}
const EdgeShader = {
  uniforms: { tDiffuse: { value: null }, tNormal: { value: null }, tDepth: { value: null }, uTexel: { value: new THREE.Vector2(1, 1) }, uRange: { value: 600 }, uDTh: { value: .25 }, uNTh: { value: .35 }, uInk: { value: new THREE.Color(0x2a2233) } },
  vertexShader: 'varying vec2 vUv; void main(){ vUv=uv; gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0); }',
  fragmentShader: `uniform sampler2D tDiffuse, tNormal, tDepth; uniform vec2 uTexel; uniform float uRange, uDTh, uNTh; uniform vec3 uInk; varying vec2 vUv;
  float D(vec2 u){ return texture2D(tDepth, u).x * uRange; }
  vec3 N(vec2 u){ return texture2D(tNormal, u).xyz * 2.0 - 1.0; }
  void main(){
    vec2 ox = vec2(uTexel.x, 0.0), oy = vec2(0.0, uTexel.y);
    float dc = D(vUv);
    float dd = abs(D(vUv + ox) - dc) + abs(D(vUv - ox) - dc) + abs(D(vUv + oy) - dc) + abs(D(vUv - oy) - dc);
    vec3 nc = N(vUv);
    float nd = (1.0 - dot(nc, N(vUv + ox))) + (1.0 - dot(nc, N(vUv - ox))) + (1.0 - dot(nc, N(vUv + oy))) + (1.0 - dot(nc, N(vUv - oy)));
    float bg = step(0.999 * uRange, dc); float de = smoothstep(uDTh, uDTh * 2.0, dd) * (1.0 - bg); float ne = smoothstep(uNTh, uNTh * 2.0, nd) * (1.0 - bg); float e = max(de, ne);
    vec4 c = texture2D(tDiffuse, vUv);
    float lum = dot(c.rgb, vec3(.299,.587,.114)); vec3 ink = (lum < 0.18 && ne > de) ? mix(c.rgb, vec3(.55,.62,.95), .3) : mix(c.rgb * 0.3, uInk, 0.55);
    gl_FragColor = vec4(mix(c.rgb, ink, e * 0.92), c.a);
  }`,
};

// ---------- Layout B ----------
function buildB(big) {
  const g = new THREE.Group(), H = 3.4, W = 37, F = big ? 3 : 1, Dz = 5, nc = { cast: false };
  const sc = [];
  const plans = [
    [[0, 5, 'lobby'], [5, 21, 'office'], [21, 28, 'meet'], [28, 34, 'kitchen'], [34, 37, 'wc']],
    [[0, 5, 'lobby'], [5, 29, 'office'], [29, 34, 'coffee'], [34, 37, 'wc']],
    [[0, 5, 'lobby'], [5, 14, 'boss'], [14, 37, 'lounge']],
  ];
  const floorM = { lobby: X.tile, office: X.carpet, meet: X.oakF, kitchen: X.tile, wc: X.tileB, coffee: X.tile, boss: X.oakF, lounge: X.oakF };
  const floorT = { lobby: 1.2, office: 2, meet: 2.4, kitchen: 1.2, wc: 1.2, coffee: 1.2, boss: 2.4, lounge: 2.4 };
  const wallM = BW(); const _unused = { lobby: M(0xdcd6cc, { r: .92 }), office: M(0xe6e2da, { r: .92 }), meet: M(0xd3d9de, { r: .92 }), kitchen: M(0xe6dccb, { r: .92 }), wc: M(0xd6e0e0, { r: .92 }), coffee: M(0xe6dccb, { r: .92 }), boss: M(0x5b6570, { r: .92 }), lounge: M(0xd8dcd2, { r: .92 }) };
  const gnd = floorP(g, -120, W + 120, -120, 300, -.3, groundMat, 4); gnd.userData.noEdge = true;
  B(g, -120, W + 120, -.3, -.2, 5.4, 8, walkMat, nc).userData.noEdge = true;
  const R = rng(5), sky = [];
  for (let i = 0; i < 26; i++) {
    const w = 3 + R() * 6, h = 2 + R() * 2.5, x = -30 + R() * (W + 60), z = -6 - R() * 10, d = 3 + R() * 3;
    const t = TEX.windows.clone(); t.needsUpdate = true; t.repeat.set(Math.max(1, Math.round(w / 3)), Math.max(1, Math.round(h / 6)));
    const m = track(new THREE.MeshStandardMaterial({ color: 0x8e97a1, roughness: .9, emissive: 0xffffff, emissiveMap: t, emissiveIntensity: 0 }));
    sky.push(m); B(g, x - w / 2, x + w / 2, -.3, h, z - d / 2, z + d / 2, m, nc);
  }
  for (let f = 0; f < F; f++) {
    const y = f * H;
    if (f === 0) B(g, -.2, W + .2, -.3, 0, -.2, Dz, X.edge, nc);
    else { B(g, -.2, 1.8, y - .3, y, -.2, Dz, X.edge, nc); B(g, 3.4, W + .2, y - .3, y, -.2, Dz, X.edge, nc); }
    for (const [x0, x1, type] of plans[f]) {
      floorP(g, x0, x1, 0, Dz, y + .005, floorM[type], floorT[type]);
      B(g, x0, x1, y, y + H - .3, -.2, 0, wallM[type], nc);
      B(g, x0, x1, y, y + .08, 0, .015, X.base, nc);
      if (['office', 'meet', 'boss', 'lounge', 'kitchen', 'coffee'].includes(type)) for (let cx = x0 + 2; cx < x1 - 1; cx += 3.4) pendant(g, cx, y + H - .3, 1.3);
      else B(g, (x0 + x1) / 2 - .6, (x0 + x1) / 2 + .6, y + H - .34, y + H - .31, 1.8, 2.8, ceilMat, nc);
      if (x0 > 0) { B(g, x0 - .07, x0 + .07, y, y + H - .3, 0, 3.1, X.wall); B(g, x0 - .07, x0 + .07, y + 2.3, y + H - .3, 3.1, Dz, X.wall); }
      if (['office', 'meet', 'boss', 'lounge', 'lobby'].includes(type)) for (let x = Math.max(x0 + 2.65, type === 'lobby' ? 4.4 : 0); x < x1 - .5; x += 2.2) sconce(sc, g, x, y + 2.68, .01);
      if (type !== 'kitchen' && type !== 'coffee') {
        const wy0 = type === 'wc' ? 1.9 : 1.0;
        for (let x = Math.max(x0 + .9, type === 'lobby' ? 3.9 : 0); x + 1.3 <= x1 - .6; x += 2.2) winBack(g, x, x + 1.3, y + wy0, y + 2.4, .005);
      }
    }
    if (f === 0) { B(g, -.2, 0, y, y + H - .3, 0, 3.1, X.wall); B(g, -.2, 0, y + 2.3, y + H - .3, 3.1, Dz, X.wall); B(g, -1.3, -.2, 0, .015, 3.1, 4.8, M(0x3d4045, { map: TEX.fabric, r: 1 }), nc); }
    else B(g, -.2, 0, y, y + H - .3, 0, Dz, X.wall);
    B(g, W, W + .2, y, y + H - .3, 0, Dz, X.wall);
    B(g, 1.7, 3.5, y, y + 2.45, 1.3, 1.46, X.frame); B(g, 1.85, 3.35, y, y + 2.3, 1.29, 1.47, X.glass, nc);
    plant(g, .7, y, .8, 1, 2);
  }
  B(g, -.3, W + .3, F * H - .3, F * H + .05, -.3, Dz + .1, X.edge, nc); B(g, -.3, W + .3, F * H + .05, F * H + .5, Dz - .05, Dz + .1, X.edge, nc);
  B(g, 1.8, 3.4, 0, F * H - .3, -.2, .02, X.shaft, nc);
  B(g, 1.75, 1.85, 0, F * H - .3, 1.35, 1.45, X.frame); B(g, 3.35, 3.45, 0, F * H - .3, 1.35, 1.45, X.frame);
  for (const cx of [2.2, 3.0]) Cy(g, .008, F * H - .3, cx, (F * H - .3) / 2, .3, X.chrome, { cast: false });
  RB(g, 1.0, 1.0, .8, 4.3, .5, 2.2, X.walnut, .03); RB(g, 1.05, .04, .85, 4.3, 1.02, 2.2, X.stone, .01);
  const st = { desk: [] }, desks = [], cof = [[], [], []], wcs = [[], []];
  const row = (y, n, f) => { for (let j = 0; j < n; j++) { const x = 6 + j * 1.8; desks.push(S(x, y, 2.2, PI / 2, 'sit', [[x, 3.9]], f)); st.desk.push(station(g, x, y, 2.2, PI / 2, false, desks.length)); } };
  row(0, 8, 0);
  let fs;
  if (!big) { fs = S(19.4, 0, 1.4, 0, 'sit', [[20.75, 1.4], [20.75, 3.9]], 0); floorP(g, 17.9, 20.9, .4, 3.0, .012, X.rug, 1.5); st.founder = station(g, 19.4, 0, 1.4, 0, true, 99); }
  else { printer(g, 19.6, 0, 1.0); plant(g, 20.4, 0, .6, 1, 1); }
  // meeting
  RB(g, 3.8, .05, 1.0, 24.5, .74, 2.2, X.walnut, .02); for (const lx of [23.2, 25.8]) B(g, lx - .04, lx + .04, 0, .72, 1.9, 2.5, X.metal);
  tv(g, 24.5, 1.75, .03, 1.8);
  const meet = [];
  [23.2, 24.5, 25.8].forEach(x => meet.push(S(x, 0, 1.1, 0, 'sit', [[22.2, 1.1], [22.2, 3.9]], 0)));
  [23.2, 24.5, 25.8].forEach(x => meet.push(S(x, 0, 3.25, PI, 'sit', [[x, 3.9]], 0)));
  meet.forEach(s => officeChair(g, s.pos.x, 0, s.pos.z, s.face, X.fabricW)); plant(g, 27.3, 0, .6, .9, 2);
  // kitchen
  kitchenRun(g, 28.2, 31.6, 0, .02); coffeeMachine(g, 28.8, .89, .3); sink(g, 30.8, 0, .35); fridge(g, 31.8, 32.7, 0, .05, .85);
  Cy(g, .45, .035, 32.95, .745, 2.4, X.deskTop); Cy(g, .05, .7, 32.95, .37, 2.4, X.metal); Cy(g, .28, .025, 32.95, .012, 2.4, X.metal);
  [28.8, 29.6, 30.4, 31.2].forEach(x => cof[0].push(S(x, 0, 1.3, PI, 'stand', [[x, 3.9]], 0)));
  const eat = [S(32.25, 0, 2.4, PI / 2, 'sit', [[32.25, 3.9]], 0), S(33.6, 0, 2.4, -PI / 2, 'sit', [[33.6, 3.9]], 0)];
  eat.forEach(s => woodChair(g, s.pos.x, 0, s.pos.z, s.face));
  const wcRoom = f => { const y = f * H; B(g, 35.51, 35.59, y + .12, y + 1.9, 0, 2.2, X.laminate); [34.85, 36.25].forEach(x => { toilet(g, x, y, .35); wcs[f].push(S(x, y, 1.1, 0, 'stand', [[x, 3.9]], f)); }); };
  wcRoom(0);
  if (big) {
    const y1 = H, y2 = 2 * H;
    row(y1, 12, 1); wcRoom(1);
    kitchenRun(g, 29.2, 31.6, y1, .02); coffeeMachine(g, 29.6, y1 + .89, .3); fridge(g, 31.7, 32.5, y1, .05, .8);
    [29.6, 30.3, 31.0, 31.7].forEach(x => cof[1].push(S(x, y1, 1.3, PI, 'stand', [[x, 3.9]], 1)));
    sofa(g, 32.5, 33.9, .3, 1.1, y1, X.fabricG);
    fs = S(9.5, y2, 1.4, 0, 'sit', [[11.3, 1.4], [11.3, 3.9]], 2);
    floorP(g, 7.2, 11.8, .4, 3.2, y2 + .012, X.rug, 1.5); st.founder = station(g, 9.5, y2, 1.4, 0, true, 99);
    bookshelf(g, 5.3, 7.0, y2, .02, .42, 2.3); plant(g, 12.8, y2, .7, 1.1, 2); sofa(g, 11.9, 13.7, 3.4, 4.3, y2, M(0x6b3f2e, { map: TEX.fabric, r: .6 }));
    kitchenRun(g, 14.4, 17.4, y2, .02); coffeeMachine(g, 14.9, y2 + .89, .3);
    [14.9, 15.6, 16.3, 17.0].forEach(x => cof[2].push(S(x, y2, 1.3, PI, 'stand', [[x, 3.9]], 2)));
    sofa(g, 20, 23, .3, 1.2, y2); sofa(g, 26, 29, .3, 1.2, y2, X.fabricG);
    RB(g, 1.2, .04, .6, 21.5, y2 + .4, 2.3, X.walnut, .02); RB(g, 1.2, .04, .6, 27.5, y2 + .4, 2.3, X.walnut, .02);
    bookshelf(g, 31.5, 34.5, y2, .02, .42, 2.0); plant(g, 24.5, y2, .7, 1, 0); plant(g, 36, y2, .7, 1.2, 2);
  }
  const out = S(-1.8, 0, 3.9, PI / 2, 'out', [[.5, 3.9]], 0);
  const floorOf = p => big ? (p.id === 0 ? 2 : p.id <= 8 ? 0 : 1) : 0;
  return {
    sconces: sc,
    g, bounds: new THREE.Box3(V(-1.5, 0, 5), V(W + .3, F * H + .3, 5)), sunOff: V(-12, 26, 30), fog: true, sky,
    spot(p, s) {
      const f = floorOf(p);
      switch (s.k) { case 'desk': return p.id === 0 ? fs : desks[p.id - 1]; case 'meet': return meet[s.i % 6]; case 'eat': return eat[s.i % 2]; case 'coffee': return cof[f][s.i % 4]; case 'wc': return wcs[f === 0 ? 0 : 1][s.i % 2]; default: return out; }
    },
    station: p => p.id === 0 ? st.founder : st.desk[p.id - 1], stations: [...st.desk, st.founder],
    connector: (a, b) => a.floor === b.floor ? [] : [V(2.6, a.floor * H, 3.9), V(2.6, a.floor * H, .8), V(2.6, b.floor * H, .8), V(2.6, b.floor * H, 3.9)],
  };
}

// ---------- v6: founder office, 10 desks, building shell ----------
ICON.visit = 'meeting'; ACT_LABEL.visit = 'Masaları dolaşıyor';
const viewMat = new THREE.MeshBasicMaterial({ color: 0xffffff });
const CITY = (() => { const R = rng(1234), out = [];
  const layer = (n, hMin, hMax, wMin, wMax, base, win) => { let x = -20; while (x < 1044) { const w = wMin + R() * (wMax - wMin), h = hMin + R() * (hMax - hMin); out.push({ x, w, h, base, win, s: Math.floor(R() * 1e6), tank: R() < .35, ant: R() < .18, setb: R() < .4, tone: R() }); x += w + (base === 176 ? 1 + R() * 3 : -4 + R() * 6); } };
  layer(0, 70, 150, 26, 60, 150, 5); layer(0, 40, 110, 34, 70, 176, 7); layer(0, 30, 70, 60, 110, 256, 10);
  return out; })();
const VIEW = (() => { const c = document.createElement('canvas'); c.width = 1024; c.height = 256; const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; t.wrapS = THREE.RepeatWrapping; const R = rng(909);
  viewMat.map = t;
  return { c, t, x: c.getContext('2d'),
    city: [...Array(38)].map(() => ({ x: R() * 1024, w: 18 + R() * 46, h: 24 + R() * 64, s: Math.floor(R() * 1e6) })),
    far: [...Array(70)].map(() => ({ x: R() * 1024, r: 12 + R() * 15, y: 156 + R() * 10 })),
    near: [...Array(16)].map(() => ({ x: R() * 1024, r: 30 + R() * 26, y: 206 + R() * 26 })),
    lamps: [...Array(9)].map(() => ({ x: R() * 1024 })) }; })();
const _vc = new THREE.Color(), _vd = new THREE.Color(), _vn = new THREE.Color();
function lerpHex(a, b, k) { _vn.set(a); _vd.set(b); return '#' + _vc.lerpColors(_vn, _vd, k).getHexString(); }
function drawView(v, day, night) {
  const { x } = VIEW, w = 1024, h = 256, hex = c => '#' + c.getHexString();
  const g = x.createLinearGradient(0, 0, 0, h * .8); g.addColorStop(0, hex(v.top)); g.addColorStop(1, hex(_vc.copy(v.bot).lerp(_vn.set(0xffffff), .25 * day))); x.fillStyle = g; x.fillRect(0, 0, w, h);
  const warm = Math.max(0, 1 - Math.abs(day - .35) * 3) * (1 - night * .6);
  for (const b of CITY) {
    const top = b.base - b.h, far = b.base === 150, near = b.base === 256;
    const haze = far ? .35 : near ? 0 : .12;
    _vc.copy(v.top).lerp(v.bot, .6).multiplyScalar(.55 + .45 * day); _vd.setHSL(.03 + b.tone * .08, .32 + b.tone * .15, (near ? .2 : .26) + b.tone * .16).multiplyScalar(.3 + .7 * day); _vd.lerp(_vc, haze);
    const lit = '#' + _vd.getHexString(); _vn.copy(_vd).multiplyScalar(.5); const shade = '#' + _vn.getHexString();
    x.fillStyle = lit; x.fillRect(b.x, top, b.w * .62, b.h); x.fillStyle = shade; x.fillRect(b.x + b.w * .62, top, b.w * .38, b.h);
    if (warm > 0) { x.fillStyle = 'rgba(255,150,90,' + (.28 * warm) + ')'; x.fillRect(b.x, top, b.w * .62, b.h); }
    if (b.setb) { x.fillStyle = lit; x.fillRect(b.x + b.w * .2, top - 12, b.w * .5, 12); }
    if (b.tank && !far) { x.fillStyle = shade; x.fillRect(b.x + b.w * .6, top - 9, 7, 7); x.fillRect(b.x + b.w * .6 + 1, top - 2, 1, 2); x.fillRect(b.x + b.w * .6 + 5, top - 2, 1, 2); }
    if (b.ant) { x.fillStyle = shade; x.fillRect(b.x + b.w * .4, top - 22, 2, 22); if (night > .3) { x.fillStyle = 'rgba(255,60,50,' + night + ')'; x.fillRect(b.x + b.w * .4 - 1, top - 24, 4, 4); } }
    const R = rng(b.s), cw = b.win, ch = b.win * 1.3;
    for (let yy = top + 4; yy < Math.min(b.base, h) - 3; yy += ch + 2) for (let xx = b.x + 3; xx < b.x + b.w - cw - 1; xx += cw + 2) {
      const r = R();
      if (night > .05 && r < .1 + .32 * night) { x.fillStyle = r < .03 ? 'rgba(200,220,255,' + (.9 * night + .1) + ')' : 'rgba(255,205,135,' + (.85 * night + .15) + ')'; }
      else x.fillStyle = day > .3 ? (r > .85 ? 'rgba(170,200,230,.55)' : 'rgba(30,45,72,' + (.45 + .2 * day) + ')') : 'rgba(10,14,30,.4)';
      x.fillRect(xx, yy, cw, ch);
    }
  }
  VIEW.t.needsUpdate = true;
}
function drawViewPark(v, day, night) {
  const { x } = VIEW, w = 1024, h = 256, hex = c => '#' + c.getHexString();
  const g = x.createLinearGradient(0, 0, 0, h * .64); g.addColorStop(0, hex(v.top)); g.addColorStop(1, hex(v.bot)); x.fillStyle = g; x.fillRect(0, 0, w, h);
  x.fillStyle = hex(_vc.copy(v.top).lerp(v.bot, .6).multiplyScalar(.7));
  for (const b of VIEW.city) x.fillRect(b.x, 160 - b.h, b.w, b.h);
  if (night > 0) for (const b of VIEW.city) { const R = rng(b.s); x.fillStyle = 'rgba(255,208,140,' + (.9 * night) + ')'; for (let yy = 160 - b.h + 5; yy < 156; yy += 7) for (let xx = b.x + 3; xx < b.x + b.w - 3; xx += 6) if (R() < .22) x.fillRect(xx, yy, 3, 3); }
  x.fillStyle = lerpHex(0x16233a, 0x7ea37a, day); for (const t of VIEW.far) { x.beginPath(); x.arc(t.x, t.y, t.r, 0, Math.PI * 2); x.fill(); }
  x.fillStyle = lerpHex(0x121b2e, 0xa8c586, day); x.fillRect(0, 164, w, h);
  x.fillStyle = lerpHex(0x1f2638, 0xe6d8bb, day); x.fillRect(0, 188, w, 9);
  for (const l of VIEW.lamps) { x.fillStyle = lerpHex(0x2a2f40, 0x3b3f4c, day); x.fillRect(l.x, 168, 2, 22); if (night > 0) { const gg = x.createRadialGradient(l.x + 1, 168, 0, l.x + 1, 168, 14); gg.addColorStop(0, 'rgba(255,214,150,' + night + ')'); gg.addColorStop(1, 'rgba(255,214,150,0)'); x.fillStyle = gg; x.fillRect(l.x - 14, 154, 30, 30); } }
  for (const t of VIEW.near) { x.fillStyle = lerpHex(0x1a1a24, 0x5b4636, day); x.fillRect(t.x - 3, t.y, 6, 60); x.fillStyle = lerpHex(0x0e1628, 0x4f8257, day); x.beginPath(); x.arc(t.x, t.y - t.r * .4, t.r, 0, Math.PI * 2); x.fill(); x.fillStyle = lerpHex(0x14203a, 0x6a9e62, day); x.beginPath(); x.arc(t.x - t.r * .3, t.y - t.r * .7, t.r * .6, 0, Math.PI * 2); x.fill(); }
  VIEW.t.needsUpdate = true;
}
const fadeTex = canvasTex(4, 256, (x, w, h) => { const g = x.createLinearGradient(0, 0, 0, h); g.addColorStop(0, 'rgba(255,255,255,0)'); g.addColorStop(.12, 'rgba(255,255,255,0)'); g.addColorStop(.92, 'rgba(255,255,255,1)'); x.fillStyle = g; x.fillRect(0, 0, w, h); });
fadeTex.wrapS = fadeTex.wrapT = THREE.ClampToEdgeWrapping;
const fadeMat = new THREE.MeshBasicMaterial({ map: fadeTex, color: 0x888888, transparent: true, depthWrite: false, opacity: 1 });
const lowDark = new THREE.MeshBasicMaterial({ color: 0x33415e }), lowLit = new THREE.MeshBasicMaterial({ color: 0xffcf8a, toneMapped: false });
const roadMat = new THREE.MeshBasicMaterial({ color: 0x6b6f78 }), grassMat = new THREE.MeshBasicMaterial({ color: 0x9dbb7c }), lineMat = new THREE.MeshBasicMaterial({ color: 0xefe9dd });
const postMat = track(new THREE.MeshStandardMaterial({ color: 0xfff2dc, emissive: 0xffd08a, emissiveIntensity: 0 }));
const fLampMat = track(new THREE.MeshStandardMaterial({ color: 0xfff2dc, emissive: 0xffc27a, emissiveIntensity: 0 }));
const poolMat = new THREE.MeshBasicMaterial({ map: glowTex, transparent: true, depthWrite: false, blending: THREE.AdditiveBlending, toneMapped: false, opacity: 0 });
const streetGlow = new THREE.MeshBasicMaterial({ map: glowTex, transparent: true, depthWrite: false, blending: THREE.AdditiveBlending, toneMapped: false, opacity: 0 });
function decal(g, x, y, z, sx, sz, m) { const p = new THREE.Mesh(PLANEG, m); p.rotation.x = -PI / 2; p.scale.set(sx, sz, 1); p.position.set(x, y, z); p.renderOrder = 2; g.add(p); return p; }
const carHead = track(new THREE.MeshStandardMaterial({ color: 0xfff6e0, emissive: 0xfff0c0, emissiveIntensity: 0 })), carTail = track(new THREE.MeshStandardMaterial({ color: 0x8a1a1a, emissive: 0xff3a2a, emissiveIntensity: 0 }));
function tree(g, x, y, z, k = 1, pit = false) {
  const R = rng(Math.floor(x * 53 + z * 97 + 7)), bark = M(0x6b4e3a, { r: .9 }), hi = M(0x9bc26a, { r: .7 });
  if (pit) { B(g, x - .55, x + .55, y, y + .03, z - .55, z + .55, M(0x3a3026), { cast: false }); for (const [a, b, c, d] of [[-.6, .6, -.6, -.52], [-.6, .6, .52, .6], [-.6, -.52, -.6, .6], [.52, .6, -.6, .6]]) B(g, x + a, x + b, y, y + .05, z + c, z + d, X.metal, { cast: false }); }
  Cy(g, .13 * k, 2.0 * k, x, y + 1.0 * k, z, bark, { geo: CONEG });
  for (const a of [.7, -.9]) { const b = new THREE.Mesh(CYLG, bark); b.scale.set(.035 * k, .7 * k, .035 * k); b.position.set(x + Math.sin(a) * .22 * k, y + 1.6 * k, z + Math.cos(a) * .12 * k); b.rotation.z = -a * .7; b.castShadow = true; g.add(b); }
  const main = new THREE.Mesh(ICOG, X.leaves[1]); main.scale.set(1.05 * k, .9 * k, 1.05 * k); main.position.set(x, y + 2.35 * k, z); main.castShadow = true; g.add(main);
  const n = 5 + Math.floor(R() * 3);
  for (let i = 0; i < n; i++) { const a = i / n * PI * 2 + R() * .6, rr = (.55 + R() * .25) * k, s = (.48 + R() * .28) * k, me = new THREE.Mesh(ICOG, i % 3 === 0 ? X.leaves[2] : X.leaves[0]); me.scale.set(s, s * .85, s); me.position.set(x + Math.cos(a) * rr, y + (2.0 + R() * .7) * k, z + Math.sin(a) * rr); me.castShadow = true; g.add(me); }
  const top = new THREE.Mesh(ICOG, hi); top.scale.set(.5 * k, .4 * k, .5 * k); top.position.set(x + .15 * k, y + 2.95 * k, z - .1 * k); top.castShadow = true; g.add(top);
}
function bench(g, x, y, z, ry) { const s = grp(g, x, y, z, ry); RB(s, 1.4, .06, .4, 0, .45, 0, X.walnut, .02); RB(s, 1.4, .3, .05, 0, .7, -.2, X.walnut, .02); for (const a of [-.6, .6]) B(s, a - .03, a + .03, 0, .45, -.18, .18, X.metal); }
function lampPost(g, list, x, y, z) { Cy(g, .05, 3.2, x, y + 1.6, z, X.metal); RB(g, .3, .18, .3, x, y + 3.25, z, postMat, .04); list.push(decal(g, x, y + .02, z, 4.5, 4.5, streetGlow)); }
function unicorn(g, x, y, z, ry) {
  const s = grp(g, x, y, z, ry), wht = M(0xfbf8f2, { r: .4 }), pink = M(0xe68ab8, { r: .5 });
  RB(s, .14, .08, .07, 0, .09, 0, wht, .03); RB(s, .06, .07, .05, .08, .15, 0, wht, .02);
  for (const [a, b] of [[-.05, -.025], [.05, -.025], [-.05, .025], [.05, .025]]) B(s, a - .01, a + .01, 0, .06, b - .01, b + .01, wht);
  const h = new THREE.Mesh(CONEG, M(0xf4c430, { r: .3 })); h.scale.set(.012, .06, .012); h.rotation.z = -.5; h.position.set(.11, .21, 0); s.add(h);
  RB(s, .03, .06, .055, .05, .17, 0, pink, .01); RB(s, .04, .03, .03, -.085, .11, 0, pink, .01);
}
function whiteboard(g, x, y, z, ry) {
  const s = grp(g, x, y, z, ry);
  const tex = canvasTex(256, 160, (c, w, h) => { c.fillStyle = '#fbfaf6'; c.fillRect(0, 0, w, h); c.lineWidth = 3; c.lineCap = 'round';
    c.strokeStyle = '#3f6f7a'; c.strokeRect(20, 24, 56, 34); c.strokeRect(110, 24, 56, 34); c.strokeRect(190, 80, 46, 30); c.beginPath(); c.moveTo(76, 41); c.lineTo(110, 41); c.moveTo(166, 41); c.quadraticCurveTo(210, 45, 212, 80); c.stroke();
    c.strokeStyle = '#c0583f'; c.beginPath(); c.moveTo(24, 130); for (let i = 0; i < 8; i++) c.lineTo(24 + i * 20, 130 - i * i * 1.3 - (i % 2) * 6); c.stroke();
    c.strokeStyle = '#34384a'; c.lineWidth = 2; for (let i = 0; i < 4; i++) { c.beginPath(); c.moveTo(20, 80 + i * 10); c.lineTo(20 + 40 + (i * 23) % 50, 80 + i * 10); c.stroke(); } });
  const board = new THREE.Mesh(BOXG, X.alu); board.scale.set(1.4, .9, .03); board.position.set(0, 1.45, 0); s.add(board); const face = new THREE.Mesh(PLANEG, M(0xffffff, { map: tex, r: .9 })); face.scale.set(1.36, .86, 1); face.position.set(0, 1.45, .016); face.userData.noEdge = true; s.add(face);
  B(s, -.72, .72, .98, 1.02, -.02, .03, X.alu); B(s, -.72, .72, 1.88, 1.92, -.02, .03, X.alu);
  for (const a of [-.66, .66]) { B(s, a - .025, a + .025, 0, 1.92, -.025, .025, X.alu); B(s, a - .025, a + .025, 0, .03, -.3, .3, X.alu); }
}
function glassDoor(g, x, z, ry) { const s = grp(g, x, 0, z, ry); B(s, 0, .95, .05, 2.3, -.012, .012, X.glass, { cast: false }); B(s, 0, .95, 0, .05, -.025, .025, X.frame); B(s, 0, .95, 2.3, 2.35, -.025, .025, X.frame); B(s, 0, .04, 0, 2.35, -.025, .025, X.frame); B(s, .91, .95, 0, 2.35, -.025, .025, X.frame); B(s, .8, .83, .9, 1.3, -.06, .06, X.chrome); }

const glassTex = canvasTex(64, 128, (x, w, h) => { const g = x.createLinearGradient(0, 0, 0, h); g.addColorStop(0, '#ffffff'); g.addColorStop(1, '#8e97a8'); x.fillStyle = g; x.fillRect(0, 0, w, h); x.fillStyle = 'rgba(255,255,255,.35)'; x.beginPath(); x.moveTo(8, h); x.lineTo(26, h); x.lineTo(w, 30); x.lineTo(w, 10); x.closePath(); x.fill(); x.fillStyle = 'rgba(255,255,255,.18)'; x.beginPath(); x.moveTo(34, h); x.lineTo(40, h); x.lineTo(w, 62); x.lineTo(w, 56); x.closePath(); x.fill(); });
const blindTex = canvasTex(64, 128, (x, w, h) => { const g = x.createLinearGradient(0, 0, 0, h); g.addColorStop(0, '#fff1d6'); g.addColorStop(1, '#f2b872'); x.fillStyle = g; x.fillRect(0, 0, w, h); x.fillStyle = 'rgba(120,70,30,.22)'; for (let y = 4; y < h; y += 7) x.fillRect(0, y, w, 2); x.fillStyle = 'rgba(120,70,30,.3)'; x.fillRect(w / 2 - 1, 0, 2, h); });
glassTex.wrapS = glassTex.wrapT = blindTex.wrapS = blindTex.wrapT = THREE.ClampToEdgeWrapping;
lowDark.map = glassTex; lowLit.map = blindTex; lowLit.color.set(0xffe2b8);
const hazeMats = [];
let BRT = null;
function brickMat(c, rx, ry) {
  if (!BRT) BRT = canvasTex(256, 256, (x, w, h) => { x.fillStyle = '#d9d0c4'; x.fillRect(0, 0, w, h); const R = rng(5);
    for (let r = 0; r < 10; r++) for (let k = -1; k < 5; k++) { const v = 196 + Math.floor(R() * 59); x.fillStyle = 'rgb(' + v + ',' + Math.floor(v * .8) + ',' + Math.floor(v * .72) + ')'; x.fillRect(k * 64 + (r % 2) * 32 + 2, r * 25.6 + 2, 60, 21.6); } });
  const t = BRT.clone(); t.needsUpdate = true; t.repeat.set(Math.max(1, rx), Math.max(1, ry)); return M(c, { map: t, r: .95 });
}
function hazeMat(c) { const m = new THREE.MeshBasicMaterial({ color: c }); m.userData.base = new THREE.Color(c); hazeMats.push(m); return m; }
function winUnit(gl, u0, u1, y0, y1, list, sched, band) {
  B(gl, u0 - .07, u1 + .07, y0 - .07, y1 + .07, -.01, .015, X.black, { cast: false });
  const p = B(gl, u0, u1, y0, y1, .015, .03, lowDark, { cast: false }); p.userData.sched = sched; list.push(p);
  const f = X.frame, t = .05;
  B(gl, u0 - t, u1 + t, y0 - t, y0, .03, .09, f); B(gl, u0 - t, u1 + t, y1, y1 + t, .03, .09, f); B(gl, u0 - t, u0, y0, y1, .03, .09, f); B(gl, u1, u1 + t, y0, y1, .03, .09, f);
  const um = (u0 + u1) / 2, yt = y0 + (y1 - y0) * .72; B(gl, um - .02, um + .02, y0, y1, .03, .08, f); B(gl, u0, u1, yt - .02, yt + .02, .03, .08, f);
  B(gl, u0 - .12, u1 + .12, y0 - .12, y0 - .05, 0, .16, band);
}
function car(g, x, y, z, ry, c, taxi = false) {
  const s = grp(g, x, y, z, ry), body = M(c, { r: .3, m: .1 }), glass = M(0x3a4a66, { r: .1 }), dark = M(0x1f2229, { r: .6 });
  RB(s, 2.1, .34, .9, 0, .36, 0, body, .12); RB(s, 1.2, .34, .84, -.12, .66, 0, body, .12);
  B(s, -.64, .4, .55, .78, -.43, -.415, glass, { cast: false }); B(s, -.64, .4, .55, .78, .415, .43, glass, { cast: false }); B(s, -.14, -.1, .55, .8, -.435, .435, body, { cast: false });
  RB(s, .04, .27, .74, .5, .67, 0, glass, .015, { rz: -.55, cast: false }); RB(s, .04, .25, .74, -.74, .67, 0, glass, .015, { rz: .55, cast: false });
  B(s, 1.02, 1.09, .2, .33, -.42, .42, dark); B(s, -1.09, -1.02, .2, .33, -.42, .42, dark);
  for (const zz of [-.3, .3]) { B(s, 1.05, 1.07, .38, .45, zz - .08, zz + .08, carHead, { cast: false }); B(s, -1.07, -1.05, .38, .45, zz - .08, zz + .08, carTail, { cast: false }); }
  for (const [a, b] of [[-.68, -.43], [.68, -.43], [-.68, .43], [.68, .43]]) { Cy(s, .18, .13, a, .18, b, X.black, { rx: PI / 2 }); Cy(s, .09, .14, a, .18, b, X.alu, { rx: PI / 2, cast: false }); }
  if (taxi) { B(s, -.32, .08, .83, .92, -.14, .14, M(0xfff4c8, { e: 0xffe08a, ei: .6 })); B(s, -1.0, 1.0, .33, .36, -.455, -.45, X.black, { cast: false }); B(s, -1.0, 1.0, .33, .36, .45, .455, X.black, { cast: false }); }
}
function buildA2(env) {
  PANES = [];
  let g = new THREE.Group(); const G0 = g, MIR = new THREE.Group(); MIR.position.x = 20; MIR.scale.x = -1; g.add(MIR);
  const D = 15, W = 20, TH = 2.8, LOW = 1.05, EXT = .45, nc = { cast: false }, GY = -6.6;
  if (env === 'mevcut') floorP(g, -60, W + 60, -60, D + 300, -.3, groundMat, 4).userData.noEdge = true;
  hazeMats.length = 0;
  B(g, -.25, W + .25, -.3, 0, -.25, D + .25, X.edge, nc);
  g = MIR;
  floorP(g, 5.4, W, 8.2, D, .005, X.carpet, 2); floorP(g, 0, 5.4, 8.4, D, .005, X.oakF, 2.4);
  floorP(g, 0, W, 6, 8.2, .006, X.oakF, 2.4); floorP(g, 0, 8, 0, 6, .006, X.oakF, 2.4);
  floorP(g, 8, 15, 0, 6, .006, X.tile, 1.2); floorP(g, 15, 20, 0, 6, .006, X.tileB, 1.2);
  g = G0;
  const segs = (a0, a1, gaps) => { const out = []; let cur = a0; for (const [a, b] of gaps) { out.push([cur, a]); cur = b; } out.push([cur, a1]); return out.filter(([a, b]) => b - a > .01); };
  const wallX = (z, x0, x1, h, gaps = [], t = .18) => { for (const [a, b] of segs(x0, x1, gaps)) { B(g, a, b, 0, h, z - t / 2, z + t / 2, X.wall); B(g, a, b, h, h + .03, z - t / 2, z + t / 2, X.cap, nc); B(g, a, b, 0, .08, z - t / 2 - .012, z + t / 2 + .012, X.base, nc); } };
  const wallZ = (x, z0, z1, h, gaps = [], t = .18) => { for (const [a, b] of segs(z0, z1, gaps)) { B(g, x - t / 2, x + t / 2, 0, h, a, b, X.wall); B(g, x - t / 2, x + t / 2, h, h + .03, a, b, X.cap, nc); B(g, x - t / 2 - .012, x + t / 2 + .012, 0, .08, a, b, X.base, nc); } };
  const glassX = (z, x0, x1, h, gaps = []) => { for (const [a, b] of segs(x0, x1, gaps)) { B(g, a, b, .05, h, z - .012, z + .012, X.glass, nc); B(g, a, b, 0, .05, z - .03, z + .03, X.frame); B(g, a, b, h, h + .05, z - .03, z + .03, X.frame); const n = Math.max(1, Math.round((b - a) / 1.2)); for (let i = 0; i <= n; i++) { const x = a + (b - a) * i / n; B(g, x - .025, x + .025, 0, h, z - .03, z + .03, X.frame); } } };
  const glassZ = (x, z0, z1, h) => { B(g, x - .012, x + .012, .05, h, z0, z1, X.glass, nc); B(g, x - .03, x + .03, 0, .05, z0, z1, X.frame); B(g, x - .03, x + .03, h, h + .05, z0, z1, X.frame); const n = Math.max(1, Math.round((z1 - z0) / 1.2)); for (let i = 0; i <= n; i++) { const z = z0 + (z1 - z0) * i / n; B(g, x - .03, x + .03, 0, h, z - .025, z + .025, X.frame); } };
  wallX(0, -.09, W + .09, TH); wallZ(0, 0, D, TH);
  wallX(D, -.09, W + .09, EXT); wallZ(W, 0, D, EXT);
  const core = M(0x5a6275, { r: .6 }); B(g, .09, 1.35, 0, 2.8, 6.02, 8.18, core); B(g, .09, 1.37, 2.8, 2.84, 6.0, 8.2, X.cap, nc);
  B(g, 1.35, 1.36, .01, 2.25, 6.45, 7.75, X.black, nc);
  B(g, 1.35, 1.43, 0, 2.35, 6.33, 6.45, X.frame); B(g, 1.35, 1.43, 0, 2.35, 7.75, 7.87, X.frame); B(g, 1.35, 1.43, 2.25, 2.37, 6.33, 7.87, X.frame);
  const elL = B(g, 1.37, 1.39, .01, 2.25, 6.45, 7.1, X.alu), elR = B(g, 1.37, 1.39, .01, 2.25, 7.1, 7.75, X.alu);
  B(g, 1.36, 1.44, 2.46, 2.56, 6.92, 7.28, M(0x9fd3ff, { e: 0x9fd3ff, ei: 1.2 }), nc);
  floorP(g, 1.4, 3.2, 6.25, 7.95, .012, X.rug2, 1.5); plant(g, 1.75, 0, 8.55, .8, 1);
  g = MIR;
  glassX(6, 0, 8, 2.4, [[3.4, 4.6]]); glassZ(8, 0, 6, 2.4); glassDoor(g, 4.6, 6, PI - .9);
  glassX(8.4, 0, 5.4, 2.4, [[3.9, 4.9]]); glassZ(5.4, 8.4, D, 2.4); glassDoor(g, 3.9, 8.4, -1.0);
  wallX(6, 8, 15, LOW, [[9.9, 11.1]]);
  wallX(6, 15, 20, 2.4, [[16.9, 18.1]]); wallZ(15, 0, 6, 2.4);
  { const dr = grp(g, 18.05, 0, 5.88, PI / 2); B(dr, 0, 1.15, 0, 2.2, -.03, .03, X.walnut); B(dr, .95, 1.0, .95, 1.05, -.07, .07, X.chrome); }
  wcSign(g, 16.0, 1.95, 6.1, 0, 18.4);
  // meeting (7 seats)
  RB(g, 4.2, .05, 1.3, 4, .74, 3, X.walnut, .02); for (const lx of [2.8, 5.2]) B(g, lx - .04, lx + .04, 0, .72, 2.6, 3.4, X.metal);
  const meet = [];
  [2.7, 4, 5.3].forEach(x => meet.push(S(x, 0, 1.7, 0, 'sit', [[x, 1.0], [1.2, 1.0], [1.2, 5.2], [4, 5.2], [4, 7]])));
  [2.7, 4, 5.3].forEach(x => meet.push(S(x, 0, 4.3, PI, 'sit', [[x, 5.2], [4, 5.2], [4, 7]])));
  meet.push(S(6.6, 0, 3, -PI / 2, 'sit', [[6.6, 5.2], [4, 5.2], [4, 7]]));
  meet.forEach(s => officeChair(g, s.pos.x, 0, s.pos.z, s.face, X.fabricW));
  B(g, 2.4, 5.6, 0, .5, .1, .5, X.walnut); plant(g, 7.3, 0, .7, 1, 2); plant(g, .7, 0, .7, .9, 1);
  // kitchen
  kitchenRun(g, 8.2, 12.8, 0, .1, false);
  for (let i = 0; i < 4; i++) { const cx = 8.5 + i * .6; RB(g, .588, .7, .34, cx, 1.95, .27, X.cabinet, .01); B(g, cx - .08, cx + .08, 1.64, 1.655, .44, .46, X.chrome); }
  coffeeMachine(g, 9.2, .89, .38); sink(g, 11.9, 0, .45);
  for (let i = 0; i < 3; i++) Cy(g, .038, .09, 9.75 + i * .12, .935, .5, X.ceramic);
  fridge(g, 13.15, 14.05, 0, .1, .85);
  Cy(g, .55, .035, 13.6, .745, 3.6, X.deskTop); Cy(g, .05, .7, 13.6, .37, 3.6, X.metal); Cy(g, .3, .025, 13.6, .012, 3.6, X.metal);
  const cof = [9.2, 10.1, 11.0, 11.9].map(x => S(x, 0, 1.45, PI, 'stand', [[10.5, 5.3], [10.5, 7]]));
  const eat = [S(12.85, 0, 3.6, PI / 2, 'sit', [[12.85, 5.0], [10.5, 5.3], [10.5, 7]]), S(14.35, 0, 3.6, -PI / 2, 'sit', [[14.35, 5.0], [10.5, 5.3], [10.5, 7]]),
    S(9.2, 0, 3.72, 0, 'sit', [[10.5, 5.3], [10.5, 7]]), S(9.2, 0, 5.08, PI, 'sit', [[10.5, 5.3], [10.5, 7]])];
  RB(g, .9, .04, .72, 9.2, .74, 4.4, X.deskTop, .015); for (const [a, b] of [[8.82, 4.1], [9.58, 4.1], [8.82, 4.7], [9.58, 4.7]]) Cy(g, .02, .72, a, .36, b, X.metal);
  eat.forEach(s => woodChair(g, s.pos.x, 0, s.pos.z, s.face)); plant(g, 14.4, 0, 5.4, .8, 0);
  // toilet
  B(g, 17.46, 17.54, .12, 1.6, 0, 2.6, X.laminate);
  for (const [a, b] of segs(15, 20, [[15.7, 16.8], [18.2, 19.3]])) B(g, a, b, .12, 1.6, 2.56, 2.64, X.laminate);
  toilet(g, 16.25, 0, .4); toilet(g, 18.75, 0, .4);
  RB(g, .6, .85, 1.0, 19.55, .425, 3.9, X.cabinet, .02); RB(g, .45, .05, .5, 19.55, .87, 3.9, X.ceramic, .02);
  const wcs = [16.25, 18.75].map(x => S(x, 0, 1.3, 0, 'stand', [[x, 3.4], [17.5, 4.9], [17.5, 7]]));
  // open office: 10 desks
  const desks = [], visits = [], st = { desk: [] };
  [7.9, 12.5, 17.1].forEach((cx, k) => {
    const seats = [[cx - .7, 9.9, 0, -1], [cx + .7, 9.9, 0, 1]];
    if (k < 2) seats.push([cx - .7, 12.1, PI, -1], [cx + .7, 12.1, PI, 1]);
    for (const [x, z, f, side] of seats) {
      const front = f === 0, ax = cx + side * 2.3;
      desks.push(S(x, 0, z, f, 'sit', front ? [[x, 7]] : [[x, 13.2], [ax, 13.2], [ax, 7]]));
      const vx = x + .55 * side, vz = front ? 9.05 : 12.95;
      visits.push(S(vx, 0, vz, Math.atan2(x - vx, (front ? 10.6 : 11.4) - vz), 'stand', front ? [[vx, 7]] : [[vx, 13.3], [ax, 13.3], [ax, 7]]));
      st.desk.push(station(g, x, 0, z, f, false, desks.length));
    }
    B(g, cx - 1.3, cx + 1.3, .74, 1.12, 10.99, 11.01, M(0xc9cfd3, { r: .9 }), nc);
  });
  plant(g, 16, 0, 13.8, 1, 2); plant(g, 19.3, 0, 14.3, 1.1, 0);
  // founder glass corner office
  floorP(g, .5, 4.9, 8.9, 14.6, .012, X.rug, 1.5);
  const fs = S(2.6, 0, 10.1, 0, 'sit', [[4.4, 9.4], [4.4, 7]]);
  st.founder = station(g, 2.6, 0, 10.1, 0, true, 99);
  woodChair(g, 1.9, 0, 12.4, PI); woodChair(g, 3.3, 0, 12.4, PI);
  bookshelf(grp(g, .35, 0, 10.7, PI / 2), -1.5, 1.5, 0, -.2, .2, .85);
  { const s = grp(g, .35, 0, 10.7, PI / 2), T = .85;
    for (let i = 0; i < 6; i++) B(s, -1.4 + i * .075, -1.34 + i * .075, T, T + .3 + (i % 3) * .04, -.15, .15, X.books[i % 4]);
    B(s, -.85, -.55, T + .02, T + .3, -.14, .14, X.books[1], { ry: .0 }); plant(s, -.25, T, 0, .5, 1); unicorn(s, .25, T, 0, 0);
    Cy(s, .05, .04, .6, T + .02, 0, M(0xc9a15a, { r: .3, m: .7 })); Cy(s, .02, .16, .6, T + .12, 0, M(0xc9a15a, { r: .3, m: .7 })); Cy(s, .09, .12, .6, T + .26, 0, M(0xc9a15a, { r: .3, m: .7 }), { geo: CONEG });
    const fr = grp(s, 1.05, T, 0); fr.rotation.x = -.18; RB(fr, .42, .52, .03, 0, .26, 0, X.walnut, .008); B(fr, -.17, .17, .05, .47, .016, .02, X.paper, { cast: false });
    for (const [yy, ww] of [[.4, .22], [.34, .16], [.28, .2], [.22, .12], [.12, .1]]) B(fr, -.14, -.14 + ww, yy, yy + .012, .021, .024, yy === .12 ? M(0xc0583f) : X.metal, { cast: false });
    B(fr, -.02, .02, 0, .16, -.1, -.07, X.walnut); }
  whiteboard(g, 4.85, 0, 13.3, -PI / 2);
  plant(g, 4.8, 0, 14.5, 1.1, 2);
  Cy(g, .14, .03, .55, .015, 8.95, X.metal); Cy(g, .02, 1.6, .55, .8, 8.95, X.metal); Cy(g, .22, .26, .55, 1.68, 8.95, fLampMat, { geo: CONEG });
  const pool = [decal(g, 2.7, .03, 11.4, 5.6, 7.2, poolMat)];
  g = G0;
  { const mS = s => { s.pos.x = W - s.pos.x; s.face = -s.face; s.chain.forEach(v => { v.x = W - v.x; }); };
    [...desks, ...visits, ...meet, ...eat, ...cof, ...wcs, fs].forEach(mS);
    [...st.desk, st.founder].forEach(q => { q.lampPos.x = W - q.lampPos.x; q.screenPos.x = W - q.screenPos.x; }); }
  // building shell
  const low = [], posts = [], band = M(0xefe2c8, { r: .8 });
  let fades = [];
  if (env !== 'mevcut') {
    const fac = M(0xc98f6d, { r: .9 });
    B(g, -.2, W + .25, GY, -.3, D, D + .25, fac); B(g, W, W + .25, GY, -.3, -.2, D + .25, fac);
    for (const yb of [GY + 3.3, -.3]) { B(g, -.2, W + .3, yb - .16, yb, D + .25, D + .3, band, nc); B(g, W + .25, W + .3, yb - .16, yb, -.2, D + .3, band, nc); }
    for (let f = 0; f < 2; f++) { const y = GY + f * 3.3, R = rng(31 + f);
      const mk = (m) => { m.userData.sched = { on: 450 + R() * 70, off: 1070 + R() * 200, allNight: R() < .1 }; low.push(m); };
      const sch = () => ({ on: 450 + R() * 70, off: 1070 + R() * 200, allNight: R() < .1 });
      const gf = grp(g, 0, 0, D + .25), gr = grp(g, W + .25, 0, 0, PI / 2);
      for (let x = .8; x + 1.6 <= W - .4; x += 2.4) { if (f === 0 && env === 'cevre' && x > 1.8 && x < 5.8) continue; winUnit(gf, x, x + 1.6, y + .9, y + 2.5, low, sch(), band); }
      for (let z = .8; z + 1.6 <= D - .2; z += 2.4) winUnit(gr, -(z + 1.6), -z, y + .9, y + 2.5, low, sch(), band);
    }
    const fz = new THREE.Mesh(PLANEG, fadeMat); fz.scale.set(W + .6, -.3 - GY + .05, 1); fz.position.set(W / 2, (GY - .3) / 2, D + .4); fz.renderOrder = 3; g.add(fz);
    const fx = new THREE.Mesh(PLANEG, fadeMat); fx.scale.set(D + .6, -.3 - GY + .05, 1); fx.rotation.y = PI / 2; fx.position.set(W + .4, (GY - .3) / 2, D / 2); fx.renderOrder = 3; g.add(fx);
    fades = [fz, fx];
  }
  if (env === 'cevre') {
    const nE = o => (o.userData.noEdge = true, o);
    nE(floorP(g, -80, W + 90, -80, D + 140, GY, groundMat, 4));
    nE(B(g, -80, W + 3.2, GY, GY + .12, D + .25, D + 3.2, walkMat, nc)); nE(B(g, W + .25, W + 3.2, GY, GY + .12, -80, D + 3.2, walkMat, nc));
    nE(B(g, -80, W + 90, GY, GY + .04, D + 3.2, D + 9.5, roadMat, nc)); nE(B(g, W + 3.2, W + 9.5, GY, GY + .04, -80, D + 9.5, roadMat, nc));
    for (let x = -20; x < W + 30; x += 3) nE(B(g, x, x + 1.4, GY + .04, GY + .05, D + 6.25, D + 6.45, lineMat, nc));
    for (let z = -20; z < D + 3; z += 3) nE(B(g, W + 6.25, W + 6.45, GY + .04, GY + .05, z, z + 1.4, lineMat, nc));
    for (let i = 0; i < 6; i++) nE(B(g, W + 3.4 + i * 1.0, W + 3.9 + i * 1.0, GY + .04, GY + .05, D + 3.4, D + 9.3, lineMat, nc));
    nE(floorP(g, -16, W + 3.2, D + 9.5, D + 40, GY + .06, grassMat, 4));
    B(g, -16, W + 3.2, GY, GY + .35, D + 9.5, D + 9.8, band, nc);
    nE(B(g, -16, W + 3.2, GY, GY + .09, D + 17, D + 18.4, walkMat, nc)); nE(B(g, 8.4, 9.8, GY, GY + .09, D + 9.8, D + 40, walkMat, nc));
    { const water = new THREE.MeshBasicMaterial({ color: 0x7fb3c9 }); water.userData.base = new THREE.Color(0x7fb3c9); hazeMats.push(water); nE(Cy(g, 3.6, .04, 15.5, GY + .08, D + 26, water, { sz: .55, cast: false })); B(g, 11.8, 19.2, GY + .06, GY + .12, D + 23.8, D + 24.1, band, nc); }
    for (let x = -14; x < W + 3; x += 2.7) tree(g, x, GY + .06, D + 11, .95);
    for (const [cx, cc, tx] of [[-3, 0xc0583f], [6.5, 0x3f6f7a], [13, 0xf2c230, 1], [-10, 0x6f9a7a], [17.2, 0xe9e4da]]) car(g, cx, GY + .04, D + 3.95, 0, cc, !!tx);
    car(g, W + 3.95, GY + .04, 2, PI / 2, 0x34384a); car(g, W + 3.95, GY + .04, 9, PI / 2, 0xf2c230, true); car(g, W + 8.7, GY + .04, -6, -PI / 2, 0xd98c5f);
    nE(B(g, W + 9.5, W + 12, GY, GY + .12, -80, D + 9.5, walkMat, nc));
    { const nb = (x0, x1, z0, z1, h, c) => { const m = brickMat(c, (x1 - x0) / 2.4, (h - GY) / 1.5); B(g, x0, x1, GY, h, z0, z1, m, nc); B(g, x0 - .1, x1 + .1, h, h + .35, z0 - .1, z1 + .1, hazeMat(0xefe2c8), nc); return m; };
      nb(-12.5, -.3, -6, D + .25, GY + 5 * 3.3, 0xdcc0a0);
      const gl = grp(g, 0, 0, D + .25), bnd = M(0xefe2c8, { r: .8 }), R2 = rng(88);
      for (let f = 0; f < 5; f++) for (let x = -11.6; x + 1.5 <= -.9; x += 2.6) winUnit(gl, x, x + 1.5, GY + f * 3.3 + .9, GY + f * 3.3 + 2.5, low, { on: 450 + R2() * 70, off: 1060 + R2() * 220, allNight: R2() < .1 }, bnd);
      const back = [[-12.5, 3, -22, -.26, 7.4, 0xc0876a], [3, 12, -18, -.26, 4.2, 0xcfa585], [12, W + .25, -24, -.26, 7.4, 0xb97a60], [W + 12, W + 26, -26, -4, 1.0, 0xc9a07e]];
      for (const [x0, x1, z0, z1, h, c] of back) {
        nb(x0, x1, z0, z1, h, c);
        if (x1 > W) { const gx = grp(g, x1, 0, 0, PI / 2);
          for (let yb = GY + 3.3; yb < h - .5; yb += 3.3) B(gx, -z1, -z0, yb - .14, yb, 0, .05, hazeMat(0xefe2c8), nc);
          for (let f = 0; GY + f * 3.3 + 2.5 < h; f++) for (let z = z0 + .9; z + 1.5 <= z1 - .6; z += 2.6) winUnit(gx, -(z + 1.5), -z, GY + f * 3.3 + .9, GY + f * 3.3 + 2.5, low, { on: 450 + R2() * 70, off: 1060 + R2() * 240, allNight: R2() < .08 }, bnd); }
        if (z1 > -1) continue;
        const gz = grp(g, 0, 0, z1);
        for (let yb = GY + 3.3; yb < h - .5; yb += 3.3) B(gz, x0, x1, yb - .14, yb, 0, .05, hazeMat(0xefe2c8), nc);
        for (let f = 0; GY + f * 3.3 + 2.5 < h; f++) for (let x = x0 + .9; x + 1.5 <= x1 - .6; x += 2.6) winUnit(gz, x, x + 1.5, GY + f * 3.3 + .9, GY + f * 3.3 + 2.5, low, { on: 450 + R2() * 70, off: 1060 + R2() * 240, allNight: R2() < .08 }, bnd);
      } }
    const e = M(0x2c3446, { r: .2 }); B(g, 2.4, 5.6, GY, GY + 2.6, D + .25, D + .3, e); B(g, 2.0, 6.0, GY + 2.7, GY + 2.86, D + .25, D + 1.8, band2()); low.push(Object.assign(B(g, 2.6, 5.4, GY + .1, GY + 2.5, D + .31, D + .32, lowDark, nc), { userData: { sched: { on: 460, off: 1150, allNight: true } } }));
    plant(g, 1.6, GY + .12, D + .8, 1.1, 0); plant(g, 6.4, GY + .12, D + .8, 1.1, 0);
    for (let x = -6; x < W + 2; x += 5.5) tree(g, x + 1.2, GY + .12, D + 2.2, 1, true);
    for (let z = 1; z < D; z += 5.5) tree(g, W + 2.2, GY + .12, z, 1, true); for (let z = -12; z < D; z += 6) tree(g, W + 10.7, GY + .12, z, .9, true);
    const R = rng(71);
    for (let i = 0; i < 26; i++) { const x = -14 + R() * (W + 16), z = D + 12.5 + R() * 26; if (Math.abs(z - D - 17.7) < 1.5 || Math.abs(x - 9.1) < 1.4 || (Math.abs(x - 15.5) < 4.4 && Math.abs(z - D - 26) < 2.6)) continue; tree(g, x, GY + .06, z, .8 + R() * .5); }
    bench(g, 4, GY + .09, D + 16.4, 0); bench(g, 14, GY + .09, D + 16.4, 0); bench(g, 11, GY + .09, D + 22, -PI / 2);
    for (let x = -4; x < W + 3; x += 9) lampPost(g, posts, x, GY + .12, D + 2.9);
    lampPost(g, posts, 7.6, GY + .09, D + 18.8); lampPost(g, posts, 15.6, GY + .09, D + 18.8); lampPost(g, posts, 10.4, GY + .09, D + 30);
  }
  function band2() { return M(0xefe2c8, { r: .8 }); }
  const OUT = S(.75, 0, 7.1, PI / 2, 'out', [[2.0, 7.1]]);
  const bounds = env === 'mevcut' ? new THREE.Box3(V(-1, 0, 0), V(W, 2.8, D)) : env === 'bina' ? new THREE.Box3(V(-1, -3.2, 0), V(W + .3, 2.8, D + .3)) : new THREE.Box3(V(-3, GY, -1), V(W + 8, 2.8, D + 20));
  return {
    g, bounds, sunOff: V(16, 30, 22), fog: false, sky: [], sconces: (() => { const sc = []; sconce(sc, g, 12.5, 2.5, .1); sconce(sc, g, 16.0, 2.5, .1); sconce(sc, g, 19.5, 2.5, .1); sconce(sc, g, 6, 2.3, .1); sconce(sc, g, .1, 2.2, 8.9, PI / 2); sconce(sc, g, .1, 2.2, 11.8, PI / 2); sconce(sc, g, .1, 2.2, 14.3, PI / 2); return sc; })(),
    panes: PANES.slice(), low, posts, fades, pool, env,
    spot(p, s) { switch (s.k) { case 'desk': return p.id === 0 ? fs : desks[p.id - 1]; case 'visit': return visits[s.i % visits.length]; case 'meet': return meet[s.i % 7]; case 'eat': return eat[s.i % 4]; case 'coffee': return cof[s.i % 4]; case 'wc': return wcs[s.i % 2]; default: return OUT; } },
    elev: { o: 0, panels: [{ m: elL, ax: 'z', p0: elL.position.z, d: -.62 }, { m: elR, ax: 'z', p0: elR.position.z, d: .62 }], near: q => Math.abs(q.x - 1.4) < 1.6 && Math.abs(q.z - 7.1) < 1.3 },
    maxN: 10, spd: SPEED,
    station: p => p.id === 0 ? st.founder : st.desk[p.id - 1], stations: [...st.desk, st.founder], connector: () => [],
  };
}
function patchLunch(P) {
  [[7, 2], [10, 3]].forEach(([id, seat]) => { const p = P.find(q => q.id === id); if (!p) return;
    const i = p.events.findIndex(e => e.a === 'out' && e.s.k === 'out'); if (i < 0) return;
    p.events[i] = { t: 752 + seat * 2, s: { k: 'eat', i: seat }, a: 'food', lab: 'Öğle yemeği · mutfakta' };
    const j = p.events.findIndex((e, k) => k > i && e.s.k === 'desk'); if (j > 0) p.events[j] = { ...p.events[j], t: 808 + seat, lab: 'Masaya dönüş' };
    p.events.sort((a, b) => a.t - b.t); });
  return P;
}
function patchFounder(P, N) {
  const p = P[0], R = rng(4242), E = [], nm = id => (P.find(q => q.id === id) || {}).name || '';
  const d = (t, a, lab, full) => E.push({ t, s: { k: 'desk' }, a, lab, full });
  const tour = t => { const used = new Set(); for (let j = 0; j < Math.min(3, N); j++) { let id = 1 + Math.floor(R() * N), g = 0; while (used.has(id) && g++ < 12) id = 1 + Math.floor(R() * N); used.add(id); E.push({ t: t + j * 7, s: { k: 'visit', i: id - 1 }, a: 'visit', full: 'Masa ziyareti · ' + nm(id) }); } d(t + 7 * Math.min(3, N), 'plan', 'Ofisine dönüş'); };
  d(480, 'plan', 'Geliş');
  E.push({ t: 560, s: { k: 'coffee', i: 3 }, a: 'coffee', lab: 'Kahve' }); d(568, 'plan', 'Ofisine dönüş');
  tour(600);
  E.push({ t: 660, s: { k: 'meet', i: 6 }, a: 'meeting', lab: 'Toplantı · ürün, yazılım, tasarım' }); d(705, 'plan', 'Ofisine dönüş');
  E.push({ t: 758, s: { k: 'out' }, a: 'out', lab: 'Öğle yemeği · dışarıda' }); d(812, 'plan', 'Öğleden dönüş');
  tour(835);
  E.push({ t: 875, s: { k: 'wc', i: 1 }, a: 'wc', lab: 'Tuvalet' }); d(881, 'plan', 'Ofisine dönüş');
  E.push({ t: 900, s: { k: 'desk' }, a: 'phone', full: 'Yatırımcı görüşmesi' }); d(940, 'plan', null, 'Ofiste · planlama');
  tour(985);
  E.push({ t: 1030, s: { k: 'coffee', i: 3 }, a: 'coffee', lab: 'Kahve' }); d(1038, 'plan', 'Ofisine dönüş');
  E.push({ t: 1250, s: { k: 'coffee', i: 2 }, a: 'coffee', lab: 'Akşam kahvesi' }); d(1258, 'plan', 'Ofisine dönüş');
  E.push({ t: 1395, s: { k: 'out' }, a: 'home', lab: 'Çıkış' });
  E.sort((a, b) => a.t - b.t); p.events = E; return P;
}

// ---------- rigged characters ----------
let XB = null, XB_LOADING = null;
function loadXbot() {
  if (XB_LOADING) return XB_LOADING;
  const loader = new GLTFLoader();
  const urls = ['https://threejs.org/examples/models/gltf/Xbot.glb', 'https://raw.githubusercontent.com/mrdoob/three.js/r160/examples/models/gltf/Xbot.glb'];
  return XB_LOADING = new Promise((res, rej) => { let i = 0; const next = () => { if (i >= urls.length) return rej(new Error('xbot')); loader.load(urls[i++], res, undefined, next); }; next(); }).then(gltf => {
    const clips = {}; gltf.animations.forEach(a => clips[a.name] = a);
    const tmp = skClone(gltf.scene), mix = new THREE.AnimationMixer(tmp); mix.clipAction(clips.idle).play(); mix.update(0); tmp.updateMatrixWorld(true);
    const bn = n => tmp.getObjectByName(n), wp = o => o.getWorldPosition(V());
    const head = wp(bn('mixamorigHead')), hips = wp(bn('mixamorigHips')), foot = wp(bn('mixamorigLeftFoot')), toe = wp(bn('mixamorigLeftToeBase') || bn('mixamorigLeftToe_End') || bn('mixamorigLeftFoot'));
    const flip = toe.z >= foot.z ? 0 : PI, k = 1.58 / head.y;
    XB = { scene: gltf.scene, clips, flip, k, hipY: hips.y * k };
    return XB;
  });
}
const _q = new THREE.Quaternion(), _qw = new THREE.Quaternion(), _qp = new THREE.Quaternion(), _ax = V();
function rotW(bone, axis, ang) {
  if (!bone) return;
  _q.setFromAxisAngle(axis, ang); bone.getWorldQuaternion(_qw); _qw.premultiply(_q);
  bone.parent.getWorldQuaternion(_qp); bone.quaternion.copy(_qp.invert().multiply(_qw)); bone.updateMatrixWorld(true);
}
const HITG = new THREE.BoxGeometry(.6, 1.7, .6), RINGF = new THREE.RingGeometry(.42, .56, 40), RINGS = new THREE.RingGeometry(.6, .7, 40);
const CHARS = [
  { name: 'Deniz Kaya', skin: 0xd9b28f, hair: 0x2b2522, hs: 'part', style: 3, sleeve: 2, inner: 0x1d1f24, bot: 0x22252c, shoe: 0xf2f0ea, sole: 0xffffff, h: 1.03, wd: 1.0 },
  { name: 'Mert Demir', skin: 0xe8c3a0, hair: 0x5a3b26, hs: 'crop', style: 2, sleeve: 2, inner: 0xe9e6df, bot: 0x4a4f57, shoe: 0x2e3238, sole: 0xf0efe9, h: 1.01, wd: 1.04 },
  { name: 'Zeynep Arslan', skin: 0xd4a37f, hair: 0x1c1c1c, hs: 'pony', style: 9, sleeve: 2, bot: 0x1f2126, shoe: 0x17181b, h: .96, wd: .93 },
  { name: 'Can Yıldız', skin: 0xf0d2b6, hair: 0x8b6a45, hs: 'buzz', beard: 1, style: 1, sleeve: 2, tie: 0x2b2f3a, bot: 0x2d3a55, shoe: 0x5a3a24, sole: 0x3a2618, h: 1.05, wd: 1.08 },
  { name: 'Elif Şahin', skin: 0xb07a55, hair: 0x2b2522, hs: 'bun', style: 4, sleeve: 2, bottom: 1, bot: 0x2f3137, legs: 0x26262b, shoe: 0x3a2a22, h: .95, wd: .94 },
  { name: 'Burak Koç', skin: 0xe2b995, hair: 0x2b2522, hs: 'long', beard: 1, style: 0, sleeve: 1, bot: 0x5c6146, shoe: 0x8d9197, sole: 0xf0efe9, h: 1.0, wd: 1.03 },
  { name: 'Selin Aydın', skin: 0xf3dcc4, hair: 0xb87434, hs: 'wavy', style: 5, sleeve: 2, inner: 0xf1eee8, bot: 0x7a93b3, shoe: 0xf2f0ea, sole: 0xffffff, h: .98, wd: .94 },
  { name: 'Emre Öztürk', skin: 0x8a5a3b, hair: 0x1c1c1c, hs: 'curly', glasses: 1, style: 6, sleeve: 1, bot: 0xbfa983, shoe: 0x5a3a24, sole: 0x3a2618, h: 1.04, wd: 1.0 },
  { name: 'Ece Çelik', skin: 0xd9b28f, hair: 0x6e3b22, hs: 'bob', style: 7, sleeve: 1, legsSkin: 1, bot: 0x2a2a2e, shoe: 0x2a2a2e, h: .97, wd: .93 },
  { name: 'Kerem Kılıç', skin: 0xc79b78, hair: 0x9a9a9a, hs: 'quiff', beard: 2, style: 8, sleeve: 2, inner: 0xeef1f4, bot: 0x55585e, shoe: 0x1b1c1f, h: 1.02, wd: 1.05 },
];
const SKINS = [0xe8c3a0, 0xd4a37f, 0xb07a55, 0x8a5a3b, 0xf0d2b6, 0xc79b78], HAIRS = [0x2b2522, 0x5a3b26, 0x8b6a45, 0x1c1c1c, 0x6e3b22, 0xa8793f], BOTS = [0x22252c, 0x4a4f57, 0x2d3a55, 0x5c6146, 0x7a93b3, 0x3a3230];
function charLook(p) {
  const i = p.id % CHARS.length, k = Math.floor(p.id / CHARS.length), C = CHARS[i]; let o = C;
  if (k) o = { ...C, skin: SKINS[(i + k * 2) % 6], hair: C.hair === 0x9a9a9a ? C.hair : HAIRS[(i + k) % 6], bot: C.bottom ? C.bot : BOTS[(i + k * 3) % 6] };
  return { ...o, legs: o.legsSkin ? o.skin : (o.legs ?? o.bot) };
}
const SPH = new THREE.SphereGeometry(1, 14, 10), HG = {};
let HEADM = null, LM = null;
function headGeo(C) {
  const key = [C.hs, C.hair, C.skin, C.beard || 0, C.glasses || 0].join('|'); if (HG[key]) return HG[key];
  const parts = [], sk = new THREE.Color(C.skin), hc = C.hair, sd = sk.clone().multiplyScalar(.86).getHex();
  const add = (col, sx, sy, sz, x, y, z, rx = 0, rz = 0, geo = SPH) => { const q = geo.clone(); q.scale(sx, sy, sz); if (rx) q.rotateX(rx); if (rz) q.rotateZ(rz); q.translate(x, y, z); const c = new THREE.Color(col), n = q.attributes.position.count, a = new Float32Array(n * 3); for (let j = 0; j < n; j++) { a[j * 3] = c.r; a[j * 3 + 1] = c.g; a[j * 3 + 2] = c.b; } q.setAttribute('color', new THREE.BufferAttribute(a, 3)); parts.push(q); };
  add(C.skin, .105, .12, .11, 0, .12, .01);
  for (const s of [-1, 1]) { add(C.skin, .02, .032, .014, s * .103, .115, .012); add(0x1c1a1f, .011, .013, .007, s * .036, .127, .107); add(hc, .024, .0055, .01, s * .037, .149, .106, 0, s * -.12); }
  add(sd, .014, .02, .018, 0, .102, .116); add(0x8e4f48, .02, .0045, .006, 0, .072, .107);
  const top = (dy = 0) => { add(hc, .113, .07, .118, 0, .185 + dy, 0); add(hc, .109, .095, .1, 0, .145, -.035); };
  switch (C.hs) {
    case 'crop': top(); for (const s of [-1, 1]) add(hc, .012, .03, .02, s * .1, .118, .03); break;
    case 'part': top(); add(hc, .08, .035, .1, .03, .235, .02, 0, -.25); for (const s of [-1, 1]) add(hc, .012, .03, .02, s * .1, .118, .03); break;
    case 'quiff': top(); add(hc, .065, .05, .07, 0, .24, .06, -.45); break;
    case 'buzz': add(hc, .108, .072, .113, 0, .165, -.006); add(hc, .1, .08, .09, 0, .12, -.04); break;
    case 'long': top(); add(hc, .105, .15, .055, 0, .06, -.075); for (const s of [-1, 1]) add(hc, .032, .11, .06, s * .09, .075, .03); break;
    case 'wavy': top(); add(hc, .108, .16, .06, 0, .05, -.075); for (const s of [-1, 1]) { add(hc, .036, .12, .065, s * .09, .07, .025); add(hc, .045, .05, .045, s * .085, 0, -.02); } add(hc, .05, .05, .05, 0, -.03, -.08); break;
    case 'pony': top(-.005); add(hc, .035, .1, .035, 0, .09, -.14, .35); add(0x2f2f35, .022, .014, .022, 0, .165, -.125); break;
    case 'bun': top(-.005); add(hc, .05, .045, .05, 0, .245, -.05); break;
    case 'bob': top(); add(hc, .12, .09, .118, 0, .1, -.02); add(hc, .085, .03, .03, 0, .19, .095); break;
    case 'curly': add(hc, .11, .08, .115, 0, .17, -.01); for (let j = 0; j < 11; j++) { const a = j / 11 * PI * 2, e = j % 2 ? .55 : .95; add(hc, .052, .05, .052, Math.cos(a) * .085 * e, .19 + (j % 2 ? .04 : 0), Math.sin(a) * .09 * e - .01); } break;
  }
  if (C.beard === 1) { add(hc, .088, .06, .07, 0, .055, .052); add(hc, .035, .009, .012, 0, .087, .113); }
  if (C.beard === 2) add(new THREE.Color(hc).lerp(sk, .45).getHex(), .09, .052, .066, 0, .062, .052);
  if (C.glasses) { for (const s of [-1, 1]) { add(0x16181c, .048, .03, .006, s * .037, .128, .118, 0, 0, BOXG); add(0x16181c, .005, .005, .1, s * .075, .13, .07, 0, 0, BOXG); } add(0x16181c, .022, .005, .006, 0, .132, .12, 0, 0, BOXG); }
  const merged = mergeGeometries(parts, false); parts.forEach(q => q.dispose());
  return HG[key] = merged;
}
function bodyLM(mesh) {
  const sk = mesh.skeleton, P = {}, m4 = new THREE.Matrix4();
  sk.bones.forEach((b, i) => { m4.copy(sk.boneInverses[i]).invert(); P[b.name.replace(/^mixamorig:?/, '')] = V().setFromMatrixPosition(m4).applyMatrix4(mesh.bindMatrixInverse); });
  const Up = P.Neck.clone().sub(P.Hips).normalize(), Lx = P.LeftHand.clone().sub(P.RightHand); Lx.addScaledVector(Up, -Lx.dot(Up)).normalize();
  const F = V().crossVectors(Lx, Up).normalize(), toe = P.LeftToeBase || P.LeftToe_End; if (toe && toe.clone().sub(P.LeftFoot).dot(F) < 0) F.negate();
  const pos = mesh.geometry.attributes.position; let mn = 1e9, mx = -1e9;
  for (let i = 0; i < pos.count; i++) { const d = pos.getX(i) * Up.x + pos.getY(i) * Up.y + pos.getZ(i) * Up.z; if (d < mn) mn = d; if (d > mx) mx = d; }
  const O = P.Hips.clone().addScaledVector(Up, mn - P.Hips.dot(Up)), hy = v => v.clone().sub(O).dot(Up), lx = v => Math.abs(v.clone().sub(O).dot(Lx)), f = v => ({ value: v });
  return { uO: f(O), uU: f(Up), uL: f(Lx), uF: f(F), uH: f(mx - mn), uNeck: f(hy(P.Neck)), uSh: f(hy(P.LeftArm)), uChest: f(hy(P.Spine2)), uWaist: f(hy(P.Hips) * .4 + hy(P.Spine) * .6), uHip: f(hy(P.LeftUpLeg)), uKnee: f(hy(P.LeftLeg)), uAnk: f(hy(P.LeftFoot)), uXsh: f(lx(P.LeftArm)), uXel: f(lx(P.LeftForeArm)), uXwr: f(lx(P.LeftHand)), uHwr: f(hy(P.LeftHand)) };
}
const OUTFIT_FS = `
uniform vec3 uO, uU, uL, uF; uniform float uH, uNeck, uSh, uChest, uWaist, uHip, uKnee, uAnk, uXsh, uXel, uXwr, uHwr;
uniform vec3 cSkin, cTop, cIn, cBot, cLegs, cShoe, cSole, cTie; uniform float sSt, sSl, sBo, sTie;
varying vec3 vRest;
bool isSt(float a) { return abs(sSt - a) < .5; }
vec3 outfit() {
  vec3 p = vRest - uO; float H = uH, y = dot(p, uU), ax = abs(dot(p, uL)); bool fr = dot(p, uF) > 0.0;
  if (ax > uXsh * 1.02 && y > min(uHwr, uSh) - .08 * H) {
    vec3 sc = isSt(8.0) ? cIn : cTop;
    float e = sSl < .5 ? uXsh * 1.06 : (sSl < 1.5 ? mix(uXsh, uXel, .6) : uXwr - .012 * H);
    if (ax < e) return (sSl > 1.5 && ax > e - .016 * H) ? sc * .8 : sc;
    return cSkin;
  }
  if (y > uNeck - .008 * H) return (isSt(4.0) && y < uNeck + .03 * H) ? cTop * .92 : cSkin;
  float ny = uNeck - .03 * H;
  if (y > uWaist) {
    if (isSt(3.0) || isSt(5.0)) {
      float vy = uChest - .015 * H, vw = (y - vy) * .42;
      if (fr && y > vy && ax < vw) { if (sTie > .5 && ax < .011 * H && y < ny) return cTie; return (y > ny - .01 * H && ax < .022 * H) ? cSkin : cIn; }
      if (isSt(3.0) && fr && y > vy - .02 * H && ax < vw + .014 * H) return cTop * .72;
      if (isSt(5.0) && fr && ax < .005 * H && mod(y, .05 * H) < .014 * H) return cTop * .55;
      return cTop;
    }
    if (isSt(1.0) || isSt(6.0) || isSt(8.0)) {
      if (y > ny - .014 * H && ax < .055 * H) return (isSt(8.0) ? cIn : cTop) * 1.1;
      if (isSt(8.0) && fr && y > uChest - .03 * H && ax < (y - (uChest - .03 * H)) * .45) return cIn;
      if (fr && ax < .0045 * H && (!isSt(6.0) || y > ny - .07 * H)) return cTop * .78;
      if (isSt(1.0) && sTie > .5 && fr && y > uWaist + .05 * H && ax < mix(.017, .009, clamp((y - uWaist) / (ny - uWaist), 0.0, 1.0)) * H) return cTie;
      return cTop;
    }
    if (isSt(2.0)) {
      if (fr && y > uWaist + .05 * H && y < uWaist + .15 * H && ax < .075 * H) return cTop * .84;
      if (fr && ax > .016 * H && ax < .022 * H && y > ny - .11 * H && y < ny) return cIn;
      if (!fr && y > ny - .03 * H) return cTop * .8;
      if (y < uWaist + .03 * H) return cTop * .84;
      return cTop;
    }
    if (!isSt(4.0) && fr && y > ny - .01 * H + pow(ax / (.06 * H), 2.0) * .03 * H) return cSkin;
    return cTop;
  }
  if (isSt(7.0)) { if (y > uKnee + .025 * H) return y > uWaist - .012 * H ? cTop * .8 : cTop; if (y > uAnk + .012 * H) return cLegs; }
  else {
    if (isSt(3.0) && y > uHip + .02 * H) return cTop;
    if (sBo > .5 && sBo < 1.5) { if (y > uKnee + .03 * H) return y > uWaist - .014 * H ? cBot * .8 : cBot; if (y > uAnk + .012 * H) return cLegs; }
    else { if (!isSt(2.0) && y > uWaist - .022 * H) return cShoe * .8 + vec3(.02); if (y > uAnk + .012 * H) return cBot; }
  }
  return y > .014 * H ? cShoe : cSole;
}
`;
function outfitMat(U) {
  const m = new THREE.MeshToonMaterial({ color: 0xffffff, gradientMap: GRAD });
  m.onBeforeCompile = sh => { Object.assign(sh.uniforms, U);
    sh.vertexShader = 'varying vec3 vRest;\n' + sh.vertexShader.replace('#include <begin_vertex>', '#include <begin_vertex>\n\tvRest = position;');
    sh.fragmentShader = OUTFIT_FS + sh.fragmentShader.replace('vec4 diffuseColor = vec4( diffuse, opacity );', 'vec4 diffuseColor = vec4( outfit(), opacity );'); };
  m.customProgramCacheKey = () => 'outfit-v1';
  return track(m);
}
function makeBot(p, pick) {
  const isF = p.id === 0, root = new THREE.Group(), holder = new THREE.Group(); root.add(holder);
  const C = charLook(p), hs = (C.h || 1) * (isF ? 1.02 : 1);
  holder.rotation.y = XB.flip; holder.scale.setScalar(XB.k * hs);
  const model = skClone(XB.scene); holder.add(model);
  let surf = null; model.traverse(o => { if (o.isSkinnedMesh && !surf && !/joint/i.test(o.material.name || '')) surf = o; });
  if (!LM && surf) LM = bodyLM(surf);
  const col = h => ({ value: new THREE.Color(h) }), sv = v => ({ value: v });
  const mat = outfitMat(Object.assign({}, LM, { cSkin: col(C.skin), cTop: col(ROLES[p.role].color), cIn: col(C.inner ?? 0xeeeeea), cBot: col(C.bot), cLegs: col(C.legs), cShoe: col(C.shoe), cSole: col(C.sole ?? C.shoe), cTie: col(C.tie ?? 0x2b2f3a), sSt: sv(C.style), sSl: sv(C.sleeve), sBo: sv(C.bottom || 0), sTie: sv(C.tie ? 1 : 0) }));
  model.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; o.frustumCulled = false; o.material = mat; } });
  const mixer = new THREE.AnimationMixer(model), idle = mixer.clipAction(XB.clips.idle), walk = mixer.clipAction(XB.clips.walk);
  idle.play(); walk.play(); walk.setEffectiveWeight(0); idle.time = (p.id * .77) % idle.getClip().duration;
  const bn = n => model.getObjectByName('mixamorig' + n);
  const b = { lUp: bn('LeftUpLeg'), rUp: bn('RightUpLeg'), lLeg: bn('LeftLeg'), rLeg: bn('RightLeg'), lArm: bn('LeftArm'), rArm: bn('RightArm'), lFore: bn('LeftForeArm'), rFore: bn('RightForeArm'), head: bn('Head'), spine: bn('Spine1') };
  if (b.head) { holder.scale.x = holder.scale.z = XB.k * hs; root.updateMatrixWorld(true); const ws = b.head.getWorldScale(V()).x || 1, a = new THREE.Group(); a.scale.setScalar(1 / ws); a.position.set(0, .06 / ws, 0); b.head.add(a);
    HEADM = HEADM || track(new THREE.MeshToonMaterial({ vertexColors: true, gradientMap: GRAD })); const hm = new THREE.Mesh(headGeo(C), HEADM); hm.castShadow = true; hm.frustumCulled = false; a.add(hm);
    holder.scale.x = holder.scale.z = XB.k * hs * (C.wd || 1); }
  const hit = new THREE.Mesh(HITG, new THREE.MeshBasicMaterial()); hit.position.y = .85; hit.visible = false; hit.userData.pid = p.id; root.add(hit); pick.push(hit);
  const sprite = new THREE.Sprite(iconMats().full.code); sprite.renderOrder = 10; sprite.layers.set(1); root.add(sprite);
  const ring = new THREE.Mesh(RINGF, new THREE.MeshBasicMaterial({ color: 0xf0b429, transparent: true, opacity: .9, depthWrite: false, toneMapped: false })); ring.rotation.x = -PI / 2; ring.position.y = .03; root.add(ring);
  const selRing = new THREE.Mesh(RINGS, new THREE.MeshBasicMaterial({ color: 0xffffff, transparent: true, opacity: .95, depthWrite: false, toneMapped: false })); selRing.rotation.x = -PI / 2; selRing.position.y = .035; selRing.visible = false; root.add(selRing);
  return { bot: true, root, mixer, idle, walk, w: 0, b, sprite, ring, selRing, hs };
}

function flipW(gg) { for (const n of ['position', 'normal', 'uv']) { const a = gg.attributes[n]; if (!a) continue; const s = a.itemSize, arr = a.array; for (let i = 0; i < a.count; i += 3) for (let c = 0; c < s; c++) { const i1 = (i + 1) * s + c, i2 = (i + 2) * s + c, t = arr[i1]; arr[i1] = arr[i2]; arr[i2] = t; } } }
function bake(L) {
  const keep = new Set(), add = o => o && o.traverse && o.traverse(c => keep.add(c));
  [...(L.keep || []), ...(L.sconces || []), ...(L.low || []), ...(L.panes || []), ...(L.fades || []), ...(L.pool || [])].forEach(add);
  if (L.elev) L.elev.panels.forEach(p => add(p.m));
  const root = L.g; root.updateMatrixWorld(true);
  const groups = new Map();
  root.traverse(o => { if (!o.isMesh || keep.has(o) || Array.isArray(o.material) || o.material.transparent || o.renderOrder || o.userData.noEdge || !o.geometry.attributes.uv) return;
    const k = o.material.uuid + (o.castShadow ? 'c' : 'n'); if (!groups.has(k)) groups.set(k, []); groups.get(k).push(o); });
  for (const list of groups.values()) {
    if (list.length < 3) continue;
    const geos = list.map(o => { const gg = o.geometry.index ? o.geometry.toNonIndexed() : o.geometry.clone(); for (const n of Object.keys(gg.attributes)) if (!['position', 'normal', 'uv'].includes(n)) gg.deleteAttribute(n); gg.applyMatrix4(o.matrixWorld); if (o.matrixWorld.determinant() < 0) flipW(gg); return gg; });
    const merged = mergeGeometries(geos, false); geos.forEach(x => x.dispose()); if (!merged) continue;
    const me = new THREE.Mesh(merged, list[0].material); me.castShadow = list[0].castShadow; me.receiveShadow = true; root.add(me);
    list.forEach(o => o.parent && o.parent.remove(o));
  }
}

// ---------- main ----------
export function createOffice(el, cb = {}) {
  initMats();
  const renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setPixelRatio(Math.min(2, window.devicePixelRatio || 1));
  renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFShadowMap;
  renderer.toneMapping = THREE.ACESFilmicToneMapping; renderer.toneMappingExposure = 1.0;
  const canvas = renderer.domElement; canvas.style.cssText = 'display:block;width:100%;height:100%;touch-action:none;cursor:grab';
  el.appendChild(canvas);
  const scene = new THREE.Scene(); scene.background = new THREE.Color(0xd3d6d3);
  const pmrem = new THREE.PMREMGenerator(renderer); scene.environment = pmrem.fromScene(new RoomEnvironment(), .04).texture;
  const cam = new THREE.OrthographicCamera(-1, 1, 1, -1, .1, 600);
  let composer = null, bloom = null, grade = null, art = ART.ink, nt = null, edge = null, fxaa = null, anyIn = false, noEdgeL = [], noEdgeC = [];
  const normalMat = new THREE.MeshNormalMaterial();
  const skyC = document.createElement('canvas'); skyC.width = 2; skyC.height = 256; const skyX = skyC.getContext('2d'); const skyTex = new THREE.CanvasTexture(skyC); skyTex.colorSpace = THREE.SRGBColorSpace; let lastSkyT = -99;
  const _sc = V(), _city = new THREE.Color(), _rd = new THREE.Color();
  try {
    const w0 = Math.max(1, el.clientWidth), h0 = Math.max(1, el.clientHeight);
    composer = new EffectComposer(renderer, new THREE.WebGLRenderTarget(w0 * renderer.getPixelRatio(), h0 * renderer.getPixelRatio(), { samples: 4, type: THREE.HalfFloatType })); composer.addPass(new RenderPass(scene, cam));
    const dpr = renderer.getPixelRatio(); nt = new THREE.WebGLRenderTarget(w0 * dpr, h0 * dpr); nt.depthTexture = new THREE.DepthTexture(w0 * dpr, h0 * dpr); nt.depthTexture.type = THREE.UnsignedIntType;
    edge = new ShaderPass(EdgeShader); edge.uniforms.tNormal.value = nt.texture; edge.uniforms.tDepth.value = nt.depthTexture; edge.uniforms.uTexel.value.set(1.15 / w0, 1.15 / h0); edge.uniforms.uRange.value = cam.far - cam.near; composer.addPass(edge);
    bloom = new UnrealBloomPass(new THREE.Vector2(w0, h0), .3, .55, .95); composer.addPass(bloom);
    composer.addPass(new OutputPass());
    grade = new ShaderPass(GradeShader); grade.uniforms.uRes.value.set(w0 * renderer.getPixelRatio(), h0 * renderer.getPixelRatio()); composer.addPass(grade);
    fxaa = new ShaderPass(FXAAShader); fxaa.uniforms.resolution.value.set(1 / (w0 * renderer.getPixelRatio()), 1 / (h0 * renderer.getPixelRatio())); composer.addPass(fxaa);
  } catch (e) { console.warn('postfx off', e); composer = null; }
  const hemi = new THREE.HemisphereLight(0xffffff, 0x8a8070, .6); scene.add(hemi);
  const amb = new THREE.AmbientLight(0xfff3e0, .4); scene.add(amb);
  const sun = new THREE.DirectionalLight(0xfff4e6, 2); sun.castShadow = true; sun.shadow.mapSize.set(4096, 4096); sun.shadow.bias = -.0004; sun.shadow.normalBias = .03;
  scene.add(sun); scene.add(sun.target);
  const lamps = [0, 1].map(() => { const l = new THREE.SpotLight(0xffb468, 0, 2.4, .9, .9, 2); scene.add(l); scene.add(l.target); return l; });
  const top = new THREE.DirectionalLight(0xfff0dc, 0); top.castShadow = true; top.shadow.mapSize.set(2048, 2048); top.shadow.bias = -.0005; top.shadow.normalBias = .03; scene.add(top); scene.add(top.target);
  const screens = [0, 1].map(() => { const l = new THREE.PointLight(0x8fb8ff, 0, 1.6, 2); scene.add(l); return l; });

  const moteGeo = new THREE.BufferGeometry(), MN = 420, mp = new Float32Array(MN * 3), mseed = new Float32Array(MN);
  { const R = rng(77); for (let i = 0; i < MN; i++) { mp[i * 3] = R(); mp[i * 3 + 1] = R(); mp[i * 3 + 2] = R(); mseed[i] = R() * 100; } }
  moteGeo.setAttribute('position', new THREE.BufferAttribute(new Float32Array(MN * 3), 3));
  const moteMat = new THREE.PointsMaterial({ color: 0xffe2b0, size: 3, sizeAttenuation: false, transparent: true, opacity: 0, depthWrite: false, blending: THREE.AdditiveBlending, toneMapped: false });
  const motes = new THREE.Points(moteGeo, moteMat); motes.frustumCulled = false; scene.add(motes);
  function applyArt(k) {
    art = ART[k] || ART.golden;
    COL.day.set(art.day); COL.dusk.set(art.dusk); COL.night.set(art.night); COL.sh.set(art.sun); COL.sl.set(art.low);
    renderer.toneMappingExposure = art.exp; X.wall.color.set(art.wall); X.carpet.color.set(art.carpet);
    const bw = BW(); for (const t in art.bw) bw[t].color.set(art.bw[t]);
    if (grade) { const u = grade.uniforms, g = art.g; u.uSat.value = g.sat; u.uCon.value = g.con; u.uVig.value = g.vig; u.uGrain.value = g.grain; u.uTilt.value = g.tilt; u.uLift.value.set(...g.lift); u.uGain.value.set(...g.gain); u.uSh.value.set(...g.sh); u.uHi.value.set(...g.hi); }
    if (L) placeSun(); motes.visible = !!art.motes;
  }
  function colorScript(t) {
    const v = csAt(t);
    if (Math.abs(t - lastSkyT) > .5) { const g = skyX.createLinearGradient(0, 0, 0, 256); g.addColorStop(0, '#' + v.top.getHexString()); g.addColorStop(1, '#' + v.bot.getHexString()); skyX.fillStyle = g; skyX.fillRect(0, 0, 2, 256); skyTex.needsUpdate = true; lastSkyT = t; }
    scene.background = skyTex; if (scene.fog) scene.fog.color.copy(v.bot);
    const gd0 = sm(425, 540, t) * (1 - sm(1100, 1200, t)), gd = gd0 * gd0; groundMat.color.lerpColors(G_NIGHT, G_DAY, gd); walkMat.color.lerpColors(W_NIGHT, W_DAY, gd);
    hemi.color.copy(v.hs); hemi.groundColor.copy(v.hg); hemi.intensity = v.hi; sun.color.copy(v.sun); sun.intensity = v.si;
    const _unusedNK = 0, nightK = t > 1165 ? 1 : 0, u = nightK ? .35 : Math.min(1, Math.max(0, (t - 425) / 740)), el = (nightK ? 55 : 10 + 48 * Math.sin(PI * u)) * PI / 180, c = L.bounds.getCenter(_sc);
    const az = (mode === 'A' ? PI / 4 : 0) + (u - .5) * (mode === 'A' ? 2.0 : 1.6);
    sun.position.set(c.x + Math.sin(az) * Math.cos(el) * SD, c.y + Math.sin(el) * SD, c.z + Math.cos(az) * Math.cos(el) * SD); sun.target.position.copy(c);
    if (L.sky.length) { _city.copy(v.top).lerp(v.bot, .7).multiplyScalar(.82); for (const m of L.sky) m.color.copy(_city); }
  }
  function renderNormals() {
    if (!nt) return;
    const bg = scene.background, fog = scene.fog, hid = [];
    scene.background = null; scene.fog = null;
    for (const o of noEdgeL.concat(noEdgeC)) if (o.visible) { o.visible = false; hid.push(o); }
    scene.overrideMaterial = normalMat; renderer.shadowMap.autoUpdate = false;
    renderer.setRenderTarget(nt); renderer.setClearColor(0x8080ff, 1); renderer.clear(); renderer.render(scene, cam); renderer.setRenderTarget(null);
    renderer.setClearColor(0x000000, 0); renderer.shadowMap.autoUpdate = true; scene.overrideMaterial = null;
    for (const o of hid) o.visible = true; scene.background = bg; scene.fog = fog;
  }
  function placeSun() { const c = L.bounds.getCenter(V()); const o = L.sunOff.clone(); o.y *= art.sunY; sun.position.copy(c).add(o); sun.target.position.copy(c); }
  let SD = 45, camAnim = null, fitT = V(), hoverId = null;
  let office = 1, env = 'cevre', lastView = -99, fIn = false, mode = 'A', big = false, count = 10, angle = 35, time = 475, playing = true, speed = 1, clock = 0, sel = null, envI = -1;
  const opts = { icons: true, founder: true, fx: true, light: 'tavan' };
  let L = null, chars = [], pick = [], target = V(), zoom = 1, fitZoom = 1;
  const COL = { day: new THREE.Color(0xcfd6db), night: new THREE.Color(0x10131a), dusk: new THREE.Color(0xd9ae90), hd: new THREE.Color(0xffffff), hn: new THREE.Color(0x5a6a90), wd: new THREE.Color(0xdfe9ee), wn: new THREE.Color(0x1c2638), wdu: new THREE.Color(0xf0c49a), sl: new THREE.Color(0xffc890), sh: new THREE.Color(0xfff4e6) };

  const size = () => ({ w: Math.max(1, el.clientWidth), h: Math.max(1, el.clientHeight) });
  function frustum() { const { w, h } = size(), a = w / h; cam.left = -FH * a / 2; cam.right = FH * a / 2; cam.top = FH / 2; cam.bottom = -FH / 2; }
  function camOff() {
    if (mode === 'A') { const e = angle * PI / 180, az = PI / 4; return V(Math.sin(az) * Math.cos(e), Math.sin(e), Math.cos(az) * Math.cos(e)).multiplyScalar(120); }
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
    placeCam(); fitT.copy(target);
  }
  function rebuildPeople() {
    for (const c of chars) scene.remove(c.m.root); chars = []; pick = [];
    const PP = L.noPeople ? [] : L.people ? L.people() : office === 1 ? patchFounder(patchLunch(buildPeople(count)), count) : buildPeopleX(count, L.peopleCfg(count));
    let li = 0;
    for (const p of PP) {
      if (p.id < CHARS.length) p.name = CHARS[p.id].name;
      const m = XB ? makeBot(p, pick) : makeCapsule(p, pick); scene.add(m.root); if (m.sprite) m.sprite.layers.set(1);
      const lastT = p.events[p.events.length - 1].t, lamp = (p.id === 0 || lastT > 1300) && li < 2 ? li++ : -1;
      chars.push({ p, m, lamp, tl: office === 1 ? buildTL(p, L, SPEED) : buildTLX(p, L, L.spd), deskSpot: L.spot(p, { k: 'desk' }), r: { pos: V() } });
    }
    if (sel != null && !chars.find(c => c.p.id === sel)) sel = null;
    noEdgeC = []; for (const c of chars) toonify(c.m.root, noEdgeC);
  }
  function rebuildLayout() {
    if (L) scene.remove(L.g);
    TIER = office === 'city' ? 1 : office; L = office === 'city' ? buildCity(H) : office === 0 ? buildHome(H) : office === 1 ? buildA2(env) : office === 2 ? buildPlaza(H) : buildLoft(H); bake(L); scene.add(L.g); count = Math.min(count, L.maxN);
    for (const pn of L.panes) pn.material = env === 'mevcut' ? winMat : lowDark; lastView = -99;
    SYNC.clear(); noEdgeL = []; toonify(L.g, noEdgeL);
    const c = L.bounds.getCenter(V()), s = L.bounds.getSize(V()), r = Math.max(s.x, s.y, s.z) * .75 + 4;
    placeSun(); top.position.copy(c).add(V(3, 30, 4)); top.target.position.copy(c); Object.assign(top.shadow.camera, { left: -r, right: r, top: r, bottom: -r, near: 1, far: 80 }); top.shadow.camera.updateProjectionMatrix();
    SD = Math.max(45, r); Object.assign(sun.shadow.camera, { left: -r, right: r, top: r, bottom: -r, near: 1, far: Math.max(140, SD + r + 30) }); sun.shadow.camera.updateProjectionMatrix();
    scene.fog = L.fog ? new THREE.Fog(0xcfd6db, L.fog.near || 135, L.fog.far || 200) : null;
    envI = -1; rebuildPeople(); fitView();
  }

  function animCapsule(c, r, clk) {
    const m = c.m;
    m.root.position.copy(r.pos); m.root.rotation.y = r.face; m.inner.position.y = 0; m.inner.rotation.z = 0; m.head.rotation.set(0, 0, 0);
    let lx = 0, rx = 0, al = 0, ar = 0;
    if (r.walking) { if (!r.vert) { const ph = r.d * 4.2; lx = Math.sin(ph) * .6; rx = -lx; al = -lx * .7; ar = lx * .7; m.inner.position.y = Math.abs(Math.cos(ph)) * .05; } }
    else if (r.pose === 'sit') { lx = rx = -PI / 2; m.inner.position.y = -.05; al = ar = -1.2 + Math.sin(clk * 13) * .08; }
    m.lL.rotation.x = lx; m.lR.rotation.x = rx; m.aL.rotation.x = al; m.aR.rotation.x = ar;
    return 1.6;
  }
  function animBot(c, r, dt, wsp, clk) {
    const m = c.m, b = m.b, target = r.walking && !r.vert ? 1 : 0;
    m.w = playing ? m.w + (target - m.w) * Math.min(1, dt * 10) : target;
    m.walk.setEffectiveWeight(m.w); m.idle.setEffectiveWeight(1 - m.w); m.walk.timeScale = Math.max(.6, wsp / 1.25);
    m.mixer.update(playing ? dt : 0);
    const sit = !r.walking && r.pose === 'sit', lie = !r.walking && r.pose === 'lie';
    m.root.position.copy(r.pos); if (sit) m.root.position.y -= XB.hipY * (m.hs || 1) - .56;
    m.root.rotation.order = 'YXZ'; m.root.rotation.set(lie ? -PI / 2 : 0, r.face, 0); m.root.updateMatrixWorld(true);
    _ax.set(Math.cos(r.face), 0, -Math.sin(r.face));
    const a = r.act;
    if (sit) {
      rotW(b.lUp, _ax, -PI / 2); rotW(b.rUp, _ax, -PI / 2); rotW(b.lLeg, _ax, PI / 2); rotW(b.rLeg, _ax, PI / 2);
      if (a === 'code' || a === 'test' || a === 'design') { rotW(b.lArm, _ax, -.5); rotW(b.rArm, _ax, -.5); rotW(b.lFore, _ax, -1.0 + Math.sin(clk * 13) * .08); rotW(b.rFore, _ax, -1.0 + Math.sin(clk * 13 + 1.9) * .08); }
      else if (a === 'research' || a === 'plan') { rotW(b.lArm, _ax, -.4); rotW(b.rArm, _ax, -.4); rotW(b.lFore, _ax, -1.1); rotW(b.rFore, _ax, -1.1 - Math.max(0, Math.sin(clk * .7)) * .4); }
      else if (a === 'phone') { rotW(b.lArm, _ax, -.4); rotW(b.lFore, _ax, -1.1); rotW(b.rArm, _ax, -.35); rotW(b.rFore, _ax, -2.5); }
      else if (a === 'meeting') { rotW(b.lArm, _ax, -.45); rotW(b.rArm, _ax, -.45); rotW(b.lFore, _ax, -1.0); rotW(b.rFore, _ax, -1.0 - Math.max(0, Math.sin(clk * 1.3 + c.p.id)) * .5); }
      else if (a === 'food') { rotW(b.lArm, _ax, -.4); rotW(b.lFore, _ax, -1.0); rotW(b.rArm, _ax, -.4); rotW(b.rFore, _ax, -1.1 - Math.max(0, Math.sin(clk * 2.2)) * 1.0); }
    } else if (!r.walking && a === 'coffee') { rotW(b.rArm, _ax, -.25); rotW(b.rFore, _ax, -1.3 - Math.max(0, Math.sin(clk * 1.1)) * .7); }
    b.head.getWorldPosition(_hp);
    return _hp.y - m.root.position.y + .28;
  }
  const _hp = V();

  function update(dt) {
    const f = time < 425 || time > 1165 ? 0 : Math.sin(PI * (time - 425) / 740);
    const interDay = sm(440, 470, time) * (1 - sm(1142, 1160, time)), nightI = time > 1100 && anyIn ? 1 : 0, _f0 = 0, inter = Math.max(interDay, nightI * .55), wallMode = opts.light === 'duvar';
    top.intensity = interDay * .3 + nightI * (1 - interDay) * (wallMode ? .4 : 1.0);
    glowMat.opacity = nightI * (1 - interDay) * .85; sconceMat.emissiveIntensity = wallMode ? Math.max(interDay * .5, nightI * 2) : 0;
    for (const s of L.sconces) s.visible = wallMode;
    const dusk = f > 0 ? 1 - sm(0, .3, f) : 0;
    colorScript(time);
    amb.intensity = .45 * interDay + .12 * nightI;
    const ei = 0;
    if (ei !== envI) { envI = ei; ALL.forEach(m => { m.envMapIntensity = ei; }); }
    winMat.color.copy(CSV.win);
    ceilMat.emissiveIntensity = inter * 1.3;
    const night = 1 - sm(.05, .35, f); for (const m of L.sky) m.emissiveIntensity = night * .35;
    if (bloom) { bloom.strength = .2 + .3 * (1 - Math.sqrt(f)); bloom.threshold = .95; }
    if (grade) grade.uniforms.uTime.value = performance.now() * .001;
    moteMat.opacity = art.motes * (.25 + .5 * Math.max(dusk, f > 0 ? .4 : 0) + (f === 0 ? .15 : 0));
    if (art.motes) { const b = L.bounds, pa = moteGeo.attributes.position.array, tt = performance.now() * .00004; for (let i = 0; i < MN; i++) { const s = mseed[i]; pa[i * 3] = b.min.x + (mp[i * 3] + Math.sin(tt * 3 + s) * .02) * (b.max.x - b.min.x); pa[i * 3 + 1] = b.min.y + .3 + ((mp[i * 3 + 1] + tt * (.5 + (s % 1))) % 1) * Math.max(2.4, b.max.y - b.min.y - .4); pa[i * 3 + 2] = b.min.z + (mp[i * 3 + 2] + Math.cos(tt * 2 + s) * .02) * (b.max.z - b.min.z); } moteGeo.attributes.position.needsUpdate = true; }
    for (const s of L.stations) { s.lampMat.emissiveIntensity = 0; s.screenMat.emissiveIntensity = 0; }
    lamps.forEach(l => l.intensity = 0); screens.forEach(l => l.intensity = 0);
    const { h } = size(), ppu = h * zoom / FH, iconS = Math.max(.6, 26 / ppu), IM = iconMats(), wsp = SPEED * RATE * speed;
    let present = false;
    for (const c of chars) {
      const r = evalTLX(c.tl, time, c.r); if (!r.hidden && c.p.id !== 0) present = true; if (c.p.id === 0) fIn = !r.hidden && r.spot === c.deskSpot; const _x = 0, m = c.m, clk = clock + c.p.id * 1.37;
      m.root.visible = !r.hidden; if (r.hidden) continue;
      const headTop = m.bot ? animBot(c, r, dt, wsp, clk) : animCapsule(c, r, clk);
      const ic = ICON[r.act];
      if (opts.icons && ic) { m.sprite.visible = true; m.sprite.material = (r.walking ? IM.dim : IM.full)[ic]; const s = m.bot ? iconS : iconS / m.root.scale.x; m.sprite.scale.set(s, s, 1); m.sprite.position.y = (m.bot ? headTop : headTop / m.root.scale.x) + s * .55; }
      else m.sprite.visible = false;
      m.ring.visible = c.p.id === 0 && opts.founder && r.pose !== 'lie'; m.selRing.visible = c.p.id === sel && r.pose !== 'lie';
      const st = L.station(c.p);
      if (st && r.spot === c.deskSpot) {
        const lampOn = time > 1050 || f < .35;
        st.lampMat.emissiveIntensity = lampOn ? 1.6 : 0; st.screenMat.emissiveIntensity = inter > .5 && f > .3 ? .6 : 1.5;
        if (c.lamp >= 0 && time > 1100) { const k = c.lamp; lamps[k].position.copy(st.lampPos).y += .1; lamps[k].target.position.copy(st.lampPos).y -= 1; lamps[k].intensity = 3; screens[k].position.copy(st.screenPos); screens[k].intensity = .9; }
      }
    }
    anyIn = present;
    if (L.elev) { const E = L.elev; let near = false; for (const c of chars) if (c.r.walking && E.near(c.r.pos)) near = true; E.o += ((near ? 1 : 0) - E.o) * Math.min(1, dt * 6); for (const q of E.panels) { if (q.rot) q.m.rotation.y = q.p0 + q.d * E.o; else q.m.position[q.ax || 'x'] = q.p0 + q.d * E.o; } }
    { const dk = sm(425, 540, time) * (1 - sm(1100, 1200, time)); for (const m of hazeMats) m.color.copy(m.userData.base).lerp(CSV.bot, .3 + .5 * (1 - dk)).multiplyScalar(.1 + .9 * dk); }
    { const nightF = 1 - sm(1100, 1180, time) * 0 - 0; const fo = time > 1080 && fIn ? 1 : 0;
      poolMat.opacity = fo * (anyIn ? .35 : .75); fLampMat.emissiveIntensity = fo * 2 + (sm(440, 470, time) * (1 - sm(1142, 1160, time))) * 0;
      for (const m of L.low) { const s = m.userData.sched, lit = s.allNight ? time > s.on && time < 1440 : time > s.on && time < s.off; m.material = lit && (f < .6) ? lowLit : lowDark; }
      const dayK = sm(425, 540, time) * (1 - sm(1100, 1200, time));
      lowDark.color.copy(CSV.top).lerp(CSV.bot, .4).multiplyScalar(.55 + .25 * dayK);
      fadeMat.color.copy(CSV.bot); fadeMat.opacity = L.env === 'cevre' ? .22 : 1;
      roadMat.color.set(0x151827).lerp(_rd.set(0x6b6f78), dayK * dayK); grassMat.color.set(0x121b2e).lerp(_rd.set(0x9dbb7c), dayK * dayK); lineMat.color.set(0x2e3350).lerp(_rd.set(0xefe9dd), dayK * dayK);
      const pn = 1 - sm(1080, 1150, time) + sm(0, 1, 0); const postOn = time > 1120 || time < 440 ? 1 : 0; postMat.emissiveIntensity = postOn * 2; carHead.emissiveIntensity = postOn * 1.4; carTail.emissiveIntensity = postOn * 1.2; streetGlow.opacity = postOn * .55;
      if (L.tick) L.tick(time, dayK);
      if (false && Math.abs(time - lastView) > 2) { drawView(CSV, dayK * dayK, 1 - sm(1080, 1180, time) < 1 ? sm(1080, 1180, time) : 0); lastView = time; } }
  }

  function syncToon() { SYNC.forEach((s, t) => { t.emissiveIntensity = s.emissiveIntensity; t.color.copy(s.color); t.opacity = s.opacity; }); }
  function _old() { for (const [t, s] of SYNC) { t.emissiveIntensity = s.emissiveIntensity; t.color.copy(s.color); t.opacity = s.opacity; } }
  function info() {
    if (sel == null) return null;
    const c = chars.find(c => c.p.id === sel); if (!c) return null;
    const r = evalTLX(c.tl, time, { pos: V() });
    let ci = -1; c.p.events.forEach((e, i) => { if (e.t <= time) ci = i; });
    const ev = c.p.events[ci], evL = ev ? (ev.full || ev.lab) : '';
    const cur = L.people ? (r.walking ? 'Yürüyor → ' : '') + (evL || '—') : r.hidden ? (r.act === 'out' ? 'Öğle yemeğinde (dışarıda)' : r.idx === 0 ? 'Henüz gelmedi' : 'Eve gitti') : (r.walking ? 'Yürüyor → ' : '') + ACT_LABEL[r.act];
    const items = c.p.events.map((e, i) => ({ time: fmt(e.t), label: e.full || (e.s.k === 'desk' ? e.lab + ' · ' + SHORT[e.a] : e.lab), bg: i === ci ? 'rgba(255,255,255,.10)' : 'transparent', fw: i === ci ? '600' : '400', op: i <= ci ? '1' : '.72' }));
    return { id: c.p.id, name: c.p.name, role: ROLES[c.p.role].name, color: '#' + ROLES[c.p.role].color.toString(16).padStart(6, '0'), current: cur, items };
  }

  const ray = new THREE.Raycaster(), ndc = new THREE.Vector2();
  const _hv = V();
  function mapHitAt(e) {
    if (!L.mapHits) return null; const r = canvas.getBoundingClientRect();
    ndc.set(((e.clientX - r.left) / r.width) * 2 - 1, -((e.clientY - r.top) / r.height) * 2 + 1); ray.setFromCamera(ndc, cam);
    let best = null, bd = 1e9; for (const h of L.mapHits) { const p = ray.ray.intersectBox(h.box, _hv); if (p) { const d = p.distanceTo(ray.ray.origin); if (d < bd) { bd = d; best = h.id; } } } return best;
  }
  function pickAt(e) {
    if (L.mapHits) return null;
    const r = canvas.getBoundingClientRect();
    ndc.set(((e.clientX - r.left) / r.width) * 2 - 1, -((e.clientY - r.top) / r.height) * 2 + 1);
    ray.setFromCamera(ndc, cam);
    const vis = pick.filter(m => { const c = chars.find(c => c.p.id === m.userData.pid); return c && c.m.root.visible; });
    const hit = ray.intersectObjects(vis, false)[0]; return hit ? hit.object.userData.pid : null;
  }
  let drag = null;
  const onDown = e => { camAnim = null; drag = { x: e.clientX, y: e.clientY, sx: e.clientX, sy: e.clientY }; canvas.setPointerCapture(e.pointerId); canvas.style.cursor = 'grabbing'; };
  const onMove = e => {
    if (drag) {
      const dx = e.clientX - drag.x, dy = e.clientY - drag.y; drag.x = e.clientX; drag.y = e.clientY;
      const { h } = size(), upp = FH / (zoom * h), right = V(1, 0, 0).applyQuaternion(cam.quaternion), up = V(0, 1, 0).applyQuaternion(cam.quaternion);
      target.addScaledVector(right, -dx * upp).addScaledVector(up, dy * upp); placeCam();
    } else if (L.mapHits) { const id = mapHitAt(e); canvas.style.cursor = id ? 'pointer' : 'grab'; hoverId = id; cb.onMapHover && cb.onMapHover(id, e.clientX, e.clientY); }
    else canvas.style.cursor = pickAt(e) != null ? 'pointer' : 'grab';
  };
  const onUp = e => { if (drag && Math.hypot(e.clientX - drag.sx, e.clientY - drag.sy) < 5) { if (L.mapHits) { cb.onMapClick && cb.onMapClick(mapHitAt(e)); } else { sel = pickAt(e); cb.onSelect && cb.onSelect(info()); } } drag = null; canvas.style.cursor = 'grab'; };
  const onWheel = e => {
    e.preventDefault(); camAnim = null;
    const r = canvas.getBoundingClientRect(), nx = ((e.clientX - r.left) / r.width) * 2 - 1, ny = -((e.clientY - r.top) / r.height) * 2 + 1;
    const zo = zoom, zn = Math.min(fitZoom * 8, Math.max(fitZoom * .6, zoom * Math.exp(-e.deltaY * .0015)));
    const { w, h } = size(), hw = FH * (w / h) / 2, hh = FH / 2, right = V(1, 0, 0).applyQuaternion(cam.quaternion), up = V(0, 1, 0).applyQuaternion(cam.quaternion);
    target.addScaledVector(right, nx * hw * (1 / zo - 1 / zn)).addScaledVector(up, ny * hh * (1 / zo - 1 / zn)); zoom = zn; placeCam();
  };
  canvas.addEventListener('pointerdown', onDown); canvas.addEventListener('pointermove', onMove); canvas.addEventListener('pointerup', onUp);
  canvas.addEventListener('wheel', onWheel, { passive: false });
  canvas.addEventListener('pointerleave', () => { if (L && L.mapHits && hoverId) { hoverId = null; cb.onMapHover && cb.onMapHover(null); } });
  const ro = new ResizeObserver(() => { const { w, h } = size(); renderer.setSize(w, h, false); if (composer) composer.setSize(w, h); if (grade) grade.uniforms.uRes.value.set(w * renderer.getPixelRatio(), h * renderer.getPixelRatio()); if (fxaa) fxaa.uniforms.resolution.value.set(1 / (w * renderer.getPixelRatio()), 1 / (h * renderer.getPixelRatio())); if (nt) { const d = renderer.getPixelRatio(); nt.setSize(w * d, h * d); edge.uniforms.uTexel.value.set(1.15 / w, 1.15 / h); } placeCam(); });
  ro.observe(el); { const { w, h } = size(); renderer.setSize(w, h, false); if (composer) composer.setSize(w, h); }

  const H = makeH();
  applyPalette(); applyArt('ink'); rebuildLayout();
  loadXbot().then(() => { if (!dead) rebuildPeople(); }).catch(e => console.warn('Karakter modeli yüklenemedi, basit modeller kullanılıyor', e));
  let raf, dead = false, lastNow = performance.now(), lastTick = 0;
  function frame(now) {
    raf = requestAnimationFrame(frame);
    const dt = Math.min(.1, (now - lastNow) / 1000); lastNow = now;
    if (camAnim) { const k = Math.min(1, (now - camAnim.t0) / camAnim.dur), e = k < .5 ? 2 * k * k : 1 - Math.pow(-2 * k + 2, 2) / 2; target.lerpVectors(camAnim.a, camAnim.b, e); zoom = camAnim.za + (camAnim.zb - camAnim.za) * e; placeCam(); if (k >= 1) camAnim = null; }
    if (playing) { time += dt * speed * RATE; clock += dt * speed; if (time >= 1440) { time = 1440; playing = false; } }
    update(dt); syncToon(); if (composer && opts.fx) { renderNormals(); composer.render(); } else renderer.render(scene, cam);
    { const bg = scene.background, fog = scene.fog; scene.background = null; scene.fog = null; renderer.autoClear = false; renderer.shadowMap.autoUpdate = false; cam.layers.set(1);
      renderer.setRenderTarget(null); renderer.clearDepth(); renderer.render(scene, cam);
      cam.layers.set(0); renderer.autoClear = true; renderer.shadowMap.autoUpdate = true; scene.background = bg; scene.fog = fog; }
    if (now - lastTick > 100) { lastTick = now; cb.onTick && cb.onTick({ time, playing, sel: info() }); }
  }
  raf = requestAnimationFrame(frame);
  return {
    setMode(m) { if (m !== mode) { mode = m; rebuildLayout(); } },
    setBig(b) { big = b; count = b ? 20 : 8; rebuildLayout(); },
    setCount(n) { count = Math.max(1, Math.min(L.maxN || 10, n)); rebuildPeople(); },
    setOffice(k) { office = k; count = 999; camAnim = null; rebuildLayout(); return { count, maxN: L.maxN }; },
    openCity(s) { office = 'city'; count = 0; sel = null; camAnim = null; rebuildLayout(); { const { h } = size(), up = V(0, 1, 0).applyQuaternion(cam.quaternion); zoom = fitZoom = fitZoom * .9; target.addScaledVector(up, 44 * FH / (zoom * h)); placeCam(); fitT.copy(target); } if (L.setMapState) L.setMapState(s || {}); },
    setMapState(s) { if (L.setMapState) L.setMapState(s || {}); },
    mapAnchors() { if (!L.mapHits) return []; const { w, h } = size(); return L.mapHits.map(q => { const v = q.anchor.clone().project(cam); return { id: q.id, x: (v.x + 1) / 2 * w, y: (1 - v.y) / 2 * h, on: Math.abs(v.x) < 1.05 && Math.abs(v.y) < 1.05 }; }); },
    focusMap(id, offPx = 0) {
      const q = L.mapHits && L.mapHits.find(m => m.id === id); const b = V(), zb = q ? fitZoom * 2.1 : fitZoom;
      if (q) { q.box.getCenter(b); b.y = q.box.min.y + (q.box.max.y - q.box.min.y) * .35; const { h } = size(), upp = FH / (zb * h), right = V(1, 0, 0).applyQuaternion(cam.quaternion); b.addScaledVector(right, offPx * upp); }
      else b.copy(fitT);
      camAnim = { t0: performance.now(), dur: 750, a: target.clone(), b, za: zoom, zb };
    },
    snapshot(k, t = 615) {
      const t0 = time; office = k; count = 999; camAnim = null; rebuildLayout(); time = t; const TH = { 0: [V(3.4, 0, 6.2), 2.3], 1: [V(10, 0, 7.5), 2.1] }[k]; if (TH) { const q = TH[0].clone(), right = V(1, 0, 0).applyQuaternion(cam.quaternion), up = V(0, 1, 0).applyQuaternion(cam.quaternion); target.copy(fitT); const dq = q.sub(target); target.addScaledVector(right, dq.dot(right)).addScaledVector(up, dq.dot(up)); zoom = fitZoom * TH[1]; } else zoom = fitZoom * 1.85; placeCam();
      update(.016); syncToon(); if (composer && opts.fx) { renderNormals(); composer.render(); } else renderer.render(scene, cam);
      const src = renderer.domElement, a = 1.6; let cw = src.width, ch = src.height; if (cw / ch > a) cw = ch * a; else ch = cw / a; cw *= .86; ch *= .86;
      const c2 = document.createElement('canvas'); c2.width = 480; c2.height = 300; c2.getContext('2d').drawImage(src, (src.width - cw) / 2, (src.height - ch) / 2, cw, ch, 0, 0, 480, 300);
      time = t0; const du = c2.toDataURL('image/jpeg', .84), bin = atob(du.split(',')[1]), u8 = new Uint8Array(bin.length); for (let i = 0; i < bin.length; i++) u8[i] = bin.charCodeAt(i); return URL.createObjectURL(new Blob([u8], { type: 'image/jpeg' }));
    },
    setEnv(k) { env = k; rebuildLayout(); },
    setAngle(a) { angle = a; placeCam(); },
    setTime(t) { time = t; }, setPlaying(p) { playing = p; if (p && time >= 1440) time = 420; }, setSpeed(s) { speed = s; },
    setOptions(o) { Object.assign(opts, o); }, setArt(k) { applyArt(k); }, select(id) { sel = id; }, fit() { fitView(); },
    destroy() { dead = true; cancelAnimationFrame(raf); ro.disconnect(); renderer.dispose(); canvas.remove(); },
  };
}

// Export entry for tools/office3d/export_office.js (deltas listed in ../DESIGN_SOURCE.md).
function makeH() { return { THREE, V, PI, M, X, TEX, B, RB, Cy, grp, floorP, station, wcSign, confPhone, armchair, barCart, poolTable, arcade, foosball, credenza, artFrame, floorLamp, tv, sofaR, pingPong, beanBag, officeChair, woodChair, plant, sofa, bookshelf, coffeeMachine, kitchenRun, sink, fridge, toilet, printer, waterCooler, unicorn, whiteboard, glassDoor, decal, poolMat, fLampMat, CONEG, hazeMat, brickMat, hazeMats, rng, canvasTex, sconce, tree, car, bench, lampPost, winUnit, lowDark, groundMat, walkMat, roadMat, grassMat, lineMat }; }
function setTier(t) { TIER = t; }
const SHARED = { winMat, ceilMat, lowDark, lowLit, postMat, fLampMat, sconceMat, carHead, carTail, groundMat, walkMat, roadMat, grassMat, lineMat, fadeMat, viewMat, glowMat, poolMat, streetGlow };
export { initMats, applyPalette, bake, buildA2, makeH, setTier, loadXbot, SHARED };
