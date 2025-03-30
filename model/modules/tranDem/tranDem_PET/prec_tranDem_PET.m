function [f,fe,fx,s,d,p] = prec_tranDem_PET(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% set the climate driven demand for transpiration equal to PET
%
% Inputs:
%   - fe.PET.PET : potential evapotranspiration out of PET module
%
% Outputs:
%   - d.tranDem.tranDem: demand driven transpiration 
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Notes:
%   - Assumes potential transpiration to be equal to PET
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
d.tranDem.tranDem          =  fe.PET.PET;
end