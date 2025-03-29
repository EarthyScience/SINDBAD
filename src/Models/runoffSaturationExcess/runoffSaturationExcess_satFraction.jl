export runoffSaturationExcess_satFraction

struct runoffSaturationExcess_satFraction <: runoffSaturationExcess end

function compute(params::runoffSaturationExcess_satFraction, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt (WBP, satFrac) ⇐ land.states

    ## calculate variables
    sat_excess_runoff = WBP * satFrac

    # update the WBP
    WBP = WBP - sat_excess_runoff

    ## pack land variables
    @pack_nt begin
        sat_excess_runoff ⇒ land.fluxes
        WBP ⇒ land.states
    end
    return land
end

purpose(::Type{runoffSaturationExcess_satFraction}) = "saturation excess runoff as a fraction of saturated fraction of land"

@doc """

$(getBaseDocString(runoffSaturationExcess_satFraction))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala

*Notes*
 - only works if soilWSatFrac module is activated
"""
runoffSaturationExcess_satFraction
