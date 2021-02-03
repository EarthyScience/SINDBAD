function [f,fe,fx,s,d,p] = gppfwSoil_gsi(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the soil moisture stress on gpp based on GSI implementation of LPJ
%
% Inputs:
%   - s.w.wSoil:             values of soil moisture current time step
%   - p.gppfwSoil.fW_base:   base of sigmoid 
%   - p.gppfwSoil.fW_tau: contribution of current time step
%   - p.gppfwSoil.fW_slope: sensiticity of exponent
%   - s.wd.p_wSoilBase_wWP:  wilting point
%
% Outputs:
%   - d.gppfwSoil.SMScGPP:   soil moisture effect on GPP between 0-1
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
%   - 1.1 on 22.01.2021 (skoirala):
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

f_smooth  = @(f_p,f_n,tau,slope,base)(1-tau) .* f_p + tau .* (1/(1+exp(-slope .*(f_n - base))));

f_prev = d.prev.d_gppfwSoil_SMScGPP;


SM      = sum(s.w.wSoil, 2);
WP      = sum(s.wd.p_wSoilBase_wWP, 2);
WFC     = sum(s.wd.p_wSoilBase_wFC, 2);
maxAWC  = max(WFC - WP, 0);
actAWC  = max(SM - WP, 0);
SM_nor	= min(actAWC ./ maxAWC, 1) .* 100;

fW  = f_smooth(f_prev, SM_nor, p.gppfwSoil.fW_tau, p.gppfwSoil.fW_slope, p.gppfwSoil.fW_base);

d.gppfwSoil.SMScGPP(:,tix)	= max(0.0,min(1.0,fW));
% d.gppfwSoil.SM_nor(:,tix)	= SM_nor;
    
end
