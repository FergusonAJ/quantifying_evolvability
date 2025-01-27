#!/bin/bash

# Extract the experiment name embedded in the passed string
# We expect the name to match the YYYY_MM_DD_ID__... format
function get_exp_name {
  if [ ! $# -eq 1 ]
  then 
    echo "Error! Function get_exp_name_from_path expects one argument:"
    echo "  1. The string to parse"
    return 1
  fi
  # Experiment name -> name of current directory
  echo "$1" | grep -oPe "\d\d\d\d_\d\d_\d\d_\d\d__[a-zA-z0-9-_]+"
}

# Extract the experiment name embedded in the current path
function get_cur_exp_name {
  get_exp_name $(pwd)
}

# Get the path to an experiment, relative to the root of the repo
# i.e., it should follow the form of experiments/.../YYYY_MM_DD_ID_...
function get_relative_exp_path {
  if [ ! $# -eq 1 ]
  then 
    echo "Error! Function get_exp_name_from_path expects one argument:"
    echo "  1. The path to parse"
    return 1
  fi
  echo "$1" | grep -oPe "experiments/\S*\d\d\d\d_\d\d_\d\d_\d\d__[a-zA-z0-9-_]+"
}

# Get the relative path (see get_relative_exp_path) based on the current working directory
function get_cur_relative_exp_path {
  get_relative_exp_path $( pwd )
}

# Escape the slashes in a path
function escape_slashes {
  if [ ! $# -eq 1 ]
  then 
    echo "Error! Function escape_slashes expects one argument:"
    echo "  1. The string to escape"
    return 1
  fi
  echo "$1" | sed -e "s/\//\\\\\//g"
}

# Get a timestamp using a set format
function get_timestamp {
  date +%m_%d_%y__%H_%M_%S
}

# Convert a YYYY_MM_DD_ID__... experiment name into a numerical seed
function exp_name_to_seed {
  if [ ! $# -eq 1 ]
  then 
    echo "Error! Function exp_name_to_seed expects one argument:"
    echo "  1. The experiment name to parse"
    return 1
  fi
  local YEAR=$( echo "$1" | grep -oP "^\d\d\d\d" )
  local YEAR_SHORT=$(echo ${YEAR} | grep -oP "\d\d$")
  local MONTH=$( echo "$1" | grep -oP "^\d+_\d+" | grep -oP "\d+$" )
  local DAY=$( echo "$1" | grep -oP "^\d+_\d+_\d+" | grep -oP "\d+$" )
  local EXP_ID=$( echo "$1" | grep -oP "^\d+_\d+_\d+_\d+" | grep -oP "\d+$" )
  # The base seed (modified for individal replicates)
  # Format:  YYMMDDID000000
  # Example: 23011301000000
  echo "${YEAR_SHORT}${MONTH}${DAY}${EXP_ID}000000"
}
