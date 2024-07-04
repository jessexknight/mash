
# time stuff
dtz  =  7 # days in 1 timestep
z1y  = 52 # timesteps in 1 year
z3m  = 13 # timesteps in 3 months
z6m  = 26 # timesteps in 6 months
amin = 15 # age of cohort entry
amax = 60 # age of cohort exit
adur = amax - amin # duration in cohort
eps  = 1e-12 # a small number

# event types
evts = c(
  'vio.e',
  'dep.o','dep.x',
  'alc.o','alc.x',
  'ptr.o','ptr.x',
  'sex.e','cdm.b')
names(evts) = evts
