function [f,fe,fx,s,d,p] = evapInt_Miralles2010(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes canopy interception evaporation according to the Gash model
%
% Inputs:
%   - info, tix
%   - rain:     rainfall [mm/time]
%   - rainInt:  rainfall intensity [mm/hr]
%               {1.5 or 5.6 for synoptic or convective}
%   - s.cd.fAPAR:   fraction of absorbed photosynthetically active 
%                   radiation (equivalent to "canopy cover" in Gash and Miralles)
%   - p.evapInt.CanopyStorage:  Canopy storage [mm] {1.2}
%   - p.evapInt.fte:            fraction of trunk evaporation [-] {0.02}
%   - p.evapInt.evapRate:       mean evaporation rate [mm/hr] {0.3}
%   - p.evapInt.St:             trunk capacity [mm] {0.02}
%   - p.evapInt.pd:             fraction rain to trunks [-] {0.02}
%
% Outputs:
%   - fx.evapInt:    canopy interception evaporation [mm/time]
%
% Modifies:
%   - s.wd.WBP:     water balance pool [mm]
%
% Notes: 
%   - Works per rain event. Here we assume that we have one rain event
%     per day - this approach should not be used for timeSteps very different
%     to daily.
%
% References:
%   - Miralles, D. G., Gash, J. H., Holmes, T. R., de Jeu, R. A., & Dolman, A. J. (2010). 
%       Global canopy interception from satellite observations. Journal of Geophysical Research: 
%       Atmospheres, 115(D16).
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%   - 1.1 on 22.11.2019 (skoirala): handle s.cd.fAPAR, rainfall intensity and rainfall
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
rain                 =  fe.rainSnow.rain(:,tix);
rainInt              =  fe.rainInt.rainInt(:,tix);
tmp                  =  info.tem.helpers.arrays.onespix;
CanopyStorage        =  p.evapInt.CanopyStorage  .* tmp;
fte                  =  p.evapInt.fte            .* tmp;
evapRate             =  p.evapInt.evapRate       .* tmp;
St                   =  p.evapInt.St             .* tmp;
pd                   =  p.evapInt.pd             .* tmp;


%catch for division by zero
valids               =  rainInt > 0 & s.cd.fAPAR > 0;
Pgc                  =  info.tem.helpers.arrays.zerospix;
Pgt                  =  info.tem.helpers.arrays.zerospix;
Ic                   =  info.tem.helpers.arrays.zerospix;
Ic1                  =  info.tem.helpers.arrays.zerospix;
Ic2                  =  info.tem.helpers.arrays.zerospix;
It2                  =  info.tem.helpers.arrays.zerospix;
It                   =  info.tem.helpers.arrays.zerospix;

%Rain intensity must be larger than evap rate
%adjusting evap rate:
v                    =  rainInt < evapRate & valids==1;
evapRate(v)          =  rainInt(v);

%Pgc: amount of gross rainfall necessary to saturate the canopy
Pgc(valids)          =  -1.*( rainInt(valids) .* CanopyStorage(valids) ./...
                        ((1- fte(valids) ) .* evapRate(valids) )).*log(1-((1- fte(valids) ) .*...
                        evapRate(valids) ./ rainInt(valids) ));

%Pgt: amount of gross rainfall necessary to saturate the trunks
Pgt(valids)          =  Pgc(valids) + rainInt(valids) .* St(valids) ./...
                        (pd(valids) .* s.cd.fAPAR(valids) .* ( rainInt(valids) - evapRate(valids) .*...
                        (1 - fte(valids) )));

%Ic: evapInt loss from canopy
Ic1(valids)          =  s.cd.fAPAR(valids) .* rain(valids); %Pg < Pgc
Ic2(valids)          =  s.cd.fAPAR(valids) .* (Pgc(valids)+((1- fte(valids) ) .* evapRate(valids) ./...
                        rainInt(valids) ) .* ( rain(valids) - Pgc(valids))); %Pg > Pgc


v                    =  rain <= Pgc & valids==1;
Ic(v)                =  Ic1(v);
Ic(v==0)             =  Ic2(v==0);

%It: interception loss from trunks
%It1 = St;% Pg < Pgt
It2(valids)          =  pd(valids) .* s.cd.fAPAR(valids) .* (1-(1 - fte(valids) ) .* evapRate(valids)...
                        ./ rainInt(valids) ).*( rain(valids) - Pgc(valids));%Pg > Pgt

v= rain <= Pgt;
It(v)                =  St(v);
It(v==0)             =  It2(v==0);

tmp                  =  Ic+It;
tmp(rain == 0)       =  0;

v=tmp > rain;
tmp(v)               =  rain(v);

fx.evapInt(:,tix)    =  tmp;

% update the water budget pool
s.wd.WBP             =  s.wd.WBP - fx.evapInt(:,tix);

end
