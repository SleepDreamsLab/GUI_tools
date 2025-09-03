function awakening_checker
    % === Settings ===
    dataDirBase = '\\vs03\vs03-sandd-3\KCs\Data_analysis\tidy_analysis\data\tidy_awakenings\';
    nParticipants = 25;
    addpath('\\vs03\vs03-sandd-3\KCs\Data_analysis\tidy_analysis\tools');

    % === Create GUI ===
    f = figure('Position', [300 300 400 220], 'MenuBar', 'none', ...
               'Name', 'Awakening Selector', 'NumberTitle', 'off');

    % Generate participant IDs
    participantIDs = arrayfun(@(x) sprintf('H%03d', x), 1:nParticipants, 'UniformOutput', false);
    participantLabels = participantIDs;
    nightStatus = cell(nParticipants, 2); % To store '1 (completed)' etc

    % === Check completion status ===
    for i = 1:nParticipants
        pid = participantIDs{i};
        completeNights = [false, false];

        for night = 1:2
            nightPath = fullfile(dataDirBase, pid, ['night' num2str(night)]);
            if ~isfolder(nightPath)
                awk_num = 0;
                comp_num = 0;
            else
                files = dir(fullfile(nightPath, '*'));
                fileNames = {files.name};
                awk_num = sum(contains(fileNames, 'original'));
                comp_num = sum(contains(fileNames, 'events'));
            end

            if awk_num == comp_num && awk_num > 0
                completeNights(night) = true;
                nightStatus{i, night} = sprintf('%d (completed)', night);
            else
                nightStatus{i, night} = sprintf('%d (NOT COMPLETED)', night);
            end
        end

        if all(completeNights)
            participantLabels{i} = sprintf('%s (completed)', pid);
        else
            participantLabels{i} = sprintf('%s (NOT COMPLETED)', pid);
        end
    end

    % === UI: Participant Dropdown ===
    uicontrol('Style', 'text', 'Position', [30 180 100 20], 'String', 'Participant');
    participantMenu = uicontrol('Style', 'popupmenu', 'Position', [30 160 120 25], ...
        'String', participantLabels, 'Callback', @updateNightAndAwakenings);

    % === UI: Night Dropdown ===
    uicontrol('Style', 'text', 'Position', [160 180 100 20], 'String', 'Night');
    nightMenu = uicontrol('Style', 'popupmenu', 'Position', [160 160 100 25], ...
        'String', {'1','2'}, 'Callback', @nightChanged);

    % === UI: Awakening Dropdown ===
    uicontrol('Style', 'text', 'Position', [270 180 100 20], 'String', 'Awakening');
    awakeningMenu = uicontrol('Style', 'popupmenu', 'Position', [270 160 100 25], ...
        'String', {'1'});

    % === UI: FIX! Button ===
    uicontrol('Style', 'pushbutton', 'String', 'FIX!', 'Position', [150 80 100 30], ...
        'Callback', @fixCallback);

    % === Callback: When Participant Changes ===
    function updateNightAndAwakenings(~, ~)
        selectedIdx = participantMenu.Value;
        participant = extractBefore(participantMenu.String{selectedIdx}, ' ');
        if isempty(participant)
            participant = participantMenu.String{selectedIdx};
        end

        % Update night dropdown with per-night completion status
        nightMenu.String = {nightStatus{selectedIdx, 1}, nightStatus{selectedIdx, 2}};
        nightMenu.Value = 1;

        updateAwakenings();  % Load awakenings for default night
    end

    % === Callback: When Night Changes ===
    function nightChanged(~, ~)
        drawnow;  % Ensure GUI updates first
        updateAwakenings();
    end

    % === Update Awakening Dropdown ===
    function updateAwakenings(~, ~)
    drawnow;

    % Get participant ID
    selectedPart = participantMenu.String{participantMenu.Value};
    participant = extractBefore(selectedPart, ' ');
    if isempty(participant)
        participant = selectedPart;
    end

    % Get selected night (parsed from string like '1 (completed)')
    nightRaw = nightMenu.String{nightMenu.Value};
    night = regexp(nightRaw, '\d', 'match', 'once');

    % Folder path for selected participant and night
    nightPath = fullfile(dataDirBase, participant, ['night' night]);

    if ~isfolder(nightPath)
        awakeningMenu.String = {'1'};
        awakeningMenu.Value = 1;
        return;
    end

    % List all files in that night folder
    files = dir(fullfile(nightPath, '*'));
    fileNames = {files.name};

    % Count awakenings (originals)
    originalFiles = fileNames(contains(fileNames, 'original'));
    awk_num = sum(contains(originalFiles, 'awake'));  % Or just numel(originalFiles)

    if awk_num == 0
        awakeningMenu.String = {'1'};
        awakeningMenu.Value = 1;
        return;
    end

    % Build awakening labels: 1 to awk_num
    awakeningLabels = cell(1, awk_num);
    for k = 1:awk_num
        % Check if corresponding events file exists
        isComplete = any(contains(fileNames, ['awakening_',num2str(k),'_'])&contains(fileNames, 'events'));

        if isComplete
            awakeningLabels{k} = sprintf('%d (completed)', k);
        else
            awakeningLabels{k} = sprintf('%d (NOT COMPLETED)', k);
        end
    end

    awakeningMenu.String = awakeningLabels;
    awakeningMenu.Value = 1;
end


    % === Callback: FIX! Button Pressed ===
    function fixCallback(~, ~)
        participantLabel = participantMenu.String{participantMenu.Value};
        participant = extractBefore(participantLabel, ' ');
        if isempty(participant)
            participant = participantLabel;
        end

        nightRaw = nightMenu.String{nightMenu.Value};
        night = str2double(regexp(nightRaw, '\d', 'match', 'once'));

        awakeningRaw = awakeningMenu.String{awakeningMenu.Value};
        awakening = str2double(regexp(awakeningRaw, '\d+', 'match', 'once'));

        % Show progress bar
        hWait = waitbar(0, 'Running fix_loader...', 'Name', 'Please Wait');
        drawnow;

        try
            waitbar(0.3, hWait);
            drawnow;

            fix_loader(participant, night, awakening);

            waitbar(1, hWait, 'Complete!');
            pause(0.5);
        catch ME
            waitbar(1, hWait, sprintf('Error: %s', ME.message));
            pause(1.5);
        end

        close(hWait);
        close(f);
    end

    % === Initialize UI ===
    updateNightAndAwakenings();
end