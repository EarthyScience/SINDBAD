function [f,fe,fx,s,d,p] = dyna_TranfwSoil_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: transpiration from vegetated area
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% PETveg        : potential evapotransration from vegetated area [mm/time]
%                 (fe.TranfwSoil.PETveg)
% wSoil         : soil moisture of different layers [mm]
%                 (s.w.wSoil)
% wTotalSoil    : soil moisture sum of all layers [mm]
%                 (s.w.wTotalSoil)
% RootUp1       : root uptake from upper soil layer [mm/time]
%                 (fx.RootUp1)
% kv            : transpiration availability of vegetation [-]
%                 (p.TranfwSoil.kv)
% k1             : fraction of upper soil layer available for transpiration
%                 (p.TranfwSoil.k1)
% k2             : fraction of lower soil layer available for transpiration
%                 (p.TranfwSoil.k2)
% wTranSup      : transpiration supply from soil water pool (mm)
%                 (d.TranfwSoil.wTranSup)
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
d.TranfwSoil.wTranSup(:,tix) = s.w.wSoil(:,1) .* p.TranfwSoil.k1 + s.w.wSoil(:,2) .* p.TranfwSoil.k2;

fx.Transp(:,tix) = min(fe.TranfwSoil.PETveg(:,tix), d.TranfwSoil.wTranSup(:,tix));

% distribute the transpiration loss among soil layers
%fx.RootUp1(:,tix) = max(0, max(fx.Transp(:,tix) - s.w.wSoil(:,1) .* p.TranfwSoil.k, fx.Transp(:,tix) - s.w.wSoil(:,2)));
fx.RootUp1(:,tix) = max(0, fx.Transp(:,tix) .* ((s.w.wSoil(:,1) .* p.TranfwSoil.k1) ./ d.TranfwSoil.wTranSup(:,tix)));
fx.RootUp2(:,tix) = max(0, fx.Transp(:,tix) .* ((s.w.wSoil(:,2) .* p.TranfwSoil.k2) ./ d.TranfwSoil.wTranSup(:,tix)));

% fx.RootUp2(:,tix) = fx.Transp(:,tix) - fx.RootUp1(:,tix);

% update soil water pools
s.w.wSoil(:,1) = s.w.wSoil(:,1) - fx.RootUp1(:,tix);
s.w.wSoil(:,2) = s.w.wSoil(:,2) - fx.RootUp2(:,tix);

end
