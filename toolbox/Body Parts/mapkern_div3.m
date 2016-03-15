function [MAP_KRNL,TLanti,BUsim,LEGsim,HDanti] = mapkern_div3(dataset,mask_fin,permit_inds,parSYM, computeKernel, showBars)
% [MAP_KRNL,TLanti,BUsim,LEGsim,HDanti] = mapkern_div3(dataset,mask_fin,permit_inds,parSYM)
%
% This function extracts the salient parts of the human body for SDALF 
% descriptor: 2 asymmetry axes (for head, torso, and legs) and 2 symmetry 
% axes (for the vertical centre of the body)
% 
% Input:
% - dataset: matrix containing the images
% - mask_fin: foreground mask for each image in the dataset
% - parSYM: parameters for the parts extraction
%
% Output:
% - MAP_KRNL: kernel for weighting features
% - TLanti: torso/leg axis
% - BUsim: vertical axis in the torso; 
% - LEGsim: vertical axis in the legs; 
% - HDanti: head/torso axis
%

if nargin == 4
    computeKernel = true;
    showBars = true;
end

[H,W,trash,trash1] = size(dataset);

% symmetries parameters automatically derived from on the image dimension (Height,Width)
parSYM.delta = [H/parSYM.val W/parSYM.val]; % border limit (in order to avoid the local minimums at the image border) 
parSYM.varW  = W/5; % variance of gaussian kernel (torso-legs)
parSYM.search_range_H  =   [parSYM.delta(1),H-parSYM.delta(1)];
parSYM.search_range_W  =   [parSYM.delta(2),W-parSYM.delta(2)];

ii              =   1;

if showBars == true
    hwait = waitbar(0,'Division in 3 parts...');
end

for i=1:length(permit_inds)
    img     =   squeeze(dataset(:,:,:,i)); 
    MSK     =   double(mask_fin(:,:,i));
    
    img_hsv     =   rgb2hsv(img);

    HDanti(i)   = uint16(fminbnd(@(x) sym_dissimilar_MSKH(x,img_hsv,MSK,parSYM.delta(1)),1,parSYM.search_range_H(1)));
    TLanti(i)   = uint16(fminbnd(@(x) dissym_div(x,img_hsv,MSK,parSYM.delta(1),parSYM.alpha),double(HDanti(i)+parSYM.search_range_H(1)),parSYM.search_range_H(2)));
    BUsim(i)    = uint16(fminbnd(@(x) sym_div(x,img_hsv(1:TLanti(i),:,:),MSK(1:TLanti(i),:),parSYM.delta(1),parSYM.alpha),parSYM.search_range_W(1),parSYM.search_range_W(2)));
    LEGsim(i)   = uint16(fminbnd(@(x) sym_div(x,img_hsv(TLanti(i)+1:end,:,:),MSK(TLanti(i)+1:end,:),parSYM.delta(1),parSYM.alpha),parSYM.search_range_W(1),parSYM.search_range_W(2)));

    if showBars == true
    	waitbar(i/length(permit_inds),hwait)
    end
end

if showBars == true
    close(hwait)
end

det_final = NaN*ones(length(permit_inds),4); % head is removed

%% Kernel-map computation
if computeKernel

    ii = 1;
    hwait = waitbar(0,'Kernel map...');
    for i=1:length(permit_inds)
        img     =   squeeze(dataset(:,:,:,i)); 

        img_hsv     =   rgb2hsv(img);
        tmp         =   img_hsv(:,:,3);
        tmp         =   histeq(tmp); % Color Equalization
        img_hsv     =   cat(3,img_hsv(:,:,1),img_hsv(:,:,2),tmp); % eq. HSV


        if ~any(isnan(det_final(i,:))) % NaN = head not found
            HEAD = img_hsv(1:HDanti(i),:,:);
            cntr = [det_final(i,1)+det_final(i,3)/2,det_final(i,2)+det_final(i,4)/2];
            HEADW = radial_gau_kernel(cntr,DIMW*3,size(HEAD,1),W);
        else
            HEADW = zeros(HDanti(i),W);
        end

        if (HDanti(i)+1 >= TLanti(i)) % avoid zero height divisions
            HDanti(i) = HDanti(i) - 2;
        end

        UP = img_hsv(HDanti(i)+1:TLanti(i),:,:);
        UPW = gau_kernel(BUsim(i),parSYM.varW,size(UP,1),W);

        DOWN = img_hsv(TLanti(i)+1:end,:,:);
        DOWNW = gau_kernel(LEGsim(i),parSYM.varW,size(DOWN,1),W);

        MAP_KRNL{i} = [HEADW/max(HEADW(:));UPW/max(UPW(:));DOWNW/max(DOWNW(:))];
        if (H-size(MAP_KRNL{i})>=0)
            MAP_KRNL{i} = padarray(MAP_KRNL{i},H-size(MAP_KRNL{i},1),'replicate','post');
        else
            MAP_KRNL{i} = MAP_KRNL{i}(1:H,:);
        end

    %     if plotY
    %         subplot(maxplot*2/12,12,ii), imagesc(img), axis image,axis off,hold on;
    %         subplot(maxplot*2/12,12,ii+1),imagesc(MAP_KRNL{i}), axis image
    %     end


        if ~any(isnan(det_final(i,:)))
            HEADW = HEADW(:);
            head_det_flag(i) = 1;
        else
            head_det_flag(i) = 0;
        end

        ii=ii+2;
        clear HEADW DOWNW UPW

    %     if ii>maxplot && plotY
    %         ii = 1;
    %         pause,clf(h1)
    % 	end
        waitbar(i/length(permit_inds),hwait)
    end
    close(hwait)
else
    MAP_KRNL = {};
end