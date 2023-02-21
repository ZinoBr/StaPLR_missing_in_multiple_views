sim_normal_views_beta <- function(v, m, ntrain, ntest, s, abs_beta, rw, rb){
  # Generates a multi-view dataset where the features follow a standard normal distribution
  #
  # Args:
  #   v: the number of views.
  #   m: a vector of length 'v', giving for each view the number of features.
  #   n: the number of observations
  #   s: a vector of length 'v', giving for each view the proportion of signal.
  #   abs_beta: a vector of length sum(m) containing regression weights
  #   rw: the population correlation coefficient WITHIN each view
  #   rb: the population correlation coefficient BETWEEN each view
  
  if(length(m) != v | length(s) != v){
    stop("Arguments m and s should be of length v!")
  }
  
  n <- ntrain + ntest
  
  # Generate features
  X <- blockcorrelate(n, m, v, rw, rb)
  
  # Create a vector of regression weights
  u <- c()
  for(i in 1:v){
    u <- c(u, sample(c(rep(0, ceiling(m[i]*(1-s[i]))), rep(1, ceiling(m[i]*s[i]))), size=m[i]))
  }
  u2 <- runif(ncol(X))
  signer <- ifelse(u == 1, ifelse(u2 < 0.5, -1, 1), 0)
  beta <- abs_beta*signer
  
  # Linear predictors
  eta <- X %*% beta
  
  # Cut off linear predictors to prevent overflow
  eta[eta > 700] <- 700
  
  # Probabilities
  p <- exp(eta)/(1 + exp(eta))
  
  # Binary response y
  y <- matrix(rbinom(n, 1, p), n, 1)
  
  # True view indicator
  tv <- which(s > 0)
  
  # Split into train and test set
  robs <- sample(1:n)
  trainobs <- robs[1:ntrain]
  testobs <- robs[(ntrain+1):n]
  xtrain <- X[trainobs,]
  xtest <- X[testobs,]
  ytrain <- y[trainobs]
  ytest <- y[testobs]
  ptrain <- p[trainobs]
  ptest <- p[testobs]
  
  out <- list(xtrain=xtrain, xtest=xtest, ytrain=ytrain, ytest=ytest, ptrain=ptrain, ptest=ptest, s=s, m=m, beta=beta, tv=tv)
  
  return(out)
  
}