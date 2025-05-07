#! /bin/bash

for dir_name in $(ls | grep 2025_)
do
    echo $dir_name
    cd ${dir_name}/data/scripts
    ./copy_landscape_data.sh
    ./scrape_final_fitness_data.sh
    cd ../../..
done
