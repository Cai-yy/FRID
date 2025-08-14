function cluster_gui

addpath('./LMVSC/');
% Simple GUI for clustering using lmv
fig = figure('Name','Clustering GUI','Position',[300 300 400 200]);
% Data file
uicontrol(fig,'Style','text','Position',[10 160 100 20],'String','Neuron file:');
edtFile = uicontrol(fig,'Style','edit','Position',[120 160 200 20]);
btnFile = uicontrol(fig,'Style','pushbutton','Position',[330 160 60 20],'String','Browse',...
    'Callback',@(s,e) selectFile());
% Cluster numbers
uicontrol(fig,'Style','text','Position',[10 120 100 20],'String','Cluster k:');
edtK = uicontrol(fig,'Style','edit','Position',[120 120 200 20],'String','3');
% Save path
uicontrol(fig,'Style','text','Position',[10 80 100 20],'String','Save folder:');
edtSave = uicontrol(fig,'Style','edit','Position',[120 80 200 20]);
btnSave = uicontrol(fig,'Style','pushbutton','Position',[330 80 60 20],'String','Browse',...
    'Callback',@(s,e) selectSave());
% Run button
uicontrol(fig,'Style','pushbutton','Position',[150 30 100 30],'String','Run',...
    'Callback',@(s,e) runClustering());

    function selectFile()
        [f,p] = uigetfile('*.mat');
        if f
            set(edtFile,'String',fullfile(p,f));
        end
    end
    function selectSave()
        p = uigetdir;
        if p
            set(edtSave,'String',p);
        end
    end
    function runClustering()
        fp = get(edtFile,'String');
        kStr = get(edtK,'String');
        ks = str2num(kStr);
        outdir = get(edtSave,'String');
        data = load(fp,'whole_trace_ori');
        X = data.whole_trace_ori;
        for ii = 1:length(ks)
            labels = lmv_total(X,ks(ii), 15, 2000);
            save(fullfile(outdir, sprintf('labels_k%d.mat', ks(ii))), 'labels');
        end
        msgbox('Clustering finished');
    end
end
