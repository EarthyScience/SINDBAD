export cCycle_simple

struct cCycle_simple <: cCycle
end

function precompute(o::cCycle_simple, forcing, land, helpers)

    @unpack_land begin
        (𝟘, 𝟙, numType) ∈ helpers.numbers
    end
    n_cEco = length(land.pools.cEco)
    ## instantiate variables
    cEcoFlow = zeros(numType, n_cEco)
    cEcoInflux = zeros(numType, n_cEco)

	cEco_prev = copy(land.pools.cEco)
    ## pack land variables
    @pack_land (cEcoFlow, cEcoInflux, cEco_prev) => land.states
    return land
end

function compute(o::cCycle_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (cAlloc, cEcoEfflux, cEcoFlow, cEcoInflux, cEco_prev) ∈ land.states
        cEco ∈ land.pools
        gpp ∈ land.fluxes
        p_k_act ∈ land.cTau
        (p_A, giver, taker) ∈ land.cFlow
        (fluxOrder) ∈ land.cCycleBase
        (𝟘, 𝟙, numType) ∈ helpers.numbers
    end
    ## these all need to be zeros maybe is taken care automatically.
    ## compute losses
    cEcoOut = min.(cEco, cEco .* p_k_act)
    ## gains to vegetation
    zixVeg = getzix(land.pools.cVeg)
    cNPP = gpp .* cAlloc[zixVeg] .- cEcoEfflux[zixVeg]
    cEcoInflux[zixVeg] .= cNPP
    # flows & losses
    # @nc; if flux order does not matter; remove# sujanq: this was deleted by simon in the version of 2020-11. Need to
    # find out why. Led to having zeros in most of the carbon pools of the
    # explicit simple
    # old before cleanup was removed during biomascat when cFlowAct was changed to gsi. But original cFlowAct CASA was writing fluxOrder. So; in biomascat; the fields do not exist & this block of code will not work.
    for jix in 1:length(fluxOrder)
        fO = fluxOrder[jix]
        take_r = taker[fO]
        give_r = giver[fO]
        cEcoFlow[take_r] = cEcoFlow[take_r] + cEcoOut[give_r] * p_A[take_r, give_r]
    end
    # for jix = 1:length(p_taker)
    # taker = p_taker[jix]
    # giver = p_giver[jix]
    # c_flow = p_A(taker, giver)
    # take_flow = cEcoFlow[taker]
    # give_flow = cEcoOut[giver]
    # cEcoFlow[taker] = take_flow + give_flow * c_flow
    # end
    ## balance
    cEco .= cEco .+ cEcoFlow .+ cEcoInflux .- cEcoOut
    ## compute RA & RH
    del_cEco = cEco - cEco_prev
    NPP = sum(cNPP)
    backNEP = sum(cEco) - sum(cEco_prev)
    cRA = gpp - NPP
    cRECO = gpp - backNEP
    cRH = cRECO - cRA
    NEE = cRECO - gpp
    cEco_prev = copy(land.pools.cEco)

    ## pack land variables
    @pack_land begin
        (NEE, NPP, cRA, cRECO, cRH) => land.fluxes
        (cEcoEfflux, cEcoFlow, cEcoInflux, cEcoOut, cNPP, del_cEco, cEco_prev) => land.states
    end
    return land
end

@doc """
Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

---

# compute:
Allocate carbon to vegetation components using cCycle_simple

*Inputs*
 - helpers.dates.nStepsYear: number of time steps per year
 - land.cCycleBase.p_annk: carbon allocation matrix
 - land.cFlow.p_E: effect of soil & vegetation on transfer efficiency between pools
 - land.cFlow.p_giver: giver pool array
 - land.cFlow.p_taker: taker pool array
 - land.fluxes.gpp: values for gross primary productivity
 - land.states.cAlloc: carbon allocation matrix

*Outputs*
 - land.cCycleBase.p_k: decay rates for the carbon pool at each time step
 - land.fluxes.cNPP: values for net primary productivity
 - land.fluxes.cRA: values for autotrophic respiration
 - land.fluxes.cRECO: values for ecosystem respiration
 - land.fluxes.cRH: values for heterotrophic respiration
 - land.pools.cEco: values for the different carbon pools
 - land.states.cEcoEfflux:

# precompute:
precompute/instantiate time-invariant variables for cCycle_simple


---

# Extended help

*References*
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions*
 - 1.0 on 28.02.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cCycle_simple