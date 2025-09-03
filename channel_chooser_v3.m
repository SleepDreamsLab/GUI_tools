
function [z, DONE, quality, ICA_repeat] = channel_chooser_sleep(Y, layout, columnNames, badall, data)
    G = 80;
    % Initialize variables
    quality = 3;    % Default value for quality (slider will be centered at 3)
    ICA_repeat = false; % Default for repeat ICA button
    colorLimitFactor = 1;  % Default factor for color limits
    if ~isempty(badall)
        prev_int = [];
        for b = 1:numel(badall)
            prev_int = [prev_int badall{b}];
        end
        prev_int = unique(prev_int);
        prev_int = ismember(layout.label, prev_int);
    else
        prev_int = zeros(size(Y,1), 1);
    end

    % Check if Y is a 2D matrix
    if size(Y, 2) < 1
        error('Y must be a 2D matrix with at least one column.');
    end

    % Check if the number of column names matches the number of columns in Y
    if length(columnNames) ~= size(Y, 2)
        error('The number of column names must match the number of columns in Y.');
    end
    
    % Initial setup
    x = layout.pos(:, 1);
    y = layout.pos(:, 2);
    labels = layout.label;
    
    % Ensure consistency in lengths
    if length(x) ~= length(y) || length(x) ~= length(labels)
        error('x, y, and labels must be the same length.');
    end
    
    % Create a figure window with KeyPressFcn to handle keyboard input
    f = figure('Name', 'Scatter Click Plot', 'NumberTitle', 'off', ...
        'WindowButtonDownFcn', @onClick, 'KeyPressFcn', @onKeyPress, 'renderer', 'painters', ...
        'units', 'normalized', 'Position', [0 0 1 1]);
    hold on;
    
    % Initialize column index
    currentColumn = 1;
    
    % Initialize slice index (default slice is 1)
    currentSlice = 1;

    % Initialize the variable to store selected labels
    z = {};
    selectedPoints = [];  % To keep track of left-click selected points (red)
    blueSelectedPoints = [];  % To keep track of right-click selected points (blue)
    hRedScatter = [];     % To store the red scatter points
    hBlueScatter = [];    % To store the blue scatter points
    hTopoPlot = [];       % To store the topographical plot handle
    hScatter = [];        % Handle for scatter plot
    
    % Create the "Iterate" and "Done" buttons side by side
    uicontrol('Style', 'pushbutton', 'String', 'Iterate', 'units', 'normalized', 'Position', [.75 .05 .1 .1], ...
        'Callback', @(src, event) closeGui(0));  % Iterate button, DONE = 0
    uicontrol('Style', 'pushbutton', 'String', 'Done', 'units', 'normalized', 'Position', [.875 .05 .1 .1], ...
        'Callback', @(src, event) closeGui(1));  % Done button, DONE = 1
    
    % Create a Listbox for the selected channels
    hListBox = uicontrol('Style', 'listbox', 'units', 'normalized', 'Position', [.75, .2, .225, .8], ...
        'String', {}, 'Max', 10, 'FontSize', 10);
    
    % Create buttons to switch between columns of Y (one button per column name)
    numColumns = length(columnNames);
    buttonHeight = 0.08;  % Height of each button
    buttonSpacing = 0.02;  % Spacing between buttons
    
    for i = 1:numColumns
        uicontrol('Style', 'pushbutton', 'String', columnNames{i}, 'units', 'normalized', ...
            'Position', [0.05, 1 - i * (buttonHeight + buttonSpacing), 0.1, buttonHeight], ...
            'Callback', @(src, event) changeColumn(i));
    end

    sliceNames = {'W'; 'N1'; 'N2'; 'N3'; 'R'}; 
    % Create buttons to switch between slices of Y (one button per slice name)
    numSlices = size(Y,3);  %length(sliceNames);  % Assuming 5 slices as per your array
    buttonHeight = 0.08;  % Height of each button
    buttonSpacing = 0.02;  % Spacing between buttons
    
    for i = 1:numSlices
        uicontrol('Style', 'pushbutton', 'String', sliceNames{i}, 'units', 'normalized', ...
            'Position', [0.15, 1 - i * (buttonHeight + buttonSpacing), 0.1, buttonHeight], ...
            'Callback', @(src, event) changeSlice(i));  % Change to changeSlice callback

        %currentSlice =i;
    end

    % Create a slider for "quality"
    uicontrol('Style', 'text', 'String', 'Quality', 'units', 'normalized', 'Position', [.05 .1 .1 .05], 'FontSize', 12);
    hSlider = uicontrol('Style', 'slider', 'units', 'normalized', 'Position', [.05 .05 .2 .05], ...
        'Min', 1, 'Max', 5, 'Value', quality, 'SliderStep', [1/4, 1/4], 'Callback', @(src, event) updateQuality(src));
    % Display the initial value of quality
    hSliderValue = uicontrol('Style', 'text', 'String', num2str(quality), 'units', 'normalized', ...
        'Position', [.25 .05 .05 .05], 'FontSize', 12);
    
    % Create the "Repeat ICA" button
    uicontrol('Style', 'pushbutton', 'String', 'Repeat ICA', 'units', 'normalized', ...
        'Position', [.4 .05 .1 .1], 'Callback', @(src, event) repeatICA());
    
    % Create the "Show Signals" button
    uicontrol('Style', 'pushbutton', 'String', 'Show Signals', 'units', 'normalized', ...
        'Position', [.5 .05 .1 .1], 'Callback', @(src, event) showSignals(currentSlice));

    
    % Start by displaying the first column
    updatePlot(currentColumn, currentSlice);
    
    % Wait for user input until the "Iterate" or "Done" button is clicked
    uiwait(f);

    % Nested function to handle the click event
    function onClick(~, ~)
        % Get the current point on the plot
        clickPos = get(gca, 'Currentpoint');
        clickX = clickPos(1, 1);
        clickY = clickPos(1, 2);

        % Find the closest point to the clicked position
        distances = sqrt((x - clickX).^2 + (y - clickY).^2);
        [~, idx] = min(distances);  % Index of the closest point

        % Check if it was a left-click (1) or right-click (3)
        clickType = get(gcf, 'SelectionType');
        
        if strcmp(clickType, 'normal')  % Left-click (red)
            % Toggle selection (deselect if already selected)
            if ismember(idx, selectedPoints)
                selectedPoints(selectedPoints == idx) = [];  % Deselect the point
                z(strcmp(z, labels{idx})) = [];  % Remove from listbox
            else
                selectedPoints = [selectedPoints, idx];  % Add to selected points
                z = [z, labels(idx)];  % Add label to listbox
            end
        elseif strcmp(clickType, 'alt')  % Right-click (blue)
            % Toggle selection (deselect if already selected)
            if ismember(idx, blueSelectedPoints)
                blueSelectedPoints(blueSelectedPoints == idx) = [];  % Deselect the point
            else
                blueSelectedPoints = [blueSelectedPoints, idx];  % Add to selected points
            end
        end
        
        % Display the current selected points in the command window
        disp('Current selected labels:');
        disp(z);

        % Update the scatter plot (without clearing the figure)
        set(hScatter, 'XData', x, 'YData', y);
        hold on;

        % Remove previous scatter points if they exist
        if ~isempty(hRedScatter)
            delete(hRedScatter);
        end
        if ~isempty(hBlueScatter)
            delete(hBlueScatter);
        end
        
        % Highlight the selected red points
        hRedScatter = scatter(x(selectedPoints), y(selectedPoints), 25, 'r', 'filled', 'markerEdgeColor', 'k');
        
        % Highlight the selected blue points
        hBlueScatter = scatter(x(blueSelectedPoints), y(blueSelectedPoints), 25, 'b', 'filled', 'markerEdgeColor', 'k');
        
        hold off;
        
        % Reapply labels and title after updating
        xlabel('X-axis');
        ylabel('Y-axis');
        title('Click on the points to select/deselect');

        % Update the listbox with the selected channels
        set(hListBox, 'String', z);
    end

    function showSignals(currentSlice)
    % Constants
    fs = 500;  % Sampling rate (500 Hz)
    windowSize = 30 * fs;  % 30 seconds of data (30 * 500 = 15000 samples)
    totalTimePoints = size(data.trial{currentSlice}, 2);  % Total number of time points in the data
    currentTime = 1;  % Start from the first sample
    %Slice = currentSlice;
    % Create a new figure for interactive plotting
    fig = figure('Name', 'Signal Viewer', 'NumberTitle', 'off', ...
        'units','normalized','Position', [0 0 1 1],'renderer','painters', 'KeyPressFcn', @onKeyPress);

    % Initial plot (first 30 seconds)
    plotTimeSeries(currentTime,currentSlice);
    
    % Back button
    uicontrol('Style', 'pushbutton', 'String', 'Back 30s', ...
        'units', 'normalized', 'Position', [0.05, 0.05, 0.1, 0.05], ...
        'Callback', @(src, event) goBack());

    % Forward button
    uicontrol('Style', 'pushbutton', 'String', 'Forward 30s', ...
        'units', 'normalized', 'Position', [0.85, 0.05, 0.1, 0.05], ...
        'Callback', @(src, event) goForward());

   % Function to plot the current 30 seconds of data
        function plotTimeSeries(startIdx,currentSlice)
        % Calculate the range of indices for the current 30-second window
        endIdx = min(startIdx + windowSize - 1, totalTimePoints);  % Ensure it doesn't go beyond the data length
        
        % Create a time vector based on the sampling rate
        timeVec = (startIdx:endIdx) / fs;  % Time in seconds

        A = 0;
        
        % Plot the data for all selected channels (blue points)
        hold off;  % Clear previous plots
            R = range(reshape(data.trial{currentSlice}(blueSelectedPoints, startIdx:endIdx),1,[]));

        for i = 1:length(blueSelectedPoints)
            idx = blueSelectedPoints(i);
            if i == 1
            plot(timeVec, A+data.trial{currentSlice}(idx, startIdx:endIdx), 'LineWidth', 1,'color',[0 0 0]);
            else
            plot(timeVec, A+data.trial{currentSlice}(idx, startIdx:endIdx), 'LineWidth', 1);%,'color',[.5 .5 .5]);
            end
            hold on;
            A = A+R;
        end
        ylim([-R A])
        %ylim([-100 200])
        xlabel('Time (seconds)');
        ylabel('Amplitude');
        title('Timeseries of Selected Channels (Blue)');
        legend(labels(blueSelectedPoints), 'Location', 'Best');
    end

    % Go back 30 seconds
    function goBack()
        % Update the current time index to go back 30 seconds
        newTime = currentTime - windowSize;
        if newTime < 1
            newTime = 1;  % Prevent going before the start of the data
        end
        currentTime = newTime;
        plotTimeSeries(currentTime,currentSlice);  % Update plot
    end

    % Go forward 30 seconds
    function goForward()
        % Update the current time index to go forward 30 seconds
        newTime = currentTime + windowSize;
        if newTime + windowSize - 1 > totalTimePoints
            newTime = totalTimePoints - windowSize + 1;  % Prevent going beyond the end of the data
        end
        currentTime = newTime;
        plotTimeSeries(currentTime,currentSlice);  % Update plot
    end

    % Key press function to navigate the time window using arrow keys
    function onKeyPress(~, event)
        if strcmp(event.Key, 'rightarrow')  % Right Arrow Key
            goForward();
        elseif strcmp(event.Key, 'leftarrow')  % Left Arrow Key
            goBack();
        end
    end
