function [f,fe,fx,s,d,p] = prec_wGW2wSoil_Buffer(f,fe,fx,s,d,p,info)
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
% p.QoverFlow.smax2         : for scaling of p.wGW2wSoil.smaxB
%
% OUTPUT
% p.wGW2wSoil.smaxB   : maximum storage capacity of the buffer
% 
% NOTES: may need to go to another (new) module: wBuffer2wSoil; 
%   processes may be partitioned between different modules (wBuffer2wSoil,
%   wSoil2wBuffer, wBuffer2wGW)
%
% #########################################################################

% PREC: storage capacity of buffer
p.wGW2wSoil.smaxB   = p.QoverFlow.smax2 .* p.wGW2wSoil.smaxB_scale .* info.tem.helpers.arrays.onespix;




end
