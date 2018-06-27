%% Location Group LASSO
function ItemGroupPOI(configure_file)

    addpath(genpath('spectral_clustering/')); % the folder of spectral clustering algorithm
    t0=cputime;
    
    for i = 1 : 1
        EXPTYPE='global';     
        eval(configure_file); % load the configure parameters    

        %-------------data preparation ------------------%   
        [Tr, Te]=dataPreparation(configure_file);  
        fprintf('complete the data preparation\n');

        %-------------data sampling ------------------% 
        [Tr.R, Tr.W, Tr.wMat]= checkinMandWeightingMatrix(Tr, configure_file);
        fprintf('complete constructing the checkin and weighting matrices\n');

        %--------------learn the model parameters ------------------%            
        [userW, itemW]= locationGSSLFM(Tr, configure_file);    
        
        %--------------Evaluate the model performance ------------------%  
        topN_recommendation(Tr, Te, userW, itemW, configure_file);
    end
    
    t=cputime-t0;
    
    %fprintf('total time used: %g\n', t);
    
end
    
