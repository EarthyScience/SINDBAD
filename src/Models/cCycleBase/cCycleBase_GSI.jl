export cCycleBase_GSI, adjust_and_pack_pool_components

#! format: off
@bounds @describe @units @with_kw struct cCycleBase_GSI{T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13} <: cCycleBase
    annk_Root::T1 = 1.0 | (0.05, 3.3) | "turnover rate of root carbon pool" | "yr-1"
    annk_Wood::T2 = 0.03 | (0.001, 10.0) | "turnover rate of wood carbon pool" | "yr-1"
    annk_Leaf::T3 = 1.0 | (0.05, 10.0) | "turnover rate of leaf carbon pool" | "yr-1"
    annk_Reserve::T4 = 1.0e-11 | (1.0e-12, 1.0) | "Reserve does not respire, but has a small value to avoid  numerical error" | "yr-1"
    annk_LitSlow::T5 = 3.9 | (0.39, 39.0) | "turnover rate of slow litter carbon (wood litter) pool" | "yr-1"
    annk_LitFast::T6 = 14.8 | (0.5, 148.0) | "turnover rate of fast litter (leaf litter) carbon pool" | "yr-1"
    annk_SoilSlow::T7 = 0.2 | (0.02, 2.0) | "turnover rate of slow soil carbon pool" | "yr-1"
    annk_SoilOld::T8 = 0.0045 | (0.00045, 0.045) | "turnover rate of old soil carbon pool" | "yr-1"
    c_flow_A::T9 = Float64[
                     -1.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0
                     0.0 -1.0 0.0 0.0 0 0.0 0.0 0.0
                     0.0 0.0 -1.0 1.0 0.0 0 0.0 0.0
                     1.0 0.0 1.0 -1.0 0.0 0.0 0.0 0.0
                     1.0 0.0 1.0 0.0 -1.0 0.0 0.0 0.0
                     0.0 1.0 0.0 0.0 0 -1.0 0.0 0.0
                     0.0 0.0 0 0.0 1.0 1.0 -1.0 0.0
                     0.0 0.0 0 0.0 0.0 0.0 1.0 -1.0
                 ] | (nothing, nothing) | "Transfer matrix for carbon at ecosystem level" | ""
    C2Nveg::T10 = Float64[25.0, 260.0, 260.0, 10.0] | (nothing, nothing) | "carbon to nitrogen ratio in vegetation pools" | "gC/gN"
    ηH::T11 = 1.0 | (0.01, 100.0) | "scaling factor for heterotrophic pools after spinup" | ""
    ηA::T12 = 1.0 | (0.01, 100.0) | "scaling factor for vegetation pools after spinup" | ""
    c_remain::T13 = 10.0 | (0.1, 100.0) | "remaining carbon after disturbance" | ""
end
#! format: on

function define(p_struct::cCycleBase_GSI, forcing, land, helpers)
    @unpack_cCycleBase_GSI p_struct
    @unpack_land begin
        num_type ∈ helpers.numbers
        (𝟘, 𝟙) ∈ helpers.numbers
        cEco ∈ land.pools
    end
    ## instantiate variables
    p_C2Nveg = zero(cEco) #sujan
    # p_C2Nveg[getzix(land.pools.cVeg, helpers.pools.zix.cVeg)] .= C2Nveg
    p_k_base = zero(cEco)
    p_annk = zero(cEco)

    # if there is flux order check that is consistent
    c_flow_order = Tuple(collect(1:length(findall(>(𝟘), c_flow_A))))
    c_taker = Tuple([ind[1] for ind ∈ findall(>(𝟘), c_flow_A)])
    c_giver = Tuple([ind[2] for ind ∈ findall(>(𝟘), c_flow_A)])

    c_model = Val(:GSI)

    ## pack land variables
    @pack_land begin
        (p_C2Nveg, c_flow_A, p_k_base, p_annk, c_flow_order, c_taker, c_giver, c_remain, c_model) => land.cCycleBase
    end
    return land
