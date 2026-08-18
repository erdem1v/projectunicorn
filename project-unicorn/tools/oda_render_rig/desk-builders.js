import * as THREE from 'three';

export const M = {
  alu:   new THREE.MeshStandardMaterial({name:'aluminum', color:0xc9cbce, roughness:0.4, metalness:0.35}),
  aluDark:new THREE.MeshStandardMaterial({name:'aluminum_dark', color:0x9fa2a6, roughness:0.45, metalness:0.35}),
  black: new THREE.MeshStandardMaterial({name:'matte_black', color:0x2b2c2f, roughness:0.6, metalness:0.1}),
  key:   new THREE.MeshStandardMaterial({name:'keycap_black', color:0x1e1f22, roughness:0.55, metalness:0.05}),
  screen:new THREE.MeshStandardMaterial({name:'screen_glass', color:0x141117, roughness:0.2, metalness:0.2}),
  cream: new THREE.MeshStandardMaterial({name:'cream_ceramic', color:0xefe6d4, roughness:0.45, metalness:0.0}),
  paper: new THREE.MeshStandardMaterial({name:'paper', color:0xf6efdf, roughness:0.9, metalness:0.0}),
  wood:  new THREE.MeshStandardMaterial({name:'oak_wood', color:0xb5854c, roughness:0.7, metalness:0.0}),
  woodD: new THREE.MeshStandardMaterial({name:'oak_wood_dark', color:0x8f6636, roughness:0.7, metalness:0.0}),
  cork:  new THREE.MeshStandardMaterial({name:'cork', color:0xc79a60, roughness:0.95, metalness:0.0}),
  bulb:  new THREE.MeshStandardMaterial({name:'warm_bulb', color:0xffe9be, roughness:0.4, emissive:0xffdda0, emissiveIntensity:0.6}),
  brass: new THREE.MeshStandardMaterial({name:'brass', color:0xd9b36a, roughness:0.35, metalness:0.4})
};

export function box(name, mat, w,h,d, x=0,y=0,z=0){
  const m = new THREE.Mesh(new THREE.BoxGeometry(w,h,d), mat);
  m.name = name; m.position.set(x,y,z); return m;
}
export function tube(name, mat, p1, p2, r, seg=20){
  const v = new THREE.Vector3().subVectors(p2,p1), len = v.length();
  const m = new THREE.Mesh(new THREE.CylinderGeometry(r,r,len,seg), mat);
  m.name = name;
  m.position.copy(p1).addScaledVector(v,0.5);
  m.quaternion.setFromUnitVectors(new THREE.Vector3(0,1,0), v.clone().normalize());
  return m;
}
export function roundedRect(w,l,r){
  const s = new THREE.Shape(), hw=w/2, hl=l/2;
  s.moveTo(-hw+r,-hl);
  s.lineTo(hw-r,-hl); s.quadraticCurveTo(hw,-hl,hw,-hl+r);
  s.lineTo(hw,hl-r);  s.quadraticCurveTo(hw,hl,hw-r,hl);
  s.lineTo(-hw+r,hl); s.quadraticCurveTo(-hw,hl,-hw,hl-r);
  s.lineTo(-hw,-hl+r);s.quadraticCurveTo(-hw,-hl,-hw+r,-hl);
  return s;
}

export function buildMonitor(){
  const g = new THREE.Group(); g.name = 'monitor';
  g.add(box('stand_base', M.alu, 0.20, 0.006, 0.17, 0, 0.003, 0.045));
  const neck = box('stand_neck', M.alu, 0.16, 0.22, 0.016, 0, 0.115, -0.005);
  neck.rotation.x = -0.22; g.add(neck);
  const disp = new THREE.Group(); disp.name = 'display';
  disp.position.set(0, 0.30, 0.01); disp.rotation.x = -0.09;
  disp.add(box('display_body', M.alu, 0.55, 0.37, 0.028));
  disp.add(box('screen', M.screen.clone(), 0.526, 0.318, 0.0016, 0, 0.019, 0.017));   // 0.0148 -> 0.017: rig FIDELITY duzeltmesi 2026-08-17. Muhurlu kaynak 0.017 diyor;
  // rig eski bir surumden kopyalanmis. 2.2mm derinlik, MONITOR_GLASS_REL'i kil payi kaydirir.
  disp.add(box('chin', M.aluDark, 0.526, 0.001, 0.0012, 0, -0.145, 0.0146));
  g.add(disp);
  return g;
}

