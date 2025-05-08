#!/bin/bash

ls | grep 2025_ | sed -E "s/(2025_05_07_)0([[:digit:]])(.+)/mv \10\2\3 \11\2\3/g" > update_exp_nums.sh
chmod u+x update_exp_nums.sh
