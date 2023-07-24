
#' Generate missingness function
#' 
#' @param   data  Dataset
#' @param   n  Number of observations
#' @param   views  Object that specifies for which views missing values are to be generated
#' @param   prop_na  Object with proportion(s) of missing values for each view included
#' @param   overlap  Whether missing values between views should overlap
#' @param   min.overlap  Minimum proportion of overlap between adjacent views if overlap == TRUE
#' @param   view.predictors  List of indices of predictors for each view


generate_missingness <- function(  data,
                                      n,
                                      views,
                                      prop_na,
                                      overlap = TRUE,
                                      min.overlap = 0.5,
                                      view.pred  ) {
# One view alone
    
  
if ( length( views ) == 1 ) {
  
    # Sample indeces (sampling with replacement)
    indices <- sample( n * prop_na )
    # Assign missing values to selected observations
    data[indices, view.pred[[views]]] <- NA  
  }

    
# Multiple views with overlap
    
    
if ( length( views ) > 1 & overlap == TRUE) {
  
  # Create list object to collect indices for each view
  list_indeces <- list()
  # Create a pool to sample from
  pool <- 1 : n
  # Sample indices (sampling without replacement)
  indices <- sample( pool, n * prop_na[1] )
  
  for ( i in seq_len( length( views ) ) ) {
      
     if ( i > 1 ) { 
       
       if( prop_na[i] >= prop_na[i - 1] ) {

          # Determine the number of observations to sample
          n_indices <- n * prop_na[i]
          # Sample overlap indices as half of the indices used in preceding view 
          overlap_indices <- sample(indices, length( indices ) * min.overlap )
          # Subtract the number of overlap indices
          n_indices <- n_indices - length( overlap_indices )
          
          # If n_indices is smaller than the pool without indices from preceding view:
          if ( n_indices <= length( setdiff( pool, indices ) ) ) {
          
            # Sample from the remaining pool
            remaining_indices <- sample( setdiff( pool, indices ), n_indices ) 
            # Combine sampled indices
            indices <- c( overlap_indices, remaining_indices )  
           
          # Else, sample additional indices used in preceding view, and then sample remaining indices
          } else {
            
            # Calculate absolute difference between n_indices and remaining pool
            diff <- abs( n_indices - length( setdiff( pool, indices ) ) )
            # Sample additional indices from indices of preceding view that were not sampled yet
            addit_overlap <- sample( setdiff(indices, overlap_indices ), diff )
            # Combine the samples
            indices <- c( setdiff( pool, indices ), overlap_indices, addit_overlap )
            }
          }
                    
        if ( prop_na[i] < prop_na[i - 1] ) {
        
          # number of needed indeces to sample
          n_indeces <- n * prop_na[i]
          # sample overlap indices as half of the indices used in preceding view 
          overlap_indices <- sample(indices, n_indeces * min.overlap )
          # substract the number of overlap indices
          n_indeces <- n_indeces - length( overlap_indices )
          # Sample from the remaining pool
          remaining_indices <- sample( pool[-indices], n_indeces ) 
          # Combine samples indices
          indices <- c( overlap_indices, remaining_indices ) 
          }
        }
        
      # Update list of indices
      list_indeces[[i]] <- indices
     }
     # Assign missing values to data based on generated indices
    
     for ( j in 1 : length( views ) ) {
      
      # Assign missing values to selected observations for each view
      data[list_indeces[[j]] , view.pred[[j]] ] <- NA
    }
   }
  
  
# Multiple views without overlap
    
  
if ( length( views ) > 1 & overlap == FALSE ) {
      
  # Create list object to collect indeces for each view
  list_indeces <- list( )
  # define pool of numbers to sample from
  pool <- 1 : n
  # Sample indeces (without replacement)
  indices <- sample( pool , length( pool ) * prop_na[1] )
  
  for ( i in 1 : length( views ) ) {

    if ( i > 1 ) {
      
      # Update pool
      pool <- pool[-indices]
      # Sample from updated pool. indices will not overlap
      indices <- sample( pool , length( pool ) * prop_na[i] )
     }
    
    # Update list
    list_indeces[[i]] <- indices
   }
  # Assign missing values to data based on generated indices
  
  for ( j in 1 : length( views ) ) {
    
    # Assign missing values to selected observations for each view
    data[list_indeces[[j]] , view.pred[[j]] ] <- NA
  }
 }
  
# Return data with generated missing values
return( data )
}
