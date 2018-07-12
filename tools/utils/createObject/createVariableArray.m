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
%   Sujan Koirala (skoirala@bgc-jena.mpg.de)
% 
% References: 
%   + 
%
% Versions: 
%   + 1.0 on 17.04.2018

%%
fe=struct;
fx=struct;

vars2create = info.tem.model.code.variables.to.create;
vars2redMem = info.tem.model.code.variables.to.redMem;
% vars2keep   = info.tem.model.code.variables.to.keepShortName;
vars2keep       =   info.tem.model.code.variables.to.keepDestination; % need to confirm this with martin

genRedMem = info.tem.model.flags.genRedMemCode;
runGenCode = info.tem.model.flags.runGenCode;
% genRedMem = true;
% runGenCode = true;
%--> get all locally needed arrays from helpers 
arnanpix= info.tem.helpers.arrays.nanpix;
arnanpixtix = info.tem.helpers.arrays.nanpixtix;
%--> create the variables to keep d.prev
kVarComp    =   'd.';
for kv = 1: numel(vars2keep)
    kVar= vars2keep{kv};
    if ~isempty(strfind(kVar,'d.'))
    keValStr            =   strcat(kVar,' = arnanpix;');
    eval(keValStr);
    info.tem.model.variables.created{end+1}     =   kVar;
    end
end
for v2c = 1:numel(vars2create)
    var2cr = vars2create{v2c};
    eValStr='';
    if runGenCode && genRedMem
        %         strcmp(vars2redMem,var2cr)
        if any(strcmp(vars2redMem,var2cr)) %% ismember is the inbuilt function that works
            if ~exist(var2cr,'var')
                eValStr     =   strcat(var2cr,' = arnanpix;');
            end
        end
    else
        eValStr     =   strcat(var2cr,' = arnanpixtix;');
    end
    if ~any(strcmp(info.tem.model.variables.created,var2cr))
        eval(eValStr);
        info.tem.model.variables.created{end+1}=var2cr;
    else
        disp(['The variable ' var2cr ' has already been created'])
    end
% need a block for non state variables to keep here to create d.prev.
end
end
