% Parse a struct to a JSON format
% only works for SINGLE strings/floats or structs as fields in the struct
function exportString = ParseStructToJSON(struct, indentLevel)
% Use indent level to track how many indents have been done in past calls
if nargin < 2
   indentLevel = 0;
end
% Use 4 whitespaces to indent (make JSON also human readible)
indent = repmat(' ', 1, 2);
% Get all field names of the struct and iterate over them
structFieldNames = fieldnames(struct);
% Initialize the export string
exportString = cell(1, length(structFieldNames));
% Track if there are sub structs
hasStruct = false;
for i = 1:length(structFieldNames)
    fieldValue = struct.(structFieldNames{i});
    % Extract the string from the field value
    if ischar(fieldValue)
        fieldString = ['"' fieldValue '"'];
    elseif isfloat(fieldValue)
        fieldString = num2str(fieldValue);
    elseif isstruct(fieldValue)
        hasStruct = true;
        % For a sub struct traverse all structs below
        fieldString = cell(1, length(fieldValue)+2);
        fieldString{1} = '[\n';
        fieldString{end} = [repmat(indent, 1, indentLevel+1) ']'];
        for j = 1:length(fieldValue)
            % Parse the sub structs
            currElementString = ParseStructToJSON(fieldValue(j), indentLevel+2);
            % Add no comma for last value
            if j ~= length(fieldValue)
                currElementString = [currElementString ','];
            end
            fieldString{j+1} = [currElementString '\n'];
        end
        % Join all sub struct strings with correct indents
        fieldString = strjoin(fieldString, '');
    else
        fieldString = '';
    end
    % Add field name and again no comma for the last value
    fieldString = ['"' structFieldNames{i} '": ' fieldString];
    if i ~= length(structFieldNames)
        fieldString = [fieldString ','];
    end
    exportString{i} = fieldString;
end
% If current struct has a sub struct parse with new lines
if hasStruct
    exportString = [repmat(indent, 1, indentLevel) '{\n' repmat(indent, 1, indentLevel+1) ...
        strjoin(exportString, ['\n' repmat(indent, 1, indentLevel+1)]) '\n' repmat(indent, 1, indentLevel) '}\n'];
% Else parse in one single line to maintain readability
else
    exportString = [repmat(indent, 1, indentLevel) '{ ' strjoin(exportString, ' ') ' }']; 
end
end

