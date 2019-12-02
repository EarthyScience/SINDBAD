function [f,fe,fx,s,d,p]=fAPAR_forcing(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.fAPAR from the forcing in every time step
%
% Inputs:
%    - tix  
%    - f.fAPAR read from the forcing data set
%
% Outputs:
%   - s.cd.fAPAR: the value of fAPAR for current time step
%
% Modifies:
%     - s.cd.fAPAR
%
% References:
%    - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 23.11.2019 (skoirala): new approach
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.fAPAR = f.fAPAR(:,tix);
end