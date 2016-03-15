function [ matches ] = NM_matchFeatures( feature1, feature2, featureType, pars )
%NM_MATCHFEATURES Summary of this function goes here
%   Detailed explanation goes here

%% Check input parameters
if nargin < 3
   error('nm_extractfeatures:argCheck', 'Wrong number of input arguments (<3)');  
end

matches = struct('indexes', [], ...
                'scores', []);

%% Compute matches between features
switch lower(featureType)

    % Match SIFT descriptors
    case 'sift'
        
        % Detect all SIFT matches
        [matches.indexes, matches.scores] = vl_ubcmatch(feature1.descriptors, feature2.descriptors);
        
        % Rejecct outliers 
        if nargin == 4 && all(isfield(pars, {'maxIter', 'threshold'})) && all(~structfun(@isempty, pars))
            
            % Matched keypoints
            x1 = [feature1.frameKeypoints(1:2,matches.indexes(1,:));ones(size(matches.indexes(1,:)))];
            x2 = [feature2.frameKeypoints(1:2,matches.indexes(2,:));ones(size(matches.indexes(2,:)))];
         
            % Compute inliers/outliersusing RANSAC
            [inliers] = ransac_epipolar_constraint( x1, x2, pars.maxIter, pars.threshold );
            
            % Update matches
            matches.indexes = matches.indexes(:,inliers);
            matches.scores  = matches.scores(:,inliers);
        end
        
        
        
    % math SURF
    case 'surf'
        
        % Put the landmark descriptors in a matrix
        D1 = reshape([feature1.descriptor],64,[]); 
        D2 = reshape([feature2.descriptor],64,[]); 
        
        % Find the best matches
        err=zeros(1,length(feature1));
        cor1=1:length(feature1); 
        cor2=zeros(1,length(feature1));
        for i=1:length(feature1),
            distance=sum((D2-repmat(D1(:,i),[1 length(feature2)])).^2,1);
            [err(i),cor2(i)]=min(distance);
        end
        
        % Sort matches on vector distance
        [err, ind]=sort(err); 
        matches.indexes = [cor1(ind);cor2(ind)];
        matches.scores = err;
  
    % match HARALICK
	case 'haralick'
        if nargin < 4
            pars.noffs = 1;
        end
        if ~isfield(pars, 'noffs') || isempty(pars.noffs)
            pars.noffs = 1;
        end
        tags = fieldnames(feature1);
        matches = cell2struct(repmat({0},length(tags),1), tags);
        for i=1:length(tags)
            for j=1:pars.noffs
                matches.(tags{i}) = matches.(tags{i}) + abs(feature1.(tags{i}) - feature2.(tags{i}));
            end
        end
        
    % match Histograms
	case 'hist'
        
end
    
end

