function [f,fe,fx,s,d,p] = evapInt_fAPAR(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes canopy interception evaporation as a fraction of fAPAR
%
% Inputs:
%    - s.cd.fAPAR: fAPAR
%   - p.evapInt.isp
%
% Outputs:
%    - fx.evapInt: interception loss
%
% Modifies:
%     - s.wd.WBP:     water balance pool [mm]
%
% References:
%    - 
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%   - 1.1 on 29.11.2019 (skoirala): s.cd.fAPAR
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> calculate interception loss
intCap                  =   p.evapInt.isp .* s.cd.fAPAR;
fx.evapInt(:,tix)       =   min(intCap, fe.rainSnow.rain(:,tix));

%--> update the available water
s.wd.WBP                =   s.wd.WBP - fx.evapInt(:,tix);
end