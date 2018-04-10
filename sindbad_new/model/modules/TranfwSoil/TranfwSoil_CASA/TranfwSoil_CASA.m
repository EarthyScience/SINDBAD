function [fx,s,d] = TranfwSoil_CASA(f,fe,fx,s,d,p,info,tix)

% % T = maxRate*(wSM)/tAWC
% d.TranfwSoil.TranActS(:,tix) = p.TranfwSoil.maxRate .* ( s.wSM(:,tix) ) ./ ( p.psoil.tAWC );
% wAvail                           = (f.Rain(:,tix) + fx.Qsnow(:,tix));
wAvail                           = (f.Rain(:,tix) + fx.Qsnow(:,tix) - fx.ECanop(:,tix) - fx.ESoil(:,tix) - fx.Qinf(:,tix) - fx.Qsat(:,tix)); 

% CALCULATE VMC: Volumetric Moisture Content
VMC                             = (s.wSM + p.psoil.WPT) ./ p.psoil.FC;
% VMC                           = (s.wSM(:,tix)) ./ p.psoil.tAWC;

% compute relative drying rate
RDR                             = zeros(info.forcing.size(1),1);
RDR(wAvail(:,1) > f.PET(:,tix))   = 1;

% ndx                             = (f.Rain(:,tix) + fx.Qsnow(:,tix)) <= f.PET(:,tix);
ndx                             = wAvail <= f.PET(:,tix); 
RDR(ndx)                        = (1 + p.psoil.Alpha(ndx)) ./ (1 + p.psoil.Alpha(ndx) .* (VMC(ndx) .^ p.psoil.Beta(ndx)));

% when PRECIPITATION EXCEEDS PET THEN EET IS EQUAL TO PET
ndx                             = wAvail >= f.PET(:,tix);
d.TranfwSoil.TranActS(ndx,tix)   = f.PET(ndx,tix);

% when not
ndx                             = wAvail < f.PET(:,tix);
EETa                            = wAvail(ndx,1) + (f.PET(ndx,tix) - wAvail(ndx,1)) .* RDR(ndx,1);
EETb                            = wAvail(ndx,1) + (d.Temp.pwSM(ndx,1));
d.TranfwSoil.TranActS(ndx,tix)	= min(EETa, EETb);

end % function