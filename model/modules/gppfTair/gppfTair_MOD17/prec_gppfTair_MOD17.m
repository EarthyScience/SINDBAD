function [f,fe,fx,s,d,p] = prec_gppfTair_MOD17(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the temperature stress on gppPot based on GPP - MOD17 model
%
% Inputs:
%   - f.TairDay: daytime temperature [degC]
%   - p.gppfTair.Tmin: minimum temperature below which GPP is zero [degC]
%   - p.gppfTair.Tmax: temperature above which GPP is maximum [degC]
%
% Outputs:
%   - d.gppfTair.TempScGPP: effect of temperature on potential GPP
%
% Modifies:
%   - 
%
% References:
%   - MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
%   - Zhao, M., Heinsch, F. A., Nemani, R. R., & Running, S. W. (2005). Improvements 
%   of the MODIS terrestrial gross and net primary production global data set. Remote 
%   sensing of Environment, 95(2), 164-176.
%   - Running, S. W., Nemani, R. R., Heinsch, F. A., Zhao, M., Reeves, M., 
%   & Hashimoto, H. (2004). A continuous satellite-derived measure of global terrestrial 
%   primary production. Bioscience, 54(6), 547-560.
%
% Notes:
%   - Tmin < Tmax ALWAYS!!! 
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
tmp                         =   info.tem.helpers.arrays.onestix;
td                          =   (p.gppfTair.Tmax - p.gppfTair.Tmin) .* tmp;
tmax                        =   p.gppfTair.Tmax .* tmp;
tsc                         =   f.TairDay ./ td + 1 - tmax ./ td;
tsc(tsc<0)                  =   0;
tsc(tsc>1)                  =   1;
d.gppfTair.TempScGPP        =   tsc;
end
