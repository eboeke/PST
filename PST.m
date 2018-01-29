function PST(subjectcode,skip_train,stims)
%implements Michael Frank's probabalistic selection task (ala Frank et al,
%Science, 2004)
%Author: Emily Boeke
%args:
%   subjectcode, a string
%   skip_train, a bool indicating whether to skip the training phase (use
%   if had to stop program between training and test phases)
%   stims, a vector indicating which stimuli are assigned to which roles (only
%   necessary if skip_train==1; otherwise, randomly assigned)

rand('state',sum(100*clock)); %reseed the random number generator

%set up variables/task parameters
L_key = KbName('q');
R_key = KbName('p');
quit_key = KbName('b'); % define a quit key
space = KbName('space');
red = [1 0 0];
blue = [0 0 1];
correct_text = 'Correct!';
incorrect_text = 'Incorrect';
slow_text = 'No response detected';
fix_string = '+';
break_text = 'Take a break. The experiment will start again in 20 seconds.';

left_char = 0; %initialize left_char and right_char
right_char = 0;

fix_dur = 1;% length of fixation, in seconds. cate: 0. berghorst: 1 s. cavanaugh 2011: jittered iti, 300-700 ms. petzold, 2010, 1000 ms
max_choice_dur = 4; %maximum duration of presentation of pairs of stimuli.
%frank and kong do 4 s, as does lighthall et al, cavanaugh et al. berghorst et al does 2 s
feedback_dur = 1.5; %duration of feedback. 1.5 s for pezold et al ,500 ms for cavanaugh et al, but also, delay of 60-100 ms
break_dur = 20;%length of breaks between blocks

%train parameters
trials_pair_training_block = 20;
max_num_training_blocks = 6; %petzold et al: 7, chase et al 10, other papers 6
num_pairs = 3;
num_trials_training_block = trials_pair_training_block*num_pairs; % total trials in a  training block
total_trials_train = num_trials_training_block * max_num_training_blocks;
criterion_ab = .65; %criterion for AB pair (choose A 65% of time) in order to proceed to test
criterion_cd = .60; %criterion for CD pair
criterion_ef = .40; %criterion for EF pair

%test parameters
trials_pair_test = 6; 
%frank 2004: don't say # per pair, but unclear whether all novel or only novel pairs w a or b
%FRANK 2007: only 4 per pair, all novel pairs.
%petzold: 4 per pair, all novel pairs
%cavanagh 2010,11: 8 pres per pair, but ALL POSSIBLE PAIRS (120 trials)
%chase 2010: 6 pres per pair, ALL POSSIBLE  PAIRS
%berghorst, 2013: 6 pres per pair, all possible pairs
%Lighthall, 2013: 4 per pair, all possible pairs
%cavanagh and chase state that subjs who didn't choose a in an a b pair
%more than half the time were excluded, cite frank but i don't see that
num_pairs_test = 15;
total_trials_test = trials_pair_test*num_pairs_test;


%random assignment of characters
character_list = Shuffle([12414 12415 12381 12398 12425 12420]); %unicode text of hiragana characters
if(skip_train)
    character_list = stims;
end
a = character_list(1);
b = character_list(2);
c = character_list(3);
d  = character_list(4);
e = character_list(5);
f = character_list(6);
demonstration_char = character_list(randperm(6,2)); %randomly pick 2 chars to display in instructions


PST_train.chars = character_list;
%make a list of all trials that must happen in each training block
%aba means , ab pair, a on left, b on right, correct answer is a
num_trial_types = 12;
train_trial_types.name = {'aba','baa','abb','bab','cdc','dcc','cdd','dcd','efe','fee','eff','fef'};
train_trial_types.reps = [ 8 8 2 2 7 7 3 3 6 6 4 4]; %number of repetitions for each trial type
train_trial_types.left =  ['a','b','a','b','c','d','c','d','e','f','e','f'];
train_trial_types.right = ['b','a','b','a','d','c','d','c','f','e','f','e'];
train_trial_types.correct_ans = ['a','a','b','b','c','c','d','d','e','e','f','f']; %correct answer to each trial type
train_trial_types.correct_key = [L_key R_key R_key L_key L_key R_key R_key L_key L_key R_key R_key L_key]; %forrect key press for each trial type

