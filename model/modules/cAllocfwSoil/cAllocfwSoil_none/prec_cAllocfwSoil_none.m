function [f,fe,fx,s,d,p] = prec_cAllocfwSoil_none(f,fe,fx,s,d,p,info)
fe.cAllocfwSoil.NL_fW = info.tem.helpers.arrays.onespixtix;
end