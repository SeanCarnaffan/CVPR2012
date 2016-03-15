function [ handles ] = NM_reid_wcnwasa12_plot_stats( stats )
% PLOT STATS
%
% Author:    Niki Martinel
% Copyright: Niki Martinel, 2012
%

pars.labelFontSize = 14;
pars.labelFontWeight = 'bold';
pars.fullScreen = false;
pars.lineWidth = 2;

if ~isempty(stats)

    cmap = hsv(length(stats));  % Creates a length(pars)-by-3 set of colors from the HSV colormap
    style = {'-', ':', '--', '-.'};
    pars.plotBatchSize = length(stats);
    stmp = style;
    ctmp = cmap;
    for j=1:length(stats)/pars.plotBatchSize
        style(((j-1)*pars.plotBatchSize)+1:((j-1)*pars.plotBatchSize)+pars.plotBatchSize) = stmp(j);
        cmap(((j-1)*pars.plotBatchSize)+1:((j-1)*pars.plotBatchSize)+pars.plotBatchSize,:) = ctmp(1:pars.plotBatchSize,:);
    end
    
    % Legend
    pars.legend = {};
    
    %% CMC
    if isfield(stats, 'CMC')
        handles.cmc = figure;
        hold on;
        for i=1:length(stats)
            plot(mean(stats(i).CMC,1)/size(stats(i).CMC,2)*100, style{i}, 'Color', cmap(i,:), 'LineWidth', pars.lineWidth); 
        end
        grid on; 
        xlabel('Rank Score');
        ylabel('Correct Recognition Percentage');
        axis square;
        
        % Set X and Y limits
        xlim([0 size(stats(i).CMC, 2)]);
        set(gca,'XTick',[0:10:size(stats(i).CMC, 2)]);
        ylim([0 100]);
        set(gca,'YTick',[0:10:100]);
        
        % Set legend
        if ~isempty(pars.legend)
            legend(pars.legend{:}, 'Location', 'SouthEast');
        end
        
        % Set title
        title('Cumulative Matching Characteristic (CMC)');
        hold off

        % Set custom style
        set_label_sytle(handles.cmc, pars.labelFontSize, pars.labelFontWeight, pars.fullScreen);
    end
    
    
    %% SRR
    if isfield(stats, 'SRR')
        handles.srr = figure;
        hold on;
        for i=1:length(stats)
            M = 1:size(stats(i).SRR,2);
            plot(M,mean(stats(i).SRR,1), style{i}, 'Color', cmap(i,:), 'LineWidth', pars.lineWidth);
        end
        grid on;
        axis([min(M),max(M),0,100]);
        axis square;
        
        % Set legend
        if ~isempty(pars.legend)
            legend(pars.legend{:}, 'Location', 'SouthWest');
        end
        
        % Set title
        title('Synthetic Recognition Rate (SRR)');
        hold off;

        % Set custom style
        set_label_sytle(handles.srr, pars.labelFontSize, pars.labelFontWeight, pars.fullScreen);
   end
end


end

function [] = set_label_sytle(handle, labelFontSize, labelFontWeight, fullScreen)
switch nargin
    case 1
        labelFontSize = 14;
        labelFontWeight = 'normal';
        fullScreen = false;
    case 2
        labelFontWeight = 'normal';
        fullScreen = false;
    case 3
        fullScreen = false;
end

if isempty(labelFontWeight)
    labelFontWeight = 'normal';
end

% Set label style
figure(handle)
set(findall(handle,'type','text'),'fontSize', labelFontSize,'fontWeight', labelFontWeight)
set(gca,'FontSize', labelFontSize, 'fontWeight', labelFontWeight)

% Make figure full screen
if fullScreen
    set(handle, 'units','normalized','outerposition',[0 0 1 1]);
end

end