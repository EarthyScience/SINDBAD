function [fx,s,d] = coreTEM(f,fe,fx,s,d,p,info)
% tic
% CORE - ...
%
% DESCRIPTION:
%
% INPUTS:
%   si	: structure variable with all initial ecosystem states inside
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

% -------------------------------------------------------------------------
% Do precomputations
% -------------------------------------------------------------------------
for prc = 1:numel(info.code.preComp)
    if info.code.preComp(prc).doAlways == 1
        [fe,fx,d,p]	= info.code.preComp(prc).fun(f,fe,fx,s,d,p,info);
    end
end

% -------------------------------------------------------------------------
% CARBON AND WATER FLUXES ON LAND
% -------------------------------------------------------------------------
% get the model structure
ms	= info.code.ms;

% LOOP : loop through the whole length of of the forcing dataset
for tix = 1:info.forcing.size(2)
    % get states from previous time step
    [fx,s,d]	= ms.getStates.fun(f,fe,fx,s,d,p,info,tix);
              
        
    % ---------------------------------------------------------------------
    % 0 - Terrain - to get the terrain params ...    
    % 0 - SOIL - to get the soil related params ...
    % 0 - VEG - put here any LC changes / phenology / disturbances / ...
    % ---------------------------------------------------------------------
    [fx,s,d]	= ms.ptopo.fun(f,fe,fx,s,d,p,info,tix);
    [fx,s,d]	= ms.psoil.fun(f,fe,fx,s,d,p,info,tix);
    [fx,s,d]	= ms.pveg.fun(f,fe,fx,s,d,p,info,tix);

    % ---------------------------------------------------------------------
    % 1 - Snow
    % ---------------------------------------------------------------------
    [fx,s,d]	= ms.wSnwFr.fun(f,fe,fx,s,d,p,info,tix);    % add snow fall and calculate SnowCoverFraction
    [fx,s,d]    = ms.EvapSub.fun(f,fe,fx,s,d,p,info,tix);  % calculate sublimation and update swe
    [fx,s,d]    = ms.Qsnw.fun(f,fe,fx,s,d,p,info,tix);     % calculate snowmelt and update SWE
    
    % ---------------------------------------------------------------------
    % 2 - Water 
    % ---------------------------------------------------------------------
    [fx,s,d]    = ms.EvapInt.fun(f,fe,fx,s,d,p,info,tix);         % interception evaporation
    [fx,s,d]    = ms.Qinf.fun(f,fe,fx,s,d,p,info,tix);           % infiltration excess runoff
    [fx,s,d]    = ms.wSoilSatFr.fun(f,fe,fx,s,d,p,info,tix);    % saturation runoff
    [fx,s,d]    = ms.Qsat.fun(f,fe,fx,s,d,p,info,tix);            % saturation runoff
    [fx,s,d]    = ms.QwSoilRchg.fun(f,fe,fx,s,d,p,info,tix);         % recharge the soil
    [fx,s,d]    = ms.Qint.fun(f,fe,fx,s,d,p,info,tix);            % interflow
                                                                        % if e.g. infiltration excess runoff and or saturation runoff are not
                                                                        % explicitly modelled then assign a dummy handle that returnes zeros and
                                                                        % lump the FastRunoff into interflow
    [fx,s,d]    = ms.QwGRchg.fun(f,fe,fx,s,d,p,info,tix);           % recharge the groundwater 
    [fx,s,d]    = ms.Qbase.fun(f,fe,fx,s,d,p,info,tix);             % baseflow
    [fx,s,d]    = ms.wG2wSoil.fun(f,fe,fx,s,d,p,info,tix);       % Groundwater soil moisture interactions (e.g. capilary flux, water
                                                                        % table in root zone etc)
    [fx,s,d]    = ms.EvapSoil.fun(f,fe,fx,s,d,p,info,tix);             % soil evaporation
            
    % ---------------------------------------------------------------------
    % 3 - Transpiration and GPP
    % ---------------------------------------------------------------------
	[fx,s,d]    = ms.WUE.fun(f,fe,fx,s,d,p,info,tix);              % estimate WUE
    [fx,s,d]    = ms.TranfwSoil.fun(f,fe,fx,s,d,p,info,tix);     % supply limited Transpiration
    [fx,s,d]    = ms.GPPfRdir.fun(f,fe,fx,s,d,p,info,tix);   % compute 'stress' scalars
    [fx,s,d]    = ms.GPPpot.fun(f,fe,fx,s,d,p,info,tix);           % maximum instantaneous radiation use efficiency
    [fx,s,d]    = ms.GPPfTair.fun(f,fe,fx,s,d,p,info,tix);    % effect of temperature
    [fx,s,d]    = ms.GPPfVPD.fun(f,fe,fx,s,d,p,info,tix);     % VPD effect
    [fx,s,d]    = ms.GPPdem.fun(f,fe,fx,s,d,p,info,tix);        % combine effects as multiplicative or minimum
    [fx,s,d]    = ms.GPPfwSoil.fun(f,fe,fx,s,d,p,info,tix);      % if 'coupled' requires access to iwue param    
    [fx,s,d]    = ms.GPPact.fun(f,fe,fx,s,d,p,info,tix);        % combine effects as multiplicative or minimum    
    [fx,s,d]    = ms.TranAct.fun(f,fe,fx,s,d,p,info,tix);           % if coupled computed from GPP
    [fx,s,d]    = ms.wRootUptake.fun(f,fe,fx,s,d,p,info,tix);       % root water uptake (extract water from soil)
    
    % ---------------------------------------------------------------------
    % 4 - Climate effects on metabolic processes
    % ---------------------------------------------------------------------
    [fx,s,d]    = ms.RHfwSoil.fun(f,fe,fx,s,d,p,info,tix);    % effect of soil moisture on decomposition
    [fx,s,d]    = ms.RHfTsoil.fun(f,fe,fx,s,d,p,info,tix);         % effect of temperature on decomposition
    [fx,s,d]    = ms.RAfTair.fun(f,fe,fx,s,d,p,info,tix);   % temperature effect on autotrophic maintenance respiration

    % ---------------------------------------------------------------------
    % 5 - Allocation of C within plant organs
    % ---------------------------------------------------------------------
    [fx,s,d]	= ms.cAlloc.fun(f,fe,fx,s,d,p,info,tix);       % carbon allocation factors
    
    % ---------------------------------------------------------------------
    % 6 - Autotrophic respiration
    % ---------------------------------------------------------------------
    [fx,s,d]    = ms.RAact.fun(f,fe,fx,s,d,p,info,tix);             % determine growth and maintenance respiration -> NPP
    
    % ---------------------------------------------------------------------
    % 7 - Carbon transfers to soil pools
    % ---------------------------------------------------------------------
    [fx,s,d]    = ms.cCycle.fun(f,fe,fx,s,d,p,info,tix);               % allocate carbon to vegetation components
                                                                        % litterfall and litter scalars
                                                                        % calculate carbon cycle/decomposition/respiration in soil
	
    % ---------------------------------------------------------------------
    % Gather all variables that are desired and insert them
    % in fx,s,d
    % ---------------------------------------------------------------------
    
    % store current states in previous state variables
    [fx,s,d]	= ms.storeStates.fun(f,fe,fx,s,d,p,info,tix);
    
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
