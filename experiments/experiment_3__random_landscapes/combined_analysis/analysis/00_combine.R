rm(list = ls())

data_dir = '../data'
if(!dir.exists(data_dir)) dir.create(data_dir)

df_combined = NA

for(exp_num in 0:59){
  k = floor(exp_num / 10)
  filename = paste0('../../k_', k, '/2025_05_08_', exp_num, '__random_landscape/data/pairwise_data.csv') 
  if(exp_num < 10){ # Add padding zero if needed
    filename = paste0('../../k_', k, '/2025_05_08_0', exp_num, '__random_landscape/data/pairwise_data.csv') 
  }
  df_exp = read.csv(filename)
  df_exp$k = k
  df_exp$exp_num = exp_num
  if(!is.data.frame(df_combined)){
    df_combined = df_exp
  } else{
    df_combined = rbind(df_combined, df_exp)
  }
}

if('X' %in% colnames(df_combined)){
  df_combined = df_combined[,setdiff(colnames(df_combined), 'X')]
}

write.csv(df_combined, paste0(data_dir, '/combined_data.csv'), row.names = F)