function [f,fe,fx,s,d,p] = roInf_Jung(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% compute infiltration excess runoff
%
% Inputs:
%   - fe.rainSnow.rain : rainfall [mm/time]
%   - s.cd.fAPAR: fraction of absorbed photosynthetically active radiation
%                (equivalent to "canopy cover" in Gash and Miralles)
%   - fe.rainInt.rainInt: rain intensity [mm/h]
%   - s.wd.p_wSoilBase_kSat: infiltration capacity [mm/day]
%
% Outputs:
%   - fx.roInf: infiltration excess runoff [mm/time] - what runs off because
%           the precipitation intensity is to high for it to inflitrate in
%           the soil
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%   - 1.1 on 22.11.2019 (skoirala): moved from prec to dyna to handle s.cd.fAPAR which is nPix,1
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
% we assume that infiltration capacity is unlimited in the vegetated
% fraction (infiltration flux = P*fpar) the infiltration flux for the
% unvegetated fraction is given as the minimum of the precip and the min of
% precip intensity (P) and infiltration capacity (I) scaled with rain
% duration (P/R)

%--> get infiltration capacity of the first layer
pInfCapacity    =   s.wd.p_wSoilBase_kSat(:,1) ./ 24; % in mm/hr
roInf           =   info.tem.helpers.arrays.zerospix;
rain            =   fe.rainSnow.rain(:,tix);
rainInt         =   fe.rainInt.rainInt(:,tix);
tmp             =   rain > 0;
roInf(tmp)      =   rain(tmp) - (rain(tmp) .* s.cd.fAPAR(tmp) + (1 - s.cd.fAPAR(tmp)) .*...
                    min(rain(tmp),min(pInfCapacity(tmp),rainInt(tmp)) .* rain(tmp) ./ rainInt(tmp)));
fx.roInf(:,tix) =   roInf;
s.wd.WBP        =   s.wd.WBP - fx.roInf(:,tix);
end