# missingness_overlap_StaPLR

### Description
This repository contains R syntax and shell scripts for a simulation study comparing the performance of Stacked Penalized Logistic Regression (StaPLR; Wouter et al., 2020) combined with imputation methods in predicting a binary outcome in multi-view structured data when missing values occur in multiple views per row.

The imputation methods used are applied at the feature level (Random Forest & Mean Imputation) or at the meta level (Meta Mean Imputation, etc.) and compared in terms of prediction accuracy, computation time and view selection. Finally, the methods are compared with performance on complete case analysis and complete data analysis. The R syntax is written for use in a cluster computer system (SLURM HPC cluster).

Note that all R syntaxes are modified versions of syntaxes created by Wouter van Loon and relate to the studies conducted and reported in Van Loon et al. (2020 & 2022). The repository to some of the original R syntaxes and the 'multiview' package for using StaPLR with multi-view structured data can be found at: 
https://gitlab.com/wsvanloon/multiview

### Manual for Running the Simulation in R in a cluster computer environment

There are two types of documents. The first type are the R syntaxes (.R files), which provide the code for R to run the simulations and return the output in a file saved in the cluster computer environment used. The second type are shell scripts (.txt files) which are needed to assign the tasks of the R syntax to the available nodes of the cluster computer system. Running one of the shell scripts initializes the process of running the according R Syntax.

Note that before personal use of the R syntaxes and shell scripts, both must be adjusted and the required R packages downloaded to the cluster computing environment. The required modifications include the following parts:

  - Source code for use of functions and other R objects (e.g., 'source("/home/.../MVS.R")') ->  Assign the correct folder and file name containing the needed function or object

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

    # miss.conditions.rds  -  Combinations of varying numbers of views with two values for missingness proportion for each view (0.3, 0.7)

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
    
    # forest.txt
    
    # mi.txt
    
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
