import json, sys, glob, os, collections
P='/Users/tugbauysal/.claude/projects/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834'
S='/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
files=[P+'.jsonl']+sorted(glob.glob(P+'/subagents/**/*.jsonl',recursive=True))
out=[]
for fn in files:
    if fn.endswith('journal.jsonl'): continue
    uses={}
    with open(fn) as f:
        for ln in f:
            try: o=json.loads(ln)
            except: continue
            m=o.get('message') or {}
            c=m.get('content')
            if isinstance(c,list):
                for b in c:
                    if b.get('type')=='tool_use':
                        uses[b['id']]=(o.get('timestamp'),b['name'],b.get('input',{}))
                    if b.get('type')=='tool_result':
                        u=uses.get(b.get('tool_use_id'))
                        if not u: continue
                        ts,name,inp=u
                        err=b.get('is_error',False)
                        out.append(dict(ts=ts,tr=os.path.basename(fn),name=name,inp=inp,err=err,res=o.get('toolUseResult')))
json.dump(out,open('all_uses.json','w'))
print(len(out))
c=collections.Counter((x['name']) for x in out); print(c.most_common(30))
