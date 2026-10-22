import sys,re
from pathlib import Path
from collections import Counter,defaultdict
D=Path(sys.argv[1])
for p in sorted(D.glob("*.log")):
    papers=[];mis=0;unnamed=0;closes=0;load=Counter();sprints_per_seed=Counter()
    for l in p.read_text(encoding="utf-8",errors="replace").splitlines():
        if l.startswith("SPRINTPROBE PAPER|"):
            t=l.split("|");papers.append((t[1],t[2],t[3],t[4]))
        elif l.startswith("SPRINTPROBE CLOSE|"):
            closes+=1
            if "MISMATCH" in l:
                mis+=1
                if "cause=" not in l: unnamed+=1
        elif l.startswith("SPRINTPROBE LOAD|"):
            sprints_per_seed[l.split("|")[1]]+=1
    per_sprint=Counter((a,b) for a,b,_,_ in papers)
    per_seed_card=Counter((a,c) for a,_,c,_ in papers)
    spk=Counter(s for *_,s in papers)
    print(p.name,"sprints/seed min-max",min(sprints_per_seed.values()),max(sprints_per_seed.values()),"papers",len(papers),"max papers in one sprint",max(per_sprint.values()) if per_sprint else 0,
      "max same card/seed",max(per_seed_card.values()) if per_seed_card else 0,"closes",closes,"mismatch",mis,"unnamed",unnamed, "speakers",dict(spk))
