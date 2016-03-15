function [imageDataConverted ] = NM_colorconverter( imageData, inputColorSpace, outputColorSpace )
%
%   NM_COLORCONVERTER Convert RGB image into deisred representation
%
%   Copyright: Niki Martinel
%   Date: 08/11/2011
%   Return Data: return converted image
%   Parameters: 1. Image data to convert
%               2/3. Input color space and output color space
%                   - RGB
%                   - YPbPr
%                   - YCbCr
%                   - JPEG-YCbCr
%                   - YUV
%                   - YIQ
%                   - YDbDr
%                   - HSV or HSB (ranges: 0-360/0-1/0-1)
%                   - HSL or HLS (ranges: 0-360/0-1/0-1)
%                   - HSI (ranges: 0-360/0-1/0-1)
%                   - Lab
%                   - Luv
%                   - LCH
%                   - CAT02 LMS
%

% Check arguments
switch nargin
    case 0 
    case 1
    case 2
        error('nm_colorconverter:argChk', 'Invalid number of input arguments (<3)');
    %case 2
    %    % Use MATALB makecform conversion
    %    cform = makecform(inputColorSpace);
    %    imageDataConverted = applycform(imageData, cform); 
end

if strcmpi(inputColorSpace, 'grayscale') == 1
    imageData = gray2rgb(imageData);
    inputColorSpace = 'RGB';
end

if strcmpi(outputColorSpace, inputColorSpace) == 1
    imageDataConverted = imageData;
elseif strcmpi(outputColorSpace, 'grayscale') == 1
    if strcmpi(inputColorSpace, 'RGB') ~= 1
        imageData = NM_colorconverter(imageData, inputColorSpace, 'RGB');
    end
    imageDataConverted = rgb2gray(imageData);
else
    % Use super fast colorspace
    % (http://www.mathworks.com/matlabcentral/fileexchange/28790-colorspace-tra
    % nsformations)
    imageDataConverted = colorspace([outputColorSpace '<-' inputColorSpace], imageData);
end

% Input and output color space are the same..(no conversion needed)
% if strcmpi(inputColorSpace, outputColorSpace) == 1
%     imageDataConverted = imageData;
%     
% else
%     
%     availableColorValues = {'grayscale','sRGB','HSI','HSV','Lab','Lch','XYZ'};
%     if isempty(strmatch(inputColorSpace, availableColorValues, 'exact'))
%         error('nm_colorconverter:wrongInputValue', 'Input argument (inputColorSpace) value is not valid');
%     end
%     
%     if isempty(strmatch(outputColorSpace, availableColorValues, 'exact'))
%         error('nm_colorconverter:wrongInputValue', 'Output argument (outputColorSpace) value is not valid');
%     end
% 
%     % Check input color space
%     switch inputColorSpace
%         case 'sRGB'
%             imageDataConverted = NM_rgb2other(imageData, outputColorSpace);
%         case 'HSI'
%             imageDataConverted = NM_hsi2other(imageData, outputColorSpace);
%         case 'HSV'
%             imageDataConverted = NM_hsv2other(imageData, outputColorSpace);
%         case 'Lab'
%             imageDataConverted = NM_lab2other(imageData, outputColorSpace);
%         case 'XYZ'
%             imageDataConverted = NM_xyz2other(imageData, outputColorSpace);
%         case 'Lch'
%             imageDataConverted = NM_lch2other(imageData, outputColorSpace);
%     end
%     
end

