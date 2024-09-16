export groundWRecharge_kUnsat

struct groundWRecharge_kUnsat <: groundWRecharge end

function compute(params::groundWRecharge_kUnsat, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        w_sat ⇐ land.properties
        unsat_k_model ⇐ land.models
        (ΔsoilW, soilW, ΔgroundW, groundW) ⇐ land.pools
        n_groundW ⇐ land.constants
    end

    # calculate recharge
    k_unsat = unsatK(land, helpers, lastindex(soilW), unsat_k_model)
    gw_recharge = min(k_unsat, soilW[end] + ΔsoilW[end])

    ΔgroundW .= ΔgroundW .+ gw_recharge / n_groundW
    ΔsoilW[end] = ΔsoilW[end] - gw_recharge

    ## pack land variables
    @pack_nt begin
        gw_recharge ⇒ land.fluxes
        (ΔsoilW, ΔgroundW) ⇒ land.pools
    end
    return land
end

function update(params::groundWRecharge_kUnsat, forcing, land, helpers)

    ## unpack variables
    @unpack_nt begin
        (soilW, groundW) ⇐ land.pools
        (ΔsoilW, ΔgroundW) ⇐ land.states
    end

    ## update storage pools
    soilW[end] = soilW[end] + ΔsoilW[end]
    groundW .= groundW .+ ΔgroundW

    # reset ΔsoilW[end] and ΔgroundW to zero
    ΔsoilW[end] = ΔsoilW[end] - ΔsoilW[end]
    ΔgroundW .= ΔgroundW .- ΔgroundW

    ## pack land variables
    @pack_nt begin
        (groundW, soilW) ⇒ land.pools
        (ΔsoilW, ΔgroundW) ⇒ land.pools
    end
    return land
end

@doc """
GW recharge as the unsaturated hydraulic conductivity of the lowermost soil layer

---

# compute:
Recharge the groundwater using groundWRecharge_kUnsat

*Inputs*
 - land.pools.soilW: soil moisture
 - land.soilProperties.unsatK: function to calculate unsaturated hydraulic conduct.
 - land.properties.w_sat: moisture at saturation

*Outputs*
 - land.fluxes.gw_recharge

# update

update pools and states in groundWRecharge_kUnsat

 - land.pools.groundW[1]
 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - skoirala
"""
groundWRecharge_kUnsat
