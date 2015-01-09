function [fe,fx,d,p]=Prec_TempEffectGPP_Maekelae2008(f,fe,fx,s,d,p,info);

%p.TempEffectGPP.TimConst between 1 and 20 days; guessed median =5
%p.TempEffectGPP.X0 [-15 1]; median ~-5
%p.TempEffectGPP.Smax between 11 and 30, median ~20

TimConst = repmat( p.TempEffectGPP.TimConst ,1,info.forcing.size(2));
X0 = repmat( p.TempEffectGPP.X0 ,1,info.forcing.size(2));
Smax = repmat( p.TempEffectGPP.Smax ,1,info.forcing.size(2));
%acclimation
X = f.TairDay;
for ii=2:length(X(1,:));
    X(:,ii)=X(:,ii-1) + 1 / TimConst .* (f.TairDay(:,ii) - X(:,ii-1));
end

S = max(X - X0 ,0);
vsc=min(S ./ Smax ,1);

d.TempEffectGPP.TempScGPP = vsc;

end