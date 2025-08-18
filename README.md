# A computational baseline for changes in long-term evolvability (ALife 2025)

Generally, all files of interests can be found in the `experiments` directory. 
Within `experiments`, subdirectories allow for navigation to specific experiments (those outside experiments 1, 2, and 3 were exploratory). 
Experiments are then divided by either dimensionality (experiments 1 and 2) or ruggedness (experiment 3), and then into treatments.  

Individual treatment directories (a collection of evolutionary replicates) are typically broken down as follows: 
- `shared_files` - These contain MABE2 configuration scripts and a representation of the NK landscape, if hand-crafted. 
- `data` - Both raw and processed .csv files 
- `analysis` - R scripts for data analysis and plotting
- `plots` - Any and all plots generated as part of this work (some are left in a rough, working state). 

Most experiments have a "combined" subdirectory for analysis across treatments. 
These follow the same general layout as treatements (above), but will contain the final plots for the paper as well as cleaned data of multiple treatments. 
