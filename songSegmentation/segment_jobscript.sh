#!/bin/bash
#SBATCH --job-name=WT
#SBATCH --time=02:00:00
#SBATCH -N 1
#SBATCH --cpus-per-task=9
##SBATCH --ntasks-per-socket=1
##SBATCH --ntasks-per-node=1
#SBATCH --mem=96G
#SBATCH --output='logs/WT.%A.%a.log'

text_file="$1"
linenum=$SLURM_ARRAY_TASK_ID
linenum=$((linenum-1))

echo $linenum
OLDIFS=$IFS
IFS=$'\n'

array=( $(grep "[a-z]" $text_file) )
linetxt=${array["$linenum"]}

IFS=$OLDIFS
delim=' ' read -r -a linearray <<< "$linetxt"

module purge
module load matlab/R2018b

daq_path="'${linearray[0]}'"
save_path="'${linearray[1]}'"
echo "daqpath: $daq_path"
echo "savepath: $save_path"

matlab -nosplash -nodisplay -nodesktop -r "segment_song_bandstop_daq($daq_path, $save_path); quit;"
# matlab -nosplash -nodisplay -nodesktop -r "segment_Sechellia($daq_path, $save_path); quit;"
