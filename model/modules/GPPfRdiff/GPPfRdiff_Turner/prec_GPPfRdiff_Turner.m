function [f,fe,fx,s,d,p] = prec_GPPfRdiff_Turner(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : diffuse radiation effect on GPP
% 
% REFERENCES: Turner et al XXXX
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% Rg        : global incoming radiation [MJ/m2/time]
%           (f.Rg)
% 
% RgPot     : potential global incoming radiation [MJ/m2/time]
%           (f.RgPot)
% 
% rue1      : maximum radiation use efficiency for direct radiation 
% 
% rue2
% 
% OUTPUT
% rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
%           (d.GPPfRdiff.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

tmp                             =   info.tem.helpers.arrays.onestix;
prue2                           =   p.GPPfRdiff.rue2 * tmp;
prue1                           =   p.GPPfRdiff.rue1 * tmp;
d.GPPfRdiff.rueGPP              =   prue1;
valid                           =   f.RgPot > 0;
d.GPPfRdiff.rueGPP(valid)       =   (prue2(valid) - prue1(valid)) .* (1 - f.Rg(valid) ...
                                    ./ f.RgPot(valid) ) + prue1(valid);
end