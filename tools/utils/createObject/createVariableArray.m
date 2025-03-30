function [fe,fx,d,info] = createVariableArray(d,info)
% Creates the arrays for non-state variables
%
% Requires: 
%   + a list of variables to:
%       ++ create: info.tem.model.code.variables.to.create
%       ++ reduce memory: info.tem.model.code.variables.to.redMem
%       ++ keep in memory: info.tem.model.code.variables.to.keepShortName,
%          info.tem.model.code.variables.to.keepSOurce
%   + information on which mode the model is run
%       ++ generate memory efficient arrays: info.tem.model.flags.genRedMemCode
%       ++ run generated code: info.tem.model.flags.runGenCode
%
% Purposes: 
%   + Creates the arrays for the variables needed to run the model
%   + Only creates the arrays in f, fe, fx, d (d.prev) 
%
% Conventions: 
%   + fe.[ModuleName].[VariableName]: nPix,nTix
%   + fx.[ModuleName].[VariableName]: nPix,nTix
%   + d.[ModuleName].[VariableName]: nPix,nTix
%   + d.prev.[VariableName]: nPix,1
%
% Created by: 
%   Sujan Koirala (skoirala)
% 
% References: 
%   + 
%
% Versions: 
%   + 1.0 on 17.04.2018
%   - 1.1 on 10.02.2020: added section to create the diagnostic arrays to be
%   saved in d.prev fields, and set it to zeros (nPix,1)


%%
fe                      =   struct;
fx                      =   struct;

vars2create             =   info.tem.model.code.variables.to.create;
vars2redMem             =   info.tem.model.code.variables.to.redMem;

genRedMem               =   info.tem.model.flags.genRedMemCode;
runGenCode              =   info.tem.model.flags.runGenCode;

%--> get all locally needed arrays from helpers 
arnanpix                =   info.tem.helpers.arrays.nanpix;
arnanpixtix             =   info.tem.helpers.arrays.nanpixtix;

for v2c                 =   1:numel(vars2create)
    var2cr              =   vars2create{v2c};
    eValStr='';
    tmp                 =   arnanpixtix;
    if runGenCode && genRedMem
        if ismember(var2cr,vars2redMem)
            if ~exist(var2cr,'var')
                tmp     =   arnanpix;
            end
        end
    end
    eValStr             =   strcat(var2cr,' = tmp;');
    if ~isempty(var2cr) && ~ismember(var2cr,info.tem.model.variables.created)
        eval(eValStr);
        info.tem.model.variables.created{end+1}     =   var2cr;
    else
        disp([pad('WARN VARIABLE',20,'right') ' : ' pad('createVariableArray',20) ' | The variable ' var2cr ' has already been created'])
    end
end

%--> create all state arrays in d.prev
allPrevVars         =  info.tem.model.code.variables.to.keepDestination;
dPrevVars           =  allPrevVars(startsWith(allPrevVars,'d.prev'));
for sv = 1:numel(dPrevVars)
    prvDes     = dPrevVars{sv};
    eval([prvDes '= info.tem.helpers.arrays.zerospix;'])
    info.tem.model.variables.created{end+1}    =    prvDes;
end

end
