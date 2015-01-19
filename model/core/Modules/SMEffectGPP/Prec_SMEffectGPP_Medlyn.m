function [fe,fx,d,p] = Prec_SMEffectGPP_Medlyn(f,fe,fx,s,d,p,info)

%precomputed: AoE   	= ca .* PsurfDay  ./ (1.6 .* (VPDDay + g1 .* sqrt(VPDDay)));    
%conversion factor:  6.6667e-004
pg1                 = p.Transp.g1 * ones(1,info.forcing.size(2));
fe.SMEffectGPP.AoE  = 6.6667e-004 .* f.ca .* f.PsurfDay ./ (1.6 .* (f.VPDDay + pg1 .* sqrt(f.VPDDay)));
 
end