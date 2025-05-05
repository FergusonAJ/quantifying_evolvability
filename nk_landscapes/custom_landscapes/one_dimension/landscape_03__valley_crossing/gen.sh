#! /bin/bash

python3 gen.py > genotype_fitness.csv
python3 ../../../custom_landscape_generator.py genotype_fitness.csv landscape_data.csv
