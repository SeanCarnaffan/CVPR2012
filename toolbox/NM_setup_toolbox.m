function [ ] = NM_setup_toolbox(  )

[root,b,c] = fileparts(mfilename('fullpath')) ;

addpath(root) ;
addpath(genpath(fullfile(root, 'Body Parts'))) ;
addpath(genpath(fullfile(root, 'Colors'))) ;
addpath(genpath(fullfile(root, 'Datasets'))) ;
addpath(genpath(fullfile(root, 'Distance Metrics'))) ;
addpath(genpath(fullfile(root, 'Histograms'))) ;
addpath(genpath(fullfile(root, 'Imageop'))) ;
addpath(genpath(fullfile(root, 'Mask'))) ;
addpath(genpath(fullfile(root, 'Misc'))) ;
addpath(genpath(fullfile(root, 'Region Properties'))) ;

%% Compile MEX files
cd(fullfile(root, 'Colors', 'colorspace'));
mex colorspace.c

cd(fullfile(root, 'Distance Metrics'));
slmetric_pw_compile

cd(fullfile(root, 'Region Properties', 'inpoly'));
mexme_inpoly

cd(fullfile(root, '..'));

%% Custom FEATURE initialization
features_setup_path = fullfile(root, 'Features', 'NM_setup_toolbox_features.m');
run(features_setup_path);



end

