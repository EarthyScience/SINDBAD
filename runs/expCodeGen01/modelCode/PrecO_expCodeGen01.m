function [fe,fx,d,p]=PrecO_expCodeGen01(f,fe,fx,s,d,p,info);
N     = numel(p.SOIL.HeightLayer);
tSLDP = zeros(info.forcing.size(1),1);
for ij = 1:N
tSLDP	= tSLDP + p.SOIL.HeightLayer(ij).value;
end
for ij = 1:N
p.SOIL.AWC(ij).value    = p.SOIL.tAWC .* p.SOIL.HeightLayer(ij).value ./ tSLDP ;
end
T = f.TairDay + 273.15;
Delta = (5723.265./T.^2 + 3.53068./(T-0.00728332)).* exp(9.550426-5723.265./T + 3.53068.*log(T) - 0.00728332.*T);
Delta = Delta.*0.001;
Lambda = 46782.5 + 35.8925.*T - 0.07414.*T.^2 + 541.5 * exp(-(T./123.75).^2);
Lambda=Lambda.*0.000001./(18.01528.*0.001);
pa = 0.001; %MJ/kg/K
Gamma = f.PsurfDay .* pa./(0.622.*Lambda);
palpha                      = p.Sublimation.alpha * ones(1,info.forcing.size(2));
tmp                         = palpha .* (Delta ./ (Delta + Gamma)) ./ Lambda;
tmp(tmp<0)                  = 0;
fe.Sublimation.PTtermSub    = tmp;
pRate               = (p.SnowMelt.Rate .* info.timeScale.timeStep) * ones(1,info.forcing.size(2));
fe.SnowMelt.Tterm	= max(pRate .* f.Tair,0);
tmp             = ones(1,info.forcing.size(2));
CanopyStorage   = p.Interception.CanopyStorage  * tmp;
fte             = p.Interception.fte            * tmp; 
EvapRate        = p.Interception.EvapRate       * tmp;
St              = p.Interception.St             * tmp;
pd              = p.Interception.pd             * tmp;
valids = f.RainInt > 0 & f.FAPAR > 0;
Pgc = zeros(info.forcing.size);
Pgt = zeros(info.forcing.size);
Ic = zeros(info.forcing.size);
Ic1 = zeros(info.forcing.size);
Ic2 = zeros(info.forcing.size);
It2 = zeros(info.forcing.size);
It = zeros(info.forcing.size);
v=f.RainInt < EvapRate & valids==1;
EvapRate(v)=f.RainInt(v);
Pgc(valids)=-1.*( f.RainInt(valids) .* CanopyStorage(valids) ./ ((1- fte(valids) ) .* EvapRate(valids) )).*log(1-((1- fte(valids) ) .* EvapRate(valids) ./ f.RainInt(valids) ));
Pgt(valids)=Pgc(valids) + f.RainInt(valids) .* St(valids) ./ ( pd(valids) .* f.FAPAR(valids) .* ( f.RainInt(valids) - EvapRate(valids) .* (1 - fte(valids) )));
Ic1(valids) = f.FAPAR(valids) .* f.Rain(valids); %Pg < Pgc
Ic2(valids) = f.FAPAR(valids) .* (Pgc(valids)+((1- fte(valids) ) .* EvapRate(valids) ./ f.RainInt(valids) ) .* ( f.Rain(valids) - Pgc(valids))); %Pg > Pgc
v= f.Rain <= Pgc & valids==1;
Ic(v)=Ic1(v);
Ic(v==0)=Ic2(v==0);
It2(valids) = pd(valids) .* f.FAPAR(valids) .* (1-(1 - fte(valids) ) .* EvapRate(valids) ./ f.RainInt(valids) ).*( f.Rain(valids) - Pgc(valids));%Pg > Pgt
v= f.Rain <= Pgt;
It(v) = St(v);
It(v==0)=It2(v==0);
tmp = Ic+It;
tmp(f.Rain == 0) = 0;
v=tmp > f.Rain;
tmp(v) = f.Rain(v);
fx.ECanop = tmp;
fx.Qinf = info.helper.zeros2d;
palpha              = p.SoilEvap.alpha * ones(1,info.forcing.size(2));
tmp                 = f.PET .* palpha .* (1 - f.FAPAR);
tmp(tmp<0)          = 0;
fe.SoilEvap.PETsoil = tmp;
VPDDay                  = f.VPDDay;
VPDDay(f.VPDDay < 1E-4) = 1E-4;
pg1                     = p.WUE.g1 * ones(1,info.forcing.size(2));
d.WUE.AoE               = 6.6667e-004 .* f.ca .* f.PsurfDay ./ (1.6 .* (VPDDay + pg1 .* sqrt(VPDDay)));
d.WUE.ci	= f.ca .* pg1 ./ (pg1 + sqrt(VPDDay));
pgamma                      = p.LightEffectGPP.gamma * ones(1,info.forcing.size(2));
d.LightEffectGPP.LightScGPP = 1 ./ (pgamma .* f.PAR .* f.FAPAR + 1);
tmp                     = ones(1,info.forcing.size(2));
prue2                   = p.MaxRUE.rue2 * tmp;
prue1                   = p.MaxRUE.rue1 * tmp;
d.MaxRUE.rueGPP         = prue1;
valid                   = f.RgPot > 0;
d.MaxRUE.rueGPP(valid)	= (prue2(valid) - prue1(valid)) .* (1 - f.Rg(valid) ./ f.RgPot(valid) ) + prue1(valid);
AIRT    = f.TairDay;
tmp     = ones(1,info.forcing.size(2));
TOPT    = p.TempEffectGPP.Topt  * tmp;
A       = p.TempEffectGPP.ToptA * tmp;    % original = 0.2
B       = p.TempEffectGPP.ToptB * tmp;    % original = 0.3
T1	= 1;
T2p1    = 1 ./ (1 + exp(A .* (-10))) ./ (1 + exp(A .* (- 10)));
T2C1    = 1 ./ T2p1;
T21     = T2C1 ./ (1 + exp(A .* (TOPT - 10 - AIRT))) ./ ...
(1 + exp(A .* (- TOPT - 10 + AIRT)));
T2p2     = 1 ./ (1 + exp(B .* (-10))) ./ (1 + exp(B .* (- 10)));
T2C2     = 1 ./ T2p2;
T22      = T2C2 ./ (1 + exp(B .* (TOPT - 10 - AIRT))) ./ ...
(1 + exp(B .* (- TOPT - 10 + AIRT)));
v       = AIRT >= TOPT;
T2      = T21;
T2(v)   = T22(v);
d.TempEffectGPP.TempScGPP = T2 .* T1;
Tparam          = 0.0512;   % very ecophysiologically based parameters, 
CompPointRef    = 42.75;    % avoid optimize
CO2CompPoint    = CompPointRef .* exp(Tparam .* (f.TairDay - 25));
d.VPDEffectGPP.VPDScGPP = (d.WUE.ci - CO2CompPoint) ./ (d.WUE.ci + 2 .* CO2CompPoint);
scall           = zeros(info.forcing.size(1),info.forcing.size(2),3);
scall(:,:,1)    = d.TempEffectGPP.TempScGPP;
scall(:,:,2)    = d.VPDEffectGPP.VPDScGPP;
scall(:,:,3)    = d.LightEffectGPP.LightScGPP;
d.DemandGPP.AllDemScGPP    = prod(scall,3);
d.DemandGPP.gppE        = f.FAPAR .* f.PAR .* d.MaxRUE.rueGPP .* d.DemandGPP.AllDemScGPP;
TsM     = 1;
fe.TempEffectRH.fT	= p.TempEffectRH.Q10 .^ ((f.Tair - p.TempEffectRH.Tref) ./ 10) .* TsM; 
d.TempEffectAutoResp.fT(1).value	= p.TempEffectAutoResp.Q10_RM .^ ((f.Tsoil - p.TempEffectAutoResp.Tref_RM) ./ 10);
d.TempEffectAutoResp.fT(2).value	= p.TempEffectAutoResp.Q10_RM .^ ((f.Tsoil - p.TempEffectAutoResp.Tref_RM) ./ 10);
d.TempEffectAutoResp.fT(3).value	= p.TempEffectAutoResp.Q10_RM .^ ((f.Tair - p.TempEffectAutoResp.Tref_RM) ./ 10);
d.TempEffectAutoResp.fT(4).value	= p.TempEffectAutoResp.Q10_RM .^ ((f.Tair - p.TempEffectAutoResp.Tref_RM) ./ 10);
ro      = p.CAllocationVeg.ro;
kext	= p.CAllocationVeg.kext;
minL    = p.CAllocationVeg.minL;
maxL    = p.CAllocationVeg.maxL;
minL_fT = p.CAllocationVeg.minL_fT;
maxL_fT = p.CAllocationVeg.maxL_fT;
RelY    = p.CAllocationVeg.RelY;
LL                      = exp (-kext .* f.LAI); 
for t=1:size(LL,2)
LL(LL(:,t) <= minL,t)          = minL(LL(:,t) <= minL);
LL(LL(:,t) >= maxL,t)          = maxL(LL(:,t) >= maxL);
end
d.CAllocationVeg.LL	= LL;
NL_fT                   = fe.TempEffectRH.fT;
for t=1:size(LL,2)
NL_fT(NL_fT(:,t) >= maxL_fT,t)	= maxL_fT(NL_fT(:,t) >= maxL_fT);
NL_fT(NL_fT(:,t) <= minL_fT,t) = minL_fT(NL_fT(:,t) <= minL_fT);
end
d.CAllocationVeg.NL_fT	= NL_fT;
NL                      = minL.*ones(size(f.PET));
d.CAllocationVeg.NL	= NL;
d.CAllocationVeg.RootNumerator	= ro .* (RelY + 1) .* LL;
d.CAllocationVeg.WLDenominator	= p.SOIL.tAWC;
RMN     = p.AutoResp.RMN ./ info.timeScale.stepsPerDay;
for ii = 1:4 % for all the vegetation pools
fe.AutoResp.km(ii).value	= 1 ./ p.AutoResp.C2N(ii).value .* RMN .* d.TempEffectAutoResp.fT(ii).value;
fe.AutoResp.km4su(ii).value	= fe.AutoResp.km(ii).value .* p.AutoResp.YG;
end
TSPY        = info.timeScale.stepsPerYear;
poolname	= {
'ROOT', 'ROOTC', 'WOOD', 'LEAF',                            ... VEGETATION
'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', ... LITTER
'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};                     %   MICROBIAL AND SLOWER SOIL
for ii = 5:numel(poolname)
annk                           = p.CCycle.(['annk' poolname{ii}]);
fe.CCycle.annkpool(ii).value   = annk;
fe.CCycle.kpool(ii).value      = 1 - (exp(-annk) .^ (1 / TSPY));
end
for ii = 1:4
AGE                            = p.CCycle.([poolname{ii} '_AGE']);
annk                           = 1e-40 .* ones(size(AGE));
annk(AGE > 0)                  = 1 ./ AGE(AGE > 0);
fe.CCycle.annkpool(ii).value   = annk;
fe.CCycle.kpool(ii).value      = 1 - (exp(-annk) .^ (1 / TSPY));
end
LITC2N              = p.CCycle.LITC2N;
LIGNIN              = p.CCycle.LIGNIN;
MTFA                = p.CCycle.MTFA;
MTFB                = p.CCycle.MTFB;
LIGEFFA             = p.CCycle.LIGEFFA;
effA                = p.CCycle.effA;
effB                = p.CCycle.effB;
CLAY                = p.SOIL.CLAY;
SILT                = p.SOIL.SILT;
WOODLIGFRAC         = p.CCycle.WOODLIGFRAC;
C2LIGNIN            = p.CCycle.C2LIGNIN;
effCLAYSOIL_MICA	= p.CCycle.effCLAYSOIL_MICA;
effCLAYSOIL_MICB	= p.CCycle.effCLAYSOIL_MICB;
effCLAYSLOWA        = p.CCycle.effCLAYSLOWA;
effCLAYSLOWB        = p.CCycle.effCLAYSLOWB;
NONSOL2SOLLIGNIN	= p.CCycle.NONSOL2SOLLIGNIN;
TEXTEFFA            = p.CCycle.TEXTEFFA;
L2N     = (LITC2N .* LIGNIN) .* NONSOL2SOLLIGNIN;
MTF             = MTFA - (MTFB .* L2N);
MTF(MTF < 0)    = 0;
SCLIGNIN    = (LIGNIN .* C2LIGNIN .* NONSOL2SOLLIGNIN) ./ (1 - MTF);
fe.CCycle.LIGEFF      = exp(-LIGEFFA .* SCLIGNIN);
p.CCycle.effSOIL_MIC2SLOW    = effA - (effB .* (SILT + CLAY));
p.CCycle.effSOIL_MIC2OLD     = effA - (effB .* (SILT + CLAY)); 
ctransfer(1).donor    = 6;  ctransfer(1).receiver   = 13;	ctransfer(1).effFLUX    = p.CCycle.effS_LEAF2SLOW;      ctransfer(1).xtrEFF     = SCLIGNIN;
ctransfer(2).donor    = 6;  ctransfer(2).receiver   = 11;   ctransfer(2).effFLUX    = p.CCycle.effS_LEAF2LEAF_MIC;	ctransfer(2).xtrEFF     = 1 - SCLIGNIN;
ctransfer(3).donor    = 8;  ctransfer(3).receiver   = 13;   ctransfer(3).effFLUX    = p.CCycle.effS_ROOT2SLOW;      ctransfer(3).xtrEFF     = SCLIGNIN;
ctransfer(4).donor    = 8;  ctransfer(4).receiver   = 12;   ctransfer(4).effFLUX    = p.CCycle.effS_ROOT2SOIL_MIC;  ctransfer(4).xtrEFF     = 1 - SCLIGNIN;
ctransfer(5).donor    = 9;  ctransfer(5).receiver   = 13;   ctransfer(5).effFLUX    = p.CCycle.effLiWOOD2SLOW;      ctransfer(5).xtrEFF     = WOODLIGFRAC;
ctransfer(6).donor    = 9;  ctransfer(6).receiver   = 11;   ctransfer(6).effFLUX    = p.CCycle.effLiWOOD2LEAF_MIC;  ctransfer(6).xtrEFF     = 1 - WOODLIGFRAC;
ctransfer(7).donor    = 11; ctransfer(7).receiver   = 13;	ctransfer(7).effFLUX    = p.CCycle.effLEAF_MIC2SLOW;    ctransfer(7).xtrEFF     = 1;
ctransfer(8).donor    = 13;	ctransfer(8).receiver   = 12;   ctransfer(8).effFLUX    = p.CCycle.effSLOW2SOIL_MIC;    ctransfer(8).xtrEFF     = 1 - (effCLAYSLOWA + (effCLAYSLOWB .* CLAY));
ctransfer(9).donor    = 13;	ctransfer(9).receiver   = 14;   ctransfer(9).effFLUX    = p.CCycle.effSLOW2OLD;         ctransfer(9).xtrEFF     = effCLAYSLOWA + (effCLAYSLOWB .* CLAY);
ctransfer(10).donor   = 14;	ctransfer(10).receiver  = 12;   ctransfer(10).effFLUX   = p.CCycle.effOLD2SOIL_MIC;     ctransfer(10).xtrEFF    = 1;
ctransfer(11).donor   = 5;  ctransfer(11).receiver  = 11;   ctransfer(11).effFLUX   = p.CCycle.effM_LEAF2LEAF_MIC;  ctransfer(11).xtrEFF    = 1;
ctransfer(12).donor   = 7;  ctransfer(12).receiver  = 12;   ctransfer(12).effFLUX   = p.CCycle.effM_ROOT2SOIL_MIC;  ctransfer(12).xtrEFF    = 1;
ctransfer(13).donor   = 12;	ctransfer(13).receiver  = 13;   ctransfer(13).effFLUX   = p.CCycle.effSOIL_MIC2SLOW;    ctransfer(13).xtrEFF    = 1 - (effCLAYSOIL_MICA + (effCLAYSOIL_MICB .* CLAY));
ctransfer(14).donor   = 12;	ctransfer(14).receiver  = 14;   ctransfer(14).effFLUX   = p.CCycle.effSOIL_MIC2OLD;     ctransfer(14).xtrEFF    = effCLAYSOIL_MICA + (effCLAYSOIL_MICB .* CLAY);
ctransfer(15).donor   = 10;	ctransfer(15).receiver  = 13;   ctransfer(15).effFLUX   = p.CCycle.effLiROOT2SLOW;      ctransfer(15).xtrEFF    = WOODLIGFRAC;
ctransfer(16).donor   = 10;	ctransfer(16).receiver	= 12;   ctransfer(16).effFLUX   = p.CCycle.effLiROOT2SOIL_MIC;  ctransfer(16).xtrEFF    = 1 - WOODLIGFRAC;
for ii = 1:numel(ctransfer)
ctransfer(ii).xtrEFF = max(min(ctransfer(ii).xtrEFF,1),0);
end
fe.CCycle.TEXTEFF	= (1 - (TEXTEFFA .* (SILT + CLAY)));
fe.CCycle.ctransfer	= ctransfer;
fe.CCycle.MTF       = MTF;
maxMinLAI	= p.CCycle.maxMinLAI;
kRTLAI      = p.CCycle.kRTLAI;
TSPY	= info.timeScale.stepsPerYear;
NYears	= info.timeScale.nYears;
if rem(TSPY,1)~=0,TSPY=floor(TSPY);end
LAI	= f.LAI;
LAI13                   = zeros(size(LAI,1), TSPY + 1);
LAI13(:, 2:TSPY + 1)	= flipdim(LAI(:,1:TSPY), 2);
LAI13(:, 1)             = LAI(:, 1);
fe.CCycle.LTLAI	= zeros(size(LAI));
fe.CCycle.RTLAI	= zeros(size(LAI));
k       = 0;
yVec	= unique(f.Year);
for iY = 1:NYears
TSPYiY	= TSPY + isleapyear(yVec(iY));
for iS = 1:TSPYiY
k 	= k + 1;
mLAI	= LAI(:,k);
LAI13(:, 2:TSPY + 1) = LAI13 (:, 1:TSPY); 
LAI13(:, 1) = mLAI;
dLAIsum                 = LAI13(:, 2:TSPY + 1) - LAI13(:, 1:TSPY);
dLAIsum(dLAIsum < 0)	= 0;
dLAIsum                 = sum(dLAIsum, 2);
LAIave                      = mean(LAI13(:, 2:TSPY + 1), 2);
LAImin                      = min(LAI13(:, 2:TSPY + 1), [], 2);
LAImin(LAImin > maxMinLAI)	= maxMinLAI(LAImin > maxMinLAI);
LAIsum                      = sum(LAI13(:, 2:TSPY + 1), 2);
LTCON       = zeros(size(LAI13(:, 1)));
ndx         = (LAIave > 0);
LTCON(ndx)  = LAImin(ndx) ./ LAIave(ndx);
dLAI            = LAI13(:, 2) - LAI13(:, 1);
dLAI(dLAI < 0)	= 0;
LTVAR                           = zeros(size(dLAI));
LTVAR(dLAI <= 0 | dLAIsum <= 0)	= 0;
ndx                             = (dLAI > 0 | dLAIsum > 0);
LTVAR(ndx)                      = (dLAI(ndx) ./ dLAIsum(ndx));
LTLAI   = LTCON ./ TSPY + (1 - LTCON) .* LTVAR;
RTLAI       = zeros(size(LTLAI));
ndx         = (LAIsum > 0);
LAI131st    = LAI13(:, 1);
RTLAI(ndx)	= (1 - kRTLAI) .* (LTLAI(ndx) + LAI131st(ndx) ./ ...
LAIsum(ndx)) ./ 2 + kRTLAI ./ TSPY;
fe.CCycle.LTLAI(:,k)	= LTLAI; % leaf litter scalar
fe.CCycle.RTLAI(:,k)	= RTLAI; % root litter scalar
end 
end
fe.CCycle.DecayRate(1).value	= max(min(fe.CCycle.annkpool(1).value .* fe.CCycle.RTLAI,1),0);
fe.CCycle.DecayRate(2).value	= max(min(fe.CCycle.kpool(2).value,1),0) * ones(1,info.forcing.size(2));
fe.CCycle.DecayRate(3).value	= max(min(fe.CCycle.kpool(3).value,1),0) * ones(1,info.forcing.size(2));
fe.CCycle.DecayRate(4).value	= max(min(fe.CCycle.annkpool(4).value .* fe.CCycle.RTLAI,1),0);
fe.CCycle.kfEnvTs(5).value  = fe.CCycle.kpool(5).value  .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(6).value  = fe.CCycle.kpool(6).value  .* fe.TempEffectRH.fT	.* fe.CCycle.LIGEFF;
fe.CCycle.kfEnvTs(7).value  = fe.CCycle.kpool(7).value  .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(8).value  = fe.CCycle.kpool(8).value  .* fe.TempEffectRH.fT   .* fe.CCycle.LIGEFF;
fe.CCycle.kfEnvTs(9).value  = fe.CCycle.kpool(9).value  .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(10).value	= fe.CCycle.kpool(10).value .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(11).value	= fe.CCycle.kpool(11).value .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(12).value	= fe.CCycle.kpool(12).value .* fe.TempEffectRH.fT	.* fe.CCycle.TEXTEFF;
fe.CCycle.kfEnvTs(13).value	= fe.CCycle.kpool(13).value .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(14).value	= fe.CCycle.kpool(14).value	.* fe.TempEffectRH.fT;
for ii = 5:14
fe.CCycle.kfEnvTs(ii).value	= max(min(fe.CCycle.kfEnvTs(ii).value,1),0);
end
end
