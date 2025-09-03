
clc
close all

ERP_GUI





























%%

function x = ERP_GUI()

if~contains(path,'Z:\Functions_and_scripts\Matlab\fieldtrip-20230309')
addpath('Z:\Functions_and_scripts\Matlab\fieldtrip-20230309')
ft_defaults
end

    % Initialize output
    x = [];

    % Create UI figure
    fig = uifigure('Name', 'Trial Selector', 'Position', [500 500 300 150]);

    % Create "All Trials" button
    uibutton(fig, 'push', ...
        'Text', 'All Trials', ...
        'Position', [50 80 200 30], ...
        'ButtonPushedFcn', @(btn,event) buttonPressed('all'));

    % Create "Slow Wave Trials" button
    uibutton(fig, 'push', ...
        'Text', 'Slow Wave Trials', ...
        'Position', [50 30 200 30], ...
        'ButtonPushedFcn', @(btn,event) buttonPressed('slow'));

    % Wait for user input
    uiwait(fig);

    % Button callback
    function buttonPressed(selection)
        switch selection
            case 'all'
                x = 'all trials';
                                        close(fig);      % Close the GUI

                alltrials_gui

            case 'slow'
                x = 'slow wave trials';
                                        close(fig);      % Close the GUI

                swtrials_gui

        end
        %uiresume(fig);   % Resume execution
        %close(fig);      % Close the GUI
    end
end

function alltrials_gui

    % Create a UI figure
    fig = uifigure('Position', [500 300 400 420], 'Name', 'Simple GUI');

    uilabel(fig, 'Text', 'Select vigilance state and stimulus modalities:', ...
        'Position', [30, 340, 300, 22]);

    % === Stimulation checkboxes ===
      % === Stimulation checkboxes ===
    cb1 = uicheckbox(fig, 'Text', 'Visual', 'Position', [180, 310, 150, 22]);
    cb2 = uicheckbox(fig, 'Text', 'Auditory', 'Position', [180, 290, 150, 22]);
    cb3 = uicheckbox(fig, 'Text', 'Tactile', 'Position', [180, 270, 150, 22]);
    cb4 = uicheckbox(fig, 'Text', 'Visual vs Auditory', 'Position', [180, 250, 150, 22]);
    cb5 = uicheckbox(fig, 'Text', 'Visual vs Tactile', 'Position', [180, 230, 150, 22]);
    cb6 = uicheckbox(fig, 'Text', 'Auditory vs Tactile', 'Position', [180, 210, 150, 22]);
    cb7 = uicheckbox(fig, 'Text', 'All Modalities', 'Position', [180, 190, 150, 22]);

    cbGroup = [cb1, cb2, cb3, cb4, cb5, cb6, cb7];
    for cb = cbGroup
        cb.ValueChangedFcn = @(src, event) toggleCheckbox(src, cbGroup);
    end

    % === Vigilance state checkboxes ===
    cbb1 = uicheckbox(fig, 'Text', 'W', 'Position', [30, 310, 100, 22]);
    cbb2 = uicheckbox(fig, 'Text', 'N1', 'Position', [30, 290, 100, 22]);
    cbb3 = uicheckbox(fig, 'Text', 'N2', 'Position', [30, 270, 100, 22]);
    cbb4 = uicheckbox(fig, 'Text', 'N3', 'Position', [30, 250, 100, 22]);
    cbb5 = uicheckbox(fig, 'Text', 'R',  'Position', [30, 230, 100, 22]);
    cbbGroup = [cbb1, cbb2, cbb3, cbb4, cbb5];
    for cbb = cbbGroup
        cbb.ValueChangedFcn = @(src, event) toggleCheckbox(src, cbbGroup);
    end

    % === Corrections ===
    uilabel(fig, 'Text', 'Corrections:', 'Position', [30, 150, 100, 22]);
    corr1 = uicheckbox(fig, 'Text', 'None', 'Position', [30, 130, 100, 22]);
    corr2 = uicheckbox(fig, 'Text', 'FDR', 'Position', [100, 130, 100, 22]);
    corr3 = uicheckbox(fig, 'Text', 'Bonferroni', 'Position', [160, 130, 100, 22]);
    corrGroup = [corr1, corr2, corr3];
    for corr = corrGroup
        corr.ValueChangedFcn = @(src, event) toggleCheckbox(src, corrGroup);
    end

    % === Lateralise ===
    uilabel(fig, 'Text', 'Lateralise?', 'Position', [30, 100, 100, 22]);
    lat1 = uicheckbox(fig, 'Text', 'yes', 'Position', [30, 80, 100, 22]);
    lat2 = uicheckbox(fig, 'Text', 'no',  'Position', [100, 80, 100, 22]);
    latGroup = [lat1, lat2];
    for lat = latGroup
        lat.ValueChangedFcn = @(src, event) toggleCheckbox(src, latGroup);
    end

 % === Smoothing slider ===
