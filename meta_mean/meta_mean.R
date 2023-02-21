# Meta level mean imputation

source("/ ... /learn.R")
source("/ ... /kFolds.R")
source("/ ... /MVS.R")
source("/ ... /blockcorrelate.R")
source("/ ... /sim_normal_views_beta.R")
source("/ ... /generate_missingness.R")
source("/ ... /transform.listobj.to.vector.R")
source("/ ... /imputation_methods.R")


library(multiview)
library(mice)
library(foreach)

# Repetitions
reps <- 1:10

# Sample size of complete data
n <- 1000

# Which view is irrelevant?
noise_view <- c(4)

# Load missingness conditions (n = 80)
miss.conditions = readRDS("/ ... /miss.conditions.rds")

# Save indeces for missing conditions table into separate object
index.misscond = 1:dim(miss.conditions)[1]

# Create a data frame with 10 repetitions for each combination of missingness conditions (n = 800)
# NOTE: Noise view is constant at 4
conds <- expand.grid(reps, index.misscond, noise_view)
names(conds) <- c("reps", "index.misscond", "noise_view")

# Generate a vector of seeds
set.seed(410422)
seed_list <- sample(.Machine$integer.max/2, size = nrow(conds))

# Get the SLURM task ID
TID <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))

# Generate data
set.seed(seed_list[TID])

mv <- c(5,50,500,5000)
view_index <- rep(1:4, mv)
abs_beta_full <- rep(2/sqrt(mv), mv)

if(conds$noise_view[TID]==0){
  abs_beta <- abs_beta_full
}else if(conds$noise_view[TID]==1){
  abs_beta <- abs_beta_full
  abs_beta[1:5] <- 0
}else if(conds$noise_view[TID]==2){
  abs_beta <- abs_beta_full
  abs_beta[6:55] <- 0
}else if(conds$noise_view[TID]==3){
  abs_beta <- abs_beta_full
  abs_beta[56:555] <- 0
}else if(conds$noise_view[TID]==4){
  abs_beta <- abs_beta_full
  abs_beta[556:5555] <- 0
}

complete_data <- sim_normal_views_beta(v = 4, 
                                       m = mv, 
                                       s=c(1,1,1,1), 
                                       ntrain=n, 
                                       ntest=1000, 
                                       abs_beta=abs_beta, 
                                       rw=0.5, 
                                       rb=0.2)
# Generate missingness


# View(s) for which missingness is applied
missing_view <- transform.listobj.to.vector ( miss.conditions$missing_view[conds$index.misscond[TID]] )

# Missingness proportion for the selected view(s)
prop_na <- transform.listobj.to.vector ( miss.conditions$missing_prop[conds$index.misscond[TID]] )


# Generate list with predictor indeces for each view 

view.predictors = list( c(1:5), c(6:55), c(56:555), c(556:5555) )

# Use function to generate missingness in 'complete data'

incomplete_data = complete_data

incomplete_data$xtrain <- generate_missingness(data = complete_data$xtrain,
                                        n = n,
                                        prop_na = prop_na,
                                        views = missing_view,
                                        overlap = TRUE,
                                        view.pred = view.predictors )



# Train a model using missForest imputation at the base level
time <- system.time(meta_mean_fit <- staplr_meta_mean(incomplete_data, view_index))

# Save quantities required for calculating outcome metrics
results <- list()
results$TID <- TID
results$rep <- conds$rep[TID]
results$missing_prop <- miss.conditions$missing_prop[ conds$index.misscond[TID] ]
results$missing_view <- miss.conditions$missing_view[ conds$index.misscond[TID] ]
results$noise_view <- conds$noise_view[TID]
results$preds <- predict(meta_mean_fit, complete_data$xtest)
results$coefs <- coef(meta_mean_fit)$`Level 2`[[1]][-1]
results$ytest <- complete_data$ytest 
results$ptest <- complete_data$ptest
results$time <- time

save(results, file=paste0("/ ... /meta_mean/", TID, ".RData"))
warnings()


