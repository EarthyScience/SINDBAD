function [f,fe,fx,s,d,p] = prec_evapInt_Miralles2010(f,fe,fx,s,d,p,info)
% #########################################################################
% computes canopy interception evaporation according to the Gash model
%
% Inputs:
%	- info structure
%   - fe.rainSnow.rain:     rain fall [mm/time]
%   - fe.rainInt.rainInt:            rainfall intensity [mm/hr]
%                           {1.5 or 5.6 for synoptic or convective}
%   - s.cd.fAPAR:              fraction of absorbed photosynthetically active 
%                           radiation [] 
%                           (equivalent to "canopy cover" in Gash and Miralles)
%
%   - p.evapInt.CanopyStorage:  Canopy storage [mm] {1.2}
%   - p.evapInt.fte:            fraction of trunk evaporation [] {0.02}
%   - p.evapInt.evapRate:       mean evaporation rate [mm/hr] {0.3}
%   - p.evapInt.St:             trunk capacity [mm] {0.02}
%   - p.evapInt.pd:             fraction rain to trunks [] {0.02}
%
% Outputs:
%   - fx.evapInt:    canopy interception evaporation [mm/time]
%
% Modifies:
% 	- 
%
% References:
%	- Gash model; Miralles et al 2010
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% NOTES: 
%   - Works per rain event. Here we assume that we have one rain event
%     per day - this approach should not be used for timeSteps very different
%     to daily.
%
%%
% #########################################################################

% tmp             =   info.tem.helpers.arrays.onestix;
% CanopyStorage   =   p.evapInt.CanopyStorage  * tmp;
% fte             =   p.evapInt.fte            * tmp; 
% evapRate        =   p.evapInt.evapRate       * tmp;
% St              =   p.evapInt.St             * tmp;
% pd              =   p.evapInt.pd             * tmp;


% %catch for division by zero
% valids          =	fe.rainInt.rainInt > 0 & s.cd.fAPAR > 0;
% Pgc             =   info.tem.helpers.arrays.zerospixtix;
% Pgt             =   info.tem.helpers.arrays.zerospixtix;
% Ic              =	info.tem.helpers.arrays.zerospixtix;
% Ic1             =	info.tem.helpers.arrays.zerospixtix;
% Ic2             =	info.tem.helpers.arrays.zerospixtix;
% It2             =   info.tem.helpers.arrays.zerospixtix;
% It              =   info.tem.helpers.arrays.zerospixtix;

% %Rainintensity must be larger than evap rate
% %adjusting evap rate:
% v=fe.rainInt.rainInt < evapRate & valids==1;
% evapRate(v)=fe.rainInt.rainInt(v);

% %Pgc: amount of gross rainfall necessary to saturate the canopy
% Pgc(valids)=-1.*( fe.rainInt.rainInt(valids) .* CanopyStorage(valids) ./ ((1- fte(valids) ) .* evapRate(valids) )).*log(1-((1- fte(valids) ) .* evapRate(valids) ./ fe.rainInt.rainInt(valids) ));

% %Pgt: amount of gross rainfall necessary to saturate the trunks
% Pgt(valids)=Pgc(valids) + fe.rainInt.rainInt(valids) .* St(valids) ./ ( pd(valids) .* s.cd.fAPAR(valids) .* ( fe.rainInt.rainInt(valids) - evapRate(valids) .* (1 - fte(valids) )));

% %Ic: evapInt loss from canopy
% Ic1(valids) = s.cd.fAPAR(valids) .* fe.rainSnow.rain(valids); %Pg < Pgc
% Ic2(valids) = s.cd.fAPAR(valids) .* (Pgc(valids)+((1- fte(valids) ) .* evapRate(valids) ./ fe.rainInt.rainInt(valids) ) .* ( fe.rainSnow.rain(valids) - Pgc(valids))); %Pg > Pgc


% v= fe.rainSnow.rain <= Pgc & valids==1;
% Ic(v)=Ic1(v);
% Ic(v==0)=Ic2(v==0);

% %It: interception loss from trunks

% %It1 = St;% Pg < Pgt
% It2(valids) = pd(valids) .* s.cd.fAPAR(valids) .* (1-(1 - fte(valids) ) .* evapRate(valids) ./ fe.rainInt.rainInt(valids) ).*( fe.rainSnow.rain(valids) - Pgc(valids));%Pg > Pgt

% v= fe.rainSnow.rain <= Pgt;
% It(v) = St(v);
% It(v==0)=It2(v==0);

% tmp = Ic+It;
% tmp(fe.rainSnow.rain == 0) = 0;

% v=tmp > fe.rainSnow.rain;
% tmp(v) = fe.rainSnow.rain(v);

% fx.evapInt = tmp;


end