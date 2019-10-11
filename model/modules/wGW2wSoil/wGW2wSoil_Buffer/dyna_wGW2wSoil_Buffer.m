function [f,fe,fx,s,d,p] = dyna_wGW2wSoil_Buffer(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates a buffer storage that gives water to the soil when the soil dries up, while the soil gives water to the buffer when the soil is
%   wet but the buffer low; the buffer is only recharged by soil moisture, but
%   the buffer drains to ground water/ wSurf in this case
%   it's a redistribution of wSoil(:,2), doesn't affect the water balance
%
% REFERENCES: Martin 2019 ;)
%
% CONTACT	: ttraut
%
% INPUT
% p.wGW2wSoil.smaxB_scale   : =0.5; scale param to yield storage capacity of the buffer [mm] from smax2, bounds=[0 1]? 
% p.wGW2wSoil.maxFlux       : =10; potential (maximum) flux between the buffer and the soil (lower layer) [mm/day], bounds=[0 20]?
% p.wGW2wSoil.drainB        : =0.5; parameter to estimate the drainage from buffer to groundwater. it scales the baseflow param (k_base) to make sure that drainage to gw is smaller than drainage from gw to q_base, bounds: [0 1]
% p.QoverFlow.smax2         : for scaling of p.wGW2wSoil.smaxB
% p.QsurfIndir.dc           : for scaling of drainage to wGW/wSurf
%
% s.w.wSoil         : soil moisture of the layers [mm]
% s.w.wBuffer       : water content of the buffer [mm]
% s.w.wSurf         : surface (GW) water storage [mm]
%
% OUTPUT
% p.wGW2wSoil.smaxB   : maximum storage capacity of the buffer
% d.wGW2wSoil.potFlux : potentital flux between wSoil and wBuffer, depending on the gradient and p.wGW2wSoil.maxFlux [mm]
%
% fx.Buffer2Soil    : flux between Buffer and Soil [mm/time], positive to soil, negative to buffer
% fx.Buffer2Surf    : flux from Buffer to wGW / wSurf [mm/time]
% s.w.wSoil         : soil moisture of the layers [mm]
% s.w.wBuffer       : water content of the buffer [mm]
% s.w.wSurf         : surface (GW) water storage [mm]

% NOTES: may need to go to another (new) module: wBuffer2wSoil; 
%   processes may be partitioned between different modules (wBuffer2wSoil,
%   wSoil2wBuffer, wBuffer2wGW)
%
% #########################################################################

% % PREC: storage capacity of buffer
% p.wGW2wSoil.smaxB = p.QoverFlow.smax2 .* p.wGW2wSoil.smaxB_scale;

% gradient between buffer and soil
tmp_gradient = s.w.wBuffer ./ p.wGW2wSoil.smaxB - s.w.wSoil(:,2) ./ p.QoverFlow.smax2; % the sign of the gradient gives direction of flow: positive=flux to soil; negative=flux to buffer

% scale gradient with pot flux rate to get pot flux
d.wGW2wSoil.potFlux(:,1) = tmp_gradient .* p.wGW2wSoil.maxFlux; % need to make sure that the flux does not overflow or underflow storages

% adjust the pot flux to what is there
fx.Buffer2Soil(:,tix)  = min(d.wGW2wSoil.potFlux(:,1), min(s.w.wBuffer, p.QoverFlow.smax2 - s.w.wSoil(:,2)));
fx.Buffer2Soil(:,tix)  = max(fx.Buffer2Soil(:,tix), max(-s.w.wSoil(:,2), -(p.wGW2wSoil.smaxB - s.w.wBuffer))); % use here the fx.Buffer2Soil from above! 

% update water pools
s.w.wSoil(:,2)  = s.w.wSoil(:,2) + fx.Buffer2Soil(:,tix);
s.w.wBuffer     = s.w.wBuffer - fx.Buffer2Soil(:,tix);

% drainage to wGW / wSurf
fx.Buffer2Surf(:,tix)  = p.wGW2wSoil.drainB .* p.QsurfIndir.dc .* s.w.wBuffer;
s.w.wBuffer     = s.w.wBuffer - fx.Buffer2Surf(:,tix) ;
s.w.wSurf       = s.w.wSurf + fx.Buffer2Surf(:,tix) ;


end
