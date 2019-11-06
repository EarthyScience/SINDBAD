function [f,fe,fx,s,d,p] = prec_QTotal_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculate total terrestrial water storage
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% wSoil      : soil water [mm]
%           (s.w.wSoil)
% wSWE      : snowpack [mm]
%           (s.w.wSnow)
% wSurf      : surface water storage [mm]
%           (s.w.wSurf)
%
% OUTPUT
% TWS    : terrestrial water storage [mm]
%           (s.w.wTWS)
%
% NOTES:
%
% #########################################################################
% wSoil1 = squeeze(d.storedStates.wSoil(:,1,:));
% wSoil2 = squeeze(d.storedStates.wSoil(:,2,:));

% qComps=p.Qtotal.components;

% qComps={'Qb','QsurfIndir','QsurfDir'};
%fx.Q = info.tem.helpers.arrays.nanpixtix;
end
