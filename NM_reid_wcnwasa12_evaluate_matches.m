function [stats] = NM_reid_wcnwasa12_evaluate_matches(dataset, matches, pars)
% COMPUTE STATS
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%

fprintf('Computing statistics...');
t = tic;

fn = fieldnames(matches);
for i=1:length(fn)
    dataset.(fn{i}) = matches.(fn{i});
end
clear matches;

% Compute stats
outputStatsFileName = [pars.settings.outputFilePrefix, '_stats.mat'];
stats = NM_reid_wcnwasa12_stats(dataset, pars, fullfile(pars.settings.outputDataFolder, outputStatsFileName));

% Plot stats
NM_reid_wcnwasa12_plot_stats( stats );

fprintf('done in %.2f(s)\n', toc(t));

end
