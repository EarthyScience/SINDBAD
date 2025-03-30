function [f,fe,fx,s,d,p] = prec_cAlloc_Fix(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% compute the fraction of NPP that is allocated to the
% different plant organs. In this case, the allocation is fixed in time
% according to the parameters in p.cAlloc. These parameters are
    % adjusted according to the TreeFrac fraction
    % (p.pveg.TreeFrac). Allocation to roots is partitioned into
% fine (cf2Root) and coarse roots (cf2RootCoarse) according to
% p.cAlloc.Rf2Rc.
%
% Inputs:
%   - p.cAlloc: fraction of NPP that is allocated to the
% different plant organs
%
% Outputs:
%   - s.cd.cAlloc: the fraction of NPP that is allocated to the different plant organs 
%
% Modifies:
%   - s.cd.cAlloc
%
% References:
% - Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
%   Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
%   production: A process model based on global satellite and surface data. 
%   Global Biogeochemical Cycles. 7: 811-841.
% 
% - Carvalhais, N., Reichstein, M., Ciais, P., Collatz, G., Mahecha, M. D.,
%   Montagnani, L., Papale, D., Rambal, S., and Seixas, J.: Identification of
%   Vegetation and Soil Carbon Pools out of Equilibrium in a Process Model
%   via Eddy Covariance and Biometric Constraints, Glob. Change Biol., 16,
%   2813?2829, doi: 10.1111/j.1365-2486.2009.2173.x, 2010.%
%
% Created by:
%   - ncarvalhais
%
% Versions:
%   - 1.0 on 12.01.2020 (sbesnard)
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

end
