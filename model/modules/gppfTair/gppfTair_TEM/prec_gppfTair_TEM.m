function [f,fe,fx,s,d,p] = prec_gppfTair_TEM(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the temperature stress for gppPot based on TEM
%
% Inputs:
%   - f.TairDay: daytime temperature [degC]
%   - p.gppfTair.Tmax: temperature above which GPP is zero [degC]
%   - p.gppfTair.Tmin: temperature below which GPP is zero [degC]
%   - p.gppfTair.Topt: optimum temperature for GPP  [degC]
%
% Outputs:
%   - d.gppfTair.TempScGPP: effect of temperature on potential GPP
%
% Modifies:
%   - 
%
% Notes:
%   - Tmin < Topt < Tmax
%
% References:
%   - 
% 
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
tmp             =   info.tem.helpers.arrays.onestix;

pTmin           =   f.TairDay - (p.gppfTair.Tmin .* tmp);
pTmax           =   f.TairDay - (p.gppfTair.Tmax .* tmp);
pTopt           =   p.gppfTair.Topt .* tmp;
pTScGPP         =   pTmin .* pTmax ./ ((pTmin .* pTmax) - (f.TairDay - pTopt) .^ 2);

d.gppfTair.TempScGPP(f.TairDay>p.gppfTair.Tmax)   =     0;
d.gppfTair.TempScGPP(f.TairDay<p.gppfTair.Tmin)   =     0;
d.gppfTair.TempScGPP                              =     min(max(pTScGPP,0),1);
end