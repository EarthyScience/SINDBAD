function [f,fe,fx,s,d,p] = prec_gppfRdiff_Wang2015(f,fe,fx,s,d,p,info)
% NEEDS TO BE CHANGED TO THE WANG ET AL 2015 IMPLEMENTATION
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the cloudiness scalar (radiation diffusion) on gppPot
%
% Inputs:
%   - f.Rg: Global radiation (SW incoming) [MJ/m2/time]
%   - f.RgPot: Potential radiation [MJ/m2/time]
%   - p.gppfRdiff.rueRatio  : ratio of clear sky LUE to max LUE, 
%       in turner et al., appendix A, e_{g_cs} / e_{g_max}, should be between 0 and 1
%
% Outputs:
%   - d.gppfRdiff.CloudScGPP: effect of cloudiness on potential GPP
%
% Modifies:
%   - 
%
% References:
%   - Turner, D. P., Ritts, W. D., Styles, J. M., Yang, Z., Cohen, W. B., Law, B. E., & Thornton, P. E. (2006). 
%       A diagnostic carbon flux model to monitor the effects of disturbance and interannual variation in 
%       climate on regional NEP. Tellus B: Chemical and Physical Meteorology, 58(5), 476-490. 
%       DOI: 10.1111/j.1600-0889.2006.00221.x
% 
% Created by:
%   - Martin Jung (mjung)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up (changed the output to nPix, nTix)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%% FROM SHANNING
% CI  = cloudiness index 
CI          =   info.tem.helpers.arrays.zerospixtix;
valid       =   f.RgPot > 0;
CI(valid)   =   1 - f.Rg(valid) ./ f.RgPot(valid);

CI_nor      = info.tem.helpers.arrays.onespixtix;

for i = unique(f.Year)
    ndx         = f.Year == i;
    CImin       = nanmin(CI(ndx));         %CImin is the minimum CI value of present year
    CImax       = nanmax(CI(ndx));
    CI_nor(ndx)	= (CI(ndx) - CImin) ./ (CImax - CImin);
end
d.gppfRdiff.CloudScGPP	= 1 - p.gppfRdiff.miu .* (1 - CI_nor);

end