function [ iamgeData ] = NM_channels2image( c1, c2, c3 )
%
%   NM_CHANNELS2IMAGE Forma image from input channels
%
%   Copyright: Niki Martinel
%   Date: 08/25/2011
%   Return Data: return image from separate image channels
%   Parameters: 1. Input channel
%               2. Input channel
%               3. Input channel
%

%% Form image from channel data
iamgeData = cat(3,c1,c2,c3);
    
end

