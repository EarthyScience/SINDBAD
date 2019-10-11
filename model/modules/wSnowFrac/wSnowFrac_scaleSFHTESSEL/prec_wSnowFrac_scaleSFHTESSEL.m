function [f,fe,fx,s,d,p] = prec_wSnowFrac_scaleSFHTESSEL(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute the snow fall.
% 
% REFERENCES:
% 
% CONTACT	: ttraut
% 
% INPUT
% Tair 		: air temperature [??C]
% 			(f.Tair)
% Snow 		: unscaled snow fall [mm/time]
%			(f.Snow)
% SF_scale 	: scaling parameter for snow fall []
%           (p.wSnowFrac.SF_scale)
% 
% OUTPUT
% Snow      : snow fall [mm/time]
%           (fe.Snow)
% 
% NOTES: repmat for snow fall
% 
% #########################################################################


% compute snow fall
fe.wSnowFrac.Snow  	 = (p.wSnowFrac.SF_scale .* info.tem.helpers.arrays.onespix) .* f.Snow; % *ones as parameter has one value for each pixel

end