%make a list of trials that must happen in each test block
num_trial_types_test = num_pairs_test*2; %2 types (placement counterbalanced)  per stim pair
test_trial_types.name = {'ab', 'ba', 'ac','ca','ad','da','ae','ea','af','fa',...
    'bc','cb','bd','db','be','eb','bf','fb','cd','dc','ce','ec','cf','fc','de',...
    'ed','df','fd','ef','fe'};
test_trial_types.left =  ['a','b','a','c','a','d','a','e','a','f','b','c',...
    'b','d','b','e','b','f','c','d','c','e','c','f','d','e','d','f','e','f'];
test_trial_types.right = ['b','a','c','a','d','a','e','a','f','a','c','b',...
    'd','b','e','b','f','b','d','c','e','c','f','c','e','d','f','d','f','e'];
test_trial_types.includes_a = [ones(10,1); zeros(20,1)]; %marks whether or not the pair includes a
test_trial_types.includes_b = [[1; 1]; zeros(8,1); ones(8,1); zeros(12,1)]; %marks whether or not the pair includes b




%make a list of all the trials that must happen in block (listed by trial type number)
list_train_trials = ones(8,1); % -currently, just contains first trial type.

%this loop completes the list  of all trials (listed by trial type)
for i = 2:num_trial_types
    reps = train_trial_types.reps(i);
    list_train_trials = vertcat(list_train_trials,i*ones(reps,1));
end

