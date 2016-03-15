function [ har ] = NM_haralick( image, pars )
% NM_HARALICK Compute Haralick features

% Process inputs
defaultpars=struct('levels',4,'offsetmat',[0 1], 'symmetric',false, 'computeForEachLevel',false, 'meanValues', false, 'vector', true);
if(~exist('pars','var')), 
    pars=defaultpars; 
else
    tags = fieldnames(defaultpars);
    for i=1:length(tags)
         if(~isfield(pars,tags{i})),  pars.(tags{i})=defaultpars.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(pars))), 
        warning('register_volumes:unknownoption','unknown haralick features pars found');
    end
end

har = [];
if pars.computeForEachLevel && size(image, 3) > 1

    % Compute gray level co-poccurence matrix
    glcm = zeros(pars.levels, pars.levels, size(pars.offsetmat, 1), size(image,3));
    for i=1:size(image,3)
        glcm(:,:,:,i) = graycomatrix(image(:,:,i), 'NumLevels', pars.levels, 'Offset', pars.offsetmat, 'Symmetric', pars.symmetric);
    
        % Compute Haralick features
        har = [har GLCM_Features4(glcm(:,:,:,i),0)];
    end
    
elseif (size(image, 3)>1 && ~pars.computeForEachLevel) || (pars.computeForEachLevel && size(image, 3) <= 1)
        
    glcm = graycomatrix(rgb2gray(image), 'NumLevels', pars.levels, 'Offset', pars.offsetmat, 'Symmetric', pars.symmetric);
   
    % Compute Haralick features
    har = GLCM_Features4(glcm,0);

else
    glcm = graycomatrix(image, 'NumLevels', pars.levels, 'Offset', pars.offsetmat, 'Symmetric', pars.symmetric);
   
    % Compute Haralick features
    har = GLCM_Features4(glcm,0);
end

% Remove non-Haralick features
fields = {'autoc', 'cprom', 'cshad', 'dissi', 'energ', 'homom', 'homop', 'maxpr', 'indnc'};
har = rmfield(har, fields);
   
% Compute mean values
if pars.meanValues
    tags = fieldnames(har(1));
    for i=1:size(har,2)
        har(i) = cell2struct( num2cell(structfun(@mean,har(i))), tags);
    end
end

% Return feature vector instead of struct
if pars.vector
    har = structfun(@(s)(s), har);
end

end

