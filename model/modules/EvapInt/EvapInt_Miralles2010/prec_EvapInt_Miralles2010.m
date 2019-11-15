function [f,fe,fx,s,d,p] = prec_EvapInt_Miralles2010(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute canopy interception evaporation according to the Gash
% model.
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% Rain      : rain fall [mm]
%           (fe.rainSnow.rain)
% RainInt   : rainfall intensity [mm/hr] {1.5 or 5.6 for synoptic or
%           convective}
%           (f.RainInt)
% CanopyStorage : Canopy storage [mm] {1.2}
%               (p.EvapInt.CanopyStorage)
% fte           : fraction of trunk evaporation [] {0.02}
%               (p.EvapInt.fte)
% EvapRate      : mean evaporation rate [mm/hr] {0.3}
%               (p.EvapInt.EvapRate)
% St            : trunk capacity [mm] {0.02}
%               (p.EvapInt.St)
% pd            : fraction rain to trunks [] {0.02}
%               (p.EvapInt.pd)
% FAPAR         : fraction of absorbed photosynthetically active radiation
%               [] (equivalent to "canopy cover" in Gash and Miralles)
%               (f.FAPAR)
% 
% OUTPUT
% ECanop    : canopy interception evaporation [mm/time]
%           (fx.ECanop)
% 
% NOTES: Works per rain event. Here we assume that we have one rain event
% per day - this approach should not be used for timeSteps very different
% to daily.
%        Parameters above, defaults in curly brackets from Mirales et al
%        2010
% 
% #########################################################################

tmp             =   info.tem.helpers.arrays.onestix;
CanopyStorage   =   p.EvapInt.CanopyStorage  * tmp;
fte             =   p.EvapInt.fte            * tmp; 
EvapRate        =   p.EvapInt.EvapRate       * tmp;
St              =   p.EvapInt.St             * tmp;
pd              =   p.EvapInt.pd             * tmp;


%catch for division by zero
valids          =	f.RainInt > 0 & f.FAPAR > 0;
Pgc             =   info.tem.helpers.arrays.zerospixtix;
Pgt             =   info.tem.helpers.arrays.zerospixtix;
Ic              =	info.tem.helpers.arrays.zerospixtix;
Ic1             =	info.tem.helpers.arrays.zerospixtix;
Ic2             =	info.tem.helpers.arrays.zerospixtix;
It2             =   info.tem.helpers.arrays.zerospixtix;
It              =   info.tem.helpers.arrays.zerospixtix;

%Rainintensity must be larger than evap rate
%adjusting evap rate:
v=f.RainInt < EvapRate & valids==1;
EvapRate(v)=f.RainInt(v);

%Pgc: amount of gross rainfall necessary to saturate the canopy
Pgc(valids)=-1.*( f.RainInt(valids) .* CanopyStorage(valids) ./ ((1- fte(valids) ) .* EvapRate(valids) )).*log(1-((1- fte(valids) ) .* EvapRate(valids) ./ f.RainInt(valids) ));

%Pgt: amount of gross rainfall necessary to saturate the trunks
Pgt(valids)=Pgc(valids) + f.RainInt(valids) .* St(valids) ./ ( pd(valids) .* f.FAPAR(valids) .* ( f.RainInt(valids) - EvapRate(valids) .* (1 - fte(valids) )));

%Ic: EvapInt loss from canopy
Ic1(valids) = f.FAPAR(valids) .* fe.rainSnow.rain(valids); %Pg < Pgc
Ic2(valids) = f.FAPAR(valids) .* (Pgc(valids)+((1- fte(valids) ) .* EvapRate(valids) ./ f.RainInt(valids) ) .* ( fe.rainSnow.rain(valids) - Pgc(valids))); %Pg > Pgc


v= fe.rainSnow.rain <= Pgc & valids==1;
Ic(v)=Ic1(v);
Ic(v==0)=Ic2(v==0);

%It: interception loss from trunks

%It1 = St;% Pg < Pgt
It2(valids) = pd(valids) .* f.FAPAR(valids) .* (1-(1 - fte(valids) ) .* EvapRate(valids) ./ f.RainInt(valids) ).*( fe.rainSnow.rain(valids) - Pgc(valids));%Pg > Pgt

v= fe.rainSnow.rain <= Pgt;
It(v) = St(v);
It(v==0)=It2(v==0);

tmp = Ic+It;
tmp(fe.rainSnow.rain == 0) = 0;

v=tmp > fe.rainSnow.rain;
tmp(v) = fe.rainSnow.rain(v);

fx.ECanop = tmp;


end