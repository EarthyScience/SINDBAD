function [f,fe,fx,s,d,p] = prec_cAllocfwSoil_none(f,fe,fx,s,d,p,info)
    %set stressors from moisture for C allocation to 1
    fe.cAllocfwSoil.fW = info.tem.helpers.arrays.onespixtix;
end
