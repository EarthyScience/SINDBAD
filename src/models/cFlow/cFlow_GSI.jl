export cFlow_GSI

@bounds @describe @units @with_kw struct cFlow_GSI{T1, T2, T3, T4} <: cFlow
	LR2ReSlp::T1 = 0.1 | (0.01, 1.0) | "Leaf-Root to Reserve" | "fraction"
	Re2LRSlp::T2 = 0.1 | (0.01, 1.0) | "Reserve to Leaf-Root" | "fraction"
	kShed::T3 = 0.1 | (0.01, 1.0) | "rate of shedding" | "fraction"
	f_τ::T4 = 0.1 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction"
end

function precompute(o::cFlow_GSI, forcing, land::NamedTuple, helpers::NamedTuple)
    @unpack_cFlow_GSI o
    @unpack_land begin
        cFlowA ∈ land.cCycleBase
        (𝟘, 𝟙, tolerance, numType) ∈ helpers.numbers
    end
    ## instantiate variables
    asrc = [:cVegReserve, :cVegReserve, :cVegLeaf, :cVegRoot, :cVegLeaf, :cVegRoot]
    atrg = [:cVegLeaf, :cVegRoot, :cVegReserve, :cVegReserve, :cLitFast, :cLitFast]
    flow = ones(numType, length(atrg))
    ndxSrc = [Int[] for x in atrg]
    ndxTrg = [Int[] for x in atrg]
    p_A = copy(cFlowA)

    flowVar = [:Re2L, :Re2R, :L2ReF, :R2ReF, :k_LshedF, :k_RshedF]
    flowTable = DataFrame(srcName=asrc, trgName=atrg, ndxSrc=ndxSrc, ndxTrg=ndxTrg, flowVar=flowVar, flow=flow)
    # Prepare the list of flows
    for trow in eachrow(flowTable)
        srcName = trow.srcName
        trgName = trow.trgName
        # @show trow, srcName, trgName
        ndxSrc = getzix(land.pools, srcName)
        ndxTrg = getzix(land.pools, trgName)
        trow.ndxSrc = ndxSrc
        trow.ndxTrg = ndxTrg
        for iSrc in 1:length(ndxSrc)
            for iTrg in 1:length(ndxTrg)
                fT = trow.flow
                p_A[ndxTrg[iTrg], ndxSrc[iSrc]] = fT
            end
        end

    end


    # transfers
    taker = [ind[1] for ind in findall(>(𝟘), p_A)]
    giver = [ind[2] for ind in findall(>(𝟘), p_A)]
    # taker = [ind[1] for ind in findall(>(𝟘), p_A)]
    # giver = [ind[2] for ind in findall(>(𝟘), p_A)]
    # (taker, giver) = findall(squeeze(sum(p_A > 𝟘, 1)) >= 𝟙)
    # p_taker = taker
    # p_giver = giver
    # if there is flux order check that is consistent
    if !hasproperty(land.cCycleBase, :p_fluxOrder)
        fluxOrder = collect(1:length(taker))
    else
        if length(fluxOrder) != length(taker)
            error(["ERR:cFlowAct_gsi:" "length(fluxOrder) != length(taker)"])
        end
    end

    fWfTfR_prev = helpers.numbers.𝟙
    ## pack land variables
    @pack_land begin
		fluxOrder => land.cCycleBase
		(p_A, fWfTfR_prev, flowTable, taker, giver) => land.cFlow
	end
    return land
end