end

function precompute(p_struct::cCycleBase_GSI, forcing, land, helpers)
    @unpack_cCycleBase_GSI p_struct
    @unpack_land begin
        (p_C2Nveg, p_k_base, p_annk) ∈ land.cCycleBase
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    ## replace values
    @rep_elem annk_Root => (p_annk, 1, :cEco)
    @rep_elem annk_Wood => (p_annk, 2, :cEco)
    @rep_elem annk_Leaf => (p_annk, 3, :cEco)
    @rep_elem annk_Reserve => (p_annk, 4, :cEco)
    @rep_elem annk_LitSlow => (p_annk, 5, :cEco)
    @rep_elem annk_LitFast => (p_annk, 6, :cEco)
    @rep_elem annk_SoilSlow => (p_annk, 7, :cEco)
    @rep_elem annk_SoilOld => (p_annk, 8, :cEco)

    vegZix = getzix(land.pools.cVeg, helpers.pools.zix.cVeg)
    for vg ∈ vegZix
        @rep_elem C2Nveg[vg] => (p_C2Nveg, vg, :cEco)
    end

    for i ∈ eachindex(p_k_base)
        tmp = 𝟙 - (exp(-p_annk[i])^(𝟙 / helpers.dates.timesteps_in_year))
        @rep_elem tmp => (p_k_base, i, :cEco)
    end

    ## pack land variables
    @pack_land begin
        (p_C2Nveg, p_annk, p_k_base, ηA, ηH) => land.cCycleBase
    end
    return land
end

function adjust_and_pack_pool_components(land, helpers, ::Val{:GSI})
    @unpack_land (cVeg,
        cLit,
        cSoil,
        cVegRoot,
        cVegWood,
        cVegLeaf,
        cVegReserve,
        cLitFast,
        cLitSlow,
        cSoilSlow,
        cSoilOld,
        cEco) ∈ land.pools

    zix = helpers.pools.zix
    for (lc, l) in enumerate(zix.cVeg)
        @rep_elem cEco[l] => (cVeg, lc, :cVeg)
    end

    for (lc, l) in enumerate(zix.cVegRoot)
        @rep_elem cEco[l] => (cVegRoot, lc, :cVegRoot)
    end

    for (lc, l) in enumerate(zix.cVegWood)
        @rep_elem cEco[l] => (cVegWood, lc, :cVegWood)
    end

    for (lc, l) in enumerate(zix.cVegLeaf)
        @rep_elem cEco[l] => (cVegLeaf, lc, :cVegLeaf)
    end

    for (lc, l) in enumerate(zix.cVegReserve)
        @rep_elem cEco[l] => (cVegReserve, lc, :cVegReserve)
    end

    for (lc, l) in enumerate(zix.cLit)
        @rep_elem cEco[l] => (cLit, lc, :cLit)
    end

    for (lc, l) in enumerate(zix.cLitFast)
        @rep_elem cEco[l] => (cLitFast, lc, :cLitFast)
    end

    for (lc, l) in enumerate(zix.cLitSlow)
        @rep_elem cEco[l] => (cLitSlow, lc, :cLitSlow)
    end

    for (lc, l) in enumerate(zix.cSoil)
        @rep_elem cEco[l] => (cSoil, lc, :cSoil)
    end

    for (lc, l) in enumerate(zix.cSoilSlow)
        @rep_elem cEco[l] => (cSoilSlow, lc, :cSoilSlow)
    end

    for (lc, l) in enumerate(zix.cSoilOld)
        @rep_elem cEco[l] => (cSoilOld, lc, :cSoilOld)
    end
    @pack_land (cVeg,
        cLit,
        cSoil,
        cVegRoot,
        cVegWood,
        cVegLeaf,
        cVegReserve,
        cLitFast,
        cLitSlow,
        cSoilSlow,
        cSoilOld,
        cEco) => land.pools
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

# instantiate:
instantiate/instantiate time-invariant variables for cCycleBase_GSI


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
