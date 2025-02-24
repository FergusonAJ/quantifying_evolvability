#! /bin/bash

../../../MABE2/build/MABE -f ./NK.mabe > raw_result.txt
num_lines=$(cat raw_result.txt | wc -l)
tail -n $((num_lines - 4)) raw_result.txt > genotype_fitnesses.csv
rm raw_result.txt
