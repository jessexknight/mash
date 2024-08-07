source('sim/meta.r')

# =============================================================================
# config

key.vars = c('age',
  'vio.nt','vio.n1y',
  'dep.now','dep.past',
  'haz.now','haz.past',
  'ptr.nw','ptr.nt')

vals = list(
  # base rates
  'Ri.all'=list(save=NULL,vars=key.vars,among=quote(sex.act)),
  # RR age
  'aRR.vio'=list(save=c('aRR.vio'),  vars=c('vio.n1y'),  strat='age.10'),
  'aRR.dep'=list(save=c('aRR.dep_o'),vars=c('dep_o.a1y'),strat='age.10'),
  'aRR.haz'=list(save=c('aRR.haz_o'),vars=c('haz_o.a1y'),strat='age.10'),
  'aRR.ptr'=list(save=c('aRR.ptr_o'),vars=c('ptr_o.n1y'),strat='age.10',among=quote(sex.act)),
  # basic RR
  'RR.dep_o.dep_p'=list(save='RR.dep_o.dep_p',vars='dep_o.a1y',strat='yp.dep.past',among=quote(!yp.dep.now)),
  'RR.haz_o.haz_p'=list(save='RR.haz_o.haz_p',vars='haz_o.a1y',strat='yp.haz.past',among=quote(!yp.haz.now)),
  'RR.haz_o.dep_w'=list(save='RR.haz_o.dep_w',vars='haz_o.a1y',strat='yp.dep.now', among=quote(!yp.haz.now)),
  'RR.haz_x.dep_w'=list(save='RR.haz_x.dep_w',vars='haz_x.a1y',strat='yp.dep.now', among=quote( yp.haz.now)),
  'RR.ptr_o.dep_w'=list(save='RR.ptr_o.dep_w',vars='ptr_o.n1y',strat='yp.dep.now', among=quote(sex.act)),
  'RR.ptr_o.haz_w'=list(save='RR.ptr_o.haz_w',vars='ptr_o.n1y',strat='yp.haz.now', among=quote(sex.act)),
  'RR.ptr_x.dep_w'=list(save='RR.ptr_x.dep_w',vars='ptr_x.n1y',strat='yp.dep.now', among=quote(sex.act)),
  'RR.ptr_x.haz_w'=list(save='RR.ptr_x.haz_w',vars='ptr_x.n1y',strat='yp.haz.now', among=quote(sex.act)),
  # transient RR
  'tRR.dep_o.vio_z'=list(save=c('iRR.dep_o.vio_z','tsc.dep_o.vio_z'),vars='dep_o.a1y',strat='vio.a1y',among=quote(!yp.dep.now)),
  'tRR.dep_x.vio_z'=list(save=c('iRR.dep_x.vio_z','tsc.dep_x.vio_z'),vars='dep_x.a1y',strat='vio.a1y',among=quote( yp.dep.now)),
  'tRR.haz_o.vio_z'=list(save=c('iRR.haz_o.vio_z','tsc.haz_o.vio_z'),vars='haz_o.a1y',strat='vio.a1y',among=quote(!yp.haz.now)),
  'tRR.haz_x.vio_z'=list(save=c('iRR.haz_x.vio_z','tsc.haz_x.vio_z'),vars='haz_x.a1y',strat='vio.a1y',among=quote( yp.haz.now)),
  'tRR.ptr_o.vio_z'=list(save=c('iRR.ptr_o.vio_z','tsc.ptr_o.vio_z'),vars='ptr_o.n1y',strat='vio.a1y',among=quote(sex.act)),
  # cumulative RR
  'nRR.dep_o.vio_n'=list(save=c('mRR.dep_o.vio_n','nsc.dep_o.vio_n'),vars='dep_o.a1y',strat='yp.vio.nt.c',among=quote(!yp.dep.now)),
  'nRR.haz_o.vio_n'=list(save=c('mRR.haz_o.vio_n','nsc.haz_o.vio_n'),vars='haz_o.a1y',strat='yp.vio.nt.c',among=quote(!yp.haz.now)),
  'nRR.ptr_o.vio_n'=list(save=c('mRR.ptr_o.vio_n','nsc.ptr_o.vio_n'),vars='ptr_o.n1y',strat='yp.vio.nt.c',among=quote(sex.act)),
  # duration RR
  'dRR.dep_x.dep_u'=list(save=c('dsc.dep_x.dep_u'),vars='dep_x.a1y',strat='yp.dep.dur.c',among=quote(yp.dep.now)),
  'dRR.haz_x.haz_u'=list(save=c('dsc.haz_x.haz_u'),vars='haz_x.a1y',strat='yp.haz.dur.c',among=quote(yp.dep.now)),
  # default
  'default'=ulist(lapply(null.all,function(re){ NULL }),vars=key.vars,among=quote(sex.act))
)
for (v in names(vals)){ vals[[v]]$name = v }

# =============================================================================
# run & plot

val.run = function(name,vars,among=quote(TRUE),strat='.',...){
  Ps = lapply(1:7,get.pars,n=333,
    null=ulist('Ri\\.m$'=NULL,...))
  Q = srv.apply(sim.runs(Ps),srvs=c(srv.val))
  Q = subset(Q,age < amax & eval(among))
  g = val.plot(Q,vars,strat)
  plot.save('val',uid,name,h=3,w=1+3*len(vars))
}

val.plot = function(Q,vars,strat='.'){
  # plot the densities for multiple (7) seeds using:
  # boxplot if var is binary else line+ribbon
  # pre-compute group-wise densities b/c no ggplot support
  g = c('seed',strat) # grouping variables
  Q = cbind(Q,.='')[c(g,vars)]
  Qd = rbind.lapply(vars,.par=FALSE,function(var){
    x = as.numeric(Q[[var]]) # extract data
    b = breaks(x) # compute breaks
    Qx = aggregate(x,Q[g],function(xg){ # for each group
      x = sum1(hist(xg,breaks=b,right=FALSE,plot=FALSE)$count) }) # compute density
    if (len(b) == 2){ Qd = cbind(d.bin=1,d.cts=NA,b=b[1]) } # singleton
    if (len(b) == 3){ Qd = cbind(d.bin=Qx$x[,2],d.cts=NA,b=b[2]) } # binary
    if (len(b) >  3){ Qd = cbind(d.cts=c(Qx$x),d.bin=NA,b=rep(b[-len(b)],each=nrow(Qx))) }
    Qdv = cbind(Qx[g],var=var,Qd)
  })
  g = ggplot(Qd,aes(x=b,y=100*as.numeric(d.cts),
      color = as.factor(.data[[strat]]),
      fill  = as.factor(.data[[strat]]))) +
    facet_wrap('~var',scales='free',ncol=len(vars)) +
    stat_summary(geom='ribbon',fun.min=min,fun.max=max,alpha=.3,color=NA) +
    stat_summary(geom='line',fun=median) +
    geom_boxplot(aes(y=100*as.numeric(d.bin),group=interaction(b,.data[[strat]])),
      alpha=.3,outlier.alpha=1,outlier.shape=3) +
    labs(x='value',y='proportion (%)',color=strat,fill=strat) +
    scale_x_continuous(expand=c(.1,.1)) +
    scale_color_viridis_d() +
    scale_fill_viridis_d() +
    ylim(c(0,NA))
  g = plot.clean(g)
}

# =============================================================================
# main

for (val in vals){
  do.call(val.run,val,quote=TRUE); break }
