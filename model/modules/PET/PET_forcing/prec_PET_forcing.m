function [f,fe,fx,s,d,p]=prec_PET_forcing(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of fe.PET.PET from the forcing
%
% Inputs:
%   - f.PET read from the forcing data set
%
% Outputs:
%   - fe.PET.PET: the value of PET for current time step
%
% Modifies:
%   - 
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
fe.PET.PET = f.PET;
end