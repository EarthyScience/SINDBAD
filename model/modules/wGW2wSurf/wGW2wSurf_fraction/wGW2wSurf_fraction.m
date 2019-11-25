function [f,fe,fx,s,d,p] = wGW2wSurf_fraction(f,fe,fx,s,d,p,info,tix)
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


fx.wGW2wSurf(:,tix)     =   p.wGW2wSurf.kGW2Surf .* (s.w.wGW - s.w.wSurf);

% update water pools
s.w.wGW                 =   s.w.wGW - fx.wGW2wSurf(:,tix);
s.w.wSurf               =   s.w.wSurf + fx.wGW2wSurf(:,tix);

end
