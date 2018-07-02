function [ obs ] = readExpStructConstraints(info)
%% (preliminary) function that reads monthly constraints from an ExpStruct used in the TWS paper
% contact: Tina Trautmann

% load the data
% for each variable, yet right now the DataPath for all is the same
tmpVar        = info.opti.constraints.VariableNames{1};
DataPath      = info.opti.constraints.(tmpVar).DataPath;
ExpStruct     = importdata(DataPath, 'ExpStruct');

% extract the defined constraints
for ii=1:numel(info.opti.constraints.VariableNames)
    varName         = info.opti.constraints.VariableNames{ii};
    varNameSource   = info.opti.constraints.(varName).SourceVariableName;
    obs.(varName)   = ExpStruct.Calibration.(varNameSource);
end

end