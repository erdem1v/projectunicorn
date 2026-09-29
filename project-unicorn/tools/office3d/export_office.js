// Builds each office through the design's own code (./src: byte-verbatim copies plus the
// deltas in DESIGN_SOURCE.md), names what Godot binds to and posts, per office,
//   art/office3d/<id>.glb + <id>.json and assets/art/office/thumb_<id>.jpg (serve.py sinks).
// Query flags: only=<id,...> limits the offices, thumbs=0 skips the thumbnails.
import * as THREE from 'https://esm.sh/three@0.160.0';
import { GLTFExporter } from 'https://esm.sh/three@0.160.0/examples/jsm/exporters/GLTFExporter.js';
import { mergeVertices } from 'https://esm.sh/three@0.160.0/examples/jsm/utils/BufferGeometryUtils.js';
import { initMats, applyPalette, bake, buildA2, makeH, setTier, loadXbot, SHARED, createOffice } from './src/office-sim-v12.js';
import { buildHome } from './src/office-home.js';
import { buildPlaza } from './src/office-plaza-v2.js';
import { buildLoft } from './src/office-loft-v2.js';
import { buildCity } from './src/office-city-v2.js';
import { buildMeet } from './src/office-meet.js';

const { say, done, post } = window.office3d;
const seen = new Set();
for (const level of ['warn', 'error']) {
  const orig = console[level].bind(console);
  console[level] = (...a) => { orig(...a); const m = level.toUpperCase() + ' ' + a.map(String).join(' '); if (!seen.has(m)) { seen.add(m); say(m); } };
}

// k is the design's office key: createOffice.rebuildLayout picks TIER and the builder from it.
const OFFICES = [
  { id: 'home', k: 0, kinds: ['desk', 'bal', 'ket', 'eat', 'wc', 'out', 'bed', 'stairs', 'door', 'enter'] },
  { id: 'ishani', k: 1, kinds: ['desk', 'visit', 'meet', 'eat', 'coffee', 'wc', 'out'] },
  { id: 'plaza', k: 2, kinds: ['desk', 'visit', 'meet_A', 'meet_B', 'meet_board', 'eat', 'coffee', 'wc', 'booth', 'out'] },
  { id: 'loft', k: 3, kinds: ['desk', 'visit', 'meet_r1', 'meet_r2', 'meet_r3', 'meet_board', 'eat', 'coffee', 'wc', 'booth', 'trib', 'present', 'out'] },
  { id: 'city', k: 'city', kinds: [] },
  // The meeting room on the investor tower's top floor: the founder's seat, the guests' (lead first), the lift.
  { id: 'meet', k: 'meet', kinds: ['desk', 'guest', 'out'] },
];
const tierOf = k => k === 'city' || k === 'meet' ? 1 : k;
const build = (k, H) => k === 'city' ? buildCity(H) : k === 'meet' ? buildMeet(H) : k === 0 ? buildHome(H) : k === 1 ? buildA2('cevre') : k === 2 ? buildPlaza(H) : buildLoft(H);
// The city map's hit ids are the design's; the game's office ids differ for two of them. The
// investor tower is no office: it travels as the meetings' building.
const MAP_OFFICE = { ev: 'home', ishani: 'ishani', plaza: 'plaza', depo: 'loft' };
const MEET_HIT = 'meridian';
const SHARED_NAMES = { winMat: 'win', ceilMat: 'ceil', lowDark: 'pane_dark', lowLit: 'pane_lit', postMat: 'post', fLampMat: 'flamp', sconceMat: 'sconce', carHead: 'car_head', carTail: 'car_tail', groundMat: 'ground', walkMat: 'walk', roadMat: 'road', grassMat: 'grass', lineMat: 'line', fadeMat: 'fade', viewMat: 'view' };
const GLOW_KIND = new Map([[SHARED.poolMat, 'pool'], [SHARED.streetGlow, 'street'], [SHARED.glowMat, 'sconce']]);
// The state the GLB freezes: 10:15 (the thumbnails' hour), full day, wall clock at 0.
const FREEZE_T = 615;

const r4 = x => Math.round(x * 1e4) / 1e4;
const v3 = v => [r4(v.x), r4(v.y), r4(v.z)];
const spotJson = s => ({ pos: v3(s.pos), face: r4(s.face), pose: s.pose, chain: s.chain.map(v3), floor: s.floor || 0, zone: s.zone || '' });

