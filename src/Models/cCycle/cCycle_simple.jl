export cCycle_simple

struct cCycle_simple <: cCycle end

function define(o::cCycle_simple, forcing, land, helpers)
    @unpack_land begin
        (𝟘, 𝟙, num_type) ∈ helpers.numbers
    end
    n_cEco = length(land.pools.cEco)
    n_cVeg = length(land.pools.cVeg)
    ## instantiate variables
    cEcoFlow = zero(land.pools.cEco)
    cEcoOut = zero(land.pools.cEco)
    cEcoInflux = zero(land.pools.cEco)
    zerocEcoFlow = zero(cEcoFlow)
    zerocEcoInflux = zero(cEcoInflux)
    cNPP = zero(land.pools.cEco)

    cEco_prev = copy(land.pools.cEco)
    zixVeg = getzix(land.pools.cVeg, helpers.pools.zix.cVeg)
    ## pack land variables
    NEE = 𝟘
    NPP = 𝟘
    cRA = 𝟘
    cRECO = 𝟘
    cRH = 𝟘

    @pack_land begin
        (cEcoFlow, cEcoInflux, cEcoOut, cEco_prev, cNPP, zixVeg, zerocEcoFlow, zerocEcoInflux) =>
            land.states
        (NEE, NPP, cRA, cRECO, cRH) => land.fluxes
    end
    return land
end

function compute(o::cCycle_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (cAlloc,
            cEcoEfflux,
            cEcoFlow,
            cEcoInflux,
            cEco_prev,
            cEcoOut,
            cNPP,
            p_k,
            zixVeg,
            zerocEcoFlow,
            zerocEcoInflux) ∈ land.states
        cEco ∈ land.pools
        ΔcEco ∈ land.states
        gpp ∈ land.fluxes
        (p_A, giver, taker) ∈ land.cFlow
        (flowOrder) ∈ land.cCycleBase
        (𝟘, 𝟙, num_type) ∈ helpers.numbers
    end
    ## reset ecoflow and influx to be zero at every time step
    cEcoFlow = zerocEcoFlow .* 𝟘
    cEcoInflux = cEcoInflux
    ## compute losses
    cEcoOut = min.(cEco, cEco .* p_k)

    ## gains to vegetation
    for zv ∈ zixVeg
        @rep_elem gpp * cAlloc[zv] - cEcoEfflux[zv] => (cNPP, zv, :cEco)
        @rep_elem cNPP[zv] => (cEcoInflux, zv, :cEco)
    end

    # flows & losses
    # @nc; if flux order does not matter; remove# sujanq: this was deleted by simon in the version of 2020-11. Need to
    # find out why. Led to having zeros in most of the carbon pools of the
    # explicit simple
    # old before cleanup was removed during biomascat when cFlowAct was changed to gsi. But original cFlowAct CASA was writing flowOrder. So; in biomascat; the fields do not exist & this block of code will not work.
    for jix ∈ eachindex(flowOrder)
        fO = flowOrder[jix]
        take_r = taker[fO]
        give_r = giver[fO]
        tmp_flow = cEcoFlow[take_r] + cEcoOut[give_r] * p_A[take_r, give_r]
        @rep_elem tmp_flow => (cEcoFlow, take_r, :cEco)
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
    ΔcEco = cEcoFlow .+ cEcoInflux .- cEcoOut
    cEco = cEco .+ cEcoFlow .+ cEcoInflux .- cEcoOut

    ## compute RA & RH
    NPP = sum(cNPP)
    backNEP = sum(cEco) - sum(cEco_prev)
    cRA = gpp - NPP
    cRECO = gpp - backNEP
    cRH = cRECO - cRA
    NEE = cRECO - gpp
    cEco_prev = cEco

    land = upd_c(land, cEco, helpers)
    ## pack land variables
    @pack_land begin
        cEco => land.pools
        (NEE, NPP, cRA, cRECO, cRH) => land.fluxes
        (ΔcEco, cEcoEfflux, cEcoFlow, cEcoInflux, cEcoOut, cNPP, cEco_prev) => land.states
    end
    return land
end

function upd_c(land, cEco, tem_helpers)
    foreach(propertynames(tem_helpers.pools.zix)) do cv
        cp = getfield(land.pools, cv)
        cz = getfield(tem_helpers.pools.zix, cv)
        cp = cEco[cz]
        return land = Sindbad.setTupleSubfield(land, :pools, (cv, cp))
        # @show cv, cp, cz
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

# instantiate:
instantiate/instantiate time-invariant variables for cCycle_simple


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
