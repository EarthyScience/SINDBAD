function [fx,s,d] = Transp_Medlyn(f,fe,fx,s,d,p,info,i)

%calc ET
 fx.Transp(:,i)	= fx.gpp(:,i) ./ fe.SMEffectGPP.AoE(:,i);



end