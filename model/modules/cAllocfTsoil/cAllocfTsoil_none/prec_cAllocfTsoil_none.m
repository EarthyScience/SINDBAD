function [f,fe,fx,s,d,p] = prec_cAllocfTsoil_none(f,fe,fx,s,d,p,info)
d.cAllocfTSoil.NL_fW = info.tem.helpers.arrays.onespixtix; %sujan fwSoil was changed to fTSoil
end % function