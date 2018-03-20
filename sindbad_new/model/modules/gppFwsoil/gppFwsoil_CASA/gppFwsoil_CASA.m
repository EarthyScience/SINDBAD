function [fx,s,d] = gppFwsoil_CASA(f,fe,fx,s,d,p,info,i)


% is not VPD effect, is the ET/PET effect 

% if Tair <= 0 | PET <= 0, use the previous stress index
We      = d.Temp.pSMScGPP;

% otherwise, compute according to CASA
ndx     = f.Tair(:,i) > 0 & f.PET(:,i) > 0;
We(ndx) = p.SMEffectGPP.Bwe(ndx,1) + d.SMEffectGPP.OmBweOPET(ndx,i) .* d.SupplyTransp.TranspS(ndx,i);

d.SMEffectGPP.SMScGPP(:,i)	= We;

end