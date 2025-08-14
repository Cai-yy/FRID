function [uniqueBases, sharedBasis,clusterBases,ev_cumsum] = extractUniqueBases(X, labels, varargin)
% INPUT:
%   - X: D x N data matrix
%   - labels: N x 1 cluster labels
%   - Optional: 'Rank' or 'EnergyThreshold' to control basis selection per cluster
% OUTPUT:
%   - uniqueBases: 1 x K cell array of unique basis matrices
%   - sharedBasis: D x d_shared matrix of shared basis

% Parse optional inputs
params = inputParser;
addParameter(params, 'Rank', [], @isnumeric); % Fixed rank per cluster
addParameter(params, 'EnergyThreshold', 0.95, @isscalar); % Default: 95% energy
parse(params, varargin{:});

K = max(labels);
clusterBases = cell(1, K);
total_var=zeros(1,K);

%% Step 1: Estimate basis for each cluster (keep only important PCs)
parfor k = 1:K
    Xk = X(:, labels == k);
    Xk_centered = Xk - mean(Xk, 2);
    [Uk, Sk, ~] = svd(Xk_centered, 'econ');
    s = diag(Sk);
    total_var(k) = sum(s.^2);
    
    % Select basis vectors based on energy or fixed rank
    if ~isempty(params.Results.Rank)
        rk = min(params.Results.Rank, size(Uk, 2)); % Ensure rank <= dim
    else
        cum_energy = cumsum(s.^2) / sum(s.^2);
        rk = find(cum_energy >= params.Results.EnergyThreshold, 1);
    end
    clusterBases{k} = Uk(:, 1:rk); % Keep top-rk PCs
    fprintf('%d / %d \n',k,K);
end

%% Step 2: Find shared basis (using only selected PCs)
allBases = [];
parfor k = 1:K
    allBases = [allBases, clusterBases{k}];
end

[U, S, ~] = svd(allBases, 'econ');
s = diag(S);
d_shared = sum(s > sqrt(K/2)); % Adjust threshold as needed
sharedBasis = U(:, 1:d_shared);

%% Step 3: Extract unique basis
uniqueBases = cell(1, K);
parfor k = 1:K
    Uk = clusterBases{k};
    % Remove shared components and orthogonalize
    % Uk_unique = orth(Uk - sharedBasis * (sharedBasis' * Uk));
    Uk_unique = Uk - sharedBasis * (sharedBasis' * Uk);
    uniqueBases{k} = Uk_unique;
end

%% Calculate the summed variance
% The kth element is the explained variance of the shared basis plus the
% unique basis 1-k
ev_cumsum=cell(1,K);
parfor k=1:K
    Xk = X(:, labels == k);
    Xk_centered = Xk - mean(Xk, 2);
    % Cat the base 
    Uk=clusterBases{k};
    rk=min(size(Uk,2),20);
    sum_var=zeros(1,rk);
    ev_ratio=zeros(1,rk);
    for rrr=1:rk
        % Project to the cat result
        catbs=orth([sharedBasis,Uk(:,1:rrr)]);
        Xk_proj = catbs * (catbs' * Xk_centered);
        % Variance explained by these basis
        [~, S_unique, ~] = svd(Xk_proj, 'econ');
        sum_var(rrr) = sum(diag(S_unique).^2);
        ev_ratio(rrr)=sum_var(rrr)/total_var(k);
    end
    ev_cumsum{k}=ev_ratio;
    fprintf('cal explained variance, %d / %d\n',k,K);
end

end