uilabel(fig, 'Text', 'Smoothing (ms):', 'Position', [30, 50, 120, 22]);

% Value display label (initially set to 0)
smoothingValueLabel = uilabel(fig, ...
    'Position', [360, 50, 30, 22], ...
    'Text', '0');

% Slider control
smoothingSlider = uislider(fig, ...
    'Position', [150, 60, 200, 3], ...
    'Limits', [0 100], ...
    'MajorTicks', 0:20:100, ...
    'MinorTicks', 0:2:100, ...
    'Value', 0, ...
    'ValueChangedFcn', @(sld, event) updateSmoothingLabel(sld, smoothingValueLabel));


    % === Run Button ===
    uibutton(fig, 'push', 'Text', 'Run', ...
        'Position', [30, 370, 100, 30], ...
    'ButtonPushedFcn', @(btn, event) runERP(fig, cbGroup, cbbGroup, corrGroup, latGroup, smoothingSlider));

    % === Close Button ===
    uibutton(fig, 'push', 'Text', 'Close', ...
        'Position', [270, 370, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) closeWindow(fig));


end
% 
% function toggleCheckbox(selectedCb, groupCbs)
%     if selectedCb.Value
%         for cb = groupCbs
%             if cb ~= selectedCb
%                 cb.Value = false;
%             end
%         end
%     end
% end

function swtrials_gui

    % Create a UI figure
    fig = uifigure('Position', [500 300 400 420], 'Name', 'Simple GUI');

    uilabel(fig, 'Text', 'Select vigilance state and stimulus modalities:', ...
        'Position', [30, 340, 300, 22]);

       % === Stimulation checkboxes ===
    cb1 = uicheckbox(fig, 'Text','Null' , 'Position', [180, 310, 150, 22]);
    cb2 = uicheckbox(fig, 'Text', 'Visual', 'Position', [180, 290, 150, 22]);
    cb3 = uicheckbox(fig, 'Text', 'Auditory', 'Position', [180, 270, 150, 22]);
    cb4 = uicheckbox(fig, 'Text', 'Tactile', 'Position', [180, 250, 150, 22]);
    cb5 = uicheckbox(fig, 'Text', 'Visual vs Null', 'Position', [180, 230, 150, 22]);
    cb6 = uicheckbox(fig, 'Text', 'Auditory vs Null', 'Position', [180, 210, 150, 22]);
    cb7 = uicheckbox(fig, 'Text', 'Tactile vs Null', 'Position', [180, 190, 150, 22]);
    cb8 = uicheckbox(fig, 'Text', 'All Modalities', 'Position', [180, 170, 150, 22]);

    cbGroup = [cb1, cb2, cb3, cb4, cb5, cb6, cb7, cb8];
    for cb = cbGroup
        cb.ValueChangedFcn = @(src, event) toggleCheckbox(src, cbGroup);
    end  

    % === Vigilance state checkboxes ===
    % cbb1 = uicheckbox(fig, 'Text', 'W', 'Position', [30, 310, 100, 22]);
    % cbb2 = uicheckbox(fig, 'Text', 'N1', 'Position', [30, 290, 100, 22]);
    cbb1 = uicheckbox(fig, 'Text', 'N2', 'Position', [30, 310, 100, 22]);
    cbb2 = uicheckbox(fig, 'Text', 'N3', 'Position', [30, 290, 100, 22]);
    % cbb5 = uicheckbox(fig, 'Text', 'R',  'Position', [30, 230, 100, 22]);
    cbbGroup = [cbb1, cbb2];
    for cbb = cbbGroup
        cbb.ValueChangedFcn = @(src, event) toggleCheckbox(src, cbbGroup);
    end

    % === SW threshold checkboxes ===
    
    cbbb1 = uicheckbox(fig, 'Text', '<75 uV', 'Position', [30, 250, 100, 22]);
    cbbb2 = uicheckbox(fig, 'Text', '>75 uV', 'Position', [30, 230, 100, 22]);
    cbbb3 = uicheckbox(fig, 'Text', '>100 uV', 'Position', [30, 210, 100, 22]);
    cbbb4 = uicheckbox(fig, 'Text', '>125 uV', 'Position', [30, 190, 100, 22]);
    cbbb5 = uicheckbox(fig, 'Text', 'all', 'Position', [30, 170, 170, 22]);

    cbbbGroup = [cbbb1, cbbb2,cbbb3, cbbb4,cbbb5];
    for cbbb = cbbbGroup
        cbbb.ValueChangedFcn = @(src, event) toggleCheckbox(src, cbbbGroup);
    end


    % === Corrections ===
    uilabel(fig, 'Text', 'Corrections:', 'Position', [30, 150, 100, 22]);
    corr1 = uicheckbox(fig, 'Text', 'None', 'Position', [30, 130, 100, 22]);
    corr2 = uicheckbox(fig, 'Text', 'FDR', 'Position', [100, 130, 100, 22]);
    corr3 = uicheckbox(fig, 'Text', 'Bonferroni', 'Position', [160, 130, 100, 22]);
    corrGroup = [corr1, corr2, corr3];
    for corr = corrGroup
        corr.ValueChangedFcn = @(src, event) toggleCheckbox(src, corrGroup);
    end

    % === Lateralise ===
    uilabel(fig, 'Text', 'Lateralise?', 'Position', [30, 100, 100, 22]);
    lat1 = uicheckbox(fig, 'Text', 'yes', 'Position', [30, 80, 100, 22]);
    lat2 = uicheckbox(fig, 'Text', 'no',  'Position', [100, 80, 100, 22]);
    latGroup = [lat1, lat2];
    for lat = latGroup
        lat.ValueChangedFcn = @(src, event) toggleCheckbox(src, latGroup);
    end

 % === Smoothing slider ===
