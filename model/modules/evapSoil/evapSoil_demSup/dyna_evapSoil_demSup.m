function [f,fe,fx,s,d,p] = dyna_evapSoil_demSup(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the bare soil evaporation from the grid using PET and supply limit
%
% Inputs:
%   - fe.evapSoil.PETsoil: extra forcing from prec
%   - p.evapSoil.supLim
%
% Outputs:
%   - fx.evapSoil
%
% Modifies:
%     - s.w.wSoil(:,1): bare soil evaporation is only allowed from first soil layer
%
% References:
%    - Teuling et al.
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Martin Jung (mjung@)
%   - Tina Trautmann (ttraut@)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): clean up the code
%
% Notes:
%   - considers that the soil evaporation can occur from the whole grid and not only the 
%       non-vegetated fraction of the grid cell
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
%--> calculate the soil evaporation as a fraction of scaling parameter and PET
fx.evapSoil(:,tix)     = min(fe.evapSoil.PETsoil(:,tix), p.evapSoil.supLim .* s.w.wSoil(:,1));
%--> update soil moisture of the first layer
s.w.wSoil(:,1)  = s.w.wSoil(:,1)  - fx.evapSoil(:,tix);
end
