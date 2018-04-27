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
s.wSM       = info.params.SOIL.tAWC;
s.wSWE      = info.helper.zeros1d;
s.wGW       = info.helper.zeros1d;    
s.wGWR      = info.helper.zeros1d;
s.wWTD      = info.helper.zeros1d;
s.wFrSnow	= info.helper.zeros1d;
end % function

