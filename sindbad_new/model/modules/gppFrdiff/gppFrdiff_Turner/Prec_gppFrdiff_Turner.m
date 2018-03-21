function [fe,fx,d,p] = prec_gppFrdiff_Turner(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: diffuse radiation effect on GPP
% 
% REFERENCES: Turner et al XXXX
% 
% CONTACT	: mjung, ncarval
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
%           (d.gppFrdiff.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

tmp                             = ones(1,info.forcing.size(2));
prue2                           = p.gppFrdiff.rue2 * tmp;
prue1                           = p.gppFrdiff.rue1 * tmp;
d.gppFrdiff.rueGPP         = prue1;
valid                           = f.RgPot > 0;
d.gppFrdiff.rueGPP(valid)	= (prue2(valid) - prue1(valid)) .* (1 - f.Rg(valid) ./ f.RgPot(valid) ) + prue1(valid);

end