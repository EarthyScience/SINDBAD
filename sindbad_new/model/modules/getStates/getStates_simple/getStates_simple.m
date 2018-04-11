function [fx,s,d,f] = getStates_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: initialize the states for the current time steps from the
% d.tmp.... variable
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
% s.w.wSoil(:,tix)  = s.prev.wSM;
% s.w.wGW(:,tix)  = s.prev.wGW;
% s.wd.wGWR(:,tix) = s.prev.wGWR;
% s.w.wSnow(:,tix) = s.prev.wSWE;
% s.wd.WTD(:,tix) = s.prev.WTD;

% Water Balance Pool
s.wd.WBP  = f.Rain(:,tix);



end % function

