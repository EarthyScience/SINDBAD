function [fe,fx,d]=Prec_TempEffectGPP_Maekelae2008(f,fe,fx,s,d,p,info);

%p.TempEffectGPP.TimConst between 1 and 20 days; guessed median =5
%p.TempEffectGPP.X0 [-15 1]; median ~-5
%p.TempEffectGPP.Smax between 11 and 30, median ~20

%acclimation
X=f.TairDay;
for ii=2:length(X);
    X(ii)=X(ii-1)+1/p.TempEffectGPP.TimConst.*(f.TairDay(ii)-X(ii-1));
end

S=max(X-p.TempEffectGPP.X0,0);
vsc=min(S./p.TempEffectGPP.Smax,1);

d.TempEffectGPP.TempScGPP = vsc;

end