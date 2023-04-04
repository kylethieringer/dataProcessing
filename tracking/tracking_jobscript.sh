#!/bin/bash
#SBATCH --job-name=track
#SBATCH --time=10:00:00
#SBATCH --mem=64000
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --output='logs/track.%A.%a.log'
##SBATCH -N 1
##SBATCH --ntasks-per-socket=1
##SBATCH --ntasks-per-node=1

text_file="$1"
linenum=$SLURM_ARRAY_TASK_ID
linenum=$((linenum-1))

# will be saved to log files in /log
echo $linenum
OLDIFS=$IFS
IFS=$'\n'

array=( $(grep "[a-z]" $text_file) )
linetxt=${array["$linenum"]}

echo "$linetxt"

IFS=$OLDIFS
delim=' ' read -r -a linearray <<< "$linetxt"


# tigress modules
# module load anaconda
# module load cudatoolkit/10.2
# module load cudnn/cuda-10.2/7.6.5

# della modules
module load anaconda3/2021.11
module load cudatoolkit/11.4
module load cudnn/cuda-11.x/8.2.0

#make sure to setup a sleap environment on the cluster
conda activate sleap

MODEL_1="${linearray[0]}"
MODEL_2="${linearray[1]}"
save_path="${linearray[2]}"
video_path="${linearray[3]}"

# run inference on videos and then clean the tracks right afterwards. Make sure to specify how many tracks the cleaner should expect
sleap-track "$video_path" -m "$MODEL_1" -m "$MODEL_2" -o "$save_path" --tracking.tracker simple --tracking.similarity centroid --tracking.matching greedy --tracking.window 5 --tracking.target_instance_count 2 tracking.post_coonect_single_breaks 1 --tracking.clean_instance_count 2
