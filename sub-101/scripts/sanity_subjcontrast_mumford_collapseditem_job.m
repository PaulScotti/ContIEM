%Paul Scotti 2018 1st Level SPM

% load onsets and durations for subject (contains trial_onset_list)
cd([root_dir]);
load([root_dir runName '_scripts.mat']);

%% Prepare Design Matrix in SPM    

if ~(7 == exist('Object40','dir')) %does Object40 folder exist? if not, create the folders
    for i = 1:numObjects %make folder for every object (adapted Mumford method)
        mkdir (['Object' num2str(i)])
    end
end

cd nii

matlabbatch{1}.spm.stats.fmri_spec.dir = {pwd};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16; % check these are the correct defaults using the GUI (these are correct for 2 s TR)
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for object = 73:numObjects %startObject:numObjects
    [R,C] = find(imgnum(:,:)==object); % find all trials with same object ID, combine betas across same object ID
    Rx = find(~any(R==[1:numRuns]));
    for run = 1:numRuns
        if length(R) == 0 % blank GLM
            indx = find(isnan(trial_type_list{run}));
            if mod(run,2) == 1 && mod(object,2) == 1 % if odd run and odd object
                trial = indx(mod(object-72,4)+1);
            elseif mod(run,2) == 0 && mod(object,2) == 1 % if even run and even object
                trial = indx(mod(object-72,4)+1);
            else
                trial = nan;
            end
            
            if ~isnan(trial)               
                fmri_images = dir(['r' runHead num2str(run) runTail '*.nii']);
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = {fmri_images.folder,filesep,fmri_images.name}';

                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).name = ['Object_' num2str(object)];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).onset = trial_onset_list{run}(trial);
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).tmod = 0;
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).orth = 1;

                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).name = ['NotObject_' num2str(object)];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset=[];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).tmod = 0;
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).orth = 1;

                for trialx = 1:numTrials
                    if trialx ~= trial &&  ~isnan(trial_type_list{run}(trialx)) % get onsets for all the trials that aren't the current trial of interest
                        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset; trial_onset_list{run}(trialx)];
                    end
                end

                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).name = ['Blank_' num2str(object)];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset=[];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).tmod = 0;
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).orth = 1;

                for trialx = 1:numTrials
                    if trialx ~= trial && isnan(trial_type_list{run}(trialx)) % get onsets for all the trials that aren't the current trial of interest
                        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset; trial_onset_list{run}(trialx)];
                    end
                end
            else
                fmri_images = dir(['r' runHead num2str(run) runTail '*.nii']);
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = {fmri_images.folder,filesep,fmri_images.name}';

                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).name = ['NotObject_' num2str(object)];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset=[];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).tmod = 0;
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).orth = 1;

                for trialx = 1:numTrials
                    if ~isnan(trial_type_list{run}(trialx))
                        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset; trial_onset_list{run}(trialx)];
                    end
                end

                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).name = ['Blank_' num2str(object)];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset=[];
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).tmod = 0;
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).orth = 1;

                for trialx = 1:numTrials
                    if isnan(trial_type_list{run}(trialx)) % get onsets for all the trials that aren't the current trial of interest
                        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset; trial_onset_list{run}(trialx)];
                    end
                end
            end
        elseif any(run == R)
            indx = find(run==R);
            trial = C(indx);

            fmri_images = dir(['r' runHead num2str(run) runTail '*.nii']);
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = {fmri_images.folder,filesep,fmri_images.name}';

            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).name = ['Object_' num2str(object)];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).onset = trial_onset_list{run}(trial);
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(3).orth = 1;

            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).name = ['NotObject_' num2str(object)];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset=[];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).orth = 1;

            for trialx = 1:numTrials
                if trialx ~= trial &&  ~isnan(trial_type_list{run}(trialx)) % get onsets for all the trials that aren't the current trial of interest
                    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset; trial_onset_list{run}(trialx)];
                end
            end
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).name = ['Blank_' num2str(object)];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset=[];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).orth = 1;

            for trialx = 1:numTrials
                if trialx ~= trial && isnan(trial_type_list{run}(trialx)) % get onsets for all the trials that aren't the current trial of interest
                    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset; trial_onset_list{run}(trialx)];
                end
            end
        elseif any(run == Rx)
            fmri_images = dir(['r' runHead num2str(run) runTail '*.nii']);
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = {fmri_images.folder,filesep,fmri_images.name}';

            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).name = ['NotObject_' num2str(object)];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset=[];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).orth = 1;

            for trialx = 1:numTrials
                if ~isnan(trial_type_list{run}(trialx))
                    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset; trial_onset_list{run}(trialx)];
                end
            end
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).name = ['Blank_' num2str(object)];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset=[];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).orth = 1;

            for trialx = 1:numTrials
                if isnan(trial_type_list{run}(trialx)) % get onsets for all the trials that aren't the current trial of interest
                    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset; trial_onset_list{run}(trialx)];
                end
            end
        end
        confounds_file = dir([runHead num2str(run) '*regressors.tsv']);
        cstruct = tdfread(confounds_file.name);
        confounds = [ ...
            cstruct.trans_x,cstruct.trans_y,cstruct.trans_z, ...
            cstruct.rot_x,cstruct.rot_y,cstruct.rot_z];
        % make it a txt file so that spm can interpret it
        save(strcat(confounds_file.folder,filesep,confounds_file.name(:,1:end-4),'.txt'),'confounds','-ascii');

        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg = {strcat(confounds_file.folder,filesep,confounds_file.name(:,1:end-4),'.txt')};
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf = 128;
    end
    %spm finishing stuff
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    % Run batch
    try
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch)
    catch me
        rethrow(me);
    end
    
    %Rename SPM.mat
    movefile('SPM.mat',['SPM_Object_' num2str(object) '.mat'])
    %Move SPM.mat to suitable folder
    movefile(['SPM_Object_' num2str(object) '.mat'],[root_dir '/Object' num2str(object)])
    
    sprintf('Completed SPM for object %f',object)
end

disp('Completed 1st level contrast for single subject.');
cd(home)
