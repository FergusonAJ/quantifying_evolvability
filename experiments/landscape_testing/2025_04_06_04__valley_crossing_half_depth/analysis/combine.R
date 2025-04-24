rm(list = ls())

library(dplyr)
library(ggplot2)

processed_data_dir = '../data'
if(!dir.exists(processed_data_dir)){
  dir.create(processed_data_dir, recursive=T)
}

num_bits = 6

df_evo = read.csv('../data/combined_final_fitness_data.csv')
df_fitness = read.csv('../data/genotype_fitness.csv', header=F, col.names = 'fitness')
df_fitness$genotype = 0:(nrow(df_fitness)-1)

df_summary = 
  dplyr::group_by(df_evo, landscape_seed, starting_index) %>%
  dplyr::summarize(fitness_avg = mean(max_fitness), 
                   fitness_var = var(max_fitness), 
                   fitness_min = min(max_fitness), 
                   fitness_max = max(max_fitness),
                   count = dplyr::n())

df_summary$starting_fitness = NA
optima = unique(df_evo$max_fitness)
for(optima_idx in 1:length(optima)){
  col_name = paste0('frac_', optima_idx)
  cat('Creating column:', col_name, '\n')
  df_summary[,col_name] = NA
}
for(row_idx in 1:nrow(df_summary)){
  genotype = df_summary[row_idx,]$starting_index
  print(genotype)
  df_summary[row_idx,]$starting_fitness = df_fitness[df_fitness$genotype == genotype,]$fitness
  for(optima_idx in 1:length(optima)){
    col_name = paste0('frac_', optima_idx)
    cur_optimum = optima[optima_idx]
    df_summary[row_idx,col_name] = sum(df_evo[df_evo$starting_index == genotype,]$max_fitness == cur_optimum) / df_summary[row_idx,]$count
  }
}

summarized_filename = paste0(processed_data_dir, '/summarized_data.csv')
write.csv(df_summary, summarized_filename)
cat('Summarized data saved to:', summarized_filename, '\n')


df_pairwise = data.frame(data = matrix(nrow = 0, ncol = 10))
colnames(df_pairwise) = c('genotype_a', 'genotype_b', 'avg_fitness_a', 'avg_fitness_b', 'fitness_sd_a', 'fitness_sd_b', 'raw_p', 'adj_p', 'starting_fitness_a', 'starting_fitness_b')
for(genotype in unique(df_evo$starting_index)){
  genotype_mask = df_evo$starting_index == genotype
  genotype_max_fitness = df_evo[genotype_mask,]$max_fitness
  starting_fitness_a = df_fitness[df_fitness$genotype == genotype,]$fitness
  for(bit_idx in 1:num_bits){
    neighbor_genotype = bitwXor(genotype, bitwShiftL(1, bit_idx - 1))
    if(neighbor_genotype > 255) next
    starting_fitness_b = df_fitness[df_fitness$genotype == neighbor_genotype,]$fitness
    cat(bit_idx, bitwShiftL(1, bit_idx - 1), genotype, neighbor_genotype, '\n')
    neighbor_max_fitness = df_evo[df_evo$starting_index == neighbor_genotype,]$max_fitness
    if(length(genotype_max_fitness) != length(neighbor_max_fitness)) next
    res = wilcox.test(genotype_max_fitness, neighbor_max_fitness, alternative = 'greater')
    if(sum(genotype_max_fitness) == sum(neighbor_max_fitness)){
      df_pairwise[nrow(df_pairwise) + 1,] = 
        c(genotype, neighbor_genotype, mean(genotype_max_fitness), mean(neighbor_max_fitness), sd(genotype_max_fitness), sd(neighbor_max_fitness),
          1, NA, starting_fitness_a, starting_fitness_b)
    } else{
      df_pairwise[nrow(df_pairwise) + 1,] = 
        c(genotype, neighbor_genotype, mean(genotype_max_fitness), mean(neighbor_max_fitness), sd(genotype_max_fitness), sd(neighbor_max_fitness),
          res$p.value, NA, starting_fitness_a, starting_fitness_b)
    }
  }
  pairwise_mask = df_pairwise$genotype_a == genotype
  p_vals = df_pairwise[pairwise_mask,]$raw_p
  if(!NA %in% p_vals){
    df_pairwise[pairwise_mask,]$adj_p = p.adjust(p_vals, method='bonferroni')
  }
}

df_pairwise$fitness_diff = df_pairwise$starting_fitness_b - df_pairwise$starting_fitness_a

pairwise_filename = paste0(processed_data_dir, '/pairwise_data.csv')
write.csv(df_pairwise, pairwise_filename)
cat('Pairwise data saved to:', pairwise_filename, '\n')



