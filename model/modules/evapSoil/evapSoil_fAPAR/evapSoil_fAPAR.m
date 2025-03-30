function [f,fe,fx,s,d,p] = evapSoil_fAPAR(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the bare soil evaporation from 1-fAPAR and PET soil
%
% Inputs:
%   - fe.PET.PET: forcing data set
%   - s.cd.fAPAR (output of fAPAR module)
%   - p.evapSoil.alpha
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
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): clean up the code and moved from prec to dyna to handle s.cd.vegFrac
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
%-->  multiply equilibrium PET with alphaSoil and (1-fAPAR) to get potential soil evap
tmp                             =   fe.PET.PET(:,tix) .* p.evapSoil.alpha .* (1 - s.cd.fAPAR);
tmp(tmp<0)                      =   0;
fe.evapSoil.PETsoil(:,tix)      =   tmp;

%--> scale the potential with the a fraction of available water and get the minimum of the current moisture
fx.evapSoil(:,tix)              =   min(fe.evapSoil.PETsoil(:,tix), p.evapSoil.supLim .* s.w.wSoil(:,1));

%--> update soil moisture of the uppermost soil layer
s.w.wSoil(:,1)                  =   s.w.wSoil(:,1) - fx.evapSoil(:,tix);
end