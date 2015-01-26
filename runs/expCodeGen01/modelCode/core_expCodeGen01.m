function [s, fx, d] = core_expCodeGen01(f,fe,fx,s,d,p,info);
for i=1:info.forcing.size(2)
d.Temp.WBP  = f.Rain(:,i);
s.wSWE = s.wSWE + f.Snow(:,i);
s.wFrSnow = double(s.wSWE > 0);
fx.Subl(:,i) = min(s.wSWE, fe.Sublimation.PTtermSub(:,i) .* f.Rn(:,i) .* s.wFrSnow );
s.wSWE = s.wSWE - fx.Subl(:,i);
fx.Qsnow(:,i) = min( s.wSWE , fe.SnowMelt.Tterm(:,i) .* s.wFrSnow );
s.wSWE = s.wSWE - fx.Qsnow(:,i);
d.Temp.WBP = d.Temp.WBP + fx.Qsnow(:,i);
d.Temp.WBP = d.Temp.WBP - fx.ECanop(:,i);
X0 = f.PET(:,i) + ( p.SOIL.AWC12 - ( s.wSM1 + s.wSM2 ));
valids = d.Temp.WBP > 0;
fx.Qsat(valids,i) =d.Temp.WBP(valids) - d.Temp.WBP(valids) .*(1 + X0(valids) ./d.Temp.WBP(valids) - ( 1 + (X0(valids) ./d.Temp.WBP(valids)).^(1./ p.RunoffSat.alpha(valids) ) ).^ p.RunoffSat.alpha(valids) ); % this is a combination of eq 14 and eq 15 in zhang et al 2008
d.Temp.WBP = d.Temp.WBP - fx.Qsat(:,i);
if d.Temp.WBP < 0
hallo=1
end
ip = min( p.SOIL.AWC1 - s.wSM1 , d.Temp.WBP);
s.wSM1 = s.wSM1 + ip;
d.Temp.WBP = d.Temp.WBP - ip;
ip=min( p.SOIL.AWC2 - s.wSM2 , d.Temp.WBP );
s.wSM2 = s.wSM2 + ip;
d.Temp.WBP = d.Temp.WBP - ip;
fx.Qgwrec(:,i) = d.Temp.WBP;
s.wGW = s.wGW + fx.Qgwrec(:,i);
fx.Qb(:,i) = p.BaseFlow.bc .* s.wGW;
s.wGW = s.wGW - fx.Qb(:,i);
fx.ESoil(:,i) = min( fe.SoilEvap.PETsoil(:,i) .* s.wSM1 ./ p.SOIL.AWC1 , s.wSM1 );
s.wSM1 = s.wSM1 - fx.ESoil(:,i);
d.SupplyTransp.TranspS(:,i) = p.SupplyTransp.maxRate .* ( s.wSM1 + s.wSM2 ) ./ ( p.SOIL.AWC12 );
d.SMEffectGPP.gppS(:,i)   = d.SupplyTransp.TranspS(:,i) .* d.WUE.AoE(:,i);   
ndx                             = d.DemandGPP.gppE(:,i) > 0;
ndxn                            = ~(d.DemandGPP.gppE(:,i) > 0);
d.SMEffectGPP.SMScGPP(ndx,i)    = min( d.SMEffectGPP.gppS(ndx,i) ./ d.DemandGPP.gppE(ndx,i) ,1);
d.SMEffectGPP.SMScGPP(ndxn,i)	= 0;
d.ActualGPP.AllScGPP(:,i)	= d.DemandGPP.AllScGPP(:,i) .* d.SMEffectGPP.SMScGPP(:,i);
fx.gpp(:,i) = d.DemandGPP.gppE(:,i) .* d.SMEffectGPP.SMScGPP(:,i);
fx.Transp(:,i)	= fx.gpp(:,i) ./ d.WUE.AoE(:,i);
ET1         = min(fx.Transp(:,i),s.wSM1);
s.wSM1 = s.wSM1 - ET1;
ET          = fx.Transp(:,i) - ET1;
ET1         = min(ET,s.wGWR);
s.wGWR = s.wGWR - ET1;
ET          = ET - ET1;
s.wSM2 = s.wSM2 - ET;
cvars = info.variables.rememberState;
for ii=1:length(cvars)
cvar = char(cvars(ii));
tmp = strsplit(cvar,'.');
if strncmp(cvar,'s.',2)
eval(['d.Temp.p' char(tmp(end)) ' = ' cvar ';'])
else
eval(['d.Temp.p' char(tmp(end)) ' = ' cvar '(:,i);'])
end
end
end
end
