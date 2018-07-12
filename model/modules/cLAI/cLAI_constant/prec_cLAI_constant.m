function [f,fe,fx,s,d,p]=prec_cLAI_constant(f,fe,fx,s,d,p,info)
d.cLAI.LAI = info.tem.helpers.arrays.onespixtix .* p.cLAI.constantLAI;    
% d.cLAI.LAI = repmat(1:1:size(info.tem.helpers.arrays.onespixtix,2),size(info.tem.helpers.arrays.onespixtix,1),1) ; %.* p.cLAI.constantLAI;    
end