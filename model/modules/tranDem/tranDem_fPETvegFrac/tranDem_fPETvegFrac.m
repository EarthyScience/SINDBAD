function [f,fe,fx,s,d,p] = tranDem_fPETvegFrac(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the climate driven demand for transpiration as a function of PET and alpha
% for vegetation, and vegetation fraction
%
% Inputs:
%   - fe.PET.PET : potential evapotranspiration out of PET module
%   - p.tranDem.alphaVeg: alpha parameter for potential transpiration
%   - s.cd.vegFrac: vegetation fraction
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
%   - Assumes that the transpiration demand scales with vegetated fraction
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
d.tranDem.tranDem(:,tix)                          =   fe.PET.PET(:,tix) .* p.tranDem.alphaVeg .* s.cd.vegFrac;
end
