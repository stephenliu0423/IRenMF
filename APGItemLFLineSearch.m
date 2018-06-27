function [itemWK, tauK, ErrorK] = APGItemLFLineSearch(Tr, userWInt, X, alpha1, opts, init)

    tau=opts.eta * opts.tauK1;
    
    itemW_new=alpha1*X + (1-alpha1)*Tr.CorrM*X;
%     [pX, deltaR]=ErrorComputingPV(checkinM, W, userWInt, itemW_new);
%     subgX=SubGradientLF(W, deltaR, userWInt, itemW_new, CorrM, alpha1, 'itemlf');

%     [pX, A] = errorX1(Tr.rating_norm, itemW_new, Tr.wMat, init);
    [pX, A] = errorPX(userWInt, itemW_new, Tr.rating_norm, Tr.wMat, init);
    
    W_new =sparse(Tr.wMat(:, 1), Tr.wMat(:,2), A, Tr.usernum, Tr.itemnum);
    
    M = W_new'*userWInt + itemW_new*init.userCorr - init.subgX;
    subgX = alpha1*M + (1-alpha1)*Tr.CorrM'*M;
    
    norm2= norm(subgX, 'fro');
    
    for e = 1 : opts.epoches
        
        Z= X- (1/tau)*subgX; 
        
        %group structured latent factor model
        Stau=ItemProxyOperator(Z, Tr.groupInX, opts.lambda, tau); 
        itemW_new1=alpha1*Stau + (1-alpha1)*Tr.CorrM*Stau;
        
%         Fstau=ErrorComputingPV(checkinM, W, userWInt,itemW_new1);
%         [Fstau, A] = errorX1(Tr.rating_norm, itemW_new1, Tr.wMat, init);
        [Fstau, A] = errorPX(userWInt, itemW_new1, Tr.rating_norm, Tr.wMat, init);
        
        norm1= norm(Stau-Z, 'fro');
        
        Qstau = 0.5 * tau*norm1^2 - (1/(2*tau)) * norm2^2 + pX;
        
        if Fstau <= Qstau
%             tauK=tau;            
            break;
        else
            tau= min(tau/opts.eta, opts.tau0);
%             tau=tau/opts.eta;
        end
        
%         fprintf('the %g times line search, tau: %g, norm2: %g, delta Stau: %g\n', e, tau, norm2^2, (Qstau-Fstau));
    end
    itemWK= Stau;    tauK=tau;  ErrorK=Fstau;   
end

function [pX, A] = errorX1(rating_norm, itemW, wSQE, init)
%     B=quickInx(itemW, wSQE(:, 2));
    M = sum(bsxfun(@times, init.userWSQE, itemW(wSQE(:, 2), :)), 2);
    A = bsxfun(@times, wSQE(:,3), M);
    pX = rating_norm-sum(A)-sum(M) + 0.5*sum(bsxfun(@times, A, M)) + 0.5*sum(sum(bsxfun(@times, itemW*init.userCorr, itemW),1),2);
end

function [pX, A] = errorPX(userW, itemW, rating_norm, wMat, init)
    [error, A] =errorX(userW, itemW, wMat);
    pX=error+ rating_norm+0.5*sum(sum(bsxfun(@times, itemW*init.userCorr, itemW),1),2);
end