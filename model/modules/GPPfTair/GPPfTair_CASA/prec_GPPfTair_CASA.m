function [f,fe,fx,s,d,p] = prec_GPPfTair_CASA(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute the temperature scalar used in the CASA model
% 
% REFERENCES: Potter et al 1993, 2003; Carvalhais et al 2008
% 
% CONTACT	: ncarval, mjung
% 
% INPUT
% 
% OUTPUT
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% get air temperature during the day
AIRT    =   f.TairDay;

% make it varying in space
tmp     =   info.tem.helpers.arrays.onestix;

TOPT    =   p.GPPfTair.Topt  * tmp;
A       =   p.GPPfTair.ToptA * tmp;    % original = 0.2
B       =   p.GPPfTair.ToptB * tmp;    % original = 0.3

% CALCULATE T1: account for effects of temperature stress;
% reflects the empirical observation that plants in very
% cold habitats typically have low maximum rates
% T1 = 0.8 + 0.02 .* TOPT - 0.0005 .* TOPT .^ 2;
% this would make sense if TOPT would be the same everywhere.
T1      =   1;
    
% FIRST HALF'S RESPONSE
T2p1    =   1 ./ (1 + exp(A .* (-10))) ./ (1 + exp(A .* (- 10)));
T2C1    =   1 ./ T2p1;
T21     =   T2C1 ./ (1 + exp(A .* (TOPT - 10 - AIRT))) ./ ...
            (1 + exp(A .* (- TOPT - 10 + AIRT)));

% SECOND HALF'S RESPONSE
T2p2    =   1 ./ (1 + exp(B .* (-10))) ./ (1 + exp(B .* (- 10)));
T2C2    =   1 ./ T2p2;
T22     =   T2C2 ./ (1 + exp(B .* (TOPT - 10 - AIRT))) ./ ...
            (1 + exp(B .* (- TOPT - 10 + AIRT)));

% BRING THEM TOGETHER
v       =   AIRT >= TOPT;
T2      =   T21;
T2(v)   =   T22(v);

% SET IT ON d
d.GPPfTair.TempScGPP    =   T2 .* T1;

end