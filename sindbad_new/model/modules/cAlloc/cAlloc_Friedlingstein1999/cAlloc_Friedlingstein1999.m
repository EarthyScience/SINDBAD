function [f,fe,fx,s,d,p] = cAlloc_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: prec_cAlloc_Friedlingstein1999
% 
% PURPOSE	: compute the fraction of NPP that is allocated to the
% different plant organs following the scheme of Friedlingstein et al 1999.
% Check cAlloc_Friedlingstein1999 for details.
% 
% INPUT
% PET       : potential evapotranspiration [mm/time]
%           (f.PET)
% tAWC      : total maximum plant available water content [mm]
%           (p.psoil.tAWC)
% #########################################################################

% allocation to root, wood and leaf
cf2.cVegRoot	= p.cAlloc.ro .* (p.cAlloc.RelY + 1) .* fe.cAllocfLAI.LL(:,tix) ./ (fe.cAllocfLAI.LL(:,tix) + p.cAlloc.RelY .* fe.cAllocfNut.minWLNL(:,tix));
cf2.cVegWood	= p.cAlloc.so .* (p.cAlloc.RelY + 1) .* fe.cAllocfNut.minWLNL(:,tix) ./ (p.cAlloc.RelY .* fe.cAllocfLAI.LL(:,tix) + fe.cAllocfNut.minWLNL(:,tix));
cf2.cVegLeaf	= 1 - cf2.cVegRoot - cf2.cVegWood;

% distribute the allocation according to pools...
cpNames = {'cVegRoot','cVegWood','cVegLeaf'};
for cpn = 1:numel(cpnames)
    zixVec = info.tem.model.variables.states.c.(cpNames{cpn}).zix;
    N      = numel(zixVec);
    for zix = zixVec
        s.cd.cAlloc(:,zix)	= cf2.(cpNames{cpn}) ./ N;
    end
end

% check allocation...
if any(s.cd.cAlloc > 1) || any(s.cd.cAlloc < 0)
    error('SINDBAD : TEM : cAlloc : s.cd.cAlloc < 0 | s.cd.cAlloc > 1')
end
if any(abs(sum(s.cd.cAlloc,2)-1)>1E-10)
    error('SINDBAD : TEM : cAlloc : s.cd.cAlloc : sum(cAlloc) ~= 1')
end
end % function

