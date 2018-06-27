clc;
clear;

clusternum=10;
addpath([pwd, '\files\']);

similarity=dlmread('..\POISimilarity.txt');
poi_num=max(similarity(:, 1));

fprintf('constructing the weighting affinity matrix\n');
M=sparse(similarity(:, 1), similarity(:, 2), similarity(:, 3)+0.001, poi_num, poi_num);
M=0.5*(M+M'+abs(M-M'));

fprintf('begin the spectral clustering\n');
[IDX, L, U] = SpectralClustering(M, clusternum, 3);

Coords=dlmread('..\POICoords.txt'); data=[Coords, IDX];
dlmwrite('..\POICluster.txt', [Coords, IDX], 'delimiter', ' ', 'precision', 10);

% for i = 1 : clusternum
%     inx=(IDX==i); subdata=data(inx, :);
%     dlmwrite(['..\clusters\Cluster_', num2str(i), '.txt'], subdata, 'delimiter', ' ', 'precision', 10);
% end
