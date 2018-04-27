function [fe,fx,d,p]=PrecO_expCodeGen01(f,fe,fx,s,d,p,info);
N     = numel(p.SOIL.HeightLayer);
tSLDP = zeros(info.forcing.size(1),1);
for ij = 1:N
tSLDP	= tSLDP + p.SOIL.HeightLayer(ij).value;
end
for ij = 1:N
p.SOIL.AWC(ij).value    = p.SOIL.tAWC .* p.SOIL.HeightLayer(ij).value ./ tSLDP ;
end
fx.Subl=info.helper.zeros2d;
fx.ECanop   = info.helper.zeros2d;
fx.Qinf = info.helper.zeros2d;
fx.Qsat = info.helper.zeros2d;
fx.Qint = info.helper.zeros2d;
fx.Qb = info.helper.zeros2d;
fx.ESoil = info.helper.zeros2d;
d.LightEffectGPP.LightScGPP = ones(info.forcing.size);
d.VPDEffectGPP.VPDScGPP = ones(info.forcing.size);
fe.TempEffectRH.fT	= 1; 
d.TempEffectAutoResp	= ones(info.forcing.size);
end
