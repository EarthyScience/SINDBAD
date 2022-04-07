function [info] = setupStateInfo(info)
% Usages: 
%   [s,d,info] = createStatesArrays(s,d,info)
%
% Requires: 
%   * a list of variables:
%       ** state variables: info.tem.model.variables.states.input
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
%   + Sujan Koirala (skoirala)
%   + Nuno Carvalhais (ncarval)
% 
% References: 
%   + 
%
% Versions: 
%   + 1.0 on 17.04.2018

%%

if ~isfield(info.tem.model.variables.states,'input')
  info.tem.model.variables.states.input     =   info.tem.model.variables.states;
end;


stateVars           =    fields(info.tem.model.variables.states.input');

for ii = 1:numel(stateVars)
    sv          =   stateVars{ii};
    if isfield(info.tem.model.variables.states,sv);...
        info.tem.model.variables.states        =   rmfield(info.tem.model.variables.states,sv);
    end;
    sInfo       =   [info.tem.model.variables.states.input.(sv).pools{:}]';
    sComb       =   info.tem.model.variables.states.input.(sv).combine;
    sStruct     =   struct;
    [sStruct]   =   genStateStructure(sInfo,sStruct,sComb);
    if isfield(sStruct.flags,sv)
        sStruct.flags.(sComb{2})    =    sStruct.flags.(sv);
        sStruct.flags               =    rmfield(sStruct.flags,sv);
    end
    if isfield(sStruct.zix,sv)
        sStruct.zix.(sComb{2})      =    sStruct.zix.(sv);
        sStruct.zix                 =   rmfield(sStruct.zix,sv);
    end
    [info]      =   setStatesInfo(sv,sStruct,info);
end

if isfield( info.tem.model.variables.states.input.w, 'wSoilLayersThickness') %% TINA HACK
% info.tem.model.variables.states.w.wSoilLayers = 
info.tem.model.variables.states.w.soilLayerDepths       =   info.tem.model.variables.states.input.w.wSoilLayersThickness;
end
% info.tem.model.variables.states.w.fracRoot2SoilD        =   info.tem.model.variables.states.input.w.fracRoot2SoilThickness;
info.tem.model.variables.states        =   rmfield(info.tem.model.variables.states,'input');

%%    
function [info]     =   setStatesInfo(sv,sStruct,info)
        stFields    =   fields(sStruct);
        for st=1:numel(stFields)
            info.tem.model.variables.states.(sv).(stFields{st})=sStruct.(stFields{st});
        end
end
%%

%%
function [sStruct]  =   genStateStructure(sInfo,sStruct,combPools)
    % generate the nameLayers from structure of the state
    
    nameLayers          =   sInfo(:,1:2);
    initValues         =   sInfo(:,3);
    %-->    check that the names are unique : we can just let it go too...
    if numel(unique(nameLayers(:,1)))   ~=  size(nameLayers,1)
        error('ERR : getFlagsPools : pool names are not unique')
    end
    
    doCombPools             =   combPools{1};
    combPoolName            =   combPools{2};
    if doCombPools
        nZix                =   sum([nameLayers{:,2}]);
        newNameLayers = cell(nZix,2);
        newInitValues = cell(nZix,1);
        layer_nm = 1;
        for i   =    1:size(nameLayers,1)
            numLayers = nameLayers{i,2};
            if numLayers == 1
                newNameLayers(layer_nm,1)=nameLayers(i,1);
                newNameLayers(layer_nm,2)=nameLayers(i,2);
                newInitValues(layer_nm)=initValues(i);
                layer_nm = layer_nm + 1;
            else
                for lN = 1:numLayers
                    tmpName = nameLayers(i,1);
                    layerName = [tmpName{:} num2str(lN)];
%                     layer_nm = i + lN-1
                    newNameLayers{layer_nm,1}     =   layerName;
                    newNameLayers{layer_nm,2}     =   1;
                    newInitValues(layer_nm)       =   initValues(i);
                    layer_nm = layer_nm + 1;
                end
            end
        end
        nameLayers = newNameLayers;
        [flags,zix]         =   genFlags(nameLayers);
        sStruct.flags       =   flags;
        sStruct.zix         =   zix;
        allNames            =   {};
        
        for i   =    1:size(nameLayers,1)
            allNames     =   [allNames  strrep(nameLayers(i,1),'.','')];
            fullName                        =   strrep(nameLayers{i,1},'.','');
            sStruct.initValue.(fullName)    =   newInitValues{i};
        end
        
        sStruct.names               =   cellstr(combPoolName);
        sStruct.components          =   allNames';
        sStruct.nZix.(combPoolName) = nZix;
        sStruct.initValue.(combPoolName)  =   combPools{3};
%         sStruct.(combPoolName) = allNames';
    else
        if~exist('sStruct','var')
            sStruct = struct;
        end
       allNames    = {};
       for i    =    1:size(nameLayers,1)
            nZix                            =    nameLayers{i,2};
            fullName                        =   strrep(nameLayers{i,1},'.','');
            allNames                        =   [allNames  fullName];
            sStruct.flags.(fullName)        =   true(1,nZix);
            sStruct.zix.(fullName)          =   1:nZix;
            sStruct.nZix.(fullName)         =   nZix;
            sStruct.initValue.(fullName)   =   initValues{i};
       end
        sStruct.names                       =   allNames';
        sStruct.components                  =   allNames';
            
    end
end

%%
function [flags,zix]    =    genFlags(nameLayers)
% check that the names are unique : we can just let it go too...
    if numel(unique(nameLayers(:,1)))    ~=  size(nameLayers,1)
        error('ERR : getFlagsPools : pool names are not unique. Check modelStructure[].json')
    end
    %-->    number of pools
    nPools          =    sum([nameLayers{:,2}]);
    ndxPools        =    [0 cumsum([nameLayers{:,2}])];
    %-->    flags (logical vectors in the structure)
    flags           =   struct;
    zix             =   struct;
    for i    =    1:size(nameLayers,1)
        pName       = nameLayers{i,1};
        fullName    = '';
        while ~isempty(pName)
            [fName, pName]              =    strtok(pName, '.');
            fullName                    =    [fullName fName];
            if  ~isfield(flags,fullName)
                    flags.(fullName)    =    false(1,nPools);
            end
            flags.(fullName)(ndxPools(i)+1:ndxPools(i+1))    =    true;
            zix.(fullName)                                  =    find(flags.(fullName) == true);
        end
    end
end

end
