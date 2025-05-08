#! /bin/bash

this_dir=$(pwd)
base_exp=$(ls | grep -P "\d{4}_\d{2}_\d{2}_\d0")
echo "Base exp: ${base_exp}"

# Prep all experiments (including base!)
for rep_id in $(seq 0 9)
do
    new_exp=$(echo "$base_exp" | sed -E "s/_([[:digit:]])0__/_\1${rep_id}__/g")
    echo "Scraping: ${new_exp}"
    cd ${new_exp}/data/scripts
    ./copy_landscape_data.sh  
    ./scrape_final_fitness_data.sh
    cd $this_dir
done
