function Stau=ItemProxyOperator(Z, groupInx, lambda, tau)
    % lambda: regularizer for U
    [m, n]= size(Z);  
    Stau=zeros(m, n);
%     Stau=sparse(m, n); % needs some modifications?
    
    InX=groupInx.InX;  InXStat=groupInx.InXStat;
    
    group_num=size(InXStat, 2);
    
    for d =1 : n         
        
        for g= 1 : group_num
%             Zgd=Z(groupInx(1, g): groupInx(2, g), d);              
            subInX=InX(InXStat(1, g) : InXStat(2, g), 1);
           
            Zgd=Z(subInX, d);  omega=InXStat(3, g);
            
            l2norm=norm(Zgd, 2);  theta= lambda(2)*omega/tau; %theta= lambda(2)*groupInx(3, g)/tau;

            if l2norm > (theta)
%                 Stau(groupInx(1, g): groupInx(2, g), d)= ((l2norm - theta)/(l2norm * (1 + lambda(1)/tau)))*Zgd;
                 Stau(subInX, d)= ((l2norm - theta)/(l2norm * (1 + lambda(1)/tau)))*Zgd;
            else
%                 Stau(groupInx(1, g): groupInx(2, g), d)=zeros((groupInx(2, g) - groupInx(1, g) + 1), 1);
%                 Stau(InX, d)=zeros((groupInx(2, g) - groupInx(1, g) + 1), 1);
                Stau(subInX, d)=zeros(length(Zgd), 1);
            end              

        end
    end
end