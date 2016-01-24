% Generate permutation order
allPerm = nan(length(roiGroups),numPermutations);
for i = 1:numPermutations
    thisPerm = randperm(length(roiGroups));
    allPerm(:,i) = thisPerm;
end
listPermSeq = allPerm(:)';