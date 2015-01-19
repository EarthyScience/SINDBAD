function [fx,s,d] = SoilMoistureGW_none(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: skoirala
% 
% INPUT
% 
% OUTPUT
% 
% NOTES:
% calc capillarly flux and update soil moistures
% we have a pool of water that is shared between the GW and the soil
% moisture, i.e. ground water in the root zone, dependent on the water
% table depth
% 
% #########################################################################

%assume no GW in the root zone
% s.wGWR = zeros(info.forcing.size);



end