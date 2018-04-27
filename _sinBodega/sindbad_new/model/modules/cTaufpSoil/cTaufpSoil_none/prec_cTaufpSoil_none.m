function [fe,fx,d,p,f] = prec_cTaufpSoil_none(f,fe,fx,s,d,p,info)
% no effect = 1;
s.cd.p_cTaufpSoil_kfSoil 		= ones(nPix,nZix)
% (ineficient, should be pix zix_mic)
end %function
