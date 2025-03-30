function [f,fe,fx,s,d,p]=NIRv_forcing(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.NIRv from the forcing in every time step
%
% Inputs:
%   - f.NIRv read from the forcing data set
%
% Outputs:
%   - s.cd.NIRv: the value of NIRv for current time step
%
% Modifies:
%   - s.cd.NIRv
%
% References:
%   - 
%
% Created by:
%   - Simon Besnard (sbesnard)
%
% Versions:
%   - 1.0 on 29.04.2020 (sbesnard): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.NIRv = f.NIRv(:,tix);

end