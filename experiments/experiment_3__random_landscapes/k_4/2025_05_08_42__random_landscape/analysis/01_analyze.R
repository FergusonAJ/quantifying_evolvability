rm(list = ls())

library(ggplot2)
library(dplyr)
library(cowplot)

plot_dir = '../plots'
if(!dir.exists(plot_dir)){
  dir.create(plot_dir, recursive = T)
}

df_pairwise = read.csv('../data/pairwise_data.csv')

df_pairwise$is_signif = df_pairwise$adj_p < 0.05
df_pairwise$signif_marker = ''
if(sum(df_pairwise$is_signif) > 0){
  df_pairwise[df_pairwise$adj_p < 0.05,]$signif_marker = '*'
  df_pairwise[df_pairwise$adj_p < 0.01,]$signif_marker = '**'
  df_pairwise[df_pairwise$adj_p < 0.001,]$signif_marker = '***'
  df_pairwise$signif_text = paste0('p=', round(df_pairwise$adj_p, 3))
  df_pairwise[df_pairwise$adj_p < 0.001,]$signif_text = 'p < 0.001'
}

ggplot(df_pairwise) + 
  geom_segment(data=df_pairwise[df_pairwise$is_signif,], aes(x = x_b, xend = x_a, y = y_b, yend = y_a, linetype = as.factor(signif_marker)), 
              color = 'red',
              arrow=arrow(type = 'closed', length = unit(0.25, 'cm'))) +
  geom_point(aes(x = x_a, y = y_a, size = starting_fitness_a, color = avg_fitness_a)) +
  scale_linetype_manual(values = c('*' = 'dotted', '**' = 'dashed', '***' = 'solid'))
ggsave(paste0(plot_dir, '/summary_plot.pdf'), units = 'in', width = 8, height = 6)


