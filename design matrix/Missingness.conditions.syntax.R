# Combinations of selected views with missingness + proportions of missingness

# All possible combinations when number of views = 4
missing_view <- list(1,
                     2,
                     3,
                     4,
                     c(1,2),
                     c(1,3),
                     c(1,4),
                     c(2,3),
                     c(2,4),
                     c(3,4),
                     c(1,2,3),
                     c(1,2,4),
                     c(2,3,4),
                     c(1,2,3,4))

# Proportions of missingness
missing_prop <-   list(   c(0.3),
                          c(0.7),
                          c(0.3, 0.3),
                          c(0.3, 0.7),
                          c(0.7, 0.3),
                          c(0.7, 0.7),
                          c( 0.3,  0.3,  0.3),
                          c( 0.3,  0.3,  0.7),
                          c( 0.3,  0.7,  0.3),
                          c( 0.3,  0.7,  0.7),
                          c( 0.7,  0.7,  0.3),
                          c( 0.7,  0.7,  0.7),
                          c( 0.3,  0.3,  0.3, 0.3),
                          c( 0.3,  0.3,  0.7, 0.3),
                          c( 0.3,  0.7,  0.3, 0.3),
                          c( 0.3,  0.7,  0.7, 0.3),
                          c( 0.7,  0.7,  0.3, 0.3),
                          c( 0.7,  0.7,  0.7, 0.3),
                          c( 0.3,  0.3,  0.3, 0.7),
                          c( 0.3,  0.3,  0.7, 0.7),
                          c( 0.3,  0.7,  0.3, 0.7),
                          c( 0.3,  0.7,  0.7, 0.7),
                          c( 0.7,  0.7,  0.3, 0.7),
                          c( 0.7,  0.7,  0.7, 0.7)
)

# All possible combinations of view selection and missing proportions under the condition n views = n missing prop.
# NOTE: The condition for all views containing missingness was is excluded, see line 53

miss.conditions <- rbind(
  expand.grid( missing_view [1:4],  missing_prop [1:2]),
  expand.grid( missing_view [5:10], missing_prop [3:6]),
  expand.grid( missing_view [11:13], missing_prop [7:12])
#  ,expand.grid( missing_view [14],  missing_prop [13:24])
)

# Change names of list objects
names(miss.conditions) <- c("missing_view","missing_prop")

# Save object
saveRDS(miss.conditions, "miss.conditions.rds")

