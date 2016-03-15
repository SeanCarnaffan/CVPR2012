function [ pointDescriptor, patches ] = NM_colorpoint( image, center, radius, bins, gaussianKernelSigma )
%   NM_COLORPOINT Extract mean of points inside the input circle
%   and mask the input image within the specified circle
%
%   Copyright: Niki Martinel
%   Date: 09/19/2011

% No correct points set as input
if isempty(center)
        
    % Output emtpy descriptor
    pointDescriptor.mean = [];
    pointDescriptor.hist = {};
   
    % End function 
    return;
end

% Round up radius to the nearest integer
radius = round(radius);

% Create point mask
mask = NM_maskrounded(radius, -inf, 1);
patches = repmat(mask, 1, 3);

% Max circular color point size
pad = (max(radius) * 2) + 1;

% padded image
paddedImage = -inf * ones((pad*2) + size(image,1), (pad*2) + size(image,2), 3);
%padarray(image, [maxColorPointSize maxColorPointSize]);
paddedImage(pad+1:pad+size(image,1),pad+1:pad+size(image,2),:) = image; 

% add pad value to center values in order to take into account the new
% padding values that have been added
center = round(center + pad);

% Descriptor
baseStruct = struct(    'mean', zeros(3,1), ...
                        'hist', {cell(3,1)} );
pointDescriptor = repmat(baseStruct, length(radius), 1);


% Compute padded images coordinates
r1 = ceil( center(:,2) - cellfun(@(m)(size(m,2)*0.5), mask));
r2 = floor(center(:,2) + cellfun(@(m)(size(m,2)*0.5), mask));
c1 = ceil( center(:,1) - cellfun(@(m)(size(m,1)*0.5), mask));
c2 = floor(center(:,1) + cellfun(@(m)(size(m,1)*0.5), mask));

% Compute histograms and mean values                     
for i=1:length(radius)

    % Mask each channel rectangle
    patches{i,1} = paddedImage(r1(i):r2(i), c1(i):c2(i), 1) .* mask{i};
    patches{i,2} = paddedImage(r1(i):r2(i), c1(i):c2(i), 2) .* mask{i};
    patches{i,3} = paddedImage(r1(i):r2(i), c1(i):c2(i), 3) .* mask{i};
    
    % Set all non interesting values to -inf
    patches{i,1}(patches{i,1} == inf | patches{i,1} == -inf | isnan(patches{i,1})) = -inf;
    patches{i,2}(patches{i,2} == inf | patches{i,2} == -inf | isnan(patches{i,2})) = -inf;
    patches{i,3}(patches{i,3} == inf | patches{i,3} == -inf | isnan(patches{i,3})) = -inf;
    
    % Calculate the mean value for each image channel
    pointDescriptor(i).mean(:) = mean([ patches{i,1}(patches{i,1}>-inf) ...
                                        patches{i,2}(patches{i,2}>-inf) ...
                                        patches{i,3}(patches{i,3}>-inf) ]);
   
    % Exclude -inf values from histogram evaluation
    pointDescriptor(i).hist{1} = NM_gaussianWeigthedHistogram(patches{i,1}, bins{1}, gaussianKernelSigma);
    pointDescriptor(i).hist{2} = NM_gaussianWeigthedHistogram(patches{i,2}, bins{2}, gaussianKernelSigma);
    pointDescriptor(i).hist{3} = NM_gaussianWeigthedHistogram(patches{i,3}, bins{3}, gaussianKernelSigma);
    
end

end

