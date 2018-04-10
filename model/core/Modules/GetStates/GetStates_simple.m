function [fx,s,d] = GetStates_simple(f,fe,fx,s,d,p,info,i)
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
% s.wSM(:,i)  = d.Temp.pwSM;
% s.wGW(:,i)  = d.Temp.pwGW;
% s.wGWR(:,i) = d.Temp.pwGWR;
% s.wSWE(:,i) = d.Temp.pwSWE;
% s.wWTD(:,i) = d.Temp.pwWTD;

% Water Balance Pool
d.Temp.WBP  = f.Rain(:,i);



end % function

