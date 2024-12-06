function [U,labels,Z] = FRID(X,k,alpha,numanchor,ifnorm,nrepanch)

% Input:
% X: The neural activity, size of neuron number x time steps
% k: number of clustering
% alpha: sparisity penalty parameter
% numanchor: anchor number
% ifnorm: bool, if perform normalization
% nrepanch: number of repetitions on finding anchor

% Output:
% U: The embedding of the neurons
% labels: The clustering result of each neuron
% Z: The affinity matrix

num=size(X,1); 

% Normalization 
if ifnorm
    for t = 1:size(X,1)
     X(t,:)=X(t,:)./norm(X(t,:),'fro');
    end    
end
X = double(X);

% Find anchor 
[~, H] = litekmeans(X,numanchor,'MaxIter', 100,'Replicates',nrepanch);
[numanchor,~]=size(H);

% Do quadratic optization
options = optimset( 'Algorithm','interior-point-convex','Display','off');

A=2*alpha*eye(numanchor)+2*H*H';
A=(A+A')/2;
B=X';
parfor ji=1:num
    ff=-2*B(:,ji)'*H';
    Z(:,ji)=quadprog(A,ff',[],[],[],[],-ones(numanchor,1),ones(numanchor,1),[],options);
end

% Get the affinity matrix
Sbar=abs(Z);

% Do spectral clustering
[U,Sig,V] = mySVD(Sbar',k);
labels=litekmeans(U, k, 'MaxIter', 100,'Replicates',10);


