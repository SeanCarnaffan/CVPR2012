function [ stats ] = NM_reid_wcnwasa12_stats( dataset, pars, outputFile )
% COMPUTE STATS
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%

% Load file
if exist(outputFile, 'file')
    load(outputFile);
else
    % Show bar
    mainBarMsg = 'Please wait while computing statistics';
    hWaitingBar = waitbar(0, mainBarMsg);
    
    % Evaluate people re-identification LOOPS times
    loops = 100;
    for t=1:loops

        msg = sprintf([mainBarMsg ': %d of %d'], t, loops);
        waitbar(t/loops, hWaitingBar, msg);
        
        % Extract image sets and updated distance matrix
        testPersonIDs = unique(dataset.personID);
        if ~isempty(pars.reid.testPersonIDs)
            if length(pars.reid.testPersonIDs) == 1
                testPersonIDs = randperm(length(unique(dataset.personID)), pars.reid.testPersonIDs);
            else
                testPersonIDs = pars.reid.testPersonIDs;
            end
        end
        testPersonIDs = sort(testPersonIDs, 'ascend');
        [finalDistance, personIDs] = NM_reid_wcnwasa12_extract_datasets( dataset, testPersonIDs, pars );
        
        % loop through all finald Distance structure since we can test
        % camera 2 camera distance
        for c=1:length(finalDistance)
            
            % Compute stats for loop t
            if t == 1
                stats(c) = compute_stats(finalDistance{c}, personIDs, 'distance', true);
            else
                stats(c) = compute_stats(finalDistance{c}, personIDs, 'distance', true, 'merge', stats(c));
            end
            
        end
    end

    % Save computed stats
    try
        save(outputFile, 'stats');
    catch ME
        warning('nm_reid_stats:saveFeatures', 'Unable to save stats data on file %s.', filePath)
    end

    % Close bar
    close(hWaitingBar);
end


end

function [stats] = compute_stats(score, labels, varargin)

p = inputParser;
p.addOptional('distance', false);
p.addOptional('merge', []);
p.parse(varargin{:});
pars = p.Results;

% From distance to similarity (suppose score = [0 1])
if pars.distance
    score = 1-score;
end

match = zeros(length(labels),1);
for k=1:length(labels)
    [~, sortedLabel] = sort( score(:,k), 'descend');
    matchPos = find( labels(k) == labels(sortedLabel) );
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

%% STORE STATS
if ~isempty(pars.merge)
    stats.CMC       = [pars.merge.CMC;  CMC];
    stats.AUC       = [pars.merge.AUC   AUC];
    stats.nAUC      = [pars.merge.nAUC  nAUC];
    stats.SRR       = [pars.merge.SRR;  SRR];
    
    stats.score     = cat(3, pars.merge.score, score);
    stats.labels    = [pars.merge.labels; labels];
else
    stats.CMC       = CMC;
    stats.AUC       = AUC;
    stats.nAUC      = nAUC;
    stats.SRR       = SRR;
    
    stats.score             = score;
    stats.labels            = labels;
end

end

