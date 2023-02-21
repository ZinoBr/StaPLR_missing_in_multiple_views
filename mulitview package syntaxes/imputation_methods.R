
# Imputation methods combined with StaPLR

impute_mean <- function(x){
  for(i in 1:ncol(x)){
    if(anyNA(x[,i])){
      x[is.na(x[,i]), i] <- mean(x[, i], na.rm=TRUE)
    }
  }
  return(x)
}

staplr_cca <- function(id, view_index){
  # Applies StaPLR with complete case analysis / list wise deletion
  x <- na.omit(id$xtrain)
  y <- id$ytrain[-attr(x, "na.action")]
  fit <- MVS(x, y, as.matrix(view_index))
  return(fit)
}

# cca_fit <- staplr_cca(incomplete_data, view_index)

staplr_base_mean <- function(id, view_index){
  # Applies StaPLR with unconditional mean imputation at the base level
  x <- impute_mean(id$xtrain)
  y <- id$ytrain
  fit <- MVS(x, y, as.matrix(view_index))
  return(fit)
}

# mean_fit <- staplr_base_mean(incomplete_data, view_index)

staplr_base_forest <- function(id, view_index, ntree){
  # Applies StaPLR with missForest imputation at the base level
  x_df <- data.frame(id$xtrain)
  x_df$y <- factor(id$ytrain)
  x_imputed <- missForest(x_df, ntree=ntree, verbose=TRUE)$ximp
  x <- data.matrix(x_imputed)
  x <- x[, - ncol(x)]
  rm(x_df, x_imputed)
  y <- id$ytrain
  fit <- MVS(x, y, as.matrix(view_index))
  return(fit)
}

# forest_fit <- staplr_base_forest(incomplete_data, view_index, 10)

staplr_base_lasso <- function(id, view_index, m){
  # Multiple lasso imputation with MICE + averaging over imputed data sets
  xy <- cbind(id$xtrain, id$ytrain)
  mice_obj <- mice(xy, m=m, method="lasso.norm")
  x_imputed <- complete(mice_obj, action="all")
  if(m > 1){
    x_array <- array(unlist(x_imputed), dim=c(nrow(xy), ncol(xy), m))
    x_mean <- apply(x_array, c(1,2), mean)
    x <- x_mean[, - ncol(x_mean)]
  } 
  else{
    x_mean <- complete(mice_obj)
    x <- x_mean[, - ncol(x_mean)]
  }
  
  y <- id$ytrain
  fit <- MVS(x, y, as.matrix(view_index))
  return(fit)
}

# mice_fit <- staplr_base_lasso(incomplete_data, view_index, 1)


# Multiple imputation (predictive mean matching)
# mice_small <- mice(cbind(complete_y, small_X), m=5)
# complete(mice_small, action="all")


staplr_pass_thru <- function(x, y, view_index){
  # Performs the base-level fitting of a StaPLR model with missingness pass-through
  base_fits <- vector("list", length(unique(view_index)))
  Z <- matrix(NA, nrow=nrow(x), ncol=length(unique(view_index)))
  
  for(i in unique(view_index[,1])){
    if(anyNA(x[, view_index[,1]==i])){
      x_omit <- na.omit(x[, view_index[,1]==i])
      incomplete_cases <- as.numeric(attr(x_omit, "na.action"))
      complete_cases <- setdiff(1:nrow(x), incomplete_cases)
      
      base_fits[[i]] <- StaPLR(x_omit, y[complete_cases], rep(1, ncol(x_omit)))
      Z[complete_cases, i] <- base_fits[[i]]$CVs
    }
    else{
      base_fits[[i]] <- StaPLR(x[, view_index[,1]==i], y, rep(1, ncol(x[, view_index[,1]==i])))
      Z[, i] <- base_fits[[i]]$CVs
    }
  }
  out <- list(base_fits=base_fits, Z=Z)
  return(out)
}

staplr_meta_mean <- function(id, view_index){
  # Applies StaPLR with unconditional mean imputation at the meta level
  passed_fits <- staplr_pass_thru(id$xtrain, id$ytrain, as.matrix(view_index))
  Z_imputed <- impute_mean(passed_fits$Z)
  glmnet.control(fdev=0)
  meta_fit <- cv.glmnet(Z_imputed, id$ytrain, family="binomial", alpha=1, standardize=FALSE, lower.limits=0, lambda.min.ratio=1e-04)
  
  base <- list()
  for(i in 1:length(passed_fits$base_fits)){
    base[[i]] <- passed_fits$base_fits[[i]]$base[[1]]
  }
  
  pseudo_staplr_obj <- list(base=base, meta=meta_fit, CVs=Z_imputed, view=view_index, metadat="response")
  class(pseudo_staplr_obj) <- "StaPLR"
  return(pseudo_staplr_obj)
}

