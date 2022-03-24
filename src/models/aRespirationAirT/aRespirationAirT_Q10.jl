export aRespirationAirT_Q10

@bounds @describe @units @with_kw struct aRespirationAirT_Q10{T1,T2,T3} <: aRespirationAirT
    Q10_RM::T1 = 2.0 | (1.05, 3.0) | "Q10 parameter for maintenance respiration" | ""
    Tref_RM::T2 = 20.0 | (0.0, 40.0) | "Reference temperature for the maintenance respiration" | "°C"
    Q10_base::T3 = 10.0 | (nothing, nothing) | "base temperature difference" | "°C"
end

function compute(o::aRespirationAirT_Q10, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters and forcing
    @unpack_aRespirationAirT_Q10 o
    @unpack_forcing Tair ∈ forcing

    ## calculate variables
    fT = Q10_RM^((Tair - Tref_RM) / Q10_base)

    ## pack land variables
    @pack_land fT => land.aRespirationAirT
    return land
end

@doc """
temperature effect on autotrophic maintenance respiration - Q10 model

# Parameters
$(PARAMFIELDS)

---

# compute:
Temperature effect on autotrophic maintenance respiration using aRespirationAirT_Q10

*Inputs*
 - forcing.Tair: air temperature [°C]

*Outputs*
 - land.aRespirationAirT.fT: autotrophic respiration rate [gC.m-2.δT-1]

---

# Extended help

*References*
 - Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.
 - Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
 - Thornley, J. H. M., & M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation & realism, Ann Bot-London, 85[1]  55-67.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: clean up  

*Created by:*
 - ncarval

*Notes*
"""
aRespirationAirT_Q10