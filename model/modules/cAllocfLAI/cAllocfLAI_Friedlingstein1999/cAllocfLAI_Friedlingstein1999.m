function [f,fe,fx,s,d,p] = cAllocfLAI_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
% light limitation (LL) calculation
LL                          = exp (-p.cAllocfLAI.kext .* s.cd.LAI); 
LL(LL <= p.cAllocfLAI.minL) = p.cAllocfLAI.minL(LL <= p.cAllocfLAI.minL);
LL(LL >= p.cAllocfLAI.maxL) = p.cAllocfLAI.maxL(LL >= p.cAllocfLAI.maxL);
d.cAllocfLAI.LL(:,tix) = LL;
end
