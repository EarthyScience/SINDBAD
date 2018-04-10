function [d,s] = InitializeVariables(info,d,s)
% initialize states and diagnostics

% note: regarding water pools, everything, including stressors, are
% initialized at AWC := stressors == 1 : no stress

AllVars	= info.variables.all;
sstr    = {'d.','s.'};

VarNameIniVal	= {...
            ... % states
                's.wSM'                     , info.params.SOIL.iniAWC ; % soil moisture at full capacity
                's.wSWE'                    , info.helper.zeros1d   ; % no SWE
                's.wGW'                     , info.helper.zeros1d   ; % GW
                's.wGWR'                    , info.helper.zeros1d   ; % no GWR
                's.wWTD'                    , info.helper.zeros1d   ; % no WTD
                's.wFrSnow'                 , info.helper.zeros1d   ; % no wFrSnow
            ... % diagnostics / stressors
                'd.SMEffectGPP.SMScGPP'     , info.helper.ones2d    ; % no initial water stress in GPP
                'd.Temp.pSMScGPP'           , info.helper.ones1d    ; % no initial water stress in GPP
                'd.SoilMoistEffectRH.pBGME' , info.helper.ones1d    ; % no initial water stress in soil microbial decomposition
            ... % previous time steps in water related variables
                'd.Temp.pwGW'               , info.params.SOIL.iniAWC ; % soil moisture at full capacity
                'd.Temp.pwGWR'              , info.helper.zeros1d   ; % 
                'd.Temp.pwSWE'              , info.helper.zeros1d   ; % 
                'd.Temp.pwSM'               , info.params.SOIL.iniAWC ; % soil moisture at full capacity
                };

% the advantage of doing it this way is that not used variables (because
% of, e.g., different model structures) will not be initialized
% loop over d and s
for ii = 1:length(sstr)
    % find respective variables
    v   = find(strncmp(AllVars,sstr{ii},length(sstr{ii})));
    % loop over respective variables
    for jj = 1:length(v)
        % the variable name
        cVar	= AllVars{v(jj)};
        ndx     = strmatch(cVar,VarNameIniVal(:,1),'exact');
        if~isempty(ndx)
            eval([cVar ' = VarNameIniVal{ndx,2};'])
        end
    end
end

% the carbon and water pools
if ~(isempty(strmatch('s.cPools',AllVars,'exact')))
    s   = initCpools(info,s);
end
if ~(isempty(strmatch('s.smPools',AllVars,'exact')))
    s   = initSMpools(info,s);
end

end % function