function [fe,fx,d,p] = Prec_CAllocationVeg_Fix(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: Prec_CAllocationVeg_Fix
% 
% PURPOSE	: compute the fraction of NPP that is allocated to the
% different plant organs. In this case, the allocation is fixed in time
% according to the parameters in p.CAllocationVeg. These parameters are
% adjusted according to the TreeCover fraction
% (p.VEG.TreeCover). Allocation to roots is partitioned into
% fine (cf2Root) and coarse roots (cf2RootCoarse) according to
% p.CAllocationVeg.Rf2Rc.
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
% 2813–2829, doi: 10.1111/j.1365-2486.2009.2173.x, 2010.
% 
% CONTACT	: Nuno
% 
% #########################################################################

% % make vectors/matrices
% for ii = {'cf2Root','cf2Wood','cf2Leaf'}
%     d.CAllocationVeg.(ii{1})	= p.CAllocationVeg.(ii{1}) .* ones(size(f.Tair));
% end

% adjust allocation
fe	= adjAllocation(f,fe,fx,s,d,p,info);

% check allocation
checkCAllocationVeg(f,fe,fx,s,d,p,info);

% check allocation again:
% only makes sense for fixed allocation scheme - dynamic allocation may not
% allocate to wood depending on resources or parameterization
% check that is consistent with the vegetation form that is being simulated
% if TreeCover is higher then 0 we need to allocate carbon to cWood -
% hmmmmm do we really??? yes, because is the FIX allocation...
if any(d.CAllocationVeg.cf2Wood(p.VEG.TreeCover > 0) == 0)
    error('SINDBAD : Prec_CAllocationVeg_Fix : TreeCover > 0 & CAllocationVeg.cf2Wood == 0')
end
% if Treecover is 0 we cannot allocate carbon to cWood
if any(p.CAllocationVeg.cf2Wood(p.VEG.TreeCover == 0) > 0)
    error('SINDBAD : Prec_CAllocationVeg_Fix : TreeCover == 0 & CAllocationVeg.cf2Wood > 0')
end


end % function
