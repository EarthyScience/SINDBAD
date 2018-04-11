function [fe,fx,d,p] = prec_cAlloc_Friedlingstein1999(f,fe,fx,s,d,p,info)
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

% constants
ro      = p.cAlloc.ro;
kext	= p.cAlloc.kext;
minL    = p.cAlloc.minL;
maxL    = p.cAlloc.maxL;
minL_fT = p.cAlloc.minL_fT;
maxL_fT = p.cAlloc.maxL_fT;
RelY    = p.cAlloc.RelY;

% light limitation (LL) calculation
LL                      = exp (-kext .* f.LAI); 
for t=1:size(LL,2)
    LL(LL(:,t) <= minL,t)          = minL(LL(:,t) <= minL);
    LL(LL(:,t) >= maxL,t)          = maxL(LL(:,t) >= maxL);
end
% send it to d
d.cAlloc.LL	= LL;

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

NL_fT                   = fe.RHfTsoil.fT;
for t=1:size(LL,2)
NL_fT(NL_fT(:,t) >= maxL_fT,t)	= maxL_fT(NL_fT(:,t) >= maxL_fT);
NL_fT(NL_fT(:,t) <= minL_fT,t) = minL_fT(NL_fT(:,t) <= minL_fT);
end
% send it to d
d.cAlloc.NL_fT	= NL_fT;

% start computation of pseudo NL
NL                      = minL.*ones(size(f.PET));
% send it to d
d.cAlloc.NL	= NL;

% numerator of the root allocation function
d.cAlloc.RootNumerator	= ro .* (RelY + 1) .* LL;

% denominator of the water limitation fuction
d.cAlloc.WLDenominator	= p.psoil.tAWC;

end % function
