function [f,fe,fx,s,d,p] = prec_evapSoil_DemSup(f,fe,fx,s,d,p,info)
% calculates the bare soil evaporation from demand-supply limited approach
%
% Inputs:
%	- tix  
%	- fe.PET: extra forcing from prec_
%   - fe.evapSoil.PETSoil
% 
% Outputs:
%   - fx.evapSoil
%
% Modifies:
% 	- s.w.wSoil(:,1): bare soil evaporation is only allowed from first soil layer
%
% References:
%	- Teuling et al.
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%   - Martin Jung (mjung@)
%   - Tina Trautmann (ttraut@)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): clean up the code
%
%% 
% calculate potential evaporation 
fe.evapSoil.PETsoil 	=	max(0, f.PET .* (p.evapSoil.alpha * info.tem.helpers.arrays.onespixtix)); 
end
