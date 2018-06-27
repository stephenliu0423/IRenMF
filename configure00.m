%%%%%% Global configuration file  %%%%%%
%%% Holds all the parameters used in all parts of the code, enable the
%%% exact reproduction of the experiement at some future date.
    
    
global datasetfolder datafolder dataset_name geo_alpha

switch lower(EXPTYPE)
    case 'global'                       
        datasetfolder='datasets/';   
        datafolder='output/';
        addpath('common/');
        % dataset_name='BerlinSubCheckins_random_0.7';
        dataset_name='Gowalla';
        geo_alpha=0.6; % the geographical influence parameter

        if ~exist(datafolder, 'dir')
            mkdir(datafolder);
        end

    case 'dataprepare'
        num_cluster=100;            
        geoNN_Num=10;
        clusterflag='kmeans'; % 'kmeans' for kmeans clustering
                                % 'spectral' for spectral clustering

    case 'checkin_weighting'
        weighting.alpha=10;    

    %-------------------------- model parameters ----------------------%            
    case 'gsslfm'              
        gsslfm.num_factors=200;
        gsslfm.epoches=150;
        gsslfm.lambda=[0.015, 0.015, 1];        % regularization term for group lasso    
        gsslfm.threshold=1e-5;

    %-------------------------- user latent factor parameters ----------------------%
    case 'userapg'
        userapg.epoches=70;
        userapg.tau=1e6;
        userapg.t=1;
        userapg.eta=0.7;
        userapg.threshold=1e-5;

    %-------------------------- item latent factor parameters ----------------------%
    case 'itemapg'
        itemapg.epoches=70;
        itemapg.tau=1e7;
        itemapg.t=1;
        itemapg.eta=0.7;
        itemapg.threshold=1e-5;

    case 'model_eval'
        N=[10];

end

