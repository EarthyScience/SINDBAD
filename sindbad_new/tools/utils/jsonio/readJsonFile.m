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

end