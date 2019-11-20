function [f,fe,fx,s,d,p] = TranfwSoil_CASA(f,fe,fx,s,d,p,info,tix)

% % T = maxRate*(wSM)/tAWC
% d.TranfwSoil.TranActS(:,tix) = p.TranfwSoil.maxRate .* ( s.w.wSoil(:,tix) ) ./ ( p.pSoil.tAWC );
% wAvail                           = (fe.rainSnow.rain(:,tix) + fx.snowMelt(:,tix));
wAvail                              =  (fe.rainSnow.rain(:,tix) + fx.snowMelt(:,tix) - fx.ECanop(:,tix) - fx.ESoil(:,tix) - fx.Qinf(:,tix) - fx.roSat(:,tix)); 

% CALCULATE VMC: Volumetric Moisture Content
VMC                                 =   (s.w.wSoil + p.pSoil.WPT) ./ p.pSoil.FC;
% VMC                           = (s.w.wSoil(:,tix)) ./ p.pSoil.tAWC;

% compute relative drying rate
RDR                                 =   info.tem.helpers.arrays.zerospix;
RDR(wAvail(:,1) > f.PET(:,tix))     =   1;

% ndx                             = (fe.rainSnow.rain(:,tix) + fx.snowMelt(:,tix)) <= f.PET(:,tix);
ndx                                 =   wAvail <= f.PET(:,tix); 
RDR(ndx)                            =   (1 + p.pSoil.Alpha(ndx)) ./ (1 + p.pSoil.Alpha(ndx) .* (VMC(ndx) .^ p.pSoil.Beta(ndx)));

% when PRECIPITATION EXCEEDS PET THEN EET IS EQUAL TO PET
ndx                                 =   wAvail >= f.PET(:,tix);
d.TranfwSoil.TranActS(ndx,tix)      =   f.PET(ndx,tix);

% when not
ndx                                 =   wAvail < f.PET(:,tix);
EETa                                =   wAvail(ndx,1) + (f.PET(ndx,tix) - wAvail(ndx,1)) .* RDR(ndx,1);
EETb                                =   wAvail(ndx,1) + (s.prev.s_w_wSoil(ndx,1));
d.TranfwSoil.TranActS(ndx,tix)      =   min(EETa, EETb);

end % function