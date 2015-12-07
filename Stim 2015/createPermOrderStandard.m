% Generate permutation order
allPerm = nan(length(listCellIDs),numPermutations);
for i = 1:numPermutations
    thisPerm = randperm(length(listCellIDs));
    allPerm(:,i) = thisPerm;
end
listPermSeq = allPerm(:)';