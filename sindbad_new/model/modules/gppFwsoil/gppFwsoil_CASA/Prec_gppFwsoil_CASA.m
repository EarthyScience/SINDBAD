function [fe,fx,d,p] = Prec_gppFwsoil_CASA(f,fe,fx,s,d,p,info,i)


% 
pBwe                            = p.SMEffectGPP.Bwe * ones(1,info.forcing.size(2));
d.SMEffectGPP.OmBweOPET        = NaN(info.forcing.size);
ndx                             = f.Tair > 0 & f.PET > 0;
d.SMEffectGPP.OmBweOPET(ndx)	= (1 - pBwe(ndx)) ./ f.PET(ndx);

d.SMEffectGPP.SMScGPP         = ones(info.forcing.size); %-> should be
% initialized in teh preallocation function

end