rm(list = ls())
library(ggplot2)
library(cowplot)

plot_dir = '../plots'
if(!dir.exists(plot_dir)){
  dir.create(plot_dir)
}

df_mut = read.csv('../data/mut_rate_combined_data.csv')
df_mut$pop_size_str = '1000 (base)'
df_mut$pop_size_factor = NA
df_mut$is_mut_rate_exp = T
df_mut$is_pop_size_exp = F
df_pop = read.csv('../data/pop_size_combined_data.csv')
df_pop$mut_str = '0.001 (base)'
df_pop$mut_factor = NA
df_pop$is_mut_rate_exp = F
df_pop$is_pop_size_exp = T

df_combined = rbind(df_mut, df_pop[df_pop$pop_size != 1000,])
df_combined[df_combined$pop_size == 1000 & df_combined$mut_prob == 0.001,]$is_mut_rate_exp = T
df_combined[df_combined$pop_size == 1000 & df_combined$mut_prob == 0.001,]$is_pop_size_exp = T

df_combined[df_combined$mut_prob == 0.0001,]$mut_str = '0.01%'
df_combined[df_combined$mut_prob == 0.0005,]$mut_str = '0.05%'
df_combined[df_combined$mut_prob == 0.001,]$mut_str = '0.1% (base)'
df_combined[df_combined$mut_prob == 0.005,]$mut_str = '0.5%'
df_combined[df_combined$mut_prob == 0.01,]$mut_str = '1%'

df_combined$mut_factor = factor(df_combined$mut_str, levels = c(
  'Starting fitness',
  '0.01%',
  '0.05%',
  '0.1% (base)',
  '0.5%',
  '1%'
))

df_combined$pop_size_factor = factor(df_combined$pop_size_str, levels = c(
  'Starting fitness',
  '10',
  '100', 
  '1000 (base)',
  '10000'
))

mut_color_map = c(
  'Starting fitness' = '#000000',
  '0.01%' = '#E7D4E8',
  '0.05%' = '#C2A5CF',
  '0.1% (base)' = '#FF0000',
  '0.5%' = '#9970AB',
  '1%' = '#762A83'
)

pop_color_map = c(
  'Starting fitness' = '#000000',
  '10' = '#ACD39E',
  '100' = '#5AAE61', 
  '1000 (base)' = '#FF0000',
  '10000' = '#1B7837'
)

small_font_size = 16
large_font_size = 18
baseline_mask = df_combined$pop_size == 1000 & df_combined$mut_prob == 0.001
order_mask = df_combined$genotype_a_x < df_combined$genotype_b_x

theme_set(theme_cowplot())
mut_mask = df_combined$is_mut_rate_exp

