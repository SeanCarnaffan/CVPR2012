function [ maskedImagePHOG, maskedImageGLCM, maskedImageSIFT, maskedImageWGCH] = NM_reid_wcnwasa12_images( image, mask, pars )
% PRE-PROCESS IMAGES
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%

imgHSV = NM_colorconverter(image, 'RGB', 'HSV');  
convertedColorSpaceImagePHOG = NM_channels2image(imgHSV(:,:,1),imgHSV(:,:,2), histeq(imgHSV(:,:,3)));

imgHSV = NM_colorconverter(image, 'RGB', 'HSV');  
imgHSV = NM_channels2image(imgHSV(:,:,1),imgHSV(:,:,2), histeq(imgHSV(:,:,3)));
convertedColorSpaceImageSIFT = NM_colorconverter(imgHSV, 'HSV', 'RGB');

imgHSV = NM_colorconverter(image, 'RGB', 'HSV');  
convertedColorSpaceImageWGCH = NM_channels2image(imgHSV(:,:,1),imgHSV(:,:,2), histeq(imgHSV(:,:,3)));
 
imgHSV = NM_colorconverter(image, 'RGB', 'HSV');  
imgHSV = NM_channels2image(imgHSV(:,:,1),imgHSV(:,:,2), histeq(imgHSV(:,:,3)));
convertedColorSpaceImageGLCM = NM_colorconverter(imgHSV, 'HSV', 'RGB');

%% ----------------------------------
% Masked images
maskedImagePHOG         =  NM_immasked( convertedColorSpaceImagePHOG, mask, 0 );
maskedImageGLCM         =  im2uint8(NM_immasked( convertedColorSpaceImageGLCM, mask, -inf ));
maskedImageSIFT         =  NM_immasked( convertedColorSpaceImageSIFT, mask, -inf );
maskedImageWGCH         =  NM_immasked( convertedColorSpaceImageWGCH, mask, -inf );

end

