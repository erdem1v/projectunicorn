"""Rebuilds a Quaternius Ultimate Modular (2022) character so Godot's humanoid retarget can read it.

In the packs' glTF files the node rest is the Idle pose while the skin is bound in a T-pose, and both
feet (with their IK pole targets) hang off Root instead of the shins. This writes one GLB per
character in metres and Y-up with:
- every bone's rest equal to its bind (T-pose), scale removed;
- Foot.L/R under LowerLeg.L/R, so a shin turn carries the foot;
- vertices and normals baked into the identity mesh space, inverse binds recomputed;
- the four outfit parts only (no carried gear), without the character's own clips or the texture
  coordinates of the flat colours;
- materials kept by name, flat: metallic 0, roughness 1.

Then it reads its own output back and exits non-zero if a bone's rest does not undo its bind, if a
foot is not under its shin, or if a vertex moved.

    python tools/people/fix_rig.py <in.gltf> <out.glb>
"""

import base64
import json
import struct
import sys

import numpy as np

FEET = {"Foot.L": "LowerLeg.L", "Foot.R": "LowerLeg.R"}
## Outfit part meshes by the end of their name (the farmer's legs are "Pants"); other skinned meshes
## are carried gear. The output names each part Part_<kind>.
PARTS = {"_Head": "Head", "_Body": "Body", "_Legs": "Legs", "_Pants": "Legs", "_Feet": "Feet"}
REST_TOL = 1e-4
VERTEX_TOL = 1e-3   # metres
CHECK_VERTICES = 200

COMPONENT = {5120: np.int8, 5121: np.uint8, 5122: np.int16, 5123: np.uint16, 5125: np.uint32, 5126: np.float32}
WIDTH = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}


def read_gltf(path):
	gltf = json.load(open(path, encoding="utf-8"))
	return gltf, base64.b64decode(gltf["buffers"][0]["uri"].split(",", 1)[1])


def read_glb(path):
	data = open(path, "rb").read()
	json_len = struct.unpack_from("<I", data, 12)[0]
	gltf = json.loads(data[20:20 + json_len])
	bin_off = 20 + json_len
	bin_len = struct.unpack_from("<I", data, bin_off)[0]
	return gltf, data[bin_off + 8:bin_off + 8 + bin_len]


def accessor(gltf, blob, index):
	acc = gltf["accessors"][index]
	view = gltf["bufferViews"][acc["bufferView"]]
	dtype = COMPONENT[acc["componentType"]]
	width = WIDTH[acc["type"]]
	start = view.get("byteOffset", 0) + acc.get("byteOffset", 0)
	stride = view.get("byteStride", 0)
	item = np.dtype(dtype).itemsize * width
	if stride and stride != item:
		rows = [np.frombuffer(blob, dtype, width, start + i * stride) for i in range(acc["count"])]
		return np.array(rows)
	return np.frombuffer(blob, dtype, acc["count"] * width, start).reshape(acc["count"], width).copy()


