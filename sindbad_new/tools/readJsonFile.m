function data_json = readJsonFile(path, filename)

    json_txt = fileread([path filename]);

    data_json = jsondecode(json_txt);

end
