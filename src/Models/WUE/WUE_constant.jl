export WUE_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct WUE_constant{T1} <: WUE
    constant_WUE::T1 = 4.1 | (1.0, 10.0) | "mean FluxNet WUE" | "gC/mmH2O" | ""
end
#! format: on

function precompute(params::WUE_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_WUE_constant params

    ## calculate variables
    WUE = constant_WUE

    ## pack land variables
    @pack_nt WUE ⇒ land.diagnostics
    return land
end

purpose(::Type{WUE_constant}) = "calculates the WUE/AOE as a constant in space & time"

@doc """

$(getBaseDocString(WUE_constant))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [`skoirala | @dr-ko`]

*Created by*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUE across fluxNet  sites
 - `skoirala | @dr-ko`
"""
WUE_constant