uilabel(fig, 'Text', 'Smoothing (ms):', 'Position', [30, 50, 120, 22]);

% Value display label (initially set to 0)
smoothingValueLabel = uilabel(fig, ...
    'Position', [360, 50, 30, 22], ...
    'Text', '0');

% Slider control
smoothingSlider = uislider(fig, ...
    'Position', [150, 60, 200, 3], ...
    'Limits', [0 100], ...
    'MajorTicks', 0:20:100, ...
    'MinorTicks', 0:2:100, ...
    'Value', 0, ...
    'ValueChangedFcn', @(sld, event) updateSmoothingLabel(sld, smoothingValueLabel));


    % === Run Button ===
    uibutton(fig, 'push', 'Text', 'Run', ...
        'Position', [30, 370, 100, 30], ...
    'ButtonPushedFcn', @(btn, event) runERP2(fig, cbGroup, cbbGroup, corrGroup, latGroup, smoothingSlider,cbbbGroup));

    % === Close Button ===
    uibutton(fig, 'push', 'Text', 'Close', ...
        'Position', [270, 370, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) closeWindow(fig));


end

function toggleCheckbox(selectedCb, groupCbs)
    if selectedCb.Value
        for cb = groupCbs
            if cb ~= selectedCb
                cb.Value = false;
            end
        end
    end
end


function closeWindow(figHandle)
    delete(figHandle);
end

function updateSmoothingLabel(slider, label)
    label.Text = num2str(round(slider.Value));
end


