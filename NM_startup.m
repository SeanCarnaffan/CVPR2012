function [ ] = NM_startup( )

%% Run toolbox custom setup
if ~exist('NM_setup_toolbox.m', 'file')
    [tmp, ~] = fileparts(mfilename('fullpath'));
    custom_setup_file = fullfile(tmp, 'toolbox', 'NM_setup_toolbox.m');
    run(custom_setup_file);
end
end