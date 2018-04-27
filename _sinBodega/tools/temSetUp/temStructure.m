function ms = temStructure(varargin)
% #########################################################################
% FUNCTION	: 
% 
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: Nuno
% 
% INPUT     :
% 
% OUTPUT    :
% 
% #########################################################################
% defaults
%% number of arguments must be even
if rem(nargin,2)~=0
    error(['number of arguments must be even: nargin = ' num2str(nargin)])
end
%% set the defaults model structures for precomputations
% the inputs to this function
UserInputs      = varargin;
% the standards for the TEM
StandardApproaches  = {...
    'SOIL'              , 'Saxton'          ,...    % ? - soil properties
    'SnowCover'         , 'HTESSEL'         ,...	% 1 - Snow
    'Sublimation'       , 'GLEAM'           ,...    % 1 - Snow
    'SnowMelt'          , 'simple'          ,...    % 1 - Snow
    'Interception'      , 'Gash'            ,...    % 2 - Water 
    'RunoffInfE'        , 'none'            ,...    % 2 - Water 
    'SaturatedFraction' , 'none'            ,...    % 2 - Water 
    'RunoffSat'         , 'Zhang'           ,...    % 2 - Water 
    'RechargeSoil'      , 'TopBottom'       ,...    % 2 - Water 
    'RunoffInt'         , 'simple'          ,...    % 2 - Water 
    'RechargeGW'        , 'simple'          ,...    % 2 - Water 
    'BaseFlow'          , 'simple'          ,...    % 2 - Water 
    'SoilMoistureGW'    , 'none'            ,...    % 2 - Water 
    'SoilEvap'          , 'simple'          ,...    % 2 - Water 
    'SupplyTransp'      , 'Federer'         ,...    % 3 - Transpiration and GPP
    'LightEffectGPP'    , 'Maekelae2008'    ,...    % 3 - Transpiration and GPP
    'MaxRUE'            , 'Turner'          ,...    % 3 - Transpiration and GPP
    'TempEffectGPP'     , 'CASA'            ,...    % 3 - Transpiration and GPP
    'VPDEffectGPP'      , 'Medlyn'          ,...    % 3 - Transpiration and GPP
    'DemandGPP'         , 'mult'            ,...    % 3 - Transpiration and GPP
    'SMEffectGPP'       , 'Medlyn'          ,...    % 3 - Transpiration and GPP
    'ActualGPP'         , 'mult'            ,...    % 3 - Transpiration and GPP
    'Transp'            , 'Medlyn'          ,...    % 3 - Transpiration and GPP
    'RootUptake'        , 'TopBottom'       ,...    % 3 - Transpiration and GPP
    'SoilMoistEffectRH' , 'CASA'            ,...    % 4 - Climate effects on metabolic processes
    'TempEffectRH'      , 'Q10'             ,...    % 4 - Climate effects on metabolic processes
    'TempEffectAutoResp', 'Q10'             ,...    % 4 - Climate effects on metabolic processes
    'CAllocationVeg'    , 'Friedlingstein'  ,...    % 5 - Allocation of C within plant organs
    'AutoResp'          , 'ATC_A'           ,...    % 6 - Autotrophic respiration
    'CCycle'            , 'CASA'            ...     % 7 - Carbon Cycle / Heteroptrophic Respiration
    };
%% build the structure handles: NOT ANYMORE! THIS IS DONE AFTERWARDS NOW...
% get the core and TEM folder paths
tmp         = mfilename('fullpath');
ndx         = strfind(tmp,'temStructure');
path_core	= [tmp(1:ndx(end)-5) 'core' filesep];
% add core to the matlab paths
addpath(path_core,'-begin')
% counter for the precomputations
k   = 0;
% for every model component
for i = 1:2:numel(StandardApproaches)
    % which is the module to use?
    coremodule	= StandardApproaches{i+1};
    % check if it exists in the User inputs and if it is not empty
    ndx	= strmatch(StandardApproaches{i},UserInputs,'exact');
    if ~isempty(ndx)
        if ~isempty(UserInputs{ndx+1})
            coremodule	= UserInputs{ndx+1};
        end
    end
    coremodule	= [StandardApproaches{i} '_' coremodule];
    modDir      = [path_core 'Modules' filesep StandardApproaches{i} filesep];
    % add the path of the module to the beginning
    addpath(modDir,'-begin')
    % set the handle in the model structure variable (ms)
    eval(['tmpHandle                    = @(f,fe,fx,s,d,p,info,i)' coremodule '(f,fe,fx,s,d,p,info,i);']);
    ms.(StandardApproaches{i}).handle	= tmpHandle;
    ms.(StandardApproaches{i}).hName	= coremodule;
    % check which are the precomputations
    precfn	= dir([modDir 'Prec_' coremodule '.m']);
    for j = 1:numel(precfn)
        % indent the precomputations counter
        k       = k + 1;
        % get the precomputation function name
        precfun	= precfn(j).name(1:end-2);
        % add it to the Precomputation handles
        eval(['tmpHandle        = @(f,fe,fx,s,d,p,info)' precfun '(f,fe,fx,s,d,p,info);']);
        ms.PreCompFun(k).handle = tmpHandle;
        ms.PreCompFun(k).hName	= precfun;
    end
end

end % function
