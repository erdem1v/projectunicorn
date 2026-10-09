// Records, per named prop call, which meshes it added.
export const LOG = { calls: [], counts: {}, secs: [], secMeshes: new Map() };
const claimed = new Set(), assigned = new Set();
const stack = [];
let curSec = 'start';
export function reset() {
  LOG.calls.length = 0; LOG.counts = {}; LOG.secs.length = 0; LOG.secMeshes = new Map();
  claimed.clear(); assigned.clear(); stack.length = 0; curSec = 'start';
}
export function __w(name, f) {
  return function (...args) {
    const root = args.find(a => a && a.isObject3D);
    const before = new Set(), kids0 = new Set(root.children);
    root.traverse(o => { if (o.isMesh) before.add(o); });
    const rec = { id: LOG.calls.length, name, parent: stack.length ? stack[stack.length - 1].id : null, section: curSec,
      args: args.filter(a => typeof a === 'number' || typeof a === 'boolean'), meshes: [] };
    LOG.calls.push(rec); stack.push(rec);
    const r = f.apply(this, args);
    stack.pop();
    root.traverse(o => { if (o.isMesh && !before.has(o)) { rec.meshes.push(o); claimed.add(o); } });
    rec.newKids = root.children.filter(k => !kids0.has(k));
    return r;
  };
}
// Unclaimed meshes created since the last marker belong to the section that was open.
export function __finish(root) {
  const list = [];
  root.traverse(o => { if (o.isMesh && !claimed.has(o) && !assigned.has(o)) { assigned.add(o); list.push(o); } });
  LOG.secMeshes.set(curSec, list);
}
export function __sec(root, label) { __finish(root); curSec = label; LOG.secs.push(label); }
export function __cnt(name) { LOG.counts[name] = (LOG.counts[name] || 0) + 1; }
