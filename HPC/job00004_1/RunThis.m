%% Inits
clc
clear all
close all
S = dbstack('-completenames');
fullDir = S(1).file(1:end-10);
jobFunctionName = split(fullDir,'/');jobFunctionName = jobFunctionName{end};
%% Inputs 
input{1}  = [1:5]; % mc
input{2}  = [1 4 8 12 16]; % fa
input{3}  = [1 5 10 15 20]; % npaths
input{4}  = [-10:2:30]; % PT

combVecExpr = ['InputMatrix = combvec('];
for k = 1:length(input)
    combVecExpr = [combVecExpr,'input{',num2str(k),'},'];
end
combVecExpr = combVecExpr(1:end-1);
combVecExpr = [combVecExpr, ');'];
eval(combVecExpr);
InputMatrix=InputMatrix.';
% % combvec(input)
%% jobs.txt
noOfJobs = size(InputMatrix,1);
fileID = fopen([fullDir,'/jobs.txt'],'w');
lineForm = ['matlab -nosplash -nodisplay -nodesktop -nojvm -singleCompThread -r ',jobFunctionName,'('];
for k = 1:size(InputMatrix,1)
    line_k = [lineForm];
    for m = 1:size(InputMatrix,2)
        line_k = [line_k,num2str(InputMatrix(k,m)),','];
    end
    line_k=line_k(1:end-1);
    line_k=[line_k,')'];
    fprintf(fileID,line_k);
    fprintf(fileID,'\n');
end
fclose(fileID)
disp(['Total number of jobs generated = ',num2str(noOfJobs)])
%% jobsParallel.txt
noOfJobs = size(InputMatrix,1);
fileID = fopen([fullDir,'/jobsParallel.txt'],'w');
lineForm = ['module load matlab; matlab -nosplash -nodisplay -nodesktop -nojvm -singleCompThread -r "',jobFunctionName,'('];
for k = 1:size(InputMatrix,1)
    line_k = [lineForm];
    for m = 1:size(InputMatrix,2)
        line_k = [line_k,num2str(InputMatrix(k,m)),','];
    end
    line_k=line_k(1:end-1);
    line_k=[line_k,')"'];
    fprintf(fileID,line_k);
    fprintf(fileID,'\n');
end
fclose(fileID)
disp(['Total number of jobs generated = ',num2str(noOfJobs)])
%% submit.sh
fileID = fopen([fullDir,'/submit.sh'],'w');
fprintf(fileID,'#!/bin/bash \n');
fprintf(fileID,'\n');
fprintf(fileID,'#SBATCH -n 1\n');
fprintf(fileID,'#SBATCH --array=1-%d\n',noOfJobs);
fprintf(fileID,'#SBATCH -c 1\n');
% fprintf(fileID,'#SBATCH -p preempt\n'); % go Dalma
fprintf(fileID,'\n');
fprintf(fileID,'#Max wallTime for the job \n');
fprintf(fileID,'#SBATCH -t 167:00:00 \n');
fprintf(fileID,'#SBATCH -o ./matlab.%%J.out');
fprintf(fileID,'\n');
fprintf(fileID,'#SBATCH -e ./matlab.%%J.err');
fprintf(fileID,'\n');
fprintf(fileID,'#Resource requiremenmt commands end here\n');
fprintf(fileID,'\n');
fprintf(fileID,'#source ./submit.sh\n');
fprintf(fileID,'#Add the lines for running your code/application\n');
fprintf(fileID,'module purge\n');
fprintf(fileID,'module load matlab\n');
fprintf(fileID,'\n');
fprintf(fileID,'\n');
fprintf(fileID,'srun $(head -n $SLURM_ARRAY_TASK_ID jobs.txt | tail -n 1)');
fclose(fileID);
% slurm_parallel_ja_submit.sh -t 167:00:00 -N 5184 jobsParallel.txt 
disp('===========')
disp('Run the following on HPC: ')
disp(['slurm_parallel_ja_submit.sh -t 167:00:00 -N ',num2str(noOfJobs),' jobsParallel.txt '])
disp('===========')
disp('Run the following on HPC (wireless lab): ')
disp(['slurm_parallel_ja_submit.sh -q wlab -t 167:00:00 -N ',num2str(noOfJobs),' jobsParallel.txt '])