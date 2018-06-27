function [userWK, tauK, ErrorK] = APGUserLFLineSearch(Tr, X, itemW_new, opts, init)

    tau=opts.eta * opts.tauK1;

%     [pX, A] = errorX1(Tr.rating_norm, X, Tr.wMat, init);
    [pX, A] = errorPX(X, itemW_new, Tr.rating_norm, Tr.wMat, init);
    
    W_new =sparse(Tr.wMat(:, 1), Tr.wMat(:,2), A, Tr.usernum, Tr.itemnum);
    subgX = W_new*itemW_new + X*init.itemCorr - init.subgX; 
    
    norm2= norm(subgX, 'fro');
    
    for e = 1 : opts.epoches
        
        Z= X- (1/tau)*subgX; 
        
        Stau=(tau/(tau + opts.lambda))*Z;
                  
%         [Fstau, A1] = errorX1(Tr.rating_norm, Stau,Tr.wMat, init);
        [Fstau, A1] = errorPX(Stau, itemW_new, Tr.rating_norm, Tr.wMat, init);
        
        norm1= norm(Stau-Z, 'fro');
        
        Qstau = 0.5 * tau*norm1^2 - (1/(2*tau)) * norm2^2 + pX;
      
        if  Fstau<=Qstau           
            break;
        else
            tau= min(tau/opts.eta, opts.tau0);
        end
        
%         fprintf('the %g times line search, tau: %g, norm2: %g, delta stau: %g \n', e, tau, norm2^2, (Qstau-Fstau));
    end
    userWK= Stau; tauK=tau; ErrorK=Fstau;
end

function [pX, A] = errorX1(rating_norm, userW, wMat, init)
    B=userW(wMat(:, 1), :); %C= itemW(wMat(:, 2), :);
%     B=quickInx(userW, wMat(:, 1));
    M = sum(bsxfun(@times, B, init.itemWSQE), 2);
    A = bsxfun(@times, wMat(:,3), M);
    pX = rating_norm-sum(A)-sum(M) + 0.5*sum(bsxfun(@times, A, M)) + 0.5*sum(sum(bsxfun(@times, userW*init.itemCorr, userW),1),2);

end

function [pX, A] = errorPX(userW, itemW, rating_norm, wMat, init)
    [error, A] =errorX(userW, itemW, wMat);
    pX=error+ rating_norm+0.5*sum(sum(bsxfun(@times, userW*init.itemCorr, userW),1),2);
end
