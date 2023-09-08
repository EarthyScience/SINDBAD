export cCycle_GSI

struct cCycle_GSI <: cCycle end

function define(p_struct::cCycle_GSI, forcing, land, helpers)
    ## instantiate variables
    c_eco_flow = zero(land.pools.cEco)
    c_eco_out = zero(land.pools.cEco)
    c_eco_influx = zero(land.pools.cEco)
    zero_c_eco_flow = zero(c_eco_flow)
    zero_c_eco_influx = zero(c_eco_influx)
    ΔcEco = zero(land.pools.cEco)
    c_eco_npp = zero(land.pools.cEco)

    cEco_prev = land.pools.cEco
    ## pack land variables

    @pack_land begin
        (c_eco_flow, c_eco_influx, c_eco_out, cEco_prev, c_eco_npp, zero_c_eco_flow, zero_c_eco_influx, ΔcEco) =>
            land.states
    end
    return land
end

function compute(p_struct::cCycle_GSI, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (c_allocation,
            c_eco_efflux,
            c_eco_flow,
            c_eco_influx,
            cEco_prev,
            c_eco_out,
            c_eco_npp,
            c_eco_k,
            c_flow_A_vec,
            zero_c_eco_flow,
            zero_c_eco_influx) ∈ land.states
        cEco ∈ land.pools
        ΔcEco ∈ land.states
        gpp ∈ land.fluxes
        (c_flow_order, c_giver, c_taker) ∈ land.cCycleBase
    end
    ## reset ecoflow and influx to be zero at every time step
    @rep_vec c_eco_flow => helpers.pools.zeros.cEco
    @rep_vec c_eco_influx => helpers.pools.zeros.cEco
    # @rep_vec ΔcEco => ΔcEco .* z_zero

    ## compute losses
    c_eco_out = inner_eco_out(cEco, c_eco_k, c_eco_out, helpers)

    ## gains to vegetation
    _pools = land.pools
    _zix_pools = helpers.pools.zix

    c_eco_npp, c_eco_influx = inner_eco_fluxes(
        c_eco_npp,
        c_eco_influx,
        gpp,
        c_allocation,
        c_eco_efflux,
        _pools,
        _zix_pools,
        helpers)

    # flows & losses
    # @nc; if flux order does not matter; remove# sujanq: this was deleted by simon in the version of 2020-11. Need to
    # find out why. Led to having zeros in most of the carbon pools of the
    # explicit simple
    # old before cleanup was removed during biomascat when cFlowAct was changed to gsi. But original cFlowAct CASA was writing c_flow_order. So; in biomascat; the fields do not exist & this block of code will not work.
    c_eco_flow = inner_eco_flow(
        c_flow_order,
        c_eco_flow, 
        c_taker,
        c_giver,
        c_eco_out,
        c_flow_A_vec,
        helpers)
    # for jix = 1:length(p_taker)
    # c_taker = p_taker[jix]
    # c_giver = p_giver[jix]
    # c_flow = c_flow_A_vec(c_taker, c_giver)
    # take_flow = c_eco_flow[c_taker]
    # give_flow = c_eco_out[c_giver]
    # c_eco_flow[c_taker] = take_flow + give_flow * c_flow
    # end
    
    ## balance

    cEco, ΔcEco = inner_eco_balance(cEco, ΔcEco, c_eco_flow, c_eco_influx, c_eco_out, helpers)

    ## compute RA & RH
    npp = totalS(c_eco_npp)
    backNEP = totalS(cEco) - totalS(cEco_prev)
    auto_respiration = gpp - npp
    eco_respiration = gpp - backNEP
    hetero_respiration = eco_respiration - auto_respiration
    nee = eco_respiration - gpp

    # cEco_prev = cEco 
    # cEco_prev = cEco_prev .*z_zero.+ cEco
    @rep_vec cEco_prev => cEco
    @pack_land cEco => land.pools

    land = adjustPackPoolComponents(land, helpers, land.cCycleBase.c_model)
    # setComponentFromMainPool(land, helpers, helpers.pools.vals.self.cEco, helpers.pools.vals.all_components.cEco, helpers.pools.vals.zix.cEco)

    ## pack land variables
    @pack_land begin
        (nee, npp, auto_respiration, eco_respiration, hetero_respiration) => land.fluxes
        (ΔcEco, c_eco_efflux, c_eco_flow, c_eco_influx, c_eco_out, c_eco_npp, cEco_prev) => land.states
    end
    return land
end

function inner_eco_out(cEco, c_eco_k, c_eco_out, helpers)
    for cl ∈ eachindex(cEco)
        c_eco_out_cl = min(cEco[cl], cEco[cl] * c_eco_k[cl])
        @rep_elem c_eco_out_cl => (c_eco_out, cl, :cEco)
    end
    return c_eco_out
end

function inner_eco_fluxes(c_eco_npp, c_eco_influx, gpp, c_allocation, c_eco_efflux, _pools, _zix_pools, helpers)
    for zv ∈ getZix(_pools.cVeg, _zix_pools.cVeg) # land.pools.cVeg, helpers.pools.zix.cVeg
        c_eco_npp_zv = gpp * c_allocation[zv] - c_eco_efflux[zv]
        @rep_elem c_eco_npp_zv => (c_eco_npp, zv, :cEco)
        @rep_elem c_eco_npp_zv => (c_eco_influx, zv, :cEco)
    end
    return c_eco_npp, c_eco_influx
end

function inner_eco_flow(c_flow_order, c_eco_flow,  c_taker, c_giver, c_eco_out, c_flow_A_vec, helpers)
    for fO ∈ c_flow_order
        take_r = c_taker[fO]
        give_r = c_giver[fO]
        tmp_flow = c_eco_flow[take_r] + c_eco_out[give_r] * c_flow_A_vec[fO]
        @rep_elem tmp_flow => (c_eco_flow, take_r, :cEco)
    end
    return c_eco_flow
end

function inner_eco_balance(cEco, ΔcEco, c_eco_flow, c_eco_influx, c_eco_out, helpers)
    for cl ∈ eachindex(cEco)
        ΔcEco_cl = c_eco_flow[cl] + c_eco_influx[cl] - c_eco_out[cl]
        @add_to_elem ΔcEco_cl => (ΔcEco, cl, :cEco)
        cEco_cl = cEco[cl] + c_eco_flow[cl] + c_eco_influx[cl] - c_eco_out[cl]
        @rep_elem cEco_cl => (cEco, cl, :cEco)
    end
    return cEco, ΔcEco
end

@doc """
Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

---

# compute:
Allocate carbon to vegetation components using cCycle_GSI

*Inputs*
 - helpers.dates.timesteps_in_year: number of time steps per year
 - land.cCycleBase.c_τ_eco: carbon allocation matrix
 - land.cFlow.p_E_vec: effect of soil & vegetation on transfer efficiency between pools
 - land.cFlow.p_giver: c_giver pool array
 - land.cFlow.p_taker: c_taker pool array
 - land.fluxes.gpp: values for gross primary productivity
 - land.states.c_allocation: carbon allocation matrix

*Outputs*
 - land.cCycleBase.c_eco_k: decay rates for the carbon pool at each time step
 - land.fluxes.c_eco_npp: values for net primary productivity
 - land.fluxes.auto_respiration: values for autotrophic respiration
 - land.fluxes.eco_respiration: values for ecosystem respiration
 - land.fluxes.hetero_respiration: values for heterotrophic respiration
 - land.pools.cEco: values for the different carbon pools
 - land.states.c_eco_efflux:

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
