function [out] = test_submit_pbs()


clear jobString;
jobString = {};
logDir = '/home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/data/';
codeDir = '/home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/';
nodes = 1;
ppn = 1;
mem = 2; %in gigs
wallt = 12; %in hours
cput = 240;
notif = false;
minJobs = 40;
maxJobs = 50;
username = 'pulkitag';
jobName = 'test';

%##################
isZen = false;
singleComp = false;
isWait     = true;
%###############

jobNum = 1;

for n=1:1:2
	jobString{jobNum} = sprintf('test_pbs(%d)',n);
	fprintf([jobString{jobNum} '\n']);
	jobNum = jobNum + 1;
end
%keyboard;
pbsRunFunctions_parallel(jobName, logDir, codeDir, nodes, ppn, mem, cput,wallt, jobString, notif, minJobs, maxJobs, username,isZen,singleComp,isWait);

end