# Just fitness
ggplot(df_combined[mut_mask,]) + 
  geom_segment(data=df_combined[mut_mask & baseline_mask & order_mask,], aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness'), linetype = 'dotted', size = 1.05) + 
  geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'), size = 2)  +
  xlab('Genotype') + 
  ylab('Fitness') + 
  labs(color = '') +
  scale_color_manual(values = mut_color_map) + 
  scale_y_continuous(limits = c(0.9, 1.8), breaks = c(1, 1.25, 1.5, 1.75), minor_breaks = c(1, 1.125, 1.25, 1.375, 1.5, 1.625, 1.75)) + 
  scale_x_continuous(limits = c(0, 6), breaks = -4:6, minor_breaks = 0:6) +
  theme(legend.position = 'bottom') + 
  theme(plot.margin = margin(25, 7, 7, 7, 'pt')) + 
  theme(axis.title = element_text(size = large_font_size)) +
  theme(axis.text = element_text(size = small_font_size)) +
  theme(legend.text = element_text(size = small_font_size)) +
  theme(axis.text.x = element_blank()) +
  guides(color=guide_legend(nrow = 2, byrow = T)) + 
  theme(panel.grid = element_line(color = '#dddddd'))
ggsave(paste0(plot_dir, '/mut_fitness_only_plot.pdf'), units = 'in', width = 8, height = 5)
ggsave(paste0(plot_dir, '/mut_fitness_only_plot.png'), units = 'in', width = 8, height = 5)

# Fitness + baseline
ggplot(df_combined[mut_mask,]) + 
  geom_segment(data=df_combined[mut_mask & baseline_mask & order_mask,], aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness'), linetype = 'dotted', size = 1.05) + 
  geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'), size = 2)  +
  geom_segment(data=df_combined[mut_mask & baseline_mask & order_mask,], 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = mut_factor), size = 1.05, linetype = 'dashed'
               ) + 
  geom_point(data=df_combined[mut_mask & baseline_mask,], aes(x = genotype_a_x, y = avg_fitness_a_norm, color = mut_factor), size = 2) + 
  geom_segment(data=df_combined[mut_mask & df_combined$is_signif & baseline_mask,], aes(x = x_min, xend = x_max, y = y, yend = y, color = mut_factor), 
              arrow=arrow(type = 'closed', length = unit(0.15, 'cm')), size = 1.15, show.legend = F) + 
  geom_text(data = df_combined[mut_mask & df_combined$is_signif & baseline_mask,], aes(x = text_x, y = text_y, label = signif_marker, color = mut_factor), size = 6, show.legend = F) + 
  xlab('Genotype') + 
  ylab('Fitness') + 
  labs(color = '') +
  scale_color_manual(values = mut_color_map) + 
  scale_y_continuous(limits = c(0.9, 1.8), breaks = c(1, 1.25, 1.5, 1.75), minor_breaks = c(1, 1.125, 1.25, 1.375, 1.5, 1.625, 1.75)) + 
  scale_x_continuous(limits = c(0, 6), breaks = -4:6, minor_breaks = 0:6) +
  theme(legend.position = 'bottom') + 
  theme(plot.margin = margin(25, 7, 7, 7, 'pt')) + 
  theme(axis.title = element_text(size = large_font_size)) +
  theme(axis.text = element_text(size = small_font_size)) +
  theme(legend.text = element_text(size = small_font_size)) +
  theme(axis.text.x = element_blank()) +
  guides(color=guide_legend(nrow = 2, byrow = T)) + 
  theme(panel.grid = element_line(color = '#dddddd'))
ggsave(paste0(plot_dir, '/mut_baseline_plot.pdf'), units = 'in', width = 8, height = 5)
ggsave(paste0(plot_dir, '/mut_baseline_plot.png'), units = 'in', width = 8, height = 5)

# Everything 
ggplot(df_combined[mut_mask,]) + 
  geom_segment(data=df_combined[mut_mask & baseline_mask & order_mask,], aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness'), linetype = 'dotted', size = 1.05) + 
  geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'), size = 2)  +
  geom_segment(data=df_combined[mut_mask & !baseline_mask & order_mask,], 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = mut_factor), size = 1.05
               ) + 
  geom_segment(data=df_combined[mut_mask & baseline_mask & order_mask,], 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = mut_factor), size = 1.05, linetype = 'dashed'
               ) + 
  geom_point(data=df_combined[mut_mask & !baseline_mask,], aes(x = genotype_a_x, y = avg_fitness_a_norm, color = mut_factor), size = 3) + 
  geom_point(data=df_combined[mut_mask & baseline_mask,], aes(x = genotype_a_x, y = avg_fitness_a_norm, color = mut_factor), size = 2) + 
  geom_segment(data=df_combined[mut_mask & df_combined$is_signif,], aes(x = x_min, xend = x_max, y = y, yend = y, color = mut_factor), 
              arrow=arrow(type = 'closed', length = unit(0.15, 'cm')), size = 1.15, show.legend = F) + 
  geom_text(data = df_combined[mut_mask & df_combined$is_signif,], aes(x = text_x, y = text_y, label = signif_marker, color = mut_factor), size = 6, show.legend = F) + 
  xlab('Genotype') + 
  ylab('Fitness') + 
  labs(color = '') +
  scale_color_manual(values = mut_color_map) + 
  scale_y_continuous(limits = c(0.9, 1.8), breaks = c(1, 1.25, 1.5, 1.75), minor_breaks = c(1, 1.125, 1.25, 1.375, 1.5, 1.625, 1.75)) + 
  scale_x_continuous(limits = c(0, 6), breaks = -4:6, minor_breaks = 0:6) +
  theme(legend.position = 'bottom') + 
  theme(plot.margin = margin(25, 7, 7, 7, 'pt')) + 
  theme(axis.title = element_text(size = large_font_size)) +
  theme(axis.text = element_text(size = small_font_size)) +
  theme(legend.text = element_text(size = small_font_size)) +
  theme(axis.text.x = element_blank()) +
  guides(color=guide_legend(nrow = 2, byrow = T)) + 
  theme(panel.grid = element_line(color = '#dddddd'))
ggsave(paste0(plot_dir, '/mut_full_plot.pdf'), units = 'in', width = 8, height = 5)
ggsave(paste0(plot_dir, '/mut_full_plot.png'), units = 'in', width = 8, height = 5)


