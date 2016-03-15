
function [ featureDistance, phogDistance, wgchDistance, haralickDistance ] = NM_reid_wcnwasa12_compare( ...
    phogFeatures, siftFeatures, haralickFeatures, ...
    pars  )

%   NM_REID_COMPARE Compare extracted features
%
%   Copyright: Niki Martinel
%   Date: 09/24/2011
  
% Distance values
featureDistance = zeros(length(siftFeatures));

%%-------------------------------------------------------------------------
% Compare PHOG features

% Create waiting bar for feature comparison process
hWaitingReidComparison = waitbar(0, 'Comparing PHOG features');
waitbar(0, hWaitingReidComparison);

%Compare phog feature using chi-square distance
tcompPhog = tic;
phogDistance = zeros([size(featureDistance) 3]);
    
if pars.reid.alpha > 0

    phogTmpMat1 = zeros(size(phogFeatures, 1), size(phogFeatures,3));
    phogTmpMat2 = phogTmpMat1;
    for i=1:size(phogFeatures,2)
        if pars.phog.channelWeights(i) > 0
            phogTmpMat1(:,:) = phogFeatures(:,i,:);
            phogTmpMat2(:,:) = phogFeatures(:,i,:);

            % Compute distance
            phogDistance(:,:,i) = pars.phog.channelWeights(i) * slmetric_pw(phogTmpMat1, phogTmpMat2, 'chisq');
        end
        
        % Step bar..
        waitbar(i/size(phogFeatures,2), hWaitingReidComparison);
    end
    
    % Release mem..
    clear phogTmpMat2;
    clear phogTmpMat1;
    
    % Final phog distance
    phogDistance = sum(phogDistance, 3);

    % Normalize distnace => [0,1]
    phogDistance = NM_normalizeMatrix(phogDistance);
else
    phogDistance = zeros(size(featureDistance));
end

clear phogFeatures;  
t = toc(tcompPhog);
fprintf('Compare PHOG time = %f\n', t);


%%-------------------------------------------------------------------------
% COMPARE SIFT + GLCM FEATURES

% Step bar..
waitbar(0, hWaitingReidComparison, 'Comparing WGCH and HARALICK features');
        
wgchDistance = zeros(size(featureDistance));
haralickDistance = zeros(size(featureDistance));

tcompSift = tic;
if pars.reid.beta > 0 || pars.reid.gamma > 0
    
    % SIFT RANSAC parameters
    siftMatchPars.maxIter = 100;
    siftMatchPars.threshold = 0.1;
    
    % Loop through all SIFT features
    loop = 0;
    for i1  = 1:length(siftFeatures)
        for i2 = 1:length(siftFeatures)

            % Find SIFT matches: the distance between disft desciptors is measured by 
            % the L2 norm of the difference between them
            [matches] = NM_matchFeatures(siftFeatures(i1), siftFeatures(i2), 'sift'); %, siftMatchPars);
            siftMatches = matches.indexes;
            clear matches;
            
            % # of matches
            numberOfMatches = size(siftMatches(1,:), 2);

            % Reject matches that own to different body parts
            intorso = all( [siftFeatures(i1).intorso(siftMatches(1,:)); siftFeatures(i2).intorso(siftMatches(2,:))]);
            inlegs  = all( [siftFeatures(i1).inlegs(siftMatches(1,:));  siftFeatures(i2).inlegs(siftMatches(2,:))] );
            rejectSiftMatchesAtIndex = find( or(intorso, inlegs) == 0 );
            
            % Reject matches that are not inside the same body region
            if ~isempty(rejectSiftMatchesAtIndex)
                siftMatches(:,rejectSiftMatchesAtIndex) = [];

                % Update # of matches
                numberOfMatches = length(siftMatches(1,:));
            end

            % Release mem..
            clear intorso;
            clear inlegs;
            clear rejectSiftMatchesAtIndex;
            
            % Sift distance sturcture has a scalar distance that describe each image 
            % channel mean distance and a scalar distance that define the phog histogram
            % distance for each image channel also
            histDistance = zeros(3, numberOfMatches);
            if numberOfMatches > 0

                % Loop through all sift matches
                for i=1:numberOfMatches

                    % Loop through all channels
                    for j=1:3

                        % Compute hist distance between for each channel using CHI-SQUARE
                        % distance metric
                        histDistance(j,i) = pars.wgch.histComponentsWeigths(j) * slmetric_pw( siftFeatures(i1).colorDescriptor(1, siftMatches(1,i)).hist{j}, siftFeatures(i2).colorDescriptor(1, siftMatches(2,i)).hist{j}, 'chisq' );
                    end
                end
                
                % Compute distances between means, histograms, and glcm
                d2 = sum(histDistance) .* max(siftFeatures(i1).weight(siftMatches(1,:)), siftFeatures(i2).weight(siftMatches(2,:)));
                
                % Compute mean histogram and glcm distance
                wgchDistance(i1,i2) = mean(d2(:));
                if isnan(wgchDistance(i1,i2))
                    wgchDistance(i1,i2) = inf;
                end
            else
                % When we got no matches set distances to inf
                wgchDistance(i1,i2) = inf;
            end
            
            % Compare glcm features computed for the two given body
            % parts
            bodyParts = 2;
            haralickDistanceTmp = zeros(length(pars.haralick.channelWeights), bodyParts);
            % Loop through all channels
            for i=1:bodyParts
                for j=1:length(pars.haralick.channelWeights)
                    haralickDistanceTmp(j,i) = abs( pars.haralick.channelWeights(j) * slmetric_pw(haralickFeatures(i1).haralick(:,i), haralickFeatures(i2).haralick(:,i), 'sqdist') );
                end
            end
            % Compute average distance between glcm features
            d3 = sum(haralickDistanceTmp);
    
            % Evaluate mean glcm distance
            haralickDistance(i1,i2) = mean(d3(:));
            if isnan(haralickDistance(i1,i2))
                haralickDistance(i1,i2) = inf;
            end

            % Step bar..
            loop = loop +1;
            waitbar(loop/(length(siftFeatures)^2), hWaitingReidComparison);
        end
    end
    
    % Normalize wgchDistance => [0,1]
    wgchDistance(wgchDistance == Inf) = max(wgchDistance(~isinf(wgchDistance)));
    if pars.reid.gamma > 0
        wgchDistance = NM_normalizeMatrix( wgchDistance );
    end
    
    % Normalize haralickDistance => [0,1]
    haralickDistance(haralickDistance == Inf) = max(haralickDistance(~isinf(haralickDistance)));
    if pars.reid.beta>0
        haralickDistance = NM_normalizeMatrix( haralickDistance );
    end
end

t = toc(tcompSift);
fprintf('Compare WGCH/Haralick time =  %f\n', t);

% Compute feature distance by summing weighted sift distance, 
% weighted phog distance, and weighted glcm distance
featureDistance =  (pars.reid.alpha*phogDistance) + (pars.reid.beta*haralickDistance) + (pars.reid.gamma*wgchDistance);
        
% Close waiting bar
close(hWaitingReidComparison);

end

