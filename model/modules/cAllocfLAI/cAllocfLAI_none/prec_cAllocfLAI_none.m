function [f,fe,fx,s,d,p] = prec_cAllocfLAI_none(f,fe,fx,s,d,p,info)
% set the allocation to ones
d.cAllocfLAI.LL = info.tem.helpers.arrays.onespixtix;
end
