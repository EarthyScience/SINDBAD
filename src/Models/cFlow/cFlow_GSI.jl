export cFlow_GSI

#! format: off
@bounds @describe @units @with_kw struct cFlow_GSI{T1,T2,T3,T4} <: cFlow
    slope_leaf_root_to_reserve::T1 = 0.1 | (0.01, 0.99) | "Leaf-Root to Reserve" | "fraction"
    slope_reserve_to_leaf_root::T2 = 0.1 | (0.01, 0.99) | "Reserve to Leaf-Root" | "fraction"
    k_shedding::T3 = 0.1 | (0.01, 0.99) | "rate of shedding" | "fraction"
    f_τ::T4 = 0.1 | (0.01, 0.99) | "contribution factor for current stressor" | "fraction"
end
#! format: on

function define(p_struct::cFlow_GSI, forcing, land, helpers)
    @unpack_cFlow_GSI p_struct
    @unpack_land begin
        (c_giver, c_taker, c_flow_A) ∈ land.cCycleBase
        (𝟘, 𝟙, tolerance, num_type, sNT) ∈ helpers.numbers
    end
    ## instantiate variables

    # transfers
    # cEco_comps = helpers.pools.components.cEco
    # aTrg_a = []
    # for t_rg in c_taker
    #     if cEco_comps[t_rg] ∉ aTrg_a
    #         push!(aTrg_a, cEco_comps[t_rg])
    #     end
    # end
    # aSrc_a = []
    # for s_rc in c_giver
    #     if cEco_comps[s_rc] ∉ aSrc_a
    #         push!(aSrc_a, cEco_comps[s_rc])
    #     end
    # end

    # aTrg_a = Tuple(aTrg_a)
    # aSrc_b = Tuple(aSrc_a)

    flowVar = [:reserve_to_leaf, :reserve_to_root, :leaf_to_reserve, :root_to_reserve, :k_shedding_leaf, :k_shedding_root]
    aSrc = (:cVegReserve, :cVegReserve, :cVegLeaf, :cVegRoot, :cVegLeaf, :cVegRoot)
    aTrg = (:cVegLeaf, :cVegRoot, :cVegReserve, :cVegReserve, :cLitFast, :cLitFast)

    # @show aSrc, aSrc_b
    # @show aTrg, aTrg_a
    p_A_ind = (reserve_to_leaf=findall((aSrc .== :cVegReserve) .* (aTrg .== :cVegLeaf) .== true)[1],
        reserve_to_root=findall((aSrc .== :cVegReserve) .* (aTrg .== :cVegRoot) .== true)[1],
        leaf_to_reserve=findall((aSrc .== :cVegLeaf) .* (aTrg .== :cVegReserve) .== true)[1],
        root_to_reserve=findall((aSrc .== :cVegRoot) .* (aTrg .== :cVegReserve) .== true)[1],
        k_shedding_leaf=findall((aSrc .== :cVegLeaf) .* (aTrg .== :cLitFast) .== true)[1],
        k_shedding_root=findall((aSrc .== :cVegRoot) .* (aTrg .== :cLitFast) .== true)[1])

    p_A = sNT.(zero([c_taker...]))

    if land.pools.cEco isa SVector
        p_A = SVector{length(p_A)}(p_A)
    end

    # eco_stressor_prev = 𝟙
    eco_stressor_prev = addS(land.pools.soilW) / land.soilWBase.s_wSat
    ## pack land variables
    # dummy init
    # leaf_to_reserve = 𝟙
    # leaf_to_reserve_frac = 𝟙
    # root_to_reserve = 𝟙
    # root_to_reserve_frac = 𝟙
    # reserve_to_leaf = 𝟙
    # reserve_to_root = 𝟙
    # eco_stressor = 𝟙
    # k_shedding_leaf = 𝟙
    # k_shedding_leaf_frac = 𝟙
    # k_shedding_root = 𝟙
    # k_shedding_root_frac = 𝟙
    # slope_eco_stressor = 𝟙

    @pack_land begin
        (p_A_ind, eco_stressor_prev, aSrc, aTrg) => land.cFlow
        # (p_A, eco_stressor_prev, ndxSrc, ndxTrg, c_taker, c_giver) => land.cFlow
        p_A => land.states
    end

    return land
end

function adjust_pk(p_k, kValue, flowValue, maxValue, zix, helpers)
    p_k_sum = zero(eltype(p_k))
    for ix ∈ zix
        # @show ix, p_k[ix]
        tmp = p_k[ix] + kValue + flowValue
        if tmp > maxValue
            tmp = maxValue
        end
        @rep_elem tmp => (p_k, ix, :cEco)
        p_k_sum = p_k_sum + tmp
    end
    return p_k, p_k_sum
end