function runERP(fig, cbGroup, cbbGroup, corrGroup, latGroup, smoothingSlider)
    stim_label = getSelected(cbGroup);
    vigil_label = getSelected(cbbGroup);
    corr_label = getSelected(corrGroup);
    lat_label = getSelected(latGroup);
    smoothing = smoothingSlider.Value;

    % Mappings
    stim_map = containers.Map({'Visual', 'Auditory', 'Tactile', ...
                               'Visual vs Auditory', 'Visual vs Tactile', ...
                               'Auditory vs Tactile', 'All Modalities'}, ...
                              {1, 2, 3, [1 2], [1 3], [2 3], [1 2 3]});
    vigil_map = containers.Map({'W', 'N1', 'N2', 'N3', 'R'}, {1, 2, 3, 4, 5});
    corr_map = containers.Map({'None', 'FDR', 'Bonferroni'}, {0, 1, 2});
    lat_map = containers.Map({'yes', 'no'}, {1, 0});

    % Convert to numeric values
    stim  = getMappedValue(stim_map, stim_label);
    vigil = getMappedValue(vigil_map, vigil_label);
    corr  = getMappedValue(corr_map, corr_label);
    lat   = getMappedValue(lat_map, lat_label);

    if any(isnan([stim, vigil, corr, lat]))
        uialert(fig, 'Please make a selection in all categories.', 'Missing Input');
        return;
    end

    % Call ERP processor
    Y = ERP_loadr(fig, stim, vigil, corr, lat, smoothing);

load('\\vs03\VS03-SandD-3\KCs\layout.mat');
load('\\vs03\VS03-SandD-3\KCs\RBG.mat');
colors = colors(stim,:);
stim_names = {'visual'; 'auditory'; 'tactile'};

% Call plotting function
ERP_plotr(Y, stim, vigil, corr, lat, smoothing, layout, colors,stim_names);
   
end

function runERP2(fig, cbGroup, cbbGroup, corrGroup, latGroup, smoothingSlider,cbbbGroup)
    stim_label = getSelected(cbGroup);
    vigil_label = getSelected(cbbGroup);
    corr_label = getSelected(corrGroup);
    lat_label = getSelected(latGroup);
    smoothing = smoothingSlider.Value;
    thresh_label = getSelected(cbbbGroup);

    % Mappings
    stim_map = containers.Map({'Null','Visual', 'Auditory', 'Tactile', ...
                               'Visual vs Null', 'Auditory vs Null', ...
                               'Tactile vs Null', 'All Modalities'}, ...
                              {1, 2, 3, 4, [1 2], [1 3], [1 4], [1 2 3 4]});

    vigil_map = containers.Map({'N2', 'N3'}, {1, 2});
    corr_map = containers.Map({'None', 'FDR', 'Bonferroni'}, {0, 1, 2});
    lat_map = containers.Map({'yes', 'no'}, {1, 0});
    thresh_map = containers.Map({'<75 uV';'>75 uV';'>100 uV';'>125 uV';'all'}, {1, 2,3,4,5});


    % Convert to numeric values
    stim  = getMappedValue(stim_map, stim_label);
    vigil = getMappedValue(vigil_map, vigil_label);
    corr  = getMappedValue(corr_map, corr_label);
    lat   = getMappedValue(lat_map, lat_label);
    thresh = getMappedValue(thresh_map, thresh_label);

    if any(isnan([stim, vigil, corr, lat]))
        uialert(fig, 'Please make a selection in all categories.', 'Missing Input');
        return;
    end

    % Call ERP processor
    Y = ERP_loadr2(fig, stim, vigil, corr, lat, smoothing,thresh);

load('\\vs03\VS03-SandD-3\KCs\layout.mat');
load('\\vs03\VS03-SandD-3\KCs\RBG.mat');
colors = [.5 .5 .5;colors];
colors = colors(stim,:);
stim_names = {'null';'visual'; 'auditory'; 'tactile'};

% Call plotting function
ERP_plotr(Y, stim, vigil, corr, lat, smoothing, layout, colors,stim_names);
   
end


function selection = getSelected(group)
    selected = group(cellfun(@(c) c.Value, num2cell(group)));
    if ~isempty(selected)
        selection = selected.Text;
    else
        selection = 'none';
    end
end

function value = getMappedValue(mapObj, label)
    if mapObj.isKey(label)
        value = mapObj(label);
    else
        value = NaN;
    end
end

