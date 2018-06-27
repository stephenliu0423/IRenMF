% construct the weighting matrix
function [R, W, wMat]= checkinMandWeightingMatrix(Tr, configure_file)
    
    EXPTYPE='checkin_weighting';   
    eval(configure_file);
    
    %-------------------- print parameters to the file --------------------%
    fid=fopen([datafolder,configure_file,'_Results.txt'], 'a+');   
    fprintf(fid, 'weighting alpha:%g, ', weighting.alpha);
    fclose(fid);
    
    users=Tr.users; items=Tr.items; times=Tr.times; 
    user_num=length(unique(users));
    item_num=length(unique(items));
    
    % construct the preference matrix
    value= ones(length(users), 1);
        
    R= sparse(users, items, value, user_num, item_num);
    
    Weights=weighting.alpha*times;
    W=sparse(users, items, Weights, user_num, item_num);
    wMat = [users, items, Weights];

end
