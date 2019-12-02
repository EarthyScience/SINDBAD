function [f,fe,fx,s,d,p] = prec_roBase_Orth2013(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the delay coefficient of first 60 days as a precomputation
%
% Inputs:
%   -   p.roBase.qt : delay parameter [time]
% 
% Outputs:
%   -   fe.roBase.Rdelay
%
% Modifies:
%
% References:
%   -   Orth, R., Koster, R. D., & Seneviratne, S. I. (2013). 
%       Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14(6), 1773-1790.
%
% Created by:
%   -   Tina Trautmann (ttraut)
%
% Versions:
%   -   1.0 on 18.11.2019 (ttraut)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> calculate delay function of previous days
z                  =    exp(-(info.tem.helpers.arrays.onespix * (0:60) ./ (p.roBase.qt * ones(1,61)))) - exp(((info.tem.helpers.arrays.onespix * (0:60)+1) ./ (p.roBase.qt * ones(1,61)))); 
fe.roBase.Rdelay   =    z./(sum(z,2) * ones(1,61));

end