def trs(node):
	m = np.eye(4)
	if "matrix" in node:
		return np.array(node["matrix"], dtype=np.float64).reshape(4, 4).T
	x, y, z, w = node.get("rotation", [0, 0, 0, 1])
	r = np.array([
		[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
		[2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
		[2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)],
	])
	m[:3, :3] = r * np.array(node.get("scale", [1, 1, 1]))
	m[:3, 3] = node.get("translation", [0, 0, 0])
	return m


def quat(r):
	"""Unit quaternion (x, y, z, w) of a rotation matrix."""
	t = np.trace(r)
	if t > 0:
		s = np.sqrt(t + 1.0) * 2
		q = [(r[2, 1] - r[1, 2]) / s, (r[0, 2] - r[2, 0]) / s, (r[1, 0] - r[0, 1]) / s, 0.25 * s]
	elif r[0, 0] > r[1, 1] and r[0, 0] > r[2, 2]:
		s = np.sqrt(1.0 + r[0, 0] - r[1, 1] - r[2, 2]) * 2
		q = [0.25 * s, (r[0, 1] + r[1, 0]) / s, (r[0, 2] + r[2, 0]) / s, (r[2, 1] - r[1, 2]) / s]
	elif r[1, 1] > r[2, 2]:
		s = np.sqrt(1.0 + r[1, 1] - r[0, 0] - r[2, 2]) * 2
		q = [(r[0, 1] + r[1, 0]) / s, 0.25 * s, (r[1, 2] + r[2, 1]) / s, (r[0, 2] - r[2, 0]) / s]
	else:
		s = np.sqrt(1.0 + r[2, 2] - r[0, 0] - r[1, 1]) * 2
		q = [(r[0, 2] + r[2, 0]) / s, (r[1, 2] + r[2, 1]) / s, 0.25 * s, (r[1, 0] - r[0, 1]) / s]
	q = np.array(q)
	return (q / np.linalg.norm(q)).tolist()


def rigid(m):
	"""The rotation and translation of `m` with its scale removed (polar decomposition)."""
	u, _, vt = np.linalg.svd(m[:3, :3])
	out = np.eye(4)
	out[:3, :3] = u @ vt
	out[:3, 3] = m[:3, 3]
	return out


def kind_of(name):
	return next((kind for end, kind in PARTS.items() if name.endswith(end)), None)


def world_of(gltf):
	parent = {}
	for i, node in enumerate(gltf["nodes"]):
		for c in node.get("children", []):
			parent[c] = i
	cache = {}

	def world(i):
		if i not in cache:
			cache[i] = (world(parent[i]) if i in parent else np.eye(4)) @ trs(gltf["nodes"][i])
		return cache[i]
	return world, parent


class Writer:
	def __init__(self):
		self.blob = bytearray()
		self.views = []
		self.accessors = []

	def add(self, array, gl_type, component, target=None, minmax=False):
		while len(self.blob) % 4:
			self.blob.append(0)
		raw = np.ascontiguousarray(array).tobytes()
		view = {"buffer": 0, "byteOffset": len(self.blob), "byteLength": len(raw)}
		if target:
			view["target"] = target
		self.blob += raw
		self.views.append(view)
		acc = {"bufferView": len(self.views) - 1, "componentType": component, "count": len(array), "type": gl_type}
		if minmax:
			acc["min"] = np.min(array, axis=0).tolist()
			acc["max"] = np.max(array, axis=0).tolist()
		self.accessors.append(acc)
		return len(self.accessors) - 1


def rebuild(src, dst):
	gltf, blob = read_gltf(src)
	nodes = gltf["nodes"]
	world, parent = world_of(gltf)
	skinned = [i for i, n in enumerate(nodes) if "skin" in n and kind_of(n["name"])]
	skin = gltf["skins"][nodes[skinned[0]]["skin"]]
	joints = skin["joints"]
	mesh_world = world(skinned[0])
	# Every part is baked in the first part's node space: the packs give all parts one transform.
	for n in skinned:
		if not np.allclose(world(n), mesh_world, atol=REST_TOL):
			sys.exit("%s: part %s has a node transform of its own" % (src, nodes[n]["name"]))
	ibm = accessor(gltf, blob, skin["inverseBindMatrices"]).reshape(-1, 4, 4).transpose(0, 2, 1).astype(np.float64)
	bind = {j: rigid(mesh_world @ np.linalg.inv(ibm[k])) for k, j in enumerate(joints)}
	name_of = {i: nodes[i]["name"] for i in range(len(nodes))}
	by_name = {v: k for k, v in name_of.items()}

	# The skeleton keeps its joints in their order; feet move under the shins.
	new_parent = {j: parent[j] for j in joints}
	for foot, shin in FEET.items():
		new_parent[by_name[foot]] = by_name[shin]
	root = [j for j in joints if new_parent[j] not in joints]

	out_nodes = []
	index = {}
	for j in joints:
		index[j] = len(out_nodes)
		out_nodes.append({"name": name_of[j]})
	for j in joints:
		p = new_parent[j]
		local = bind[j] if p not in joints else np.linalg.inv(bind[p]) @ bind[j]
		out_nodes[index[j]]["translation"] = local[:3, 3].tolist()
		out_nodes[index[j]]["rotation"] = quat(local[:3, :3])
		kids = [index[c] for c in joints if new_parent[c] == j]
		if kids:
			out_nodes[index[j]]["children"] = kids
	armature = len(out_nodes)
	out_nodes.append({"name": "CharacterArmature", "children": [index[j] for j in root]})

	w = Writer()
	inv_bind = np.array([np.linalg.inv(bind[j]).T for j in joints], dtype=np.float32).reshape(-1, 16)
	ibm_acc = w.add(inv_bind, "MAT4", 5126)
	out_skin = {"joints": [index[j] for j in joints], "inverseBindMatrices": ibm_acc, "skeleton": index[root[0]]}
	normal_m = np.linalg.inv(mesh_world[:3, :3]).T

	out_meshes = []
	mesh_nodes = []
	for n in skinned:
		mesh = gltf["meshes"][nodes[n]["mesh"]]
		prims = []
		for p in mesh["primitives"]:
			a = p["attributes"]
			pos = accessor(gltf, blob, a["POSITION"]).astype(np.float64)
			pos = (mesh_world[:3, :3] @ pos.T).T + mesh_world[:3, 3]
			nrm = accessor(gltf, blob, a["NORMAL"]).astype(np.float64)
			nrm = (normal_m @ nrm.T).T
			nrm /= np.linalg.norm(nrm, axis=1, keepdims=True)
			attrs = {
				"POSITION": w.add(pos.astype(np.float32), "VEC3", 5126, 34962, True),
				"NORMAL": w.add(nrm.astype(np.float32), "VEC3", 5126, 34962),
				"JOINTS_0": w.add(accessor(gltf, blob, a["JOINTS_0"]).astype(np.uint16), "VEC4", 5123, 34962),
				"WEIGHTS_0": w.add(accessor(gltf, blob, a["WEIGHTS_0"]).astype(np.float32), "VEC4", 5126, 34962),
			}
			out = {"attributes": attrs, "material": p["material"]}
			if "indices" in p:
				out["indices"] = w.add(accessor(gltf, blob, p["indices"]).reshape(-1).astype(np.uint32), "SCALAR", 5125, 34963)
			prims.append(out)
		out_meshes.append({"name": mesh["name"], "primitives": prims})
		mesh_nodes.append(len(out_nodes))
		out_nodes.append({"name": "Part_" + kind_of(nodes[n]["name"]), "mesh": len(out_meshes) - 1, "skin": 0})

	materials = []
	for m in gltf["materials"]:
		pbr = dict(m.get("pbrMetallicRoughness", {}))
		pbr["metallicFactor"] = 0.0
		pbr["roughnessFactor"] = 1.0
		materials.append({"name": m["name"], "pbrMetallicRoughness": pbr})

	out = {
		"asset": {"version": "2.0", "generator": "project-unicorn tools/people/fix_rig.py"},
		"scene": 0,
		"scenes": [{"nodes": [armature] + mesh_nodes}],
		"nodes": out_nodes,
		"meshes": out_meshes,
		"skins": [out_skin],
		"materials": materials,
		"accessors": w.accessors,
		"bufferViews": w.views,
		"buffers": [{"byteLength": len(w.blob)}],
	}
	write_glb(dst, out, bytes(w.blob))
	return gltf, blob, skinned, mesh_world


def write_glb(path, gltf, blob):
	j = json.dumps(gltf, separators=(",", ":")).encode()
	j += b" " * ((4 - len(j) % 4) % 4)
	b = blob + b"\0" * ((4 - len(blob) % 4) % 4)
	with open(path, "wb") as f:
		f.write(struct.pack("<III", 0x46546C67, 2, 12 + 8 + len(j) + 8 + len(b)))
		f.write(struct.pack("<II", len(j), 0x4E4F534A) + j)
		f.write(struct.pack("<II", len(b), 0x004E4942) + b)


def verify(src_gltf, src_blob, skinned, mesh_world, dst):
	gltf, blob = read_glb(dst)
	nodes = gltf["nodes"]
	world, parent = world_of(gltf)
	skin = gltf["skins"][0]
	ibm = accessor(gltf, blob, skin["inverseBindMatrices"]).reshape(-1, 4, 4).transpose(0, 2, 1)
	fails = []
	for k, j in enumerate(skin["joints"]):
		err = np.abs(world(j) @ ibm[k] - np.eye(4)).max()
		if err > REST_TOL:
			fails.append("rest of %s does not undo its bind (%.2e)" % (nodes[j]["name"], err))
	names = {n["name"]: i for i, n in enumerate(nodes)}
	for foot, shin in FEET.items():
		if parent.get(names[foot]) != names[shin]:
			fails.append("%s is not under %s" % (foot, shin))
	moved = 0.0
	for k, n in enumerate(skinned):
		src_prims = src_gltf["meshes"][src_gltf["nodes"][n]["mesh"]]["primitives"]
		for src_prim, prim in zip(src_prims, gltf["meshes"][k]["primitives"]):
			old = accessor(src_gltf, src_blob, src_prim["attributes"]["POSITION"]).astype(np.float64)
			old = (mesh_world[:3, :3] @ old.T).T + mesh_world[:3, 3]
			new = accessor(gltf, blob, prim["attributes"]["POSITION"])
			step = max(1, len(old) // CHECK_VERTICES)
			moved = max(moved, float(np.abs(old[::step] - new[::step]).max()))
	if moved > VERTEX_TOL:
		fails.append("vertices moved %.4f m" % moved)
	heights = [accessor(gltf, blob, p["attributes"]["POSITION"])[:, 1] for m in gltf["meshes"] for p in m["primitives"]]
	lo = min(np.min(y) for y in heights)
	hi = max(np.max(y) for y in heights)
	print("%s: %d bones, height %.3f..%.3f m, max vertex move %.2e" % (dst, len(skin["joints"]), lo, hi, moved))
	return fails


def main():
	src, dst = sys.argv[1], sys.argv[2]
	src_gltf, src_blob, skinned, mesh_world = rebuild(src, dst)
	fails = verify(src_gltf, src_blob, skinned, mesh_world, dst)
	for f in fails:
		print("FAIL " + f)
	sys.exit(1 if fails else 0)


if __name__ == "__main__":
	main()
