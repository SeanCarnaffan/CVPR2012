function [ phogFeatures, siftFeatures, haralickFeatures ] = NM_reid_wcnwasa12_extractfeatures( imagePHOG, imageGLCM, imageSIFT, ...
    imageWGCH, imageMask, phogPars, siftPars, glcmPars, ...
    kernelMap, torso, legs )
% EXTRACT FEATURES
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%


%% Extract PHOG features
phogFeatures = NM_extractFeatures(imagePHOG, 'phog', phogPars);

%% Extract SIFT feature points

%Update SIFT paramters: set sift image on which perform color extraction
siftPars.imageForColorExtraction = imageWGCH;

% Perform SIFT feature detection
siftFeatures = NM_extractFeatures(imageSIFT, 'sift', siftPars);

% Reject SIFT points that line outside the image mask
% if image mask at point [frameKeypoints(1,i), frameKeypoints(2,i)] is
% equal or less than 0
frameKeypointsRounded = round( siftFeatures.frameKeypoints(1:2,:)' );
idx = sub2ind(size(imageMask), frameKeypointsRounded(:,2), frameKeypointsRounded(:,1));
rejectedSiftIndexes = find( imageMask(idx) <= 0 );

% Remove rejected sift frame
if ~isempty( rejectedSiftIndexes ) 
    siftFeatures.frameKeypoints(:,rejectedSiftIndexes) = [];
    siftFeatures.descriptors(:,rejectedSiftIndexes) = [];
    siftFeatures.colorDescriptor(:,rejectedSiftIndexes) = [];
end

% Take the max mahalnobis distance and use it to weight features
% reliability
frameKeypointsRounded = fliplr( round( siftFeatures.frameKeypoints(1:2,:)' ) );
[~,loc] = ismember(frameKeypointsRounded, kernelMap.coordinates, 'rows');
siftFeatures.weight = kernelMap.weights( loc )';

% Assign body part location to each sift keypoint
if nargin == 11
    frameKeypointsRounded = siftFeatures.frameKeypoints(1:2, :)';
    torso = double([torso(1, [1 3 3 1 1]); torso(1, [2 2 4 4 2])]);
    legs  = double([legs(1, [1 3 3 1 1]);  legs(1, [2 2 4 4 2])]);

    siftFeatures.intorso = NM_inregion( frameKeypointsRounded', torso);
    siftFeatures.inlegs  = NM_inregion( frameKeypointsRounded', legs);
end

%% GLCM Features
haralickFeatures.haralick = [];
if ~isempty(glcmPars)
    if nargin == 11
        if isempty(haralickFeatures.haralick)>0
            tmp = NM_extractFeatures(imageGLCM, 'haralick', glcmPars);
            haralickFeatures.haralick = repmat(tmp, 1, 2); 
            clear tmp;
        end
        haralickFeatures.haralick(:,1) = NM_extractFeatures(imageGLCM(torso(2,1):torso(2,3),torso(1,1):torso(1,2),:), 'haralick', glcmPars);
        haralickFeatures.haralick(:,2) = NM_extractFeatures(imageGLCM(legs(2,1):legs(2,3),legs(1,1):legs(1,2),:), 'haralick', glcmPars);
    end
end

end


