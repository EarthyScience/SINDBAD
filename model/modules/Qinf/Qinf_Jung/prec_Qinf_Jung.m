function [f,fe,fx,s,d,p] = prec_Qinf_Jung(f,fe,fx,s,d,p,info)
% #########################################################################
% compute the runoff from infiltration excess
%
% Inputs:
%	- fe.rainSnow.rain : rainfall [mm/time]
% 	- f.FAPAR:   fraction of absorbed photosynthetically active radiation
%                [] (equivalent to "canopy cover" in Gash and Miralles)
% 	- f.RainInt: rain intensity [mm/h]
%   - p.pSoil.InfCapacity: infiltration capacity [mm/hour]
%
% Outputs:
%   - fx.Qinf: infiltration excess runoff [mm/time] - what runs off because
%           the precipitation intensity is to high for it to inflitrate in
%           the soil
%
% Modifies:
% 	- 
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
%% 
% #########################################################################

% we assume that infiltration capacity is unlimited in the vegetated
% fraction (infiltration flux = P*fpar) the infiltration flux for the
% unvegetated fraction is given as the minimum of the precip and the min of
% precip intensity (P) and infiltration capacity (I) scaled with rain
% duration (P/R)

% Qinf=P-(P.*fpar+(1-fpar).*min(P,min(I,R).*P./R));

pInfCapacity	=   p.pSoil.InfCapacity * info.tem.helpers.arrays.onestix;

Qinf            =   info.tem.helpers.arrays.zerospixtix;

tmp             =   fe.rainSnow.rain > 0;
Qinf(tmp)       =   fe.rainSnow.rain(tmp) - (fe.rainSnow.rain(tmp) .* f.FAPAR(tmp) + (1 - f.FAPAR(tmp)) .* min(fe.rainSnow.rain(tmp),min(pInfCapacity(tmp),f.RainInt(tmp)) .* fe.rainSnow.rain(tmp) ./ f.RainInt(tmp)));
fx.Qinf         =   Qinf;

end

