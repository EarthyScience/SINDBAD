function [f,fe,fx,s,d,p] = prec_gppfVPD_MOD17(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the VPD stress on gppPot based on MOD17 model
%
% Inputs:
%   - f. VPDDay: daytime vapor pressure deficit [kPa]
%   - p.gppfVPD.VPDmax: VPD value above which GPP is 0 [kPa]
%   - p.gppfVPD.VPDmin: VPD value below which GPP is maximum [kPa]
%
% Outputs:
%   - d.gppfVPD.VPDScGPP: VPD effect on GPP [] dimensionless, between 0-1
%
% Modifies:
%   - 
%
% References:
%   - MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
%   - Zhao, M., Heinsch, F. A., Nemani, R. R., & Running, S. W. (2005)
%       Improvements of the MODIS terrestrial gross and net primary production 
%       global data set. Remote sensing of Environment, 95(2), 164-176.
%   - Running, S. W., Nemani, R. R., Heinsch, F. A., Zhao, M., Reeves, M., 
%       & Hashimoto, H. (2004). A continuous satellite-derived measure of
%       global terrestrial primary production. Bioscience, 54(6), 547-560.
%
% Notes:
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
tmp                     =   info.tem.helpers.arrays.onestix;
td                      =   (p.gppfVPD.VPDmax - p.gppfVPD.VPDmin) .* tmp;
pVPDmax                 =   p.gppfVPD.VPDmax .* tmp;


vsc                     =   (pVPDmax - f.VPDDay) ./ td;
vsc(vsc<0)              =   0;
vsc(vsc>1)              =   1;

d.gppfVPD.VPDScGPP      =   vsc;
end