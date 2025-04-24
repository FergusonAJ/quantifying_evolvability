rm(list = ls())

library(ggplot2)
library(cowplot)

plot_dir = '../plots'
if(!dir.exists(plot_dir)){
  dir.create(plot_dir, recursive = T)
}

df_pairwise = read.csv('../data/pairwise_data.csv')

df_trimmed = df_pairwise[df_pairwise$starting_fitness_a != 0 & df_pairwise$starting_fitness_b != 0,]

ggplot(df_pairwise, aes(x = fitness_diff, y = adj_p)) + 
  scale_y_log10() +
  geom_point(alpha = 0.1)

ggplot(df_trimmed, aes(x = fitness_diff, y = adj_p)) + 
  scale_y_log10() + 
  geom_point(alpha = 0.5)

x_map = c(
  '0' = 0,
  '32' = 1,
  '48' = 2,
  '56' = 3,
  '60' = 4,
  '62' = 5,
  '63' =6
)

df_trimmed$genotype_a_x = 0
df_trimmed$genotype_b_x = 0
for(row_idx in 1:nrow(df_trimmed)){
  df_trimmed[row_idx,]$genotype_a_x = x_map[as.character(df_trimmed[row_idx,]$genotype_a)][[1]]
  df_trimmed[row_idx,]$genotype_b_x = x_map[as.character(df_trimmed[row_idx,]$genotype_b)][[1]]
}

ggplot(df_trimmed, aes(x = genotype_a_x, y = starting_fitness_a)) + 
  geom_segment(aes(xend = genotype_b_x, yend = starting_fitness_b)) + 
  geom_point()

ggplot(df_trimmed, aes(x = genotype_a_x, y = avg_fitness_a)) + 
  geom_segment(aes(xend = genotype_b_x, yend = avg_fitness_b)) + 
  geom_point(aes(y = avg_fitness_a))


fitness_baseline = 10
df_trimmed$starting_fitness_a_norm = df_trimmed$starting_fitness_a / fitness_baseline
df_trimmed$starting_fitness_b_norm = df_trimmed$starting_fitness_b / fitness_baseline
df_trimmed$avg_fitness_a_norm = df_trimmed$avg_fitness_a / fitness_baseline
df_trimmed$avg_fitness_b_norm = df_trimmed$avg_fitness_b / fitness_baseline
df_trimmed$sd_fitness_a_norm = df_trimmed$fitness_sd_a / fitness_baseline
df_trimmed$sd_fitness_b_norm = df_trimmed$fitness_sd_b / fitness_baseline

ggplot(df_trimmed) + 
  geom_segment(aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm)) + 
  geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm))  +
  geom_segment(data=df_trimmed[df_trimmed$genotype_a_x < df_trimmed$genotype_b_x,], aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm), color = 'red', linetype='dashed') + 
  geom_point(aes(x = genotype_a_x, y = avg_fitness_a_norm), color = 'red') + 
  xlab('Genotype') + 
  ylab('Fitness')


