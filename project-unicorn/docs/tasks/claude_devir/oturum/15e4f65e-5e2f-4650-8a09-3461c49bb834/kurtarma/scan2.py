import json, glob, os
P='/Users/tugbauysal/.claude/projects/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834'
files=[P+'.jsonl']+sorted(glob.glob(P+'/subagents/**/agent-*.jsonl',recursive=True))
out=[]
for fn in files:
    uses={}
    for ln in open(fn):
        try: o=json.loads(ln)
        except: continue
        m=o.get('message') or {}
        c=m.get('content')
        if not isinstance(c,list): continue
        for b in c:
            if b.get('type')=='tool_use':
                uses[b['id']]=(o.get('timestamp'),b['name'],b.get('input',{}))
            elif b.get('type')=='tool_result':
                u=uses.get(b.get('tool_use_id'))
                if not u: continue
                rc=b.get('content')
                if isinstance(rc,list): rc='\n'.join(x.get('text','') for x in rc if isinstance(x,dict))
                out.append(dict(ts=u[0] or o.get('timestamp'),rts=o.get('timestamp'),tr=os.path.basename(fn)[:-6],name=u[1],inp=u[2],err=b.get('is_error',False),txt=rc,res=o.get('toolUseResult')))
[x.__setitem__('rts', x['rts'] or x['ts'] or '') for x in out]; out.sort(key=lambda x:x['rts'])
for i,x in enumerate(out): x['i']=i
json.dump(out,open('all_uses.json','w'))
with open('timeline.txt','w') as f:
    for x in out:
        if x['name'] in ('Bash','Edit','Write'):
            s=x['inp'].get('command') or x['inp'].get('file_path')
            f.write(f"{x['i']:5d} {x['rts'][5:19]} {x['tr'][:12]:12s} {x['name'][:4]} {'ERR ' if x['err'] else ''}{s[:400]!r}\n")
print(len(out))
