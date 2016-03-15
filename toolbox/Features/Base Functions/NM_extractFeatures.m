function [ extractedFeature, times ] = NM_extractFeatures( imageData, featureType, algorithmParameters)
%
%   NM_EXTRACTFEATURES Extract required features from input image
%
%   Copyright:  Niki Martinel
%   Date:       08/24/2011
%  

%% Check input parameters
if nargin ~= 3
   error('nm_extractfeatures:argCheck', 'Wrong number of input arguments (!=3)');  
end

%% Extract features from image
switch featureType
    
    %   -------------------------------------------------------------------
    %       PHOG
    %   -------------------------------------------------------------------
    case 'phog'
        % Compute the Pyramid Histogram of Oriented Gradients
        % The histogram exploit the spatial pyramid technique and return a
        % normalized histogram sum(phog)= 1
        % Sample:
        %   bin = #of input bins = 360;
        %   angle = gradient angle = 180 or 360;
        %   levels = pyramid levels = 3;
        %   roi = region of interest = [1;225;1;300];
        %   evaluateDifferentChannels = true/false if you want to evaluate
        %   3 phog descriptors (one for each image channel)
        if ~isfield(algorithmParameters, 'evaluateDifferentChannels'), algorithmParameters.evaluateDifferentChannels = false; end 
        if ~isfield(algorithmParameters, 'bin'), algorithmParameters.bin = 9; end
        if ~isfield(algorithmParameters, 'angle'), algorithmParameters.angle = 180; end
        if ~isfield(algorithmParameters, 'levels'), algorithmParameters.levels = 3; end
        
        if size(imageData,3) == 3 && algorithmParameters.evaluateDifferentChannels == false
            imageData = rgb2gray(imageData);
        end
        if isempty(algorithmParameters.roi)
            rmax = size(imageData, 1);
            cmax = size(imageData, 2);
            algorithmParameters.roi = [1;rmax;1;cmax]; 
        end
            
        % Extract PHOG feature
        phogTimer1 = tic;
        for i=1:size(imageData,3)
           extractedFeature(:,i) = anna_phog(imageData(:,:,i), algorithmParameters.bin, algorithmParameters.angle, algorithmParameters.levels, algorithmParameters.roi);
        end
        times(1) = toc(phogTimer1);
    
    %   -------------------------------------------------------------------
    %       SIFT
    %   -------------------------------------------------------------------
    case 'sift'
        
        %Sample
        %   points = #of sift points to retrieve = 50
        %   levels =  Set the number of levels per octave of the DoG scale
        %   space = 5
        %   displayImage = true/false = if you want to see or not the
        %   original imag
        %   plotFrame = true/false if you want to see or not the frame kypoinsts = true
        %   plotDescriptors = true/false if you want to see or not the sift
        %                   descriptors = true
        %   colorMeanAndHist = true/false if you want to extract the mean 
        %               and the histogram of some points around the sift frame
        %   colorRadius = radius of the circle on which evaluate color mean
        %               or color histogram (have to be integer, otherwise it is rounded to the nearest one)
        %   colorHistBin = edges of histogram bins
        %   imageForColorExtraction = image on which perform color
        %                             extraction (if not set use original
        %                             one)

        siftTimer1 = tic;
        
        % Input image must be single class and grayscale
        if size(imageData,3) == 3
            imageDataToProcess = single(rgb2gray(imageData));
        else
            imageDataToProcess = single(imageData);
        end
        
        % Check if "levels" par is defined
        if ~isfield(algorithmParameters, 'levels')
            algorithmParameters.levels = 3;
        end
        
        % The matrix frameKeypoints has a column for each frame
        % A frame is a disk of center f(1:2), scale f(3) and orientation f(4).
        [frameKeypoints, descriptors] = vl_sift(imageDataToProcess, 'levels', algorithmParameters.levels);
          
        % Check sift points to return
        if algorithmParameters.points ~= 0
            perm = randperm(size(frameKeypoints,2));
            sel = perm(1:algorithmParameters.points);
        else
            % Sel = tot # of frame keypoints
            sel = 1:size(frameKeypoints,2);
        end
        
        % Assign framekeypoints and descriptors to extracted feature
        % structure
        extractedFeature.frameKeypoints = frameKeypoints(:,sel);
        extractedFeature.descriptors = descriptors(:,sel);
        
        % Check if have to display input image
        if algorithmParameters.displayImage == true
            NM_imshow(imageData);
        end
        
        % Check if have or not to plot sift keypoints/descriptors
        if algorithmParameters.plotFrame == true || algorithmParameters.plotDescriptors == true
            if algorithmParameters.plotFrame == true
                h1 = vl_plotframe( extractedFeature.frameKeypoints ); 
                h2 = vl_plotframe( extractedFeature.frameKeypoints ); 
                set(h1,'color','k','linewidth',3) ;
                set(h2,'color','y','linewidth',2) ;
            end
            
            if algorithmParameters.plotDescriptors
                h3 = vl_plotsiftdescriptor(extractedFeature.descriptors, extractedFeature.frameKeypoints);  
                set(h3,'color','g') ;
            end
        end
       
        % Define histogram bin edges
        if isfield( algorithmParameters, 'colorHistBin' ) == false || ( isfield( algorithmParameters, 'colorHistBin' ) == true && isempty(algorithmParameters.colorHistBin))
            if NM_isdouble(imageData)
                algorithmParameters.colorHistBin{1} = 0:0.01:1;
            else
                algorithmParameters.colorHistBin{1} = 0:1:255;
            end
            
            algorithmParameters.colorHistBin{2} = algorithmParameters.colorHistBin{1};
            algorithmParameters.colorHistBin{3} = algorithmParameters.colorHistBin{1};
        end
        
        % Check on which image perform color data extraction
        if isfield( algorithmParameters, 'imageForColorExtraction' ) == false || (isfield(algorithmParameters, 'imageForColorExtraction') == true && isempty(algorithmParameters.imageForColorExtraction)) 
            imageForColorExtraction = imageData;
        else
            imageForColorExtraction = algorithmParameters.imageForColorExtraction;
        end
        
        times(1) = toc(siftTimer1);
        
        siftTimer2 = tic;
        % Check if have to extract color mean and color histogram around sift point
        if isfield(algorithmParameters, 'colorMeanAndHist') && ~isempty(algorithmParameters.colorMeanAndHist) && algorithmParameters.colorMeanAndHist == true 
        
            % Check the value of the radius to consider for sift point
            colorRadius = ones(size(sel)) * algorithmParameters.colorRadius;
            if algorithmParameters.colorRadius == -1
                colorRadius(:) = extractedFeature.frameKeypoints(3,sel);
            end
            
            extractedFeature.colorDescriptor(1,:) = NM_colorpoint(imageForColorExtraction, extractedFeature.frameKeypoints(1:2, :)', colorRadius(:), algorithmParameters.colorHistBin, algorithmParameters.gaussianKernelSigma);
        end
          
        times(2) = toc(siftTimer2);
        %fprintf('COL DESC = %f \n', toc(siftTimer2))
   
    %   -------------------------------------------------------------------
    %       HARALICK
    %   -------------------------------------------------------------------
    case 'haralick'
        haralickTimer = tic;
        extractedFeature = NM_haralick(imageData, algorithmParameters);
        times(1) = toc(haralickTimer);
end

end

