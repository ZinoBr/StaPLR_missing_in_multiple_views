
# Test which files are missing

setwd('/.../')

# 3420

existing = rep(NA, 4560)

for (i in 1:4560 ) { 
  
  # Specify file
  file =  paste0( i, '.RData' )
  
  # Load file
  existing[i] <- file.exists(file)
}

which(existing == FALSE)
