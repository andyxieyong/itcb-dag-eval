#!/bin/bash

# Task *SET* Parameters
# Count of task sets with "same" utilization
TCNT=100

# Total task set utilization
TASKSET_UTILS=(${TASKSET_UTILS[@]:-0.5 1 2 4 8 16 32})

# Architecture Parameters
CORES=(${CORES[@]:-4 8 12 16 20 24 32})


