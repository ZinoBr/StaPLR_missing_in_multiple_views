learn <- function(X, y, views, type, generate.CVs=TRUE, ...){
  switch(type,
         StaPLR = StaPLR(X, y, view=views, skip.meta = TRUE, skip.cv = !generate.CVs, ...))
}