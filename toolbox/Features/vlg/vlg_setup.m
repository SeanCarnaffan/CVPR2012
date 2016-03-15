function path = vlg_setup
% VLG_SETUP adds VLG toolbox path to MATLAB path
%  PATH = VLG_SETUP() adds VLG to MATLAB path.

% Copyright 2008 (C) Taehee Lee
%
% This program is part of VLG, available in the terms of the GNU
% General Public Licenseversion 2.

root=vlg_root ;
addpath(root);
addpath(fullfile(root,'bundle'       )) ;
addpath(fullfile(root,'geometry'     )) ;
addpath(fullfile(root,'visualization')) ;
addpath(fullfile(root,'test'         )) ;
