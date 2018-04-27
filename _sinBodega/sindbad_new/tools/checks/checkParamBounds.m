function [] = checkParamBounds(info)
% checks whether the parameter value is within its predefined range
paramList   = info.tem.model.variables.paramInput;

for ii=1:length(paramList)
    paramInfo   = strsplit(paramList{ii},'.');
    module      = paramInfo{2};
    appr        = info.tem.model.modules.(module).apprName;
    paramName   = paramInfo{3};
    paramValue  = info.tem.params.(module).(paramName);
    if ischar(paramValue) paramValue = str2num(paramValue);end
    % load the json of the approach
    file_json   = convertToFullPaths(['./model/modules/' module '/' module '_' appr  '/' module '_' appr '.json']);
    if exist(file_json,'file')
        param_json    = readJsonFile(file_json);
        if paramValue < param_json.params.(paramName).LowerBound
            warning(['Parameter value of: ' paramList{ii} ' (' num2str(paramValue) ') is below its lower bound of: ' num2str( param_json.params.(paramName).LowerBound) '!']);
        elseif paramValue > param_json.params.(paramName).UpperBound
            warning(['Parameter value of: ' paramList{ii} ' (' num2str(paramValue) ') is above its upper bound of: ' num2str(param_json.params.(paramName).UpperBound) '!']);            
        end
        
    end
    
end

end