function [ h ] = NM_gaussianWeigthedHistogram(inputData, binEdges, sigma, excludeRanges )
%NM_GAUSSIANWEIGTHEDHISTOGRAM Compute the gaussian weighted histogram of input data
%
%   Copyright: Niki Martinel
%   Date: 01/13/2012

%% Check input parameters
if nargin < 3
    error('nm_weightedhistc:argChk', 'Wrong number of input parameters (<3)');
elseif nargin == 3
    excludeRanges = [];
end

% Create gaussian kernel same size of input data with SIGMA and MU
% values and compute gaussian weighted histogram
h = NM_weightedHistc(inputData, binEdges, fspecial('gaussian', size(inputData), sigma), excludeRanges);


end

