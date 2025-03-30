function [f,fe,fx,s,d,p] = dyna_gppfwSoil_CASA(f,fe,fx,s,d,p,info,tix)


% is not VPD effect, is the ET/PET effect 

% if Tair <= 0 | PET <= 0, use the previous stress index
We      = d.prev.d_gppfwSoil_SMScGPP;

% otherwise, compute according to CASA
ndx     = f.Tair(:,tix) > 0 & fe.PET.PET(:,tix) > 0;
We(ndx) = p.gppfwSoil.Bwe(ndx,1) + d.gppfwSoil.OmBweOPET(ndx,tix) .* fx.tranAct.tranAct(ndx,tix);

d.gppfwSoil.SMScGPP(:,tix)	= We;

end