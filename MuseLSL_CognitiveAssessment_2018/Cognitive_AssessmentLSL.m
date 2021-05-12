%% Cognitive Assessment for Muse LSL and VPixx
% Written by Chad C. Williams at the University of Victoria, 2018
% www.chadcwilliams.weebly.com

%Supporting scripts include: 'FixationMuseLSL.m', OddballMuseLSL.m',
%'DecisionMakingMuseLSL.m', 'LSL_flipandmark.m' OR 'VPixx_flipandmark.m'

%% Initial parameters
clear all; clc; Shuffle(rng);

%% User input
LSL_or_VPixx = 1; %1 if using Muse LSL, 2 if using VPixx, 0 for behavioural only

run_fixation = 1; %Determine whether to run this task. 1 = yes, 0 = no.
run_oddball = 1; %Determine whether to run this task. 1 = yes, 0 = no.
run_decisionmaking = 1; %Determine whether to run this task. 1 = yes, 0 = no.

%Note: There are additional user inputs at the top of each task that may be
%changed (e.g., number of blocks/trials)

%% Opening devices
if LSL_or_VPixx == 1
    usingMuse = 1;
    usingVPixx = 0;
    [lib, info, outlet] = LSL_Muse_InitiationLR(usingMuse);
elseif LSL_or_VPixx == 2
    usingMuse = 0;
    usingVPixx = 1;
    Datapixx('Open');
    Datapixx('StopAllSchedules');
else
    usingMuse = 0;
    usingVPixx = 0;
end

%% Subject Number
subject_number = input('Enter the subject number:\n','s');  % get the subject number
ListenChar(2);

%% Experiments
if run_fixation
    FixationMuseLSL
end

if run_oddball == 1 && run_decisionmaking == 1 %Run both in random order
    if rand < .5
        OddballMuseLSL
        DecisionMakingMuseLSL
    else
        DecisionMakingMuseLSL
        OddballMuseLSL
    end
elseif run_oddball == 1 && run_decisionmaking == 0 %Run Oddball only
    OddballMuseLSL
elseif run_oddball == 0 && run_decisionmaking == 1 %Run Decision Making only
    DecisionMakingMuseLSL
else
    %Run neither
end

%% Shutdown

DrawFormattedText(win, 'Thank you for participating','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', win);
WaitSecs(5);

if LSL_or_VPixx == 1
    LSL_Muse_Shutdown;
elseif LSL_or_VPixx == 2
    Datapixx('close');
else
    %Do nothing
end

ListenChar();
sca;