function [fe,fx,d,p]=PrecO_expCodeGen01(f,fe,fx,s,d,p,info);
pRate               = (p.SnowMelt.Rate .* info.timeScale.timeStep) * ones(1,info.forcing.size(2));
fe.SnowMelt.Tterm	= max(pRate .* f.Tair,0);
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
