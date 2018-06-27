function [itemW, Error]=APGItemLatentFactor(Tr, userWInt, itemWInt, lambda, alpha1, configure_file)

    EXPTYPE='itemapg';
    eval(configure_file);
    
    tauK=itemapg.tau;  tK1=itemapg.t;  
    
    itemWK=itemWInt;  itemWK1= itemWInt;
    CurrError= 0; LastError=0;
    
    % initialization
    init.userCorr = userWInt'*userWInt;
    init.subgX = (Tr.W + Tr.R)'*userWInt;
%     init.userWSQE = userWInt(Tr.wMat(:, 1), :);
    
    for e = 1 : itemapg.epoches
        tK= (1+ sqrt(1 + 4*((tK1)^2)))/2;
        X=itemWK + ((tK1-1)/tK) * (itemWK-itemWK1);
        itemWK1= itemWK; tK1= tK; 
        
        t=cputime;
   
        apgopts.tauK1= tauK;  apgopts.eta= itemapg.eta;  apgopts.tau0=itemapg.tau; 
        apgopts.epoches= 10;  apgopts.lambda = lambda; 
                
        [itemWK, tauK, ErrorK] = APGItemLFLineSearch(Tr, userWInt, X, alpha1, apgopts, init);         
           
        CurrError=ErrorK + 0.5*lambda(1)*(norm(itemWK, 'fro'))^2 + ItemGroupLassoRegError(itemWK, Tr.groupInX, lambda(2));
        
        deltaError=abs(CurrError - LastError)/abs(LastError);
        delta_time=cputime - t;
        
%         fprintf('ItemAPG: epoch %g, CurrError %g, LastError %g, DeltaErr %g, time %g\n', e, CurrError, LastError, deltaError, delta_time);
        
        if deltaError < itemapg.threshold   
            break;
        end
        
        LastError=CurrError;
    end
    
    itemW=itemWK; Error=CurrError;
%     fprintf('complete the learning of item latent factors\n');
end