function Y = ERP_loadr(fig, stim, vigil, corr, lat, smoothing)
    dlg = uiprogressdlg(fig, ...
        'Title', 'Loading', ...
        'Message', 'Loading ERP data...', ...
        'Indeterminate', 'on');

    drawnow; % Force GUI update

    stim_names = {'visual';'auditory';'tactile'};
    stage_name = {'W';'N1';'N2';'N3';'R'};

    load('\\vs03\VS03-SandD-3\KCs\rvrse.mat');

    S = 1;
    for s = stim
        if vigil == 1
            load(['\\vs03\vs03-sandd-3\KCs\Data_analysis\tidy_analysis\data\erp\wake\group_', stim_names{s}, '.mat']);
        else
            load(['\\vs03\VS03-SandD-3\KCs\Data_analysis\tidy_analysis\data\erp\sleep\group_', stim_names{s}, '_', stage_name{vigil}, '.mat']);
        end

        if smoothing >0
        y = movmean(y(:,500:2000,~isnan(y(1,1,:))),smoothing/2,2);
        else
        y = y(:,500:2000,~isnan(y(1,1,:)));

        end
        if lat == 1
            Y{S} = y - y(rvrse,:,:);
        else
            Y{S} = y;
        end
        S = S + 1;
    end

    pause(0.5); % Optional delay to let user see progress
    close(dlg); % Automatically close the progress dialog
    close(fig)
end

function Y = ERP_loadr2(fig, stim, vigil, corr, lat, smoothing,thresh)
    dlg = uiprogressdlg(fig, ...
        'Title', 'Loading', ...
        'Message', 'Loading ERP data...', ...
        'Indeterminate', 'on');

    drawnow; % Force GUI update

    stim_names = {'null';'visual';'auditory';'tactile'};
    stage_name = {'N2';'N3'};
    thresh_name = {'under75uV';'over75uV';'over100uV';'over125uV';'all'};
    load('\\vs03\VS03-SandD-3\KCs\rvrse.mat');

    S = 1;
    for s = stim
        
            load(['\\vs03\VS03-SandD-3\KCs\Data_analysis\tidy_analysis\data\erp\sleep\group_',thresh_name{thresh},'_slow_waves', stim_names{s}, '_', stage_name{vigil}, '.mat']);
        

        if smoothing >0
        y = movmean(y(:,:,~isnan(y(1,1,:))),smoothing/2,2);
        else
        y = y(:,:,~isnan(y(1,1,:)));

        end
        if lat == 1
            Y{S} = y - y(rvrse,:,:);
        else
            Y{S} = y;
        end
        S = S + 1;
    end

    pause(0.5); % Optional delay to let user see progress
    close(dlg); % Automatically close the progress dialog
    close(fig)
end


function ERP_plotr(y, stim, vigil, corr, lat, smoothing, layout, colors,stim_names)


addpath('Z:\Functions_and_scripts\Matlab\Henry')
stim_names = {stim_names{stim}};

 if length(stim)==2
     stim_names{end+1} = [stim_names{1},' vs ',stim_names{2}];
     colors(3,:) = [0 0 0];
          y{3} = y{1}-y{2};

 end


if lat == 1
    chans = 183;
else
    chans = 257;
end

Ntime = size(y{1}, 2);

fig = figure('units', 'normalized', 'Position', [0 0 1 1]);%,'Renderer','painters');
set(fig, 'KeyPressFcn', @onKeyPress);

% Initialize selectedChannels appdata with first channel as default
setappdata(fig, 'selectedChannels', chans(1));  
setappdata(fig, 'prevSelectedChannels', []);

setappdata(fig, 'isPlaying', false);
setappdata(fig, 'playTimer', []);

playInterval = 0.01;

dim = [.625 .525 .3 .3;.625 .225 .3 .3;.625 0 .3 .3];

for s = 1:numel(stim_names)

 annotation('textbox',dim(s,:),'String',stim_names{s},'FitBoxToText','on','color',colors(s,:),'FontWeight','bold');

end

axERP = subplot(1, 2, 1);
hold(axERP, 'on');
set(axERP, 'YDir', 'reverse');
set(axERP, 'ButtonDownFcn', @onERPClick);
title(axERP, 'ERP Plot');
xlabel(axERP, 'Time (samples)');
ylabel(axERP, 'Amplitude');

axTopo = gobjects(1, numel(y));
I = 2;
for i = 1:numel(y)
    axTopo(i) = subplot(3, 2, I);
    I = I + 2;
    axis(axTopo(i), 'square');
    axis(axTopo(i), 'off');
end

uicontrol('Style', 'text', 'String', 'Time Index', ...
    'Units', 'normalized', 'Position', [0.5 0.1 0.1 0.03], 'FontSize', 12);

