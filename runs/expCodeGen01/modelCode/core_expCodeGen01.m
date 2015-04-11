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
X0 = f.PET(:,i) + p.SOIL.tAWC - s.wSM;
valids = d.Temp.WBP > 0;
fx.Qsat(valids,i) =d.Temp.WBP(valids) - d.Temp.WBP(valids) .*(1 + X0(valids) ./d.Temp.WBP(valids) - ( 1 + (X0(valids) ./d.Temp.WBP(valids)).^(1./ p.RunoffSat.alpha(valids) ) ).^ p.RunoffSat.alpha(valids) ); % this is a combination of eq 14 and eq 15 in zhang et al 2008
d.Temp.WBP = d.Temp.WBP - fx.Qsat(:,i);
for ii=1:length(s.smPools)
ip = min( p.SOIL.AWC(ii).value - s.smPools(ii).value , d.Temp.WBP);
s.smPools(ii).value = s.smPools(ii).value + ip;
d.Temp.WBP = d.Temp.WBP - ip;
s.wSM = s.wSM + ip;
end
fx.Qgwrec(:,i) = d.Temp.WBP;
s.wGW = s.wGW + fx.Qgwrec(:,i);
fx.Qb(:,i) = p.BaseFlow.bc .* s.wGW;
s.wGW = s.wGW - fx.Qb(:,i);
wAvail                           = (f.Rain(:,i) + fx.Qsnow(:,i));
VMC = (s.wSM + p.SOIL.WPT) ./ p.SOIL.FC;
RDR                             = zeros(info.forcing.size(1),1);
RDR(wAvail(:,1) > f.PET(:,i))   = 1;
ndx                             = (f.Rain(:,i) + fx.Qsnow(:,i)) <= f.PET(:,i);
RDR(ndx)                        = (1 + p.SOIL.Alpha(ndx)) ./ (1 + p.SOIL.Alpha(ndx) .* (VMC(ndx) .^ p.SOIL.Beta(ndx)));
ndx                             = wAvail >= f.PET(:,i);
d.SupplyTransp.TranspS(ndx,i)   = f.PET(ndx,i);
ndx                             = wAvail < f.PET(:,i);
EETa                            = wAvail(ndx,1) + (f.PET(ndx,i) - wAvail(ndx,1)) .* RDR(ndx,1);
EETb                            = wAvail(ndx,1) + (d.Temp.pwSM(ndx,1));
d.SupplyTransp.TranspS(ndx,i)	= min(EETa, EETb);
We      = d.Temp.pSMScGPP;
ndx     = f.Tair(:,i) > 0 & f.PET(:,i) > 0;
We(ndx) = p.SMEffectGPP.Bwe(ndx,1) + d.SMEffectGPP.OmBweOPET(ndx,i) .* d.SupplyTransp.TranspS(ndx,i);
d.SMEffectGPP.SMScGPP(:,i)	= We;
d.ActualGPP.AllScGPP(:,i)	= d.DemandGPP.AllScGPP(:,i) .* d.SMEffectGPP.SMScGPP(:,i);
fx.gpp(:,i) = d.DemandGPP.gppE(:,i) .* d.SMEffectGPP.SMScGPP(:,i);
fx.Transp(:,i)	= d.SupplyTransp.TranspS(:,i);
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
cvars	= info.variables.rememberState;
for ii = 1:length(cvars)
cvar	= char(cvars(ii));
tmp     = splitZstr(cvar,'.');
if strncmp(cvar,'s.',2) || strncmp(cvar,'d.Temp.',7)
eval(['d.Temp.p' char(tmp(end)) ' = ' cvar ';'])
else
eval(['d.Temp.p' char(tmp(end)) ' = ' cvar '(:,i);'])
end
end
cvars = info.variables.saveState;
for ii = 1:length(cvars)
cvar    = char(cvars(ii));
tmp     = splitZstr(cvar,'.');
tmpVN   = char(tmp(end));
if strcmp(tmpVN,'value');
tmpVN   = [char(tmp(end-1)) '.' char(tmp(end))];
end
if strncmp(cvar,'s.',2) && strcmpi(cvar(3),'c') && ~strncmp(cvar,'s.cPools',8)
poolname                    = cvar(3:end);
switch poolname
case 'cVeg'         , poolid	= 1:4;
case 'cLitter'      , poolid	= 1:10;
case 'cSoil'        , poolid	= 11:14;
case 'cLeaf'        , poolid	= 4;
case 'cWood'        , poolid	= 3;            %including sapwood and hardwood.
case 'cRoot'        , poolid	= 1:2;          %including fine and coarse roots.
case 'cMisc'        , poolid	= [];           %e.g., labile, fruits, reserves, etc.
case 'cCwd'         , poolid	= 9;            %Carbon Mass in Coarse Woody Debris
case 'cLitterAbove' , poolid	= 5:6;          %Carbon Mass in Above-Ground Litter
case 'cLitterBelow' , poolid	= [7:8 10];     %Carbon Mass in Below-Ground Litter
case 'cSoilFast'    , poolid	= 11:13;        %fast is meant as lifetime of less than 10 years for  reference climate conditions (20 C, no water limitations).
case 'cSoilMedium'  , poolid	= [];           %medium is meant as lifetime of more than than 10 years and less than 100 years for  reference climate conditions (20 C, no water limitations)
case 'cSoilSlow'    , poolid	= 14;           %fast is meant as lifetime of more than 100 years for  reference climate conditions (20 C, no water limitations)
otherwise
error(['CMIP5cPools : not a known poolname : ' poolname])
end
x	= info.helper.zeros1d;
for ii = poolid
x	= x + s.cPools(ii).value;
end
d.statesOut.(tmpVN)(:,i)    = x;
elseif strncmp(cvar,'s.',2)
eval(['d.statesOut.' tmpVN '(:,i) = ' cvar ';'])
end
end
d.Temp.pSMScGPP = d.SMEffectGPP.SMScGPP(:,i);
end
end
