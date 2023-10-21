export WUE_constant

#! format: off
@bounds @describe @units @with_kw struct WUE_constant{T1} <: WUE
    constant_WUE::T1 = 4.1 | (1.0, 10.0) | "mean FluxNet WUE" | "gC/mmH2O"
end
#! format: on

function compute(params::WUE_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_WUE_constant params

    ## calculate variables
    WUE = constant_WUE

    ## pack land variables
    @pack_land WUE → land.diagnostics
    return land
end

@doc """
calculates the WUE/AOE as a constant in space & time

# Parameters
$(SindbadParameters)

---

# compute:
Estimate wue using WUE_constant

*Inputs*

*Outputs*
 - land.diagnostics.WUE: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O]

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUE across fluxNet  sites
 - skoirala
"""
WUE_constant