export function buildKeyboard(){
  const g = new THREE.Group(); g.name = 'keyboard';
  const W = 0.285, D = 0.115, U = 15;
  const u = W/U, gap = 0.0016;
  g.add(box('body', M.alu, W, 0.009, D, 0, 0.0045, 0));
  const rows = [
    {ws:Array(13).fill(U/13), d:0.55},
    {ws:[...Array(13).fill(1),2], d:1},
    {ws:[1.5,...Array(12).fill(1),1.5], d:1},
    {ws:[1.8,...Array(11).fill(1),2.2], d:1},
    {ws:[2.4,...Array(10).fill(1),2.6], d:1},
    {ws:[1,1,1,1.3,5.4,1.3,1,1,1,1], d:1}
  ];
  const rowDepth = u, edge = 0.006, keyH = 0.0035;
  let z = -D/2 + edge + (rows[0].d*rowDepth)/2;
  const keys = new THREE.Group(); keys.name = 'keys';
  rows.forEach((row,ri)=>{
    let x = -W/2 + edge;
    const usable = W - edge*2, total = row.ws.reduce((a,b)=>a+b,0);
    row.ws.forEach((w,ki)=>{
      const kw = (w/total)*usable;
      keys.add(box(`key_r${ri}_${ki}`, M.key, kw-gap, keyH, row.d*rowDepth-gap, x+kw/2, 0.009+keyH/2, z));
      x += kw;
    });
    z += (row.d*rowDepth)/2 + rowDepth/2 + 0.0004;
  });
  g.add(keys);
  return g;
}

export function buildLamp(){
  const g = new THREE.Group(); g.name = 'desk_lamp';
  const base = new THREE.Mesh(new THREE.CylinderGeometry(0.055,0.06,0.016,36), M.black);
  base.name = 'base'; base.position.y = 0.008; g.add(base);
  const j0 = new THREE.Vector3(0, 0.018, 0);
  const elbow = new THREE.Vector3(0, 0.225, -0.075);
  const head = new THREE.Vector3(0, 0.36, 0.075);
  g.add(tube('arm_lower', M.black, j0, elbow, 0.007));
  g.add(tube('arm_upper', M.black, elbow, head, 0.007));
  const jm = (name,p)=>{ const j = new THREE.Mesh(new THREE.CylinderGeometry(0.013,0.013,0.026,20), M.black); j.name=name; j.rotation.z=Math.PI/2; j.position.copy(p); return j; };
  g.add(jm('joint_base', j0), jm('joint_elbow', elbow), jm('joint_head', head));
  // Abajur profili — MÜHÜRLÜ KAYNAĞIN KENDİSİ, on nokta, düz parçalarla.
  // 2026-08-17'de bunu spline'a çevirip ikiye bölmüş (dış kabuk + krem astar) ve
  // GERİ ALMIŞIMDIR. Sebep kayda değer: baş "kapüşonlu göz" gibi okuyordu ve ben
  // kırışıklık + karanlık iç sanıp ikisini de "düzelttim". Gerçek sebep BAŞIN
  // NİŞANIYDI (layers.html'deki quaternion bloğu) — ağzı kameraya çeviriyordu,
  // yani aydınlanmayan iç yüzey objenin en büyük yüzeyi oluyordu. Astar lambayı
  // siyah olmaktan çıkardı; kırışıklar ise nişan yüzünden profil kenardan
  // göründüğü için fark ediliyordu. Nişan kalkınca ikisi de gereksiz.
  // Lamba HER İKİ MODDA DÜZ SİYAHTIR; değişen tek şey ışık, gece ampul yanar.
  const pts = [];
  [[0.004,0.095],[0.024,0.09],[0.05,0.055],[0.06,0.018],[0.061,0.004],[0.058,0.002],[0.05,0.014],[0.04,0.045],[0.02,0.078],[0.004,0.085]]
    .forEach(p=>pts.push(new THREE.Vector2(p[0],p[1])));
  const shade = new THREE.Mesh(new THREE.LatheGeometry(pts, 40), M.black);
  shade.name = 'shade';
  const bulb = new THREE.Mesh(new THREE.SphereGeometry(0.02, 24, 16), M.bulb.clone());
  bulb.name = 'bulb'; bulb.position.y = 0.028;
  const headG = new THREE.Group(); headG.name = 'head';
  headG.add(shade, bulb);
  headG.position.copy(head).add(new THREE.Vector3(0, -0.075, 0.04));
  // SABİT pitch — ağız AŞAĞI/UZAĞA bakar, kamera siyah dış kabuğu görür.
  // layers.html BUNU ARTIK EZMİYOR (nişan bloğu kaldırıldı, bilinçli override).
  headG.rotation.set(-0.6, 0, 0);
  g.add(headG);
  return g;
}

