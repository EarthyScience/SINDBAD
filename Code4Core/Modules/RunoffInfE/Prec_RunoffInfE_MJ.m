function [fe,fx,d,p]=Prec_RunoffInfE_MJ(f,fe,fx,s,d,p,info);


%we assume that infiltration capacity is unlimited in the vegetated
%fraction (infiltration flux = P*fpar)
%the infiltration flux for the unvegetated fraction is given as the minimum
%of the precip and the min of precip intensity (P) and infiltration
%capacity (I)
%scaled with rain duration (P/R)

%Qinf=P-(P.*fpar+(1-fpar).*min(P,min(I,R).*P./R));

fx.Qinf = f.Rain -( f.Rain .* f.FAPAR + (1 - f.FAPAR ) .* min( f.Rain ,min( p.SOIL.InfCapacity , f.RainInt ) .* f.Rain ./ f.RainInt ));



end

