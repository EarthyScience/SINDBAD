function [f,fe,fx,s,d,p] = dyna_GPPfwSoil_CASA(f,fe,fx,s,d,p,info,tix)


% is not VPD effect, is the ET/PET effect 

% if Tair <= 0 | PET <= 0, use the previous stress index
We      = d.prev.d_GPPfwSoil_SMScGPP;

% otherwise, compute according to CASA
ndx     = f.Tair(:,tix) > 0 & f.PET(:,tix) > 0;
We(ndx) = p.GPPfwSoil.Bwe(ndx,1) + d.GPPfwSoil.OmBweOPET(ndx,tix) .* d.TranfwSoil.TranSup(ndx,tix);

d.GPPfwSoil.SMScGPP(:,tix)	= We;

end