function [f,fe,fx,s,d,p] = prec_gppfTair_Wang2014(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the temperature stress on gppPot based on Wang2014
%
% Inputs:
%   - f.TairDay: daytime temperature [degC]
%   - p.gppfTair.Tmax: minimum temperature for maximum GPP [degC]
%
% Outputs:
%   - d.gppfTair.TempScGPP: effect of temperature on potential GPP
%
% Modifies:
%   - 
%
% References:
%   - Wang, H., Prentice, I. C., & Davis, T. W. (2014). Biophsyical constraints on gross 
%   primary production by the terrestrial biosphere. Biogeosciences, 11(20), 5987.
% 
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
pTmax                   =   p.gppfTair.Tmax .* info.tem.helpers.arrays.onestix;
tsc                     =   f.TairDay ./ pTmax;

tsc(tsc<0)              =   0;
tsc(tsc>1)              =   1;

d.gppfTair.TempScGPP    =   tsc;
end