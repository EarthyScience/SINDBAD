function [fx,s,d] = dyna_gppFwsoil_CASA(f,fe,fx,s,d,p,info,tix)


% is not VPD effect, is the ET/PET effect 

% if Tair <= 0 | PET <= 0, use the previous stress index
We      = d.Temp.pSMScGPP;

% otherwise, compute according to CASA
ndx     = f.Tair(:,tix) > 0 & f.PET(:,tix) > 0;
We(ndx) = p.gppFwsoil.Bwe(ndx,1) + d.gppFwsoil.OmBweOPET(ndx,tix) .* d.transpFwsoil.transpJactS(ndx,tix);

d.gppFwsoil.SMScGPP(:,tix)	= We;

end