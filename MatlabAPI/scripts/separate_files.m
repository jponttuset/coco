function separate_files(database,gt_set,method_out,method_in)

% addpath('/Users/jpont/Workspace/libs/coco/MatlabAPI')
addpath('/srv/glusterfs/jpont/dev/libs/coco/MatlabAPI')

% addpath(genpath('/Users/jpont/Workspace/bop/gt_wrappers'))
addpath(genpath('/srv/glusterfs/jpont/dev/bop/gt_wrappers/'))


root_folder = ['/srv/glusterfs/jpont/datasets/' database '/proposals/'];
% method = 'SharpMaskRegions';

res_folder = fullfile(root_folder,method_out);
if ~exist(res_folder,'dir')
    mkdir(res_folder);
end

% Get ids
ids = db_ids(database,gt_set);

files = dir(fullfile(root_folder, method_in, 'jsons', '*.json'));

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
        
        if strcmp(database,'Pascal')
            curr_id = sprintf('%d', id_set(jj));
            curr_id = [curr_id(1:4) '_' curr_id(5:end)];
        elseif strcmp(database,'COCO')
            curr_id = ['COCO_' gt_set '_' sprintf('%012d', id_set(jj))];
        else
            error('DB');
        end
        assert(ismember(curr_id,ids));
        
        % Write per-image
        file_out = fopen(fullfile(res_folder,[curr_id '.json']),'w');
        fprintf(file_out,'%s',gason(curr_prop));
        fclose(file_out);
    end
end







