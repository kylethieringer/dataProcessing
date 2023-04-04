#!/bin/bash
#SBATCH --time=01:59:00
#SBATCH --mem=64000
#SBATCH --cpus-per-task=8
#SBATCH --output='logs/h5.%A.%a.log'
##SBATCH -N 1
##SBATCH --ntasks-per-socket=1
##SBATCH --ntasks-per-node=1

# Split up text file
text_file="$1"
linenum=$SLURM_ARRAY_TASK_ID
linenum=$((linenum-1))
OLDIFS=$IFS
IFS=$'\n'

array=( $(grep "[a-z]" $text_file) )
linetxt=${array["$linenum"]}
echo "$linetxt"

# Split up line
IFS=$OLDIFS
delim=' ' read -r -a linearray <<< "$linetxt"

module load anaconda
conda activate sleap

save_path="${linearray[0]}"

python -m sleap.info.write_tracking_h5 --all-frames "$save_path"
