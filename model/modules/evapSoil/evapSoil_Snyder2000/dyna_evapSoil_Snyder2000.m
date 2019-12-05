function [f,fe,fx,s,d,p] = dyna_evapSoil_Snyder2000(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the bare soil evaporation using relative drying rate of soil
%
% Inputs:
%   - fe.PET.PET: 
%   - fe.rainSnow.rain
%   - p.evapSoil.alpha
%   - s.cd.fAPAR
%   - p.evapSoil.beta
% 
% Outputs:
%   - fx.evapSoil
%
% Modifies:
%     - s.w.wSoil(:,1): bare soil evaporation is only allowed from first soil layer
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
%--> get the rain, and PET scaled by alpha and a proxy of vegetation cover
rain                        =   fe.rainSnow.rain(:,tix);
PET                         =   fe.PET.PET(:,tix) .* p.evapSoil.alpha .* (1 - s.cd.fAPAR);
PET(PET<0)                  =   0;

beta2                       =   p.evapSoil.beta .* p.evapSoil.beta;
isdry                       =   s.wd.WBP < PET;     % assume wetting occurs with precip-interception > 
                                                    % pet_soil; Snyder argued one should use precip > 3*pet_soil but then it becomes inconsistent here
sPET                        =   isdry .* (s.wd.p_evapSoil_sPETOld + PET);
issat                       =   sPET > beta2;       % same as sqrt(sPET) > beta (see paper); issat is a flag for stage 2 evap 
                                                    % (name 'issat' not correct here)
ET                          =   isdry.*(~issat .* sPET + issat .* sqrt(sPET) .* p.evapSoil.beta - s.wd.p_evapSoil_sET) + ~isdry .* PET;
%
%--> correct for conditions with light rainfall which were considered not as a
%wetting event; for these conditions we assume soil_evap=minsb(precip-ECanop,pet_soil-evap soil already used)
ET2                         =   minsb(s.wd.WBP, PET-ET);

ETsoil                      =   ET + ET2;
actETsoil                   =   minsb(ETsoil, s.w.wSoil(:,1));
fx.evapSoil(:,tix)          =   actETsoil;

%--> storing the ET and PET of the current time step
s.wd.p_evapSoil_sPETOld     =   sPET;
s.wd.p_evapSoil_sET         =   isdry.*(s.wd.p_evapSoil_sET+ET);

%--> update soil moisture of the first layer
s.w.wSoil(:,1)              =   s.w.wSoil(:,1) - fx.evapSoil(:,tix);
end