function [cmv ridx] = cmcDup(cnfmat, idx, dupIdx, gndTruth, nbL )

[ma,ridx] = sort(cnfmat, 2); 
% ma = ma';
% ridx = ridx';
% cnfmat = cnfmat';
ntoc  = size(dupIdx,2);
cmat = zeros(ntoc, nbL);

for i=1:ntoc
    j = idx(i);
    di = dupIdx{i};
    for jj = 1:size(di, 2)
        k = find(ridx(i,:)==di(jj));
        cmat(i,k) = 1;
    end
end

cmat = cmat(:, 2:end);
cmv = sum(cmat);
for i=2:size(cmv,2)
    cmv(i) = cmv(i-1)+cmv(i); 
end
cmv = cmv*100./gndTruth;