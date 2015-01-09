function [s, fx, d] = core(f,fe,fx,s,d,p,info);
% CORE - ...
%
% DESCRIPTION:
%
% INPUTS:
%   si	: structure variable with all initial ecosystem states inside
%   f   : forcing variables
%   fe  : pre-computed extra 'forcing'
%   p   : parameter structure
%   
%   si contains the initial state
%
% OUTPUTS:
%   s   : structure variable with all the ecosystem states inside
%   fx	: flux variables
%   d   : diagnostics (where the stressors are also

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


%do precompo
    for i=1:length(info.prcA)
        [fe,fx,d,p]=info.prcA(i).fun(f,fe,fx,s,d,p,info);
    end




% -------------------------------------------------------------------------
% CARBON AND WATER FLUXES ON LAND
% -------------------------------------------------------------------------

% LOOP : loop through the whole length of of the forcing dataset
for i=1:info.forcing.size(2)
 
           
        
    % ---------------------------------------------------------------------
    % 1 - Snow
    % ---------------------------------------------------------------------
    % add snow fall and calculate SnowCoverFraction
    [fx,s,d]=ms.SnowCover.fun(f,fe,fx,s,d,p,info,i);
    
    %calculate sublimation and update swe
    [fx,s,d]=ms.Sublimation.fun(f,fe,fx,s,d,p,info,i);
    
    %calculate snowmelt and update SWE
    [fx,s,d]=ms.SnowMelt.fun(f,fe,fx,s,d,p,info,i);
    
    % ---------------------------------------------------------------------
    % 2 - Water 
    % ---------------------------------------------------------------------
    %interception evaporation
    [fx,s,d]=ms.Interception.fun(f,fe,fx,s,d,p,info,i);
    %this should be precomputed a dummy will just copy from fei to fxi
            
    %infiltration excess runoff
    [fx,s,d]=ms.RunoffInfE.fun(f,fe,fx,s,d,p,info,i);
    
    %saturation runoff
    [fx,s,d]=ms.SaturatedFraction.fun(f,fe,fx,s,d,p,info,i);
    [fx,s,d]=ms.RunoffSat.fun(f,fe,fx,s,d,p,info,i);
    
    %recharge the soil
    [fx,s,d]=ms.RechargeSoil.fun(f,fe,fx,s,d,p,info,i);
    
    %interflow
    [fx,s,d]=ms.RunoffInt.fun(f,fe,fx,s,d,p,info,i);    
    %if e.g. infiltration excess runoff and or saturation runoff are not
    %explicitly modelled then assign a dummy fun that returnes zeros and
    %lumb the FastRunoff into interflow
    
    %recharge the groundwater 
    [fx,s,d]=ms.RechargeGW.fun(f,fe,fx,s,d,p,info,i);
    
    %baseflow
    [fx,s,d]=ms.BaseFlow.fun(f,fe,fx,s,d,p,info,i);
    
    %Groundwater soil moisture interactions (e.g. capilary flux, water
    %table in root zone etc)
    [fx,s,d]=ms.SoilMoistureGW.fun(f,fe,fx,s,d,p,info,i);
    
    %soil evaporation
    [fx,s,d]=ms.SoilEvap.fun(f,fe,fx,s,d,p,info,i);
            
    % ---------------------------------------------------------------------
    % 3 - Transpiration and GPP
    % ---------------------------------------------------------------------
    
    %supply limited Transpiration
    [fx,s,d]=ms.SupplyTransp.fun(f,fe,fx,s,d,p,info,i);
       
    %demand limited GPP (all should be precomputed, i.e. use dummies here that copy stuff from fei to di)
    %compute 'stress' scalars
    [fx,s,d]=ms.LightEffectGPP.fun(f,fe,fx,s,d,p,info,i); 
    [fx,s,d]=ms.RdiffEffectGPP.fun(f,fe,fx,s,d,p,info,i);%effect of diffuse radiation   
    [fx,s,d]=ms.TempEffectGPP.fun(f,fe,fx,s,d,p,info,i);
    [fx,s,d]=ms.VPDEffectGPP.fun(f,fe,fx,s,d,p,info,i);     
    [fx,s,d]=ms.DemandGPP.fun(f,fe,fx,s,d,p,info,i);%combine effects as multiplicative or minimum
    
    [fx,s,d]=ms.SMEffectGPP.fun(f,fe,fx,s,d,p,info,i); %if 'coupled' requires access to iwue param    
    [fx,s,d]=ms.ActualGPP.fun(f,fe,fx,s,d,p,info,i);%combine effects as multiplicative or minimum    
    [fx,s,d]=ms.Transp.fun(f,fe,fx,s,d,p,info,i);%if coupled computed from GPP
    
    %root water uptake (extract water from soil)
    [fx,s,d]=ms.RootUptake.fun(f,fe,fx,s,d,p,info,i);
    
    % ---------------------------------------------------------------------
    % 4 - Allocation of C within plant organs
    % ---------------------------------------------------------------------
    
    % determine growth and maintenance respiration -> NPP
    
    % allocate carbon to vegetation components
    
    % ---------------------------------------------------------------------
    % 5 - Carbon transfers to soil pools
    % ---------------------------------------------------------------------
    
    % litterfall and litter scalars
    
    % calculate carbon cycle/decomposition/respiration in soil
    
    
   
    
    
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