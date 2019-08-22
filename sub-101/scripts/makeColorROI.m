% PS 2018, tighten ROI to only include preferentially activated voxels (AllVsFix), then DoBetaSeries.m steps
Conds = {'1','2','3','4','5','6','7','8','9'};
MapNames = {'RedPink' 'RedOrange' 'Orange' 'Olive' 'Green' 'Teal' 'Blue' 'Purple' 'HotPink'};

cd([root_dir 'scripts'])

for nROI = 1:length(roi_file)
    mydata.betas=[];mydata.runs=[];mydata.conds=[];mydata.condName=[];mydata.trial=[];

    % load subject's ROI
    seedroi = [roi_dir roi_file{nROI} '.nii'];
    fprintf('ROI: %s \n',roi_file{nROI});

    % load subject-specific .mat information 
    load([root_dir '/Color_Contrast_scripts.mat']);

    % load SPM.mat and contrast (uses MarsBaR)
    spm_mat = [root_dir '/scripts/Color_vs_Gray_SPM.mat'];
    load(spm_mat);
    sess_model = mardo(spm_mat);
    con_name = SPM.xCon.name;
    t_con = get_contrast_by_name(sess_model, con_name);
    t_con_fname = t_con.Vspm.fname;

    % Get t threshold of uncorrected p < 0.001
    p_thresh = 0.001; %.000000001
    erdf = error_df(sess_model);
    t_thresh = spm_invTcdf(1-p_thresh, erdf);

    % get all voxels from t image above threshold
    V = spm_vol(t_con_fname);
    img = spm_read_vols(V);
    % get all voxels from t image above threshold
    Y = spm_read_vols(spm_vol(seedroi),1);
    indx = find(Y>=1 & img>t_thresh);
    [x,y,z] = ind2sub(size(Y),indx);
    XYZ = [x y z]';
    
    imgname = 'sV1.nii';
    o = maroi_image(struct('vol', spm_vol(imgname), 'binarize',0,...
    'func', 'img'));
    o = maroi_matrix(o);
    saveroi(o, 'my_image_roi.mat')

%     % make into clusters, find max cluster
%     cluster_nos = spm_clusters(XYZ);
%     [mx max_index] = max(img);
%     max_cluster = cluster_nos(max_index);
%     cluster_XYZ = XYZ(:, cluster_nos == max_cluster);

%     % make into clusters, eliminate small clusters
%     cluster_nos = spm_clusters(XYZ);
%     for clustNum = 1:length(unique(cluster_nos))
%         if length(cluster_nos(cluster_nos == clustNum)) > cluster_size
%             yesClust = clustNum;
%             break
%         end
%     end
%     cluster_XYZ = XYZ(:, cluster_nos >= clustNum);

    XYZ = cluster_XYZ;
    
    fprintf('num voxels: %i \n',length(XYZ));
    save(['ColorVsFix_' roi_file{nROI} '.mat'],'XYZ');
end