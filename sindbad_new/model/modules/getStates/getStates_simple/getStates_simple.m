function [fx,s,d] = getStates_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: initialize the states for the current time steps from the
% d.Temp.... variable
% 
% REFERENCES:
% 
% CONTACT	: ncarval; mjung
% 
% INPUT
% 
% OUTPUT
% 
% NOTES:
% 
% #########################################################################

% water pools
% s.wSM(:,tix)  = d.Temp.pwSM;
% s.wGW(:,tix)  = d.Temp.pwGW;
% s.wGWR(:,tix) = d.Temp.pwGWR;
% s.wSWE(:,tix) = d.Temp.pwSWE;
% s.wWTD(:,tix) = d.Temp.pwWTD;

% Water Balance Pool
d.Temp.WBP  = f.Rain(:,tix);



end % function

