function [ dataset, timeToLoad ] = NM_loaddataset( datasetName, ...
    imageFileExtension, varargin )
%NM_LOADDATASET Load a specific dataset
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%
t_load_dataset = tic;

% Parse inputs
p = inputParser;

% optional pars and default values
p.addOptional('imageHeight', []);
p.addOptional('imageWidth', []);
p.addOptional('avoidImagesAtIndexes', []);
p.addOptional('showLoadingBar', true );
p.addOptional('loadMasks', true);
p.addOptional('loadCams', false);

p.parse(varargin{:});
pars = p.Results;


%% Base configuration choices

% Retrieve the dataset path
baseDatasetsPath  = NM_datasetroot; 

% Try to load preloaded dataset if valid

% Dataset directory
datasetPath = fullfile(baseDatasetsPath, datasetName);

% Dataset image list
datasetImageList = dir(strcat(datasetPath, strcat(filesep, '*.', imageFileExtension)));

% Exclude background images..
tmpCell = struct2cell(datasetImageList);
tmpCell(2:end,:) = [];
bgPos = cell2mat(cellfun(@(x)(~isempty(strfind(x, '_bg'))), tmpCell, 'UniformOutput', false));
pars.avoidImagesAtIndexes = [pars.avoidImagesAtIndexes find(bgPos>0)];

% Total number of dataset images
nDatasetImages = size(datasetImageList,1);
if nDatasetImages == 0
    error('nm_dataset:numImages', strcat('Warning: no images loaded from folder: ', datasetPath)) 
end

% Image indexes to load (=totalNumberOfDatasetImages - % avoidImagesAtIndexes)
imageToLoadIndexes = setdiff(1:nDatasetImages, pars.avoidImagesAtIndexes);

% Update number of dataset images
nDatasetImages = length(imageToLoadIndexes);

%% Load Dataset
fprintf(['Loading dataset:' datasetName '\n'])

% Fill return matrix with zeros (dataset matrix must be set to uint8 class)
nImageChannels = 3;

% Initialize dataset values
dataset = struct(   'images',       {zeros(pars.imageHeight,pars.imageWidth,nImageChannels,nDatasetImages,'uint8')}, ...
                    'masks',        {zeros(pars.imageHeight,pars.imageWidth,nDatasetImages)}, ...
                    'imageNames',   {cell(nDatasetImages,1)}, ...
                    'cam',          {ones(1,nDatasetImages)}, ...
                    'personID',     {zeros(1, nDatasetImages)}, ...
                    'personSubsetImageIndex', {zeros(1, nDatasetImages)}, ...
                    'imageIndex',   {1:1:nDatasetImages}, ...
                    'peopleCount',  0, ...
                    'name',         datasetName, ...
                    'count',        nDatasetImages);

% Do not want to resize original images
if isempty(pars.imageHeight) && isempty(pars.imageWidth)
    dataset.images = cell(nDatasetImages,1);
end

% Load data showing loading bar
if pars.showLoadingBar
    hWaitingBar = waitbar(0, 'Please wait while loading the dataset');
end

% Person ID
idOld = -inf;

% Filename format
fileFormat = datasetImageList(imageToLoadIndexes(1)).name;
bAddCamID = false;
if length(fileFormat) >= 16
    bAddCamID = true;
end

sumSubIndex = 0;
% Load images loop
for i=1:length(imageToLoadIndexes)

    % Image name
    imagePath = strcat(datasetPath, filesep, datasetImageList(imageToLoadIndexes(i)).name);

    % Load and normalize image
    image = NM_imread(imagePath, '', '', [pars.imageHeight, pars.imageWidth]);
    dataset.images(:,:,:,i) = image;
    
    % Save image name
    dataset.imageNames{i} = datasetImageList(imageToLoadIndexes(i)).name;

    % New person ID
    dataset.personID(i) = str2double(datasetImageList(imageToLoadIndexes(i)).name(1:4));

    % Count the number of different people within the dataset
    idNew = dataset.personID(i);
    if idNew ~= idOld
        dataset.peopleCount = dataset.peopleCount+1;
        idOld = idNew;
        sumSubIndex = 0;
    end

    % Person ID + camID
    if bAddCamID
        if pars.loadCams
            dataset.cam(i) = str2double(datasetImageList(imageToLoadIndexes(i)).name(5:8));
            dataset.personSubsetImageIndex(i) = str2double(datasetImageList(imageToLoadIndexes(i)).name(9:12));
        else
            dataset.personID(i) = str2double(datasetImageList(imageToLoadIndexes(i)).name(1:4));
            dataset.personSubsetImageIndex(i) = str2double(datasetImageList(imageToLoadIndexes(i)).name(9:12));
            if i>1 && dataset.personSubsetImageIndex(i) == 1 && dataset.personID(i) == dataset.personID(i-1) 
                sumSubIndex = dataset.personSubsetImageIndex(i-1);
            end
            dataset.personSubsetImageIndex(i) = dataset.personSubsetImageIndex(i) + sumSubIndex;
        end
    else

        dataset.personID(i) = str2double(datasetImageList(imageToLoadIndexes(i)).name(1:4));
        dataset.personSubsetImageIndex(i) = str2double(datasetImageList(imageToLoadIndexes(i)).name(5:8));

        % Load cam ID = to person sub index (camera ID not defined in
        % the file name...)
        if pars.loadCams
            dataset.cam(i) = dataset.personSubsetImageIndex(i);
        end
    end

    % Step bar position
    if pars.showLoadingBar
        waitbar(i/nDatasetImages,hWaitingBar)
    end
end

% If wait bar exists close it
if pars.showLoadingBar
    close(hWaitingBar)
end


%% Load masks images
if pars.loadMasks

    % Show loading bar
    if pars.showLoadingBar
        hWaitingBar = waitbar(0, 'Please wait while loading dataset masks');
    end

    % load the masks
    load(strcat(baseDatasetsPath, filesep, 'Masks', filesep, datasetName));
    %mask_fin = zeros(imageHeight,imageWidth,nDatasetImages);

    for i=1:nDatasetImages
        msk{imageToLoadIndexes(i)} = imresize(msk{imageToLoadIndexes(i)},[pars.imageHeight,pars.imageWidth]);
        dataset.masks(:,:,i) = imfill(msk{imageToLoadIndexes(i)},'holes');

        % Step bar position
        if pars.showLoadingBar
            waitbar(i/nDatasetImages,hWaitingBar)
        end
    end

    % If wait bar exists close it
    if exist('hWaitingBar', 'var') == 1
        close(hWaitingBar)
    end

else
    dataset.masks = ones(pars.imageHeight,pars.imageWidth,nDatasetImages);
end

% Dataset loaded
fprintf('Dataset loaded\n');

% Replace masks
if ~pars.loadMasks
    dataset.masks = ones(size(dataset.images(:,:,:,1),1),size(dataset.images(:,:,:,1),2),dataset.count);
end


% Loading time
timeToLoad = toc(t_load_dataset);

end