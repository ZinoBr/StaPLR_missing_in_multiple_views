
### Calculate measures of interest

# Set working directory
setwd('../CCA')

# Loading results from MI simulations

# Create an s x m data frame to save measures of interest for each conditions

# s = number of simulation sessions and 
s = 8000

#   m = number of measures of interest
m = 8

#   s x m data frame
measures = data.frame( matrix(  rep(0, times = s * m ), 
                                nrow = s,
                                ncol = m) )
#   Assign names to columns
colnames(measures) = c("TestAccuracy",
                       "MSEP",
                       "MPsV",
                       "TPR",
                       "FPR",
                       "FDR",
                       "logCompTime",
                       "n_completecases")

for (i in 1:s ) { 
  
  # Specify file
  file =  paste0( i, '.RData' )
  
  # Load file
  load(file)
  
  # If complete cases were 0 or too small to run StaPLR under CCA, 
  # assign NA to all outcome measures
  if (length(results) == 1) {
    
    measures$TestAccuracy[i] = NA
    measures$MSEP[i] = NA
    measures$MPsV[i] = NA
    measures$TPR[i] = NA
    measures$FPR[i] = NA
    measures$FDR[i] = NA
    measures$logCompTime[i] = NA
    measures$n_completecases[i] = results$CC
  
  }else{
  
  # Define coefficients of noise and signal views
  coefficients_noise_views = results$coefs[ c( results$noise_view) ]
  coefficients_signal_views = results$coefs[ - c( results$noise_view) ]
  
  ## Test accuracy 
  test.accuracy = mean( round(results$preds) == results$ytest )
  
  ## Mean squared error of probabilities (MSEP)
  msep = sum ( ( results$preds - results$ptest ) ^2 )  / 1000
  
  ## True positive rate (TPR) : 
  
  # number of signal views
  n_sv =  length( coefficients_signal_views )
  
  # number of selected signal views
  n_selected_sv = sum(coefficients_signal_views != 0)
  
  # If all coefficients of signal views were zero, then TPR = 0, otherwise 
  # it is the proportion of selected signal views in all signal views
  if ( n_selected_sv == 0 ) { tpr = 0 } else { tpr = n_selected_sv / n_sv}
  
  ## False positive rate (FPR) : 
  
  # number of noise views
  n_nv =  length( coefficients_noise_views )
  
  # number of selected noise views
  n_selected_nv = sum(coefficients_noise_views != 0)  
  
  # If all coefficients of noise views were zero, then FPR = 0, otherwise 
  # it is the proportion of selected noise views in all noise views
  if ( n_selected_nv == 0 ) { fpr = 0 } else { fpr = n_selected_nv / n_nv }
  
  ## False discovery rate (FDR) :   
  
  if ( fpr == 0 & tpr == 0) 
  { fdr = 0 } else 
  { fdr =  n_selected_nv / ( n_selected_nv + n_selected_sv ) }
  
  ##  Mean proportion of correctly selected views (MPsV)
  
  # number of views selected ( coefficients that are not zero)
  n_views_selected = sum( results$coefs != 0)
  
  # number of correctly selected views ( coefficients of the 'signal' views that are not zero )
  n_correctly_selected_views = sum( coefficients_signal_views != 0)
  
  # Calculate proportion of correctly selected views among the number of selected views
  
  if (n_views_selected == 0) { MPsV = 0 } 
  
  if (n_correctly_selected_views == 0) { MPsV = 0 } 
  
  if (n_views_selected != 0 & n_correctly_selected_views != 0)
  { MPsV = n_correctly_selected_views / n_views_selected }
  
  ## Computation time
  
  # Explanation of 'time' output: 
  
  # Using elapsed time as measurement of interest
  time = results$time[3]
  
  # Using the log of the time measurement
  log.time = log(time)
  
  # Save results
  measures$TestAccuracy[i] = test.accuracy
  measures$MSEP[i] = msep
  measures$MPsV[i] = MPsV
  measures$TPR[i] = tpr
  measures$FPR[i] = fpr
  measures$FDR[i] = fdr
  measures$logCompTime[i] = log.time
  measures$n_completecases[i] = results$CC
  }
  
}

saveRDS(measures,"/../CCA_outcome")
