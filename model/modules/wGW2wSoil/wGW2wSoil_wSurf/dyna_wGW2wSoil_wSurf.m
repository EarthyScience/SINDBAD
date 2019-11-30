function [f,fe,fx,s,d,p] = dyna_wGW2wSoil_wSurf(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates a flux between the lowest wSoil layer and wSurf
%   depending on how wet the soil layer is
%   it's a redistribution of wSoil(:,2), doesn't affect the water balance
%
% REFERENCES: 
%
% CONTACT	: ttraut
%
% INPUT
% p.wGW2wSoil.maxFlux       : =10; potential (maximum) flux between the buffer and the soil (lower layer) [mm/day], bounds=[0 20]?
% p.QoverFlow.smax2         : for scaling of p.wGW2wSoil.smaxB
%
% s.w.wSoil         : soil moisture of the layers [mm]
% s.w.wSurf         : surface (GW) water storage [mm]
%
% OUTPUT
% fx.Soil2Surf      : flux from wSoil to wGW / wSurf [mm/time]
% s.w.wSoil         : soil moisture of the layers [mm]
% s.w.wSurf         : surface (GW) water storage [mm]

% NOTES: may need to go to another (new) module
%
% #########################################################################


% saturation of second soil layer
tmp_sat =  s.w.wSoil(:,2) ./ p.QoverFlow.smax2; % the sign of the gradient gives direction of flow: positive=flux to soil; negative=flux to buffer

% scale saturation with maximum flux
potFlux  = tmp_sat .* p.wGW2wSoil.maxFlux; % need to make sure that the flux does not overflow or underflow storages

fx.Soil2Surf(:,tix) = minsb(potFlux, s.w.wSoil(:,2));

% update water pools
s.w.wSoil(:,2)  = s.w.wSoil(:,2) - fx.Soil2Surf(:,tix);
s.w.wSurf       = s.w.wSurf + fx.Soil2Surf(:,tix);


end
