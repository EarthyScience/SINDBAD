function [fx,s,d] = SupplyTransp_CASA(f,fe,fx,s,d,p,info,i)

% % T = maxRate*(wSM)/tAWC
% d.SupplyTransp.TranspS(:,i) = p.SupplyTransp.maxRate .* ( s.wSM(:,i) ) ./ ( p.SOIL.tAWC );
wAvail                           = (f.Rain(:,i) + fx.Qsnow(:,i));


% CALCULATE VMC: Volumetric Moisture Content
VMC = (s.wSM + p.SOIL.WPT) ./ p.SOIL.FC;
% VMC = (s.wSM(:,i)) ./ p.SOIL.tAWC;

% compute relative drying rate
RDR                             = zeros(info.forcing.size(1),1);
RDR(wAvail(:,1) > f.PET(:,i))   = 1;

ndx                             = (f.Rain(:,i) + fx.Qsnow(:,i)) <= f.PET(:,i);
RDR(ndx)                        = (1 + p.SOIL.Alpha(ndx)) ./ (1 + p.SOIL.Alpha(ndx) .* (VMC(ndx) .^ p.SOIL.Beta(ndx)));

% when PRECIPITATION EXCEEDS PET THEN EET IS EQUAL TO PET
ndx                             = wAvail >= f.PET(:,i);
d.SupplyTransp.TranspS(ndx,i)   = f.PET(ndx,i);

% when not
ndx                             = wAvail < f.PET(:,i);
EETa                            = wAvail(ndx,1) + (f.PET(ndx,i) - wAvail(ndx,1)) .* RDR(ndx,1);
EETb                            = wAvail(ndx,1) + (d.Temp.pwSM(ndx,1));
d.SupplyTransp.TranspS(ndx,i)	= min(EETa, EETb);

end % function