function [ c1,c2,c3 ] = NM_image2channels( imageData )
%
%   NM_IMAGE2CHANNELS Extract image channels
%
%   Copyright: Niki Martinel
%   Date: 07/01/2011
%   Return Data: return image separate image channels
%   Parameters: 1. Image data to analyse
%

%% Extract channels from image data

% Check image channels
[r,c,n,l] = size(imageData);
c1 = zeros(size(imageData,1), size(imageData, 2), l);
c2 = zeros(size(imageData,1), size(imageData, 2), l);
c3 = zeros(size(imageData,1), size(imageData, 2), l);

% Operation are allowed if image has 3 separate channels
if n == 3
    for i=1:l
        c1 = imageData(:,:,1, i);
        c2 = imageData(:,:,2, i);
        c3 = imageData(:,:,3, i);
    end
end
    
end

