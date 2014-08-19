#!/bin/bash 
#PBS -N test
#PBS -r n
#PBS -w /home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/
#PBS -e /home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/data/test.err
#PBS -o /home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/data/test.log
#PBS -q psi 
#PBS -l nodes=1:ppn=1

#PBS -l mem=2g 
#PBS -l walltime=12:00:00 
#PBS -l cput=240:00:00 
echo Working directory is $PBS_O_WORKDIR 
cd $PBS_O_WORKDIR 
echo Running on host `hostname` 
echo Time is `date` 
echo Directory is `pwd` 
echo This jobs runs on the following processors: 
echo `cat $PBS_NODEFILE` 
NPROCS=`wc -l < $PBS_NODEFILE` 
echo This job has allocated $NPROCS cpus 
echo This job is the $PBS_ARRAYID th function 

if [ $PBS_ARRAYID = 1 ]; then 
	source /home/eecs/pulkitag/.bashrc 
	env LD_PRELOAD=/lib/libgcc_s.so.1:/usr/lib/libstdc++.so.6 /usr/sww/pkg/matlab-r2011a/bin/matlab -nodisplay -r "tic; test_pbs(1); toc; quit;" > /home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/data/test1.log 2> /home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/data/test1.err 
elif [ $PBS_ARRAYID = 2 ]; then 
	source /home/eecs/pulkitag/.bashrc 
	env LD_PRELOAD=/lib/libgcc_s.so.1:/usr/lib/libstdc++.so.6 /usr/sww/pkg/matlab-r2011a/bin/matlab -nodisplay -r "tic; test_pbs(2); toc; quit;" > /home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/data/test2.log 2> /home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/data/test2.err 
fi 
