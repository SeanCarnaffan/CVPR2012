function [ dataset ] = NM_reid_wcnwasa12_load_dataset( pars )
% LOAD DATASET
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%

datasetFolder =[];
datasetImageExtension = [];

%% Dataset parameters
if strcmpi(pars.dataset.name, 'WARD') == 1
    datasetFolder = 'WARD';
    datasetImageExtension = 'png';
end

% Load dataset
if ~isempty(datasetFolder)
    dataset = NM_loaddataset(   datasetFolder, datasetImageExtension, ...
                            pars.dataset.imageHeight, pars.dataset.imageWidth, ...
                            [], true, pars.dataset.useMasks, ~isempty(pars.settings.testCams) );
else
    error('nmreid:dataset:invalid_folder', 'NM_reid_wcnwasa12_load_dataset.m: Invalid dataset folder path (empty)');
end

end

