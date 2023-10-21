export cFlow_GSI

#! format: off
@bounds @describe @units @with_kw struct cFlow_GSI{T1,T2,T3,T4} <: cFlow
    slope_leaf_root_to_reserve::T1 = 0.1 | (0.01, 0.99) | "Leaf-Root to Reserve" | "fraction"
    slope_reserve_to_leaf_root::T2 = 0.1 | (0.01, 0.99) | "Reserve to Leaf-Root" | "fraction"
    k_shedding::T3 = 0.1 | (0.01, 0.99) | "rate of shedding" | "fraction"
    f_τ::T4 = 0.1 | (0.01, 0.99) | "contribution factor for current stressor" | "fraction"
end
#! format: on

function define(params::cFlow_GSI, forcing, land, helpers)
    @unpack_cFlow_GSI params
    @unpack_land begin
        (c_giver, c_taker, c_flow_A_array) ∈ land.cCycleBase
    end
    ## instantiate variables

    # transfers
    cEco_comps = helpers.pools.components.cEco
    aTrg = []
    for t_rg in c_taker
        push!(aTrg, cEco_comps[t_rg])
    end
    aSrc = []
    for s_rc in c_giver
        push!(aSrc, cEco_comps[s_rc])
    end

    # aTrg_a = Tuple(aTrg_a)
    # aSrc_b = Tuple(aSrc_a)

    # flowVar = [:reserve_to_leaf, :reserve_to_root, :leaf_to_reserve, :root_to_reserve, :k_shedding_leaf, :k_shedding_root]
    # aSrc = (:cVegReserve, :cVegReserve, :cVegLeaf, :cVegRoot, :cVegLeaf, :cVegRoot)
    # aTrg = (:cVegLeaf, :cVegRoot, :cVegReserve, :cVegReserve, :cLitFast, :cLitFast)

    aSrc = Tuple(aSrc)
    aTrg = Tuple(aTrg)

    # @show aSrc, aSrc_b
    # @show aTrg, aTrg_a
    c_flow_A_vec_ind = (reserve_to_leaf=findall((aSrc .== :cVegReserve) .* (aTrg .== :cVegLeaf) .== true)[1],
        reserve_to_root=findall((aSrc .== :cVegReserve) .* (aTrg .== :cVegRoot) .== true)[1],
        leaf_to_reserve=findall((aSrc .== :cVegLeaf) .* (aTrg .== :cVegReserve) .== true)[1],
        root_to_reserve=findall((aSrc .== :cVegRoot) .* (aTrg .== :cVegReserve) .== true)[1],
        k_shedding_leaf=findall((aSrc .== :cVegLeaf) .* (aTrg .== :cLitFast) .== true)[1],
        k_shedding_root=findall((aSrc .== :cVegRoot) .* (aTrg .== :cLitFast) .== true)[1])

    # tcPrint(c_flow_A_vec_ind)
    c_flow_A_vec = one.(eltype(land.pools.cEco).(zero([c_taker...])))

    if land.pools.cEco isa SVector
        c_flow_A_vec = SVector{length(c_flow_A_vec)}(c_flow_A_vec)
    end

    eco_stressor_prev = totalS(land.pools.soilW) / land.properties.sum_wSat


    @pack_land begin
        (c_flow_A_vec_ind, aSrc, aTrg) → land.cFlow
        eco_stressor_prev → land.diagnostics
        c_flow_A_vec → land.fluxes
    end

    return land
end

function adjust_pk(c_eco_k, kValue, flowValue, maxValue, zix, helpers)
    c_eco_k_f_sum = zero(eltype(c_eco_k))
    for ix ∈ zix
        # @show ix, c_eco_k[ix]
        tmp = min(c_eco_k[ix] + kValue + flowValue, maxValue)
        @rep_elem tmp → (c_eco_k, ix, :cEco)
        c_eco_k_f_sum = c_eco_k_f_sum + tmp
    end
    return c_eco_k, c_eco_k_f_sum
end

