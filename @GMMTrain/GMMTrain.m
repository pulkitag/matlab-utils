classdef GMMTrain < handle
    
    properties
        cluster_count % number of visual words in codebook
        descount_limit % limit on # features to use for clustering
        maxcomps % maximum number of comparisons when using ANN (-1 = exact)
        GMM_init % GMM initialisation method
    end

    methods
        function obj = GMMTrain(cluster_count)
            obj.cluster_count = cluster_count;
            obj.descount_limit = 1e6;
            obj.maxcomps = ceil(cluster_count/4);
            obj.GMM_init = 'kmeans';
        end

        codebook = train(obj, feat, varargin)

    end

end