set.seed(42)

m <- 10

library(stats)
#install.packages(stats)

## parameters setting
lambda_1 <- 0.2 # parameter to generate job length
lambda_2 <- 0.05 # parameter to generate break length
njobs <- 6 # number of jobs
nmach <- 5 # number of machines

lengths <- c(rexp(n = njobs, rate = lambda_1))
breaks <- c(rexp(n = njobs-1, rate = lambda_2))

start_times <-c(rep(0,j))
for (i in 1:(njobs-1)) {
  start_times[i+1] <- start_times[i] + lengths[i] + breaks[i]   
}                

finish_times <-c(rep(0,njobs))
for (i in 1:j) {
  finish_times[i] <- start_times[i] + lengths[i]   
}

hedges_adj <- matrix(0L, nrow = njobs, ncol = njobs)
for (i in 1:njobs) {
  for (j in 1:njobs) {
    if (i != j) {
      if (start_times[i] <= start_times[j] && start_times[j] < finish_times[i]){
            hedges_adj[i,j] <- 1
      }
    }
  }
}

edges_adj <- matrix(0L, nrow = njobs, ncol = njobs)
for (i in 1:njobs) {
  for (j in 1:njobs) {
    if (i > j) {
      if (start_times[i] >= finish_times[j]){
        edges_adj[j,i] <- 1
      }
    }
  }
}

p_no <- 0.9
lambda_d <- 0.2
penalties <- matrix(0L, nrow = njobs, ncol = njobs)
for (i in 1:njobs) {
  for (j in 1:njobs) {
    if (edges_adj[i,j] == 1){
      penalties[i,j] <- (1-p_no)*(exp(- lambda_d*(start_times[j]-finish_times[i])))
    }  
  }
}


#
#breaks <- c(0,breaks)
#df<- cbind(start_times,finish_times, breaks)
#View(df)

name <- "input_bigger"
filename =  paste0(name,'.inc')
nmaint = 2
cat('set  j jobs /1*',njobs,'/;\n',file=filename,sep="",append=T)
cat('set  m maintenance /1*',nmaint,'/;\n',file=filename,sep="",append=T)
cat('set  c machines /1*',nmach,'/;\n',file=filename,sep="",append=T)

cat('alias(i,j);\n',file=filename,sep="",append=T)

edges = which(edges_adj !=0,arr.ind = T)
cat('sets edg(i,j) /\n',apply(edges,1,function(x) paste0('\t',x[1],'.',x[2],'\n' )),'/;\n',file=filename,sep="",append=T)

hedges = which(hedges_adj !=0,arr.ind = T)
cat('sets hedg(i,j) /\n',apply(hedges,1,function(x) paste0('\t',x[1],'.',x[2],'\n' )),'/;\n',file=filename,sep="",append=T)

price <- 20
cat('scalar price "price for outsourcing" /',price,'/;\n',file=filename,sep="",append=T)
cat('scalar big_J "big M constant" /',njobs,'/;\n',file=filename,sep="",append=T)

costs <- c(2, 3)
cat('Parameters costs(m) /',sapply(1:length(costs),function(x) paste0('\n', x,' ',costs[x])),'\n/;\n',file=filename,sep="",append=T)

pens = which(penalties !=0,arr.ind = T)
cat('Parameters q(i,j) "penalties" /\n',apply(pens,1,function(x) paste0('\t',x[1],'.',x[2],' ',penalties[x[1],x[2]],'\n' )),'/;\n',file=filename,sep="",append=T)

improvements <- penalties / 2
imps = which(improvements !=0,arr.ind = T)
cat('Parameters delta(i,j) "improvements" /\n',apply(imps,1,function(x) paste0('\t',x[1],'.',x[2],' ',improvements[x[1],x[2]],'\n' )),'/;\n',file=filename,sep="",append=T)
