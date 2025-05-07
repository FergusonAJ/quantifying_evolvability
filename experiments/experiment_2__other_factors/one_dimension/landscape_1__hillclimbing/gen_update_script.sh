#!/bin/bash

ls | grep 2025_ | sed -E "s/(2025_05_04_)1([[:digit:]])(.+)/mv \11\2\3 \12\2\3/g" > update_exp_nums.sh
chmod u+x update_exp_nums.sh
