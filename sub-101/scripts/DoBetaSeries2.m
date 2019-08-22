% PS 2018, tighten ROI to only include preferentially activated voxels (AllVsFix), then DoBetaSeries.m steps
Conds = {'1','2','3','4','5','6','7','8','9'};
MapNames = {'RedPink' 'RedOrange' 'Orange' 'Olive' 'Green' 'Teal' 'Blue' 'Purple' 'HotPink'};

for nROI = 1:length(roi_file)
    mydata.betas=[];mydata.runs=[];mydata.conds=[];mydata.condName=[];mydata.trial=[];

    % load subject's ROI
    seedroi = [roi_dir roi_file{nROI} '.nii'];
    fprintf('ROI: %s \n',roi_file{nROI});

    % load subject-specific .mat information 
    load([root_dir '/ColorEncoder_scripts.mat']);

    % load SPM.mat and contrast (uses MarsBaR)
    spm_mat = [root_dir 'scripts/SPM.mat'];
    sess_model = mardo(spm_mat);

    % Get t threshold of uncorrected p < 0.001
    p_thresh = .000000000000001%
    erdf = error_df(sess_model);
    t_thresh = spm_invTcdf(1-p_thresh, erdf);

    % get all voxels from t image above threshold
    V = spm_vol([root_dir 'scripts/spmT_0001.nii']);
    img = spm_read_vols(V);
    % get all voxels from t image above threshold
    Y = spm_read_vols(spm_vol(seedroi),1);
    indx = find(Y>0 & img>t_thresh);
    [x,y,z] = ind2sub(size(Y),indx);
    XYZ = [x y z]';

    % make into clusters, find max cluster
%         cluster_nos = spm_clusters(XYZ);
%         [mx max_index] = max(img);
%         max_cluster = cluster_nos(max_index);
%         cluster_XYZ = XYZ(:, cluster_nos == max_cluster);

%         % make into clusters, eliminate small clusters
%         cluster_nos = spm_clusters(XYZ);
%         for clustNum = 1:length(unique(cluster_nos))
%             if length(cluster_nos(cluster_nos == clustNum)) > cluster_size
%                 yesClust = clustNum;
%                 break
%             end
%         end
%         cluster_XYZ = XYZ(:, cluster_nos >= clustNum);

%         XYZ = cluster_XYZ;

    fprintf('num voxels: %i \n',length(XYZ));

    for r = 1:numRuns
        for j = 1:numTrials %for every trial in the run
            %load SPM.mat
            load([root_dir 'Trial' num2str(j) '/SPM.mat']);
            cd([root_dir 'Trial' num2str(j)]);

            Betas=[];
            which = find(contains({SPM.Vbeta.descrip},['Sn(' num2str(r) ') Trial']));

            condID = trial_type_list{r}(j);
            
            if isnan(condID)
                continue;
            end
            
            Betas = strvcat(Betas,SPM.Vbeta(which).fname);
            mydata.trial = [mydata.trial; j];
            mydata.runs = [mydata.runs; r];
            mydata.conds = [mydata.conds; condID];
            mydata.condName = [mydata.condName; {MapNames{condID}}];

            %Extract beta series time course from ROI
            %This will be correlated with every other voxel in the brain
            if ischar(Betas)
                P = spm_vol(Betas);
            end

            est = spm_get_data(P,XYZ);
            est = est(~isnan(est));

            mydata.betas = [mydata.betas; est];
        end
    end
    cd(root_dir)
    save(['AllVsFix_p000000000000001_' roi_file{nROI} '_betas'],'mydata');
end