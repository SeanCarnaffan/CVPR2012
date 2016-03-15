function [stats] = NM_reid_wcnwasa12_compute_stats(score, labels, varargin)
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%

p = inputParser;
p.addOptional('display', true);
p.addOptional('distance', false);
p.addOptional('merge', []);
p.addOptional('thresholds', 100);
p.parse(varargin{:});
pars = p.Results;

% From distance to similarity (suppose score = [0 1])
if pars.distance
    score = 1-score;
end

% Fix possible score issues vector
%score(isinf(score)) = 0;
    
match = zeros(length(labels),1);
for k=1:length(labels)
    [~, sortedLabel] = sort( score(:,labels(k)), 'descend');
    matchPos = find( labels(k) == sortedLabel );
    match(matchPos) = match(matchPos)+1;
end

%% CMC
CMC = zeros(1, length(match));
for k=1:length(match)
    CMC(k) = sum(match(1:k));
end
AUC = sum(CMC);
nAUC = sum(CMC)/(length(match)*length(unique(labels)))*100;

%% SRR
M = 1:10;
if length(M) > length(match)
    M=1:length(match);
end
SRR = zeros(1,length(M));
for m = 1:length(M)
    SRR(1,m) = CMC(uint16(floor(length(match)/M(m))))/length(unique(labels))*100;
end

%% PRECISION, RECALL, and F-SCORE
precision = zeros(length(labels),   pars.thresholds); 
recall = zeros(length(labels),      pars.thresholds);
fscore =zeros(length(labels),       pars.thresholds);
tpr = zeros(length(labels),          pars.thresholds);
fpr = zeros(length(labels),         pars.thresholds);
th = zeros(length(labels),          pars.thresholds);

% Loop through all signatures
for k=1:length(labels)

    % Target vector
    target = zeros(1,length(labels));
    target(k) = 1;

    % Compute true positive rate, false positive rate, and precision
    [precision(k,:), recall(k,:), fscore(k,:), ...
        truePositivesRate(k,:), falsePositivesRate(k,:), th(k,:) ] = ...
        NM_ROC(score(:,labels(k)), target, 'numThresh', pars.thresholds);
end


%% STORE STATS
if ~isempty(pars.merge)
    stats.CMC       = [pars.merge.CMC;  CMC];
    stats.AUC       = [pars.merge.AUC   AUC];
    stats.nAUC      = [pars.merge.nAUC  nAUC];
    stats.SRR       = [pars.merge.SRR;  SRR];
    
    stats.falsePositivesRate =  cat(3, pars.merge.falsePositivesRate, falsePositivesRate);
    stats.truePositivesRate =   cat(3, pars.merge.truePositivesRate, truePositivesRate);
    stats.precision =           cat(3, pars.merge.precision, precision);
    stats.recall =              cat(3, pars.merge.recall, recall);
    stats.fscore =              cat(3, pars.merge.fscore, fscore);

    stats.score     = cat(3, pars.merge.score, score);
    stats.labels    = [pars.merge.labels; labels];
else
    stats.CMC       = CMC;
    stats.AUC       = AUC;
    stats.nAUC      = nAUC;
    stats.SRR       = SRR;
    
    stats.falsePositivesRate = falsePositivesRate;
    stats.truePositivesRate = truePositivesRate;
    stats.precision = precision;
    stats.recall = recall;
    stats.fscore = fscore;
    
    stats.score             = score;
    stats.labels            = labels;
end

if pars.display
    fprintf('AUC: %d     normalized AUC: %f \n',mean(stats.AUC), mean(stats.nAUC))
    %fprintf('Precision: %f     recall: %f \n', mean(stats.precision(:)), mean(stats.recall(:)));
    %fprintf('F-score: %f \n', mean(stats.fscore(:)))
end


end