function compute(p_struct::cFlow_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cFlow_GSI p_struct
    ## unpack land variables
    @unpack_land begin
        (eco_stressor_prev, p_A_ind, aSrc, aTrg) ∈ land.cFlow
        c_allocation_f_soilW ∈ land.cAllocationSoilW
        c_allocation_f_soilT ∈ land.cAllocationSoilT
        c_allocation_f_cloud ∈ land.cAllocationRadiation
        (𝟘, 𝟙, tolerance) ∈ helpers.numbers
        (p_A, p_k) ∈ land.states
    end

    # Compute sigmoid functions
    # LPJ-GSI formulation: In GSI; the stressors are smoothened per control variable. That means; gppfsoilW; fTair; and fRdiff should all have a GSI approach for 1:1 conversion. For now; the function below smoothens the combined stressors; & then calculates the slope for allocation
    # current time step before smoothing
    eco_stressor_now = c_allocation_f_soilW * c_allocation_f_soilT * c_allocation_f_cloud

    # get the smoothened stressor based on contribution of previous steps using ARMA-like formulation
    eco_stressor = (𝟙 - f_τ) * eco_stressor_prev + f_τ * eco_stressor_now

    slope_eco_stressor = eco_stressor - eco_stressor_prev

    # calculate the flow rate for exchange with reserve pools based on the slopes
    # get the flow & shedding rates
    leaf_root_to_reserve = min_1(max_0(-slope_eco_stressor) * slope_leaf_root_to_reserve) # * (cVeg_growth < 𝟘)
    reserve_to_leaf_root = min_1(max_0(slope_eco_stressor) * slope_reserve_to_leaf_root) # * (cVeg_growth > 0.0)
    shedding_rate = min_1(max_0(-slope_eco_stressor) * k_shedding)

    # set the Leaf & Root to Reserve flow rate as the same
    leaf_to_reserve = leaf_root_to_reserve # should it be divided by 2?
    root_to_reserve = leaf_root_to_reserve
    #todo this is needed to make sure that the flow out of Leaf or root does not exceed one. was not needed in matlab version, but reaches this point often in julia, when the eco_stressor suddenly drops from 1 to near zero.
    k_shedding_leaf = min(shedding_rate, one(shedding_rate) - leaf_to_reserve)
    k_shedding_root = min(shedding_rate, one(shedding_rate) - root_to_reserve)

    # Estimate flows from reserve to leaf & root (sujan modified on
    Re2L_i = zero(reserve_to_leaf_root)
    if c_allocation_f_soilW + c_allocation_f_cloud !== 𝟘
        Re2L_i = reserve_to_leaf_root * (c_allocation_f_soilW / (c_allocation_f_cloud + c_allocation_f_soilW)) # if water stressor is high, , larger fraction of reserve goes to the leaves for light acquisition
    end
    Re2R_i = reserve_to_leaf_root * (one(Re2L_i) - Re2L_i) # if light stressor is high (=sufficient light), larger fraction of reserve goes to the root for water uptake

    # adjust the outflow rate from the flow pools

    # # get the indices of leaf & root
    # cVegLeafzix = getzix(land.pools.cVegLeaf)
    # cVegRootzix = getzix(land.pools.cVegRoot)
    # cVegReservezix = getzix(land.pools.cVegReserve)

    # p_k[cVegLeafzix] .= min.((p_k[cVegLeafzix] .+ k_shedding_leaf .+ leaf_to_reserve), 𝟙)
    # leaf_to_reserve_frac = leaf_to_reserve ./ (p_k[cVegLeafzix])
    # k_shedding_leaf_frac = k_shedding_leaf / (p_k[cVegLeafzix])

    # p_k[cVegRootzix] .= min.((p_k[cVegRootzix] .+ k_shedding_root .+ root_to_reserve), 𝟙)
    # root_to_reserve_frac = root_to_reserve ./ (p_k[cVegRootzix])
    # k_shedding_root_frac = k_shedding_root / (p_k[cVegRootzix])

    # p_k[cVegReservezix] .= min.((p_k[cVegReservezix] .+ reserve_to_leaf .+ reserve_to_root), 𝟙)
    # reserve_to_leaf_frac = reserve_to_leaf ./ p_k[cVegReservezix]
    # reserve_to_root_frac = reserve_to_root ./ p_k[cVegReservezix]

    # @show reserve_to_leaf_frac, reserve_to_root_frac

    p_k, p_k_sum = adjust_pk(p_k, k_shedding_leaf, leaf_to_reserve, 𝟙, helpers.pools.zix.cVegLeaf, helpers)
    leaf_to_reserve_frac = getFrac(leaf_to_reserve, p_k_sum)
    k_shedding_leaf_frac = getFrac(k_shedding_leaf, p_k_sum)

    p_k, p_k_sum = adjust_pk(p_k, k_shedding_root, root_to_reserve, 𝟙, helpers.pools.zix.cVegRoot, helpers)
    root_to_reserve_frac = getFrac(root_to_reserve, p_k_sum)
    k_shedding_root_frac = getFrac(k_shedding_root, p_k_sum)

    p_k, p_k_sum = adjust_pk(p_k, Re2L_i, Re2R_i, 𝟙, helpers.pools.zix.cVegReserve, helpers)
    reserve_to_leaf_frac = getFrac(Re2L_i, p_k_sum)
    reserve_to_root_frac = getFrac(Re2R_i, p_k_sum)

    p_A = rep_elem(p_A, reserve_to_leaf_frac, p_A, p_A, 𝟘, 𝟙, p_A_ind.reserve_to_leaf)
    p_A = rep_elem(p_A, reserve_to_root_frac, p_A, p_A, 𝟘, 𝟙, p_A_ind.reserve_to_root)
    p_A = rep_elem(p_A, leaf_to_reserve_frac, p_A, p_A, 𝟘, 𝟙, p_A_ind.leaf_to_reserve)
    p_A = rep_elem(p_A, root_to_reserve_frac, p_A, p_A, 𝟘, 𝟙, p_A_ind.root_to_reserve)
    p_A = rep_elem(p_A, k_shedding_leaf_frac, p_A, p_A, 𝟘, 𝟙, p_A_ind.k_shedding_leaf)
    p_A = rep_elem(p_A, k_shedding_root_frac, p_A, p_A, 𝟘, 𝟙, p_A_ind.k_shedding_root)
    # p_A[p_A_ind.reserve_to_leaf] = p_A
    # p_A[p_A_ind.reserve_to_root] = reserve_to_root_frac
    # p_A[p_A_ind.leaf_to_reserve] = leaf_to_reserve_frac
    # p_A[p_A_ind.root_to_reserve] = root_to_reserve_frac
    # p_A[p_A_ind.k_shedding_leaf] = k_shedding_leaf_frac
    # p_A[p_A_ind.k_shedding_root] = k_shedding_root_frac

    # store the varibles in diagnostic structure
    leaf_to_reserve = leaf_root_to_reserve # should it be divided by 2?
    k_shedding_leaf = shedding_rate
    k_shedding_root = shedding_rate
    reserve_to_leaf = reserve_to_leaf_frac
    reserve_to_root = reserve_to_root_frac
    leaf_to_reserve_frac = leaf_to_reserve_frac # should it be divided by 2?

    eco_stressor_prev = eco_stressor

    ## pack land variables
    @pack_land begin
        (leaf_to_reserve,
            leaf_to_reserve_frac,
            root_to_reserve,
            root_to_reserve_frac,
            reserve_to_leaf,
            reserve_to_root,
            eco_stressor,
            k_shedding_leaf,
            k_shedding_leaf_frac,
            k_shedding_root,
            k_shedding_root_frac,
            slope_eco_stressor,
            eco_stressor_prev) => land.cFlow
        (p_A, p_k) => land.states
    end
    return land
end

@doc """
Precomputations for the transfers between carbon pools based on GSI method. combine all the effects that change the transfers between carbon pools based on GSI method

# Parameters
$(PARAMFIELDS)

---

# compute:
Actual transfers of c between pools (of diagonal components) using cFlow_GSI

*Inputs*
 - land.cAllocationRadiation.c_allocation_f_cloud: radiation stressors for carbo allocation
 - land.cAllocationRadiation.fR_prev: previous radiation stressors for carbo allocation
 - land.cAllocationSoilT.c_allocation_f_soilT: temperature stressors for carbon allocation
 - land.cAllocationSoilT.fT_prev: previous temperature stressors for carbon allocation
 - land.cAllocationSoilW.c_allocation_f_soilW: water stressors for carbon allocation
 - land.cAllocationSoilW.fW_prev: previous water stressors for carbon allocation
 - land.cCycleBase.c_flow_A: transfer matrix for carbon at ecosystem level

*Outputs*
 - land.cFlow.p_A: updated transfer flow rate for carbon at ecosystem level
 - land.cFlow.p_flowTable: a table with flow pools & parameters
 - land.cFlow.p_flowVar: the variable that represents the flow between the source & target pool
 - land.cFlow.p_ndxSrc: source pools
 - land.cFlow.p_ndxTrg: taget pools
 - land.cFlow.p_A

# instantiate:
instantiate/instantiate time-invariant variables for cFlow_GSI


---

# Extended help

*References*

*Versions*
 - 1.0 on 13.01.2020 [sbesnard]
 - 1.1 on 05.02.2021 [skoirala]: changes with stressors & smoothing as well as handling the activation of leaf/root to reserve | reserve to leaf/root switches. Adjustment of total flow rates [cTau] of relevant pools  
 - 1.1 on 05.02.2021 [skoirala]: move code from dyna. Add table etc.  

*Created by:*
 - ncarvalhais, sbesnard, skoirala

*Notes*
"""
cFlow_GSI
