function [f,fe,fx,s,d,p] = prec_gppfwSoil_CASA(f,fe,fx,s,d,p,info,tix)


% 
pBwe                            =   p.gppfwSoil.Bwe .* info.tem.helpers.arrays.onestix;
d.gppfwSoil.OmBweOPET           =   info.tem.helpers.arrays.nanpixtix;
ndx                             =   f.Tair > 0 & fe.PET.PET > 0;
d.gppfwSoil.OmBweOPET(ndx)      =   (1 - pBwe(ndx)) ./ fe.PET.PET(ndx);

d.gppfwSoil.SMScGPP             =   info.tem.helpers.arrays.onespixtix; %-> should be
% initialized in teh preallocation function

end