end



    % Callback function to change the column of Y
    function changeColumn(newColumn)
        % Set the new column index (retain the current slice)
        currentColumn = newColumn;

        % Update the plot with the new column and the current slice
        updatePlot(currentColumn, currentSlice);
    end

    % Callback function to change the slice of Y
    function changeSlice(newSlice)
        % Set the new slice index
        currentSlice = newSlice;

        % Update the plot with the current column and the new slice
        updatePlot(currentColumn, currentSlice);


        
         uicontrol('Style', 'pushbutton', 'String', 'Show Signals', 'units', 'normalized', ...
        'Position', [.5 .05 .1 .1], 'Callback', @(src, event) showSignals(currentSlice));
    end




    % Function to update the plot with a specific column and slice of Y
    function updatePlot(columnIndex, sliceIndex)
        % Set up color limits for the plot
        if columnIndex == 6
            mm = [0 50 400];
        elseif columnIndex == 7
            mm = [0 1 5];
        elseif columnIndex == 8
            mm = [0 .1 1];
        else
            mm = [min(Y(:, columnIndex, sliceIndex)), 0.3 * range(Y(:, columnIndex, sliceIndex)), max(Y(:, columnIndex, sliceIndex))];
        end
        mm = mm * colorLimitFactor;

        % Redraw the topographical plot for the specified column and slice
        if ishandle(hTopoPlot)  % Check if hTopoPlot is valid before deleting
            delete(hTopoPlot);  % Remove the previous topographical plot if it exists
        end
        
        hTopoPlot = ft_plot_topo(layout.pos(:, 1), layout.pos(:, 2), Y(:, columnIndex, sliceIndex), 'mask', layout.mask, 'outline', layout.outline, ...
            'interplim', 'mask', 'clim', [mm(1), mm(3)], 'gridscale', G);  % Plot for the new column
        
        axis square;
        axis off;
        ft_hastoolbox('brewermap', 1);  % ensure this toolbox is on the path
        colormap(gca, brewermap(64, 'Reds'));  % Apply color map
        hold on;
        colorbar;

        if sum(prev_int) > 0
            scatter(x(prev_int), y(prev_int), 30, 'k');
        end

        % Initialize the scatter plot (hScatter) for the new column
        hScatter = scatter(x, y, 5, 'k', 'filled');

        % Highlight previously selected points (if any)
        if ~isempty(selectedPoints) || ~isempty(blueSelectedPoints)
            hold on;
            hRedScatter = scatter(x(selectedPoints), y(selectedPoints), 25, 'r', 'filled', 'markerEdgeColor', 'k');
            hBlueScatter = scatter(x(blueSelectedPoints), y(blueSelectedPoints), 25, 'b', 'filled', 'markerEdgeColor', 'k');
            hold off;
        end
        
        % Update the title to reflect the current column and slice
        title([sliceNames{sliceIndex}, ' ', columnNames{columnIndex}]);
    end

    % Close the GUI and set the DONE value
    function closeGui(value)
        DONE = value;  % Set DONE to 0 (Iterate) or 1 (Done)
        uiresume(f);  % Resume the execution of the GUI
        close(f);     % Close the figure
    end
end


%}



