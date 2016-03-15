function [ kernelMap ] = NM_reid_person_kernelmap( mask, torso, legs, head, kernelType )
%   NM_PERSON_KERNELMAP Computes the kernel map for the given mask of a
%   given person image
%
%   Copyright: Niki Martinel
%   Date: 09/19/2011
%   Return Data: kernel map

% Check input arguments
if nargin == 1
    torso = [];
    legs = [];
    head = [];
    kernelType = 'normal';
elseif nargin == 2
    legs = [];
    head = [];
    kernelType = 'normal';
elseif nargin == 3 
    head = [];
    kernelType = 'normal';
elseif nargin == 4
    kernelType = 'normal';
end

% Create body parts coordinages
headCoordinates  = [];
torsoCoordinates = [];
legsCoordinates  = [];

%% Extract coordinates 
if strcmpi(kernelType, 'normal') == false
 
    % Find mask coordinates
    [i, j] = find(mask > 0 );
    fullBodyCoordinates = [i j];
    
    % Check body parts
    if head(1) == head(3), head(3) = head(3)+1; end
    if head(2) == head(4), head(4) = head(4)+1; end 

    % Extract torso coordinate points whose value is greater than 0
    if ~isempty(torso)
            [i, j] = find(mask(torso(2):torso(4), torso(1):torso(3)) > 0 );
            torsoCoordinates = [(i + double(torso(2)) -1) (j + double(torso(1)) -1)];
    end
    
    % Extract legs coordinate poitns whose value is greater than 0
    if ~isempty(legs)
        [i, j] = find(mask(legs(2):legs(4), legs(1):legs(3)) > 0 );
        legsCoordinates = [(i + double(legs(2)) -1) (j + double(legs(1)) -1)];
    end

    % Extract head coordinate poitns whose value is greater than 0
    if ~isempty(head)
        if head(1) == head(3) head(3) = head(3)+1; end
        if head(2) == head(4) head(4) = head(4)+1; end            
        [i, j] = find(mask(head(2):head(4), head(1):head(3)) > 0 );
        headCoordinates = [(i + double(head(2)) -1) (j + double(head(1)) -1)];
    end
    % Convert coordinate values into double class
    torsoCoordinates = double(torsoCoordinates);
    legsCoordinates = double(legsCoordinates);
    headCoordinates = double(headCoordinates);

    % Input points = mask points for each body part
    torsoQueryPoints = torsoCoordinates;
    legsQueryPoints = legsCoordinates;
    headQueryPoints = headCoordinates;
end

%% Compute kernel weights 
switch kernelType
    case 'normal'
        [i, j] = find(mask >= 0 );
        fullBodyCoordinates = [i j];
        weightsFullBody = ones(length(fullBodyCoordinates), 1);
    case 'mahal'
        
        % Legs weights
        if size(torsoCoordinates,1) > 2
            weightsTorso = mahal(torsoQueryPoints, torsoCoordinates);
        else
            weightsTorso = 1;
        end
        
        % Legs weights
        if size(legsCoordinates,1) > 2
            weightsLegs= mahal(legsQueryPoints, legsCoordinates);
        else
            weightsLegs = max(weightsTorso(:));
        end
            
        % Head weights
        if size(headCoordinates, 1) > 2
            weightsHead = mahal(headQueryPoints, headCoordinates);
        else
            weightsHead = max(weightsTorso(:));
        end
        
        % Full body weights
        weightsFullBody = [weightsHead; weightsTorso; weightsLegs];
        fullBodyCoordinates = [headCoordinates; torsoCoordinates; legsCoordinates];
    case 'mahal_full'
        weightsFullBody = mahal(fullBodyCoordinates, fullBodyCoordinates);
end

% KERNEL MAP struct
% Fuse all results in one single kernelMap appending head, torso and legs
% coordinates and weights
% . Create weights matrix with the same size of all body parts
% . Coordinate matrix [xcoord ycoord; xcoord2 ycoord2; ..] of all fused
%   body parts
kernelMap = struct( 'weights',     {weightsFullBody}, ...
                    'coordinates', {fullBodyCoordinates} );

end

