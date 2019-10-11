function [f,fe,fx,s,d,p] = wGW2wSoil_none(f,fe,fx,s,d,p,info,tix)
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
% s.wd.wGWR = info.tem.helpers.arrays.zerospixtix;



end