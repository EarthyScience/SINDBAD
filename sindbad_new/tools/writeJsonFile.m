function fid = writeJsonFile(pth, filename, data_json)
% write a structure dataset (data_json) into a human readable JSON file
% (pth/filename). output the file open id (fid).

% encode json
json_txt_created    = jsonencode(data_json);
json_txt_created    = strrep(json_txt_created, '\/','/');
% write it
fid     = writeZfile(strcat(pth, filesep, filename),json_txt_created);
% read what was writen
tmp1	= readJsonFile(strcat(pth, filesep, filename));
% save it in a human readable way
try
    saveJSONfile(data_json, strcat(pth, filesep, filename));
catch
    disp(['MSG : writeJsonFile : not possible to save it in a human readable way...' ...
        ' may be related to multiple records in cell array... needs checking... ' ...
        'Stick to internal functions'])
    return
end
% read what was writen
tmp2    = readJsonFile(strcat(pth, filesep, filename));
% compare both outputs
if~isequal(tmp1,tmp2)
    fid = writeZfile(strcat(pth, filesep, filename),json_txt_created);
    disp('MSG : writeJsonFile : saveJSONfile : did not work. Stick to internal functions')
end
end

function fid = writeZfile(fn,txt)
fid = fopen(fn,'w');
fprintf(fid,txt);
fid = fclose(fid);
end