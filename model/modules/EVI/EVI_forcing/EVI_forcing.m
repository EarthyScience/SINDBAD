function [f,fe,fx,s,d,p]=EVI_forcing(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.EVI from the forcing in every time step
%
% Inputs:
%   - f.EVI read from the forcing data set
%
% Outputs:
%   - s.cd.EVI: the value of EVI for current time step
%
% Modifies:
%   - s.cd.EVI
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.EVI = f.EVI(:,tix);

end