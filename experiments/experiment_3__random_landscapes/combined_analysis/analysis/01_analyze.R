rm(list = ls())

library(ggplot2)
library(dplyr)
library(cowplot)
library(ggbeeswarm)

data_dir = '../data'
plot_dir = '../plots'
if(!dir.exists(plot_dir)) dir.create(plot_dir)

df_combined = read.csv(paste0(data_dir, '/combined_data.csv'))

df_combined$is_signif = df_combined$adj_p < 0.05
df_combined$fitness_effect = NA
# Calculate fitness effect
# This looks backward, because the stats are based on is A more evolvable than B, but fitness_diff is B - A
df_combined[df_combined$fitness_diff > 0,]$fitness_effect = 'deleterious'
df_combined[df_combined$fitness_diff < 0,]$fitness_effect = 'beneficial'

df_exp = df_combined %>% 
  dplyr::group_by(exp_num) %>%
  dplyr::summarize(
    num_signif = sum(is_signif), 
    count = dplyr::n(),
    #count = dplyr::n() / 2, # Divide by two because initial data includes BOTH directions of pairwise comparison 
    num_signif_deleterious = sum(is_signif & fitness_effect == 'deleterious'),
    num_signif_beneficial = sum(is_signif & fitness_effect == 'beneficial'), 
    k = dplyr::first(k)
    )

df_exp$frac_signif = df_exp$num_signif / df_exp$count
df_exp$frac_deleterious = df_exp$num_signif_deleterious / df_exp$num_signif
df_exp$frac_beneficial = df_exp$num_signif_beneficial / df_exp$num_signif

df_k = df_combined %>% 
  dplyr::group_by(k) %>%
  dplyr::summarize(
    num_signif = sum(is_signif), 
    count = dplyr::n(),
    #count = dplyr::n() / 2, # Divide by two because initial data includes BOTH directions of pairwise comparison 
    num_signif_deleterious = sum(is_signif & fitness_effect == 'deleterious'),
    num_signif_beneficial = sum(is_signif & fitness_effect == 'beneficial')
    )

df_k$frac_signif = df_k$num_signif / df_k$count
df_k$frac_deleterious = df_k$num_signif_deleterious / df_k$num_signif
df_k$frac_beneficial = df_k$num_signif_beneficial / df_k$num_signif

df_exp$x_signif = NA
df_exp$x_beneficial = NA
for(exp_num in unique(df_exp$exp_num)){
  mask = df_exp$exp_num == exp_num
  row = df_exp[mask,]
  signif_vals = sort(df_exp[df_exp$k == row$k,]$frac_signif)
  rep_idx = 1
  while(rep_idx < length(signif_vals) && row$frac_signif > signif_vals[rep_idx]){
    rep_idx = rep_idx + 1
  }
  offset = (rep_idx / 20) - 0.25
  df_exp[df_exp$exp_num == exp_num,]$x_signif = row$k + offset
  
  beneficial_vals = sort(df_exp[df_exp$k == row$k,]$frac_beneficial)
  rep_idx = 1
  while(!is.na(row$frac_beneficial) && rep_idx > length(beneficial_vals) && row$frac_beneficial < beneficial_vals[rep_idx]){
    rep_idx = rep_idx + 1
  }
  offset = (rep_idx / 20) - 0.25
  df_exp[df_exp$exp_num == exp_num,]$x_beneficial = row$k + offset
}

theme_set(theme_cowplot())

df_counts = dplyr::group_by(df_exp, k) %>% dplyr::summarize(count_with_ee_mutations = sum(frac_signif > 0), avg_ee_frac = mean(frac_signif))

ggp_ee = ggplot(df_k, aes(x = k, y = frac_signif)) + 
  geom_line() + 
  theme(axis.title = element_text(size = 18)) + 
  theme(axis.text = element_text(size = 16)) + 
  geom_beeswarm(data = df_exp, cex = 1.5) +
  scale_y_continuous(limits = c(NA,1), breaks = c(0, 0.25, 0.5, 0.75, 1), minor_breaks = c()) + 
  scale_x_continuous(breaks = 0:5, minor_breaks = c()) +
  theme(panel.grid = element_line(color = '#dddddd')) +
  xlab('\nLandscape ruggedness (K)') + 
  ylab('Fraction of mutations\nthat enhance evolvability')

ggp_beneficial = ggplot(df_k[!is.na(df_k$frac_beneficial),], aes(x = k, y = frac_beneficial)) + 
  geom_line() + 
  geom_text(data = df_counts, aes(x = k, y = -0.17, label = paste0('n=', count_with_ee_mutations)), size = 6) +
  geom_beeswarm(data = df_exp[!is.na(df_exp$frac_beneficial),], cex = 1.5) +
  scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1), minor_breaks = c()) + 
  scale_x_continuous(limits = c(0,5), breaks = 0:5, minor_breaks = c()) +
  theme(axis.title = element_text(size = 18)) + 
  theme(axis.text = element_text(size = 16)) + 
  coord_cartesian(ylim = c(0,1), clip="off") + 
  theme(panel.grid = element_line(color = '#dddddd')) +
  xlab('\nLandscape ruggedness (K)') + 
  ylab('Fraction of EE mutations\nthat are beneficial')

cowplot::plot_grid(ggp_ee, ggp_beneficial, nrow = 1, labels = 'AUTO', label_size = 18)
ggsave(paste0(plot_dir, '/mut_analysis.pdf'), units = 'in', width = 12, height = 4.5)
ggsave(paste0(plot_dir, '/mut_analysis.png'), units = 'in', width = 12, height = 4.5)

kruskal.test(frac_signif ~ k, data = df_exp)

kruskal.test(frac_beneficial ~ k, data = df_exp[!is.na(df_exp$frac_beneficial),])


