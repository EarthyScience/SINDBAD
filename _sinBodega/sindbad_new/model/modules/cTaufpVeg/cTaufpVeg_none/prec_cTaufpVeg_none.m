function [fe,fx,d,p,f] = prec_cTaufpVeg_none(f,fe,fx,s,d,p,info)
% initialize the outputs to ones
s.cd.p_cTaufpVeg_kfVeg	= ones(nPix,nZix);
s.cd.p_cTaufpVeg_LITC2N	= zeros(nPix,1);
s.cd.p_cTaufpVeg_LIGNIN	= zeros(nPix,1);
s.cd.p_cTaufpVeg_MTF    = ones(nPix,1);
s.cd.p_cTaufpVeg_SCLIGNIN = zeros(nPix,1);
s.cd.p_cTaufpVeg_LIGEFF = zeros(nPix,1);



end %function