function compute(o::cFlow_GSI, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters
    @unpack_cFlow_GSI o


    ## unpack land variables
    @unpack_land begin
        (fWfTfR_prev, p_A, flowTable) ∈ land.cFlow
        fW ∈ land.cAllocationSoilW
        fT ∈ land.cAllocationSoilT
        fR ∈ land.cAllocationRadiation
        (𝟘, 𝟙, tolerance) ∈ helpers.numbers
        p_k ∈ land.states
    end

    flowTable = flowTable
    ndxSrc = flowTable.ndxSrc
    ndxTrg = flowTable.ndxTrg

    # Compute sigmoid functions
    # LPJ-GSI formulation: In GSI; the stressors are smoothened per control variable. That means; gppfsoilW; fTair; and fRdiff should all have a GSI approach for 1:1 conversion. For now; the function below smoothens the combined stressors; & then calculates the slope for allocation
    # current time step before smoothing
    f_tmp = fW * fT * fR
    # stressor from previos time step
    f_prev = fWfTfR_prev
    # get the smoothened stressor based on contribution of previous steps using ARMA-like formulation
    f_now = (𝟙 - f_τ) * f_prev + f_τ * f_tmp
    fWfTfR = f_now

    slope_fWfTfR = f_now - f_prev

    # get the indices of leaf & root
    cVegLeafzix = getzix(land.pools.cVegLeaf)
    cVegRootzix = getzix(land.pools.cVegRoot)
    cVegReservezix = getzix(land.pools.cVegReserve)

    # calculate the flow rate for exchange with reserve pools based on the slopes
    # get the flow & shedding rates
    LR2Re = clamp(-slope_fWfTfR * LR2ReSlp, 𝟘, 𝟙) # * (cVeg_growth < 𝟘)
    Re2LR = clamp(slope_fWfTfR * Re2LRSlp, 𝟘, 𝟙) # * (cVeg_growth > 0.0)
    KShed = clamp(-slope_fWfTfR * kShed, 𝟘, 𝟙)

    # set the Leaf & Root to Reserve flow rate as the same
    L2Re = LR2Re # should it be divided by 2?
    R2Re = LR2Re
    k_Lshed = KShed
    k_Rshed = KShed

    # Estimate flows from reserve to leaf & root (sujan modified on
    # 30.09.2021 to avoid 0/0 calculation which leads to NaN values; 1E-15 should avoid that)
    Re2L = Re2LR * (fW / (tolerance + fR + fW)) # if water stressor is high [
    Re2R = Re2LR * (𝟙 - Re2L)
    # # Estimate flows from reserve to leaf & root
    # Re2L = Re2LR * (fW / (fR + fW)); # if water stressor is high [
    # Re2R = Re2LR * (fR / (fR + fW)); # if light stressor is high [
    # the following two lines lead to k larger than 1; which results in negative carbon pools.
    # p_k[cVegLeafzix] = p_k[cVegLeafzix] + k_Lshed + L2Re
    # p_k[cVegRootzix] = p_k[cVegRootzix] + k_Rshed + R2Re

    # adjust the outflow rate from the flow pools
    p_k[cVegLeafzix] .= min.((p_k[cVegLeafzix] .+ k_Lshed .+ L2Re), 𝟙)
    L2ReF = L2Re ./ (p_k[cVegLeafzix])
    k_LshedF = k_Lshed ./ (p_k[cVegLeafzix])
    p_k[cVegRootzix] .= min.((p_k[cVegRootzix] .+ k_Rshed .+ R2Re), 𝟙)
    R2ReF = R2Re ./ (p_k[cVegRootzix])
    k_RshedF = k_Rshed ./ (p_k[cVegRootzix])
    p_k[cVegReservezix] .= min.((p_k[cVegReservezix] .+ Re2L .+ Re2R), 𝟙)
    Re2LF = Re2L ./ p_k[cVegReservezix]
    Re2RF = Re2R ./ p_k[cVegReservezix]

    # while using the indexing of aM would be elegant; the speed is really slow; & hence the following block of code is implemented
    for ii in 1:length(ndxSrc)
        src = ndxSrc[ii]
        trg = ndxTrg[ii]
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
        (L2Re, L2ReF, R2Re, R2ReF, Re2L, Re2R, fWfTfR, k_Lshed, k_LshedF, k_Rshed, k_RshedF, p_A, slope_fWfTfR, fWfTfR_prev) => land.cFlow
        p_k => land.states
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
 - ncarvalhais & sbesnard
 - ncarvalhais & skoirala

*Notes*
"""
cFlow_GSI