function [fx,s,d] = PutStates_simple(f,fe,fx,s,d,p,info,i)

% water pools
d.Temp.pwSM1	= s.wSM1(:,i);
d.Temp.pwSM2	= s.wSM2(:,i);
d.Temp.pwGW     = s.wGW(:,i);
d.Temp.pwGWR    = s.wGWR(:,i);
d.Temp.pwSWE    = s.wSWE(:,i);
d.Temp.pwWTD    = s.wWTD(:,i);


d.Temp.pSMScGPP = d.SMEffectGPP.SMScGPP(:,i);

end % function

