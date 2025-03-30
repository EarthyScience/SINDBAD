function [f,fe,fx,s,d,p] = prec_cAllocfTsoil_none(f,fe,fx,s,d,p,info)
%set stressors from temperature for C allocation to 1
d.cAllocfTSoil.fT = info.tem.helpers.arrays.onespixtix; %sujan fwSoil was changed to fTSoil
end