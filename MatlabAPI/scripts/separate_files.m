
%addpath('/Users/jpont/Workspace/libs/coco/MatlabAPI')
addpath('/srv/glusterfs/jpont/dev/libs/coco/MatlabAPI')

%addpath(genpath('/Users/jpont/Workspace/bop/gt_wrappers'))
addpath(genpath('/srv/glusterfs/jpont/dev/bop/gt_wrappers/'))

root_folder = '/srv/glusterfs/jpont/datasets/Pascal/proposals/';
method = 'SharpMask-regions';

res_folder = fullfile(root_folder,method);
if ~exist(res_folder,'dir')
    mkdir(res_folder);
end

ids = db_ids('Pascal','Main_val_2012');
% db_ids('COCO','val2014')

files = dir(fullfile(root_folder, [method '-val2012'], 'jsons', '*.json'));

for ii=1:length(files)
    
    % Read file
    prop_set = gason(fileread(fullfile(files(ii).folder,files(ii).name)));
    
    % Get image ids
    id_list = [prop_set.image_id];
    id_set = unique(id_list);
    assert(length(id_set)==500 || length(id_set)==mod(length(ids),500))
    
    % Process all 500 images
    for jj=1:length(id_set)
        % Isolate current proposals
        curr_prop = prop_set(id_list==id_set(jj));
        assert(length(curr_prop)==1000)
        
        % Get the Pascal-style ID
        curr_id = sprintf('%d', id_set(jj));
        curr_id = [curr_id(1:4) '_' curr_id(5:end)];
        assert(ismember(curr_id,ids));
        
        % Write per-image
        file_out = fopen(fullfile(res_folder,[curr_id '.json']),'w');
        fprintf(file_out,gason(curr_prop));
        fclose(file_out);
    end
end