# meta_mean_fit <- staplr_meta_mean(incomplete_data, view_index)

staplr_meta_forest <- function(id, view_index, ntree){
  # Applies StaPLR with missForest imputation at the meta level
  passed_fits <- staplr_pass_thru(id$xtrain, id$ytrain, as.matrix(view_index))
  
  Z_df <- data.frame(passed_fits$Z)
  Z_df$y <- factor(id$ytrain)
  Z_imputed <- missForest(Z_df, ntree=ntree, verbose=TRUE)$ximp
  Z_imputed <- data.matrix(Z_imputed)
  Z_imputed <- Z_imputed[, - ncol(Z_imputed)]
  glmnet.control(fdev=0)
  meta_fit <- cv.glmnet(Z_imputed, id$ytrain, family="binomial", alpha=1, standardize=FALSE, lower.limits=0, lambda.min.ratio=1e-04)
  
  base <- list()
  for(i in 1:length(passed_fits$base_fits)){
    base[[i]] <- passed_fits$base_fits[[i]]$base[[1]]
  }
  
  pseudo_staplr_obj <- list(base=base, meta=meta_fit, CVs=Z_imputed, view=view_index, metadat="response")
  class(pseudo_staplr_obj) <- "StaPLR"
  return(pseudo_staplr_obj)
}

# meta_forest_fit <- staplr_meta_forest(incomplete_data, view_index, ntree=100)

staplr_meta_pmm <- function(id, view_index, m){
  # Applies StaPLR with predictive mean matching at the meta level
  passed_fits <- staplr_pass_thru(id$xtrain, id$ytrain, as.matrix(view_index))
  
  zy <- cbind(passed_fits$Z, id$ytrain)
  mice_obj <- mice(zy, m=m, method="pmm")
  Z_imputed <- complete(mice_obj, action="all")
  if(m > 1){
    Z_array <- array(unlist(Z_imputed), dim=c(nrow(zy), ncol(zy), m))
    Z_mean <- apply(Z_array, c(1,2), mean)
    Z_imputed <- Z_mean[, - ncol(Z_mean)]
  } 
  else{
    Z_mean <- complete(mice_obj)
    Z_imputed <- Z_mean[, - ncol(Z_mean)]
  }
  names(Z_imputed) <- NULL
  Z_imputed <- data.matrix(Z_imputed)
  glmnet.control(fdev=0)
  meta_fit <- cv.glmnet(Z_imputed, id$ytrain, family="binomial", alpha=1, standardize=FALSE, lower.limits=0, lambda.min.ratio=1e-04)
  
  base <- list()
  for(i in 1:length(passed_fits$base_fits)){
    base[[i]] <- passed_fits$base_fits[[i]]$base[[1]]
  }
  
  pseudo_staplr_obj <- list(base=base, meta=meta_fit, CVs=Z_imputed, view=view_index, metadat="response")
  class(pseudo_staplr_obj) <- "StaPLR"
  return(pseudo_staplr_obj)
}

# meta_pmm_fit <- staplr_meta_pmm(incomplete_data, view_index, m=1)

staplr_meta_cv <- function(id, view_index, m){
  # Applies StaPLR with predictive mean matching at the meta level, using m cross-validations
  Z_array <- array(NA, dim=c(nrow(id$xtrain), length(unique(view_index)), m))
  
  for(i in 1:m){
    passed_fits <- staplr_pass_thru(id$xtrain, id$ytrain, as.matrix(view_index))
    if(i==1){
      singular_fit <- passed_fits
    }
    zy <- cbind(passed_fits$Z, id$ytrain)
    mice_obj <- mice(zy, m=1, method="pmm")
    Z_imputed <- complete(mice_obj)
    Z_array[,,i] <- as.matrix(Z_imputed[, -ncol(Z_imputed)])
  }
  
  Z_mean <- apply(Z_array, c(1,2), mean)
  names(Z_mean) <- NULL
  Z_imputed <- data.matrix(Z_mean)
  
  glmnet.control(fdev=0)
  meta_fit <- cv.glmnet(Z_imputed, id$ytrain, family="binomial", alpha=1, standardize=FALSE, lower.limits=0, lambda.min.ratio=1e-04)
  
  base <- list()
  for(i in 1:length(singular_fit$base_fits)){
    base[[i]] <- singular_fit$base_fits[[i]]$base[[1]]
  }
  
  pseudo_staplr_obj <- list(base=base, meta=meta_fit, CVs=Z_imputed, view=view_index, metadat="response")
  class(pseudo_staplr_obj) <- "StaPLR"
  return(pseudo_staplr_obj)
}

# meta_cv_fit <- staplr_meta_cv(incomplete_data, view_index, m=2)
