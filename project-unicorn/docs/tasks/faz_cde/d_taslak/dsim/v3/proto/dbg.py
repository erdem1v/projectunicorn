import statistics
orig_release = Sim.release
log=[]
def rel(self,c,extra_known=0):
    if c.kind=="feature" and self.live: log.append((c.H*(1-c.C), c.nbugs-c.found, c.H, c.C, c.nbugs, c.found))
    return orig_release(self,c,extra_known)
Sim.release=rel
for seed in range(1,4):
    s=Sim(SCEN["S3"](),seed); s.run()
print(len(log), statistics.mean(x[0] for x in log), statistics.mean(x[1] for x in log), statistics.mean(x[2] for x in log), statistics.mean(x[3] for x in log), statistics.mean(x[4] for x in log),statistics.mean(x[5] for x in log))
