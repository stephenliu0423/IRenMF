function topN_recommendation(Tr, Te, userW, itemW, configure_file)
    EXPTYPE='model_eval';   
    eval(configure_file); 
    
    precision=zeros(1, length(N));
    recall=zeros(1, length(N));
    
    TrUsers=unique(Tr.users); TrItems=unique(Tr.items);
    TeUsers=unique(Te.users); TeItems=unique(Te.items);
    user_num=length(TeUsers);  item_num=length(TeItems);
    fprintf('There are %g users and %g items in the testing data\n', user_num, item_num);

    CorrUsers=intersect(TrUsers, TeUsers);  % users exisits in training data and testing data simultaneously
    
    % write the debug file 
%     fid=fopen([datafolder,dataset_name,'_debugfile.txt'], 'w');
    fout=fopen('./output/cikm_14_100.txt', 'w');
    for i = 1 : length(CorrUsers)
        user_id= CorrUsers(i);
%         Val=userW(user_id, :)* itemW'* CorrM';
        preRatings=userW(user_id, :)* itemW';        
        Val=geo_alpha*preRatings + (1-geo_alpha)*preRatings*Tr.CorrM'; clear preRatings;
        
        index=(Te.users==user_id);
        
        % needs some modification? 
        % this may affect the computation of recall
        CorrItems=[Te.items(index),Te.times(index)]; 
%         CorrItems=intersect(TrItems, Te.items(index)); 
        
        index=(Tr.users==user_id);
        IgnoreItems=unique(Tr.items(index));
        MissItems=setdiff(TrItems, IgnoreItems);
        
        [pre_val, rec_val, topK]=precisionAndRecallAtN(Val, CorrItems(:, 1), MissItems, N, user_id, fout);
        precision= precision+ pre_val;
        recall= recall + rec_val;
%         fprintf('User ID:%d\n', user_id);
%         fprintf('Visited locations:\n');
%         for k=1:length(IgnoreItems)
%             fprintf('%d ',IgnoreItems(k));
%         end
%         fprintf('\nRecomended locations:\n');
%         for k=1:5
%             fprintf('%d ', topK(k));
%         end
%         fprintf('\n\n');
    end
    fclose(fout);
    
    precision=precision/length(CorrUsers);
    recall=recall/length(CorrUsers);
    
    fprintf('the evaluation results is as follows:\n');
    
    for j = 1 : length(N)
        fprintf('P@%d: %g, R@%d: %g\n', N(j), precision(j), N(j), recall(j));
    end
    
    fid=fopen([datafolder,configure_file,'_Results.txt'], 'a+');
    for j = 1 : length(N)
        fprintf(fid, 'P@%d: %g ', N(j), precision(j));
    end
    for j = 1 : length(N)
        fprintf(fid, 'R@%d: %g ', N(j), recall(j));
    end
    fprintf(fid, '\n\n');
    fclose(fid);
end

%% calculate the precision and recall
function [precision, recall, topK]= precisionAndRecallAtN(Val, CorrItems, MissItems, N, user_id, fout)
    precision=zeros(1, length(N));
    recall=zeros(1, length(N));
%     missingEntr= setdiff(Items, IgnoreItems);
    
    [rankedVal, rankIndex]=sort(Val(MissItems), 2, 'descend');
    
    for i=1 : length(N)
        predictedItems=MissItems(rankIndex(1 : N(i)));
        fprintf(fout, '%d', user_id);
        fprintf(fout, ' %d', predictedItems(1));
        fprintf(fout, ',%d', predictedItems(2:N(i)));
        fprintf(fout, '\n');
        precision(i)=length(intersect(predictedItems, CorrItems))/N(i);
        recall(i)=length(intersect(predictedItems, CorrItems))/length(CorrItems);
    end
    
    topK=[MissItems(rankIndex(1 : max(N))), rankedVal(1 : max(N))'];
end