function [sSU,dSU] = doSpinUp(f,p,info,SUData,precOdata)
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
    if info.spinUp.cycleMSC
        fSU	= mkSpinUpData(f,info);
    else
        fSU	= f;
    end
    % ---------------------------------------------------------------------
    % Adjust the info structure
    % ---------------------------------------------------------------------
    infoSpin    = info;
    if info.spinUp.cycleMSC
        infoSpin.forcing.size(2)    = floor(info.timeScale.stepsPerYear);
        infoSpin.timeScale.nYears   = 1;
    end
    infoSpin                        = temHelpers(infoSpin);
    infoSpin.variables.saveState	= {};
    
    % ---------------------------------------------------------------------
    % Pre-allocate fx,fe,d,s for the spinup runs
    % ---------------------------------------------------------------------
    [fxSU,feSU,dSU,sSU]	= initTEMStruct(infoSpin);

    % ---------------------------------------------------------------------
    % Precomputations DO ONLY PRECOMP ALWAYS HERE
    % ---------------------------------------------------------------------
    % DoPrecO=1;DoCore=0;Use4SpinUp=0;
% function [fx,s,d,fe,p]=runModel(f,fe,fx,s,d,p,info,DoPrecO,DoCore,Use4SpinUp)
    [fxSU,tmp,dSU,feSU,p]=runModel(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,1,0,0);
    
    
    %     if info.flags.runGenCode
    %         [feSU,fxSU,dSU,p]	= infoSpin.code.msi.preComp(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    %     else
    %         for prc = 1:numel(infoSpin.code.preComp)
    %             [feSU,fxSU,dSU,p]	= infoSpin.code.preComp(prc).fun(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    %         end
    %     end
    % ---------------------------------------------------------------------
    % run the model for spin-up for NPP and soil water pools @ equilibrium
    % ---------------------------------------------------------------------
    for ij = 1:info.spinUp.wPools %% number of years for spinup of water pools
        % DoPrecO=0;DoCore=1;Use4SpinUp=0;
        [fxSU,sSU,dSU,feSU,p]=runModel(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,0,1,0);
        %[fxSU,sSU,dSU]	= infoSpin.code.msi.core(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    end
    
    %
    %     if info.flags.runGenCode
    %         for ij = 1:info.spinUp.wPools
    %             [fxSU,sSU,dSU]	= infoSpin.code.msi.core(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    %         end
    %     else
    %         for ij = 1:info.spinUp.wPools
    %             [fxSU,sSU,dSU] = core(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    %         end
    %     end
    % ---------------------------------------------------------------------
    % run the model for spin-up for soil C pools @ equilibrium
    % ---------------------------------------------------------------------
    if~isempty(strmatch('CCycle_CASA',info.approaches,'exact'))
        if info.spinUp.cPools > 0
            if info.flags.doSpinUpFast == 1
                [fxSU,sSU,dSU]	= CASA_fast(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
            elseif info.flags.doSpinUpFast == 0
                for ij = 1:info.spinUp.cPools
                     % DoPrecO=0;DoCore=1;Use4SpinUp=1;
                    [fxSU,sSU,dSU,feSU,p]=runModel(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,0,1,1);
                end
%                if info.flags.runGenCode
%                    error('doSpinUp : not implemented yet!')
%                else
%                    for ij = 1:info.spinUp.cPools
%                        for ii = 1:infoSpin.forcing.size(2)
%							 %[fxSU,sSU,dSU]	= infoSpin.code.msi.core(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
%                            [fxSU,sSU,dSU]    = infoSpin.code.ms.AutoResp.fun(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,ii);
%                            [fxSU,sSU,dSU]    = infoSpin.code.ms.CCycle.fun(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,ii);
%                        end
%                    end
%                end
            end
        end
        
        
        % if~isempty(strmatch('CCycle_CASA',info.approaches,'exact'))
        %         if info.spinUp.cPools > 0
        %             if info.flags.doSpinUpFast == 1
        %                 [fxSU,sSU,dSU]	= CASA_fast(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
        %             elseif info.flags.doSpinUpFast == 0
        %                 if info.flags.runGenCode
        %                     error('doSpinUp : not implemented yet!')
        %                 else
        %                     for ij = 1:info.spinUp.cPools
        %
        %                         for ii = 1:infoSpin.forcing.size(2)
        %                             [fxSU,sSU,dSU]    = infoSpin.code.ms.AutoResp.fun(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,ii);
        %                             [fxSU,sSU,dSU]    = infoSpin.code.ms.CCycle.fun(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,ii);
        %                         end
        %                     end
        %                 end
        %             end
        %         end
		% end
        % force equilibrium
        % @NC: for spatial runs this can be optimized by subsampling the
        % data only for gridcells where equilibrium is not achieved...
        if info.flags.forceNullNEP == 1
            NEP_LIM = info.flags.spinUpLimNEP;
            MAXITER = info.flags.spinUpMaxIter;
            fNEP    = sum(fxSU.npp,2)-sum(fxSU.rh,2);
            k       = 0;
            % disp(num2str([k min(fNEP) max(fNEP)]))
            while max(abs(fNEP)) > NEP_LIM && k <= MAXITER % @NC: double check this when optimizing...
                k               = k + 1;
                [fxSU,sSU,dSU]  = CASA_forceEquilibrium(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
                fNEP            = sum(fxSU.npp,2)-sum(fxSU.rh,2);
                % disp(num2str([k min(fNEP) max(fNEP)]))
            end
        end
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
    elseif ~isempty(SUData)
        if ~isempty(SUData.sSpinUp) && ~isempty(SUData.dSpinUp)
            % get the initial conditions from memory
            sSU	= SUData.sSpinUp;
            dSU	= SUData.dSpinUp;
        else
            error('No SUData.sSpinUp and SUData.dSpinUp in memory!')
        end
    else %if SUData is empty, set all storages to zero
        
        
    end
end

end % function 
