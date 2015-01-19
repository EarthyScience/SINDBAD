function [fx,s,d] = RunoffSat_Zhang(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: compute saturation runoff
% 
% REFERENCES: Zhang et al ????
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
% NOTES: is supposed to work over multiple time scales
% 
% #########################################################################

% this is a supply / demand limit concept cf Budyko
% it's conceptually not really consistent with 'saturation runoff'
% calc demand limit (X0)
X0 = f.PET(:,i) + ( p.SOIL.AWC12 - ( s.wSM1(:,i) + s.wSM2(:,i) ));

% calc supply limit (P) (modified)
P = d.Temp.WBP;
% p.RunoffSat.alpha default ~0.5

fx.Qsat(:,i) = P - P.*(1+X0./P - ( 1+(X0./P).^(1./ p.RunoffSat.alpha ) ).^ p.RunoffSat.alpha );

d.Temp.WBP = d.Temp.WBP - fx.Qsat(:,i);

end