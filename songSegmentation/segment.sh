#!/bin/bash
# Usage bash: segment_jobscript.sh

JOB_SCRIPT="segment_jobscript.sh"

# where to save the ARRAY ARGS FILE (created for parallel submission)
SAVE_FOLDER="/tigress/MMURTHY/Kyle/code/dataProcessing/songSegmentation"
EXP_FOLDER=$1
readarray DAQ_PATHS < <(find $EXP_FOLDER -not -path '*/\.*' -name "daq.h5") # find all daq files in the folders

# echo "${DAQ_PATHS[@]}"

#creates an array file for the job script to use
ARRAY_ARGS_FILE="$SAVE_FOLDER/segment_array_args_IM.txt"
rm -f "$ARRAY_ARGS_FILE"

NUM_ARRAY_JOBS=0

for DAQ_PATH in "${DAQ_PATHS[@]}"; do

    # change to whatever file name you want segmentation saved as
	SAVE_PATH="$(dirname ${DAQ_PATH})/song_new.mat"

	if [ -f "$SAVE_PATH" ]; then # skip folders that have already been segmented
		echo "EXISTS: $SAVE_PATH"
		continue
	else
		echo "$DAQ_PATH"
		NUM_ARRAY_JOBS=$((NUM_ARRAY_JOBS + 1))
		string="$DAQ_PATH $SAVE_PATH"
		echo $string >> $ARRAY_ARGS_FILE
  
  fi

done

echo "Jobs: $NUM_ARRAY_JOBS"
sbatch -a 1-"$NUM_ARRAY_JOBS" "$JOB_SCRIPT" "$ARRAY_ARGS_FILE"
