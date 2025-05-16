#!/bin/bash 

#SBATCH -n 1
#SBATCH --array=1-2625
#SBATCH -c 1

#Max wallTime for the job 
#SBATCH -t 167:00:00 
#SBATCH -o ./matlab.%J.out
#SBATCH -e ./matlab.%J.err
#Resource requiremenmt commands end here

#source ./submit.sh
#Add the lines for running your code/application
module purge
module load matlab


srun $(head -n $SLURM_ARRAY_TASK_ID jobs.txt | tail -n 1)