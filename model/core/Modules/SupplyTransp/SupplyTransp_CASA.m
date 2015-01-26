function [fx,s,d] = SupplyTransp_CASA(f,fe,fx,s,d,p,info,i)

% % T = maxRate*(SM1+SM2)/AWC12
% d.SupplyTransp.TranspS(:,i) = p.SupplyTransp.maxRate .* ( s.wSM1(:,i) + s.wSM2(:,i) ) ./ ( p.SOIL.AWC12 );
wAvail                           = (f.Rain(:,i) + fx.Qsnow(:,i));


% CALCULATE VMC: Volumetric Moisture Content
VMC = (s.wSM1 + s.wSM2 + p.SOIL.WPT) ./ p.SOIL.FC;
% VMC = (s.wSM1(:,i) + s.wSM2(:,i)) ./ p.SOIL.AWC12;

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
EETb                            = wAvail(ndx,1) + (d.Temp.pwSM1(ndx,1) + d.Temp.pwSM2(ndx,1));
d.SupplyTransp.TranspS(ndx,i)	= min(EETa, EETb);

end % function