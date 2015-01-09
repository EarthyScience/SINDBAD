function [fe,fx,d,p]=Prec_RdiffEffectGPP_Turner(f,fe,fx,s,d,p,info);


 d.RdiffEffectGPP.rueGPP = ( repmat( p.RdiffEffectGPP.rue2 ,1,info.forcing.size(2)) - repmat( p.RdiffEffectGPP.rue1 ,1,info.forcing.size(2)) ) .* (1 - f.Rg ./ f.RgPot ) + repmat( p.RdiffEffectGPP.rue1 ,1,info.forcing.size(2));    



end