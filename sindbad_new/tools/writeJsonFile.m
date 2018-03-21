function fid = writeJsonFile(pth, filename, data_json)
    
    json_txt_created = jsonencode(data_json);
    json_txt_created = strrep(json_txt_created, '\/','/');
    
    fid = fopen(strcat(pth, filename),'w');
    fprintf(fid,json_txt_created);
    fid = fclose(fid);

end
