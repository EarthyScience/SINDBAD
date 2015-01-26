function [fx,s,d] = CAllocationVeg_Friedlingstein(f,fe,fx,s,d,p,info,i)
% #########################################################################
% FUNCTION	: CAllocationVeg_Friedlingstein
% 
% PURPOSE	: compute the fraction of NPP that is allocated to the
% different plant organs. It follows the scheme of Friedlingstein et al
% 1999 without the effects of CO2. Ultimately, the allocation to different
% pools is adjusted according to the TreeCover fraction
% (p.VEG.TreeCover). Allocation to roots is partitioned into
% fine (cf2Root) and coarse roots (cf2RootCoarse) according to
% p.CAllocationVeg.Rf2Rc.
% 
% REFERENCES:
% Friedlingstein, P., Joel, G., Field, C. B., and Fung, I. Y., Toward an
% allocation scheme for global terrestrial carbon models, Global Change
% Biology, 5, 755-770, 1999
% 
% Carvalhais, N., Reichstein, M., Ciais, P., Collatz, G., Mahecha, M. D.,
% Montagnani, L., Papale, D., Rambal, S., and Seixas, J.: Identification of
% Vegetation and Soil Carbon Pools out of Equilibrium in a Process Model
% via Eddy Covariance and Biometric Constraints, Glob. Change Biol., 16,
% 2813–2829, doi: 10.1111/j.1365-2486.2009.2173.x, 2010.
% 
% INPUT
% PET       : potential evapotranspiration [mm/time]
%           (f.PET)
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% wSM2      : soil moisture of bottom layer [mm]
%           (s.wSM2)
% 
% 
% CONTACT	: ncarval
% 
% 
% 
% #########################################################################

% constants
so      = p.CAllocationVeg.so;
minL    = p.CAllocationVeg.minL;
maxL    = p.CAllocationVeg.maxL;
minL_fW = p.CAllocationVeg.minL_fW;
maxL_fW = p.CAllocationVeg.maxL_fW;
RelY    = p.CAllocationVeg.RelY;

% precomputations
NL_fT	= d.CAllocationVeg.NL_fT(:,i);

% pseudo-nutrient limitation (NL) calculation: 
% "There is no explicit estimate of soil mineral nitrogen in the version of
% CASA used for these simulations. As a surrogate, we assume that spatial
% variability in nitrogen mineralization and soil organic matter
% decomposition are identical (Townsend et al. 1995). Nitrogen
% availability, N, is calculated as the product of the temperature and
% moisture abiotic factors used in CASA for the calculation of microbial
% respiration (Potter et al. 1993)." in Friedlingstein et al., 1999.

% computation for the moisture effect on decomposition/mineralization
NL_fW                   = d.SoilMoistEffectRH.BGME(:,i);
NL_fW(NL_fW >= maxL_fW)	= maxL_fW;
NL_fW(NL_fW <= minL_fW) = minL_fW;

% estimate NL
NL              = d.CAllocationVeg.NL(:,i);
ndx             = f.PET(:,i) > 0;
NL(ndx)         = NL_fT(ndx) .* NL_fW(ndx);
NL(NL <= minL)	= minL;
NL(NL >= maxL)	= maxL;

% water limitation calculation
WL              = (s.wSM1 + s.wSM2) ./ d.CAllocationVeg.WLDenominator;
WL(WL <= minL)	= minL;
WL(WL >= maxL)  = maxL;

% minimum of WL and NL
minWLNL             = NL;
minWLNL(WL < NL)	= WL(WL < NL);

% allocation to root, wood and leaf
d.CAllocationVeg.cf2Root(:,i)	= d.CAllocationVeg.RootNumerator(:,i) ./ (d.CAllocationVeg.LL(:,i) + RelY .* minWLNL);
d.CAllocationVeg.cf2Wood(:,i)	= so .* (RelY + 1) .* minWLNL ./ (RelY .* d.CAllocationVeg.LL(:,i) + minWLNL);
d.CAllocationVeg.cf2Leaf(:,i)	= 1 - d.CAllocationVeg.cf2Root(:,i) - d.CAllocationVeg.cf2Wood(:,i);

% adjust allocation
d	= adjAllocation(f,fe,fx,s,d,p,info,i);

% check allocation
checkCAllocationVeg(f,fe,fx,s,d,p,info,i);


end % function
