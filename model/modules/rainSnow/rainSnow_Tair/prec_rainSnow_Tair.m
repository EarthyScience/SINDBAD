function [f,fe,fx,s,d,p] = prec_rainSnow_Tair(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% stores the time series of rainfall and estimated snowfall from forcing
%
% Inputs: 
%   - f.Rain
%   - f.Tair
%
% Outputs:
%   - fe.rainSnow.rain: liquid rainfall from forcing input 
%   - fe.rainSnow.snow: snowfall estimated as the rain when tair <
%   threshold
%
% Modifies:
%   - f.Rain
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): creation of approach
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
rain                    =   f.Rain;
tair                    =   f.Tair;
snow                    =   info.tem.helpers.arrays.zerospixtix;
tmp                     =   tair < p.rainSnow.Tair_thres;
snow(tmp)               =   rain(tmp);
rain(tmp)               =   0.;
fe.rainSnow.rain        =   rain;
fe.rainSnow.snow        =   snow;
end

