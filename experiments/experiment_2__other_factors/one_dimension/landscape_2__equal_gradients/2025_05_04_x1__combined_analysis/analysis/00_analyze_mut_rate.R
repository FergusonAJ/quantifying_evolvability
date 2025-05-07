rm(list = ls())
library(ggplot2)
library(cowplot)

plot_dir = '../plots'
if(!dir.exists(plot_dir)){
  dir.create(plot_dir)
}

df_base = read.csv('../../2025_05_04_10__base/data/pairwise_data.csv')
df_base$mut_prob = 0.001
df_base$pop_size = 1000
df_base$condition_num = 3

df_mut_low = read.csv('../../2025_05_04_11__mut_0_0005/data/pairwise_data.csv')
df_mut_low$mut_prob = 0.0005
df_mut_low$pop_size = 1000
df_mut_low$condition_num = 1

df_mut_very_low = read.csv('../../2025_05_04_12__mut_0_0001/data/pairwise_data.csv')
df_mut_very_low$mut_prob = 0.0001
df_mut_very_low$pop_size = 1000
df_mut_very_low$condition_num = 2

df_mut_high = read.csv('../../2025_05_04_13__mut_0_005/data/pairwise_data.csv')
df_mut_high$mut_prob = 0.005
df_mut_high$pop_size = 1000
df_mut_high$condition_num = 4

df_mut_very_high = read.csv('../../2025_05_04_14__mut_0_01/data/pairwise_data.csv')
df_mut_very_high$mut_prob = 0.01
df_mut_very_high$pop_size = 1000
df_mut_very_high$condition_num = 5

df_combined = rbind(df_base, df_mut_low, df_mut_very_low, df_mut_high, df_mut_very_high)
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
  '0.0001' = '#DDCC77',
  '0.0005' = '#CC6677',
  '0.001 (base)' = '#FF0000',
  '0.005' = '#882255',
  '0.01' = '#AA4499'
)

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
df_combined$text_x = (df_combined$genotype_a_x + df_combined$genotype_b_x) / 2 - 0.05
if(sum(df_combined$is_signif) > 0){
  df_combined[df_combined$adj_p < 0.05,]$signif_marker = '*'
  df_combined[df_combined$adj_p < 0.01,]$signif_marker = '**'
  df_combined[df_combined$adj_p < 0.001,]$signif_marker = '***'
  df_combined[df_combined$adj_p < 0.001,]$signif_text = 'p < 0.001'
}

df_combined$x_min = df_combined$genotype_b_x + 0.1
df_combined[df_combined$genotype_b_x > df_combined$genotype_a_x,]$x_min = df_combined[df_combined$genotype_b_x > df_combined$genotype_a_x,]$x_min - 0.2
df_combined$x_max = df_combined$genotype_a_x - 0.1
df_combined[df_combined$genotype_b_x > df_combined$genotype_a_x,]$x_max = df_combined[df_combined$genotype_b_x > df_combined$genotype_a_x,]$x_max + 0.2
 
theme_set(theme_cowplot())

df_combined$mut_str = df_combined$mut_prob
df_combined[df_combined$mut_prob == 0.0001,]$mut_str = '0.0001'
df_combined[df_combined$mut_prob == 0.0005,]$mut_str = '0.0005'
df_combined[df_combined$mut_prob == 0.001,]$mut_str = '0.001 (base)'
df_combined[df_combined$mut_prob == 0.005,]$mut_str = '0.005'
df_combined[df_combined$mut_prob == 0.01,]$mut_str = '0.01'
df_combined$mut_factor = factor(df_combined$mut_str, levels = c(
  'Starting fitness',
  '0.0001',
  '0.0005',
  '0.001 (base)',
  '0.005',
  '0.01'
))

ggplot(df_combined) + 
  geom_segment(data=df_combined[df_combined$pop_size == 1000 & df_combined$mut_prob == 0.001,], aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness'), size = 1.05) + 
  geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'), size = 2)  +
  geom_segment(data=df_combined[df_combined$genotype_a_x < df_combined$genotype_b_x,], 
               #aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = 'Average evolved fitness (N=100)'), linetype='dashed') + 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = mut_factor), size = 1.05
               ) + 
  #geom_errorbar(aes(x = genotype_a_x, ymin = avg_fitness_a_norm - sd_fitness_a_norm, ymax = avg_fitness_a_norm + sd_fitness_a_norm, color = 'Average evolved fitness')) + 
  #geom_point(aes(x = genotype_a_x, y = avg_fitness_a_norm, color = 'Average evolved fitness (N=100)')) + 
  geom_point(aes(x = genotype_a_x, y = avg_fitness_a_norm, color = mut_factor), size = 2) + 
  #annotate('rect', xmin = 0, xmax = 4, ymin = 0.66, ymax = 1, fill = '#ffffff') + 
  geom_segment(data=df_combined[df_combined$is_signif,], aes(x = x_min, xend = x_max, y = 1 - condition_num * 0.05, yend = 1 - condition_num * 0.05, color = mut_factor), 
              arrow=arrow(type = 'closed', length = unit(0.25, 'cm')), size = 1.15, show.legend = F) + 
  geom_text(data = df_combined[df_combined$is_signif,], aes(x = text_x, y = 0.96 - condition_num * 0.05, label = signif_marker, color = mut_factor), size = 6, show.legend = F) + 
  #geom_text(data = df_combined[df_combined$is_signif,], aes(x = text_x, y = 0.75, label = signif_text)) + 
  xlab('Genotype') + 
  ylab('Fitness') + 
  labs(color = '') +
  #scale_color_manual(values = c('Starting fitness' = '#000000', 'Average evolved fitness (N=100)' = '#ff0000')) +
  scale_color_manual(values = color_map) + 
  scale_y_continuous(limits = c(0.71, 1.8), breaks = c(1, 1.25, 1.5, 1.75), minor_breaks = c(1, 1.125, 1.25, 1.375, 1.5, 1.625, 1.75)) + 
  scale_x_continuous(limits = c(-3, 6), breaks = -4:6, minor_breaks = -1:6) +
  theme(legend.position = 'bottom') + 
  theme(axis.text.x = element_blank()) +
  theme(panel.grid = element_line(color = '#dddddd'))
ggsave(paste0(plot_dir, '/mut_prob_summary_plot.pdf'), units = 'in', width = 6.5, height = 4.5)
ggsave(paste0(plot_dir, '/mut_prob_summary_plot.png'), units = 'in', width = 6.5, height = 4.5)
