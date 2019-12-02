function [f,fe,fx,s,d,p] = prec_rainInt_forcing(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% stores the time series of rainfall and snowfall from forcing
%
% Inputs: 
%   - fe.rainInt.rainInt
%
% Outputs:
%   - fe.rainInt.rainInt: liquid rainfall from forcing input 
%   threshold
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
fe.rainInt.rainInt     =   f.RainInt;
end

