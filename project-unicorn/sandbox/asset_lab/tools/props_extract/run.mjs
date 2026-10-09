import crypto from 'node:crypto';
import fs from 'node:fs';
import { registerHooks } from 'node:module';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import * as hooks from './hooks.mjs';

// The sim modules draw textures on canvases while loading and only build geometry, so a no-op 2D context is enough.
const mk = () => new Proxy(function () {}, { get: () => mk(), apply: () => mk() });
globalThis.document = { createElement: () => ({ getContext: () => mk() }) };

const HERE = import.meta.dirname;
const OUT = path.resolve(HERE, '../../out/props');
fs.mkdirSync(OUT, { recursive: true });

// The design source is read-only: every module must hash the same after the run as before it.
const hashSrc = () => Object.fromEntries(fs.readdirSync(hooks.SRC).filter(f => f.endsWith('.js')).sort()
  .map(f => [f, crypto.hash('sha256', fs.readFileSync(path.join(hooks.SRC, f)))]));
const srcBefore = hashSrc();

// Static imports link before this module runs, so the hooked modules have to load dynamically after registration.
registerHooks({ resolve: hooks.resolve, load: hooks.load });
const imp = n => import(pathToFileURL(path.join(hooks.SRC, n)).href);
const THREE = await import('three');
const inst = await import(hooks.INST_URL);
const sim = await imp('office-sim-v12.js');
const home = await imp('office-home.js');
const r3 = v => [Math.round(v.x * 100) / 100, Math.round(v.y * 100) / 100, Math.round(v.z * 100) / 100];
sim.initMats(); sim.applyPalette();
const H = sim.makeH();
function bboxOf(meshes) { const b = new THREE.Box3(); for (const m of meshes) b.expandByObject(m); return b.isEmpty() ? null : { min: r3(b.min), max: r3(b.max), size: r3(b.getSize(new THREE.Vector3())) }; }
function scene(id, tier, build) {
  inst.reset(); sim.setTier(tier);
  const L = build();
  L.g.updateMatrixWorld(true);
  let nodes = 0, meshes = 0; L.g.traverse(o => { nodes++; if (o.isMesh) meshes++; });
  const top = inst.LOG.calls.filter(c => c.parent === null);
  const byName = {};
  for (const c of top) { const e = byName[c.name] || (byName[c.name] = { calls: 0, meshes: 0 }); e.calls++; e.meshes += c.meshes.length; }
  const pose = c => { const k = c.newKids.find(x => x.isGroup); if (!k) return null; const p = new THREE.Vector3(), q = new THREE.Quaternion(), s = new THREE.Vector3(); k.matrixWorld.decompose(p, q, s); const e = new THREE.Euler().setFromQuaternion(q, 'YXZ'); return { pos: r3(p), yaw: Math.round(e.y * 1000) / 1000, mirrored: k.matrixWorld.determinant() < 0 }; };
  const items = top.map(c => ({ i: c.id, type: c.name, section: c.section, args: c.args, nMeshes: c.meshes.length, pose: pose(c), bboxWorld: bboxOf(c.meshes), mats: [...new Set(c.meshes.map(m => '#' + m.material.color.getHexString()))] }));
  const secs = {};
  for (const [k, list] of inst.LOG.secMeshes) secs[k] = { residualMeshes: list.length, bboxWorld: bboxOf(list) };
  const claimed = top.reduce((a, c) => a + c.meshes.length, 0);
  const secType = {};
  for (const c of top) { const k = c.section; (secType[k] || (secType[k] = {}))[c.name] = (secType[k][c.name] || 0) + 1; }
  const res = { id, nodes, meshesPreBake: meshes, claimedByNamedProps: claimed, residualInlinePrimitives: meshes - claimed, byName, counts: inst.LOG.counts, secType, sections: secs, items,
    extras: { low: L.low.length, posts: L.posts.length, sconces: L.sconces.length, keep: L.keep?.length, stations: L.stations.length } };
  fs.writeFileSync(path.join(OUT, id + '_props.json'), JSON.stringify(res, null, 1));
  console.log('=== ' + id, JSON.stringify({ nodes, meshesPreBake: meshes, claimed, residual: meshes - claimed, counts: inst.LOG.counts, extras: res.extras }));
  console.log(' named top-level calls:', JSON.stringify(byName));
  for (const k of inst.LOG.secs) console.log('  ', k.padEnd(34), 'residual', String(secs[k].residualMeshes).padStart(5), JSON.stringify(secType[k] || {}));
}
scene('home', 0, () => home.buildHome(H));
scene('ishani', 1, () => sim.buildA2('cevre'));

const srcAfter = hashSrc();
if (JSON.stringify(srcAfter) !== JSON.stringify(srcBefore)) throw new Error('props_extract: tools/office3d/src changed during the run');
const three = JSON.parse(fs.readFileSync(path.join(HERE, 'node_modules/three/package.json'), 'utf8')).version;
fs.writeFileSync(path.join(OUT, 'run_meta.json'), JSON.stringify({ src_sha256: srcAfter, three, node: process.version }, null, 1));
