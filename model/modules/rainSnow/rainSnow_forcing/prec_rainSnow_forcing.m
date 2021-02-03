function [f,fe,fx,s,d,p] = prec_rainSnow_forcing(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% stores the time series of rainfall and snowfall from forcing
%
% Inputs: 
%   - info
%   - f.Rain
%   - f.Snow
%
% Outputs:
%   - fe.rainSnow.rain: liquid rainfall from forcing input 
%   - fe.rainSnow.snow: snowfall estimated as the rain when tair <
%     threshold
%
% Modifies:
%   - f.Snow using the snowfall scaling parameter which can be optimized
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
fe.rainSnow.rain     =   f.Rain;
fe.rainSnow.snow     =   (p.rainSnow.SF_scale .* info.tem.helpers.arrays.onespixtix) .* f.Snow; % ones as parameter has one value for each pixelf.Snow;
end

