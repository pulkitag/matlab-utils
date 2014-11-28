function [] = test_pbs(i)

pathName = '/home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/unit_test/data/';
fileName = fullfile(pathName,sprintf('pbs_test_pass%d.mat',i));
save(fileName,'i');
end
