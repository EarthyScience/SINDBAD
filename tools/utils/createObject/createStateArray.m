function [s,d,info] = createStateArray(info)
% Creates the arrays of state variables before the model run.
%
% Requires:
%	- a list of variables
%       - state variables: info.tem.model.variables.states.input
%       - store in memory: info.tem.model.variables.to.store
%       - keep in memory: Feeds to s.prev. info.tem.model.code.variables.to.keepShortName,
%	- information on whether or not to combine the pool
%       - info.tem.model.variables.states.input.(sv).combine
%       - first element: a logical on whether or not to combine the
%               pools
%       - second element: a string of the name of combined pool
% Purposes:
%   - Creates the arrays for the state variables needed to run the model.
%   - Creates the arrays in
%       - s: for current
%       (s.w.[VariableName],s.wd.[VariableName],s.c.[VariableName],s.cd.[VariableName])
%       pix,zix
%       - s.prev: previous (s.prev.[VariableName]) time step
%       - d.storedStates: for storing storage variables to save or later
%          write to a file
%   - Saves the information of state variables in info.tem.model.variables.states.(w,wd,c,cd)
%       -
%   - Saves the list of created variables to info.tem.model.variables.created
%
% Conventions:
%   - s.w.[VariableName]: nPix,nZix
%   - s.prev.[VariableName]: nPix,nZix
%   - d.storedStates.[VariableName]: nPix,nZix,nTix
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%   - Nuno Carvalhais (ncarval@bgc-jena.mpg.de)
%
% References:
%   -
%
% Versions:
%   - 1.0 on 17.04.2018
%   - 1.1 on 05.11.2019 (handling of variables available in model
%   structure, and removal of prev or variables to keep. exception for
%   state variables not in modelStructure but in code: create nPix,1 and
%   moving of storedStates fields to storeStates_simple

%%

%--> get the variables in the model and input in modelStructure.json
tf                      =   logical(startsWith(info.tem.model.code.variables.moduleAll,'s.')...
                            .* ~startsWith(info.tem.model.code.variables.moduleAll,'s.prev'));
stateVarsCode           =   info.tem.model.code.variables.moduleAll(tf);
stateVars               =   fields(info.tem.model.variables.states);

%--> get the list of variables to keep
keepVarsSource          =   info.tem.model.code.variables.to.keepSource;
keepVars                =   {};
for ij                  =	1:numel(keepVarsSource)
    var2ks              =   keepVarsSource{ij}(1:end-1);
    keepVars            =   [keepVars var2ks];
end

stateVarsCode=unique(vertcat(stateVarsCode(:),keepVars(:)));
%--> initiate the sindbad structures and info fields
s                       =   struct;
d                       =   struct;
if~isfield('info.tem.model.variables','created');info.tem.model.variables.created={};end;

nTix                    =   info.tem.helpers.sizes.nTix;
nPix                    =   info.tem.helpers.sizes.nPix;

%--> get all locally needed arrays from helpers
arnanpix                =   info.tem.helpers.arrays.nanpix;
arzerospix              =   info.tem.helpers.arrays.zerospix;
arnanpixtix             =   info.tem.helpers.arrays.nanpixtix;


for ij                  =	1:numel(stateVarsCode)
    var2cr               =  stateVarsCode{ij};
    varPart             =   cellstr(strsplit(var2cr,'.'));
    sv                  =   varPart{2};
    poolName            =   varPart{3};
    if ~ismember(var2cr,info.tem.model.variables.created) && isempty(strfind(poolName, 'p_'))
        try
            nZix        =   info.tem.model.variables.states.(char(sv)).nZix.(poolName);
        catch
            if ismember(sv,{'c' 'cd'})
                nZix    =   info.tem.model.variables.states.c.nZix.cEco;
            else
                disp([pad('WARN STATE ARRAY',20,'right') ' : ' pad('createStateArray',20) ' | The state variable ' var2cr ' exists in the code, but its size is not defined in modelStructure.json: Using nZix = 1'])
                nZix    =   1;
            end
        end
        if isempty(strfind(sv, 'd')) || ismember(var2cr,keepVars)
            if startsWith(var2cr,'s.')
                tmp             =   repmat(arzerospix,1,nZix);
                eValStr         =   strcat(var2cr,' = tmp;');
                eval(eValStr);
                info.tem.model.variables.created{end+1}    =    var2cr;
            end
            end
    end
    
end
end
