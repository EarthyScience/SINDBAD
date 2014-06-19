function [fe,fx,d,p]=Prec_SMEffectGPP_Medlyn_AoE(f,fe,fx,s,d,p,info);

%precomputed: AoE   	= ca .* PsurfDay  ./ (1.6 .* (VPDDay + g1 .* sqrt(VPDDay)));    
%conversion factor:  6.6667e-004
fe.AoE =  6.6667e-004 .* f.ca .* f.PsurfDay  ./ (1.6 .* ( f.VPDDay + repmat( p.Transp.g1 ,1,info.Forcing.Size(2)) .* sqrt( f.VPDDay )));  
 
end