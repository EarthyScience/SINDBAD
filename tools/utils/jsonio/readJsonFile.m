function data_json = readJsonFile(filepath)
% read a json file (filepath) into a data structure (data_json)
json_txt    = fileread(filepath);
good2go     =   false;
tryN        =   0;
while ~good2go
    tryN     =   tryN+1;
    try
        switch tryN
            case 1
                data_json = jsondecode(json_txt);
            case 2
                data_json = jsondecode(strrep(json_txt,'\','\\'));
                disp('MSG jsonFile is good to go: readJsonFile : replace \ by \\ ')
            otherwise
        end
        good2go = true;
    catch ME
        if tryN >= 2
            disp(ME)
            error([filepath 'has an error in syntax'])
        end
    end
end


% remove comments marked by fieldnames "1_c", "2_x" in the json-file...
info = data_json;
[~, tree] = editInfoField(info, '_c');
for ii = 1 : size(tree, 2)
    [info, tree2del] = editInfoField(info, ['x' num2str(ii) '_c']);
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
