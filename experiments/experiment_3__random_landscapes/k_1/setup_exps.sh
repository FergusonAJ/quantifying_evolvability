#! /bin/bash

base_exp=$(ls | grep -P "\d{4}_\d{2}_\d{2}_\d0")
echo "Base exp: ${base_exp}"

# Copy base experiment
for rep_id in $(seq 1 9)
do
    new_exp=$(echo "$base_exp" | sed -E "s/_([[:digit:]])0__/_\1${rep_id}__/g")
    echo "New exp: ${new_exp}"
    cp ${base_exp} ${new_exp} -r
done

# Prep all experiments (including base!)
for rep_id in $(seq 0 9)
do
    new_exp=$(echo "$base_exp" | sed -E "s/_([[:digit:]])0__/_\1${rep_id}__/g")
    echo "Prepping: ${new_exp}"
    cd ${new_exp}
    ./00_prepare_evolution_jobs.sb
    cd ..
done
