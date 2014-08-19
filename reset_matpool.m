function [] = reset_matpool()
    numWorkers = matlabpool('size');
    if(numWorkers>0)
        disp('Resetting matlab-pool');
        matlabpool('close');
        matpool(numWorkers);
    end

end