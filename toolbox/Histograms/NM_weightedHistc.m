function [h] = NM_weightedHistc( inputData, binEdges, weights, excludeRanges)
%NM_WEIGHTEDHISTC Compute the weighted histogram of input data
%
%   Copyright: Niki Martinel
%   Date: 01/13/2012

%% Check input parameters
if nargin < 3
    error('nm_weightedhistc:argChk', 'Wrong number of input parameters (<3)');
elseif nargin == 3
    excludeRanges = [];
end

if ~isequal(size(inputData), size(weights))
    error('INPUTDATA and WEIGHTS must be vectors/matrix of the same size');
end

% Exclude ranges from histogram computation
dataForHistogram = inputData;
[rows, cols] = size(excludeRanges);
for i=1:rows
    dataForHistogram(excludeRanges(i,1)<=dataForHistogram & dataForHistogram<=excludeRanges(i,2)) = -inf;
end
inputData = dataForHistogram;

% Number of edges
Nedge = length(binEdges);

% Empty histogram
h = zeros(Nedge-1,1);

% Loop through all n-1 bin edges
for n=1:Nedge-1
    
    % Find index of input data where its values are inside bin edges
    ind = find(inputData >= binEdges(n) & inputData < binEdges(n+1));
    
    % Non empty matrix/vector
    if ~isempty(ind)
        
        % Add weights to historam
        h(n) = sum(weights(ind));
    end
end

% Select matrix indexes where values are equal to last bin edge 
ind = find(inputData == binEdges(end));
if ~isempty(ind)
    % Add weights into the last bin
    h(Nedge-1) = h(Nedge-1) + sum(weights(ind));
end

end

