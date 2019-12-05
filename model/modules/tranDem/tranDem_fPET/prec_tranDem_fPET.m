function [f,fe,fx,s,d,p] = prec_tranDem_fPET(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the climate driven demand for transpiration as a function of PET and alpha
% for vegetation
%
% Inputs:
%   - fe.PET.PET : potential evapotranspiration out of PET module
%   - p.tranDem.alphaVeg: alpha parameter for potential transpiration
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
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
d.tranDem.tranDem                          =   fe.PET.PET .* p.tranDem.alphaVeg;
end