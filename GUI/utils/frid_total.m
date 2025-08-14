function [ids] = frid_total(X, k, numanchor, alpha)

for t = 1:size(X,1)
    X(t,:) = X(t,:)./ norm(X(t,:),'fro');
end
X = double(X);

[~, H] = litekmeans(X,numanchor,'MaxIter', 100, 'Replicates', 2);
[F,ids] = frid_edit(X,k, H, alpha);

end
