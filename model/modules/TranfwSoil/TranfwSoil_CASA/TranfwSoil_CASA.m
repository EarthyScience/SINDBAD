function [f,fe,fx,s,d,p] = TranfwSoil_CASA(f,fe,fx,s,d,p,info,tix)

wAvail                              =  s.wd.WBP; 

% CALCULATE VMC: Volumetric Moisture Content with root fractions
VMC                             = min(max((sum(s.w.wSoil .* fe.wSoilBase.fracRoot2SoilD,2) - sum(fe.wSoilBase.sWP .* fe.wSoilBase.fracRoot2SoilD,2)),0) ./ sum(fe.wSoilBase.sAWC .* fe.wSoilBase.fracRoot2SoilD,2),1);

% compute relative drying rate
RDR                                 =   info.tem.helpers.arrays.zerospix;
RDR(wAvail(:,1) > f.PET(:,tix))     =   1;
ndx                                 =   wAvail <= f.PET(:,tix); 
RDR(ndx)                            =   (1 + mean(fe.wSoilBase.Alpha(ndx,:),2)) ./ (1 + mean(fe.wSoilBase.Alpha(ndx,:),2) .* (VMC(ndx) .^ mean(fe.wSoilBase.Beta(ndx,:),2)));

% when PRECIPITATION EXCEEDS PET THEN EET IS EQUAL TO PET
ndx                                 =   wAvail >= f.PET(:,tix);
d.TranfwSoil.TranActS(ndx,tix)      =   f.PET(ndx,tix);

% when not
ndx                                 =   wAvail < f.PET(:,tix);
EETa                                =   wAvail(ndx,1) + (f.PET(ndx,tix) - wAvail(ndx,1)) .* RDR(ndx,1);
EETb                                =   wAvail(ndx,1) + sum(s.w.wSoil(ndx,:),2);
d.TranfwSoil.TranActS(ndx,tix)      =   min(EETa, EETb);

end % function