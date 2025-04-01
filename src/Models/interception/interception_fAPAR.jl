export interception_fAPAR

#! format: off
@bounds @describe @units @timescale @with_kw struct interception_fAPAR{T1} <: interception
    isp::T1 = 1.0 | (0.1, 5.0) | "fapar dependent storage" | "" | ""
end
#! format: on

function compute(params::interception_fAPAR, forcing, land, helpers)
    ## unpack parameters
    @unpack_interception_fAPAR params

    ## unpack land variables
    @unpack_nt begin
        (WBP, fAPAR) ⇐ land.states
        rain ⇐ land.fluxes
    end
    # calculate interception loss
    interception_capacity = isp * fAPAR
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

purpose(::Type{interception_fAPAR}) = "computes canopy interception evaporation as a fraction of fAPAR"

@doc """

$(getBaseDocString(interception_fAPAR))

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 29.11.2019 [`skoirala | @dr-ko`]: land.states.fAPAR  

*Created by*
 - mjung
"""
interception_fAPAR
