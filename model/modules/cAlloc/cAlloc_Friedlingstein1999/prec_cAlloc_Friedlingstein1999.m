function [f,fe,fx,s,d,p] = prec_cAlloc_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: prec_cAlloc_Friedlingstein1999

% s.cd.cAlloc=zeros(pix,zix);
% s.cd.cAlloc     =   info.tem.helpers.arrays.zerospixzix.c.cEco; %sujan
d.cAlloc.cAlloc	= repmat(info.tem.helpers.arrays.zerospixzix.c.cEco,1,1,info.tem.helpers.sizes.nTix);
end % function

