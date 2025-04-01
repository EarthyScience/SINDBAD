export runoffInfiltrationExcess_kUnsat

struct runoffInfiltrationExcess_kUnsat <: runoffInfiltrationExcess end

function compute(params::runoffInfiltrationExcess_kUnsat, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        WBP ⇐ land.states
        unsat_k_model ⇐ land.models
        (z_zero, o_one) ⇐ land.constants
    end
    # get the unsaturated hydraulic conductivity based on soil properties for the first soil layer
    k_unsat = unsatK(land, helpers, 1, unsat_k_model)
    # minimum of the conductivity & the incoming water
    inf_excess_runoff = maxZero(WBP - k_unsat)
    # update remaining water
    WBP = WBP - inf_excess_runoff

    ## pack land variables
    @pack_nt begin
        inf_excess_runoff ⇒ land.fluxes
        WBP ⇒ land.states
    end
    return land
end

purpose(::Type{runoffInfiltrationExcess_kUnsat}) = "infiltration excess runoff based on unsaτurated hydraulic conductivity"

@doc """

$(getBaseDocString(runoffInfiltrationExcess_kUnsat))

---

# Extended help

*References*

*Versions*
 - 1.0 on 23.11.2019 [`skoirala | @dr-ko`]

*Created by*
 - `skoirala | @dr-ko`
"""
runoffInfiltrationExcess_kUnsat
