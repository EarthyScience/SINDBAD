function [fe,fx,d,p] = prec_snowOcovfrac_scaleSFHTESSEL(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute the snow fall.
% 
% REFERENCES:
% 
% CONTACT	: ttraut
% 
% INPUT
% Tair 		: air temperature [°C]
% 			(f.Tair)
% Snow 		: unscaled snow fall [mm/time]
%			(f.Snow)
% SF_scale 	: scaling parameter for snow fall []
%           (p.snowOcovfrac.SF_scale)
% 
% OUTPUT
% Snow      : snow fall [mm/time]
%           (fe.Snow)
% 
% NOTES: repmat for snow fall
% 
% #########################################################################


% compute snow fall
fe.Snow  	 = (p.snowOcovfrac.SF_scale * ones(1,info.forcing.size(2))) .* f.Snow; % *ones as parameter has one value for each pixel

end
