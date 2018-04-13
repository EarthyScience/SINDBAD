function [f,fe,fx,s,d,p] = dyna_cAlloc_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: dyna_cAlloc_Friedlingstein1999
% 
% PURPOSE	: compute the fraction of NPP that is allocated to the
% different plant organs. It follows the scheme of Friedlingstein et al
% 1999 without the effects of CO2. Ultimately, the allocation to different
% pools is adjusted according to the TreeCover fraction
% (p.pveg.TreeCover). Allocation to roots is partitioned into
% fine (cf2Root) and coarse roots (cf2RootCoarse) according to
% p.cAlloc.Rf2Rc.
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
% 2813?2829, doi: 10.1111/j.1365-2486.2009.2173.x, 2010.
% 
% INPUT
% PET       : potential evapotranspiration [mm/time]
%           (f.PET)
% wSM      : soil moisture sum of all layers [mm]
%           (s.w.wSoil)
% 
% 
% CONTACT	: ncarval
% 
% 
% 
% #########################################################################

% constants
so      = p.cAlloc.so;
minL    = p.cAlloc.minL;
maxL    = p.cAlloc.maxL;
minL_fW = p.cAlloc.minL_fW;
maxL_fW = p.cAlloc.maxL_fW;
RelY    = p.cAlloc.RelY;

% precomputations
NL_fT	= d.cAlloc.NL_fT(:,tix);

% pseudo-nutrient limitation (NL) calculation: 
% "There is no explicit estimate of soil mineral nitrogen in the version of
% CASA used for these simulations. As a surrogate, we assume that spatial
% variability in nitrogen mineralization and soil organic matter
% decomposition are identical (Townsend et al. 1995). Nitrogen
% availability, N, is calculated as the product of the temperature and
% moisture abiotic factors used in CASA for the calculation of microbial
% respiration (Potter et al. 1993)." in Friedlingstein et al., 1999.

% computation for the moisture effect on decomposition/mineralization
% for t=1:size(LL,2)
%     LL(LL(:,t) <= minL,t)          = minL(LL(:,t) <= minL);
%     LL(LL(:,t) >= maxL,t)          = maxL(LL(:,t) >= maxL);
% end
NL_fW                   = d.cTaufwSoil.BGME(:,tix);
NL_fW(NL_fW >= maxL_fW)	= maxL_fW(NL_fW >= maxL_fW);
NL_fW(NL_fW <= minL_fW) = minL_fW(NL_fW <= minL_fW);

% estimate NL
NL              = d.cAlloc.NL(:,tix);
ndx             = f.PET(:,tix) > 0;
NL(ndx)         = NL_fT(ndx) .* NL_fW(ndx);
NL(NL <= minL)	= minL(NL <= minL);
NL(NL >= maxL)	= maxL(NL >= maxL);

% water limitation calculation
WL              = s.w.wSoil ./ d.cAlloc.WLDenominator;
WL(WL <= minL)	= minL(WL <= minL);
WL(WL >= maxL)  = maxL(WL >= maxL); %% check if maxL and minL should used maxL_fW?


% minimum of WL and NL
minWLNL             = NL;
minWLNL(WL < NL)	= WL(WL < NL);

% allocation to root, wood and leaf
d.cAlloc.cf2Root(:,tix)	= d.cAlloc.RootNumerator(:,tix) ./ (d.cAlloc.LL(:,tix) + RelY .* minWLNL);
d.cAlloc.cf2Wood(:,tix)	= so .* (RelY + 1) .* minWLNL ./ (RelY .* d.cAlloc.LL(:,tix) + minWLNL);
d.cAlloc.cf2Leaf(:,tix)	= 1 - d.cAlloc.cf2Root(:,tix) - d.cAlloc.cf2Wood(:,tix);

% adjust allocation
d	= calcAdjAllocation(f,fe,fx,s,d,p,info,tix);

% check allocation
checkcAlloc(f,fe,fx,s,d,p,info,tix);

end % function
