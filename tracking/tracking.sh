#!/bin/bash
# Usage: bash tracking_jobscript.sh

# name of the jobscript
JOB_SCRIPT="tracking_jobscript.sh"

# Top-down
TOPDOWN=true

# path to sleap models (should be accessible to cluster)
# best practice would be to keep a copy of models within this directory rather than passing to other user's folders
CENTROIDS_MODEL="${2:-/dataProcessing/models/training_config.json}" # add models and change path/name to whichever the correct model is 
CONFMAPS_MODEL="${3:-/dataProcessing/models/training_config.json}" # add models and change path/name to whichever the correct model is

# path to save ARRAY_ARGS_FILE created below
# this is creating an array file to submit all tracking at once in parallel
SAVE_FOLDER="/dataProcessing/tracking"
mkdir -p "$SAVE_FOLDER"

# Paths to all video files (ignoring hidden dot files)
EXP_FOLDER=$1
readarray VIDEO_PATHS < <(find $EXP_FOLDER -not -path '*/\.*' -name "*.mp4")

echo "${VIDEO_PATHS[@]}"

# name of arguments file where video file paths and model paths are saved
ARRAY_ARGS_FILE="$SAVE_FOLDER/track_array_args.txt"
rm -f "$ARRAY_ARGS_FILE"

NUM_ARRAY_JOBS=0

# for VIDEO_PATH in "${VIDEO_PATHS[@]}";
for VIDEO_PATH in "${VIDEO_PATHS[@]}"; do   # only for wildcards not list

    SAVE_PATH="$(dirname $VIDEO_PATH)/$(basename $VIDEO_PATH).inference.slp"

    if [ -f "$SAVE_PATH" ]; then  # skip videos that have already been tracked
            echo "Exists: $SAVE_PATH"
            continue
    else
        NUM_ARRAY_JOBS=$((NUM_ARRAY_JOBS + 1))

      if $TOPDOWN; then
      	echo "$CENTROIDS_MODEL" "$CONFMAPS_MODEL" "$SAVE_PATH" "$VIDEO_PATH" >> $ARRAY_ARGS_FILE
      else
  	    echo "$CENTROIDS_MODEL" "$CONFMAPS_MODEL" "$PAFS_MODEL" "$SAVE_PATH" "$VIDEO_PATH" >> $ARRAY_ARGS_FILE
    fi

  fi

done

echo "Jobs: $NUM_ARRAY_JOBS"
sbatch -a 1-"$NUM_ARRAY_JOBS" "$JOB_SCRIPT" "$ARRAY_ARGS_FILE"