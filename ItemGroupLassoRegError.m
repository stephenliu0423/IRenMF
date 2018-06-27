function regError=ItemGroupLassoRegError(itemW, groupInx, lambda)
    InX=groupInx.InX;  InXStat=groupInx.InXStat;

    group_num=size(InXStat, 2);
    
    dimensions= size(itemW, 2); regError=0;
    
    for d= 1 : dimensions
        for g =1 : group_num
%             fprintf('%g, %g, %g, %g\n', groupInx(1, g), groupInx(2, g), g, d);
%             InX=(groupInx(:,2)==clusters(g)); 
            subInX=InX(InXStat(1, g) : InXStat(2, g), 1);
            
%             subvec=itemW(groupInx(1, g) : groupInx(2, g), d);
            subvec=itemW(subInX, d); omega=InXStat(3, g);
            
            regError= regError + omega* norm(subvec, 2);
        end
    end
    regError= regError * lambda;
    
end