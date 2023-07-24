# Function to transform list element to a vector when 'as.vector' does not work
transform.listobj.to.vector <-
  function( i ) {  as.vector(   t(  as.matrix(  as.data.frame( i )  )))  }