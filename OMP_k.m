function [C_best, matches_best] = OMP_k(X, K, M_BEST, MAX_ITERS, N_RESTARTS)
%From Jon
%K: Number of centers or dictionary size to be learnt
%M_Best: K in usual usage of OMP-K
if nargin < 4
  MAX_ITERS = 50;
end

if nargin < 5
  N_RESTARTS = 1;
end

distortion_best = inf;

tic

Xt = X';

for i_restart = 1:N_RESTARTS
  
  ridx = randperm(size(X,2));
  C = full(X(:,ridx(mod([0:(K-1)], length(ridx)-1)+1)));
  
  C = C ./ repmat(sqrt(sum(C.^2,1)), size(C,1), 1);
  
  C_last = C;
  
  for iter = 1:MAX_ITERS
    
    P = C'*X;
     
    matches = {};
    projs = {};
    for m = 1:M_BEST
          
      [p, i] = max(P, [], 1);

      matches{m} = i';
      projs{m} = p';
      
      if m < M_BEST
        X_proj = bsxfun(@times, p, C(:,i));
        P = P - C' * X_proj;
      end
      
    end
    matches = cat(2, matches{:});
    projs = cat(2, projs{:});
    
    A = sparse(reshape(repmat([1:size(matches,1)]', 1, size(matches,2)), [], 1), reshape(matches, [], 1), projs(:), size(X,2), K);
    
    warning off all
    if M_BEST == 1
      C = full(X*A);
    else
      C = full((A\Xt)');
    end
    warning on all
    
    dead_idx = all(C == 0);
    if any(dead_idx)
      C(:,dead_idx) = X(:,max(1,ceil(size(X,2)*rand(nnz(dead_idx),1))));
    end
    
    C = C ./ repmat(10^-8 + sqrt(sum(C.^2,1)), size(C,1), 1);
    
    delta_angle = mean(acos(sum(C_last .* C,1)))/pi;
    
    C_last = C;
    
    fprintf('%03d:   %0.3f   %0.2f sec/iter\n', iter, full(delta_angle), toc/iter);
    
  end
  
  At = A';
  distortion = mean(sum((C*At - X).^2,1),2);

  fprintf('\n');
    
  if distortion < distortion_best
    matches_best = matches;
    C_best = C;
    distortion_best = distortion;
  end
  
end
