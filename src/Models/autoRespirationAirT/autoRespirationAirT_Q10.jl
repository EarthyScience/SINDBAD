export autoRespirationAirT_Q10

#! format: off
@bounds @describe @units @timescale @with_kw struct autoRespirationAirT_Q10{T1,T2,T3} <: autoRespirationAirT
    Q10::T1 = 2.0 | (1.05, 3.0) | "Q10 parameter for maintenance respiration" | "" | ""
    ref_airT::T2 = 20.0 | (0.0, 40.0) | "Reference temperature for the maintenance respiration" | "°C" | ""
    Q10_base::T3 = 10.0 | (-Inf, Inf) | "base temperature difference" | "°C" | ""
end
#! format: on

function compute(params::autoRespirationAirT_Q10, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_autoRespirationAirT_Q10 params
    @unpack_nt f_airT ⇐ forcing

    ## calculate variables
    auto_respiration_f_airT = Q10^((f_airT - ref_airT) / Q10_base)

    ## pack land variables
    @pack_nt begin
        auto_respiration_f_airT ⇒ land.diagnostics
    end
    return land
end

@doc """
temperature effect on autotrophic maintenance respiration - Q10 model

# Parameters
$(SindbadParameters)

---

# compute:
Temperature effect on autotrophic maintenance respiration using autoRespirationAirT_Q10

*Inputs*
 - forcing.f_airT: air temperature [°C]

*Outputs*
 - land.diagnostics.auto_respiration_f_airT: autotrophic respiration rate [gC.m-2.δT-1]

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
autoRespirationAirT_Q10