function compute(params::cFlow_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cFlow_GSI params
    ## unpack land variables
    @unpack_land begin
        (c_flow_A_vec_ind, aSrc, aTrg) ∈ land.cFlow
        (c_allocation_f_soilW, c_allocation_f_soilT, c_allocation_f_cloud, eco_stressor_prev)  ∈ land.diagnostics
        c_eco_k ∈ land.diagnostics
        (c_flow_A_vec, ) ∈ land.fluxes
    end

    # Compute sigmoid functions
    # LPJ-GSI formulation: In GSI; the stressors are smoothened per control variable. That means; gppfsoilW; fTair; and fRdiff should all have a GSI approach for 1:1 conversion. For now; the function below smoothens the combined stressors; & then calculates the slope for allocation
    # current time step before smoothing
    eco_stressor_now = c_allocation_f_soilW * c_allocation_f_soilT * c_allocation_f_cloud

    # get the smoothened stressor based on contribution of previous steps using ARMA-like formulation
    eco_stressor = (one(f_τ) - f_τ) * eco_stressor_prev + f_τ * eco_stressor_now

    slope_eco_stressor = eco_stressor - eco_stressor_prev

    # calculate the flow rate for exchange with reserve pools based on the slopes
    # get the flow & shedding rates
    leaf_root_to_reserve = minOne(maxZero(-slope_eco_stressor) * slope_leaf_root_to_reserve) # * (cVeg_growth < z_zero)
    reserve_to_leaf_root = minOne(maxZero(slope_eco_stressor) * slope_reserve_to_leaf_root) # * (cVeg_growth > 0.0)
    shedding_rate = minOne(maxZero(-slope_eco_stressor) * k_shedding)

    # set the Leaf & Root to Reserve flow rate as the same
    leaf_to_reserve = leaf_root_to_reserve # should it be divided by 2?
    root_to_reserve = leaf_root_to_reserve
    #todo this is needed to make sure that the flow out of Leaf or root does not exceed one. was not needed in matlab version, but reaches this point often in julia, when the eco_stressor suddenly drops from 1 to near zero.
    k_shedding_leaf = min(shedding_rate, one(leaf_to_reserve) - leaf_to_reserve)
    k_shedding_root = min(shedding_rate, one(root_to_reserve) - root_to_reserve)

    # Estimate flows from reserve to leaf & root (sujan modified on
    Re2L_i = zero(slope_leaf_root_to_reserve)
    if c_allocation_f_soilW + c_allocation_f_cloud !== Re2L_i
        Re2L_i = reserve_to_leaf_root * (c_allocation_f_soilW / (c_allocation_f_cloud + c_allocation_f_soilW)) # if water stressor is high, , larger fraction of reserve goes to the leaves for light acquisition
    end
    Re2R_i = reserve_to_leaf_root * (one(Re2L_i) - Re2L_i) # if light stressor is high (=sufficient light), larger fraction of reserve goes to the root for water uptake

    # adjust the outflow rate from the flow pools
    # @show reserve_to_leaf_frac, reserve_to_root_frac

    c_eco_k, c_eco_k_f_sum = adjust_pk(c_eco_k, k_shedding_leaf, leaf_to_reserve, one(leaf_to_reserve), helpers.pools.zix.cVegLeaf, helpers)
    leaf_to_reserve_frac = getFrac(leaf_to_reserve, c_eco_k_f_sum)
    k_shedding_leaf_frac = getFrac(k_shedding_leaf, c_eco_k_f_sum)

    c_eco_k, c_eco_k_f_sum = adjust_pk(c_eco_k, k_shedding_root, root_to_reserve, one(root_to_reserve), helpers.pools.zix.cVegRoot, helpers)
    root_to_reserve_frac = getFrac(root_to_reserve, c_eco_k_f_sum)
    k_shedding_root_frac = getFrac(k_shedding_root, c_eco_k_f_sum)

    c_eco_k, c_eco_k_f_sum = adjust_pk(c_eco_k, Re2L_i, Re2R_i, one(Re2R_i), helpers.pools.zix.cVegReserve, helpers)
    reserve_to_leaf_frac = getFrac(Re2L_i, c_eco_k_f_sum)
    reserve_to_root_frac = getFrac(Re2R_i, c_eco_k_f_sum)

    c_flow_A_vec = repElem(c_flow_A_vec, reserve_to_leaf_frac, c_flow_A_vec, c_flow_A_vec, c_flow_A_vec_ind.reserve_to_leaf)
    c_flow_A_vec = repElem(c_flow_A_vec, reserve_to_root_frac, c_flow_A_vec, c_flow_A_vec, c_flow_A_vec_ind.reserve_to_root)
    c_flow_A_vec = repElem(c_flow_A_vec, leaf_to_reserve_frac, c_flow_A_vec, c_flow_A_vec, c_flow_A_vec_ind.leaf_to_reserve)
    c_flow_A_vec = repElem(c_flow_A_vec, root_to_reserve_frac, c_flow_A_vec, c_flow_A_vec, c_flow_A_vec_ind.root_to_reserve)
    c_flow_A_vec = repElem(c_flow_A_vec, k_shedding_leaf_frac, c_flow_A_vec, c_flow_A_vec, c_flow_A_vec_ind.k_shedding_leaf)
    c_flow_A_vec = repElem(c_flow_A_vec, k_shedding_root_frac, c_flow_A_vec, c_flow_A_vec, c_flow_A_vec_ind.k_shedding_root)
    # c_flow_A_vec[c_flow_A_vec_ind.reserve_to_leaf] = c_flow_A_vec
    # c_flow_A_vec[c_flow_A_vec_ind.reserve_to_root] = reserve_to_root_frac
    # c_flow_A_vec[c_flow_A_vec_ind.leaf_to_reserve] = leaf_to_reserve_frac
    # c_flow_A_vec[c_flow_A_vec_ind.root_to_reserve] = root_to_reserve_frac
    # c_flow_A_vec[c_flow_A_vec_ind.k_shedding_leaf] = k_shedding_leaf_frac
    # c_flow_A_vec[c_flow_A_vec_ind.k_shedding_root] = k_shedding_root_frac

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
        (leaf_to_reserve, leaf_to_reserve_frac, root_to_reserve, root_to_reserve_frac, reserve_to_leaf, reserve_to_leaf_frac, reserve_to_root, reserve_to_root_frac, eco_stressor, k_shedding_leaf, k_shedding_leaf_frac, k_shedding_root, k_shedding_root_frac, slope_eco_stressor, eco_stressor_prev) → land.diagnostics
        (c_eco_k,) → land.states
        c_flow_A_vec → land.fluxes
    end
    return land
end

@doc """
Precomputations for the transfers between carbon pools based on GSI method. combine all the effects that change the transfers between carbon pools based on GSI method

# Parameters
$(SindbadParameters)

---

# compute:
Actual transfers of c between pools (of diagonal components) using cFlow_GSI

*Inputs*
 - land.diagnostics.c_allocation_f_cloud: radiation stressors for carbo allocation
 - land.diagnostics.f_cloud_prev: previous radiation stressors for carbo allocation
 - land.diagnostics.c_allocation_f_soilT: temperature stressors for carbon allocation
 - land.diagnostics.f_soilT_prev: previous temperature stressors for carbon allocation
 - land.diagnostics.c_allocation_f_soilW: water stressors for carbon allocation
 - land.diagnostics.f_soilW_prev: previous water stressors for carbon allocation
 - land.cCycleBase.c_flow_A_array: transfer matrix for carbon at ecosystem level

*Outputs*
 - land.cFlow.c_flow_A_vec: updated transfer flow rate for carbon at ecosystem level
 - land.cFlow.p_flowTable: a table with flow pools & parameters
 - land.cFlow.p_flowVar: the variable that represents the flow between the source & target pool
 - land.cFlow.p_ndxSrc: source pools
 - land.cFlow.p_ndxTrg: taget pools
 - land.cFlow.c_flow_A_vec

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