async function postOk(name, body) {
  const r = await post(name, body);
  if (!r.ok) throw new Error(name + ' -> HTTP ' + r.status);
}

// snapshot()'s framing lives inside createOffice; read it from the source so it cannot drift.
async function thumbSpec() {
  const src = await (await fetch('./src/office-sim-v12.js')).text();
  const grab = re => { const m = re.exec(src); if (!m) throw new Error('snapshot() changed shape: ' + re); return m; };
  const time = +grab(/snapshot\(k, t = (\d+)\)/)[1];
  const th = {};
  for (const m of grab(/const TH = \{([^}]*)\}\[k\]/)[1].matchAll(/(\d+): \[V\(([^)]*)\), ([\d.]+)\]/g)) th[m[1]] = { target: m[2].split(',').map(Number), zoom: +m[3] };
  const zoom = +grab(/else zoom = fitZoom \* ([\d.]+);/)[1];
  const aspect = +grab(/a = ([\d.]+); let cw = src\.width/)[1];
  const crop = +grab(/cw \*= ([\d.]+); ch \*= /)[1];
  const size = grab(/c2\.width = (\d+); c2\.height = (\d+);/).slice(1).map(Number);
  return k => k === 'city' || k === 'meet' ? null : { k, target: th[k] ? th[k].target : null, zoom: th[k] ? th[k].zoom : zoom, time, aspect, crop, size };
}

// L.elev.near is a closure over an x/z box: read its numbers from the source, prove them by probing.
// The box is written either as two half widths or, for z, as a range.
function nearBox(near) {
  let m = /Math\.abs\(q\.x - ([\d.]+)\) < ([\d.]+) && Math\.abs\(q\.z - ([\d.]+)\) < ([\d.]+)/.exec(String(near));
  if (!m) {
    const r = /Math\.abs\(q\.x - ([\d.]+)\) < ([\d.]+) && q\.z > ([\d.]+) && q\.z < ([\d.]+)/.exec(String(near));
    if (r) m = [r[0], r[1], r[2], r4((+r[3] + +r[4]) / 2), r4((r[4] - r[3]) / 2)];
  }
  if (!m) throw new Error('elev.near is no longer an x/z box: ' + near);
  const [cx, hx, cz, hz] = m.slice(1).map(Number), e = 1e-3, at = (x, z) => near(new THREE.Vector3(x, 0, z));
  if (!at(cx, cz) || !at(cx + hx - e, cz - hz + e) || at(cx + hx + e, cz) || at(cx, cz - hz - e)) throw new Error('elev.near probe mismatch: ' + near);
  return { center: [cx, 0, cz], half: [hx, 1000, hz] };
}

// L.spot is a closure: walk each kind's index until the same spot object comes back.
function enumerateSpots(L, kinds) {
  const spots = {}, firstOf = new Map();
  for (const kind of kinds) {
    const [k, r] = kind.split('_'), list = [], got = new Set();
    for (let i = 0; i <= (k === 'desk' ? L.maxN : 4095); i++) {
      // A guest's seat is the person's own: the meeting room seats ids 20, 21, 22.
      const s = k === 'desk' ? L.spot({ id: i }, { k }) : k === 'guest' ? i < 3 && L.spot({ id: 20 + i }, { k: 'seat' })
        : L.spot({ id: 0 }, r ? { k, r, i } : { k, i });
      if (!s || got.has(s)) break;
      got.add(s); list.push(s);
    }
    if (!list.length) throw new Error(`spot kind ${kind} is empty`);
    if (firstOf.has(list[0])) throw new Error(`spot kind ${kind} falls back to ${firstOf.get(list[0])}`);
    firstOf.set(list[0], kind);
    spots[kind] = list.map(spotJson);
  }
  return spots;
}

