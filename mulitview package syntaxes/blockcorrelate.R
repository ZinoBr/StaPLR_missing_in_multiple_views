blockcorrelate <- function(n, m, b, rw, rb){
  # Generates a matrix of features with a block correlation structure
  #
  # Args:
  #   n: number of observations
  #   m: a vector of length b, giving the number of features *per block*
  #   b: number of blocks
  #   rw: correlation within blocks
  #   rb: correlation between blocks
  #
  # Returns:
  #   A matrix of n rows and sum(m) columns, containing the block correlated features
  
  if(length(m) != b){
    stop("Argument m should be of length b!")
  }
  
  if(rb > rw){
    stop("Correlation between blocks cannot exceed correlation within blocks!")
  }
  
  if(rb == 0 & rw ==0){
    IY <- matrix(rnorm(n*sum(m)), nrow=n, ncol=sum(m))
    warning("Both correlation parameters are zero. Returning independent features.")
    return(IY)
  }
  
  z <- rnorm(n)
  Z <- sqrt(rb/rw) * matrix(rep(z, b), nrow=n, ncol=b) + matrix(rnorm(n*b, mean=0, sd=sqrt(1 - rb/rw)), nrow=n, ncol=b)
  Y <- matrix(NA, nrow=n, ncol=sum(m))
  index <- rep(1:b, m)
  
  for(i in 1:ncol(Y)){
    Y[,i] <- sqrt(rw) * Z[, index[i]] + rnorm(n, mean=0, sd=sqrt(1 - rw))
  }
  
  return(Y)
}