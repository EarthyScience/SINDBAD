function [f,fe,fx,s,d,p] = tranfwSoil_vegFrac(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: transpiration from vegetated area
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% PETveg        : potential evapotransration from vegetated area [mm/time]
%                 (fe.tranfwSoil.PETveg)
% wSoil         : soil moisture of different layers [mm]
%                 (s.w.wSoil)
% wTotalSoil    : soil moisture sum of all layers [mm]
%                 (s.w.wTotalSoil)
% RootUp1       : root uptake from upper soil layer [mm/time]
%                 (fx.RootUp1)
% kv            : transpiration availability of vegetation [-]
%                 (p.tranfwSoil.kv)
% k1             : fraction of upper soil layer available for transpiration
%                 (p.tranfwSoil.k1)
% k2             : fraction of lower soil layer available for transpiration
%                 (p.tranfwSoil.k2)
% wTranSup      : transpiration supply from soil water pool (mm)
%                 (s.wd.TranSup)
%
% OUTPUT
% Transp      : transpiration [mm/time]
%               (fx.Transp)
% wSoil         : soil moisture of different layers [mm]
%                 (s.w.wSoil)
%
% NOTES:
%
% #########################################################################


% scale the potential with the moisture status and take the minimum of what
% is available
PETveg                          =   f.PET(:,tix) .* s.cd.vegFrac .* p.tranfwSoil.alphaVeg;

d.tranfwSoil.TranSup(:,tix)     =   minsb(PETveg,sum(s.wd.p_wSoilBase_wAWC .* s.wd.p_rootFrac_fracRoot2SoilD,2));

% d.tranfwSoil.TranSup(:,tix) = s.w.wSoil(:,1) .* p.tranfwSoil.k1 + s.w.wSoil(:,2) .* p.tranfwSoil.k2;
% % d.tranfwSoil.TranSup(:,tix)
% fx.Transp(:,tix) = minsb(fe.tranfwSoil.PETveg(:,tix), d.tranfwSoil.TranSup(:,tix));

% % distribute the transpiration loss among soil layers
% %fx.RootUp1(:,tix) = maxsb(0, maxsb(fx.Transp(:,tix) - s.w.wSoil(:,1) .* p.tranfwSoil.k, fx.Transp(:,tix) - s.w.wSoil(:,2)));
% fx.RootUp1(:,tix) = maxsb(0, fx.Transp(:,tix) .* ((s.w.wSoil(:,1) .* p.tranfwSoil.k1) ./ d.tranfwSoil.TranSup(:,tix)));
% fx.RootUp2(:,tix) = maxsb(0, fx.Transp(:,tix) .* ((s.w.wSoil(:,2) .* p.tranfwSoil.k2) ./ d.tranfwSoil.TranSup(:,tix)));

% % fx.RootUp2(:,tix) = fx.Transp(:,tix) - fx.RootUp1(:,tix);

% % update soil water pools
% s.w.wSoil(:,1) = s.w.wSoil(:,1) - fx.RootUp1(:,tix);
% s.w.wSoil(:,2) = s.w.wSoil(:,2) - fx.RootUp2(:,tix);

end