%predetermine random order for all train blocks (# of trial type for given trial)
PST_train.order = zeros(total_trials_train,1);
PST_train.block = zeros(total_trials_train,1);
PST_train.trial = zeros(total_trials_train,1);
for i = 1:max_num_training_blocks

    start_block = (i-1)*num_trials_training_block+1;
    end_block = start_block+num_trials_training_block-1;
    
    PST_train.order(start_block:end_block) = Shuffle(list_train_trials);
    PST_train.block(start_block:end_block) = i; 
    PST_train.trial(start_block:end_block) = 1:num_trials_training_block;
end
    
%set up the rest of data struct for test
PST_train.name = cell(total_trials_train,1);
for i = 1:total_trials_train
    trial_type = PST_train.order(i);
    PST_train.name{i} = train_trial_types.name{trial_type};
    PST_train.correct_ans(i) = train_trial_types.correct_ans(trial_type);
    PST_train.correct_key(i) = train_trial_types.correct_key(trial_type);
    PST_train.left(i) = train_trial_types.left(trial_type);
    PST_train.right(i) = train_trial_types.right(trial_type);
    
end
PST_train.choice_onset = zeros(total_trials_train,1);
PST_train.feedback_onset = zeros(total_trials_train,1);
PST_train.fix_onset = zeros(total_trials_train,1);
PST_train.key_response = zeros(total_trials_train,1);
PST_train.choice = char(total_trials_train,1);
PST_train.correct = zeros(total_trials_train,1);
PST_train.RT = zeros(total_trials_train,1);
PST_train.criterion_reached = 0; %flag to indicate whether criterion was reached
PST_train.chars = character_list;

%predetermine order for test and make data struct
reps_test = trials_pair_test/2; %number of repetitions per trial type during test
list_test_trials = ones(reps_test,1);
for i = 2:num_trial_types_test
    list_test_trials = vertcat(list_test_trials,i*ones(reps_test,1));
end
 
PST_test.order = zeros(total_trials_test,1);
PST_test.trial = [1:total_trials_test]';
PST_test.order(1:total_trials_test) = Shuffle(list_test_trials);
PST_test.name = cell(total_trials_test,1);
PST_test.includes_a = zeros(total_trials_test,1);
PST_test.includes_b = zeros(total_trials_test,1);
for i = 1: total_trials_test
    trial_type = PST_test.order(i);
    PST_test.left(i) = test_trial_types.left(trial_type);
    PST_test.right(i) = test_trial_types.right(trial_type);
    PST_test.name{i} = test_trial_types.name{trial_type};
    PST_test.includes_a(i) = test_trial_types.includes_a(trial_type);
    PST_test.includes_b(i) = test_trial_types.includes_b(trial_type);
end
PST_test.choice_onset = zeros(total_trials_test,1);
PST_test.fix_onset = zeros(total_trials_test,1);
PST_test.RT =zeros(total_trials_test,1);
PST_test.choice = char(total_trials_test,1);
PST_test.key_response = zeros(total_trials_test,1);

%name files
root = '/Users/emilyboeke/Documents/NYU/SCRS/PST/'; %name of the parent folder
results_dir =  fullfile(root,'results'); %name the folder where data will go
train_mat_file = fullfile(results_dir,sprintf('%s_train_PST.mat',subjectcode));
test_mat_file = fullfile(results_dir,sprintf('%s_test_PST.mat',subjectcode));
train_txt_file = fullfile(results_dir,sprintf('%s_train_PST.txt',subjectcode));
test_txt_file = fullfile(results_dir,sprintf('%s_test_PST.txt',subjectcode));
if exist(train_txt_file, 'file') ==2
    disp('the specified file exists already. please enter a different subject code.')
    return;
end

%set up instruction text
 inst_1 = sprintf(['You will be making a series of choices in which\n' , ... 
     'a pair of figures appear on the screen at the same time.\n\n\n' , ... 
     'Press the space bar to see an example of the figures, and\n',...
     'press again to move on.']);
 inst_2 = sprintf(['For each choice, one character will be correct and\n' , ... 
     ' another will be incorrect. Press the ''','q''',' key to select the \n' , ... 
     'character on the left, and the ''','p''',' key to select the character \n' , ... 
     'on the right. \n\n',...
     'After each choice, you will receive feedback about whether your\n' , ...  
     'choice was correct or not.\n\n',...
     'Press the space bar to continue.']);
inst_3 = sprintf(['Between trials, you will see a plus sign (+) on the \n' , ... 
     'screen. During this time, just keep your gaze on the plus sign.\n\n',...
     'Press the space bar to continue.']);
inst_4 = sprintf(['No character will be correct every time, but some \n' , ... 
     'characters will have a higher chance of being correct than others.\n' , ... 
     ' Try to pick the symbol that you find to have the highest chance of\n' , ... 
     ' being correct. At first you may be confused, but don''','t worry, \n' , ... 
     'you''','ll have plenty of practice!\n\n',...
     'Press the space bar to continue.']);
inst_5 = sprintf(['All characters will appear on both the left and right\n' , ... 
     ' sides of the screen. The side that  a character appears on is \n' , ... 
     'random, so there is no relationship between the side it is on and\n' , ... 
     ' whether or not it is correct.\n\n',...
     'Press the space bar to continue.']);
inst_6 = sprintf(['You will have a few seconds to make each choice. You \n' , ... 
     'will be able to respond most quickly if you keep the pointer \n' , ... 
     'finger of your left hand on the ''','q''',' key and the pointer finger\n' , ... 
     ' of your right hand on the ''','p''',' key.\n\n',...
     'Press the space bar to continue.']);
inst_7 = sprintf(['Let the experimenter know when you are ready to start.']);

 
 test_inst = sprintf(['It''','s time to test what you''','ve learned!\n' , ... 
 'During this set of trials you will NOT receive feedback \n',...
 '(''','Correct''',' or ''','Incorrect''',') to your responses. If you see\n',...
 'new combinations of symbols in the test, please choose the\n ',...
 'symbol that ''','feels''',' more correct based on what you learned \n',...
 'during the training sessions. If you''','re not sure which one \n',...
 'to pick, just go with your gut instinct!\n\n',...
     'Press the space bar to continue.']);
 
 done_text = sprintf(['Thank you. You have completed this task.']);
 
% Set up psych toolbox, screens etc
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests',1); %skip the screen tests
    
screens = Screen('Screens');
screen_number = max(screens);
white = WhiteIndex(screen_number);
black = BlackIndex(screen_number);
HideCursor; % hide the cursor
[window, window_rect] = PsychImaging('OpenWindow', screen_number, white)
Screen('TextSize', window, 40);

%open text file
fid = fopen(train_txt_file,'a');
fid_test = fopen(test_txt_file,'a');

%put time stamp in text file
fprintf(fid,'\n%d\t%d\t%d\t%d\t%d\t%2.3f\n\n',clock);
fprintf(fid_test,'\n%d\t%d\t%d\t%d\t%d\t%2.3f\n\n',clock);

%put in character identities

fprintf(fid,'%s\t%s\n','a',num2str(a));
fprintf(fid,'%s\t%s\n','b',num2str(b));
fprintf(fid,'%s\t%s\n','c',num2str(c));
fprintf(fid,'%s\t%s\n','d',num2str(d));
fprintf(fid,'%s\t%s\n','e',num2str(e));
fprintf(fid,'%s\t%s\nn','f',num2str(f));

% write a header row to the text file describing what's in each of the columns
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Block','Trial_number', ...
'Trial_type_number','Trial_type_name', 'Left_char','Right_char', 'Correct_key','Choice_onset', 'Feedback_onset', ...
 'Fix_onset', 'Key_response', 'Choice','Correct?','RT');

