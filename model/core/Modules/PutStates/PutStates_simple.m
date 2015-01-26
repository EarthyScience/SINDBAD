function [fx,s,d] = PutStates_simple(f,fe,fx,s,d,p,info,i)

% water pools
d.Temp.pwSM1	= s.wSM1;
d.Temp.pwSM2	= s.wSM2;
d.Temp.pwGW     = s.wGW;
d.Temp.pwGWR    = s.wGWR;
d.Temp.pwSWE    = s.wSWE;
%d.Temp.pwWTD    = s.wWTD;


d.Temp.pSMScGPP = d.SMEffectGPP.SMScGPP(:,i);

end % function

