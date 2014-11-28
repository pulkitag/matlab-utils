function [cnfg] = get_myutils_config(varargin)

dfs = {'caffeVersion','caffe-v2-2', 'deviceId',[]};
dfs = get_defaults(varargin, dfs, true);

host = get_hostname();
%keyboard;
switch host(1:3)
	case {'vader','anakin','spock','poseidon'}
		caffeDir = '/work4/pulkitag-code/pkgs/';
		toolPkgs = '/work4/pulkitag-code/pkgs/';
	otherwise
		caffeDir = '/home/eecs/pulkitag/Research/codes/codes/projCaffe/';
		toolPkgs = '/home/eecs/pulkitag/Research/codes/codes/pkgs/';
end

if isempty(dfs.deviceId)
	cnfg.deviceId = 0;
else
	cnfg.deviceId = dfs.deviceId;
end

cnfg.paths.caffe = fullfile(caffeDir, dfs.caffeVersion);
cnfg.paths.caffeMatlab = fullfile(caffeDir, dfs.caffeVersion, 'matlab','caffe');
cnfg.paths.toolPkgs = toolPkgs;
	
end


function [name] = get_hostname()
	[out, cmdout] = system('echo $HOSTNAME');
	name = cmdout;
end
