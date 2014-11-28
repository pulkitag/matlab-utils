function [codebook] = train(obj,feats)
%feats: numFeat*numExamples

if isequal(obj.GMM_init, 'kmeans')
    fprintf('Computing initial means using K-means...\n');

    % if maxcomps is below 1, then use exact kmeans, else use approximate
    % kmeans with maxcomps number of comparisons for distances
    if obj.maxcomps < 1
        init_mean = vl_kmeans(feats, obj.cluster_count, ...
            'verbose', 'algorithm', 'elkan');
    else
        init_mean = annkmeans(feats, obj.cluster_count, ...
            'verbose', false, 'MaxNumComparisons', obj.maxcomps, ...
            'MaxNumIterations', 150);
    end

    fprintf('Computing initial variances and coefficients...\n');

    % compute hard assignments
    kd_tree = vl_kdtreebuild(init_mean, 'numTrees', 3) ;
    assign = vl_kdtreequery(kd_tree, init_mean, feats);

    % mixing coefficients
    init_coef = single(vl_binsum(zeros(obj.cluster_count, 1), 1, double(assign)));
    init_coef = init_coef / sum(init_coef);

    % variances
    init_var = zeros(size(feats, 1), obj.cluster_count, 'single');

    for i = 1:obj.cluster_count
        feats_cluster = feats(:, assign == i);
        init_var(:, i) = var(feats_cluster, 0, 2);
    end

elseif isequal(obj.GMM_init, 'rand')
    init_mean = [];
    init_var = [];
    init_coef = [];
end

fprintf('Clustering features using GMM...\n');

% call FMM mex
gmm_params = struct;

if ~isempty(init_mean) && ~isempty(init_var) && ~isempty(init_coef)
    codebook = mexGmmTrainSP(feats, obj.cluster_count, gmm_params, init_mean, init_var, init_coef);
else
    codebook = mexGmmTrainSP(feats, obj.cluster_count, gmm_params);
end

fprintf('Done training codebook!\n');
end

