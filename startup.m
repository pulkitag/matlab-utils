if(exist('/scratch/','dir')==7)
	if(~(exist('/scratch/pulkitag','dir')==7))
		system(['mkdir ' '/scratch/pulkitag']);
		system(['mkdir ' '/scratch/pulkitag/matlab']);
		system(['mkdir ' '/scratch/pulkitag/matlab/local_scheduler_data']);

	else
		if(~(exist('/scratch/pulkitag/matlab','dir')==7))  
			system(['mkdir ' '/scratch/pulkitag/matlab']);
			system(['mkdir ' '/scratch/pulkitag/matlab/local_scheduler_data']);
		end
	end

	j = findResource();
	mat_job_dir = '/scratch/pulkitag/matlab/local_scheduler_data';
	set(j,'DataLocation',mat_job_dir);
	disp('Data Location Set');
else
	disp('Data Location NOT set');
end
