function [ updatedDistance, personIDs] = NM_reid_wcnwasa12_extract_datasets( dataset, testPersonIDs, pars )

% Copy distance matrix
personIDs = testPersonIDs; %unique(dataset.personID);

% Handle multiple-shot and single-shot cases
imCount1 = 1;
imCount2 = 1;
if strcmpi(pars.reid.type, 'MvsS') == 1
    imCount1 = pars.reid.signatureImagesCount;
elseif strcmpi(pars.reid.type, 'MvsM') == 1
    imCount1 = pars.reid.signatureImagesCount;
    imCount2 = pars.reid.signatureImagesCount;
end

if ~isempty(pars.settings.testCams)
    testCams = pars.settings.testCams;
    updatedDistance = repmat({zeros(length(personIDs))}, size(testCams, 1), 1);
    for c=1:size(testCams, 1)

        % Choose two views for each person in the dataset
        % one view as probe, one as test
        for i=1:length(personIDs)

            % Gallery image indexes
            galleryIdx  = dataset.imageIndex( dataset.personID == personIDs(i) & dataset.cam == testCams(c,1) );
            galleryIdx  = galleryIdx(randperm(length(galleryIdx), imCount1));
                         
            % Test images
            for j=1:length(personIDs)
                testIdx     = dataset.imageIndex( dataset.personID == personIDs(j) & dataset.cam == testCams(c,2) );
                testIdx     = testIdx(randperm(length(testIdx), imCount2));
                
                % Phog and sift min distances
                phogMin = min(min(dataset.phogDistance(galleryIdx, testIdx)));
                wgchMin = min(min(dataset.wgchDistance(galleryIdx, testIdx)));
                haralickMin = min(min(dataset.haralickDistance(galleryIdx, testIdx)));

                % Update cam 2 cam distance matrix
                updatedDistance{c}(i,j) = (pars.reid.alpha*phogMin)+(pars.reid.beta*haralickMin)+(pars.reid.gamma*wgchMin);
                
            end
        end       
    end
else
    
    % Updated matrix (all zeros)
    updatedDistance = {zeros(length(personIDs))};
    
    % Choose two views for each person in the dataset
    % one view as probe, one as test
    for i=1:length(personIDs)

        % Gallery image indexes
        galleryIdx  = dataset.imageIndex( dataset.personID == personIDs(i) );
        galleryIdx  = galleryIdx(randperm(length(galleryIdx), imCount1));

        % Test images
        for j=1:length(personIDs)
            testIdx     = dataset.imageIndex( dataset.personID == personIDs(j) );
            testIdx     = testIdx(randperm(length(testIdx), imCount2));

            % Features mean distances
            phogMin = mean(mean(dataset.phogDistance(galleryIdx, testIdx)));
            wgchMin = mean(mean(dataset.wgchDistance(galleryIdx, testIdx)));
            haralickMin = mean(mean(dataset.haralickDistance(galleryIdx, testIdx)));

            % Update cam 2 cam distance matrix
            updatedDistance{1}(i,j) = (pars.reid.alpha*phogMin)+(pars.reid.beta*haralickMin)+(pars.reid.gamma*wgchMin);
        end
    end
end

end

