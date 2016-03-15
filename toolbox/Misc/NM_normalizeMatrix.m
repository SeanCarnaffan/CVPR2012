function [ normalizedMat ] = NM_normalizeMatrix( mat )
%NM_NORMALIZEMATRIX Normalize matrix values into 0-1 range

normalizedMat = (mat - min(mat(:)) + realmin) ./ (max(mat(:))-min(mat(:)));

end

