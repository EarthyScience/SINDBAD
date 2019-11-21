function [f,fe,fx,s,d,p] = cAllocfNut_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)


% pseudo-nutrient limitation (NL) calculation: 
% "There is no explicit estimate of soil mineral nitrogen in the version of
% CASA used for these simulations. As a surrogate, we assume that spatial
% variability in nitrogen mineralization and soil organic matter
% decomposition are identical (Townsend et al. 1995). Nitrogen
% availability, N, is calculated as the product of the temperature and
% moisture abiotic factors used in CASA for the calculation of microbial
% respiration (Potter et al. 1993)." in Friedlingstein et al., 1999.


% estimate NL
NL                          = p.cAllocfNut.minL.*ones(size(f.PET(:,tix)));
ndx                         = f.PET(:,tix) > 0;
NL(ndx)                     = fe.cAllocfTsoil.NL_fT(ndx) .* d.cAllocfwSoil.NL_fW(ndx);
NL(NL <= p.cAllocfNut.minL)	= p.cAllocfNut.minL;%(NL <= p.cAllocfNut.minL);
NL(NL >= p.cAllocfNut.maxL)	= p.cAllocfNut.maxL;%(NL >= p.cAllocfNut.maxL);
%sujan NL(NL <= p.cAllocfNut.minL)	= p.cAllocfNut.minL(NL <= p.cAllocfNut.minL);
%sujan NL(NL >= p.cAllocfNut.maxL)	= p.cAllocfNut.maxL(NL >= p.cAllocfNut.maxL);

% sujan consider root fractions
% water limitation calculation
WL                          = sum(s.w.wSoil *. fe.wSoilBase.fracRoot2SoilD,2) ./ sum(fe.wSoilBase.sAWC .* fe.wSoilBase.fracRoot2SoilD,2);
% WL                          = sum(s.w.wSoil,2) ./ sum(fe.wSoilBase.sAWC,2);
WL(WL <= p.cAllocfNut.minL)	= p.cAllocfNut.minL;%(WL <= p.cAllocfNut.minL);
WL(WL >= p.cAllocfNut.maxL) = p.cAllocfNut.maxL;%(WL >= p.cAllocfNut.maxL); %% check if p.cAlloc.maxL and p.cAlloc.minL should used p.cAlloc.maxL_fW?
%sujan WL(WL <= p.cAllocfNut.minL)	= p.cAllocfNut.minL(WL <= p.cAllocfNut.minL);
%sujan WL(WL >= p.cAllocfNut.maxL) = p.cAllocfNut.maxL(WL >= p.cAllocfNut.maxL); %% check if p.cAlloc.maxL and p.cAlloc.minL should used p.cAlloc.maxL_fW?


% minimum of WL and NL
minWLNL             = NL;
minWLNL(WL < NL)	= WL(WL < NL);

fe.cAllocfNut.minWLNL(:,tix) = minWLNL;
end % function
