function [f,fe,fx,s,d,p] = coreTEM(f,fe,fx,s,d,p,info)
% #########################################################################
% tic
% CORE - ...
%
% DESCRIPTION:
%
% INPUTS:
%   s	: structure variable with all initial ecosystem states inside
%   f   : forcing variables
%   fe  : pre-computed extra 'forcing' - whatever is exclusively computed
%       from precomputations should be in fe
%   p   : parameter structure
%   
%   si contains the initial state
%
% OUTPUTS:
%   s   : structure variable with all the ecosystem states inside
%   fx	: flux variables
%   d   : diagnostics (where the stressors are also) - stressors that are
%   exclusively computed in precomputations should be in fe, and can be
%   updated in the end to d - could be used for double checks

% alternative names for info could be brain or sindbad

% CONTRIBUTORS:
%
% CONTACT:

% note, we should not need to do any checks here... this is operating as
% the number crunching core. Anything related to checks on inputs and
% consistency should be outside (before and afterwards!).
% anything that can be outsourced should be done

%MJ: i suggest to use an additional separate structure that contains pre-computed
%stuff (or will be populated with it during the loop) 'fe' because at least for
%site-level runs it will remain unchanged (efficient, matlab doesn't need
%to make copies)

% NOTES: moved from the block comment at the end (sujan, 2018-04-12)
% A) In this code, we should use the following strategy, e.g. for ET:
% if ET is not a forcing (~exist('f.ET','var'))
%     compute ET
% 
% for ET and GPP - this allows us to force the model with different
% datastreams
% 
% B) from 1->3 depends on the WAI flags (which we should start calling the
% 
% C) check mass balance in all different calculations (at each iteration or
% in the end? In the end: saves time)
% 
% D) don't forget to output the stressors for the spinup inside the
% diagnostics structure (d) to be used in the calc_cflux_fast
% #########################################################################

% -------------------------------------------------------------------------
% Do precomputations
% -------------------------------------------------------------------------
for prc = 1:numel(info.tem.model.code.prec)
    if info.tem.model.code.prec(prc).runAlways == 1
        [f,fe,fx,s,d,p]	= info.tem.model.code.prec(prc).funHandle(f,fe,fx,s,d,p,info);
    end
end

% -------------------------------------------------------------------------
% CARBON AND WATER FLUXES ON LAND
% -------------------------------------------------------------------------
% get the model structure
ms	= info.tem.model.code.ms;

% LOOP : loop through the whole length of of the forcing dataset
for tix = 1:info.tem.helpers.sizes.nTix
    % get states from previous time step
    [f,fe,fx,s,d,p]     =   ms.getStates.funHandle(f,fe,fx,s,d,p,info,tix);
              
        
    % ---------------------------------------------------------------------
    % 0 - Terrain - to get the terrain params ...    
    % 0 - SOIL - to get the soil related params ...
    % 0 - VEG - put here any LC changes / phenology / disturbances / ...
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]     =   ms.pTopo.funHandle(f,fe,fx,s,d,p,info,tix);
    [f,fe,fx,s,d,p]     =   ms.pSoil.funHandle(f,fe,fx,s,d,p,info,tix);
    [f,fe,fx,s,d,p]     =   ms.pVeg.funHandle(f,fe,fx,s,d,p,info,tix);

    % ---------------------------------------------------------------------
    % 1 - Snow
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]     =   ms.wSnwFr.funHandle(f,fe,fx,s,d,p,info,tix);            % add snow fall and calculate SnowCoverFraction
    [f,fe,fx,s,d,p]     =   ms.EvapSub.funHandle(f,fe,fx,s,d,p,info,tix);           % calculate sublimation and update swe
    [f,fe,fx,s,d,p]     =   ms.Qsnw.funHandle(f,fe,fx,s,d,p,info,tix);              % calculate snowmelt and update SWE
    
    % ---------------------------------------------------------------------
    % 2 - Water 
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]     =   ms.EvapInt.funHandle(f,fe,fx,s,d,p,info,tix);           % interception evaporation
    [f,fe,fx,s,d,p]     =   ms.QinfExc.funHandle(f,fe,fx,s,d,p,info,tix);
    
    % infiltration excess runoff
    [f,fe,fx,s,d,p]     =   ms.wSoilSatFr.funHandle(f,fe,fx,s,d,p,info,tix);        % saturation runoff
    [f,fe,fx,s,d,p]     =   ms.Qsat.funHandle(f,fe,fx,s,d,p,info,tix);              % saturation runoff
    [f,fe,fx,s,d,p]     =   ms.QwSoilRchg.funHandle(f,fe,fx,s,d,p,info,tix);        % recharge the soil
