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

purpose(::Type{groundWRecharge_kUnsat}) = "GW recharge as the unsaturated hydraulic conductivity of the lowermost soil layer"

@doc """

$(getModelDocString(groundWRecharge_kUnsat))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up  

*Created by*
 - skoirala | @dr-ko
"""
groundWRecharge_kUnsat
