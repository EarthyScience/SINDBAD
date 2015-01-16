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


s.wGW   = S;    
s.wGWR  = S;

s.wWTD  = S;

end % function

