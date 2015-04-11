function s = initSMpools(info,s)
% #########################################################################
% FUNCTION	: initWpools
% 
% PURPOSE	: initialize the variable that holds the soil water pools 
% 
% REFERENCES:
% 
% CONTACT	: Martin
% 
% #########################################################################
% # of layers in the soil: 
N           = numel(info.params.SOIL.AWC); 
% start the structure
s.smPools	= struct;
for ij = 1:N
    s.smPools(ij).value = info.params.SOIL.AWC(ij).value;
    s.smPools(ij).name	= ['SMLayer' num2str(ij)];
end

end % function
