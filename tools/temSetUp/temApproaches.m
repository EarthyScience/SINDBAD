function [approaches,modules,modStruct] = temApproaches(varargin)
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
    'GetStates'         , 'simple'          ,...
    'Terrain'           , 'none'            ,...    % ? - elevation properties
    'SOIL'              , 'Saxton'          ,...    % ? - soil properties
    'VEG'               , 'none'            ,...    % ? - vegetation properties
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
    'WUE'               , 'Medlyn'          ,...    % 2 - Water 
    'SupplyTransp'      , 'Federer'         ,...    % 3 - Transpiration and GPP
    'LightEffectGPP'    , 'Maekelae2008'    ,...    % 3 - Transpiration and GPP
    'RdiffEffectGPP'    , 'Turner'          ,...    % 3 - Transpiration and GPP
    'TempEffectGPP'     , 'CASA'            ,...    % 3 - Transpiration and GPP
    'VPDEffectGPP'      , 'Wang'            ,...    % 3 - Transpiration and GPP
    'DemandGPP'         , 'mult'            ,...    % 3 - Transpiration and GPP
    'SMEffectGPP'       , 'Supply'          ,...    % 3 - Transpiration and GPP
    'ActualGPP'         , 'mult'            ,...    % 3 - Transpiration and GPP
    'Transp'            , 'Coupled'         ,...    % 3 - Transpiration and GPP
    'RootUptake'        , 'TopBottom'       ,...    % 3 - Transpiration and GPP
    'SoilMoistEffectRH' , 'CASA'            ,...    % 4 - Climate effects on metabolic processes
    'TempEffectRH'      , 'Q10'             ,...    % 4 - Climate effects on metabolic processes
    'TempEffectAutoResp', 'Q10'             ,...    % 4 - Climate effects on metabolic processes
    'CAllocationVeg'    , 'Friedlingstein'  ,...    % 5 - Allocation of C within plant organs
    'AutoResp'          , 'ATC_A'           ,...    % 6 - Autotrophic respiration
    'CCycle'            , 'CASA'            , ...   % 7 - Carbon Cycle / Heteroptrophic Respiration
    'PutStates'         , 'simple'          ...
    };
%% build the structure handles: NOT ANYMORE! THIS IS DONE AFTERWARDS NOW...
% get the core and TEM folder paths
tmp         = mfilename('fullpath');
ndx         = strfind(tmp,'temApproaches');
path_core	= strrep(tmp(1:ndx(end)-1),['tools' filesep 'temSetUp'],['model' filesep 'core']);
% add core to the matlab paths
addpath(path_core,'-begin')
% counter for the precomputations
k   = 0;
k1  = 0;
% output
approaches	= cell(numel(StandardApproaches)/2,1);
modules     = approaches;
modStruct   = struct;
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
    % feed the output
    k               = k + 1;
    approaches{k}   = coremodule;
    modules{k}      = StandardApproaches{i};
    % set the handle in the model structure variable (ms)
    eval(['tmpHandle                    = @(f,fe,fx,s,d,p,info,i)' coremodule '(f,fe,fx,s,d,p,info,i);']);
    modStruct.ms.(StandardApproaches{i}).doAlways   = 1;
    modStruct.ms.(StandardApproaches{i}).fun        = tmpHandle;
    modStruct.ms.(StandardApproaches{i}).funCont    = {};
    modStruct.ms.(StandardApproaches{i}).funPath    = [modDir coremodule '.m'];
    modStruct.ms.(StandardApproaches{i}).funName    = coremodule;
    modStruct.ms.(StandardApproaches{i}).funInput   = {};
    modStruct.ms.(StandardApproaches{i}).funOutput  = {};
    % check which are the precomputations
    precfn	= dir([modDir 'Prec_' coremodule '*.m']);
    for j = 1:numel(precfn)
        % indent the precomputations counter
        k1      = k1 + 1;
        % get the precomputation function name
        precfun	= precfn(j).name(1:end-2);
        % add it to the Precomputation handles
        eval(['tmpHandle        = @(f,fe,fx,s,d,p,info)' precfun '(f,fe,fx,s,d,p,info);']);
        modStruct.preComp(k1).doAlways  = 1;
        modStruct.preComp(k1).fun       = tmpHandle;
        modStruct.preComp(k1).funCont   = {};
        modStruct.preComp(k1).funPath   = [modDir precfn(j).name];
        modStruct.preComp(k1).funName   = precfun;
        modStruct.preComp(k1).funInput  = {};
        modStruct.preComp(k1).funOutput = {};
    end
end

end % function
