function userW=APGUserLatentFactor(Tr, userWInt, itemWInt, lambda, alpha1, configure_file)   

    EXPTYPE='userapg';
    eval(configure_file);
    
    tauK=userapg.tau;  tK1=userapg.t;  
    
    userWK=userWInt;  userWK1= userWInt;
    CurrError= 0; LastError=0;
    
    %initialization
    itemW_new=alpha1*itemWInt + (1-alpha1)*Tr.CorrM*itemWInt;
    init.itemCorr = itemW_new'*itemW_new;
    init.subgX=Tr.W*itemW_new + Tr.R*itemW_new;
%     init.itemWSQE = itemW_new(Tr.wMat(:,2),:);
    
    for e = 1 : userapg.epoches
        tK= (1+ sqrt(1 + 4*((tK1)^2)))/2;
        X=userWK + ((tK1-1)/tK) * (userWK-userWK1);
        userWK1= userWK; tK1= tK; 
        
        t=cputime;
        
        apgopts.tauK1= tauK;  apgopts.eta= userapg.eta;  apgopts.tau0=userapg.tau; 
        apgopts.epoches= 10;  apgopts.lambda = lambda;  
        
        [userWK, tauK, ErrorK] = APGUserLFLineSearch(Tr, X, itemW_new, apgopts, init);        
        CurrError=ErrorK+0.5* lambda * norm(userWK, 'fro')^2;
        
        delta_time=cputime - t;
        
        deltaError=abs(CurrError - LastError)/abs(LastError);
%         fprintf('UserAPG: epoch %g, CurrError %g, LastError %g, DeltaErr %g, time %g\n', e, CurrError, LastError, deltaError, delta_time);
        
        if deltaError < userapg.threshold          
            break;
        end
        
        LastError=CurrError;
    end
    userW=userWK;
%     fprintf('complete the learning of user latent factors\n');
end



