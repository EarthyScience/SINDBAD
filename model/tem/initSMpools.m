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
N           = numel(info.params.SOIL.HeightLayer); 
% total soil depth
tSLDP = zeros(info.forcing.size(1),1);
for ij = 1:N
    tSLDP	= tSLDP + info.params.SOIL.HeightLayer(ij).value;
end
% start the structure
s.smPools	= struct;
for ij = 1:N
    s.smPools(ij).value = info.params.SOIL.iniAWC .* info.params.SOIL.HeightLayer(ij).value ./ tSLDP;
    s.smPools(ij).name	= ['SMLayer' num2str(ij)];
end

end % function
