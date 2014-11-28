function pbsRunFunctions_parallel(jobName, batchDir, workDir, nodes, ppn, mem, HH_cpu,HH_wall, matF, notif, minJobs, maxJobs, username,isZen,isSingleComp,isWait)
%function pbsRunFunctions(jobName, batchDir, workDir, nodes, ppn, mem, HH, matF, notif, minJobs, maxJobs,username)

if ~exist('isWait','var')
	isWait = true;
end

fname = fullfile(batchDir, sprintf('%s.sh',jobName));
cellFile = fullfile(batchDir, sprintf('opts_%s.mat',jobName)); 
fid = fopen(fname,'w');
if (fid==-1),
    error('Could not open file %s for writing.',fname);
end
fprintf(fid,['#!/bin/bash \n']);
fprintf(fid,['#PBS -N ' jobName '\n']);
fprintf(fid,['#PBS -r n\n']);
if (notif),
    fprintf(fid, '#PBS -m ae\n');
    fprintf(fid,['#PBS -M ' username '@eecs.berkeley.edu\n']);
end
fprintf(fid, ['#PBS -w ' workDir '\n']);
fprintf(fid, ['#PBS -e ' fullfile(batchDir,sprintf('%s.err',jobName)) '\n']);
fprintf(fid, ['#PBS -o ' fullfile(batchDir,sprintf('%s.log',jobName)) '\n']);
if(isZen)
    fprintf(fid, ['#PBS -q zen \n']);
else
    fprintf(fid, ['#PBS -q psi \n']);
end
fprintf(fid, ['#PBS -l nodes=' num2str(nodes) ':ppn=' num2str(ppn) '\n\n']);
if (mem>0),
    fprintf(fid, ['#PBS -l mem=' num2str(mem) 'g \n']);
end
if (HH_wall>0),
    MM = floor((HH_wall-floor(HH_wall))*60);
    fprintf(fid, ['#PBS -l walltime=' num2str(floor(HH_wall)) ':' num2str(MM,'%02d') ':00 \n']);
    fprintf(fid, ['#PBS -l cput=' num2str(floor(HH_cpu)) ':' num2str(MM,'%02d') ':00 \n']);
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
if(isSingleComp)
    matlabString = 'env LD_PRELOAD=/lib/libgcc_s.so.1:/usr/lib/libstdc++.so.6 /usr/sww/pkg/matlab-r2011a/bin/matlab -singleCompThread -nodisplay -r ';
else
    matlabString = 'env LD_PRELOAD=/lib/libgcc_s.so.1:/usr/lib/libstdc++.so.6 /usr/sww/pkg/matlab-r2011a/bin/matlab -nodisplay -r ';
end
if(length(matF) > 0)
    fprintf(fid, ['if [ $PBS_ARRAYID = 1 ]; then \n']);
    fprintf(fid,['\t' 'source /home/eecs/pulkitag/.bashrc \n']);
	logFileName = fullfile(batchDir,sprintf('%s%d.log',jobName,1)); 
	errFileName = fullfile(batchDir,sprintf('%s%d.err',jobName,1)); 
	fprintf(fid, ['\t' matlabString '"tic; ' matF{1} '; toc; quit;" > ' logFileName ' 2> ' errFileName  ' \n']);
    for i = 2:length(matF)
        fprintf(fid, ['elif [ $PBS_ARRAYID = ' num2str(i) ' ]; then \n']);
        fprintf(fid,['\t' 'source /home/eecs/pulkitag/.bashrc \n']);
		logFileName = fullfile(batchDir,sprintf('%s%d.log',jobName,i));
		errFileName = fullfile(batchDir,sprintf('%s%d.err',jobName,i));
        fprintf(fid, ['\t' matlabString '"tic; ' matF{i} '; toc; quit;" > ' logFileName ' 2> ' errFileName ' \n']);
    end
    fprintf(fid,'fi \n');
end
fclose(fid);
save(cellFile,'fname','jobName', 'batchDir', 'workDir', 'nodes', 'ppn', 'mem', 'HH_cpu','HH_wall', 'matF', 'notif', 'minJobs', 'maxJobs', 'username','isZen','isSingleComp','-v7.3');
pause(0.01);

[~,hostName] = system('hostname');
hostName = strtrim(hostName);
if (strcmp(hostName,'psi') || strcmp(hostName,'zen'))
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

	if isWait
		while(true)
			[status, numJobs] = system(['qstat -a | grep ' username ' | grep ''' jobName ''' | wc -l']);
			if(str2num(numJobs)==0)
				break;
			else
				disp(numJobs);
			end
			pause(10);
		end
		disp('All jobs have finished!');
	end
else
	remoteCmd  = sprintf('ssh psi pbs.sh pbsRunSh %s',cellFile);
	disp(remoteCmd);
	status     = system(remoteCmd); 	 
end