slider = uicontrol('Style', 'slider', 'Min', 1, 'Max', Ntime, ...
    'Value', round(Ntime/3), 'SliderStep', [1/(Ntime-1), 0.1], ...
    'Units', 'normalized', 'Position', [0.6 0.1 0.3 0.03], ...
    'Callback', @updatePlots);

dat = cell(1, numel(y));
for i = 1:numel(y)
    dat{i} = nanmean(y{i}, 3);
end

peas = cell(1,numel(y));
for i = 1:numel(y)
    [~, p, ~, ~] = ttest(permute(y{i}, [3 1 2]));
    if corr == 1
        peas{i} = squeeze(p);
    elseif corr == 2
        [~, ~, ~, adj_p] = fdr_bh(squeeze(p));
        peas{i} = adj_p;
    else
        peas{i} = squeeze(p*257);
    end
end

minval = cell(1, numel(y));
maxval = cell(1, numel(y));
isol = cell(1, numel(y));
for i = 1:numel(y)
    allVals = reshape(dat{i},1,[]);
    minval{i} = -max(abs(allVals));
    maxval{i} = max(abs(allVals));
    scale = 0.1 * range(allVals);
    minval{i} = floor(minval{i}/scale) * scale;
    maxval{i} = ceil(maxval{i}/scale) * scale;
    isol{i} = minval{i}:scale:maxval{i};
end

updatePlots();
figure(fig);

% ========== NESTED FUNCTIONS ==========

   function updatePlots(~, ~)
    time = round(get(slider, 'Value'));
    axes(axERP);
sc = [];
    % Get and ensure unique channels
    selCh = unique(getappdata(fig,'selectedChannels'));
    prevCh = getappdata(fig,'prevSelectedChannels');
    if isempty(prevCh), prevCh = []; end

    % **Clear & redraw ERP lines only when channel list changes**
    if ~isequal(selCh, prevCh)
       % cla(axERP); hold(axERP,'on');
        delete(findall(axERP, '-regexp', 'Tag', '^ERPLine_'));
delete(sc)
hold(axERP,'on');
        for iCond = 1:length(stim)%numel(y)
            for ch = selCh
                data = squeeze(y{iCond}(ch,:,:));
                meanERP = mean(data,2);
                stdErr = std(data,0,2)/sqrt(size(data,2));
      % sc{iCond} = scatter([find(peas{iCond}(ch,:)<.05) find(peas{iCond}(ch,:)<.05)], ... 
      %     [meanERP(peas{iCond}(ch,:)<.05)+stdErr(peas{iCond}(ch,:)<.05); meanERP(peas{iCond}(ch,:)<.05)-stdErr(peas{iCond}(ch,:)<.05)],15,colors(iCond,:),'filled');

sc{iCond} = scatter([find(peas{iCond}(ch,:)<.05)], ... 
          [meanERP(peas{iCond}(ch,:)<.05)],15,colors(iCond,:),'filled');

set(sc{iCond}, 'HandleVisibility', 'off');  % Prevents it from showing in legend

                h = shadedErrorBar(1:Ntime, meanERP, stdErr, ...
    'lineprops', {'color', colors(iCond,:)}, ...
    'patchSaturation', 0.4);


set(h.mainLine, 'ButtonDownFcn', @onERPClick, ...
    'HitTest','on','PickableParts','all', ...
    'Tag', 'ERPLine_');  % Tag for deletion


if isfield(h, 'patch') && all(isvalid(h.patch))
    set(h.patch, 'Tag', 'ERPLine_');
end
if isfield(h, 'edge') && all(isvalid(h.edge))
    set(h.edge, 'Tag', 'ERPLine_');
end
            
set(sc{iCond},'Tag','ERPLine_')

            end
        end
        xticks(1:50:2000)
        xticklabels(0:100:4000)
                                setappdata(fig,'prevSelectedChannels', selCh);

    end



    % Add or update vertical time line without stacking
    delete(findobj(axERP,'Tag','TimeLine'));
    yl = ylim(axERP);
    line([time time], yl, 'Color','k','LineWidth',1.1,'Tag','TimeLine');

    title(axERP, sprintf('ERP at channels: %s', mat2str(selCh)));
    legend(axERP, stim_names); xlabel(axERP,'Time'); ylabel(axERP,'Amplitude');


        % Topoplots 
        for i = 1:numel(y)
            axes(axTopo(i)); 
            cla(axTopo(i)); 
            hold(axTopo(i), 'on');

