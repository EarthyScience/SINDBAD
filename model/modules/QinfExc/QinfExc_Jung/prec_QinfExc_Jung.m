function [f,fe,fx,s,d,p] = prec_QinfExc_Jung(f,fe,fx,s,d,p,info)
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

pInfCapacity	=   p.pSoil.InfCapacity * info.tem.helpers.arrays.onestix;

Qinf            =   info.helper.zeros2d;
tmp             =   fe.rainSnow.rain > 0;
Qinf(tmp)       =   fe.rainSnow.rain(tmp) - (fe.rainSnow.rain(tmp) .* f.FAPAR(tmp) + (1 - f.FAPAR(tmp)) .* min(fe.rainSnow.rain(tmp),min(pInfCapacity(tmp),f.RainInt(tmp)) .* fe.rainSnow.rain(tmp) ./ f.RainInt(tmp)));
fx.Qinf         =   Qinf;
end

