function [fe,fx,d,p] = Prec_CAllocationVeg_Friedlingstein(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: Prec_CAllocationVeg_Friedlingstein
% 
% PURPOSE	: compute the fraction of NPP that is allocated to the
% different plant organs following the scheme of Friedlingstein et al 1999.
% Check CAllocationVeg_Friedlingstein for details.
% 
% INPUT
% PET       : potential evapotranspiration [mm/time]
%           (f.PET)
% AWC1      : maximum plant available water content in the top layer [mm]
%           (p.SOIL.AWC1)
% AWC2      : maximum plant available water content in the bottom layer [mm]
%           (p.SOIL.AWC2)
% #########################################################################

% constants
ro      = p.CAllocationVeg.ro;
kext	= p.CAllocationVeg.kext;
minL    = p.CAllocationVeg.minL;
maxL    = p.CAllocationVeg.maxL;
minL_fT = p.CAllocationVeg.minL_fT;
maxL_fT = p.CAllocationVeg.maxL_fT;
RelY    = p.CAllocationVeg.RelY;

% light limitation (LL) calculation
LL                      = exp (-kext * f.LAI); 
LL(LL <= minL)          = minL;
LL(LL >= maxL)          = maxL;
% send it to d
d.CAllocationVeg.LL	= LL;

% pseudo-nutrient limitation (NL) calculation: 
% "There is no explicit estimate of soil mineral nitrogen in the version of
% CASA used for these simulations. As a surrogate, we assume that spatial
% variability in nitrogen mineralization and soil organic matter
% decomposition are identical (Townsend et al. 1995). Nitrogen
% availability, N, is calculated as the product of the temperature and
% moisture abiotic factors used in CASA for the calculation of microbial
% respiration (Potter et al. 1993)." in Friedlingstein et al., 1999.

% partial computation for the temperature effect on
% decomposition/mineralization
NL_fT                   = fe.TempEffectRH.fT;
NL_fT(NL_fT >= maxL_fT)	= maxL_fT;
NL_fT(NL_fT <= minL_fT) = minL_fT;
% send it to d
d.CAllocationVeg.NL_fT	= NL_fT;

% start computation of pseudo NL
NL                      = minL.*ones(size(f.PET));
% send it to d
d.CAllocationVeg.NL	= NL;

% numerator of the root allocation function
d.CAllocationVeg.RootNumerator	= ro .* (RelY + 1) .* LL;

% denominator of the water limitation fuction
d.CAllocationVeg.WLDenominator	= p.SOIL.AWC1 + p.SOIL.AWC2;

end % function
