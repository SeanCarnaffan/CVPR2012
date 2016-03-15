function maskedImage = NM_immasked(imageData, mask, valueOfBGPixels)
% NM_IMMASKED Create a masked image
% 
%   Copyright: Niki Martinel
%   Date: 09/07/2011
%   Return Data: double class RGB masked image
%   Parameters: 1. input image
%               2. binary mask
%
%   MASKEDIMAGE = IMOVERLAY(IMAGEDATA, MASK, VALUEOFBGPIXELS) takes an input image, IMAGEDATA, and a binary
%   image, MASK, and produces an output image whose pixels in the MASK
%   locations have the ORIGINAL IMAGE VALUES, other locations will have
%   VALUEOFBGPIXELS value.
%
%   IMAGEDATA should be a grayscale or an RGB image of class uint8, uint16, int16,
%   logical, double, or single.  If IMAGEDATA is double or single, it should be in
%   the range [0, 1].  If it is not in that range, you might want to use
%   mat2gray to scale it into that range.
%
%   MASK should be a two-dimensional logical matrix.
%
%   OUT is a double RGB image.
%

%% Check input parameters
switch nargin 
    case 0
        error('nm_immasked:argChk', 'Wrong number of input parameters (=0)');
    case 1
        error('nm_immasked:argChk', 'Wrong number of input parameters (=1 => input mask not available)');
    case 2
        valueOfBGPixels = 0;
end

%% Compute masked image

% Make the uint8 the working data class
in_double = im2double(imageData);
isgrayscale = false;

% Initialize the red, green, and blue output channels.
if ndims(in_double) == 2
    % Input is grayscale.  Initialize all output channels the same.
    out_red   = in_double;
    out_green = in_double;
    out_blue  = in_double;
    isgrayscale = true;
else
    % Input is RGB truecolor.
    out_red   = in_double(:,:,1);
    out_green = in_double(:,:,2);
    out_blue  = in_double(:,:,3);
end

% Replace output channel values in the mask locations with the appropriate
% color value.
out_red(mask==0)   = valueOfBGPixels;
out_green(mask==0) = valueOfBGPixels;
out_blue(mask==0)  = valueOfBGPixels;

% Form an RGB truecolor image by concatenating the channel matrices along
% the third dimension.
maskedImage = NM_channels2image(out_red, out_green, out_blue);
if isgrayscale
    maskedImage = out_red;
end

end
