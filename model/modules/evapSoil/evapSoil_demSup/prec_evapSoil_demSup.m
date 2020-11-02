function [f,fe,fx,s,d,p] = prec_evapSoil_demSup(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the bare soil evaporation from demand-supply limited approach
%
% Inputs:
%   - fe.PET.PET: extra forcing from prec
%   - p.evapSoil.alpha: 
% 
% Outputs:
%   - fe.evapSoil.PETSoil
%   
% Modifies:
%   - s.w.wSoil(:,1): bare soil evaporation is only allowed from first soil layer
%
% References:
%   - Teuling et al.
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Martin Jung (mjung@)
%   - Tina Trautmann (ttraut@)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): clean up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%  
% calculate potential soil evaporation 
fe.evapSoil.PETsoil      =     max(0, fe.PET.PET .* (p.evapSoil.alpha .* info.tem.helpers.arrays.onespixtix)); 
end