fprintf(fid_test,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Trial_number', ...
'Trial_type_number','Trial_type_name', 'Left_char','Right_char', 'Includes_A', 'Includes_B', 'Choice_onset',  ...
 'Fix_onset', 'Key_response', 'Choice','RT');

%tell me which chars are which
inst_text(window,'a',0,0,quit_key,space);
Screen('TextFont', window, 'Hiragino Mincho Pro'); %characters can only be shown in this font.
Screen('TextSize', window, 72);
inst_text(window,a,0,0,quit_key,space);
Screen('TextFont', window, 'Geneva'); %reset font
Screen('TextSize', window, 40);

inst_text(window,'b',0,0,quit_key,space);
Screen('TextFont', window, 'Hiragino Mincho Pro'); %characters can only be shown in this font.
Screen('TextSize', window, 72);
inst_text(window,b,0,0,quit_key,space);
Screen('TextFont', window, 'Geneva'); %reset font
Screen('TextSize', window, 40);

inst_text(window,'c',0,0,quit_key,space);
Screen('TextFont', window, 'Hiragino Mincho Pro'); %characters can only be shown in this font.
Screen('TextSize', window, 72);
inst_text(window,c,0,0,quit_key,space);
Screen('TextFont', window, 'Geneva'); %reset font
Screen('TextSize', window, 40);

inst_text(window,'d',0,0,quit_key,space);
Screen('TextFont', window, 'Hiragino Mincho Pro'); %characters can only be shown in this font.
Screen('TextSize', window, 72);
inst_text(window,d,0,0,quit_key,space);
Screen('TextFont', window, 'Geneva'); %reset font
Screen('TextSize', window, 40);

inst_text(window,'e',0,0,quit_key,space);
Screen('TextFont', window, 'Hiragino Mincho Pro'); %characters can only be shown in this font.
Screen('TextSize', window, 72);
inst_text(window,e,0,0,quit_key,space);
Screen('TextFont', window, 'Geneva'); %reset font
Screen('TextSize', window, 40);


inst_text(window,'f',0,0,quit_key,space);
Screen('TextFont', window, 'Hiragino Mincho Pro'); %characters can only be shown in this font.
Screen('TextSize', window, 72);
inst_text(window,f,0,0,quit_key,space);
Screen('TextFont', window, 'Geneva'); %reset font
Screen('TextSize', window, 40);


if ~skip_train
    
 %INSTRUCTIONS
inst_text(window,inst_1,0,0,quit_key,space);
Screen('TextFont', window, 'Hiragino Mincho Pro'); %characters can only be shown in this font.
Screen('TextSize', window, 72);
inst_text(window,demonstration_char,0,0,quit_key,space);
Screen('TextFont', window, 'Geneva'); %reset font
Screen('TextSize', window, 40);
inst_text(window,inst_2,0,0,quit_key,space);
inst_text(window,inst_3,0,0,quit_key,space);
inst_text(window,inst_4,0,0,quit_key,space);
inst_text(window,inst_5,0,0,quit_key,space);
inst_text(window,inst_6,0,0,quit_key,space);
inst_text(window,inst_7,0,0,quit_key,space);


