function [fe,fx,d,p]=Prec_Sublimation_GLEAM_PTterm(f,fe,fx,s,d,p,info);

%precompute PT term

%TairC temperature in C
%P: air pressure kPa

%PTterm=(fei.Delta./(fei.Delta+fei.Gamma))./fei.Lambda

T = f.TairDay + 273.15;
%from Diego miralles
%The majority of the parameters I use in GLEAM come from the equations in Murphy and Koop (2005) here attached.
%The slope of the vapour pressure over ice versus temperature curve (Delta) is obtained from eq. (7). You may want to do this derivative yourself because my calculus is not as good as it used to; what I get is:
Delta = (5723.265./T.^2 + 3.53068./(T-0.00728332)).* exp(9.550426-5723.265./T + 3.53068.*log(T) - 0.00728332.*T);
%;That you can convert from [Pa/K] to [kPa/K] by multiplying times 0.001.
Delta=Delta.*0.001;

%The latent heat of sublimation of ice (Lambda) can be found in eq. (5):
Lambda = 46782.5 + 35.8925.*T - 0.07414.*T.^2 + 541.5 * exp(-(T./123.75).^2);

%To convert from [J/mol] to [MJ/kg] I assume a molecular mass of water of 18.01528 g/mol:
Lambda=Lambda.*0.000001./(18.01528.*0.001);

%Then the psychrometer 'constant' (Gamma) can be calculated in [kPa/K] according to Brunt [1952] as:
%Where P is the air pressure in [kPa], which I consider as a function of the elevation (DEM) but can otherwise be set to 101.3, and ca is the specific heat of air which I assume 0.001 MJ/kg/K.
%ca=101.3
pa=0.001; %MJ/kg/K
Gamma = f.PsurfDay .* pa./(0.622.*Lambda);

fe.PTtermSub = repmat( p.Sublimation.alpha ,1,info.forcing.size(2)) .*(Delta./(Delta+Gamma))./Lambda;

end