mut_mask = df_combined$is_mut_rate_exp
ggp_mut = ggplot(df_combined[mut_mask,]) + 
  geom_segment(data=df_combined[mut_mask & baseline_mask & order_mask,], aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness'), linetype = 'dotted', size = 1.05) + 
  geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'), size = 2)  +
  geom_segment(data=df_combined[mut_mask & !baseline_mask & order_mask,], 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = mut_factor), size = 1.05
               ) + 
  geom_segment(data=df_combined[mut_mask & baseline_mask & order_mask,], 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = mut_factor), size = 1.05, linetype = 'dashed'
               ) + 
  geom_point(data=df_combined[mut_mask & !baseline_mask,], aes(x = genotype_a_x, y = avg_fitness_a_norm, color = mut_factor), size = 3) + 
  geom_point(data=df_combined[mut_mask & baseline_mask,], aes(x = genotype_a_x, y = avg_fitness_a_norm, color = mut_factor), size = 2) + 
  geom_segment(data=df_combined[mut_mask & df_combined$is_signif,], aes(x = x_min, xend = x_max, y = y, yend = y, color = mut_factor), 
              arrow=arrow(type = 'closed', length = unit(0.15, 'cm')), size = 1.15, show.legend = F) + 
  geom_text(data = df_combined[mut_mask & df_combined$is_signif,], aes(x = text_x, y = text_y, label = signif_marker, color = mut_factor), size = 6, show.legend = F) + 
  xlab('Genotype') + 
  ylab('Fitness') + 
  labs(color = '') +
  scale_color_manual(values = mut_color_map) + 
  scale_y_continuous(limits = c(0.9, 1.8), breaks = c(1, 1.25, 1.5, 1.75), minor_breaks = c(1, 1.125, 1.25, 1.375, 1.5, 1.625, 1.75)) + 
  scale_x_continuous(limits = c(0, 6), breaks = -4:6, minor_breaks = 0:6) +
  theme(legend.position = 'bottom') + 
  theme(plot.margin = margin(25, 7, 7, 7, 'pt')) + 
  theme(axis.title = element_text(size = large_font_size)) +
  theme(axis.text = element_text(size = small_font_size)) +
  theme(legend.text = element_text(size = small_font_size)) +
  theme(axis.text.x = element_blank()) +
  guides(color=guide_legend(nrow = 2, byrow = T)) + 
  theme(panel.grid = element_line(color = '#dddddd'))













pop_mask = df_combined$is_pop_size_exp
# Pop size - everything
ggplot(df_combined[pop_mask,]) + 
  geom_segment(data=df_combined[pop_mask & baseline_mask & order_mask,], aes(x = genotype_a_x, xend = genotype_b_x, y = starting_fitness_a_norm, yend = starting_fitness_b_norm, color = 'Starting fitness'), linetype = 'dotted', size = 1.05) + 
  geom_point(aes(x = genotype_a_x, y = starting_fitness_a_norm, color = 'Starting fitness'), size = 2)  +
  geom_segment(data=df_combined[pop_mask & !baseline_mask & order_mask,], 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = pop_size_factor), size = 1.05
               ) + 
  geom_segment(data=df_combined[pop_mask & baseline_mask & order_mask,], 
               aes(x = genotype_a_x, xend = genotype_b_x, y = avg_fitness_a_norm, yend = avg_fitness_b_norm, color = pop_size_factor), size = 1.05, linetype = 'dashed'
               ) + 
  geom_point(data=df_combined[pop_mask & !baseline_mask,],aes(x = genotype_a_x, y = avg_fitness_a_norm, color = pop_size_factor), size = 2) + 
  geom_point(data=df_combined[pop_mask & baseline_mask,], aes(x = genotype_a_x, y = avg_fitness_a_norm, color = pop_size_factor), size = 2) + 
  geom_segment(data=df_combined[pop_mask & df_combined$is_signif,], aes(x = x_min, xend = x_max, y = y, yend = y, color = pop_size_factor), 
              arrow=arrow(type = 'closed', length = unit(0.15, 'cm')), size = 1.15, show.legend = F) + 
  geom_text(data = df_combined[pop_mask & df_combined$is_signif,], aes(x = text_x, y = text_y, label = signif_marker, color = pop_size_factor), size = 6, show.legend = F) + 
  xlab('Genotype') + 
  ylab('Fitness') + 
  labs(color = '') +
  scale_color_manual(values = pop_color_map) + 
  scale_y_continuous(limits = c(0.9, 1.8), breaks = c(1, 1.25, 1.5, 1.75), minor_breaks = c(1, 1.125, 1.25, 1.375, 1.5, 1.625, 1.75)) + 
  scale_x_continuous(limits = c(0, 6), breaks = -4:6, minor_breaks = 0:6) +
  theme(legend.position = 'bottom') + 
  theme(axis.text.x = element_blank()) +
  guides(color=guide_legend(nrow = 2, byrow = T)) + 
  theme(plot.margin = margin(25, 7, 7, 7, 'pt')) + 
  theme(axis.title = element_text(size = large_font_size)) +
  theme(axis.text = element_text(size = small_font_size)) +
  theme(legend.text = element_text(size = small_font_size)) +
  theme(panel.grid = element_line(color = '#dddddd'))
ggsave(paste0(plot_dir, '/pop_full_plot.pdf'), units = 'in', width = 8, height = 5)
ggsave(paste0(plot_dir, '/pop_full_plot.png'), units = 'in', width = 8, height = 5)
