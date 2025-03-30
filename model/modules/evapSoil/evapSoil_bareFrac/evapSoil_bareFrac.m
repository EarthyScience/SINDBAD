function [f,fe,fx,s,d,p] = evapSoil_bareFrac(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the bare soil evaporation from 1-vegFrac of the grid and PETsoil
%
% Inputs:
%   - fe.PET.PET: forcing data set
%   - s.cd.vegFrac (output of vegFrac module)
%   - p.evapSoil.ks
%
% Outputs:
%   - fx.evapSoil
%   - fe.evapSoil.PETSoil
%
% Modifies:
%     - s.w.wSoil(:,1): bare soil evaporation is only allowed from first soil layer
%
% References:
%    - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Martin Jung (mjung@)
%   - Tina Trautmann (ttraut@)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): clean up the code and moved from prec to dyna to handle s.cd.vegFrac
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
%--> scale the potential ET with bare soil fraction
fe.evapSoil.PETsoil(:,tix)      =   fe.PET.PET(:,tix) .* (1-s.cd.vegFrac);

%--> calculate actual ET as a fraction of PETsoil
fx.evapSoil(:,tix)              =   min(fe.evapSoil.PETsoil(:,tix), s.w.wSoil(:,1) .* p.evapSoil.ks);

% update soil moisture of the first layer
s.w.wSoil(:,1)                  =   s.w.wSoil(:,1) - fx.evapSoil(:,tix);
end
