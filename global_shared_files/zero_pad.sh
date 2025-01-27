#!/bin/bash

if [ ! $# -eq 2 ]
then
    echo "Error! Expected exactly two arguments:"
    echo "  1. The number to pad"
    echo "  2. The number of digits to pad to"
    exit 1
fi

printf "%0${2}d\n" ${1}
