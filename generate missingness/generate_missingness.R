# Missingness function


# Function ####

# Define the indeces of predictors for each view
# view.pred = list( c(1:5), c(6:55), c(56:555), c(556:5555) )

generate_missingness = 
  
  function( data,
            n,
            prop_na,
            views,
            overlap = FALSE,
            view.pred  )
  {
    # ARGUMENTS
    
    # data : dataset
    # n : number of observations
    # prop_na : Proportion of missing values; Option are to enter one missingness proportion for all view, or a vector of missingness proportions with length = number of views
    # views : Views included
    # overlap : whether missing values between views can overlap. If TRUE, overlap of missing values is 50% between adjacent views.
    # view.predictors : list of indices of predictors for each view
    
    if (length(views) == 1) {
      
      # Sample indeces (sampling with replacement)
      ind = sample(n * prop_na , replace = TRUE)
      
      # Assign missing values to selected observations
      data[ind , view.pred[[views]]] <- NA
      
    }
    
    if (length(views) > 1) {
      
      if (overlap == TRUE) {
        
        # Create list object to collect indeces for each view
        list_indeces = list()
        
        # Create a pool to sample from
        pool = 1:n
        
        # Sample indeces (sampling without replacement)
        ind = sample(pool , n * prop_na[1])
        
        for (i in 1:length(views)) {
          
          if (i == 1) {
            
            # Indeces for first view is equal to indeces sampled beforehand
            ind_mult = ind
          }
          
          else {
            
            # number of indeces to sample
            n_indeces = n * prop_na[i]
            
            # Update pool
            pool = setdiff(pool, ind_mult)  # pool != ind_mult: longer object length is not a multiple of shorter
            
            # Use half of the sampled indeces from previous sample to introduce overlap
            
            # Condition 1 : Half of the indices to sample is smaller or equal in number to the indices from the previous round
            if (n_indeces / 2 <= length(ind_mult) ) { ind_overlap = sample(ind_mult, n_indeces / 2) }
            
            # Condition 2 : Half of the indices to sample is larger in number than the indices from the previous round
            if (n_indeces / 2 > length(ind_mult) ) { ind_overlap = sample(ind_mult, n_indeces / 2, replace = T) }
            
            # Combine overlapping indeces with newly sampled indeces. Two conditions can apply:
            
            # Condition 1: The remaining pool is larger than the number of indeces to sample
            if ( n_indeces / 2 <= length(pool) ) {  
              
              # Index 50% from overlap and 50% from remaining indeces
              ind_mult = c(ind_overlap , sample(pool, n_indeces / 2) ) }
            
            # Condition 2: The remaining pool is smaller than the number of indeces to sample
            if ( n_indeces / 2 > length(pool) ) {
              
              # Update pool to include all possible values that were not selected by the 50% overlap object 'ind_overlap'
              pool = (1:n)[-ind_overlap]
              
              # Index from combinded pool with overlap >= 50%
              ind_mult = c(ind_overlap , sample(pool, n_indeces / 2) ) }
            
            # Update pool
            pool = 1:n
            
          }
          
          #update list of indeces
          list_indeces[[i]] = ind_mult
          
        }
      }
      
      if (overlap == FALSE)  {
        
        # Create list object to collect indeces for each view
        list_indeces = list()
        
        # define pool of numbers to sample from
        pool = 1:n
        
        # Sample indeces (without replacement)
        ind = sample(pool , length(pool) * prop_na[1])
        
        for (i in 1:length(views)) {
          
          if (i == 1) {
            
            # Indeces for first view is equal to indeces sampled beforehand
            ind_mult = ind
          }
          
          else {
            # Update pool
            pool = pool[-ind_mult]
            
            # Sample from updated pool. Indices will not overlap
            ind_mult = sample(pool , length(pool) * prop_na[i])
          }
          
          # Update list
          list_indeces[[i]] = ind_mult
          
        }
      }
    }
    
    
    for (j in 1:length(views) ){
      
      # Assign missing values to selected observations for each view
      data[list_indeces[[j]] , view.pred[[j]]] <- NA
      
    }
    
    return(data)
  }
