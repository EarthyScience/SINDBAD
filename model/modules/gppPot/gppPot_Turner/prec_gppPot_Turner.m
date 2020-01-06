function [f,fe,fx,s,d,p] = prec_gppPot_Turner(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% set the potential GPP as a function of direct and diffused radiation 
%
% Inputs:
%   - p.gppPot.rue1: maximum radiation use efficiency for direct radiation
%   - p.gppPot.rue2: maximum radiation use efficiency for diffused radiation
%   - f.Rg: global incoming radiation [MJ/m2/time]
%   - f.RgPot: potential global incoming radiation [MJ/m2/time]
%
% Outputs:
%   - d.gppPot.rueGPP: potential GPP based on RUE (nPix,nTix)
%
% Modifies:
%   - 
%
% References:
%   - Turner et al. (xx)
%
% Notes:
%   - 
%
% Created by:
%   - Martin Jung (mjung)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up (changed the output to nPix, nTix)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> 
tmp                         =   info.tem.helpers.arrays.onespixtix;
prue2                       =   p.gppPot.rue2 * tmp;
prue1                       =   p.gppPot.rue1 * tmp;
d.gppPot.rueGPP             =   prue1;
valid                       =   f.RgPot > 0;
d.gppPot.rueGPP(valid)      =   (prue2(valid) - prue1(valid)) .* (1 - f.Rg(valid) ./ f.RgPot(valid) ) + prue1(valid);
end