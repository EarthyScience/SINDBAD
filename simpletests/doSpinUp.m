function [sSU,dSU] = doSpinUp(f,p,info,SUData)
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

if info.flags.doSpinUp
    % ---------------------------------------------------------------------
    % Make the spinup data - this should be done before?
    % ---------------------------------------------------------------------
    fSU	= mkSpinUpData(f,info);
    
    % ---------------------------------------------------------------------
    % Adjust the info structure
    % ---------------------------------------------------------------------
    infoSpin                    = info;
    infoSpin.forcing.size(2)    = floor(info.timeScale.stepsPerYear);
    infoSpin.timeScale.nYears   = 1;
    
    % ---------------------------------------------------------------------
    % Pre-allocate fx,fe,d,s for the spinup runs
    % ---------------------------------------------------------------------
    [fxSU,feSU,dSU,sSU]	= initTEMStruct(infoSpin);

    % ---------------------------------------------------------------------
    % Precomputations
    % ---------------------------------------------------------------------
    for prc = 1:numel(infoSpin.code.preComp)
%         tmp                 = infoSpin.code.preComp(prc).fun;     % no idea why this way
        [feSU,fxSU,dSU,p]	= infoSpin.code.preComp(prc).fun(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);  % works but not inline
    end
    
    % ---------------------------------------------------------------------
    % run the model for spin-up for NPP and soil water pools @ equilibrium
    % ---------------------------------------------------------------------
    for ij = 1:info.spinUp.wPools
        [sSU, fxSU, dSU] = core(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    end
    
    % ---------------------------------------------------------------------
    % run the model for spin-up for soil C pools @ equilibrium
    % ---------------------------------------------------------------------
    if~isempty(strmatch('CCycle_CASA',info.approaches,'exact'))
        [fxSU,sSU,dSU]	= CASA_fast(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    elseif isempty(strmatch('CCycle_none',info.approaches,'exact'))
        error('No spinUp definition for current setup.')
    end
    
    % ---------------------------------------------------------------------
    % save the spinup output?
    % ---------------------------------------------------------------------
    if ~isempty(info.outputs.saveSpinUp)
    end
else
    % ---------------------------------------------------------------------
    % steady state pools have to loaded from memory or from a restart file
    % ---------------------------------------------------------------------
    if info.flags.loadSpinUp
        % load the spinup file "restart.mat" inside the run path
        
    elseif ~isempty(SUData.sSpinUp) && ~isempty(SUData.dSpinUp)
        % get the initial conditions from memory
        sSU	= SUData.sSpinUp;
        dSU	= SUData.dSpinUp;
    else
        error('what to do for the spin up?!')
    end
end

end % function 
