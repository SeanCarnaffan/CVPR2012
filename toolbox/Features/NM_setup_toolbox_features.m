function [ ] = NM_setup_toolbox_features( )
%NM_SETUP_TOOLBOX_FEATURES Summary of this function goes here

[root,b,c] = fileparts(mfilename('fullpath')) ;

addpath(root);
addpath(genpath(fullfile(root,'Base Functions')));
addpath(genpath(fullfile(root,'Color')));
addpath(genpath(fullfile(root,'GLCM')));
addpath(genpath(fullfile(root,'Haralick')));
addpath(genpath(fullfile(root,'PHOG')));

%% CUSTOM VL_FEAT AND VLG SETUP

% Include vl feat library (see http://www.vlfeat.org/install-matlab.html for details)
custom_setup_file = fullfile(root, 'vlfeat', 'vl_setup');
run(custom_setup_file);

% Include vlg geometry library (see http://vision.ucla.edu/vlg/ for details)
custom_setup_file = fullfile(root, 'vlg', 'vlg_setup');
run(custom_setup_file);


end

