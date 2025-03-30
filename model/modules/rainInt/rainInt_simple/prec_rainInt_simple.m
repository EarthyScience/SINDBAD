function [f,fe,fx,s,d,p] = prec_rainInt_simple(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% stores the time series of rainfall intensity
%
% Inputs: 
%   - p.rainInt.rainIntFactor
%   - f.Rain
%
% Outputs:
%   - fe.rainInt.rainInt: Intesity of rainfall during the day 
%
% Modifies:
%   - None
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
fe.rainInt.rainInt        =   f.Rain .* p.rainInt.rainIntFactor;
end

