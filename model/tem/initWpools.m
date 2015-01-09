function s = initWpools(s,info)
% #########################################################################
% FUNCTION	: 
% 
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: 
% 
% #########################################################################
% initial value for pools
S = zeros(info.forcing.size);

s.wSWE  = S;

s.wSM1	= S;
s.wSM2  = S;

s.wpSM1  = S; % SM1 of previous time step (deal with this later...)
s.wpSM2  = S; % SM2 of previous time step (deal with this later...)


s.wGW   = S;    
s.wGWR  = S;

s.wWTD  = S;

end % function

