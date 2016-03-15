function [pars] = NM_reid_wcnwasa12_init_parameters(datasetName, testID, reidType, reidNumImages)
%% INITIALIZE PARAMETERS
%   Copyright: Niki Martinel
%   Date: 09/07/2011

switch nargin
    case 1
        testID = '001';
        reidType = 'Svs';
        reidNumImages = 1;
    case 2
        reidType = 'Svs';
        reidNumImages = 1;
    case 3
        reidNumImages = 1;
end

%% Dataset parameters
pars.dataset.name = datasetName;
pars.dataset.imageWidth         = 64;
pars.dataset.imageHeight        = 128;
pars.dataset.imageMagFactor     = 1;
pars.dataset.useMasks = true;       

%% Phog paramters
pars.phog.levels  = 4;  
pars.phog.bins    = 9;
pars.phog.angle   = 180;
pars.phog.channelWeights = [0.2 0.3 0.5];

%% GLCM/Haralick parameters
pars.glcm.offsetmat = [0 1; -1 1; -1 0; -1 -1];
pars.glcm.grayLevels = 64;    
pars.glcm.symmetry = true;
pars.haralick.computeForEachLevel = false;
pars.haralick.channelWeights = 1;
pars.haralick.type = 'bp';

%% Sift paramters
pars.sift.points  = '';
pars.sift.levels  = 7;

%% WGCH parameters
pars.wgch.radius  = (pars.dataset.imageWidth*pars.dataset.imageMagFactor)/4;
pars.wgch.kernelType = 'mahal';
pars.wgch.gaussianKernelSigma = pars.wgch.radius/3;
pars.wgch.histBins = [16 10 4];
pars.wgch.histComponentsWeigths = [0.5 0.3 0.2];
pars.wgch.colorHistBin{1} = 0:(360/pars.wgch.histBins(1)):360;
pars.wgch.colorHistBin{2} = 0:(1/pars.wgch.histBins(2)):1;
pars.wgch.colorHistBin{3} = 0:(1/pars.wgch.histBins(3)):1;

pars.reid.alpha   = 0.4;
pars.reid.beta    = 0.1;
pars.reid.gamma   = 1-(pars.reid.alpha+pars.reid.beta);

pars.reid.type = reidType;                % Possible values: SvsS, MvsS, MvsM
pars.reid.signatureImagesCount  = reidNumImages;
pars.reid.testPersonIDs = [];

%% Other settings

% testCams is used only in case the camera ID is specified in the dataset
% e.g. ars.settings.testCams = [1 2; 1 3; 2 3];
%pars.settings.testCams = [];
pars.settings.testCams = [1 2; 1 3; 2 3];
pars.settings.testID = testID;

% Output file on which save test data
rootFolder = fileparts(which(mfilename));
pars.settings.outputDataFolder = fullfile(rootFolder, 'data');
pars.settings.outputFilePrefix = [pars.dataset.name, '_', pars.reid.type, '_I', num2str(pars.reid.signatureImagesCount), '_Id', pars.settings.testID];


end
