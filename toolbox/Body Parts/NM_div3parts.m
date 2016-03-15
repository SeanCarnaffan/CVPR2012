function [ torso, legs, head ] = NM_div3parts( imageData, imageMask, plotBoryParts )
%   NM_DIV3PARTS Extract torso and legs from input figure
%
%   Copyright: Niki Martinel
%   Date: 09/19/2011
%   Return Data: torso and legs body parts
%   Parameters: 1. input image
%               2. image mask
%               3. plot body parts
%
%   [TORSO, LEGS, HEAD] = NM_REID_DIV3PARTS(IMAGEDAT, IMAGEMASK) takes as input 
%   the image to split into three body parts, IMAGGDATA, and the mask of the image,
%   IMAGEMASK.
%   The function produce three output values TORSO, LEGS and HEAD that define 
%   the rectangles into which the input image has been split.
%
%   IMAGEDATA should be a valid image RGB or GRAYSCALE
%
%   IMAGEMASK should be a binary image
%   
%   TORSO, LEGS and HEAD are three output rectangles of size [x y w h]
%

switch nargin
    case 0
        error('argChk:nm_reid_div3parts', 'Wrong number of input parameters (=0)');
    case 1
        error('argChk:nm_reid_div3parts', 'Wrong number of input parameters: no mask specified (=1)');
    case 2
        plotBoryParts = false;
end

%addpath(genpath('../SDALF'));
[H,W,~] = size(imageData);

permit_inds = 1; % dummy value
symmetryPars = struct('val',5,'alpha',0.7);

% Division in 3 parts and kernel map computation
[~, torsoAsymmteryAxis,BUsim,LEGsim, headAsymmteryAxis] = mapkern_div3(imageData,imageMask,permit_inds,symmetryPars,false,false);

% Define torso, legs and head rectangle
head = [1, 1, W, headAsymmteryAxis];
torso = [1, headAsymmteryAxis+1, W, torsoAsymmteryAxis];
legs = [1, torsoAsymmteryAxis+1, W, H];

% Plot body parts if required
if plotBoryParts
    figure, imshow(imageData);
    hold on;
    rectangle('Position', torso, 'EdgeColor', 'r', 'LineWidth',1);
    rectangle('Position', legs, 'EdgeColor', 'g', 'LineWidth',1);
    rectangle('Position', head, 'EdgeColor', 'b', 'LineWidth',1);
    hold off;
end

end

