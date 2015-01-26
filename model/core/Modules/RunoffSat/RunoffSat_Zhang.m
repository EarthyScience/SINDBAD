function [fx,s,d] = RunoffSat_Zhang(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: compute saturation runoff
% 
% REFERENCES: Zhang et al 2008, Water balance modeling over variable time scales
%based on the Budyko framework – Model
%development and testing, Journal of Hydrology
% 
% CONTACT	: mjung
% 
% INPUT
% PET       : potential evapotranspiration [mm/time]
%           (f.PET)
% AWC12     : maximum plant available water content [mm]
%           (p.SOIL.AWC12)
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% wSM2      : soil moisture of bottom layer [mm]
%           (s.wSM2)
% alpha     : an empirical Budiko parameter []
%           (p.RunoffSat.alpha)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% 
% OUTPUT
% Qsat      : saturation runoff [mm/time]
%           (fx.Qsat)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES: is supposed to work over multiple time scales. it represents the
% 'fast' or 'direct' runoff and thus it's conceptually not really
% consistent with 'saturation runoff'. it basically lumps saturation runoff
% and interflow, i.e. if using this approach for saturation runoff it would
% be consistent to set interflow to none
% 
% #########################################################################

% this is a supply / demand limit concept cf Budyko
% 
% calc demand limit (X0)
X0 = f.PET(:,i) + ( p.SOIL.AWC12 - ( s.wSM1 + s.wSM2 ));

% calc supply limit (d.Temp.WBP) (modified)
%Zhang et al use precipitation as supply limit. we here use precip +snow
%melt - interception - infliltration excess runoff (i.e. the water that
%arrives at the ground) - this is more consistent with the budyko logic
%than just using precip

%catch for division by zero
valids = d.Temp.WBP > 0;

% p.RunoffSat.alpha default ~0.5

fx.Qsat(valids,i) =d.Temp.WBP(valids) - d.Temp.WBP(valids) .*(1 + X0(valids) ./d.Temp.WBP(valids) - ( 1 + (X0(valids) ./d.Temp.WBP(valids)).^(1./ p.RunoffSat.alpha(valids) ) ).^ p.RunoffSat.alpha(valids) ); % this is a combination of eq 14 and eq 15 in zhang et al 2008

d.Temp.WBP = d.Temp.WBP - fx.Qsat(:,i);

end