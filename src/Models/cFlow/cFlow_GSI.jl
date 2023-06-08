export cFlow_GSI

@bounds @describe @units @with_kw struct cFlow_GSI{T1, T2, T3, T4} <: cFlow
	LR2ReSlp::T1 = 0.1 | (0.01, 0.99) | "Leaf-Root to Reserve" | "fraction"
	Re2LRSlp::T2 = 0.1 | (0.01, 0.99) | "Reserve to Leaf-Root" | "fraction"
	kShed::T3 = 0.1 | (0.01, 0.99) | "rate of shedding" | "fraction"
	f_τ::T4 = 0.1 | (0.01, 0.99) | "contribution factor for current stressor" | "fraction"
end

function precompute(o::cFlow_GSI, forcing, land, helpers)
    @unpack_cFlow_GSI o
    @unpack_land begin
        cFlowA ∈ land.cCycleBase
        (𝟘, 𝟙, tolerance, numType) ∈ helpers.numbers
    end
    ## instantiate variables
    flowVar = [:Re2L, :Re2R, :L2ReF, :R2ReF, :k_LshedF, :k_RshedF]
    asrc = [:cVegReserve, :cVegReserve, :cVegLeaf, :cVegRoot, :cVegLeaf, :cVegRoot]
    atrg = [:cVegLeaf, :cVegRoot, :cVegReserve, :cVegReserve, :cLitFast, :cLitFast]
    ndxSrc = [Int[] for x in atrg]
    ndxTrg = copy(ndxSrc)
    p_A = copy(cFlowA)

    # Prepare the list of flows
    for trow in eachindex(flowVar)
        # @show trow, srcName, trgName
        zixSrc = getzix(getfield(land.pools, asrc[trow]), getfield(helpers.pools.carbon.zix, asrc[trow]))
        zixTrg = getzix(getfield(land.pools, atrg[trow]), getfield(helpers.pools.carbon.zix, atrg[trow]))
        push!(ndxSrc, zixSrc)
        push!(ndxTrg, zixTrg)
        for iSrc in zixSrc
            for iTrg in zixTrg
                p_A[iTrg, iSrc] = 𝟙
            end
        end
    end

    # transfers
    taker = [ind[1] for ind in findall(>(𝟘), p_A)]
    giver = [ind[2] for ind in findall(>(𝟘), p_A)]

    # if there is flux order check that is consistent
    if !hasproperty(land.cCycleBase, :p_fluxOrder)
        fluxOrder = collect(1:length(taker))
    else
        if length(fluxOrder) != length(taker)
            error("cFlow_GSI: length(fluxOrder) [$(length(fluxOrder))] != length(taker) [$(length(taker))]")
        end
    end

    fWfTfR_prev = 𝟙
    ## pack land variables
    # dummy init
    L2Re = 𝟙
    L2ReF = 𝟙
    R2Re = 𝟙
    R2ReF = 𝟙
    Re2L = 𝟙
    Re2R = 𝟙
    fWfTfR = 𝟙
    k_Lshed = 𝟙
    k_LshedF = 𝟙
    k_Rshed = 𝟙
    k_RshedF = 𝟙
    slope_fWfTfR = 𝟙

    ndxSrc = vcat(ndxSrc...)
    ndxTrg = vcat(ndxTrg...)

    @pack_land begin
		fluxOrder => land.cCycleBase
		(p_A, fWfTfR_prev, ndxSrc, ndxTrg, taker, giver) => land.cFlow
        (L2Re, L2ReF, R2Re, R2ReF, Re2L, Re2R, fWfTfR, k_Lshed, k_LshedF, k_Rshed, k_RshedF, slope_fWfTfR) => land.cFlow
	end

    return land
end


function adjust_pk(p_k, kValue, flowValue, maxValue, zix, helpers)
    p_k_sum = zero(eltype(p_k))
    for ix in zix
        # @show ix, p_k[ix]
        tmp = p_k[ix] + kValue + flowValue
        if tmp > maxValue
            tmp = maxValue
        end
        p_k = ups(p_k, tmp, helpers.pools.carbon.zeros.cEco, helpers.pools.carbon.ones.cEco, helpers.numbers.𝟘, helpers.numbers.𝟙, ix)
        p_k_sum = p_k_sum + tmp
    end
    return p_k_sum
