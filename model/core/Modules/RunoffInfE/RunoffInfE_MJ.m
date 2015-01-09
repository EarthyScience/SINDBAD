function [fx,s,d]=RunoffInfE_MJ(f,fe,fx,s,d,p,info,i);


%we assume that infiltration capacity is unlimited in the vegetated
%fraction (infiltration flux = P*fpar)
%the infiltration flux for the unvegetated fraction is given as the minimum
%of the precip and the min of precip intensity (P) and infiltration
%capacity (I)
%scaled with rain duration (P/R)

%Qinf=P-(P.*fpar+(1-fpar).*min(P,min(I,R).*P./R));

%fx.Qinf(:,i)=f.Rain(:,i)-(f.Rain(:,i).*f.FAPAR(:,i)+(1-f.FAPAR(:,i)).*min(f.Rain(:,i),min(p.SOIL.InfCapacity,f.RainInt(:,i)).*f.Rain(:,i)./f.RainInt(:,i)));
%is precomputed
d.Temp.WBdum(:,i) = d.Temp.WBdum(:,i) - fx.Qinf(:,i);

end