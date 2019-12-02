function [f,fe,fx,s,d,p] = prec_cAlloc_Fix(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% FUNCTION    : prec_cAlloc_Fix
% 
% PURPOSE    : compute the fraction of NPP that is allocated to the
% different plant organs. In this case, the allocation is fixed in time
% according to the parameters in p.cAlloc. These parameters are
% adjusted according to the TreeCover fraction
% (p.pveg.TreeCover). Allocation to roots is partitioned into
% fine (cf2Root) and coarse roots (cf2RootCoarse) according to
% p.cAlloc.Rf2Rc.
% 
% REFERENCES:
% Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
% Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
% production: A process model based on global satellite and surface data. 
% Global Biogeochemical Cycles. 7: 811-841.
% 
% Carvalhais, N., Reichstein, M., Ciais, P., Collatz, G., Mahecha, M. D.,
% Montagnani, L., Papale, D., Rambal, S., and Seixas, J.: Identification of
% Vegetation and Soil Carbon Pools out of Equilibrium in a Process Model
% via Eddy Covariance and Biometric Constraints, Glob. Change Biol., 16,
% 2813?2829, doi: 10.1111/j.1365-2486.2009.2173.x, 2010.
% 
% CONTACT    : Nuno
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% % make vectors/matrices
% for ii = {'cf2Root','cf2Wood','cf2Leaf'}
%     d.cAlloc.(ii{1})    = p.cAlloc.(ii{1}) .* ones(size(f.Tair));
% end
s.cd.cAlloc = info.tem.helpers.arrays.zerospixzix.c.cEco;
% distribute the allocation according to pools...
cpNames = {'cVegRoot','cVegWood','cVegLeaf'};
for cpn = 1:numel(cpNames)
    zixVec = info.tem.model.variables.states.c.zix.(cpNames{cpn});
    N      = numel(zixVec);
    for zix = zixVec
        s.cd.cAlloc(:,zix)    = p.cAlloc.(cpNames{cpn}) ./ N .* info.tem.helpers.arrays.onespix;
    end
end

% check allocation again:
% check allocation...
% check allocation...
% the following will need to move to the checks module that is not implemented yet
tmp0 = s.cd.cAlloc(:); %sujan
tmp1 = sum(s.cd.cAlloc,2);
if any(tmp0 > 1) || any(tmp0 < 0)
     error('SINDBAD TEM prec_cAlloc_Fix: cAlloc lt 0 or gt 1')
%      error('SINDBAD TEM dyna_cAlloc_Friedlingstein1999: cAlloc lt 0 or gt 1')
end
if any(abs(sum(tmp1,2)-1) > 1E-6)
      error('SINDBAD TEM prec_cAlloc_Fix: sum(cAlloc) ne1')
%      warning('SINDBAD TEM dyna_cAlloc_Friedlingstein1999: sum(cAlloc) ne 1')
end
end
