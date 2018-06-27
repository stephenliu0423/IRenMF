function groupInX=getGroupInx(clusterInx)
    [val, index]=sort(clusterInx(:, 2), 'ascend');
    
    InX=clusterInx(index, :);
     
    sorted_label= sort(unique(clusterInx(:,2)));
    K=length(sorted_label);  InXStat=[];
    
    [m, n]=hist(clusterInx(:,2), sorted_label);   
    
    ind=0;
    for i = 1 : K
        InXStat=[InXStat, [(ind + 1), (ind + m(i)), sqrt(m(i))]'];
        ind = ind + m(i);    
    end        
    groupInX=struct('InX', InX, 'InXStat', InXStat); 

end