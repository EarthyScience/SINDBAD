function [approaches,modules] = temApproaches(info,varargin)
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
if rem(nargin-1,2)~=0
    error(['number of arguments must be even: varargin = ' num2str(nargin-1)])
end
%% set the defaults model structures for precomputations
% the inputs to this function
UserInputs      = varargin;
% the standards for the TEM
StandardApproaches_tmp  = {...
    'GetStates'         , 'simple'          ,...
    'Terrain'           , 'none'            ,...    % ? - elevation properties
    'SOIL'              , 'none'            ,...    % ? - soil properties
    'VEG'               , 'none'            ,...    % ? - vegetation properties
    'SnowCover'         , 'none'            ,...	% 1 - Snow
    'Sublimation'       , 'none'            ,...    % 1 - Snow
    'SnowMelt'          , 'none'            ,...    % 1 - Snow
    'Interception'      , 'none'            ,...    % 2 - Water 
    'RunoffInfE'        , 'none'            ,...    % 2 - Water 
    'SaturatedFraction' , 'none'            ,...    % 2 - Water 
    'RunoffSat'         , 'none'            ,...    % 2 - Water 
    'RechargeSoil'      , 'none'            ,...    % 2 - Water 
    'RunoffInt'         , 'none'            ,...    % 2 - Water 
    'RechargeGW'        , 'none'            ,...    % 2 - Water 
    'BaseFlow'          , 'none'            ,...    % 2 - Water 
    'SoilMoistureGW'    , 'none'            ,...    % 2 - Water 
    'SoilEvap'          , 'none'            ,...    % 2 - Water 
    'WUE'               , 'none'            ,...    % 2 - Water 
    'SupplyTransp'      , 'none'            ,...    % 3 - Transpiration and GPP
    'LightEffectGPP'    , 'none'            ,...    % 3 - Transpiration and GPP
    'MaxRUE'            , 'none'            ,...    % 3 - Transpiration and GPP
    'TempEffectGPP'     , 'none'            ,...    % 3 - Transpiration and GPP
    'VPDEffectGPP'      , 'none'            ,...    % 3 - Transpiration and GPP
    'DemandGPP'         , 'none'            ,...    % 3 - Transpiration and GPP
    'SMEffectGPP'       , 'none'            ,...    % 3 - Transpiration and GPP
    'ActualGPP'         , 'none'            ,...    % 3 - Transpiration and GPP
    'Transp'            , 'none'            ,...    % 3 - Transpiration and GPP
    'RootUptake'        , 'none'            ,...    % 3 - Transpiration and GPP
    'SoilMoistEffectRH' , 'none'            ,...    % 4 - Climate effects on metabolic processes
    'TempEffectRH'      , 'none'            ,...    % 4 - Climate effects on metabolic processes
    'TempEffectAutoResp', 'none'            ,...    % 4 - Climate effects on metabolic processes
    'CAllocationVeg'    , 'none'            ,...    % 5 - Allocation of C within plant organs
    'AutoResp'          , 'none'            ,...    % 6 - Autotrophic respiration
    'CCycle'            , 'none'            ,...   % 7 - Carbon Cycle / Heteroptrophic Respiration
    'PutStates'         , 'none'          ...
    };
%%
pthCore=[info.paths.core 'core.m'];
[ModuleNames]=GetModuleNamesFromCore(pthCore);

StandardApproaches=cell(1,2*length(ModuleNames));
for ii=1:length(ModuleNames)
    StandardApproaches(1,ii*2-1)=ModuleNames(ii);
    tf=strcmp(ModuleNames(ii),StandardApproaches_tmp);
    vv=find(tf);
    if isempty(vv)
        mmsg=['No default approach for module ' char(ModuleNames(ii)) ' defined'];
        error(mmsg)
    else
        StandardApproaches(1,ii*2)=StandardApproaches_tmp(vv+1);
    end
end


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
    % check that the module exists
    if~exist([modDir coremodule '.m'],'file')
        error(['temApproaches : MODULE : ' coremodule ' does not exist'])
    end
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
