function [f,fe,fx,s,d,p]= wGW2wSoil_VanDijk2010(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the upward flow of water from groundwater to lowermost soil layer
%
% Inputs:
%	- s.w.wSoil: soil moisture in different layers
%   - p.pSoil.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
%
% Outputs:
%   - fx.gwRec: net groundwater recharge
%   - fx.gwClux: capillary flux
%
% Modifies:
% 	- s.w.wSoil
%   - s.w.wGW 
%   - fx.gwRec
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
%--> index of the last soil layer
wSoilend                =  info.tem.model.variables.states.w.nZix.wSoil;

%--> degree of saturation and unsaturated hydraulic conductivity of the lowermost soil layer

dosSoilend              =  s.w.wSoil(:,wSoilend) ./ s.wd.p_wSoilBase_wSat(:,wSoilend);
% k_unsat                 =  feval(p.pSoil.kUnsatFuncH,s,p,info,wSoilend);    

k_sat                   =  s.wd.p_wSoilBase_kSat(:,wSoilend); %GW is saturated
k_fc                   =  s.wd.p_wSoilBase_kFC(:,wSoilend); %GW is saturated

%--> get the capillary flux
% c_flux                  =  sqrt(k_unsat .* k_sat) .* (1 - dosSoilend);
c_flux                  =  k_fc .* (1 - dosSoilend);
c_flux                  =  min(c_flux,s.w.wGW);

%--> store the net recharge and capillary flux
fx.gwRec(:,tix)        =  fx.gwRec(:,tix) - c_flux ;
fx.gwCflux(:,tix)      =  c_flux;

%--> adjust the storages
s.w.wSoil(:,wSoilend)   =  s.w.wSoil(:,wSoilend)+c_flux;
s.w.wGW                 =  s.w.wGW - c_flux;
end