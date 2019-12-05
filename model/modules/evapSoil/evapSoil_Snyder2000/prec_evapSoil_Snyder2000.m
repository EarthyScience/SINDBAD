function [f,fe,fx,s,d,p] = prec_evapSoil_Snyder2000(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the bare soil evaporation using relative drying rate of soil
%
% Inputs:
%   - fe.PET.PET 
%   - p.evapSoil.alpha 
%   - s.cd.fAPAR 
% 
% Outputs:
%   - s.wd.p_evapSoil_sPETOld and s.wd.p_evapSoil_sET of first time step
%
% Modifies:
%     - 
%
% References:
%    - Snyder, R. L., Bali, K., Ventura, F., & Gomez-MacPherson, H. (2000). 
%       Estimating evaporation from bare or nearly bare soil. Journal of irrigation and drainage engineering, 126(6), 399-403.
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Martin Jung (mjung@)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): transfer from prec_ to accommodate s.cd.fAPAR
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
%--> set the PET and ET values as precomputation, because they are needed in the first time step and updated every time
PET                         =   fe.PET.PET .* p.evapSoil.alpha .* (1 - s.cd.fAPAR);
PET(PET<0)                  =   0;
s.wd.p_evapSoil_sPETOld     =   PET(:,1);
s.wd.p_evapSoil_sET         =   info.tem.helpers.arrays.zerospix;
end