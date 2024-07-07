options(width=180)

len = length
lens = lengths

# proj.root: full path to parent of /code.r/fio.r
proj.root = strsplit(file.path(getwd(),''),file.path('','code.r',''))[[1]][1]

root.path = function(...,create=FALSE){
  # e.g. root.path('abc','123') returns proj.root/abc/123
  path = file.path(proj.root,...)
  if (create & !dir.exists(dirname(path))){
    dir.create(dirname(path),recursive=TRUE) }
  return(path)
}

even.len = function(x){
  # truncate vector x to have an even length
  length(x) = len(x) - (len(x) %% 2)
  return(x)
}

last = function(x){
  # get the last element in x or NA if len(x) == 0
  ifelse(len(x),tail(x,1),NA)
}

reppend = function(x,xa,n){
  append(x,rep.int(xa,n))
}

list.update = function(x,xu=list(),...){
  # e.g. list.update(list(a=1,b=2),xu=list(a=3),b=4) -> list(a=3,b=4)
  args = c(xu,list(...))
  for (name in names(args)){
    x[[name]] = args[[name]]
  }
  return(x)
}

par.lapply = function(...,.par=TRUE){
  if (.par){
    parallel::mclapply(...,mc.cores=7)
  } else {
    lapply(...)
  }
}

rbind.lapply = function(...){
  do.call(rbind,par.lapply(...))
}
