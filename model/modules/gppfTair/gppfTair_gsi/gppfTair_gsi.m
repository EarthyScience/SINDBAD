function [f,fe,fx,s,d,p] = prec_gppfTair_Wang2014(f,fe,fx,s,d,p,info, tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the light stress on gpp based on GSI implementation of LPJ
%
% Inputs:
%   - Rg:  shortwave radiation incoming for the current time step
%   - p.gppfTair.fT_c_base:   base of sigmoid 
%   - p.gppfTair.fT_c_tau: contribution of current time step
%   - p.gppfTair.fT_c_slope: sensiticity of exponent
%
% Outputs:
%   - d.gppfTair.TempScGPP:   light effect on GPP between 0-1
%
% Modifies:
%   - 
%
% References:
%    - Forkel, M., Carvalhais, N., Schaphoff, S., v. Bloh, W., Migliavacca, M., 
%       Thurner, M., and Thonicke, K.: Identifying environmental controls on 
%       vegetation greenness phenology through model–data integration, 
%       Biogeosciences, 11, 7025–7050, https://doi.org/10.5194/bg-11-7025-2014,2014.
% 
%
% Notes: 
%   - 
%
% Created by:
%   - Sujan Koirala
%
% Versions:
%   - 1.1 on 22.01.2021 (skoirala:
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

f_smooth  = @(f_p,f_n,tau,slope,base)(1-tau) .* f_p + tau .* (1/(1+exp(-slope .*(f_n - base))));

Tair   =   f.Tair(:,tix);

f_c_prev = d.prev.d_gppfTair_cScGPP;

fT_c  = f_smooth(f_c_prev, Tair, p.gppfTair.fT_c_tau, p.gppfTair.fT_c_slope, p.gppfTair.fT_c_base);

d.gppfTair.cScGPP(:,tix)	= max(0.0,min(1.0,fT_c));


f_h_prev = d.prev.d_gppfTair_hScGPP;

fT_h  = f_smooth(f_h_prev, Tair, p.gppfTair.fT_h_tau, -p.gppfTair.fT_h_slope, p.gppfTair.fT_h_base);

d.gppfTair.hScGPP(:,tix)	= max(0.0,min(1.0,fT_h));

d.gppfTair.TempScGPP(:,tix)    =   min(d.gppfTair.cScGPP(:,tix), d.gppfTair.hScGPP(:,tix));
end