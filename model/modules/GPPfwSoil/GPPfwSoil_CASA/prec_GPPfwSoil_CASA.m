function [f,fe,fx,s,d,p] = prec_GPPfwSoil_CASA(f,fe,fx,s,d,p,info,tix)


% 
pBwe                            =   p.GPPfwSoil.Bwe * info.tem.helpers.arrays.onestix;
d.GPPfwSoil.OmBweOPET           =   info.tem.helpers.arrays.nanpixtix;
ndx                             =   f.Tair > 0 & fe.PET.PET > 0;
d.GPPfwSoil.OmBweOPET(ndx)      =   (1 - pBwe(ndx)) ./ fe.PET.PET(ndx);

d.GPPfwSoil.SMScGPP             =   info.tem.helpers.arrays.onespixtix; %-> should be
% initialized in teh preallocation function

end