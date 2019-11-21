function [f,fe,fx,s,d,p]=dyna_wGW2wSoil_VanDijk2010(f,fe,fx,s,d,p,info,tix)
% Usages:
%   [f,fe,fx,s,d,p]=dyna_wGWUpflow_VanDijk(f,fe,fx,s,d,p,info,tix)
%
% Requires:
%   + a list of variables:
%       ++ state variables: info.tem.model.variables.states.input
%   + information on whether or not to combine the pool:
%       ++ info.tem.model.variables.states.input.(sv).combine
% Purposes:
%   + Creates the arrays for the state variables needed to run the model.

% Conventions:
%   + d.storedStates.[VarName]: nPix,nZix,nTix
%
% Created by:
%   + Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% References:
%   + AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model (version 0.5) Technical Description
%   + http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf
% Versions:
%   + 1.0 on 17.04.2018
%   + 1.1 on 21.11.2019: skoirala: replaced p.pSoil with fe.wSoilBase.



% index of the last soil layer
wSoilend                =   info.tem.model.variables.states.w.nZix.wSoil;

% degree of saturation of the lowermost soil layer

dosSoilend              =  s.w.wSoil(:,wSoilend) ./ fe.wSoilBase.wSat(:,wSoilend);

% calculate the reduction in hydraulic conductivity due to soil under
% saturation
k_unsatfrac_soil        =  min((dosSoilend) .^ (2.* fe.wSoilBase.Beta(:,wSoilend) + 3),1);

% unsaturated hydraulic conductivity and GW downward recharge
k_unsat                 =  fe.wSoilBase.kSat(:,wSoilend) .* k_unsatfrac_soil;

k_sat                   =  fe.wSoilBase.kSat(:,wSoilend) ;

c_flux                  =  sqrt(k_unsat .* k_sat) .* (1 - dosSoilend);
% 
% c_flux                  =  max(c_flux,0.);
c_flux                  =  min(c_flux,s.w.wGW);

% c_flux = 0;
fx.Qgwrec(:,tix)        =  fx.QgwDrain(:,tix) - c_flux ;

fx.Qgwcflux(:,tix)      =   c_flux;
% update storages

s.w.wSoil(:,wSoilend)   =   s.w.wSoil(:,wSoilend)+c_flux;

s.w.wGW                 =   s.w.wGW - c_flux;


end % function