function prepare(o, L, H, thumb) {
  const g = L.g;
  g.name = 'office_' + o.id;
  g.updateMatrixWorld(true);

  // Additive glows are re-created in Godot; their placement travels in the JSON.
  const glows = { pool: [], street: [], sconce: [] }, additive = [];
  g.traverse(x => { if (x.isMesh && [x.material].flat().some(m => m.blending === THREE.AdditiveBlending)) additive.push(x); });
  for (const x of additive) {
    const kind = GLOW_KIND.get(x.material);
    if (!kind) throw new Error(`${o.id}: unknown additive mesh`);
    const s = x.getWorldScale(new THREE.Vector3()), n = new THREE.Vector3(0, 0, 1).applyQuaternion(x.getWorldQuaternion(new THREE.Quaternion()));
    glows[kind].push({ pos: v3(x.getWorldPosition(new THREE.Vector3())), size: [r4(Math.abs(s.x)), r4(Math.abs(s.y))], normal: v3(n) });
    x.parent.remove(x);
  }

  // Towers are unlit day maps whose night map the design swaps in; glTF carries the night
  // map as the emissive texture at strength 0.
  const towerOf = new Map();
  const tower = m => {
    if (!m.userData.d) return m;
    if (!towerOf.has(m)) {
      const t = new THREE.MeshStandardMaterial({ name: 'tower', map: m.userData.d, emissive: 0xffffff, emissiveMap: m.userData.n, emissiveIntensity: 0, roughness: 1, metalness: 0 });
      t.userData = { unlit: true };
      towerOf.set(m, t);
    }
    return towerOf.get(m);
  };
  g.traverse(x => { if (x.isMesh) x.material = Array.isArray(x.material) ? x.material.map(tower) : tower(x.material); });
  for (const m of H.hazeMats) { m.name = 'haze'; m.userData = { base: '#' + m.userData.base.getHexString() }; }
  if (L.wtex) g.traverse(x => { if (x.isMesh && x.material.map === L.wtex) x.material.name = 'water'; });
  // The facade's night map tiles differently from its base map; Godot's importer keeps only
  // the base map's UV transform, so the emissive one rides in the material extras.
  (L.facMats || []).forEach(m => { m.name = 'facade'; m.userData.emissiveUv = { scale: m.emissiveMap.repeat.toArray(), offset: m.emissiveMap.offset.toArray() }; });
  if (L.crown) L.crown.name = 'crown';
  if (L.ferry) L.ferry.traverse(x => { if (x.isMesh && x.material.emissive && x.material.emissive.getHex()) x.material.name = 'ferry_win'; });

  // Stations: index i is desk id i + 1, the founder's is 'f'.
  const founder = L.station({ id: 0 }) || null, desks = L.stations.filter(s => s !== founder), owner = new Map();
  desks.forEach((s, i) => {
    if (L.station({ id: i + 1 }) !== s) throw new Error(`${o.id}: station ${i} is not desk ${i + 1}`);
    owner.set(s.lampMat, [i, 'lamp']); owner.set(s.screenMat, [i, 'screen']);
  });
  if (founder) { owner.set(founder.lampMat, ['f', 'lamp']); owner.set(founder.screenMat, ['f', 'screen']); }
  const count = new Map();
  g.traverse(x => {
    const hit = x.isMesh && owner.get(x.material);
    if (!hit) return;
    const base = `station_${hit[0]}_${hit[1]}`, n = count.get(base) || 0;
    count.set(base, n + 1);
    x.name = n ? `${base}_${n}` : base;
    x.material.name = 'station_' + hit[1];
  });
  for (const i of [...desks.keys(), ...(founder ? ['f'] : [])]) for (const part of ['lamp', 'screen']) if (!count.get(`station_${i}_${part}`)) throw new Error(`${o.id}: station ${i} has no ${part}`);

  L.low.forEach((m, i) => { if (!m.userData.sched) throw new Error(`${o.id}: pane ${i} has no schedule`); m.name = 'pane_' + i; });
  L.panes.forEach((m, i) => { m.name = 'envpane_' + i; });
  L.sky.forEach((m, i) => { m.name = 'sky_' + i; });
  L.fades.forEach((m, i) => { m.name = 'fade_' + i; });
  // The design's default light mode ('tavan') hides the sconces.
  L.sconces.forEach((s, i) => { s.name = 'sconce_' + i; s.userData.hidden = true; });
  const elevPanels = L.elev ? L.elev.panels.map((q, i) => {
    const e = { p0: r4(q.p0), d: q.d, rot: !!q.rot, ax: q.ax || 'x' };
    q.m.name = 'elev_panel_' + i;
    Object.assign(q.m.userData, e);
    return { node: q.m.name, ...e };
  }) : [];
  if (L.frames) for (const id in L.frames) L.frames[id].name = 'frame_' + id;
  if (L.pin) L.pin.name = 'pin';
  if (L.pen) L.pen.name = 'pen';
  if (L.ferry) L.ferry.name = 'ferry';
  (L.cars || []).forEach((c, i) => { c.hg.name = 'car_' + i; });
  (L.boats || []).forEach((b, i) => { b.name = 'boat_' + i; });
  (L.keep || []).forEach((x, i) => { if (!x.name) x.name = 'keep_' + i; });

  g.traverse(x => {
    if (!x.visible) x.userData.hidden = true;
    if (!x.isMesh) return;
    if (!x.castShadow) x.userData.noCast = true;
    if (!x.receiveShadow) x.userData.noReceive = true;
  });
  // pane_lit is only swapped in at runtime; a hidden 1 cm quad carries it into the GLB.
  if (L.low.length) {
    const c = new THREE.Mesh(new THREE.PlaneGeometry(.01, .01), SHARED.lowLit);
    c.name = 'matlib_pane_lit';
    c.userData = { hidden: true };
    g.add(c);
  }
  // bake() leaves the groups it emptied behind.
  const prune = x => { for (const c of [...x.children]) prune(c); if (x !== g && !x.isMesh && !x.children.length && !x.name) x.parent.remove(x); };
  prune(g);
  // bake()'s merged buffers are non-indexed (three vertices per triangle); indexing them keeps
  // every triangle and shrinks the GLB about threefold. Shared geometries stay shared.
  const indexed = new Map();
  g.traverse(x => {
    if (!x.isMesh || x.geometry.index) return;
    if (!indexed.has(x.geometry)) indexed.set(x.geometry, mergeVertices(x.geometry));
    x.geometry = indexed.get(x.geometry);
  });

  const names = new Set(), mats = new Set(), hidden = [];
  let meshes = 0, tris = 0;
  g.traverse(x => {
    if (x.name) { if (names.has(x.name)) throw new Error(`${o.id}: duplicate node name ${x.name}`); names.add(x.name); }
    if (x.userData.hidden) hidden.push(x.name);
    if (!x.isMesh) return;
    meshes++;
    tris += (x.geometry.index ? x.geometry.index.count : x.geometry.attributes.position.count) / 3;
    [x.material].flat().forEach(m => { if (m.name) mats.add(m.name); });
  });

  const hitBox = h => ({ box: { min: v3(h.box.min), max: v3(h.box.max) }, anchor: v3(h.anchor) });
  const meetHit = (L.mapHits || []).find(h => h.id === MEET_HIT);
  const info = {
    id: o.id, generator: 'tools/office3d/export_office.js', three: THREE.REVISION, tier: tierOf(o.k),
    bounds: { min: v3(L.bounds.min), max: v3(L.bounds.max) },
    sunOff: v3(L.sunOff),
    fog: L.fog ? { near: L.fog.near || 135, far: L.fog.far || 200 } : null,
    maxN: L.maxN, spd: L.spd, env: L.env,
    spots: enumerateSpots(L, o.kinds),
    meetRooms: o.kinds.filter(k => k.startsWith('meet_')).map(k => k.slice(5)),
    stations: desks.map((s, i) => ({ deskId: i + 1, node: 'station_' + i, lampPos: v3(s.lampPos), screenPos: v3(s.screenPos) })),
    founderStation: founder ? { node: 'station_f', lampPos: v3(founder.lampPos), screenPos: v3(founder.screenPos) } : null,
    elevNear: L.elev ? nearBox(L.elev.near) : null,
    elevPanels,
    panes: L.low.map(m => ({ node: m.name, sched: { on: r4(m.userData.sched.on), off: r4(m.userData.sched.off), allNight: !!m.userData.sched.allNight } })),
    envPanes: L.panes.map(m => m.name),
    sconces: L.sconces.map(s => s.name),
    fades: L.fades.map(m => m.name),
    keep: (L.keep || []).map(x => x.name),
    hidden,
    glows,
    mapHits: (L.mapHits || []).filter(h => MAP_OFFICE[h.id]).map(h => ({ id: h.id, office: MAP_OFFICE[h.id], ...hitBox(h) })),
    meetHit: meetHit ? hitBox(meetHit) : null,
    table: L.table ? v3(L.table) : null,
    // The pen's place put down on the table; in the hand it is the note-taker's own.
    pen: L.pen ? { pos: v3(L.penB.p), rot: v3(L.penB.r) } : null,
    lanes: (L.cars || []).map(c => ({ a: [r4(c.a[0]), r4(c.a[1])], b: [r4(c.a[0] + c.dx), r4(c.a[1] + c.dz)], v: r4(c.v), ph: r4(c.ph), ry: r4(c.ry), carNode: c.hg.name })),
    thumbTargets: thumb,
    materials: [...mats].sort(),
  };
  return { info, stats: { nodes: names.size, meshes, tris } };
}

