function [f,fe,fx,s,d,p] = gppfRdiff_gsi(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the light stress on gpp based on GSI implementation of LPJ
%
% Inputs:
%   - Rg:  shortwave radiation incoming for the current time step
%   - p.gppfRdiff.fR_base:   base of sigmoid 
%   - p.gppfRdiff.fR_tau: contribution of current time step
%   - p.gppfRdiff.fR_slope: sensiticity of exponent
%
% Outputs:
%   - d.gppfRdiff.CloudScGPP:   light effect on GPP between 0-1
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

f_prev = d.prev.d_gppfRdiff_CloudScGPP;

Rg   =   f.Rg(:,tix) .* 11.57407; % multiplied by a scalar to covert MJ/m2/day to W/m2

fR  = f_smooth(f_prev, Rg, p.gppfRdiff.fR_tau, p.gppfRdiff.fR_slope, p.gppfRdiff.fR_base);

d.gppfRdiff.CloudScGPP(:,tix)	= max(0.0,min(1.0,fR));
end