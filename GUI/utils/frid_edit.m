function [U,labels, Z] = frid_edit(X,k,H,alpha)

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


[U,Sig,V] = mySVD(Sbar',k);

labels=litekmeans(U, k, 'MaxIter', 100,'Replicates',10);%kmeans(U, c, 'emptyaction', 'singleton', 'replicates', 100, 'display', 'off');
