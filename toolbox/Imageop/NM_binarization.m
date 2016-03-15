function [ binaryImage ] = NM_binarization( image, threshold )
%   NM_BINARIZATION Summary of this function goes here
%   Detailed explanation goes here

binaryImage = zeros(size(image, 1), size(image, 2), 'double');

% Convert to grayscale and reduce to range [0,1]
if  NM_isuint8(image) || NM_isuint16(image)
    binaryImage = double(NM_colorconverter(image, 'sRGB', 'grayscale')) / 255;
else
    binaryImage = image;
end

% Make binary image
binaryImage(binaryImage>=threshold) = 1;
binaryImage(binaryImage<threshold) = 0;

end

