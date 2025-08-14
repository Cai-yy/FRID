% This code runs the LMVSC algorithm and records its
% performance. The results are output in *.txt format.

% Notice: The dataset is organized in a cell array with each element being
% a view. Each view is represented by a matrix, each row of which is a
% sample.

% The core of LMVSC is encapsulated in an independent matlab function.
% Visit lmv.m directly, if you want to learn the details of its
% implementation.

% clear;
addpath([pwd, '/measure']);
load ('E:\Projects\subspace Cluster\validation_simulation\Sim6_p5e-3.mat');
X{1} = Fr;  % 用元胞数组存储节点特征，每行对应一个节点
Y = id_true;  % 节点标签
nv=1;  % single view clustering
n = length(Y);  %节点个数
norm_style = 2; % 特征预处理的类型
switch norm_style
    case 1
        for v = 1:nv
            X{v} = full(X{v});
            for  j = 1:n
                X{v}(j,:) = ( X{v}(j,:) - mean( X{v}(j,:) ) ) / std( X{v}(j,:) ) ;
            end
        end
    case 2
        % 长度归一化
        for v = 1:nv
            X{v} = full(X{v});
            XX = X{v};
            for t = 1:size(XX,1)
                XX(t,:)=XX(t,:)./norm(XX(t,:),'fro');
            end
            X{v} = double(XX);
        end
    case 3
        % 最大值归一化
        for v = 1:nv
            X{v} = full(X{v});
            a = max(X{v}(:));
            X{v} = double(X{v}./a);
        end
end
    
ns=length(unique(Y));  % 总类别个数

% 参数设置
% Parameter 1: number of anchors (tunable)
numanchor=[100];   % ns, 100，200，500

% Parameter 2: alpha (tunable)
alpha=[0.001];  % tuned from 1e-4,1e-3,1e-2,1e-1,1e0,1e1, or more
totalrun = 10;   % 独立重复的次数, default 20

%%
for j=1:length(numanchor)
    for i=1:length(alpha)
        fprintf('params:\tnumanchor=%d\t\talpha=%f\n',numanchor(j),alpha(i));
        for runid = 1:totalrun
            rng(runid*1000)
            tic;
            % Perform K-Means on each view
            parfor v=1:nv
%                 rand('twister',5489);
                % % 可增加 replicates 次数提升稳定性，但也会增加运行时间
                [~, H{v}] = litekmeans(X{v},numanchor(j),'MaxIter', 100,'Replicates',1); 
            end
            % Core part of this code (LMVSC)
            [F,ids] = lmv(X,Y,H,alpha(i));

            % Performance evaluation of clustering result
    %         result=ClusteringMeasure(ids,Y);
            [result(runid,:)] = Clustering8Measure(Y, ids);
            timer(runid) = toc;
            fprintf('result: %.4f\t %.4f\t %.4f\t %.4f\t Time:%.4f\n\n',result(runid,1),result(runid,2),result(runid,3),result(runid,4),timer(runid));
        end
        mean_res = mean(result,1);
        std_res = std(result,1);
        fprintf('mean_result: %.4f\t %.4f\t %.4f\t %.4f\t Time:%.4f\n\n',mean_res(1),mean_res(2),mean_res(3),mean_res(4),mean(timer));

        output1 = [',alpha=' num2str(alpha(i),'%.4f'), ',m=' num2str(numanchor(j),'%.1f'), ',totalrun=', num2str(totalrun,'%.1f'),...
             ',norm_style=' num2str(norm_style,'%.1f')];
        output2 = ['measure: ACC nmi Purity Fscore Precision Recall AR Entropy'];
        output3 = ['mean:',...
                  num2str(mean_res(1),'%.4f'),' ', num2str(mean_res(2),'%.4f'),' ',num2str(mean_res(3),'%.4f'),' ',num2str(mean_res(4),'%.4f'),' ', ...
                  num2str(mean_res(5),'%.4f'),' ',num2str(mean_res(6),'%.4f'),' ',num2str(mean_res(7),'%.4f'),' ',num2str(mean_res(8),'%.4f')
                 ];
        output4 = ['std:',...
                  num2str(std_res(1),'%.4f'),' ',num2str(std_res(2),'%.4f'),' ',num2str(std_res(3),'%.4f'),' ',num2str(std_res(4),'%.4f'),' ', ...
                  num2str(std_res(5),'%.4f'),' ',num2str(std_res(6),'%.4f'),' ',num2str(std_res(7),'%.4f'),' ',num2str(std_res(8),'%.4f')
                 ];
        output5 = ['time:',',avgrate=' num2str(mean(timer),'%.4f'),',std=' num2str(std(timer),'%.4f'), '\n'
          ];
        fid = fopen('sim1_results.txt','a');
        fprintf(fid, '%s\n', output1);
        fprintf(fid, '%s\n', output2);
        fprintf(fid, '%s\n', output3);
        fprintf(fid, '%s\n', output4);
        fprintf(fid, '%s\n', output5);
        fclose(fid);
        
    end
end