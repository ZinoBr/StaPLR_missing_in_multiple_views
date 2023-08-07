
# Test which files are missing

setwd('/Users/zinobrystowski/Desktop/Desktop/Leiden/Job LU/CICA/ALICE (CICA)/SLURM results/Designs_10replications/Design_5')

# 3420

existing = rep(NA, 4560)

for (i in 1:4560 ) { 
  
  # Specify file
  file =  paste0( 'CICA_results_', i, '.RData' )
  
  # Load file
  existing[i] <- file.exists(file)
}

which(existing == FALSE)
