function [ obs ] = readConstraintsFluxNet(info)
%% (preliminary) function that reads monthly constraints from an ExpStruct used in the TWS paper
% contact: Tina Trautmann

% load the data
% for each variable, yet right now the DataPath for all is the same

% extract the defined constraints
for ii=1:numel(info.opti.constraints.VariableNames)
    varName         = info.opti.constraints.VariableNames{ii};
    DataPath      = info.opti.constraints.(varName).DataPath;
    varNameSource   = info.opti.constraints.(varName).SourceVariableName;
    try
        obs.(varName)     = ncread(DataPath, varNameSource)';
    catch
        error(['CRIT: readConstraintsFluxNet: Variable ' varNameSource ' not found in Constraints.']);
    end
    DataPathUnc      = info.opti.constraints.(varName).VariableUncertainty.Data.DataPath;
    varNameSourceUnc   = info.opti.constraints.(varName).VariableUncertainty.Data.SourceVariableName;
    try
        obs.unc.(varName)     = ncread(DataPathUnc, varNameSourceUnc)';
    catch
        error(['CRIT: readConstraintsFluxNet: Uncertainty Variable ' varNameSourceUnc ' not found in Constraints.']);
    end
    
    DataPathFlag      = info.opti.constraints.(varName).QualityFlag.Data.DataPath;
    varNameSourceFlag   = info.opti.constraints.(varName).QualityFlag.Data.SourceVariableName;
    try
        obs.flag.(varName)     = ncread(DataPathFlag, varNameSourceFlag)';
    catch
        error(['CRIT: readConstraintsFluxNet: Flag Variable ' varNameSourceFlag ' not found in Constraints.']);
    end
    
end

end