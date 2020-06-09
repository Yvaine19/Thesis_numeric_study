name <- "input"
filename =  paste0(name,'.inc')
njobs = 3 #nrow(prace)
nmaint = 2
nmach = 2
cat('set  j jobs /1*',njobs,'/;\n',file=filename,sep="",append=T)
cat('set  m maintenance /1*',nmaint,'/;\n',file=filename,sep="",append=T)
cat('set  c machines /1*',nmach,'/;\n',file=filename,sep="",append=T)

cat('alias(i,j);\n',file=filename,sep="",append=T)

adj_matrix <- matrix(c(0,1,0,0,0,1,0,0,0), byrow = TRUE, nrow = 3)
edges = which(adj_matrix !=0,arr.ind = T)
cat('sets edg(i,j) /\n',apply(edges,1,function(x) paste0('\t',x[1],'.',x[2],'\n' )),'/;\n',file=filename,sep="",append=T)

adj_mat_2 <- matrix(c(0,0,1,0,0,0,0,0,0), byrow = TRUE, nrow = 3) 
hedges = which(adj_mat_2 !=0,arr.ind = T)
cat('sets hedg(i,j) /\n',apply(hedges,1,function(x) paste0('\t',x[1],'.',x[2],'\n' )),'/;\n',file=filename,sep="",append=T)

price <- 20
cat('scalar price "price for outsourcing" /',price,'/;\n',file=filename,sep="",append=T)
cat('scalar big_J "big M constant" /',njobs,'/;\n',file=filename,sep="",append=T)

costs <- c(2, 3)
cat('Parameters costs(m) /',sapply(1:length(costs),function(x) paste0('\n', x,' ',costs[x])),'\n/;\n',file=filename,sep="",append=T)

penalties <- matrix(c(0,4,0,0,0,5,0,0,0), byrow = TRUE, nrow = 3)
pens = which(penalties !=0,arr.ind = T)
cat('Parameters q(i,j) "penalties" /\n',apply(pens,1,function(x) paste0('\t',x[1],'.',x[2],' ',penalties[x[1],x[2]],'\n' )),'/;\n',file=filename,sep="",append=T)

improvements <- matrix(c(0,3,0,0,0,3,0,0,0), byrow = TRUE, nrow = 3)
imps = which(improvements !=0,arr.ind = T)
cat('Parameters delta(i,j) "improvements" /\n',apply(imps,1,function(x) paste0('\t',x[1],'.',x[2],' ',improvements[x[1],x[2]],'\n' )),'/;\n',file=filename,sep="",append=T)
