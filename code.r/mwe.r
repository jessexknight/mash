source('meta.r')

Ps = lapply(1:7,get.pars)
Ms = sim.runs(Ps)
Q  = srv.apply(Ms)

print(summary(Q[Q$age<amax,c(
  'vio.nt',
  'dep.now','dep.past',
  'haz.now','haz.past',
  'ptr.nw','ptr.nt',
  'age'
)]))
