%% Oddball Task for Muse LSL and VPixx%%
% Written by Chad C. Williams at the University of Victoria, 2018
% www.chadcwilliams.weebly.com

%% User Input
num_of_blocks = 4; %Determine number of blocks (4) now 2
num_of_trials = 50; %Determine how many trials per block (50)

%% Marker List
% 201: Fixation prior to oddball stimulus
% 202: Fixation prior to Control stimulus
% 211: Oddball stimulus
% 212: Control stimulus

%% Setup Muse
if ~exist('outlet') && usingMuse
    clearvars -except usingMuse; clc;
    [lib, info, outlet] = LSL_Muse_InitiationLR(usingMuse); %Initiate Muse Streaming
end

%% Setup Behavioural
if ~exist('subject_number');
    clc;
    subject_number = input('Enter the subject number:\n','s');  % get the subject number
end
pname = strcat('OddballBehMuseLSL_',subject_number);

%% Setup Display
if ~exist('win');
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'ConserveVRAM', 64);
    [win, rec] = Screen('OpenWindow', 0  , [166 166 166],[], 32, 2);
    
    if LSL_or_VPixx == 2
        %Begin recording message
        DrawFormattedText(win, 'Begin recording now. \n Experimenter, press F when ready','center', 'center', [255 255 255],[],[],[],2);
        Screen('Flip', win);
        Wait_for_Response = 1;
        while Wait_for_Response
            [keypressed, ~, keyCode] = KbCheck();
            if keypressed
                if keyCode(KbName('F'))
                    Wait_for_Response = 0;
                end
            end
        end
        WaitSecs(.25);
    end
end

%Setup Parameters
Screen(win,'TextSize', 24);
ListenChar(2); %Stop typing in Matlab
HideCursor();		% hide the cursor
xmid = rec(3)/2;
ymid = rec(4)/2;
ExitKey = KbName('ESCAPE');
beh_data = [];

%% Run Experiment

DrawFormattedText(win, 'Oddball Task','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', win);
WaitSecs(5);

%Instructions
instructions = ['On each trial, you''re going to see a blue or green circle in the middle of the display\nTry to keep your eyes on the middle of the display at all times\nSimply count the number of green circles\nYou will complete ' num2str(num_of_blocks) ' blocks of ' num2str(num_of_trials) ' trials\nPress F to proceed'];
DrawFormattedText(win, instructions,'center', 'center', [255 255 255],[],[],[],2);
Screen('Flip',win);

Wait_for_Response = 1;
while Wait_for_Response
    [keypressed, ~, keyCode] = KbCheck();
    if keypressed
        if keyCode(KbName('F'))
            Wait_for_Response = 0;
        end
    end
end
WaitSecs(.25);

for block = 1:num_of_blocks
    %Block message
    DrawFormattedText(win,['Block ' num2str(block)],'center','center',[255 255 255]);
    Screen('Flip',win);
    WaitSecs(2);
    
    for trial = 1:num_of_trials
        
        %Determine whether oddball or control
        if rand < .25
            colour = [0 255 0];
            marker = 201;
        else
            colour = [0 0 255];
            marker = 202;
        end
        
        %Draw fixation for 300 - 500ms
        DrawFormattedText(win,'+','center','center',[255 255 255]);
        
        if LSL_or_VPixx == 1
            LSL_flipandmark(marker,win,outlet,usingMuse);
        elseif LSL_or_VPixx == 2
            VPixx_flipandmark(win,marker,usingVPixx);
        else
            Screen('Flip',win);
        end
        
        fixation_interval = rand()*.2 + .3;
        WaitSecs(fixation_interval);
        
        %Draw circle for 800ms
        Screen('FillOval', win , colour, [xmid-30 ymid-30 xmid+30 ymid+30], 8);
        if LSL_or_VPixx == 1
            LSL_flipandmark(marker+10,win,outlet,usingMuse);
        elseif LSL_or_VPixx == 2
            VPixx_flipandmark(win,marker+10,usingVPixx);
        else
            Screen('Flip',win);
        end
        
        WaitSecs(.8);
        
        %Store Behavioural Data
        beh_data = [beh_data; block trial marker fixation_interval];
        
        %Crash out of experiment (trials)
        [~, ~, keyCode] = KbCheck();
        if keyCode(ExitKey)
            break;
        end
    end
    
    %Crash out of experiment (blocks)
    [~, ~, keyCode] = KbCheck();
    if keyCode(ExitKey)
        break;
    end
end

%% End Experiment
dlmwrite([pname '.txt'],beh_data,'\t');
