#!/bin/bash

# Usage: bash export_jobscript.sh

JOB_SCRIPT="export_jobscript.sh"

SAVE_FOLDER="/dataProcessing/tracking"
mkdir -p "$SAVE_FOLDER"

# Paths to all video files (ignoring hidden dot files)
EXP_FOLDER=$1
readarray VIDEO_PATHS < <(find $EXP_FOLDER -not -path '*/\.*' -name "*.mp4")

echo "${VIDEO_PATHS[@]}"

ARRAY_ARGS_FILE="$SAVE_FOLDER/track_array_args.txt"
rm -f "$ARRAY_ARGS_FILE"

NUM_ARRAY_JOBS=0

#for VIDEO_PATH in $VIDEO_PATHS    # only for wildcards not list
for VIDEO_PATH in "${VIDEO_PATHS[@]}"
do
    SAVE_PATH="$(dirname $VIDEO_PATH)/$(basename $VIDEO_PATH).inference.cleaned.proofread.slp"
    TEST_PATH="$(dirname $VIDEO_PATH)/$(basename $VIDEO_PATH).inference.cleaned.proofread.tracking.h5"

    if [ -f "$TEST_PATH" ]; then
            echo "Exists: $TEST_PATH"
            continue
    fi

    NUM_ARRAY_JOBS=$[$NUM_ARRAY_JOBS +1]

    echo "$SAVE_PATH" "$VIDEO_PATH" >> $ARRAY_ARGS_FILE

done

echo "Jobs: $NUM_ARRAY_JOBS"
sbatch -a 1-"$NUM_ARRAY_JOBS" "$JOB_SCRIPT" "$ARRAY_ARGS_FILE"
