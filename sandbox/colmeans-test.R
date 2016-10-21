len<-100000

complexvec = complex(r=1:len,i=1:len)
dim(complexvec) = c(len/2,2)

compute <- function(x) colMeans(x)

system.time(compute(complexvec))
