function [fx,s,d] = core_expCodeGen01(f,fe,fx,s,d,p,info);
for i=1:info.forcing.size(2)
d.Temp.WBP  = f.Rain(:,i);
s.wSWE = s.wSWE + f.Snow(:,i);
s.wFrSnow = min(1, s.wSWE ./ p.SnowCover.CoverParam );
fx.Subl(:,i) = min(s.wSWE, fe.Sublimation.PTtermSub(:,i) .* f.Rn(:,i) .* s.wFrSnow );
s.wSWE = s.wSWE - fx.Subl(:,i);
fx.Qsnow(:,i) = min( s.wSWE , fe.SnowMelt.Tterm(:,i) .* s.wFrSnow );
s.wSWE = s.wSWE - fx.Qsnow(:,i);
d.Temp.WBP = d.Temp.WBP + fx.Qsnow(:,i);
d.Temp.WBP = d.Temp.WBP - fx.ECanop(:,i);
X0 = f.PET(:,i) + p.SOIL.tAWC - s.wSM;
Qsat = info.helper.zeros1d;
valids = d.Temp.WBP > 0;
Qsat(valids) = d.Temp.WBP(valids) - d.Temp.WBP(valids) .*(1 + X0(valids) ./d.Temp.WBP(valids) - ( 1 + (X0(valids) ./d.Temp.WBP(valids)).^(1./ p.RunoffSat.alpha(valids) ) ).^ p.RunoffSat.alpha(valids) ); % this is a combination of eq 14 and eq 15 in zhang et al 2008
fx.Qsat(:,i)=Qsat;
d.Temp.WBP = d.Temp.WBP - fx.Qsat(:,i);
for ii=1:length(s.smPools)
ip = min( p.SOIL.AWC(ii).value - s.smPools(ii).value , d.Temp.WBP);
s.smPools(ii).value = s.smPools(ii).value + ip;
d.Temp.WBP = d.Temp.WBP - ip;
s.wSM = s.wSM + ip;
end
fx.Qint(:,i) = p.RunoffInt.rc .* d.Temp.WBP;
d.Temp.WBP = d.Temp.WBP - fx.Qint(:,i);
fx.Qgwrec(:,i) = d.Temp.WBP;
s.wGW = s.wGW + fx.Qgwrec(:,i);
fx.Qb(:,i) = p.BaseFlow.bc .* s.wGW;
s.wGW = s.wGW - fx.Qb(:,i);
fx.ESoil(:,i) = min( fe.SoilEvap.PETsoil(:,i) .* s.smPools(1).value ./ p.SOIL.AWC(1).value , s.smPools(1).value );
s.smPools(1).value = s.smPools(1).value - fx.ESoil(:,i);
s.wSM = s.wSM - fx.ESoil(:,i);
d.SupplyTransp.TranspS(:,i) = p.SupplyTransp.maxRate .* s.wSM  ./ p.SOIL.tAWC;
d.SMEffectGPP.gppS(:,i)   = d.SupplyTransp.TranspS(:,i) .* d.WUE.AoE(:,i);   
ndx                             = d.DemandGPP.gppE(:,i) > 0;
ndxn                            = ~(d.DemandGPP.gppE(:,i) > 0);
d.SMEffectGPP.SMScGPP(ndx,i)    = min( d.SMEffectGPP.gppS(ndx,i) ./ d.DemandGPP.gppE(ndx,i) ,1);
d.SMEffectGPP.SMScGPP(ndxn,i)	= 0;
d.ActualGPP.AllScGPP(:,i)	= d.DemandGPP.AllDemScGPP(:,i) .* d.SMEffectGPP.SMScGPP(:,i);
fx.gpp(:,i) = d.DemandGPP.gppE(:,i) .* d.SMEffectGPP.SMScGPP(:,i);
fx.Transp(:,i)	= fx.gpp(:,i) ./ d.WUE.AoE(:,i);
ET          = fx.Transp(:,i);
ET1         = min(ET,s.wGWR);
s.wGWR = s.wGWR - ET1;
ET=ET-ET1;
for ii=1:length(s.smPools)
ET1         = min(ET,s.smPools(ii).value);
s.smPools(ii).value = s.smPools(ii).value - ET1;
ET=ET-ET1;
s.wSM = s.wSM - ET1;
end
TSPY	= info.timeScale.stepsPerYear;
TSPM	= TSPY ./ 12;
BGRATIO = zeros(info.forcing.size(1),1);
BGME	= zeros(info.forcing.size(1),1);
pBGME	= d.SoilMoistEffectRH.pBGME;
ndx = (f.PET(:,i) > 0);
BGRATIO(ndx)	= (d.Temp.pwSM(ndx,1) ./ TSPM  + f.Rain(ndx,i)) ./ f.PET(ndx,i);
BGRATIO         = BGRATIO .* p.SoilMoistEffectRH.Aws;
ndx1        = ndx & (BGRATIO >= 0 & BGRATIO < 1);
BGME(ndx1)  = 0.1 + (0.9 .* BGRATIO(ndx1));
ndx2        = ndx & (BGRATIO >= 1 & BGRATIO <= 2);
BGME(ndx2)  = 1;
ndx3        = ndx & (BGRATIO > 2 & BGRATIO <= 30);
BGME(ndx3)  = 1 + 1 / 28 - 0.5 / 28 .* BGRATIO(ndx(ndx3));
ndx4        = ndx & (BGRATIO > 30);
BGME(ndx4)	= 0.5;
ndxn        = (f.PET(:,i) <= 0);
BGME(ndxn)	= pBGME(ndxn);
BGME        = max(min(BGME,1),0);
d.SoilMoistEffectRH.BGME(:,i)	= BGME;
d.SoilMoistEffectRH.pBGME       = BGME;
for ii = 1:4
fx.cEfflux(ii).maintenance(:,i)	= fe.AutoResp.km(ii).value(:,i) .* s.cPools(ii).value;
fx.cEfflux(ii).growth(:,i)	= (1 - p.AutoResp.YG) .* (fx.gpp(:,i) .* d.CAllocationVeg.c2pool(ii).value(:,i) - fx.cEfflux(ii).maintenance(:,i));
fx.cEfflux(ii).growth(fx.cEfflux(ii).growth(:,i) < 0, i)	= 0;
end
fx.npp(:,i) = 0;
fx.ra(:,i)  = 0;
for ii = 1:4
fx.cEfflux(ii).value(:,i)	= fx.cEfflux(ii).maintenance(:,i) + fx.cEfflux(ii).growth(:,i);
fx.cNpp(ii).value(:,i)	= fx.gpp(:,i) .* d.CAllocationVeg.c2pool(ii).value(:,i) - fx.cEfflux(ii).value(:,i);
fx.npp(:,i)	= fx.npp(:,i) + fx.cNpp(ii).value(:,i);
fx.ra(:,i)	= fx.ra(:,i) + fx.cEfflux(ii).value(:,i);
end
MTF     = fe.CCycle.MTF;
BGME	= d.SoilMoistEffectRH.BGME(:,i);
for ii = 1:4
s.cPools(ii).value	= s.cPools(ii).value + fx.cNpp(ii).value(:,i);
end
POTcOUT	= zeros(info.forcing.size(1),numel(s.cPools));
for ii = 1:4
POTcOUT(:,ii)  = min(s.cPools(ii).value,s.cPools(ii).value .* fe.CCycle.DecayRate(ii).value(:,i));
s.cPools(ii).value	= s.cPools(ii).value - POTcOUT(:,ii);
end
s.cPools(5).value	= s.cPools(5).value + POTcOUT(:,4) .* MTF;
s.cPools(6).value	= s.cPools(6).value + POTcOUT(:,4) .* (1 - MTF);
s.cPools(9).value	= s.cPools(9).value + POTcOUT(:,3);
s.cPools(7).value   = s.cPools(7).value + POTcOUT(:,1) .* MTF;
s.cPools(8).value   = s.cPools(8).value + POTcOUT(:,1) .* (1 - MTF);
s.cPools(10).value	= s.cPools(10).value + POTcOUT(:,2);
for ii = 5:14
POTcOUT(:,ii)   = min(s.cPools(ii).value, s.cPools(ii).value .* fe.CCycle.kfEnvTs(ii).value(:,i) .* BGME);
fx.cEfflux(ii).value(:,i)	= 0;
end
flux_order  = [9 8 11 2 1 12 4 3 6 5 16 15 7 14 13 10];
for ij = 1:numel(flux_order)
ii                              = flux_order(ij); % this saves, like, 1/3 of the time in the function...
idonor                          = fe.CCycle.ctransfer(ii).donor;
ireceiver                       = fe.CCycle.ctransfer(ii).receiver;
cOUT                            = POTcOUT(:,idonor) .* fe.CCycle.ctransfer(ii).xtrEFF;
s.cPools(idonor).value          = s.cPools(idonor).value    - cOUT;
s.cPools(ireceiver).value       = s.cPools(ireceiver).value + cOUT .* fe.CCycle.ctransfer(ii).effFLUX;
fx.cEfflux(idonor).value(:,i)   = fx.cEfflux(idonor).value(:,i)  + cOUT .* (1 - fe.CCycle.ctransfer(ii).effFLUX);
end
fx.rh(:,i)  = 0;
for ii = 5:14
fx.rh(:,i)	= fx.rh(:,i) + fx.cEfflux(ii).value(:,i);
end
d.Temp.pBGME = d.SoilMoistEffectRH.BGME(:,i);
d.Temp.pwSM = s.wSM;
d.statesOut.wGW(:,i) = s.wGW;
d.statesOut.wGWR(:,i) = s.wGWR;
d.statesOut.wSM(:,i) = s.wSM;
d.statesOut.wSWE(:,i) = s.wSWE;
d.statesOut.cPools(1).value(:,i) = s.cPools(1).value;
d.statesOut.cPools(2).value(:,i) = s.cPools(2).value;
d.statesOut.cPools(3).value(:,i) = s.cPools(3).value;
d.statesOut.cPools(4).value(:,i) = s.cPools(4).value;
d.statesOut.cPools(5).value(:,i) = s.cPools(5).value;
d.statesOut.cPools(6).value(:,i) = s.cPools(6).value;
d.statesOut.cPools(7).value(:,i) = s.cPools(7).value;
d.statesOut.cPools(8).value(:,i) = s.cPools(8).value;
d.statesOut.cPools(9).value(:,i) = s.cPools(9).value;
d.statesOut.cPools(10).value(:,i) = s.cPools(10).value;
d.statesOut.cPools(11).value(:,i) = s.cPools(11).value;
d.statesOut.cPools(12).value(:,i) = s.cPools(12).value;
d.statesOut.cPools(13).value(:,i) = s.cPools(13).value;
d.statesOut.cPools(14).value(:,i) = s.cPools(14).value;
end
end
