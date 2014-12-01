function [out] = add_toolbox(toolName)

cnfg = get_myutils_config();

pkg_path = cnfg.paths.toolPkgs;
pkg_path_2 = '/work4/pulkitag/code/';
codePath = '/home/eecs/pulkitag/Research/codes/codes/';
my_pkg_path = '/home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/my_pkgs/';
utils_path  = '/home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/';
switch toolName
	case 'gpb'
		addpath(fullfile(pkg_path_2,'BSR_source/grouping/lib'));
		disp('gpb added');
	
	case 'bsr'
		addpath(fullfile(pkg_path,'BSR/BSR/bench/benchmarks/'));
		disp('bsr benchmakrs code added');
	
	case 'vlfeat'
		addpath(fullfile(pkg_path,'vlfeat','/vlfeat-0.9.18/toolbox/'));
		vl_setup;
		disp('Added vlfeat');
        
    case 'libsvm'
        addpath('/home/eecs/pulkitag/Research/codes/codes/pkgs/libsvm-3.16/matlab/');
        disp('Added libsvm');

	case 'liblinear'
		addpath(strcat(pkg_path,'liblinear_subhranshu/liblinear/matlab'));
		disp('Added liblinear, version: Subhranshu');

	case 'liblinear-joachims'
		addpath(strcat(pkg_path,'liblinear-1.93/matlab/'));
		disp('Added liblinear, version: joachims');		

	case 'minFunc'
		addpath(genpath(strcat(pkg_path,'minFunc_2012')));
		disp('Added minFunc');
        
	case 'labelme'
		addpath(strcat(pkg_path,'LabelMeToolbox'));
		disp('LabelMe Added');

		case 'voc_2007'
			addpath(strcat(pkg_path,'VOCdevkit_2007/VOCdevkit/VOCcode'));
			disp('VOC_2007 Code added');
        
    case 'voc_code'
		addpath(strcat(pkg_path,'VOCdevkit/VOCcode'));
        disp('VOC Code added');

    case 'gurobi'
		addpath(strcat(pkg_path,'gurobi510/linux64/matlab'));
		gurobi_setup;
        disp('gurobi added');

	case 'lbfgsb'
		addpath(strcat(pkg_path,'lbfgsb3.0_mex1.2/'));
		disp('lbfgsb added');

	case 'fisher'
		addpath(strcat(pkg_path,'fisher'));
		featpipem_addpaths;
		disp('pkg fisher added');

	case 'vocrelease5'
		addpath(strcat(pkg_path,'voc-release5/gdetect'));
		addpath(strcat(pkg_path,'voc-release5/features'));
		disp('Relevants parts of voc-release 5 added');

	case 'hog_lda'
		addpath(strcat(pkg_path,'hog_lda/generative_RELEASE/code/features'));
		addpath(strcat(pkg_path,'hog_lda/generative_RELEASE/code/learn'));
		addpath(strcat(pkg_path,'hog_lda/generative_RELEASE/code/misc'));
		disp('hog_lda feature code added');

	case 'svm_struct'
		disp('Not available');

	case 'projScene_singleclass'
		addpath(fullfile(codePath,'projScene/single_class'));
		disp('Single Class from projScene added');

	case 'projFisher'
		addpath(genpath(fullfile(codePath,'projFisher')));
		disp('projFisher added');

	case 'projScene'
		addpath(genpath(fullfile(codePath,'projScene')));
		disp('projScene added');

	case 'flow_brox'
		addpath(genpath(fullfile(pkg_path,'OpticalFlow')));
		disp('Brox optical flow added');

	case 'segment_pedro'
		addpath(genpath(fullfile(pkg_path,'segment')));
		disp('Pedro Segmentation added');

	case 'piotr'
		addpath(genpath(fullfile(pkg_path,'piotr')));
		disp('Piotrs Toolbox added');

	case 'my_svm'
		add_toolbox('liblinear');
		addpath(fullfile(my_pkg_path,'svm'));
		disp('My SVM Package added');

	case 'fconv'
		addpath(fullfile(pkg_path,'pkg_fconv/fconv'));
		addpath(fullfile(pkg_path,'pkg_fconv/fconv/bin'));
		disp('Convolutions package added');
	
	case 'export_fig'
		addpath(fullfile(pkg_path,'export_fig'));
		disp('export_fig added');

	otherwise
		disp('No Match found');

end

out=1;
end

