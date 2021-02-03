function [f,fe,fx,s,d,p] = prec_roSurf_TWSPaper(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the delay coefficient of first 60 days as a precomputation
% based on Orth et al. 2013 and as it is used in Trautmannet al. 2018
%
% Inputs:
%   -   p.roSurf.qt : delay parameter [time]
% 
% Outputs:
%   -   fe.roSurf.Rdelay
%
% Modifies:
%
% References:
%   -   Orth, R., Koster, R. D., & Seneviratne, S. I. (2013). 
%       Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14(6), 1773-1790.
%   -   used in Trautmann et al. 2018
% Created by:
%   -   Tina Trautmann (ttraut)
%
% Versions:
%   -   1.1 on 21.01.2020 (ttraut) : calculate wSurf based on water balance
%   (1:1 as in TWS Paper)
%   -   1.0 on 18.11.2019 (ttraut)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> calculate delay function of previous days
z                  =    exp(-(info.tem.helpers.arrays.onespix .* (0:60) ./ (p.roSurf.qt .* ones(1,61)))) - exp(((info.tem.helpers.arrays.onespix .* (0:60)+1) ./ (p.roSurf.qt .* ones(1,61))));
fe.roSurf.Rdelay   =    z./(sum(z,2) .* ones(1,61));

end
