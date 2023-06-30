export cCycle_GSI

struct cCycle_GSI <: cCycle end

function define(o::cCycle_GSI, forcing, land, helpers)
    @unpack_land begin
        (𝟘, 𝟙, numType) ∈ helpers.numbers
    end
    ## instantiate variables
    cEcoFlow = zero(land.pools.cEco)
    cEcoOut = zero(land.pools.cEco)
    cEcoInflux = zero(land.pools.cEco)
    zerocEcoFlow = zero(cEcoFlow)
    zerocEcoInflux = zero(cEcoInflux)
    cNPP = zero(land.pools.cEco)

    cEco_prev = deepcopy(land.pools.cEco)
    ## pack land variables
    NEE = 𝟘
    NPP = 𝟘
    cRA = 𝟘
    cRECO = 𝟘
    cRH = 𝟘

    @pack_land begin
        (cEcoFlow, cEcoInflux, cEcoOut, cEco_prev, cNPP, zerocEcoFlow, zerocEcoInflux) =>
            land.states
        (NEE, NPP, cRA, cRECO, cRH) => land.fluxes
    end
    return land
end

function compute(o::cCycle_GSI, forcing, land, helpers)

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
            p_A,
            zerocEcoFlow,
            zerocEcoInflux) ∈ land.states
        (cVeg,
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
        ΔcEco ∈ land.states
        gpp ∈ land.fluxes
        (flowOrder, giver, taker) ∈ land.cCycleBase
        (𝟘, 𝟙, numType) ∈ helpers.numbers
    end
    ## reset ecoflow and influx to be zero at every time step
    @rep_vec cEcoFlow => helpers.pools.zeros.cEco
    @rep_vec cEcoInflux => helpers.pools.zeros.cEco
    # @rep_vec ΔcEco => ΔcEco .* 𝟘

    ## compute losses
    for cl ∈ eachindex(cEco)
        cEcoOut_cl = min(cEco[cl], cEco[cl] * p_k[cl])
        @rep_elem cEcoOut_cl => (cEcoOut, cl, :cEco)
    end

    ## gains to vegetation
    for zv ∈ getzix(land.pools.cVeg, helpers.pools.zix.cVeg)
        cNPP_zv = gpp * cAlloc[zv] - cEcoEfflux[zv]
        @rep_elem cNPP_zv => (cNPP, zv, :cEco)
        @rep_elem cNPP_zv => (cEcoInflux, zv, :cEco)
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
        tmp_flow = cEcoFlow[take_r] + cEcoOut[give_r] * p_A[fO]
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
    for cl ∈ eachindex(cEco)
        ΔcEco_cl = cEcoFlow[cl] + cEcoInflux[cl] - cEcoOut[cl]
        @add_to_elem ΔcEco_cl => (ΔcEco, cl, :cEco)
        cEco_cl = cEco[cl] + cEcoFlow[cl] + cEcoInflux[cl] - cEcoOut[cl]
        @rep_elem cEco_cl => (cEco, cl, :cEco)
    end

    ## compute RA & RH
    NPP = addS(cNPP)
    backNEP = addS(cEco) - addS(cEco_prev)
    cRA = gpp - NPP
    cRECO = gpp - backNEP
    cRH = cRECO - cRA
    NEE = cRECO - gpp

    # cEco_prev = cEco 
    # cEco_prev = cEco_prev .* 𝟘 .+ cEco
    @rep_vec cEco_prev => cEco

    # set_component_from_main_pool(land, helpers, helpers.pools.vals.self.cEco, helpers.pools.vals.all_components.cEco, helpers.pools.vals.zix.cEco)

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

    ## pack land variables
    @pack_land begin
        (cVeg,
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
        (NEE, NPP, cRA, cRECO, cRH) => land.fluxes
        (ΔcEco, cEcoEfflux, cEcoFlow, cEcoInflux, cEcoOut, cNPP, cEco_prev) => land.states
    end
    return land
end

function adj_component_pools(comp, full, pool_name, indx, helpers)
    i_c = 1
    for i_f ∈ indx
        @rep_elem full[i_f] => (comp, i_c, pool_name)
        i_c = i_c + 1
    end
    return comp
end

@doc """
Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

---

# compute:
Allocate carbon to vegetation components using cCycle_GSI

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
instantiate/instantiate time-invariant variables for cCycle_GSI


---

# Extended help

*References*
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions*
 - 1.0 on 28.02.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cCycle_GSI
