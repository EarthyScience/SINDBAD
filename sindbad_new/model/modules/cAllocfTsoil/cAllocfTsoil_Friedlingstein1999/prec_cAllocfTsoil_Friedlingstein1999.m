function [f,fe,fx,s,d,p] = prec_cAllocfTsoil_Friedlingstein1999(f,fe,fx,s,d,p,info)
% partial computation for the temperature effect on
% decomposition/mineralization
NL_fT                                 	= fe.cTaufTsoil.fT;
NL_fT(NL_fT >= p.cAllocfTsoil.maxL_fT)  = p.cAllocfTsoil.maxL_fT(NL_fT >= p.cAllocfTsoil.maxL_fT);
NL_fT(NL_fT <= p.cAllocfTsoil.minL_fT)  = p.cAllocfTsoil.minL_fT(NL_fT <= p.cAllocfTsoil.minL_fT);
fe.cAllocfTsoil.NL_fT                   = NL_fT;
end % function