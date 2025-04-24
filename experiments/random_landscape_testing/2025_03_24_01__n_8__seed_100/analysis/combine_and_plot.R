rm(list = ls())

library(dplyr)
library(ggplot2)

df_evo = read.csv('../data/combined_final_fitness_data.csv')
df_fitness = read.csv('../data/genotype_fitnesses.csv')

df_summary = 
  dplyr::group_by(df_evo, landscape_seed, starting_index) %>%
  dplyr::summarize(fitness_avg = mean(max_fitness), 
                   fitness_var = var(max_fitness), 
                   fitness_min = min(max_fitness), 
                   fitness_max = max(max_fitness))

df_summary$starting_fitness = NA
for(row_idx in 1:nrow(df_summary)){
  genotype = df_summary[row_idx,]$starting_index
  print(genotype)
  if(genotype > 255) next
  df_summary[row_idx,]$starting_fitness = df_fitness[df_fitness$genotype == genotype,]$fitness
}

ggplot(df_summary, aes(x = starting_fitness, y = fitness_avg)) + 
  geom_point()

ggplot(df_evo, aes(x = avg_fitness)) + 
  geom_density()
