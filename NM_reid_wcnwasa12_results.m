function [] = NM_reid_wcnwasa12_results(dataset, stats, pars)
% SHOW RE-ID RESULTS
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%


% Test person IDs
Nplot = 10;
if strcmpi(pars.dataset.name, 'i-LIDS') == 1
    queryPersonID = [1 22 34 56 73 78 95 119]; %[15 19 24 37 44 80 98 99];
elseif strcmpi(pars.dataset.name, 'WARD') == 1
    %queryPersonID = [7 23 37 43 44 45 51 53 57 58 62 68];
    queryPersonID = [23 37 43 44 45 51 53 57 58 62];
    %queryPersonID = [1 15 27 30 37 44 45 51 53 55];
    queryPersonID = [1 13 27 33 38 44 45 51 53 68];
else
    queryPersonID = 1:dataset.peopleCount;
end

fprintf('Plotting reidentification results...');
t = tic;

% Run test and siplay results
show_image_results(dataset, stats, queryPersonID, Nplot, pars);

fprintf('done in %.2f(s)\n', toc(t));
end


function [] = show_image_results(dataset, stats, queryIDs, showTopNResults, pars)

opts.borderColor = [0 255 0];
opts.borderSize = 8;
plotCols = 2;
queryIDs = unique(queryIDs);

for c=1:length(stats)

    % Create new figure
    figure;
    ax = tight_subplot(length(queryIDs), plotCols, [.001 .001], [.001 .001], [.001 .001]);
    plotIdx = 1;

    % Loop through all query IDs
    for i=1:length(queryIDs)

        avgScore = mean(stats(c).score, 3);
        [~, sortedMatchIDs] = sort(avgScore(:, queryIDs(i)), 'descend');

        % Get top N results 
        resultIdx = sortedMatchIDs(1:showTopNResults);

        %Probe image
        if isfield(pars.settings, 'testCams') && ~isempty( pars.settings.testCams )
            
            % Query Image
            queryImage = dataset.images(:,:,:, dataset.personID == queryIDs(i) & dataset.cam ==  pars.settings.testCams(c,1) & dataset.personSubsetImageIndex == 1);
        
            % Gallery images
            %galleryImages = dataset.images(:,:,:, ismember(dataset.personID, resultIdx) & dataset.cam ==  pars.settings.testCams(c,2) & dataset.personSubsetImageIndex == 1);
            allGalleryImages = dataset.images(:,:,:, dataset.cam ==  pars.settings.testCams(c,2) & dataset.personSubsetImageIndex == 1);
            galleryImages = allGalleryImages(:,:,:,resultIdx);
            
            % Re-id image index
            j = find( queryIDs(i) == resultIdx );

        else
             % Query Image
            queryImage = dataset.images(:,:,:, dataset.personID == queryIDs(i) & dataset.personSubsetImageIndex == 1);
        
            % Gallery images
            galleryImages = [];
            for m=1:length(resultIdx)
                personSubsetImageRandomIndex = dataset.personSubsetImageIndex(dataset.personID == resultIdx(m));
                personSubsetImageRandomIndex = randperm(length(personSubsetImageRandomIndex));
                galleryImages = cat(4, galleryImages, dataset.images(:,:,:,  dataset.personID == resultIdx(m) & dataset.personSubsetImageIndex == personSubsetImageRandomIndex(1)));
            end
            
            % Re-id image index
            j = find( queryIDs(i) == resultIdx );
        end

        % Draw correct match rectangle around image
        galleryImages = draw_correct_match_rect(galleryImages, j, opts.borderSize, opts.borderColor);

        %Subplot current image
        %subplot(length(queryIDs), plotCols, (plotCols*i)-(plotCols-1));
        axes(ax(plotIdx));
        imshow(queryImage);
        plotIdx = plotIdx+1;
        
        % Subplot best result images
        %subplot(length(queryIDs), plotCols, (plotCols*i)-(plotCols-2));
        axes(ax(plotIdx));
        montage(galleryImages, 'Size', [1, showTopNResults] );  
        plotIdx = plotIdx+1;
    end
    
    % Make figure full screen
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    filePath = strcat('.', filesep, 'data', filesep, 'images_fig_cams_', num2str(pars.settings.testCams(c,1)), '-', num2str(pars.settings.testCams(c,2)));

    % Save figure
    saveas(gcf, filePath,'fig');

    % Export as PDF
    export_fig('filename', filePath, '-pdf', '-q101', '-transparent', '-r600', '-m3');


end


end


function [galleryImages] = draw_correct_match_rect(galleryImages, idx, borderSize, color)

[imHeight, imWidth] = size(galleryImages(:,:,1,1));

% Draw rect for image
if ~isempty(idx)
    galleryImages([1:borderSize,     imHeight-borderSize:imHeight],:,1,idx) =    color(1);
    galleryImages(:,[1:borderSize,   imWidth-borderSize:imWidth],1,idx) =        color(1);
    galleryImages([1:borderSize,     imHeight-borderSize:imHeight],:,2,idx) =    color(2);
    galleryImages(:,[1:borderSize,   imWidth-borderSize:imWidth],2,idx) =        color(2);
    galleryImages([1:borderSize,     imHeight-borderSize:imHeight],:,3,idx) =    color(3);
    galleryImages(:,[1:borderSize,   imWidth-borderSize:imWidth],3,idx) =        color(3);
end

end