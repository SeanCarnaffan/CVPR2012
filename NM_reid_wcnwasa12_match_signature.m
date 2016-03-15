function [distances] = NM_reid_wcnwasa12_match_signature(signatures, pars)
% MATCH SIGNATURES
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%

% FEATURES COMPARISION
fprintf('Matching Signatures...');

% People distances...
sz = length(signatures.siftFeatures);
distances.distance = zeros(sz);
distances.phogDistance = zeros(sz);
distances.wgchDistance = zeros(sz);
distances.haralickDistance = zeros(sz);
    
% Start compare timer
t_reid_compare_all = tic;

% Load distance matrix
distancesFile = fullfile(pars.settings.outputDataFolder, [pars.settings.outputFilePrefix '_distance.mat']);
if exist(distancesFile, 'file')
    load(distancesFile);
else
    
    % Compare extracted features
    [distances.distance(:,:) distances.phogDistance(:,:) ...
        distances.wgchDistance(:,:) distances.haralickDistance(:,:)] ...
              = NM_reid_wcnwasa12_compare(  signatures.phogFeatures, signatures.siftFeatures, signatures.haralickFeatures, pars );
                                    
    % Save distances
    try
        save(distancesFile, 'distances');
    catch ME
        warning('nm_reid_main:saveDistances', 'Unable to save features data on file %s.', namefile)
    end
end
fprintf('done in %.2f(s)\n', toc(t_reid_compare_all));


end