export function buildPhone(){
  const g = new THREE.Group(); g.name = 'phone';
  const bodyGeo = new THREE.ExtrudeGeometry(roundedRect(0.072, 0.150, 0.012), {depth:0.0062, bevelEnabled:true, bevelThickness:0.0007, bevelSize:0.0007, bevelSegments:3, curveSegments:24});
  const body = new THREE.Mesh(bodyGeo, M.aluDark); body.name = 'body';
  body.rotation.x = -Math.PI/2; body.position.y = 0.0007;
  g.add(body);
  const scrGeo = new THREE.ExtrudeGeometry(roundedRect(0.066, 0.144, 0.009), {depth:0.0006, bevelEnabled:false, curveSegments:24});
  const scr = new THREE.Mesh(scrGeo, M.screen); scr.name = 'screen';
  scr.rotation.x = -Math.PI/2; scr.position.y = 0.0078;
  g.add(scr);
  const cam = new THREE.Mesh(new THREE.CylinderGeometry(0.0035,0.0035,0.0008,20), M.black);
  cam.name = 'camera'; cam.position.set(0, 0.0082, -0.062);
  g.add(cam);
  return g;
}

export function buildMug(){
  const g = new THREE.Group(); g.name = 'mug';
  const prof = [[0.012,0.0],[0.038,0.0],[0.041,0.004],[0.043,0.03],[0.044,0.06],[0.0445,0.092],[0.0405,0.092],[0.040,0.06],[0.039,0.03],[0.037,0.008],[0.012,0.008]]
    .map(p=>new THREE.Vector2(p[0],p[1]));
  const bodyMesh = new THREE.Mesh(new THREE.LatheGeometry(prof, 48), M.cream);
  bodyMesh.name = 'body'; g.add(bodyMesh);
  const handle = new THREE.Mesh(new THREE.TorusGeometry(0.026, 0.0062, 14, 32), M.cream);
  handle.name = 'handle';
  handle.position.set(0.052, 0.048, 0); handle.scale.set(0.8, 1, 1);
  g.add(handle);
  return g;
}

export function buildFrame(){
  const g = new THREE.Group(); g.name = 'picture_frame';
  const w = 0.14, h = 0.19, bar = 0.013, d = 0.014;
  g.add(box('bar_top', M.wood, w, bar, d, 0, h-bar/2, 0));
  g.add(box('bar_bottom', M.wood, w, bar, d, 0, bar/2, 0));
  g.add(box('bar_left', M.woodD, bar, h-2*bar, d, -w/2+bar/2, h/2, 0));
  g.add(box('bar_right', M.woodD, bar, h-2*bar, d, w/2-bar/2, h/2, 0));
  g.add(box('backing', M.paper, w-2*bar+0.002, h-2*bar+0.002, 0.003, 0, h/2, -0.001));
  return g;
}

export function buildCorkboard(){
  const g = new THREE.Group(); g.name = 'cork_board';
  const w = 0.92, h = 0.62, bar = 0.036, d = 0.026;
  g.add(box('bar_top', M.woodD, w, bar, d, 0, h-bar/2, 0));
  g.add(box('bar_bottom', M.woodD, w, bar, d, 0, bar/2, 0));
  g.add(box('bar_left', M.woodD, bar, h-2*bar, d, -w/2+bar/2, h/2, 0));
  g.add(box('bar_right', M.woodD, bar, h-2*bar, d, w/2-bar/2, h/2, 0));
  g.add(box('cork_panel', M.cork, w-2*bar+0.004, h-2*bar+0.004, 0.012, 0, h/2, -0.004));
  const notes = [[-0.17, h/2+0.09, 0.11, 0.075, 0.05], [0.20, h/2-0.02, 0.13, 0.09, -0.03]];
  notes.forEach((n,i)=>{
    const note = box(`note_${i+1}`, M.paper, n[2], n[3], 0.0012, n[0], n[1], 0.0032);
    note.rotation.z = n[4]; g.add(note);
    const pinHead = new THREE.Mesh(new THREE.SphereGeometry(0.0045, 16, 12), M.brass);
    pinHead.name = `pin_head_${i+1}`;
    pinHead.position.set(n[0], n[1]+n[3]/2-0.008, 0.007);
    g.add(pinHead);
  });
  return g;
}
