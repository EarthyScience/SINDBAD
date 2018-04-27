function [fx,s,d] = core(si, f, fe, p,info);
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
% slice out the model structure
% -------------------------------------------------------------------------
ms=info.ms;

% -------------------------------------------------------------------------
% Pre-allocate s, fx,d, di, fxi  (could be out-sourced to the TEM and used as an input)
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
% CARBON AND WATER FLUXES ON LAND
% -------------------------------------------------------------------------

% LOOP : loop through the whole length of of the forcing dataset
for i=1:info.forcing.length
    
    
    
    % functions assume that everything which needs to be precomputed is
    % precomputed
    % function handles that need to be executed are collected in
    % 'info.Precompute.handles' (the TEM has to take care of collecting and
    % defining the right ones)
    %%do the neccessary pre-computations here if not already done (if
    %%everything is already precomputed then
    %%length(info.Precompute.handles)=0;
    for prc=1:length(info.Precompute.handles)        
        [fe,fx,d]=info.Precompute.handles(prc).fun(f,fe,fx,s,d,p,info,i);        
    end
    % NOTE: REAL PRECOMPUTATIONS SHOULD BE CALLED BEFORE THE CORE...
    
    % ---------------------------------------------------------------------
    % 1 - Snow
    % ---------------------------------------------------------------------
    % add snow fall and calculate SnowCoverFraction
    [fx,s,d]=ms.SnowCover.handle(f,fe,fx,s,d,p,info,i);
    
    %calculate sublimation and update swe
    [fx,s,d]=ms.Sublimation.handle(f,fe,fx,s,d,p,info,i);
    
    %calculate snowmelt and update SWE
    [fx,s,d]=ms.SnowMelt.handle(f,fe,fx,s,d,p,info,i);
    
    % ---------------------------------------------------------------------
    % 2 - Water 
    % ---------------------------------------------------------------------
    %interception evaporation
    [fx,s,d]=ms.Interception.handle(f,fe,fx,s,d,p,info,i);
    %this should be precomputed a dummy will just copy from fe to fx
            
    %infiltration excess runoff
    [fx,s,d]=ms.RunoffInfE.handle(f,fe,fx,s,d,p,info,i);
    
    %saturation runoff
    [fx,s,d]=ms.SaturatedFraction.handle(f,fe,fx,s,d,p,info,i);
    [fx,s,d]=ms.RunoffSat.handle(f,fe,fx,s,d,p,info,i);
    
    %recharge the soil
    [fx,s,d]=ms.RechargeSoil.handle(f,fe,fx,s,d,p,info,i);
    
    %interflow
    [fx,s,d]=ms.RunoffInt.handle(f,fe,fx,s,d,p,info,i);    
    %if e.g. infiltration excess runoff and or saturation runoff are not
    %explicitly modelled then assign a dummy handle that returnes zeros and
    %lumb the FastRunoff into interflow
    
    %recharge the groundwater 
    [fx,s,d]=ms.RechargeGW.handle(f,fe,fx,s,d,p,info,i);
    
    %baseflow
    [fx,s,d]=ms.BaseFlow.handle(f,fe,fx,s,d,p,info,i);
    
    %Groundwater soil moisture interactions (e.g. capilary flux, water
    %table in root zone etc)
    [fx,s,d]=ms.SoilMoistureGW.handle(f,fe,fx,s,d,p,info,i);
    
    %soil evaporation
    [fx,s,d]=ms.SoilEvap.handle(f,fe,fx,s,d,p,info,i);
            
    % ---------------------------------------------------------------------
    % 3 - Transpiration and GPP
    % ---------------------------------------------------------------------
    
    %supply limited Transpiration
    [fx,s,d]=ms.SupplyTransp.handle(f,fe,fx,s,d,p,info,i);
       
    %demand limited GPP (all should be precomputed, i.e. use dummies here that copy stuff from fe to d)
    %compute 'stress' scalars
    [fx,s,d]=ms.LightEffectGPP.handle(f,fe,fx,s,d,p,info,i); 
    [fx,s,d]=ms.MaxRUE.handle(f,fe,fx,s,d,p,info,i);%effect of diffuse radiation   
    [fx,s,d]=ms.TempEffectGPP.handle(f,fe,fx,s,d,p,info,i);
    [fx,s,d]=ms.VPDEffectGPP.handle(f,fe,fx,s,d,p,info,i);     
    [fx,s,d]=ms.DemandGPP.handle(f,fe,fx,s,d,p,info,i);%combine effects as multiplicative or minimum
    
    [fx,s,d]=ms.SMEffectGPP.handle(f,fe,fx,s,d,p,info,i); %if 'coupled' requires access to iwue param    
    [fx,s,d]=ms.ActualGPP.handle(f,fe,fx,s,d,p,info,i);%combine effects as multiplicative or minimum    
    [fx,s,d]=ms.Transp.handle(f,fe,fx,s,d,p,info,i);%if coupled computed from GPP
    
    %root water uptake (extract water from soil)
    [fx,s,d]=ms.RootUptake.handle(f,fe,fx,s,d,p,info,i);
    
    % ---------------------------------------------------------------------
    % 4 - Allocation of C within plant organs
    % ---------------------------------------------------------------------
    
    % allocation of carbon
    [fx,s,d] = ms.CAllocationVeg.handle(f,fe,fx,s,d,p,info,i);
        
    % determine growth and maintenance respiration -> NPP
    
    % allocate carbon to vegetation components
    
    % ---------------------------------------------------------------------
    % 5 - Carbon transfers to soil pools
    % ---------------------------------------------------------------------
    
    % litterfall and litter scalars
    
    % calculate carbon cycle/decomposition/respiration in soil
    
    
    % ---------------------------------------------------------------------
    % Gather all variables that are desired from fxi,si,di and insert them
    % in fx,s,d
    % ---------------------------------------------------------------------
    
    
    % END LOOP
end
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
