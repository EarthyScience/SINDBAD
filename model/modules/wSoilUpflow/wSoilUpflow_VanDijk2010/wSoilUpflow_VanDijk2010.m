function [f,fe,fx,s,d,p]= wSoilUpflow_VanDijk2010(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes the upward water flow in the soil layers
%
% Inputs:
%	- s.w.wSoil: soil moisture in different layers
%   - p.pSoil.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
%
% Outputs:
%   - 
%
% Modifies:
% 	- s.w.wSoil 
%   - s.wd.wSoilFlow: drainage flux between soil layers (from wSoilRec) is adjusted to reflect
%     upward capillary flux
%
% References:
%   - AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model (version 0.5) Technical Description
%   - http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
wSoilend                =   info.tem.model.variables.states.w.nZix.wSoil;
for sl=wSoilend:-1:2   
    %--> calculate the capillary flux
    % k_unsat_lower                 =   feval(p.pSoil.kUnsatFuncH,s,p,info,sl);    
    dosSoilUpper                  =   s.w.wSoil(:,sl-1) ./ s.wd.p_wSoilBase_wSat(:,sl-1);
    % k_unsat_upper                 =   feval(p.pSoil.kUnsatFuncH,s,p,info,sl-1);    
 
    % c_flux                        =   sqrt(k_unsat_lower .* k_unsat_upper) .* (1 - dosSoilUpper);


    % modified by sujan 01.12.2020
    k_fc                            =  s.wd.p_wSoilBase_kFC(:,sl); %GW is saturated
    c_flux                          =  k_fc .* (1 - dosSoilUpper);
   
    c_flux                        =   min(c_flux,s.w.wSoil(:,sl));
    %--> update the soil flow to have a net between drainage and capillary flux
    s.wd.wSoilFlow(:,sl)          =   s.wd.wSoilFlow(:,sl)-c_flux;

    %--> update storages
    s.w.wSoil(:,sl)               =   s.w.wSoil(:,sl)-c_flux;
    s.w.wSoil(:,sl-1)             =   s.w.wSoil(:,sl-1)+c_flux;
end
end
