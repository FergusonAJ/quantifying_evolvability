#!/bin/bash

ls | grep 2025_ | sed -E "s/(2025_05_04_)2([[:digit:]])(.+)/mv \12\2\3 2025_05_07_0\2\3/g" > update_exp_nums.sh
chmod u+x update_exp_nums.sh
