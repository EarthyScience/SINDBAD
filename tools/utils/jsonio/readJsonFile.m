function data_json = readJsonFile(filepath)
% read a json file (filepath) into a data structure (data_json)
json_txt = fileread(filepath);
try
    data_json = jsondecode(json_txt);
catch ME
    disp(['MSG : readJsonFile : error decoding : ' filepath])
    disp('MSG : readJsonFile : replace \ by \\ ')
    data_json = jsondecode(strrep(json_txt,'\','\\'));
end

% remove comments marked by fieldnames "1_c", "2_x" in the json-file...
info = data_json;
[~, tree] = editINFOSettings(info, '_c');
for ii = 1 : size(tree, 2)
    [info, tree2del] = editINFOSettings(info, ['x' num2str(ii) '_c']);
    if numel(tree2del) == 1
        tree2del = erase(tree2del,'info');
        tree2del = erase(tree2del,['.x' num2str(ii) '_c']);
        if ~isempty(tree2del{:})
            info.(tree2del{:}(2:end)) = rmfield(info.(tree2del{:}(2:end)),['x' num2str(ii) '_c']);
        else
            info = rmfield(info,['x' num2str(ii) '_c']);
        end        
    end
end 
data_json = info;
end
