#!/bin/bash

# This file contains variables that are shared across ALL experiments

# Grab the full path to the root directory of the repository 
REPO_ROOT_DIR=

# All files on the scratch will live in some subdirectory of this
SCRATCH_ROOT_DIR=

# Where is the user's global roll_q?
ROLL_Q_DIR=${SCRATCH_ROOT_DIR}/roll_q

# Where is the local copy of roll_q? (Likely a submodule in the repo)
BASE_ROLL_Q_DIR=${REPO_ROOT_DIR}/roll_q
