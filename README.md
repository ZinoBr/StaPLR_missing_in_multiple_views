### Description
The repository comprises R syntax and shell scripts designed for a simulation study that evaluates the performance of Stacked Penalized Logistic Regression (StaPLR; Van Loon et al., 2020) in combination with meta-level imputation methods.

The study explores the performance of StaPLR under varying conditions of missingness, utilizing four different meta-level imputation methods, as well as Complete Case Analysis and Complete Data Analysis. The evaluation focuses on view selection performance and prediction accuracy.

The R syntax is written for use in a cluster computer system (SLURM HPC cluster).

Note that the majority of the R syntaxes have been adapted from the work of Wouter van Loon and are closely related to the studies conducted and reported in Van Loon et al. (2020 & 2022). For original R syntaxes and the 'multiview' package for utilizing StaPLR with multi-view structured data, please refer to the following repository:

https://gitlab.com/wsvanloon/multiview

### Instruction for Running the Simulation in R in a cluster computer environment

Two types of documents are provided: The first type are the R syntaxes (.R files), which provide the code for R to run the simulations and return the output in a file saved in the cluster computer environment used. The second type are shell scripts (.txt files) which are needed to assign the tasks of the R syntax to the available nodes of the cluster computer system. Running one of the shell scripts initializes the process of running the according R Syntax.

Note that the R syntaxes and shell scripts must be adjusted (see below) and the required R packages downloaded to the cluster computing environment before using them. The required adjustments include the following parts:

  - Source code for use of functions and other R objects (e.g., 'source("/ ... /MVS.R")') ->  Assign the correct folder and file name containing the needed function or object

  - File name for saving the results -> assign the correct repository

  - shell scripts -> Check if assigned memory is sufficient. If not, increase slightly and try again.
 
### Files
 
   Functions from the multiview package ( Copyright (C) 2018-2021  Wouter van Loon )

    # kFolds.R  -  Function to create folds
    
    # learn.R  -  Train a learner on multi-view input data
    
    # blockcorrelate.R  -  Generate features with a block-correlation structure

    # sim_normal_views_beta.R  -  Simulate multi-view structured data
    
    # StaPLR.R  -  StaPLR functions
    
    # MVS.R  -  MVS function wich appplies StaPLR for high-dimensional data with n dimensions > 2
    
    # imputation_methods.R  -  Imputation methods used in combination with StaPLR

  Function for inducing missingness in data

    # generate_missingness.R  -  Function to induce missingness in the views defined. For more details, inspect the function syntax.

  Design matrix used for performing the simulations
    
    # Design Matrix.R  -  syntax to create design matrix and save it as object 'miss.conditions'

    # miss.conditions.rds  -  Combinations of varying numbers of views with two values for missingness proportion for each view (0.3, 0.7)

  Helper function
    
    # transform.listobj.to.vector.R  -  transforms list entries of the design matrix to a vector

  Simulations using functions at the feature and meta level (modified from original syntaxes by Wouter van Loon)

    # CDA.R  -  Complete data analysis on a SLURM HPC cluster
    
    # CCA.R  -  Complete case analysis on a SLURM HPC cluster
    
    # forest.R  -  missForest (Random Forest algorithm) on a SLURM HPC cluster
    
    # mi.R  -  Mean imputation on a SLURM HPC cluster
    
    # meta_forest.R  -  meta-level missForest on a SLURM HPC cluster
    
    # meta_mean.R  -  meta-level mean imputation on a SLURM HPC cluster
    
    # meta_pmm.R  -  meta-level PMM on a SLURM HPC cluster (strategy 1)
    
    # meta_cv.R  -  meta-level PMM on a SLURM HPC cluster (strategy 2)

  Shell scripts

    # CDA.txt
    
    # CCA.txt
    
    # meta_forest.txt
    
    # meta_mean.txt
    
    # meta_pmm.txt
    
    # meta_cv.txt

### Required R packages

    * missForest
    
    * mice
    
    * foreach
    
    * multiview (  devtools::install_gitlab("wsvanloon/multiview") )

### References

Van Loon, W., Fokkema, M., Szabo, B., & de Rooij, M. (2020). Stacked penalized logistic regression for selecting views in multi-view learning. Information Fusion, 61, 113–123. https://doi.org/10.1016/j.inffus.2020.03.007

Van Loon, W., Fokkema, M., & de Rooij, M. (2022). Imputation of missing values in multi-view data. https:// doi.org/10.48550/ arxiv.2210.14484