// Number-only arrays on one line keep the sidecar readable.
const pretty = obj => JSON.stringify(obj, null, 1).replace(/\[\s*(-?[\d.e+-]+(?:,\s*-?[\d.e+-]+)*)\s*\]/g, (_, inner) => '[' + inner.split(/,\s*/).join(',') + ']') + '\n';

async function thumbnails(ids) {
  // DPR 2 supersamples; snapshot() crops relative to the canvas, so the framing is unchanged.
  Object.defineProperty(window, 'devicePixelRatio', { get: () => 2 });
  const sim = createOffice(document.getElementById('stage'), {});
  let rig = 'xbot';
  try { await Promise.race([loadXbot(), new Promise((_, no) => setTimeout(() => no(new Error('no answer in 90 s')), 90000))]); }
  catch (e) { rig = 'capsule'; await say('Xbot rig not loaded, capsule thumbnails: ' + e.message); }
  for (const o of OFFICES) {
    if (o.k === 'city' || o.k === 'meet' || !ids.includes(o.id)) continue;
    const url = sim.snapshot(o.k), blob = await (await fetch(url)).blob();
    URL.revokeObjectURL(url);
    await postOk(`thumb_${o.id}.jpg`, blob);
    await say(`thumb_${o.id}.jpg ${blob.size} B (${rig})`);
  }
  sim.destroy();
  return rig;
}

