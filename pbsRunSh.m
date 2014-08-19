function [] = pbsRunSh(jobFileName)

disp('In pbsRunSh');
data     = load(jobFileName);
matF     = data.matF;
username = data.username;
jobName  = data.jobName;
maxJobs  = data.maxJobs;
minJobs  = data.minJobs;
fname    = data.fname;

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
	else
		disp('All Jobs Launched');
    end
    %Pause for some time
    pause(60);
end

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
exit;
end
