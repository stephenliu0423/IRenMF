function [userW, itemW]= locationGSSLFM(Tr, configure_file)
    
    EXPTYPE='gsslfm';
    eval(configure_file);
    
    fid=fopen([datafolder,configure_file,'_Results.txt'], 'a+');   
    fprintf(fid, 'num_factors:%g, lambda:%g %g %g, ', gsslfm.num_factors, gsslfm.lambda(1),gsslfm.lambda(2), gsslfm.lambda(3));
    fclose(fid);
    
%     global rating_norm
    Tr.rating_norm=0.5*(norm(bsxfun(@times, sqrt(Tr.W), Tr.R), 'fro')^2 + norm(Tr.R, 'fro')^2);
    
    % initialize the user and item latent factors
    Tr.usernum=length(unique(Tr.users));
    Tr.itemnum=length(unique(Tr.items));
    
    userW=sqrt(1/gsslfm.num_factors)*rand(Tr.usernum, gsslfm.num_factors+2);  
    itemW=sqrt(1/gsslfm.num_factors)*rand(Tr.itemnum, gsslfm.num_factors+2); 
    userW(:, 1)=1; itemW(:, end)=1;
    
    CurrError= 0; LastError=0;
    
    for e = 1 : gsslfm.epoches 
        
        % ---------------updating the latent factors of users --------%
        tic;
        userW= APGUserLatentFactor(Tr, userW, itemW, gsslfm.lambda(1), geo_alpha, configure_file);
        
        % ---------------updating the latent factors of items --------%
        
        [itemW, error]= APGItemLatentFactor(Tr, userW, itemW, gsslfm.lambda(2:3), geo_alpha, configure_file);  
               
        CurrError=error+0.5* gsslfm.lambda(1)* norm(userW, 'fro')^2;
        
        t=toc;
        
        deltaError=(CurrError - LastError)/abs(LastError);
        fprintf('Epoch %g, CurrError %g, LastError %g, DeltaErr %g, Time: %g\n', e, CurrError, LastError, deltaError, t);
        
        if abs(deltaError) < gsslfm.threshold            
            break;
        end
        
        LastError=CurrError;        
    end
    
    fprintf('complete the learning of the model parameters\n');
        
    %--------------- the sparsity of latent factors of item------------------------%
    density=nnz(itemW)/numel(itemW);    
    fid=fopen([datafolder,configure_file,'_Results.txt'], 'a+');   
    fprintf(fid, 'item latent factors density:%g\n', density);
    fclose(fid);
    fprintf('item latent factors density:%g\n', density);
end

