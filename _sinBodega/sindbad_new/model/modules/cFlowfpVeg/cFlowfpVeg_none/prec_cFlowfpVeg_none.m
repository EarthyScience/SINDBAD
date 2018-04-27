function [fe,fx,d,p,f] = prec_cFlowfpVeg_none(f,fe,fx,s,d,p,info)
% no effect = 1;
s.cd.p_cFlowfpVeg_fVeg = zeros(nPix,numel(info.tem.model.c.nZix));
end %function
