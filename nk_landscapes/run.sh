#! /bin/bash

idx=0
if (($# > 0))
then
  idx=$1
fi

filename_arr=()
filename_arr+=(cpp_data/n_5__k_2__custom/landscape_data.csv)
filename_arr+=(cpp_data/n_5__k_1__seed_101/landscape_data.csv)
filename_arr+=(cpp_data/n_10__k_3__seed_100/landscape_data.csv)
filename_arr+=(cpp_data/n_6__k_2__seed_102/landscape_data.csv)
filename_arr+=(cpp_data/n_7__k_2__seed_7200/landscape_data.csv)
filename_arr+=(cpp_data/n_3__k_1__custom/landscape_data.csv)
filename_arr+=(cpp_data/n_5__k_2__custom_2/landscape_data.csv)
filename_arr+=(cpp_data/n_3__k_2__custom/landscape_data.csv)

if (($idx < ${#filename_arr[@]}))
then
  filename=${filename_arr[$idx]}
else
  echo "Invalid index: $idx"
  echo "Index must be between 0 and $(( ${#filename_arr[@]} - 1))"
  echo "Exiting"
  exit 1
fi
  
echo "Running with index ${idx}: ${filename}"
#grep -v "#" ${filename} | python3 landscape_viz.py
python3 landscape_viz.py ${filename}
