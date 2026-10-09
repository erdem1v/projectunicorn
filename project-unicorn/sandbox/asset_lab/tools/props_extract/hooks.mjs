import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const HERE = import.meta.dirname;
export const SRC = path.resolve(HERE, '../../../../tools/office3d/src');   // read only, never written
export const INST_URL = pathToFileURL(path.join(HERE, 'inst.mjs')).href;
const THREE = path.join(HERE, 'node_modules', 'three');
const SRC_URL = pathToFileURL(SRC).href + '/';
const IMP = `import { __w, __sec, __cnt, __finish } from '${INST_URL}';\n`;

const must = (c, m) => { if (!c) throw new Error('props_extract: ' + m); };
const before = (s, p, t, w) => { const i = s.indexOf(p); must(i >= 0, `marker missing (${w}): ${p.slice(0, 70)}`);
  const ls = s.lastIndexOf('\n', i) + 1; return s.slice(0, ls) + t + s.slice(ls); };
const after = (s, p, t, w) => { must(s.includes(p), `marker missing (${w}): ${p.slice(0, 70)}`); return s.replace(p, () => p + t); };
// The wrappers sit above the module body, so no call can reach a prop without being recorded.
const wrap = (s, names, exp) => {
  let consts = '';
  for (const n of names) {
    const re = new RegExp(`^(export )?function ${n}\\(`, 'm'); must(re.test(s), 'function missing: ' + n);
    s = s.replace(re, `function ${n}__o(`);
    consts += `${exp ? 'export ' : ''}const ${n} = __w('${n}', ${n}__o);\n`;
  }
  return IMP + consts + s;
};

const SIM = ['station','officeChair','woodChair','plant','sofaR','sofa','armchair','bookshelf','floorLamp','whiteboard','glassDoor','winUnit','car','tree','bench','lampPost','kitchenRun','sink','fridge','coffeeMachine','toilet','wcSign','unicorn','decal','monitorUnit','sconce'];
const A2 = [["  if (env === 'mevcut') floorP(g, -60",'floors'],['  wallX(0, -.09, W + .09, TH); wallZ(0, 0, D, TH);','outer_walls'],['  const core = M(0x5a6275','elevator_core'],
  ['  glassX(6, 0, 8, 2.4, [[3.4, 4.6]]);','partitions_doors'],['  // meeting (7 seats)','meeting_room'],['  // kitchen\n','kitchen'],['  // toilet\n','toilet'],
  ['  // open office: 10 desks','open_office'],['  // founder glass corner office','founder_corner'],['  // building shell','building_shell'],
  ['    const nE = o =>','street_context'],['    { const nb = (x0, x1, z0, z1, h, c) =>','neighbour_buildings'],['    const e = M(0x2c3446, { r: .2 }); B(g, 2.4','entrance_street_trees_cars']];
function simT(src) {
  const s = wrap(src, SIM, false);
  const i0 = s.indexOf('function buildA2(env) {'), i1 = s.indexOf('function patchLunch(P)');
  must(i0 >= 0 && i1 > i0, 'buildA2 bounds');
  let a = s.slice(i0, i1);                       // markers only inside buildA2
  a = after(a, 'const nb = (x0, x1, z0, z1, h, c) => { ', "__cnt('neighbour_building'); ", 'nb counter');
  for (const [p, l] of A2) a = before(a, p, `  __sec(G0, 'A2:${l}');\n`, l);
  // The sconces are built inside the returned literal, after the last statement: they get their own section before the final flush.
  a = before(a, '  return {\n    g, bounds', "  __sec(G0, 'A2:sconces');\n  __finish(G0);\n", 'sconces');
  return s.slice(0, i0) + a + s.slice(i1);
}
const H = [['  // slab + floors','slab_floors'],['  // full-height back (z=0)','back_wall_windows'],['  // cut interior walls','interior_cut_walls'],['  // exterior cut walls','exterior_cut_walls'],
  ['  // KITCHEN corner','kitchen'],['  // BATHROOM','bathroom'],['  // LANDING','landing_lift_stair'],['  // ANTRE','antre'],['  // BEDROOM','bedroom'],
  ['  // SALON + work corner','salon_work_corner'],['  // BALCONIES + FACADE','balcony_facade_windows'],['  // street + neighbours','street_neighbours'],
  ['  const roofM = [','neighbour_blocks'],['  tree(g, W + 14.5, GY + .12','trees_lamps_cars']];
function homeT(src) {
  let h = wrap(src, ['hipRoof'], true);
  h = after(h, 'const bld = (x0, x1, z0, z1, floors, col, faces, roof = 1, minF = 0) => { ', "__cnt('neighbour_building'); ", 'bld');
  h = after(h, 'const shop = (x0, x1, z0, z1, c, side, i) => { ', "__cnt('neighbour_shop'); ", 'shop');
  for (const [p, l] of H) h = before(h, p, `  __sec(g, 'home:${l}');\n`, l);
  return before(h, '  // spots (founder only)', '  __finish(g);\n', 'finish');
}
const TRANSFORMS = { 'office-sim-v12.js': simT, 'office-home.js': homeT };

// The design imports three from esm.sh. The local install is also what bare 'three' resolves to, so there is ONE module instance.
export function resolve(spec, ctx, next) {
  const m = /^https:\/\/esm\.sh\/three@0\.160\.0(\/.*)?$/.exec(spec);
  if (m) return { url: pathToFileURL(path.join(THREE, m[1] ?? '/build/three.module.js')).href, shortCircuit: true };
  return next(spec, ctx);
}
export function load(url, ctx, next) {              // read the file ourselves: no dependence on package "type" detection
  if (!url.startsWith(SRC_URL)) return next(url, ctx);
  let source = fs.readFileSync(fileURLToPath(url), 'utf8');
  const fn = TRANSFORMS[url.slice(url.lastIndexOf('/') + 1)];
  if (fn) source = fn(source);
  return { format: 'module', source, shortCircuit: true };
}
