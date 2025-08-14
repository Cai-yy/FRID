function [labels_cell, Z] = frid_edit_multiple_k(X,k_list,H,alpha)

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
labels_cell = {length(k_list)};

for idx = 1:length(k_list)
    [U,Sig,V] = mySVD(Sbar', k_list(idx));
    labels=litekmeans(U, k_list(idx), 'MaxIter', 100,'Replicates',10);%kmeans(U, c, 'emptyaction', 'singleton', 'replicates', 100, 'display', 'off');
    labels_cell{idx} = labels;
end