(async () => {
  const q = new URLSearchParams(location.search);
  const ids = (q.get('only') || OFFICES.map(o => o.id).join(',')).split(',');
  const thumbOf = await thumbSpec();
  initMats(); applyPalette();
  const H = makeH();
  for (const [k, name] of Object.entries(SHARED_NAMES)) SHARED[k].name = name;
  H.X.glass.name = 'glass';
  const exporter = new GLTFExporter(), summary = [];
  for (const o of OFFICES) {
    if (!ids.includes(o.id)) continue;
    const t0 = performance.now();
    setTier(tierOf(o.k));
    const L = build(o.k, H);
    // Kept whole so they can be named; bake() would merge them into the scenery otherwise.
    if (L.boats) L.keep.push(...L.boats);
    bake(L);
    for (const pn of L.panes) pn.material = L.env === 'mevcut' ? SHARED.winMat : SHARED.lowDark;
    if (L.tick) {
      performance.now = () => 0;
      try { L.tick(FREEZE_T, 1); } finally { delete performance.now; }
    }
    const { info, stats } = prepare(o, L, H, thumbOf(o.k));
    const buf = await exporter.parseAsync(L.g, { binary: true, embedImages: true, onlyVisible: false });
    await postOk(o.id + '.glb', new Blob([buf], { type: 'model/gltf-binary' }));
    await postOk(o.id + '.json', pretty(info));
    const line = `${o.id}: ${(buf.byteLength / 1048576).toFixed(2)} MB, ${stats.nodes} named, ${stats.meshes} meshes, ${Math.round(stats.tris)} tris, ${((performance.now() - t0) / 1000).toFixed(1)} s`;
    summary.push(line);
    await say(line);
  }
  const rig = q.get('thumbs') === '0' ? 'skipped' : await thumbnails(ids);
  await done('ok thumbs=' + rig + '\n' + summary.join('\n'));
})().catch(async e => {
  await say('EXPORT FAILED: ' + (e.stack || e));
  await done('ERR ' + e.message);
});
