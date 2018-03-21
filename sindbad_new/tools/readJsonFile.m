function data_json = readJsonFile(filepath)

    json_txt = fileread(filepath);

    data_json = jsondecode(json_txt);

end
