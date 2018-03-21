function [fe,fx,d,p] = prec_qCinfex_Jung(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute the runoff from infiltration excess.
% 
% REFERENCES: SINDBAD ;)
% 
% CONTACT	: mjung
% 
% INPUT
% Rain      : rainfall [mm/time]
%           (f.Rain)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% RainInt   : [mm/h]
%           (f.RainInt)
% InfCapacity   : infiltration capacity [mm/hour]
%               (p.psoilR.InfCapacity)
% 
% OUTPUT
% Qinf      : infiltration excess runoff [mm/time] - what runs off because
%           the precipitation intensity is to high for it to inflitrate in
%           the soil.
%           (fx.Qinf)
% 
% NOTES: NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT
% TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!!
% NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT
% TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! 
% 
% #########################################################################

% we assume that infiltration capacity is unlimited in the vegetated
% fraction (infiltration flux = P*fpar) the infiltration flux for the
% unvegetated fraction is given as the minimum of the precip and the min of
% precip intensity (P) and infiltration capacity (I) scaled with rain
% duration (P/R)

% Qinf=P-(P.*fpar+(1-fpar).*min(P,min(I,R).*P./R));
pInfCapacity	= p.psoilR.InfCapacity * ones(1,info.forcing.size(2));

Qinf            =     info.helper.zeros2d;
tmp             =     f.RainInt > 0;
Qinf(tmp)            = f.Rain(tmp) - (f.Rain(tmp) .* f.FAPAR(tmp) + (1 - f.FAPAR(tmp)) .* min(f.Rain(tmp),min(pInfCapacity(tmp),f.RainInt(tmp)) .* f.Rain(tmp) ./ f.RainInt(tmp)));
fx.Qinf =Qinf;
end

