function [fx,s,d] = core(f,fe,fx,s,d,p,info);
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
for i = 1:info.forcing.size(2)
    % get states from previous time step
    [fx,s,d]	= ms.GetStates.fun(f,fe,fx,s,d,p,info,i);
    
    % ---------------------------------------------------------------------
    % 0 - VEG - put here any LC changes / phenology / disturbances / ...
    % ---------------------------------------------------------------------
    [fx,s,d]	= ms.VEG.fun(f,fe,fx,s,d,p,info,i);

    % ---------------------------------------------------------------------
    % 1 - Snow
    % ---------------------------------------------------------------------
    [fx,s,d]	= ms.SnowCover.fun(f,fe,fx,s,d,p,info,i);    % add snow fall and calculate SnowCoverFraction
    [fx,s,d]    = ms.Sublimation.fun(f,fe,fx,s,d,p,info,i);  % calculate sublimation and update swe
    [fx,s,d]    = ms.SnowMelt.fun(f,fe,fx,s,d,p,info,i);     % calculate snowmelt and update SWE
    
    % ---------------------------------------------------------------------
    % 2 - Water 
    % ---------------------------------------------------------------------
    [fx,s,d]    = ms.Interception.fun(f,fe,fx,s,d,p,info,i);         % interception evaporation
    [fx,s,d]    = ms.RunoffInfE.fun(f,fe,fx,s,d,p,info,i);           % infiltration excess runoff
    [fx,s,d]    = ms.SaturatedFraction.fun(f,fe,fx,s,d,p,info,i);    % saturation runoff
    [fx,s,d]    = ms.RunoffSat.fun(f,fe,fx,s,d,p,info,i);            % saturation runoff
    [fx,s,d]    = ms.RechargeSoil.fun(f,fe,fx,s,d,p,info,i);         % recharge the soil
    [fx,s,d]    = ms.RunoffInt.fun(f,fe,fx,s,d,p,info,i);            % interflow
                                                                        % if e.g. infiltration excess runoff and or saturation runoff are not
                                                                        % explicitly modelled then assign a dummy handle that returnes zeros and
                                                                        % lumb the FastRunoff into interflow
    [fx,s,d]    = ms.RechargeGW.fun(f,fe,fx,s,d,p,info,i);           % recharge the groundwater 
    [fx,s,d]    = ms.BaseFlow.fun(f,fe,fx,s,d,p,info,i);             % baseflow
    [fx,s,d]    = ms.SoilMoistureGW.fun(f,fe,fx,s,d,p,info,i);       % Groundwater soil moisture interactions (e.g. capilary flux, water
                                                                        % table in root zone etc)
    [fx,s,d]    = ms.SoilEvap.fun(f,fe,fx,s,d,p,info,i);             % soil evaporation
            
    % ---------------------------------------------------------------------
    % 3 - Transpiration and GPP
    % ---------------------------------------------------------------------
	[fx,s,d]    = ms.WUE.fun(f,fe,fx,s,d,p,info,i);              % estimate WUE
    [fx,s,d]    = ms.SupplyTransp.fun(f,fe,fx,s,d,p,info,i);     % supply limited Transpiration
    [fx,s,d]    = ms.LightEffectGPP.fun(f,fe,fx,s,d,p,info,i);   % compute 'stress' scalars
    [fx,s,d]    = ms.RdiffEffectGPP.fun(f,fe,fx,s,d,p,info,i);   % effect of diffuse radiation   
    [fx,s,d]    = ms.TempEffectGPP.fun(f,fe,fx,s,d,p,info,i);    % effect of temperature
    [fx,s,d]    = ms.VPDEffectGPP.fun(f,fe,fx,s,d,p,info,i);     % VPD effect
    [fx,s,d]    = ms.DemandGPP.fun(f,fe,fx,s,d,p,info,i);        % combine effects as multiplicative or minimum
    [fx,s,d]    = ms.SMEffectGPP.fun(f,fe,fx,s,d,p,info,i);      % if 'coupled' requires access to iwue param    
    [fx,s,d]    = ms.ActualGPP.fun(f,fe,fx,s,d,p,info,i);        % combine effects as multiplicative or minimum    
    [fx,s,d]    = ms.Transp.fun(f,fe,fx,s,d,p,info,i);           % if coupled computed from GPP
    [fx,s,d]    = ms.RootUptake.fun(f,fe,fx,s,d,p,info,i);       % root water uptake (extract water from soil)
    
    % ---------------------------------------------------------------------
    % 4 - Climate effects on metabolic processes
    % ---------------------------------------------------------------------
    [fx,s,d]    = ms.SoilMoistEffectRH.fun(f,fe,fx,s,d,p,info,i);    % effect of soil moisture on decomposition
    [fx,s,d]    = ms.TempEffectRH.fun(f,fe,fx,s,d,p,info,i);         % effect of temperature on decomposition
    [fx,s,d]    = ms.TempEffectAutoResp.fun(f,fe,fx,s,d,p,info,i);   % temperature effect on autotrophic maintenance respiration

    % ---------------------------------------------------------------------
    % 5 - Allocation of C within plant organs
    % ---------------------------------------------------------------------
    [fx,s,d]	= ms.CAllocationVeg.fun(f,fe,fx,s,d,p,info,i);       % carbon allocation factors
    
    % ---------------------------------------------------------------------
    % 6 - Autotrophic respiration
    % ---------------------------------------------------------------------
    [fx,s,d]    = ms.AutoResp.fun(f,fe,fx,s,d,p,info,i);             % determine growth and maintenance respiration -> NPP
    
    % ---------------------------------------------------------------------
    % 7 - Carbon transfers to soil pools
    % ---------------------------------------------------------------------
    [fx,s,d]    = ms.CCycle.fun(f,fe,fx,s,d,p,info,i);               % allocate carbon to vegetation components
                                                                        % litterfall and litter scalars
                                                                        % calculate carbon cycle/decomposition/respiration in soil
	
    % ---------------------------------------------------------------------
    % Gather all variables that are desired and insert them
    % in fx,s,d
    % ---------------------------------------------------------------------
    
    % store current states in previous state variables
    [fx,s,d]	= ms.PutStates.fun(f,fe,fx,s,d,p,info,i);
    
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
