function [ datasetRootFolder ] = NM_datasetroot( )
%   NM_DATASETROOT function
%   Return the dataset root folder   
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%
%% Return this file position (root folder of NMLib)
datasetRootFolder = fileparts(which('NM_datasetroot.m'));

end