%TRAINING BLOCKS
exp_onset = GetSecs;
for j = 1:max_num_training_blocks
    %if it's not the first block, take a break.
    if j ~= 1
        DrawFormattedText(window, break_text, 'center', 'center', black);
        [~, break_onset]=  Screen('Flip', window); 
        while (GetSecs < break_onset + break_dur) %while ITI time (minus anticipation time) has not elapsed
            [~, ~, keyCode]=KbCheck;
            keyCodeNum = find(keyCode==1);
            if (keyCodeNum == quit_key) %check for quit key
                Screen('closeall');
                %Priority(0);
                ShowCursor;

                disp('... The program was terminated manually.');
                RestrictKeysForKbCheck([]);
                return;
            end
        end
    end
    
    %INDIVIDUAL TRIALS IN TRAINING BLOCKS
      % put fixation cross up
    DrawFormattedText(window, fix_string, 'center', 'center', black);
    [~, block_onset]=  Screen('Flip', window); 
    while (GetSecs < block_onset + fix_dur) %while ITI time (minus anticipation time) has not elapsed
        [~, ~, keyCode]=KbCheck;
        keyCodeNum = find(keyCode==1);
        if (keyCodeNum == quit_key) %check for quit key
            Screen('closeall');
            %Priority(0);
            ShowCursor;

            disp('... The program was terminated manually.');
            RestrictKeysForKbCheck([]);
            return;
        end
    end

    for k = 1:num_trials_training_block
            %CHOICE
            i = num_trials_training_block*j - (num_trials_training_block-k);
            % i tracks the trial number out of all trials, j is block #, k
            % is trial # within the block

            left_char = eval(PST_train.left(i));
            right_char = eval(PST_train.right(i));
            
            Screen('TextFont', window, 'Hiragino Mincho Pro');
            Screen('TextSize', window, 72);
            DrawFormattedText(window, left_char, window_rect(3)/2-200, 'center',black); %display characters
            DrawFormattedText(window, right_char, window_rect(3)/2+200, 'center',black);
            choice_made = 0;
            [~, choice_onset]=  Screen('Flip', window); 
            PST_train.choice_onset(i) = choice_onset - exp_onset; %record timing (relative to start of exp)
            while (GetSecs < choice_onset + max_choice_dur) %check for key press
            [~,~, keyCode]=KbCheck;
                        if sum(keyCode)>1 %if they press 2 buttons at once
                %if they press the left key + some other key:
                if (keyCode(L_key)==1 && keyCode(R_key)==0)
                    keyCode = keyCode * 0;
                    keyCode(L_key) = 1; %make it so only left is selected
                %if they press the right key + some other key
                elseif (keyCode(R_key)==1 && keyCode(L_key)==0)
                    keyCode = keyCode * 0;
                    keyCode(R_key) = 1; %make it so only right is selected
                %if they press both the left and right keys 
                elseif (keyCode(L_key)==1 && keyCode(R_key)==1)
                    keyCode = keyCode * 0; %ignore it--it will tell them no resp was detected
                end %if they hit 2 random keys, move on (it won't count as a response)
            end
            keyCodeNum = find(keyCode==1);

            if keyCodeNum == L_key | keyCodeNum == R_key %if they press one of the answer keys
                PST_train.key_response(i) = keyCodeNum; %store the response
                if keyCodeNum == L_key 
                    PST_train.choice(i) = PST_train.left(i);
                else
                    PST_train.choice(i) = PST_train.right(i);
                end
                PST_train.RT(i) = GetSecs - exp_onset;

                choice_made = 1;
                if keyCodeNum == PST_train.correct_key(i) %check if correct and store this info.
                    PST_train.correct(i) = 1;
                     %record if correct
                end

                break
            end

                if (keyCodeNum == quit_key) %check for quit key
                    Screen('closeall');
                    %Priority(0);
                    ShowCursor;

                    disp('... The program was terminated manually.');
                    RestrictKeysForKbCheck([]);
                    return;
                end
            end
            %FEEDBACK
            
      Screen('TextFont', window, 'Geneva'); %reset text info for normal text
      Screen('TextSize', window, 40);
            if choice_made %depending on response, pick appropriate feedback
                if PST_train.correct(i)
                    feedback_string = correct_text;
                    color = blue;
                else
                    feedback_string = incorrect_text;
                    color = red;
                end
            else
                feedback_string = slow_text;
                color = red;
                PST_train.choice(i) = 0;
            end
             DrawFormattedText(window, feedback_string, 'center', 'center', color); %draw the feedback
            [~, feedback_onset]=  Screen('Flip', window); 
            PST_train.feedback_onset(i) = feedback_onset - exp_onset;
            while (GetSecs < feedback_onset + feedback_dur) %while feedback time has not elapsed 
                [~,~, keyCode]=KbCheck;
          
                keyCodeNum = find(keyCode==1);
                if (keyCodeNum == quit_key) %check for quit key
                    Screen('closeall');
                   % Priority(0);
                    ShowCursor;

                    disp('... The program was terminated manually.');
                    RestrictKeysForKbCheck([]);
                    return;
                end
            end

            %FIXATION
            DrawFormattedText(window, fix_string, 'center', 'center', black);
            [~, fix_onset]=  Screen('Flip', window);
            PST_train.fix_onset(i) = fix_onset - exp_onset;
            while (GetSecs <fix_onset + fix_dur) %while fix time has not elapsed
                [~,~, keyCode]=KbCheck;
                keyCodeNum = find(keyCode==1);
                if (keyCodeNum == quit_key) %check for quit key
                    Screen('closeall');
                    %Priority(0);
                    ShowCursor;
                    disp('... The program was terminated manually.');
                    RestrictKeysForKbCheck([]);
                    return;
                end
            end
            
            save(train_mat_file, '-struct', 'PST_train'); %save the struct
            %print info to text file
           fprintf(fid,'%d\t%d\t%d\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%s\t%d\t%d\n', PST_train.block(i),PST_train.trial(i), ...
        PST_train.order(i),char(PST_train.name{i}), PST_train.left(i), PST_train.right(i),PST_train.correct_key(i),PST_train.choice_onset(i), PST_train.feedback_onset(i), ...
         PST_train.fix_onset(i), PST_train.key_response(i), PST_train.choice(i),PST_train.correct(i),PST_train.RT(i));


    end

        %BLOCK END: calculate pct choice a, c, e 
        num_trials_chose_a = length(find(PST_train.choice(PST_train.block == j) == 'a')); %find # time chose a in current block
        percent_a = num_trials_chose_a / trials_pair_training_block;

        num_trials_chose_c = length(find(PST_train.choice(PST_train.block == j) == 'c'));
        percent_c = num_trials_chose_c / trials_pair_training_block;

        num_trials_chose_e = length(find(PST_train.choice(PST_train.block == j) == 'e'));
        percent_e = num_trials_chose_e / trials_pair_training_block;

        if percent_a >= criterion_ab && percent_c >= criterion_cd && percent_e >= criterion_ef
            PST_train.criterion_reached = 1;
            break %if they reach the criterion, break from this loop and proceed to test.
        end

end

end
%TEST INSTRUCTIONS
 inst_text(window,test_inst,0,0,quit_key,space);

 if skip_train
     exp_onset = GetSecs;%if training skipped, record experiment onset as now.
 end
%TEST
  % put fixation cross up
    DrawFormattedText(window, fix_string, 'center', 'center', black);
    [~, test_onset]=  Screen('Flip', window); 
    while (GetSecs < test_onset + fix_dur) %while ITI time (minus anticipation time) has not elapsed
        [~, ~, keyCode]=KbCheck;
        keyCodeNum = find(keyCode==1);
        if (keyCodeNum == quit_key) %check for quit key
            Screen('closeall');
           % Priority(0);
            ShowCursor;

            disp('... The program was terminated manually.');
            RestrictKeysForKbCheck([]);
            return;
        end
    end

    for i = 1:total_trials_test
        left_char = eval(PST_test.left(i));
        right_char = eval(PST_test.right(i));
        Screen('TextFont', window, 'Hiragino Mincho Pro');
        Screen('TextSize', window, 72);
        DrawFormattedText(window, left_char, window_rect(3)/2-200, 'center',black);
        DrawFormattedText(window, right_char, window_rect(3)/2+200, 'center',black);
        [~, choice_onset]=  Screen('Flip', window); 
        Screen('TextFont', window, 'Geneva');
        Screen('TextSize', window, 40);
        PST_test.choice_onset(i) = choice_onset - exp_onset; %record timing (relative to start of exp)
            
        while (GetSecs < choice_onset + max_choice_dur)  %check for key press
            [~, ~, keyCode]=KbCheck;
                              if sum(keyCode)>1 %if they press 2 buttons at once
                %if they press the left key + some other key:
                if (keyCode(L_key)==1 && keyCode(R_key)==0)
                    keyCode = keyCode * 0;
                    keyCode(L_key) = 1; %make it so only left is selected
                %if they press the right key + some other key
                elseif (keyCode(R_key)==1 && keyCode(L_key)==0)
                    keyCode = keyCode * 0;
                    keyCode(R_key) = 1; %make it so only right is selected
                %if they press both the left and right keys 
                elseif (keyCode(L_key)==1 && keyCode(R_key)==1)
                    keyCode = keyCode * 0; %ignore it--it will tell them no resp was detected
                end %if they hit 2 random keys, move on (it won't count as a response)
            end
            keyCodeNum = find(keyCode==1);
            if keyCodeNum == L_key | keyCodeNum == R_key %if they press one of the answer keys
                PST_test.key_response(i) = keyCodeNum; %store the response
                if keyCodeNum == L_key 
                    PST_test.choice(i) = PST_test.left(i);                 
                else
                    PST_test.choice(i) = PST_test.right(i);
                end
                PST_test.RT(i) = GetSecs - exp_onset;  
                break
            else
                PST_test.choice(i) = 0;
            end
            
            if (keyCodeNum == quit_key) %check for quit key
                Screen('closeall');
               % Priority(0);
                ShowCursor;
                disp('... The program was terminated manually.');
                RestrictKeysForKbCheck([]);
                return;
            end
            
        end
            
             %FIXation
        DrawFormattedText(window, fix_string, 'center', 'center', black);
        [~, fix_onset]=  Screen('Flip', window);
        PST_test.fix_onset(i) = fix_onset - exp_onset;
        while (GetSecs <fix_onset + fix_dur) %while fix time has not elapsed
            [~, ~, keyCode]=KbCheck;
            keyCodeNum = find(keyCode==1);
            if (keyCodeNum == quit_key) %check for quit key
                Screen('closeall');
               % Priority(0);
                ShowCursor;
               
                disp('... The program was terminated manually.');
                RestrictKeysForKbCheck([]);
                return;
            end
        end
        
        PST_test.trial(i)
            PST_test.order(i)
            char(PST_test.name{i})
            PST_test.left(i)
            PST_test.right(i)
            PST_test.includes_a(i)
            PST_test.includes_b(i)
            PST_test.choice_onset(i)
            PST_test.fix_onset(i)
            PST_test.key_response(i)
            PST_test.choice(i)
            PST_test.RT(i)
        save(test_mat_file, '-struct', 'PST_test');
        
       
        fprintf(fid_test,'%d\t%d\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%s\t%d\n', PST_test.trial(i), ...
            PST_test.order(i),char(PST_test.name{i}), PST_test.left(i), PST_test.right(i), PST_test.includes_a(i),PST_test.includes_b(i), PST_test.choice_onset(i), ...
            PST_test.fix_onset(i), PST_test.key_response(i), PST_test.choice(i),PST_test.RT(i));
    end
%Tell subj they're done.
 inst_text(window,done_text,0,0,quit_key,space);
 disp('finished inst text')
    fclose(fid);
    fclose(fid_test);




    % Clear the screen.
    sca;
    Screen('CloseAll');
    close all;
    clear all;
end

        

function inst_text(window,text,texture,position,quit_key,end_key) %presents instructions
    if texture
        Screen('DrawTexture', window, texture, [], position, 0);
    end
        DrawFormattedText(window, text,'center', 'center', 0); %draw text
        Screen('Flip', window);
        RestrictKeysForKbCheck([end_key, quit_key]);
    while ~KbCheck
    end
    [~, ~, keyCode]=KbCheck; 

    KbReleaseWait; %wait for key to be released
    keyCodeNum = find(keyCode==1); %see which key was pressed
    if keyCodeNum == quit_key %if user quits, end program
                        Screen('closeall');
                        Priority(0);
                        ShowCursor;
                        disp('... The program was terminated manually.');
                        RestrictKeysForKbCheck([]);
                        return;
    end
    RestrictKeysForKbCheck([]);
end

