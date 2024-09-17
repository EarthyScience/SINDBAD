export interception_vegFraction

#! format: off
@bounds @describe @units @with_kw struct interception_vegFraction{T1} <: interception
    p_interception::T1 = 1.0 | (0.0001, 5.0) | "maximum interception storage" | "mm"
end
#! format: on

function compute(params::interception_vegFraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_interception_vegFraction params

    ## unpack land variables
    @unpack_nt begin
        (WBP, frac_vegetation) ⇐ land.states
        rain ⇐ land.fluxes
    end
    # calculate interception loss
    interception_capacity = p_interception * frac_vegetation
    interception = min(interception_capacity, rain)
    # update the available water
    WBP = WBP - interception

    ## pack land variables
    @pack_nt begin
        interception ⇒ land.fluxes
        WBP ⇒ land.states
    end
    return land
end

@doc """
computes canopy interception evaporation as a fraction of vegetation cover

# Parameters
$(SindbadParameters)

---

# compute:
Interception evaporation using interception_vegFraction

*Inputs*
 - land.states.frac_vegetation

*Outputs*
 -
 - land.states.WBP: updates the water balance pool [mm]

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 27.11.2019 [skoiralal]: moved contents from prec, handling of frac_vegetation from s.cd  

*Created by:*
 - ttraut
"""
interception_vegFraction
