function [sSU,dSU] = runSpinupTEM(f,info,SUData,fSU,infoSU,...
    precOnceDataSU,fxSU,feSU,dSU,sSU)
% varargin
% #########################################################################
% PURPOSE	: do the spinup of the tem (carbon and water pools):
% 
% REFERENCES:
% 
% CONTACT	: ncarval
% 
% INPUT
% info      : structure info 
% 
% OUTPUT
% sSU       : state variables 
% dSU       : diagnostics
% 
% NOTES:
% 
% #########################################################################
%% ------------------------------------------------------------------------
% 1 - LOAD THE SPINUP FROM MEMORY OR FILES
% -------------------------------------------------------------------------
if info.tem.spinup.flags.loadSpinup
    % load the spinup file "restart.mat" inside the run path
    load(info.tem.spinup.paths.restartFile)
    % this needs to output sSU and dSU
    return
elseif~info.tem.spinup.flags.runSpinup
    % in this case we need to have SUData
    if ~isempty(SUData)
        if ~isempty(SUData.sSpinUp) && ~isempty(SUData.dSpinUp)
            % get the initial conditions from memory
            sSU	= SUData.sSpinUp;
            dSU	= SUData.dSpinUp;
        else
            error('No SUData.sSpinUp and SUData.dSpinUp in memory!')
        end
    else
        error('SUData is empty!')
    end
    return
end

if~info.tem.spinup.flags.runSpinup
    return
end
%% ------------------------------------------------------------------------
% 2 - RUN THE SPINUP
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% check whether there is the need to initialize stuff
% -------------------------------------------------------------------------
runFlags.initialize = false;
requirInitVars      = {'fxSU','feSU','dSU','sSU'};
if sum(cellfun(@(x)exist(x,'var'),requirInitVars)) < numel(requirInitVars)
    runFlags.initialize	= true;
end
% -------------------------------------------------------------------------
% Make the spinup data - only if it is an empty input
% -------------------------------------------------------------------------
if isempty(fSU)
    if info.tem.spinup.flags.recycleMSC
        fSU	= mkSpinUpData(f,info);
    else
        fSU	= f;
    end
end
% -------------------------------------------------------------------------
% Adjust the info structure - only if it is an empty input
% -------------------------------------------------------------------------
if isempty(infoSU)
    % make a new info for spin up based on info...
    infoSU	= info;
    % adjust the nTix
    tmp     = fieldnames(fSU);
    newNTix = size(fSU.(tmp{1}),2);
    infoSU.tem.helpers.sizes.nTix = newNTix;
    if info.tem.spinup.flags.recycleMSC
        infoSU.tem.model.nYears	= 1;
    end
    error(['we need to code here the initialization of the tem ' ...
        'helpers for the spinup and maybe more things... ' ...
        'not save anything and so on...'])
end
% -------------------------------------------------------------------------
% Pre-allocate fx,fe,d,s for the spinup runs
% -------------------------------------------------------------------------
if runFlags.initialize
    [fxSU,feSU,dSU,sSU]	= initTEMStruct(infoSU);
end
% -------------------------------------------------------------------------
% the parameters
% -------------------------------------------------------------------------
pSU	= info.tem.params;
% -------------------------------------------------------------------------
% Precomputations DO ONLY PRECOMP ALWAYS HERE - if an empty input...
% -------------------------------------------------------------------------
if isempty(precOnceDataSU)
    [fSU,feSU,fxSU,sSU,dSU,pSU]	= ...
        runCoreTEM(fSU,feSU,fxSU,sSU,dSU,pSU,infoSU,true,false,false);
    precOnceDataSU = struct;
    for v = {'fSU','feSU','fxSU','sSU','dSU','pSU'}
        eval(['precOnceDataSU.(i{1})	= ' v{1} ';']);
    end
else
    for v = {'fSU','feSU','fxSU','sSU','dSU','pSU'}
        eval([v{1} ' = precOnceData.(i{1});']);
    end
end
% -------------------------------------------------------------------------
% run the model for spin-up for NPP and soil water pools @ equilibrium
% -------------------------------------------------------------------------
disp(['we need to check if here is the number of years, ' ...
    'or the number of times that the spinup is being recycled!!!'])
for ij = 1:info.tem.spinup.nYears.water
    [fSU,feSU,fxSU,sSU,dSU,pSU]	= ...
        runCoreTEM(fSU,feSU,fxSU,sSU,dSU,pSU,infoSU,false,true,false);
end
% -------------------------------------------------------------------------
% run the model for spin-up for soil C pools @ equilibrium
% -------------------------------------------------------------------------
if info.tem.spinup.flags.runFastSpinup && ...
        strcmp('CASA',info.tem.model.modules.cCycle.apprName)
    [fSU,feSU,fxSU,sSU,dSU,pSU]	= ...
        CASA_fast(fSU,feSU,fxSU,sSU,dSU,pSU,infoSU);
else
    if info.tem.spinup.flags.runFastSpinup
        disp('somehow notpossible todo the spin up fastt...')
    end
    disp(['we need to check if here is the number of years, ' ...
        'or the number of times that the spinup is being recycled!!!'])
    for ij = 1:info.tem.spinup.nYears.carbon
        [fSU,feSU,fxSU,sSU,dSU,pSU] = ...
            runCoreTEM(fSU,feSU,fxSU,sSU,dSU,pSU,infoSU,false,true,true);
    end
end
% -------------------------------------------------------------------------
% force equilibrium
% -------------------------------------------------------------------------
% @NC: for spatial runs this can be optimized by subsampling the
% data only for gridcells where equilibrium is not achieved...
if info.tem.spinup.flags.forceNullNEP && ...
        strcmp('CASA',info.tem.model.modules.cCycle.apprName)
    NEP_LIM = info.tem.spinup.rules.limitNullNEP;
    MAXITER = info.tem.spinup.rules.maxIter;
    fNEP    = sum(fxSU.npp,2)-sum(fxSU.rh,2);
    k       = 0;
    % @NC: double check this when optimizing...
    while max(abs(fNEP)) > NEP_LIM && k <= MAXITER
        [fSU,feSU,fxSU,sSU,dSU,pSU]	= ...
            CASA_forceEquilibrium(fSU,feSU,fxSU,sSU,dSU,pSU,infoSU);
        k       = k + 1;
        fNEP	= sum(fxSU.npp,2)-sum(fxSU.rh,2);
    end
elseif info.tem.spinup.flags.forceNullNEP
    disp('somehow notpossible todo the forceNullNEP...')
end
end % function 
