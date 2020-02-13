function [f,fe,fx,s,d,p] = prec_cAllocfRad_none(f,fe,fx,s,d,p,info)
%set stressors from radiation for C allocation to 1
d.cAllocfRad.fR = info.tem.helpers.arrays.onespixtix;
end