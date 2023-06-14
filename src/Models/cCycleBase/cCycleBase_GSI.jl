export cCycleBase_GSI

@bounds @describe @units @with_kw struct cCycleBase_GSI{T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12} <: cCycleBase
	annk_Root::T1 = 1.0 | (0.05, 3.3) | "turnover rate of root carbon pool" | "yr-1"
	annk_Wood::T2 = 0.03 | (0.001, 10.0) | "turnover rate of wood carbon pool" | "yr-1"
	annk_Leaf::T3 = 1.0 | (0.05, 10.0) | "turnover rate of leaf carbon pool" | "yr-1"
	annk_Reserve::T4 = 1.0e-11 | (1.0e-12, 1.0) | "Reserve does not respire, but has a small value to avoid  numerical error" | "yr-1"
	annk_LitSlow::T5 = 3.9 | (0.39, 39.0) | "turnover rate of slow litter carbon (wood litter) pool" | "yr-1"
	annk_LitFast::T6 = 14.8 | (0.5, 148.0) | "turnover rate of fast litter (leaf litter) carbon pool" | "yr-1"
	annk_SoilSlow::T7 = 0.2 | (0.02, 2.0) | "turnover rate of slow soil carbon pool" | "yr-1"
	annk_SoilOld::T8 = 0.0045 | (0.00045, 0.045) | "turnover rate of old soil carbon pool" | "yr-1"
	cFlowA::T9 = Float64[-1.0 0.0 0.0 0 0.0 0.0 0.0 0.0
	    0.0 -1.0 0.0 0.0 0 0.0 0.0 0.0
	    0.0 0.0 -1.0 0.0 0.0 0 0.0 0.0
	    0.0 0.0 0 -1.0 0.0 0.0 0.0 0.0
	    1.0 0.0 1.0 0.0 -1.0 0.0 0.0 0.0
	    0.0 1.0 0.0 0.0 0 -1.0 0.0 0.0
	    0.0 0.0 0 0.0 1.0 1.0 -1.0 0.0
	    0.0 0.0 0 0.0 0.0 0.0 1.0 -1.0] | nothing | "Transfer matrix for carbon at ecosystem level" | ""
	C2Nveg::T10 = Float64[25.0, 260.0, 260.0, 10.0] | nothing | "carbon to nitrogen ratio in vegetation pools" | "gC/gN"
	etaH::T11 = 1.0 | (0.01, 100.0) | "scaling factor for heterotrophic pools after spinup" | ""
	etaA::T12 = 1.0 | (0.01, 100.0) | "scaling factor for vegetation pools after spinup" | ""
end

function precompute(o::cCycleBase_GSI, forcing, land, helpers)
    @unpack_cCycleBase_GSI o
	@unpack_land begin
		numType ∈ helpers.numbers
		𝟙 ∈ helpers.numbers
		cEco ∈ land.pools
	end
    ## instantiate variables
    p_C2Nveg = zero(cEco) #sujan
	vegZix = getzix(land.pools.cVeg, helpers.pools.zix.cVeg)
	for vg in vegZix
        @rep_elem C2Nveg[vg] => (p_C2Nveg, vg, :cEco)
	end
    # p_C2Nveg[getzix(land.pools.cVeg, helpers.pools.zix.cVeg)] .= C2Nveg
    cEcoEfflux = zero(cEco) #sujan moved from get states
	p_k_base = zero(cEco)
    p_annk = (annk_Root, annk_Wood, annk_Leaf, annk_Reserve, annk_LitSlow, annk_LitFast, annk_SoilSlow, annk_SoilOld)
	for i in eachindex(p_k_base)
		tmp = 𝟙 - (exp(-p_annk[i])^(𝟙 / helpers.dates.nStepsYear))
        @rep_elem tmp => (p_k_base, i, :cEco)
	end
    ## pack land variables
    @pack_land begin
		(p_C2Nveg, cFlowA, p_k_base, p_annk) => land.cCycleBase
		cEcoEfflux => land.states
	end
    return land
end

@doc """
Compute carbon to nitrogen ratio & annual turnover rates

# Parameters
$(PARAMFIELDS)

---

# compute:
Pool structure of the carbon cycle using cCycleBase_GSI

*Inputs*
 - annk: turnover rate of ecosystem carbon pools

*Outputs*
 - land.cCycleBase.p_annk _Pool: turnover rate of each ecosystem carbon pool

# precompute:
precompute/instantiate time-invariant variables for cCycleBase_GSI


---

# Extended help

*References*
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions*
 - 1.0 on 28.02.2020 [skoirala]  

*Created by:*
 - ncarvalhais
"""
cCycleBase_GSI