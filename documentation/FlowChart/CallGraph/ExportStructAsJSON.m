% Export struct to a JSON
function ExportStructAsJSON(struct, outputPath)

parsedStruct = ParseStructToJSON(struct);

fileID = fopen(outputPath, 'wt');
fprintf(fileID, parsedStruct);
fclose(fileID);

end
