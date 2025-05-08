#! /bin/bash

for dir_name in $(ls | grep 2025_)
do
    echo $dir_name
    cp landscape_data.csv ${dir_name}/shared_files
done
