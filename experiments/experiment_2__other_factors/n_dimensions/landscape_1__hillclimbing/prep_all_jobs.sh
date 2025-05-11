#! /bin/bash

for dir_name in $(ls | grep 2025_)
do
    echo $dir_name
    cd $dir_name
    ./00_prepare_evolution_jobs.sb
    cd ..
done
