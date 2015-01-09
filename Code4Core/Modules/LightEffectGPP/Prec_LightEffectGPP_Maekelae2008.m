function [fe,fx,d,p]=Prec_LightEffectGPP_Maekelae2008(f,fe,fx,s,d,p,info);

d.LightEffectGPP.LightScGPP = 1./( repmat( p.LightEffectGPP.gamma ,1,info.forcing.size(2)) .* f.Rg .* f.FAPAR +1);

%p.TempEffectGPP.gamma [0.007 0.05], median ~0.04 (unit matters???)
%the smaller p.TempEffectGPP.gamma the smaller the effect; no effect if it
%becomes 0 (i.e. linear light response)


end