end

function get_frac_flow(num, den)
    if !iszero(den)
        rat = num / den
    else
        rat = num
    end    
    return rat
end

function compute(o::cFlow_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cFlow_GSI o
    ## unpack land variables
    @unpack_land begin
        (fWfTfR_prev, p_A, ndxSrc, ndxTrg) ∈ land.cFlow
        fW ∈ land.cAllocationSoilW
        fT ∈ land.cAllocationSoilT
        fR ∈ land.cAllocationRadiation
        (𝟘, 𝟙, tolerance) ∈ helpers.numbers
        p_k ∈ land.states
    end

    # Compute sigmoid functions
    # LPJ-GSI formulation: In GSI; the stressors are smoothened per control variable. That means; gppfsoilW; fTair; and fRdiff should all have a GSI approach for 1:1 conversion. For now; the function below smoothens the combined stressors; & then calculates the slope for allocation
    # current time step before smoothing
    f_tmp = fW * fT * fR

    # get the smoothened stressor based on contribution of previous steps using ARMA-like formulation
    fWfTfR = (𝟙 - f_τ) * fWfTfR_prev + f_τ * f_tmp

    slope_fWfTfR = fWfTfR - fWfTfR_prev

    # calculate the flow rate for exchange with reserve pools based on the slopes
    # get the flow & shedding rates
    LR2Re = min(max(-slope_fWfTfR, 𝟘) * LR2ReSlp, 𝟙) # * (cVeg_growth < 𝟘)
    # LR2Re = clamp(-slope_fWfTfR * LR2ReSlp, 𝟘, 𝟙) # * (cVeg_growth < 𝟘)
    Re2LR = min(max(slope_fWfTfR, 𝟘) * Re2LRSlp, 𝟙) # * (cVeg_growth > 0.0)
    # Re2LR = clamp(slope_fWfTfR * Re2LRSlp, 𝟘, 𝟙) # * (cVeg_growth > 0.0)
    KShed = min(max(-slope_fWfTfR, 𝟘) * kShed, 𝟙)
    # KShed = clamp(-slope_fWfTfR * kShed, 𝟘, 𝟙)

    # set the Leaf & Root to Reserve flow rate as the same
    L2Re = LR2Re # should it be divided by 2?
    R2Re = LR2Re
    #todo this is needed to make sure that the flow out of Leaf or root does not exceed one. was not needed in matlab version, but reaches this point often in julia, when the fWfTfR suddenly drops from 1 to near zero.
    k_Lshed = min(KShed, 𝟙-L2Re)
    k_Rshed = min(KShed, 𝟙-R2Re)

    # Estimate flows from reserve to leaf & root (sujan modified on
    # 30.09.2021 to avoid 0/0 calculation which leads to NaN values; 1E-15 should avoid that)
    Re2L_i = 𝟘
    if fW + fR !== 𝟘
        Re2L_i = Re2LR * (fW / (fR + fW)) # if water stressor is high, , larger fraction of reserve goes to the leaves for light acquisition
    end
    Re2R_i = Re2LR * (𝟙 - Re2L_i) # if light stressor is high (=sufficient light), larger fraction of reserve goes to the root for water uptake
    
    # adjust the outflow rate from the flow pools


    # # get the indices of leaf & root
    # cVegLeafzix = getzix(land.pools.cVegLeaf)
    # cVegRootzix = getzix(land.pools.cVegRoot)
    # cVegReservezix = getzix(land.pools.cVegReserve)

    # p_k[cVegLeafzix] .= min.((p_k[cVegLeafzix] .+ k_Lshed .+ L2Re), 𝟙)
    # L2ReF = L2Re ./ (p_k[cVegLeafzix])
    # k_LshedF = k_Lshed / (p_k[cVegLeafzix])

    # p_k[cVegRootzix] .= min.((p_k[cVegRootzix] .+ k_Rshed .+ R2Re), 𝟙)
    # R2ReF = R2Re ./ (p_k[cVegRootzix])
    # k_RshedF = k_Rshed / (p_k[cVegRootzix])
    
    # p_k[cVegReservezix] .= min.((p_k[cVegReservezix] .+ Re2L .+ Re2R), 𝟙)
    # Re2LF = Re2L ./ p_k[cVegReservezix]
    # Re2RF = Re2R ./ p_k[cVegReservezix]

    # @show Re2LF, Re2RF



    p_k_sum = adjust_pk(p_k, k_Lshed, L2Re, 𝟙, helpers.pools.carbon.zix.cVegLeaf, helpers)
    L2ReF = get_frac_flow(L2Re, p_k_sum)
    k_LshedF = get_frac_flow(k_Lshed, p_k_sum)

    p_k_sum = adjust_pk(p_k, k_Rshed, R2Re, 𝟙, helpers.pools.carbon.zix.cVegRoot, helpers)
    R2ReF = get_frac_flow(R2Re, p_k_sum)
    k_RshedF = get_frac_flow(k_Rshed, p_k_sum)

    p_k_sum = adjust_pk(p_k, Re2L_i, Re2R_i, 𝟙, helpers.pools.carbon.zix.cVegReserve, helpers)
    Re2LF = get_frac_flow(Re2L_i, p_k_sum)
    Re2RF = get_frac_flow(Re2R_i, p_k_sum)

    # while using the indexing of aM would be elegant; the speed is really slow; & hence the following block of code is implemented
    for ii in eachindex(ndxSrc)
        src = ndxSrc[ii]
        trg = ndxTrg[ii]
        # @show p_A[trg[1], src[1]]
        if ii == 1
            p_A[trg, src] = Re2LF
        elseif ii == 2
            p_A[trg, src] = Re2RF
        elseif ii == 3
            p_A[trg, src] = L2ReF
        elseif ii == 4
            p_A[trg, src] = R2ReF
        elseif ii == 5
            p_A[trg, src] = k_LshedF
        elseif ii == 6
            p_A[trg, src] = k_RshedF
        end
    end

    # store the varibles in diagnostic structure
    L2Re = LR2Re # should it be divided by 2?
    k_Lshed = KShed
    k_Rshed = KShed
    Re2L = Re2LF
    Re2R = Re2RF
    L2ReF = L2ReF # should it be divided by 2?

    fWfTfR_prev = fWfTfR
    ## pack land variables
    @pack_land begin
        (L2Re, L2ReF, R2Re, R2ReF, Re2L_i, Re2R_i, Re2L, Re2R, fWfTfR, k_Lshed, k_LshedF, k_Rshed, k_RshedF, slope_fWfTfR, fWfTfR_prev) => land.cFlow
        #p_k => land.states
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
 - land.cAllocationRadiation.fR: radiation stressors for carbo allocation
 - land.cAllocationRadiation.fR_prev: previous radiation stressors for carbo allocation
 - land.cAllocationSoilT.fT: temperature stressors for carbon allocation
 - land.cAllocationSoilT.fT_prev: previous temperature stressors for carbon allocation
 - land.cAllocationSoilW.fW: water stressors for carbon allocation
 - land.cAllocationSoilW.fW_prev: previous water stressors for carbon allocation
 - land.cCycleBase.cFlowA: transfer matrix for carbon at ecosystem level

*Outputs*
 - land.cFlow.p_A: updated transfer flow rate for carbon at ecosystem level
 - land.cFlow.p_flowTable: a table with flow pools & parameters
 - land.cFlow.p_flowVar: the variable that represents the flow between the source & target pool
 - land.cFlow.p_ndxSrc: source pools
 - land.cFlow.p_ndxTrg: taget pools
 - land.cFlow.p_A

# precompute:
precompute/instantiate time-invariant variables for cFlow_GSI


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