function [fx,s,d] = PutStates_simple(f,fe,fx,s,d,p,info,i)

% water pools
d.Temp.pwSM	    = s.wSM;
d.Temp.pwGW     = s.wGW;
d.Temp.pwGWR    = s.wGWR;
d.Temp.pwSWE    = s.wSWE;
%d.Temp.pwWTD    = s.wWTD;


d.Temp.pSMScGPP = d.SMEffectGPP.SMScGPP(:,i);

end % function

