function [Tr, Te]=dataPreparation(configure_file)
    
    EXPTYPE='dataprepare';
    eval(configure_file);
        
    %-------------------- print parameters to the file --------------------%
    fid=fopen([datafolder,configure_file,'_Results.txt'], 'a+');   
    fprintf(fid, 'dataset: %s, clusterflag: %s\n', dataset_name, clusterflag);
    fclose(fid);
      
    %-------------------------data files--------------------%
    trainingfile=[datasetfolder, dataset_name, '_training.txt'];
    testingfile=[datasetfolder, dataset_name, '_testing.txt'];
    POIfile=[datasetfolder, dataset_name, '_POICoords.txt'];    

    pidNNfile=[datasetfolder, dataset_name, '_GeoNN.txt'];  
   
    trainingdata=dlmread(trainingfile);
    Tr.users = trainingdata(:,1); Tr.items = trainingdata(:,2); Tr.times = trainingdata(:,3);
    
    testingdata=dlmread(testingfile);
    Te.users = testingdata(:,1); Te.items = testingdata(:,2); Te.times = testingdata(:,3);
    
    pidNN=dlmread(pidNNfile);

    POIdata=dlmread(POIfile);
    [val, index]=sort(POIdata(:, 1));
    POIdata=POIdata(index, :);
    
    Tr.CorrM=geographicalCorr(POIdata, pidNN, geoNN_Num);
    
    % Geographical groups
%     clusterInx=geographicalGroup(POIdata, gridpara, grid_flag); 

    %--------------Geo-kmeans (Matlab)----------------------------------%
    if strcmp(clusterflag, 'kmeans')
        cluster_file=[datasetfolder, dataset_name, '_', num2str(num_cluster), '_clusters.mat'];
        if ~exist(cluster_file, 'file')
            [IDX, C]=kmeans(POIdata(:, 2:3), num_cluster);
            clusterInx=[POIdata(:, 1), IDX];
            save(cluster_file, 'clusterInx')
        else
            load(cluster_file, '-mat');
        end
    elseif strcmp(clusterflag, 'spectral')
        cluster_file=[datasetfolder, dataset_name, '_', num2str(num_cluster), '_spectral_clusters.mat'];
        if ~exist(cluster_file, 'file')
            IDX=PoiSpectralClustering(trainingdata, pidNN, 15, num_cluster);
            clusterInx=[POIdata(:, 1), IDX];
            save(cluster_file, 'clusterInx');
        else
            load(cluster_file, '-mat');
        end
    elseif strcmp(clusterflag, 'kmeans_history')
        cluster_file=[datasetfolder, dataset_name, '_', num2str(num_cluster), '_kmeans_history.mat'];
        if ~exist(cluster_file, 'file')
            IDX=PoiHistoryKmeans(trainingdata, num_cluster);
            clusterInx=[POIdata(:, 1), IDX];
            save(cluster_file, 'clusterInx');
        else
            load(cluster_file, '-mat');
        end
    end
        
    Tr.groupInX=getGroupInx(clusterInx);
 
%     Tr= struct ('users', trainingdata(:, 1), 'items', trainingdata(:,2), 'times', trainingdata(:,3));
%     Te= struct ('users', testingdata(:, 1), 'items', testingdata(:,2), 'times', testingdata(:,3));
   
end

function CorrM=geographicalCorr(POICoords, geoNN_InX, geoNN_Num)
    Corr=[]; [m, n]=size(geoNN_InX);
    
    for i = 1 : m
        geoSim=L2_distance(POICoords(geoNN_InX(i, 1), 2:3)', POICoords(geoNN_InX(i, 2: geoNN_Num+1), 2:3)'); % may need some modification
        geoSim=exp(-10*geoSim);
        temp=[ones(geoNN_Num, 1)*geoNN_InX(i, 1), geoNN_InX(i, 2: (geoNN_Num+1))', geoSim'/sum(geoSim)];
        Corr=[Corr; temp];
    end

    CorrM=sparse(Corr(:, 1), Corr(:, 2), Corr(:, 3), m, m);    

end

function CorrM=pidCorrelation(pidNN)
    pids=unique(pidNN(:, 1)); m=length(pids); data=pidNN;
    for i= 1 : m
        index=(pidNN(:, 1)==pids(i));
        data(index, 3)=exp(data(index, 3))/sum(exp(data(index, 3)));
    end
    
    CorrM=sparse(data(:, 1), data(:, 2), data(:, 3), m, m);

end

function IDX=PoiSpectralClustering(trainingdata, pidNN, geoNN_Num, num_cluster)
    M=sparse(trainingdata(:, 1), trainingdata(:, 2), ones(1, length(trainingdata(:,1))), max(trainingdata(:, 1)), max(trainingdata(:, 2)));
    itemnum=max(pidNN(:, 1)); Similarity=[];
    
    for i = 1 : itemnum
        distance= full(slmetric_pw(M(:,i), M(:, pidNN(i, 2 : geoNN_Num+1)), 'nrmcorr'));
        Similarity=[Similarity; [i*ones(geoNN_Num, 1), pidNN(i, 2 : geoNN_Num+1)', distance']];
    end
    SimM=sparse(Similarity(:, 1), Similarity(:, 2), Similarity(:, 3)+0.001, itemnum, itemnum);
    SimM=0.5*(SimM+ SimM'+abs(SimM-SimM'));

    fprintf('begin the spectral clustering\n');
    [IDX, L, U] = SpectralClustering(SimM, num_cluster, 3);

end

function IDX=PoiHistoryKmeans(trainingdata, num_cluster)
    M=sparse(trainingdata(:, 1), trainingdata(:, 2), ones(1, length(trainingdata(:,1))), max(trainingdata(:, 1)), max(trainingdata(:, 2)));
%     IDX=kmeans(M', num_cluster);
    
    cluster_options.maxiters= 200;
    cluster_options.verbose =1;
    [CX, sse] = vgg_kmeans(full(M), num_cluster, cluster_options);
    L2D=L2_distance(M, CX);
    [minD, tempToken]=min(L2D');
    IDX = tempToken';
    
end
