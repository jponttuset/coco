function separate_files_boxes(database,gt_set,method_out,method_in)

% addpath(genpath('/srv/glusterfs/jpont/dev/bop/gt_wrappers/'))
% addpath('/srv/glusterfs/jpont/dev/libs/coco/MatlabAPI')

root_folder = ['/srv/glusterfs/jpont/datasets/' database '/boxes/'];
% method = 'SharpMaskRegions';

res_folder = fullfile(root_folder,method_out);
if ~exist(res_folder,'dir')
    mkdir(res_folder);
end

% Get ids
ids = db_ids(database,gt_set);

% % Start all files
% for ii=1:length(ids)
%     fid = fopen(fullfile(res_folder,[ids{ii} '.json']),'w');
%     fprintf(fid,'[');
%     fclose(fid);
% end

% Allocate output
out_strings = cell(1,length(ids));

% Read the input file
fid = fopen(fullfile(root_folder,[method_in '.json']),'r');

% Start temporary variables
c = fscanf(fid,'%c',1);
assert(c=='[')
curr_buf = [];
end_found = 0;
group_end = 0;
in_bracket  = 0;

% Scan until the end is found
num_groups = 0;
tic
while ~end_found
    c = fscanf(fid,'%c',1);
    switch c
        case '{'
            curr_buf = [];
        case '}'
            group_end=1;
        case '['
            in_bracket = 1-in_bracket;
        case ']'
            if ~in_bracket, end_found = 1; end
            in_bracket = 1-in_bracket;
    end

    curr_buf = [curr_buf c];  %#ok<AGROW>
    
    if group_end
        num_groups = num_groups+1;
        if mod(num_groups,10000)==0
            toc
            disp(num2str(num_groups))
            tic
        end
        
        % Check the image id
        curr_box = gason(curr_buf);
        loc = find(ismember(ids,['COCO_val2014_' sprintf('%012d', curr_box.image_id)]));
        
        % Save curr_buff
%         fprintf(fids(ii),'%s',curr_buf);
        if isempty(out_strings{loc})
            out_strings{loc} = curr_buf;
        else  
            out_strings{loc} = [out_strings{loc} ',' curr_buf];
        end
        curr_buf = [];
        group_end = 0;
    end
end
    
% Close all files
fids = zeros(length(ids));
for ii=1:length(fids)
    fprintf(fids(ii),']');
    fclose(fids(ii));
end
    