%     for tix2 = 1:10
    [f,fe,fx,s,d,p]     =   ms.Qint.funHandle(f,fe,fx,s,d,p,info,tix);              % interflow
%     end                                                                           % if e.g. infiltration excess runoff and or saturation runoff are not
                                                                                    % explicitly modelled then assign a dummy handle that returnes zeros and
                                                                                    % lump the FastRunoff into interflow
    [f,fe,fx,s,d,p]     =   ms.QwGRchg.funHandle(f,fe,fx,s,d,p,info,tix);           % recharge the groundwater 
    [f,fe,fx,s,d,p]     =   ms.Qbase.funHandle(f,fe,fx,s,d,p,info,tix);             % baseflow
    [f,fe,fx,s,d,p]     =   ms.wG2wSoil.funHandle(f,fe,fx,s,d,p,info,tix);          % Groundwater soil moisture interactions (e.g. capilary flux, water
                                                                                    % table in root zone etc)
    [f,fe,fx,s,d,p]     =   ms.EvapSoil.funHandle(f,fe,fx,s,d,p,info,tix);          % soil evaporation
            
    % ---------------------------------------------------------------------
    % 3 - Transpiration and GPP
    % ---------------------------------------------------------------------
	[f,fe,fx,s,d,p]     =   ms.WUE.funHandle(f,fe,fx,s,d,p,info,tix);               % estimate WUE
    [f,fe,fx,s,d,p]     =   ms.TranfwSoil.funHandle(f,fe,fx,s,d,p,info,tix);        % supply limited Transpiration
    [f,fe,fx,s,d,p]     =   ms.GPPfRdir.funHandle(f,fe,fx,s,d,p,info,tix);          % compute 'stress' scalars
    [f,fe,fx,s,d,p]     =   ms.GPPpot.funHandle(f,fe,fx,s,d,p,info,tix);            % maximum instantaneous radiation use efficiency
    [f,fe,fx,s,d,p]     =   ms.GPPfTair.funHandle(f,fe,fx,s,d,p,info,tix);          % effect of temperature
    [f,fe,fx,s,d,p]     =   ms.GPPfVPD.funHandle(f,fe,fx,s,d,p,info,tix);           % VPD effect
    [f,fe,fx,s,d,p]     =   ms.GPPdem.funHandle(f,fe,fx,s,d,p,info,tix);            % combine effects as multiplicative or minimum
    [f,fe,fx,s,d,p]     =   ms.GPPfwSoil.funHandle(f,fe,fx,s,d,p,info,tix);         % if 'coupled' requires access to iwue param    
    [f,fe,fx,s,d,p]     =   ms.GPPact.funHandle(f,fe,fx,s,d,p,info,tix);            % combine effects as multiplicative or minimum    
    [f,fe,fx,s,d,p]     =   ms.TranAct.funHandle(f,fe,fx,s,d,p,info,tix);           % if coupled computed from GPP
    [f,fe,fx,s,d,p]     =   ms.wRootUptake.funHandle(f,fe,fx,s,d,p,info,tix);       % root water uptake (extract water from soil)
    
    % ---------------------------------------------------------------------
    % 4 - Climate and other effects on metabolic processes
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]     =   ms.cCycleBase.funHandle(f,fe,fx,s,d,p,info,tix);
    [f,fe,fx,s,d,p]     =   ms.cTaufTsoil.funHandle(f,fe,fx,s,d,p,info,tix);        % effect of soil temperature on decomposition rates
    [f,fe,fx,s,d,p]     =   ms.cTaufwSoil.funHandle(f,fe,fx,s,d,p,info,tix);        % effect of soil moisture on decomposition rates
    [f,fe,fx,s,d,p]     =   ms.cTaufLAI.funHandle(f,fe,fx,s,d,p,info,tix);          % calculate litterfall scalars (that affect the changes in the vegetation k
    [f,fe,fx,s,d,p]     =   ms.cTaufpSoil.funHandle(f,fe,fx,s,d,p,info,tix);        % effect of soil texture on soil decomposition rates
    [f,fe,fx,s,d,p]     =   ms.cTaufpVeg.funHandle(f,fe,fx,s,d,p,info,tix);         % effect of vegetation properties on soil decomposition rates
    
    [f,fe,fx,s,d,p]     =   ms.cTauAct.funHandle(f,fe,fx,s,d,p,info,tix);
    
    [f,fe,fx,s,d,p]     =   ms.RAfTair.funHandle(f,fe,fx,s,d,p,info,tix);           % temperature effect on autotrophic maintenance respiration
    

    % ---------------------------------------------------------------------
    % 5 - Allocation of C within plant organs
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]     =   ms.cAllocfLAI.funHandle(f,fe,fx,s,d,p,info,tix);        % effect of LAI on carbon allocation 
    [f,fe,fx,s,d,p]     =   ms.cAllocfwSoil.funHandle(f,fe,fx,s,d,p,info,tix);      % effect of soil moisture on carbon allocation 
    [f,fe,fx,s,d,p]     =   ms.cAllocfTsoil.funHandle(f,fe,fx,s,d,p,info,tix);      % effect of soil temperature on carbon allocation 
    [f,fe,fx,s,d,p]     =   ms.cAllocfNut.funHandle(f,fe,fx,s,d,p,info,tix);        % (pseudo)effect of nutrients on carbon allocation 
    [f,fe,fx,s,d,p]     =   ms.cAlloc.funHandle(f,fe,fx,s,d,p,info,tix);            % combine the different effects of carbon allocation 
    [f,fe,fx,s,d,p]     =   ms.cAllocfTreeCover.funHandle(f,fe,fx,s,d,p,info,tix);  % adjustment of carbon allocation according to tree cover
    
    % ---------------------------------------------------------------------
    % 6 - Autotrophic respiration
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]     =    ms.RAact.funHandle(f,fe,fx,s,d,p,info,tix);             % determine growth and maintenance respiration -> NPP
    
    % ---------------------------------------------------------------------
    % 7 - Carbon transfers to soil pools
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]     =   ms.cFlowfpSoil.funHandle(f,fe,fx,s,d,p,info,tix);       % effect of soil texture on transfer between C pools
    [f,fe,fx,s,d,p]     =   ms.cFlowfpVeg.funHandle(f,fe,fx,s,d,p,info,tix);        % effect of vegetation properties on transfer between C pools
    [f,fe,fx,s,d,p]     =   ms.cFlowAct.funHandle(f,fe,fx,s,d,p,info,tix);
    [f,fe,fx,s,d,p]     =   ms.cCycle.funHandle(f,fe,fx,s,d,p,info,tix);            % allocate carbon to vegetation components
                                                                                    % litterfall and litter scalars
                                                                                    % calculate carbon cycle/decomposition/respiration in soil
	
    % ---------------------------------------------------------------------
    % Gather all variables that are desired and insert them
    % in fx,s,d
    % ---------------------------------------------------------------------
    
    % store current states in previous state variables
     [f,fe,fx,s,d,p]	= ms.storeStates.funHandle(f,fe,fx,s,d,p,info,tix);
     
end % END LOOP

end % function
%{
NOTES:
A) In this code, we should use the following strategy, e.g. for ET:
if ET is not a forcing (~exist('f.ET','var'))
    compute ET

for ET and GPP - this allows us to force the model with different
datastreams

B) from 1->3 depends on the WAI flags (which we should start calling the

C) check mass balance in all different calculations (at each iteration or
in the end? In the end: saves time)

D) don't forget to output the stressors for the spinup inside the
diagnostics structure (d) to be used in the calc_cflux_fast

%}
