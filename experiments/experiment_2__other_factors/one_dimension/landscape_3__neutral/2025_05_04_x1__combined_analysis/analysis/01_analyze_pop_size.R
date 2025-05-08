rm(list = ls())
library(ggplot2)
library(cowplot)

plot_dir = '../plots'
if(!dir.exists(plot_dir)){
  dir.create(plot_dir)
}

data_dir = '../data'
if(!dir.exists(data_dir)){
  dir.create(data_dir)
}

df_base = read.csv('../../2025_05_04_30__base/data/pairwise_data.csv')
df_base$mut_prob = 0.001
df_base$pop_size = 1000
df_base$condition_num = 3

df_10 = read.csv('../../2025_05_04_35__pop_10/data/pairwise_data.csv')
df_10$mut_prob = 0.001
df_10$pop_size = 10
df_10$condition_num = 1

df_100 = read.csv('../../2025_05_04_36__pop_100/data/pairwise_data.csv')
df_100$mut_prob = 0.001
df_100$pop_size = 100
df_100$condition_num = 2

df_10k = read.csv('../../2025_05_04_37__pop_10000/data/pairwise_data.csv')
df_10k$mut_prob = 0.001
df_10k$pop_size = 10000
df_10k$condition_num = 4

df_combined = rbind(df_base, df_10, df_100, df_10k)
df_combined = df_combined[df_combined$starting_fitness_a > 0 & df_combined$starting_fitness_b > 0,]

x_map = c(
  '7' = -3,
  '3' = -2,
  '1' = -1,
  '0' = 0,
  '32' = 1,
  '48' = 2,
  '56' = 3,
  '60' = 4,
  '62' = 5,
  '63' = 6
)

color_map = c(
  'Starting fitness' = '#000000',
  '10' = '#332288',
  '100' = '#88CCEE', 
  '1000 (base)' = '#FF0000',
  '10000' = '#117733'
)

df_combined$pop_size_str = df_combined$pop_size
df_combined[df_combined$pop_size == 1000,]$pop_size_str = '1000 (base)'
df_combined$pop_size_factor = factor(df_combined$pop_size_str, levels = c(
  'Starting fitness',
  '10',
  '100', 
  '1000 (base)',
  '10000'
))

df_combined$genotype_a_x = 0
df_combined$genotype_b_x = 0
for(row_idx in 1:nrow(df_combined)){
  df_combined[row_idx,]$genotype_a_x = x_map[as.character(df_combined[row_idx,]$genotype_a)][[1]]
  df_combined[row_idx,]$genotype_b_x = x_map[as.character(df_combined[row_idx,]$genotype_b)][[1]]
}

fitness_baseline = 1
df_combined$starting_fitness_a_norm = df_combined$starting_fitness_a / fitness_baseline
df_combined$starting_fitness_b_norm = df_combined$starting_fitness_b / fitness_baseline
df_combined$avg_fitness_a_norm = df_combined$avg_fitness_a / fitness_baseline
df_combined$avg_fitness_b_norm = df_combined$avg_fitness_b / fitness_baseline
df_combined$sd_fitness_a_norm = df_combined$fitness_sd_a / fitness_baseline
df_combined$sd_fitness_b_norm = df_combined$fitness_sd_b / fitness_baseline


df_combined$is_signif = df_combined$adj_p < 0.05
df_combined$signif_marker = ''
df_combined$signif_text = paste0('p=', round(df_combined$adj_p, 3))
df_combined$text_x = (df_combined$genotype_a_x + df_combined$genotype_b_x) / 2
if(sum(df_combined$is_signif) > 0){
  df_combined[df_combined$adj_p < 0.05,]$signif_marker = ' *'
  df_combined[df_combined$adj_p < 0.01,]$signif_marker = '**'
  df_combined[df_combined$adj_p < 0.001,]$signif_marker = '***'
  df_combined[df_combined$adj_p < 0.001,]$signif_text = 'p < 0.001'
}

df_combined$x_min = df_combined$genotype_b_x + 0.1
df_combined[df_combined$genotype_b_x > df_combined$genotype_a_x,]$x_min = df_combined[df_combined$genotype_b_x > df_combined$genotype_a_x,]$x_min - 0.2
df_combined$x_max = df_combined$genotype_a_x - 0.1
df_combined[df_combined$genotype_b_x > df_combined$genotype_a_x,]$x_max = df_combined[df_combined$genotype_b_x > df_combined$genotype_a_x,]$x_max + 0.2
df_combined$y =  1 - df_combined$condition_num * 0.05
df_combined$text_y = df_combined$y - 0.04
 

output_filename = paste0(data_dir, '/pop_size_combined_data.csv')
write.csv(df_combined, output_filename, row.names = F)
cat('Saving combined data to:', output_filename, '\n')

theme_set(theme_cowplot())

ggplot(df_combined) + 
  geom_segment(data=df_combined[df_combined$pop_size == 1000 & df_combined$mut_prob == 0.001,], aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness'), size = 1.1) + 
  geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'), size = 2)  +
  geom_segment(data=df_combined[df_combined$genotype_a_x < df_combined$genotype_b_x,], 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = pop_size_factor), linetype='solid', size = 1.1) + 
  geom_point(aes(x = genotype_a_x, y = avg_fitness_a_norm, color = pop_size_factor), size = 2) + 
  geom_segment(data=df_combined[df_combined$is_signif,], aes(x = x_min, xend = x_max, y = y, yend = y, color = pop_size_factor), 
              arrow=arrow(type = 'closed', length = unit(0.25, 'cm')), show.legend = F, size = 1.1) + 
  geom_text(data = df_combined[df_combined$is_signif,], aes(x = text_x - 0.05, y = text_y, label = signif_marker, color = pop_size_factor), show.legend = F, size = 6) + 
  xlab('Genotype') + 
  ylab('Fitness') + 
  labs(color = '') +
  scale_color_manual(values = color_map) + 
  scale_y_continuous(limits = c(0.72, 1.8), breaks = c(1, 1.25, 1.5, 1.75), minor_breaks = c(1, 1.125, 1.25, 1.375, 1.5, 1.625, 1.75)) + 
  scale_x_continuous(limits = c(-3, 6), breaks = -4:6, minor_breaks = -1:6) +
  theme(legend.position = 'bottom') + 
  theme(axis.text.x = element_blank()) +
  theme(panel.grid = element_line(color = '#dddddd'))
ggsave(paste0(plot_dir, '/pop_size_summary_plot.pdf'), units = 'in', width = 6.5, height = 4.5)
ggsave(paste0(plot_dir, '/pop_size_summary_plot.png'), units = 'in', width = 6.5, height = 4.5)

