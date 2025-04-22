#! /bin/bash

python3 gen.py > genotype_fitness.csv
python3 ../../../../nk_landscapes/custom_landscape_generator.py genotype_fitness.csv landscape_data.csv
