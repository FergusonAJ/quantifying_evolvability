#!/bin/bash
IS_VERBOSE=0

# Grab global variables and helper functions
# Root directory -> The root level of the repo, should be directory just above 'experiments'
REPO_ROOT_DIR=$(pwd | grep -oP ".+(?=/experiments/)")
if [ ! ${IS_VERBOSE} -eq 0 ]
then
  echo "[VERBOSE] Found repo root dir: ${REPO_ROOT_DIR}"
  echo "[VERBOSE] Loading global config and helper functions..."
fi
. ${REPO_ROOT_DIR}/config_global.sh
. ${REPO_ROOT_DIR}/global_shared_files/helper_functions.sh

# Extract info about this experiment
EXP_NAME=$( get_cur_exp_name )
EXP_REL_PATH=$( get_cur_relative_exp_path )
EXP_ROOT_DIR=${REPO_ROOT_DIR}/${EXP_REL_PATH}
if [ ! ${IS_VERBOSE} -eq 0 ]
then
  echo "[VERBOSE] Experiment name: ${EXP_NAME}"
  echo "[VERBOSE] Experiment path (relative): ${EXP_REL_PATH}"
  echo "[VERBOSE] Experiment root dir (not relative): ${EXP_ROOT_DIR}"
  echo ""
fi

# Grab references to the various directories used in setup
MABE_DIR=${REPO_ROOT_DIR}/MABE2
#MABE_EXTRAS_DIR=${REPO_ROOT_DIR}/MABE2_extras
SCRATCH_EXP_DIR=${SCRATCH_ROOT_DIR}/${EXP_REL_PATH}
SCRATCH_REP_DIR=${SCRATCH_EXP_DIR}/reps
if [ ! ${IS_VERBOSE} -eq 0 ]
then
  echo ""
  echo "[VERBOSE] MABE dir: ${MABE_DIR}"
  echo "[VERBOSE] Global shared file dir: ${GLOBAL_FILE_DIR}"
  echo "[VERBOSE] Scratch directories:"
  echo "[VERBOSE]     Main exp dir: ${SCRATCH_EXP_DIR}"
  echo "[VERBOSE]     Scratch reps dir: ${SCRATCH_REP_DIR}"
fi

for dir_name in $( ls ${SCRATCH_REP_DIR} | sort)
do
    full_path=${SCRATCH_REP_DIR}/${dir_name}
    if ! [ -d $full_path ]
    then
        continue
    fi
    cp ${full_path}/generated_landscape_data.csv ..
    grep -v "#" ../generated_landscape_data.csv | python3 ${REPO_ROOT_DIR}/nk_landscapes/genotype_fitness_calc.py | tail -n +15 > ../genotype_fitnesses.csv
    break
done
