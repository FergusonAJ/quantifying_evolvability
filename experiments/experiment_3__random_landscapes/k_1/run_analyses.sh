#! /bin/bash

base_dir="2025_05_08_10__random_landscape"

for dir_name in $(ls | grep 2025_)
do
    echo $dir_name
    if ! [ ${dir_name} = "$base_dir" ]
    then
      cp ${base_dir}/analysis $dir_name -r
    fi
    exp_num=$(echo "$dir_name" | grep -oP "2025_\d\d_\d\d_\d\d" | grep -oP "\d\d$")
    echo "exp_num = ${exp_num}"
    if [ -z "${exp_num}" ]
    then
      echo "Skipping!"
      continue
    fi
    cd ${dir_name}/analysis
    Rscript 00_combine.R
    Rscript 01_analyze.R
    cd ../..
done
