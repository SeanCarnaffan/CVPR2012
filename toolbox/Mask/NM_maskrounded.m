function [ mask ] = NM_maskrounded( radius, outsideValue, insideValue )
%   NM_MASKROUNDED Create cicular binary masks
%
%   Copyright:  Niki Martinel
%   Date:       09/20/2011
%   Return Data: Create circular binary mask
%   Parameters: 1. mask radius
%               2. Value of points outside the mask
%               3. Value of points that lay inside the mask
%
%   [ MASK ] = NM_MASKROUNDED( RADIUS, OUTSIDEVALUE, INSIDEVALUE)
%   takes as input the mask RADIUS; OUTSIDEVALUE is the value of the
%   points that lay outside the binary mask. The parameter INSIDEVALUE,
%   instead, is the value of the points that lay inside the mask
%
%   RADIUS should be valid non-negative vector of size mx1
%
%   OUTSIDEVALUE and INSIDEVALUE should be valid integer vectors of size
%   mx1
%
%   OUT is a circle shape binary mask
%

% check input paramters
switch nargin
    case 0
        error('arg_check:nm_maskrounded', 'Error: invalid number of input paramters');
    case 1
        outsideValue = -100;
        insideValue = 1;
    case 2
        insideValue = 1;
end

% Create mask cell array
mask = cell(length(radius), 1);

% Round radius values
radius = round(radius);

% Loop through all radius values
for i=1:length(radius)
    
    % Create mask
    tmpMask = insideValue * double(getnhood(strel('disk', radius(i), 0)));
    tmpMask(tmpMask==0) = outsideValue;
    mask{i} = tmpMask;
    
end

end


