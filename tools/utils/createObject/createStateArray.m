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
%   state variables not in modelStructure but in code: create nPix,1

%%
tf=logical(startsWith(info.tem.model.code.variables.moduleAll,'s.') .* ~startsWith(info.tem.model.code.variables.moduleAll,'s.prev'));
stateVarsCode=info.tem.model.code.variables.moduleAll(tf);
stateVars       =   fields(info.tem.model.variables.states);
s=struct;
d=struct;

if~isfield('info.tem.model.variables','created');info.tem.model.variables.created= {};end;
vars2store      =   info.tem.model.variables.to.store;
% vars2keep       =   info.tem.model.code.variables.to.keepSource; % need to confirm this with martin
% vars2keep       =   info.tem.model.code.variables.to.keepDestination; % need to confirm this with martin

nTix            =   info.tem.helpers.sizes.nTix;
nPix            =   info.tem.helpers.sizes.nPix;

%--> get all locally needed arrays from helpers
arnanpix        =   info.tem.helpers.arrays.nanpix;
arzerospix      =   info.tem.helpers.arrays.zerospix;
arnanpixtix     =   info.tem.helpers.arrays.nanpixtix;
for ii = 1:numel(stateVars)
    sv          =	stateVars{ii};
    poolNames   =   info.tem.model.variables.states.(sv).names;
    for sp=1:numel(poolNames)
        sVar                    =   ['s.' sv '.' poolNames{sp}];
        if ismember(sVar, stateVarsCode) %|| strcmp(sVar,'s.c.cEco')
            nZix                    =   info.tem.model.variables.states.(sv).nZix.(poolNames{sp});
            tmp = repmat(arzerospix,1,nZix);
            %tmp = zeros(size(repmat(arzerospix,1,nZix)));
            eValStr                 =   strcat(sVar,' = tmp;');
            eval(eValStr);
            tmp = 0;
            info.tem.model.variables.created{end+1}         =   sVar;
            if any(strcmp(vars2store,sVar))
                dVar            =   ['d.storedStates.' poolNames{sp}];
                tmp = reshape(repmat(arnanpixtix,[nZix,1]),[nPix,nZix,nTix]);
                %tmp = NaN(size(reshape(repmat(arnanpixtix,[nZix,1]),[nPix,nZix,nTix])));
                deValStr        =   strcat(dVar,' = tmp;');
                eval(deValStr);
                tmp = 0;
                info.tem.model.variables.created{end+1}     =   dVar;
            end
%             kVar    =   ['s.prev.s_' sv '_' poolNames{sp}];
%             if any(strcmp(vars2keep,kVar))
%                 %                 kVar=vark;%['s.prev.' poolNames{sp}];
%                 tmp = repmat(arzerospix,1,nZix);
%                 %tmp = zeros(size(repmat(arzerospix,1,nZix)));
%                 keValStr            =   strcat(kVar,' = tmp;');
%                 eval(keValStr);
%                 tmp = 0;
%                 info.tem.model.variables.created{end+1}     =   kVar;
%             end
        end
    end
end

for ii = 1:numel(stateVarsCode)
    sVar                    =   stateVarsCode{ii};
    if ~ismember(sVar,info.tem.model.variables.created) 
            tmp = arzerospix;
            eValStr                 =   strcat(sVar,' = tmp;');
            eval(eValStr);
            info.tem.model.variables.created{end+1}         =   sVar;
    end
end

end
