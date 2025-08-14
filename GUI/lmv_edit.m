function [U,labels, Z] = lmv_edit(X,k,H,alpha)

num=size(X,1); 
[r,~]=size(H);

options = optimset( 'Algorithm','interior-point-convex','Display','off');

A=2*alpha*eye(r)+2*H*H';
A=(A+A')/2;
B=X';
parfor ji=1:num
    ff=-2*B(:,ji)'*H';
    ff = double(ff);
    Z(:,ji)=quadprog(A,ff',[],[],[],[],-ones(r,1),ones(r,1),[],options);
end
Sbar=abs(Z);
%  f(j)=(norm(X{j}'-H{j}'*S{j},'fro'))^2+alpha*(norm(S{j},'fro'))^2;

% for ji=1:nv
%     f(ji)/sum(f)
%      Sbar=cat(1,Sbar,1/sqrt(nv)*S{ji}/f(ji));
% end

[U,Sig,V] = mySVD(Sbar',k);

% rand('twister',5489)
labels=litekmeans(U, k, 'MaxIter', 100,'Replicates',10);%kmeans(U, c, 'emptyaction', 'singleton', 'replicates', 100, 'display', 'off');

