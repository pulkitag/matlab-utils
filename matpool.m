function matpool(n)

% Open the pool and try to be somewhat robust to error
if n > 0
  %j = findResource();
  %mat_job_dir = j.DataLocation;
  mat_job_dir = '/scratch/pulkitag/matlab/local_scheduler_data';

  % Make the directory if it doesn't exist
  if ~exist(mat_job_dir, 'dir')
    [rv, msg] = system(sprintf('mkdir -p %s', mat_job_dir));
    if rv ~= 0
      error(sprintf('error: %s', msg));
    end
  end

  while true
    try
      matlabpool('open', n);
      break;
    catch exc
      r = getReport(exc, 'extended');
      disp(r);
      t = 5 + rand*10;
      fprintf('Ugg! Something bad happened. Trying again in %f seconds...\n', t);
      pause(t);
    end
  end
end
