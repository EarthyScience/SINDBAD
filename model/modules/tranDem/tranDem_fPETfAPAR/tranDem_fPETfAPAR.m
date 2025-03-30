function [f,fe,fx,s,d,p] = tranDem_fPETfAPAR(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the climate driven demand for transpiration as a function of PET and fAPAR
%
% Inputs:
%   - fe.PET.PET : potential evapotranspiration out of PET module
%   - p.tranDem.alphaVeg: alpha parameter for potential transpiration
%   - s.cd.fAPAR: fAPAR
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
%   - Simon Besnard, Sujan Koirala, Nuno Carvalhais
%
% Versions:
%   - 1.0 on 30.04.2020 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
d.tranDem.tranDem(:,tix)                          =   fe.PET.PET(:,tix) .*  p.tranDem.alphaVeg .* s.cd.fAPAR;
end