df_trimmed$is_signif = df_trimmed$adj_p < 0.05
if(sum(df_trimmed$is_signif) > 0){
  df_trimmed$signif_marker = ''
  df_trimmed[df_trimmed$adj_p < 0.05,]$signif_marker = '*'
  df_trimmed[df_trimmed$adj_p < 0.01,]$signif_marker = '**'
  df_trimmed[df_trimmed$adj_p < 0.001,]$signif_marker = '***'
  df_trimmed$signif_text = paste0('p=', round(df_trimmed$adj_p, 3))
  df_trimmed[df_trimmed$adj_p < 0.001,]$signif_text = 'p < 0.001'
  
  df_trimmed$text_x = (df_trimmed$genotype_a_x + df_trimmed$genotype_b_x) / 2
  
  ggplot(df_trimmed) + 
    geom_segment(aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm)) + 
    geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm))  +
    geom_segment(data=df_trimmed[df_trimmed$genotype_a_x < df_trimmed$genotype_b_x,], aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm), color = 'red', linetype='dashed') + 
    geom_point(aes(x = genotype_a_x, y = avg_fitness_a_norm), color = 'red') + 
    geom_segment(data=df_trimmed[df_trimmed$is_signif,], aes(x = genotype_b_x + 0.1, xend = genotype_a_x - 0.1, y = 0.95, yend = 0.95), 
                color = 'red',
                arrow=arrow(type = 'closed', length = unit(0.35, 'cm'))) + 
    geom_text(data = df_trimmed[df_trimmed$is_signif,], aes(x = text_x, y = 0.9, label = signif_marker)) + 
    geom_text(data = df_trimmed[df_trimmed$is_signif,], aes(x = text_x, y = 0.85, label = signif_text)) + 
    xlab('Genotype') + 
    ylab('Fitness') + 
    scale_y_continuous(limits = c(0.85, 2.05), breaks = c(1, 1.25, 1.5, 1.75, 2))
  ggsave(paste0(plot_dir, '/summary_plot_original.pdf'), units = 'in', width = 6.5, height = 4.5)
  ggsave(paste0(plot_dir, '/summary_plot_original.png'), units = 'in', width = 6.5, height = 4.5)


  theme_set(theme_cowplot())
  
  ggplot(df_trimmed) + 
    geom_segment(aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness')) + 
    geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'))  +
    geom_segment(data=df_trimmed[df_trimmed$genotype_a_x < df_trimmed$genotype_b_x,], 
                 aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = 'Average evolved fitness (N=100)'), linetype='dashed') + 
    #geom_errorbar(aes(x = genotype_a_x, ymin = avg_fitness_a_norm - sd_fitness_a_norm, ymax = avg_fitness_a_norm + sd_fitness_a_norm, color = 'Average evolved fitness')) + 
    geom_point(aes(x = genotype_a_x, y = avg_fitness_a_norm, color = 'Average evolved fitness (N=100)')) + 
    geom_segment(data=df_trimmed[df_trimmed$is_signif,], aes(x = genotype_b_x + 0.1, xend = genotype_a_x - 0.1, y = 0.675, yend = 0.675), 
                color = 'red',
                arrow=arrow(type = 'closed', length = unit(0.35, 'cm'))) + 
    geom_text(data = df_trimmed[df_trimmed$is_signif,], aes(x = text_x, y = 0.6, label = signif_marker)) + 
    geom_text(data = df_trimmed[df_trimmed$is_signif,], aes(x = text_x, y = 0.55, label = signif_text)) + 
    xlab('Genotype') + 
    ylab('Fitness') + 
    labs(color = '') +
    scale_color_manual(values = c('Starting fitness' = '#000000', 'Average evolved fitness (N=100)' = '#ff0000')) +
    scale_y_continuous(limits = c(0.5, 2.05), breaks = c(0.75, 1, 1.25, 1.5, 1.75, 2)) + 
    scale_x_continuous(limits = c(0, 6), breaks = -1:6, minor_breaks = -1:6) +
    theme(legend.position = 'bottom') + 
    theme(axis.text.x = element_blank()) +
    theme(panel.grid = element_line(color = '#dddddd'))
  ggsave(paste0(plot_dir, '/summary_plot.pdf'), units = 'in', width = 6.5, height = 4.5)
  ggsave(paste0(plot_dir, '/summary_plot.png'), units = 'in', width = 6.5, height = 4.5)

} else {
  ggplot(df_trimmed) + 
    geom_segment(aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm)) + 
    geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm))  +
    geom_segment(data=df_trimmed[df_trimmed$genotype_a_x < df_trimmed$genotype_b_x,], aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm), color = 'red', linetype='dashed') + 
    geom_point(aes(x = genotype_a_x, y = avg_fitness_a_norm), color = 'red') + 
    xlab('Genotype') + 
    ylab('Fitness') + 
    scale_y_continuous(limits = c(0.85, 2.05), breaks = c(1, 1.25, 1.5, 1.75, 2))
  ggsave(paste0(plot_dir, '/summary_plot_original.pdf'), units = 'in', width = 6.5, height = 4.5)
  ggsave(paste0(plot_dir, '/summary_plot_original.png'), units = 'in', width = 6.5, height = 4.5)


  theme_set(theme_cowplot())
  
  ggplot(df_trimmed) + 
    geom_segment(aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness')) + 
    geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'))  +
    geom_segment(data=df_trimmed[df_trimmed$genotype_a_x < df_trimmed$genotype_b_x,], 
                 aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = 'Average evolved fitness (N=100)'), linetype='dashed') + 
    #geom_errorbar(aes(x = genotype_a_x, ymin = avg_fitness_a_norm - sd_fitness_a_norm, ymax = avg_fitness_a_norm + sd_fitness_a_norm, color = 'Average evolved fitness')) + 
    geom_point(aes(x = genotype_a_x, y = avg_fitness_a_norm, color = 'Average evolved fitness (N=100)')) + 
    xlab('Genotype') + 
    ylab('Fitness') + 
    labs(color = '') +
    scale_color_manual(values = c('Starting fitness' = '#000000', 'Average evolved fitness (N=100)' = '#ff0000')) +
    scale_y_continuous(limits = c(0.9, 2.05), breaks = c(1, 1.25, 1.5, 1.75, 2)) + 
    scale_x_continuous(limits = c(0, 6), breaks = -1:6, minor_breaks = -1:6) +
    theme(legend.position = 'bottom') + 
    theme(axis.text.x = element_blank()) +
    theme(panel.grid = element_line(color = '#dddddd'))
  ggsave(paste0(plot_dir, '/summary_plot.pdf'), units = 'in', width = 6.5, height = 4.5)
  ggsave(paste0(plot_dir, '/summary_plot.png'), units = 'in', width = 6.5, height = 4.5)
  
}

