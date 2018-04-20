function [f,fe,fx,s,d,p] = cAllocfwSoil_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)

% computation for the moisture effect on decomposition/mineralization
NL_fW                                   = d.cTaufwSoil.fwSoil(:,tix);
NL_fW(NL_fW >= p.cAllocfwSoil.maxL_fW)  = p.cAllocfwSoil.maxL_fW(NL_fW >= p.cAllocfwSoil.maxL_fW);
NL_fW(NL_fW <= p.cAllocfwSoil.minL_fW)	= p.cAllocfwSoil.minL_fW(NL_fW <= p.cAllocfwSoil.minL_fW);
fe.cAllocfwSoil.NL_fW(:,tix)            = NL_fW;

end % function