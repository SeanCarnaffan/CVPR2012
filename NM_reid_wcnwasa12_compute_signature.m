function [signatures] = NM_reid_wcnwasa12_compute_signature(dataset, pars)
% COMPUTE SIGNATURES
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%

fprintf('Computing signatures...');
t_reid_feature_extraction_all = tic;

% Update width and height of images according to pars.dataset.imageMagFactor value
pars.dataset.imageWidth   = pars.dataset.imageWidth  * pars.dataset.imageMagFactor;
pars.dataset.imageHeight  = pars.dataset.imageHeight * pars.dataset.imageMagFactor;

% Set features parameters
phogPars.bin = pars.phog.bins;
phogPars.angle = pars.phog.angle;
phogPars.levels = pars.phog.levels;
phogPars.roi =  [];
phogPars.evaluateDifferentChannels = true;

% Set SIFT feature parameters
wgchPars.points = pars.sift.points;
wgchPars.displayImage = false;
wgchPars.plotFrame = false;
wgchPars.plotDescriptors = false;
wgchPars.levels = pars.sift.levels;
wgchPars.colorRadius = pars.wgch.radius;
wgchPars.colorMeanAndHist = true;
wgchPars.colorHistBin = pars.wgch.colorHistBin;
if isfield(pars.wgch, 'gaussianKernelSigma')
    wgchPars.gaussianKernelSigma = pars.wgch.gaussianKernelSigma;
end

% Haralick pars
harPars.offsetmat = pars.glcm.offsetmat;
harPars.levels = pars.glcm.grayLevels;
harPars.symmetric = pars.glcm.symmetry;
harPars.computeForEachLevel = pars.haralick.computeForEachLevel;
harPars.meanValues = true;
harPars.type = pars.haralick.type;
if pars.reid.beta == 0
    harPars = [];
end


%% ------------------------------------------------------------------------
% LOAD DATA
signaturesFile = fullfile(pars.settings.outputDataFolder, [pars.settings.outputFilePrefix '_signatures.mat']);
if exist(signaturesFile, 'file')
    load(signaturesFile);
else

    %% --------------------------------------------------------------------
    % IMAGE PRE-PROCESSING
    
    % Squared structuring element used to open/close image
    squaredSE = strel('square', 3);
    
    % Resize all dataset images if mag factor is bigger than one
    if pars.dataset.imageMagFactor > 1
        tmpImages = zeros(pars.dataset.imageHeight, pars.dataset.imageWidth, 3, dataset.count, 'double');
        for i=1:dataset.count
            tmpImages(:,:,:,i) = double(imresize(dataset.images(:,:,:, i), pars.dataset.imageMagFactor))/255;
        end
        dataset.images = tmpImages;
        clear tmpImages;
        
        % Load mask or set mask to be the complete image
        tmpMasks = ones(pars.dataset.imageHeight, pars.dataset.imageWidth, dataset.count, 'double');
        if isfield(pars.reid, 'useMasks') && pars.reid.useMasks
            for i=1:dataset.count
                tmpMasks(:,:,i) = NM_binarization(imresize(dataset.masks(:,:,i),pars.dataset.imageMagFactor), 0.5);
            end
        end
        dataset.masks = tmpMasks;
        clear tmpMasks;
    else
        dataset.images = double(dataset.images)/255;
    end
    
    for i=1:dataset.count
        % Remove possible noise and fill gaps
        dataset.masks(:,:,i) = imfill(dataset.masks(:,:,i), 'holes');
        dataset.masks(:,:,i) = imerode(dataset.masks(:,:,i), squaredSE);
        dataset.masks(:,:,i) = imdilate(dataset.masks(:,:,i), squaredSE);
    end
      
    %% --------------------------------------------------------------------
    % FEATURES EXTRACTION

    % Create waiting bar for feature extraction process
    hWaitingReidExtraction = waitbar(0, 'Please wait while extracting features');
    
    
    %% IMAGE PROCESSING
    maskedImagePHOG = zeros(size(dataset.images(:,:,:,1)));
    maskedImageGLCM = zeros(size(dataset.images(:,:,:,1)));
    maskedImageSIFT = zeros(size(dataset.images(:,:,:,1)));
    maskedImageWGCH = zeros(size(dataset.images(:,:,:,1)));
    
    % Loop through all dataset images to extract features
    for i=1:dataset.count

        % -----------------------------------------------------------------
        %    Main feature extraction part

        % Compute masked and color converted images
        [maskedImagePHOG, maskedImageGLCM, maskedImageSIFT, maskedImageWGCH] = NM_reid_wcnwasa12_images( dataset.images(:,:,:,i), dataset.masks(:,:,i), pars);
        
        % Divide upper and lower body part
        [torso, legs, head] = NM_div3parts( dataset.images(:,:,:,i), dataset.masks(:,:,i) );
        
        % Extract kernel map
        kernelMap = NM_reid_person_kernelmap( dataset.masks(:,:,i), torso, legs, head, pars.wgch.kernelType);
        
        % Extract features
        if i == 1
            [phogFeatures, ~, ~] = NM_reid_wcnwasa12_extractfeatures( maskedImagePHOG, ...
                maskedImageGLCM, maskedImageSIFT, maskedImageWGCH, ...
                dataset.masks(:,:,i), phogPars, wgchPars, harPars, ...
                kernelMap );
            signatures.phogFeatures = zeros(size(phogFeatures,1), size(phogFeatures,2), dataset.count);
        end
        
        [signatures.phogFeatures(:,:,i), signatures.siftFeatures(i), ...
            signatures.haralickFeatures(i)] = NM_reid_wcnwasa12_extractfeatures( maskedImagePHOG,...
            maskedImageGLCM, maskedImageSIFT, maskedImageWGCH, ...
            dataset.masks(:,:,i), phogPars, wgchPars, harPars, ...
            kernelMap, torso, legs );
        
        % Step waiting bar
        waitbar(i/dataset.count, hWaitingReidExtraction);
        
    end %End for dataset.count

    % Close feature extraction waiting bar
    close(hWaitingReidExtraction);

    % Save data
    try
        save(signaturesFile, 'signatures');
    catch ME
        warning('nm_reid_main:saveSignatures', 'Unable to save signatures data on file %s.', signaturesFile)
    end
end

% Features extraction time
fprintf('done in %.2f(s)\n', toc(t_reid_feature_extraction_all));

end
