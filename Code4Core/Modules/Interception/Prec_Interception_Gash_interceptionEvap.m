function [fe,fx,d]=Prec_Interception_Gash_interceptionEvap(f,fe,fx,s,d,p,info);

%works per rain event. here we assume that we have one rain event per day

%defaults in square brackets from Mirales et al 2010
%fi.Rainfall: gross precip [mm]
%fi.RainInt: rainfall rate (mm/hr) [1.5 or 5.6 for synoptic or convective]
%p.Interception.CanopyStorage: Canopy storage (mm) [1.2]
%p.Interception.fte: fraction of trunk evaporation [0.02]
%p.Interception.EvapRate: mean evaporation rate (mm/hr) [0.3]
%p.Interception.St: trunk capacity (mm) [0.02]
%p.Interception.pd: fraction rain to trunks [0.02]
%c: canopy cover [0-1]




%Pgc: amount of gross rainfall necessary to saturate the canopy
Pgc=-1.*(f.RainInt.*p.Interception.CanopyStorage./((1-p.Interception.fte).*p.Interception.EvapRate)).*log(1-((1-p.Interception.fte).*p.Interception.EvapRate./f.RainInt));

%Pgt: amount of gross rainfall necessary to saturate the trunks
Pgt=Pgc + f.RainInt.*p.Interception.St./(p.Interception.pd.*f.FAPAR.*(f.RainInt-p.Interception.EvapRate.*(1-p.Interception.fte)));

%Ic: Interception loss from canopy
Ic1=f.FAPAR.*f.Rain; %Pg < Pgc
Ic2 = f.FAPAR.*(Pgc+((1-p.Interception.fte).*p.Interception.EvapRate./f.RainInt).*(f.Rain-Pgc)); %Pg > Pgc

Ic = zeros(info.Forcing.Size);
v=f.Rain <= Pgc;
Ic(v)=Ic1(v);
Ic(v==0)=Ic2(v==0);

%It: interception loss from trunks

%It1 = St;% Pg < Pgt
It2 = p.Interception.pd.*f.FAPAR.*(1-(1-p.Interception.fte).*p.Interception.EvapRate./f.RainInt).*(f.Rain-Pgc);%Pg > Pgt

It=f.Rain.*0;
v=f.Rain <= Pgt;
It(v)=p.Interception.St;
It(v==0)=It2(v==0);

fx.ECanop=Ic+It;


end