% This is a demonstratin of FRID framework using a simulated dataset

%% Clear all
clc;
clear;
close all;

%% Add path
addpath('./util/');
addpath('./FRID/');

%% Load data and pre-process
dataset_path = './Sim3_p0.1_mini.mat';
load(dataset_path);

[nN,nT]=size(Fr);
ns=length(unique(id_true)); % Number of clusters


%% FRID
tic;
disp('FRID for clustering');
numanchor=900;
alpha=0.1;

[~,ids,~] = FRID(Fr,ns,alpha,numanchor,true,2);
% Evaluate accuracy on the simulation dataset
res=Clustering8Measure(id_true,ids);

disp('FRID done!');
toc;


%% Visualize the result
figure();
newL2 = bestMap(id_true,ids);
cfm=confusionmat(id_true,newL2);
cfm_norm = cfm;
for i = 1:size(cfm_norm, 1)
    cfm_norm(i, :) = cfm_norm(i, :) / sum(cfm_norm(i, :));
end
imagesc(cfm_norm);  hold on 
for icc=1.5:1:ns-0.5
    plot([0.5,ns+0.5],[icc, icc],'k--');
    plot([icc,icc],[0.5,ns+0.5],'k--');
end
axis equal;   
colormap(flipud(othercolor('RdBu4')));
colorbar;
caxis([0, 1]);
xlim([0.5, 5.5]);
ylim([0.5, 5.5]);
title('FRID result');
xlabel('Predicted cluster'); ylabel('Actual cluster');
savefig('./confusion_matrix.fig');

%% Save result
save('./clusres.mat','res', '-v7.3');
