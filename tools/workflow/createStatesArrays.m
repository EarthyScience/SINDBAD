function [s,d,info] = createStatesArrays(info)

% Usages:
%   [s,d,info] = createStatesArrays(s,d,info)
%
% Requires:
%   + a list of variables:
%       ++ state variables: info.tem.model.variables.states.input
%       ++ store in memory: info.tem.model.variables.to.store
%       ++ keep in memory: Feeds to s.prev. info.tem.model.code.variables.to.keepShortName,
%   + information on whether or not to combine the pool:
%       ++ info.tem.model.variables.states.input.(sv).combine
%           +++ first element: a logical on whether or not to combine the
%               pools
%           +++ second element: a string of the name of combined pool
%
% Purposes:
%   + Creates the arrays for the state variables needed to run the model.
%   + Creates the arrays in
%       ++ s: for current
%       (s.w.[VariableName],s.wd.[VariableName],s.c.[VariableName],s.cd.[VariableName])
%       pix,zix
%       ++ s.prev: previous (s.prev.[VariableName]) time step
%       ++ d.storedStates: for storing storage variables to save or later
%          write to a file
%   + Saves the information of state variables in info.tem.model.variables.states.(w,wd,c,cd)
%       ++
%   + Saves the list of created variables to info.tem.model.variables.created
%
% Conventions:
%   + s.w.[VariableName]: nPix,nZix
%   + s.prev.[VariableName]: nPix,nZix
%   + d.storedStates.[VariableName]: nPix,nZix,nTix
%
% Created by:
%   + Sujan Koirala (skoirala@bgc-jena.mpg.de)
%   + Nuno Carvalhais (ncarval@bgc-jena.mpg.de)
%
% References:
%   +
%
% Versions:
%   + 1.0 on 17.04.2018

%%
stateVars       =   fields(info.tem.model.variables.states);
s=struct;
d=struct;
if~isfield('info.tem.model.variables','created');info.tem.model.variables.created= {};end;
vars2store      =   info.tem.model.variables.to.store;
% vars2keep       =   info.tem.model.code.variables.to.keepSource; % need to confirm this with martin
vars2keep       =   info.tem.model.code.variables.to.keepDestination; % need to confirm this with martin

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
        nZix                    =   info.tem.model.variables.states.(sv).nZix.(poolNames{sp});
        eValStr                 =   strcat(sVar,' = repmat(arzerospix,1,nZix);');
        eval(eValStr);
        info.tem.model.variables.created{end+1}         =   sVar;
        if any(strcmp(vars2store,sVar))
            dVar            =   ['d.storedStates.' poolNames{sp}];
            deValStr        =   strcat(dVar,' = reshape(repmat(arnanpixtix,[nZix,1]),[nPix,nZix,nTix]);');
            eval(deValStr);
            info.tem.model.variables.created{end+1}     =   dVar;
        end
        kVar    =   ['s.prev.s_' sv '_' poolNames{sp}];
        if any(strcmp(vars2keep,kVar))
            %                 kVar=vark;%['s.prev.' poolNames{sp}];
            keValStr            =   strcat(kVar,' = repmat(arzerospix,1,nZix);');
            eval(keValStr);
            info.tem.model.variables.created{end+1}     =   kVar;
        end
    end
end
end
