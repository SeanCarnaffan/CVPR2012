function [ imageData ] = NM_imread( imageName, imageColorSpace, imageDataType, imageResize )
%NM_IMAGE Summary of this function goes here
%%
%   Niki Martinel
%   Date: 07/01/2011
%   Return Data: image data matrix
%   Parameters: 1. imageName = image to read
%               2. imageDataType = convert image data to imageDataType
%               3. imageColorSpace = see makecform color spaces conversions: http://www.mathworks.com/help/toolbox/images/ref/makecform.html
%                                    moreover you can use 'sRGB' for
%                                    standard RGB color space
%                                    and 'grayscale' for grayscale images
%                                    if empty use standard sRGB color space     
%               4. desired image [numrows numcols]
%              
%
%

%% Check parameters
switch nargin
    case 0
        disp('Error: imageName not set')
    case 1
        imageColorSpace = 'sRGB';
        imageDataType = '';
        imageResize = false;
    case 2
        imageDataType = '';
        imageResize = false;
    case 3
        imageResize = false;
end

%% Read uint8 data type image
imageData = imread(imageName);

%% Convert to specified color space
if strcmpi(imageColorSpace, '') == 0 && strcmpi(imageColorSpace, 'sRGB') == 0

    % Check color space
    
    % Convert to grayscale
    if strcmpi(imageColorSpace, 'grayscale') == 1
        imageData = rgb2gray(imageData);
        needConverstionTo01Values = true;
    
    % Use MATALB makecform conversion
    else
        cform = makecform(imageColorSpace);
        imageData = applycform(imageData, cform); 
    end
    
else
    needConverstionTo01Values = false;
end
    
%% Check data format
if strcmpi(imageDataType,'double') == 1

    %% Convert to double
    imageData = double(imageData);
    
    %% uniform values if needed
    % e.g.
    % in unit8  => 0 = black, 256 = white
    % in double => 0 = black,   1 = white
    if( needConverstionTo01Values == true )
        imageData = imageData/256;
    end
    
else
    
end

%% Resize image if required
if imageResize
    imageData = imresize(imageData, imageResize);
end