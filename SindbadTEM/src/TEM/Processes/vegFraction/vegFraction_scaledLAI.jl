export vegFraction_scaledLAI

#! format: off
@bounds @describe @units @timescale @with_kw struct vegFraction_scaledLAI{T1} <: vegFraction
    LAIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for LAI" | "" | ""
end
#! format: on

function compute(params::vegFraction_scaledLAI, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_scaledLAI params

    ## unpack land variables
    @unpack_nt begin
        LAI ⇐ land.states
    end

    ## calculate variables
    frac_vegetation = minOne(LAI * LAIscale)

    ## pack land variables
    @pack_nt frac_vegetation ⇒ land.states
    return land
end

purpose(::Type{vegFraction_scaledLAI}) = "Vegetation fraction as a linear function of LAI."

@doc """

$(getProcessDocstring(vegFraction_scaledLAI))

---

# Extended help

*References*

*Versions*
 - 1.1 on 24.10.2020 [ttraut]: new module  

*Created by*
 - sbesnard
"""
vegFraction_scaledLAI
