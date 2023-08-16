export cCycle_simple

struct cCycle_simple <: cCycle end

function define(p_struct::cCycle_simple, forcing, land, helpers)
    @unpack_land begin
        (z_zero, o_one) ∈ land.wCycleBase
    end
    n_cEco = length(land.pools.cEco)
    n_cVeg = length(land.pools.cVeg)
    ## instantiate variables
    c_eco_flow = zero(land.pools.cEco)
    c_eco_out = zero(land.pools.cEco)
    c_eco_influx = zero(land.pools.cEco)
    zero_c_eco_flow = zero(c_eco_flow)
    zero_c_eco_influx = zero(c_eco_influx)
    c_eco_npp = zero(land.pools.cEco)

    cEco_prev = copy(land.pools.cEco)
    zixVeg = getZix(land.pools.cVeg, helpers.pools.zix.cVeg)
    ## pack land variables
    nee = z_zero
    npp = z_zero
    auto_respiration = z_zero
    eco_respiration = z_zero
    hetero_respiration = z_zero

    @pack_land begin
        (c_eco_flow, c_eco_influx, c_eco_out, cEco_prev, c_eco_npp, zixVeg, zero_c_eco_flow, zero_c_eco_influx) =>
            land.states
        (nee, npp, auto_respiration, eco_respiration, hetero_respiration) => land.fluxes
    end
    return land
end

function compute(p_struct::cCycle_simple, forcing, land, helpers)

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
            zixVeg,
            zero_c_eco_flow,
            zero_c_eco_influx) ∈ land.states
        cEco ∈ land.pools
        ΔcEco ∈ land.states
        gpp ∈ land.fluxes
        (c_flow_A_vec, c_giver, c_taker) ∈ land.cFlow
        (c_flow_order) ∈ land.cCycleBase
        (z_zero, o_one) ∈ land.wCycleBase
    end
    ## reset ecoflow and influx to be zero at every time step
    c_eco_flow = zero_c_eco_flow .* z_zero
    c_eco_influx = c_eco_influx
    ## compute losses
    c_eco_out = min.(cEco, cEco .* c_eco_k)

    ## gains to vegetation
    for zv ∈ zixVeg
        @rep_elem gpp * c_allocation[zv] - c_eco_efflux[zv] => (c_eco_npp, zv, :cEco)
        @rep_elem c_eco_npp[zv] => (c_eco_influx, zv, :cEco)
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
        tmp_flow = c_eco_flow[take_r] + c_eco_out[give_r] * c_flow_A_vec[take_r, give_r]
        @rep_elem tmp_flow => (c_eco_flow, take_r, :cEco)
    end
    # for jix = 1:length(p_taker)
    # c_taker = p_taker[jix]
    # c_giver = p_giver[jix]
    # c_flow = c_flow_A_vec(c_taker, c_giver)
    # take_flow = c_eco_flow[c_taker]
    # give_flow = c_eco_out[c_giver]
    # c_eco_flow[c_taker] = take_flow + give_flow * c_flow
    # end
    ## balance
    ΔcEco = c_eco_flow .+ c_eco_influx .- c_eco_out
    cEco = cEco .+ c_eco_flow .+ c_eco_influx .- c_eco_out

    ## compute RA & RH
    npp = sum(c_eco_npp)
    backNEP = sum(cEco) - sum(cEco_prev)
    auto_respiration = gpp - npp
    eco_respiration = gpp - backNEP
    hetero_respiration = eco_respiration - auto_respiration
    nee = eco_respiration - gpp
    cEco_prev = cEco

    land = upd_c(land, cEco, helpers)
    ## pack land variables
    @pack_land begin
        cEco => land.pools
        (nee, npp, auto_respiration, eco_respiration, hetero_respiration) => land.fluxes
        (ΔcEco, c_eco_efflux, c_eco_flow, c_eco_influx, c_eco_out, c_eco_npp, cEco_prev) => land.states
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