if i == 1
    title([num2str((time)*2),' ms'])
end
            ft_plot_topo(layout.pos(:,1), layout.pos(:,2), dat{i}(:, time), ...
                'mask', layout.mask, ...
                'outline', layout.outline, ...
                'interplim', 'mask', ...
                'gridscale', 30, ...
                'clim', [minval{i} maxval{i}], ...
                'isolines', isol{i});

            ft_hastoolbox('brewermap', 1);
            colormap(axTopo(i), flipud(brewermap(64, 'RdBu')));
            axis(axTopo(i), 'off'); 
            axis(axTopo(i), 'square');
            colorbar

            sigIdx = peas{i}(:, time) < 0.05;
            scatter(layout.pos(sigIdx, 1), layout.pos(sigIdx, 2), 15, 'k', 'filled');

    selCh = unique(getappdata(fig,'selectedChannels'));

            if ~isempty(selCh)
                for chSel = selCh
                    pos = layout.pos(chSel, :);
                    scatter(pos(1), pos(2), 50, [.5 .5 .5],'LineWidth',2);%, 'filled');
                end
            end

            children = get(axTopo(i), 'Children');
            for c = 1:length(children)
                set(children(c), 'ButtonDownFcn', @(src,event) onTopoClick(src, event, i), ...
                    'HitTest', 'on', 'PickableParts', 'all');
            end
        end
    end

    function onTopoClick(~, ~, topoIdx)
        selectedChannels = getappdata(fig, 'selectedChannels');
        clickPoint = get(axTopo(topoIdx), 'CurrentPoint');
        clickX = clickPoint(1,1);
        clickY = clickPoint(1,2);
        distances = sqrt((layout.pos(:,1) - clickX).^2 + (layout.pos(:,2) - clickY).^2);
        [~, closestChan] = min(distances);

        selType = get(fig, 'SelectionType');
        if strcmp(get(fig, 'SelectionType'), 'normal')
    % LEFT click replaces previous selection with new channel
    selectedChannels = closestChan;
end

        setappdata(fig, 'selectedChannels', unique(selectedChannels));
        updatePlots();
    end

    function onERPClick(~, ~)
        clickPoint = get(axERP, 'CurrentPoint');
        clickTime = round(clickPoint(1,1));
        if clickTime >= 1 && clickTime <= Ntime
            set(slider, 'Value', clickTime);
            updatePlots();
        end
    end

    function onKeyPress(~, event)
        time = round(get(slider, 'Value'));
        isPlaying = getappdata(fig, 'isPlaying');
        playTimer = getappdata(fig, 'playTimer');

        switch event.Key
            case 'leftarrow'
                time = max(1, time - 1);
                set(slider, 'Value', time);
                updatePlots();
            case 'rightarrow'
                time = min(Ntime, time + 1);
                set(slider, 'Value', time);
                updatePlots();
            case 'space'
                if isPlaying
                    if ~isempty(playTimer) && isvalid(playTimer)
                        stop(playTimer);
                        delete(playTimer);
                    end
                    setappdata(fig, 'isPlaying', false);
                    setappdata(fig, 'playTimer', []);
                    disp('Paused');
                else
                    newTimer = timer( ...
                        'ExecutionMode', 'fixedRate', ...
                        'Period', playInterval, ...
                        'TimerFcn', @(~,~) playStep());
                    setappdata(fig, 'playTimer', newTimer);
                    setappdata(fig, 'isPlaying', true);
                    start(newTimer);
                    disp('Playing...');
                end
        end
    end

    function playStep()
        if ~isvalid(fig)
            return;
        end
        time = round(get(slider, 'Value'));
        if time < Ntime
            set(slider, 'Value', time + 1);
            updatePlots();
        else
            playTimer = getappdata(fig, 'playTimer');
            if ~isempty(playTimer) && isvalid(playTimer)
                stop(playTimer);
                delete(playTimer);
            end
            setappdata(fig, 'isPlaying', false);
            setappdata(fig, 'playTimer', []);
        end
    end

end


%}