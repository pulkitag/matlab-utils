function pbsRunFunctions(jobName, batchDir, workDir, nodes, ppn, mem, HH, matF, notif, minJobs, maxJobs, username)
%function pbsRunFunctions(jobName, batchDir, workDir, nodes, ppn, mem, HH, matF, notif, minJobs, maxJobs,username)

fname = fullfile(batchDir, sprintf('%s.sh',jobName));
fid = fopen(fname,'w');
if (fid==-1), 
	error('Could not open file %s for writing.',fname);
end
fprintf(fid,['#!/bin/sh \n']);
fprintf(fid,['#PBS -N ' jobName '\n']);
fprintf(fid,['#PBS -r n\n']);
if (notif),
   fprintf(fid, '#PBS -m ae\n');
   fprintf(fid,['#PBS -M ' username '@eecs.berkeley.edu\n']);
end
fprintf(fid, ['#PBS -w ' workDir '\n']);
fprintf(fid, ['#PBS -e ' fullfile(batchDir,sprintf('%s.err',jobName)) '\n']);
fprintf(fid, ['#PBS -o ' fullfile(batchDir,sprintf('%s.log',jobName)) '\n']);
fprintf(fid, ['#PBS -q zen \n']);
fprintf(fid, ['#PBS -l nodes=' num2str(nodes) ':ppn=' num2str(ppn) '\n\n']);
if (mem>0),
   fprintf(fid, ['#PBS -l mem=' num2str(mem) 'g \n']);
end
if (HH>0),
	MM = floor((HH-floor(HH))*60);
   fprintf(fid, ['#PBS -l walltime=' num2str(floor(HH)) ':' num2str(MM,'%02d') ':00 \n']);
   fprintf(fid, ['#PBS -l cput=' num2str(floor(HH)) ':' num2str(MM,'%02d') ':00 \n']);
end
fprintf(fid, ['echo Working directory is $PBS_O_WORKDIR \n']);
fprintf(fid, ['cd $PBS_O_WORKDIR \n']);
fprintf(fid, 'echo Running on host `hostname` \n');
fprintf(fid, 'echo Time is `date` \n');
fprintf(fid, 'echo Directory is `pwd` \n');
fprintf(fid, 'echo This jobs runs on the following processors: \n'); 
fprintf(fid, 'echo `cat $PBS_NODEFILE` \n');
fprintf(fid, 'NPROCS=`wc -l < $PBS_NODEFILE` \n'); 
fprintf(fid, 'echo This job has allocated $NPROCS cpus \n');
fprintf(fid, 'echo This job is the $PBS_ARRAYID th function \n');
fprintf(fid, '\n');
matlabString = 'env LD_PRELOAD=/lib/libgcc_s.so.1:/usr/lib/libstdc++.so.6 /usr/sww/pkg/matlab-r2010b/bin/matlab -singleCompThread -nodisplay -r ' 

if(length(matF) > 0)
	fprintf(fid, ['if [ $PBS_ARRAYID = 1 ]; then \n']);
	fprintf(fid, ['\t' matlabString '"tic; ' matF{1} '; toc; quit;"\n']);
	for i = 2:length(matF)
		fprintf(fid, ['elif [ $PBS_ARRAYID = ' num2str(i) ' ]; then \n']);
		fprintf(fid, ['\t' matlabString '"tic; ' matF{i} '; toc; quit;"\n']);
	end
	fprintf(fid,'fi \n');
end
fclose(fid);
pause(0.01);

nJobs = length(matF);
launched = 0;
while launched < nJobs,
	%Check how many are running..
	cmd = ['qstat -a| grep ' username ' | grep ''' jobName ''' | wc -l']
	[gr a] = system(cmd);
	runningNow = str2num(a);
	canLaunch = maxJobs-runningNow;
	%If running less than minJobs, launch new jobs..
	if(runningNow < minJobs)
		cmd = sprintf('qsub %s -t %d-%d',fname,launched+1,min(launched+canLaunch,nJobs))
		system(cmd);
		launched = min(launched+canLaunch,nJobs);
	end
	%Pause for some time
	pause(60);
end
end
