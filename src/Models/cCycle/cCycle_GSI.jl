export cCycle_GSI

struct cCycle_GSI <: cCycle end

function define(p_struct::cCycle_GSI, forcing, land, helpers)
    @unpack_land begin
        (𝟘, 𝟙, num_type) ∈ helpers.numbers
    end
    ## instantiate variables
    c_eco_flow = zero(land.pools.cEco)
    c_eco_out = zero(land.pools.cEco)
    c_eco_influx = zero(land.pools.cEco)
    zero_c_eco_flow = zero(c_eco_flow)
    zero_c_eco_influx = zero(c_eco_influx)
    c_eco_npp = zero(land.pools.cEco)

    cEco_prev = deepcopy(land.pools.cEco)
    ## pack land variables
    nee = 𝟘
    npp = 𝟘
    auto_respiration = 𝟘
    eco_respiration = 𝟘
    hetero_respiration = 𝟘

    @pack_land begin
        (c_eco_flow, c_eco_influx, c_eco_out, cEco_prev, c_eco_npp, zero_c_eco_flow, zero_c_eco_influx) =>
            land.states
        (nee, npp, auto_respiration, eco_respiration, hetero_respiration) => land.fluxes
    end
    return land
end

function compute(p_struct::cCycle_GSI, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (c_allocation,
            c_efflux,
            c_eco_flow,
            c_eco_influx,
            cEco_prev,
            c_eco_out,
            c_eco_npp,
            p_k,
            p_A,
            zero_c_eco_flow,
            zero_c_eco_influx) ∈ land.states
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
        (c_flow_order, c_giver, c_taker) ∈ land.cCycleBase
        (𝟘, 𝟙, num_type) ∈ helpers.numbers
    end
    ## reset ecoflow and influx to be zero at every time step
    @rep_vec c_eco_flow => helpers.pools.zeros.cEco
    @rep_vec c_eco_influx => helpers.pools.zeros.cEco
    # @rep_vec ΔcEco => ΔcEco .* 𝟘

    ## compute losses
    for cl ∈ eachindex(cEco)
        c_eco_out_cl = min(cEco[cl], cEco[cl] * p_k[cl])
        @rep_elem c_eco_out_cl => (c_eco_out, cl, :cEco)
    end

    ## gains to vegetation
    for zv ∈ getzix(land.pools.cVeg, helpers.pools.zix.cVeg)
        c_eco_npp_zv = gpp * c_allocation[zv] - c_efflux[zv]
        @rep_elem c_eco_npp_zv => (c_eco_npp, zv, :cEco)
        @rep_elem c_eco_npp_zv => (c_eco_influx, zv, :cEco)
    end

    # flows & losses
    # @nc; if flux order does not matter; remove# sujanq: this was deleted by simon in the version of 2020-11. Need to
    # find out why. Led to having zeros in most of the carbon pools of the
    # explicit simple
    # old before cleanup was removed during biomascat when cFlowAct was changed to gsi. But original cFlowAct CASA was writing c_flow_order. So; in biomascat; the fields do not exist & this block of code will not work.
    for jix ∈ eachindex(c_flow_order)
        fO = c_flow_order[jix]
        take_r = c_taker[fO]
        give_r = c_giver[fO]
        tmp_flow = c_eco_flow[take_r] + c_eco_out[give_r] * p_A[fO]
        @rep_elem tmp_flow => (c_eco_flow, take_r, :cEco)
    end
    # for jix = 1:length(p_taker)
    # c_taker = p_taker[jix]
    # c_giver = p_giver[jix]
    # c_flow = p_A(c_taker, c_giver)
    # take_flow = c_eco_flow[c_taker]
    # give_flow = c_eco_out[c_giver]
    # c_eco_flow[c_taker] = take_flow + give_flow * c_flow
    # end
    ## balance
    for cl ∈ eachindex(cEco)
        ΔcEco_cl = c_eco_flow[cl] + c_eco_influx[cl] - c_eco_out[cl]
        @add_to_elem ΔcEco_cl => (ΔcEco, cl, :cEco)
        cEco_cl = cEco[cl] + c_eco_flow[cl] + c_eco_influx[cl] - c_eco_out[cl]
        @rep_elem cEco_cl => (cEco, cl, :cEco)
    end

    ## compute RA & RH
    npp = addS(c_eco_npp)
    backNEP = addS(cEco) - addS(cEco_prev)
    auto_respiration = gpp - npp
    eco_respiration = gpp - backNEP
    hetero_respiration = eco_respiration - auto_respiration
    nee = eco_respiration - gpp

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
        (nee, npp, auto_respiration, eco_respiration, hetero_respiration) => land.fluxes
        (ΔcEco, c_efflux, c_eco_flow, c_eco_influx, c_eco_out, c_eco_npp, cEco_prev) => land.states
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
 - helpers.dates.timesteps_in_year: number of time steps per year
 - land.cCycleBase.p_annk: carbon allocation matrix
 - land.cFlow.p_E: effect of soil & vegetation on transfer efficiency between pools
 - land.cFlow.p_giver: c_giver pool array
 - land.cFlow.p_taker: c_taker pool array
 - land.fluxes.gpp: values for gross primary productivity
 - land.states.c_allocation: carbon allocation matrix

*Outputs*
 - land.cCycleBase.p_k: decay rates for the carbon pool at each time step
 - land.fluxes.c_eco_npp: values for net primary productivity
 - land.fluxes.auto_respiration: values for autotrophic respiration
 - land.fluxes.eco_respiration: values for ecosystem respiration
 - land.fluxes.hetero_respiration: values for heterotrophic respiration
 - land.pools.cEco: values for the different carbon pools
 - land.states.c_efflux:

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
