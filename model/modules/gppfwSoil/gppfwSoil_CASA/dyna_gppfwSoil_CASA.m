function [f,fe,fx,s,d,p] = dyna_gppfwSoil_CASA(f,fe,fx,s,d,p,info,tix)


% is not VPD effect, is the ET/PET effect 

% if Tair <= 0 | PET <= 0, use the previous stress index
We      = d.prev.d_gppfwSoil_SMScGPP;

% otherwise, compute according to CASA
ndx     = f.Tair(:,tix) > 0 & fe.PET.PET(:,tix) > 0;
We(ndx) = p.gppfwSoil.Bwe(ndx,1) + d.gppfwSoil.OmBweOPET(ndx,tix) .* d.tranSup.tranSup(ndx,tix);

d.gppfwSoil.SMScGPP(:,tix)	= We;


% OLD code of transup for casa

% % % T = maxRate*(wSM)/tAWC
% % d.TranfwSoil.TranActS(:,tix) = p.TranfwSoil.maxRate .* ( s.w.wSoil(:,tix) ) ./ ( p.pSoil.tAWC );
% % wAvail                           = (f.Rain(:,tix) + fx.Qsnow(:,tix));
% wAvail                              =  (f.Rain(:,tix) + fx.Qsnow(:,tix) - fx.ECanop(:,tix) - fx.ESoil(:,tix) - fx.Qinf(:,tix) - fx.Qsat(:,tix)); 

% % CALCULATE VMC: Volumetric Moisture Content
% VMC                                 =   (s.w.wSoil + p.pSoil.WPT) ./ p.pSoil.FC;
% % VMC                           = (s.w.wSoil(:,tix)) ./ p.pSoil.tAWC;

% % compute relative drying rate
% RDR                                 =   info.tem.helpers.arrays.zerospix;
% RDR(wAvail(:,1) > f.PET(:,tix))     =   1;

% % ndx                             = (f.Rain(:,tix) + fx.Qsnow(:,tix)) <= f.PET(:,tix);
% ndx                                 =   wAvail <= f.PET(:,tix); 
% RDR(ndx)                            =   (1 + p.pSoil.Alpha(ndx)) ./ (1 + p.pSoil.Alpha(ndx) .* (VMC(ndx) .^ p.pSoil.Beta(ndx)));

% % when PRECIPITATION EXCEEDS PET THEN EET IS EQUAL TO PET
% ndx                                 =   wAvail >= f.PET(:,tix);
% d.TranfwSoil.TranActS(ndx,tix)      =   f.PET(ndx,tix);

% % when not
% ndx                                 =   wAvail < f.PET(:,tix);
% EETa                                =   wAvail(ndx,1) + (f.PET(ndx,tix) - wAvail(ndx,1)) .* RDR(ndx,1);
% EETb                                =   wAvail(ndx,1) + (s.prev.s_w_wSoil(ndx,1));
% d.TranfwSoil.TranActS(ndx,tix)      =   min(EETa, EETb);



end