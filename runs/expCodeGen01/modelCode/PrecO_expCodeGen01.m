function [fe,fx,d,p]=PrecO_expCodeGen01(f,fe,fx,s,d,p,info);
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
fx.ECanop = tmp;
d.LightEffectGPP.LightScGPP = ones(info.forcing.size);
d.MaxRUE.rueGPP = p.MaxRUE.rue * ones(1,info.forcing.size(2));
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
v=AIRT >= TOPT;
T2       = T21;
T2(v)    = T22(v);
d.TempEffectGPP.TempScGPP = T2 .* T1;
d.VPDEffectGPP.VPDScGPP = ones(info.forcing.size);
scall           = zeros(info.forcing.size(1),info.forcing.size(2),3);
scall(:,:,1)    = d.TempEffectGPP.TempScGPP;
scall(:,:,2)    = d.VPDEffectGPP.VPDScGPP;
scall(:,:,3)    = d.LightEffectGPP.LightScGPP;
d.DemandGPP.AllScGPP    = prod(scall,3);
d.DemandGPP.gppE        = f.FAPAR .* f.PAR .* d.MaxRUE.rueGPP .* d.DemandGPP.AllScGPP;
pBwe                            = p.SMEffectGPP.Bwe * ones(1,info.forcing.size(2));
d.SMEffectGPP.OmBweOPET        = NaN(info.forcing.size);
ndx                             = f.Tair > 0 & f.PET > 0;
d.SMEffectGPP.OmBweOPET(ndx)	= (1 - pBwe(ndx)) ./ f.PET(ndx);
d.SMEffectGPP.SMScGPP         = ones(info.forcing.size);
fe.TempEffectRH.fT	= 1; 
d.TempEffectAutoResp	= ones(info.forcing.size);
end
