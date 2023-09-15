export cTauSoilT_Q10

#! format: off
@bounds @describe @units @with_kw struct cTauSoilT_Q10{T1,T2,T3} <: cTauSoilT
    Q10::T1 = 1.4 | (1.05, 3.0) | "" | ""
    Tref::T2 = 30.0 | (0.01, 40.0) | "" | "°C"
    Q10_base::T3 = 10.0 | (-Inf, Inf) | "base temperature difference" | "°C"
end
#! format: on

function compute(p_struct::cTauSoilT_Q10, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_cTauSoilT_Q10 p_struct
    @unpack_forcing Tair ∈ forcing

    ## calculate variables
    # CALCULATE EFFECT OF TEMPERATURE ON SOIL CARBON FLUXES
    c_eco_k_f_soilT = Q10^((Tair - Tref) / Q10_base)

    ## pack land variables
    @pack_land c_eco_k_f_soilT => land.cTauSoilT
    return land
end

@doc """
Compute effect of temperature on psoil carbon fluxes

# Parameters
$(SindbadParameters)

---

# compute:
Effect of soil temperature on decomposition rates using cTauSoilT_Q10

*Inputs*
 - forcing.Tair: values for air temperature

*Outputs*
 - land.cTauSoilT.c_eco_k_f_soilT: air temperature stressor on turnover rates [k]

---

# Extended help

*References*

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais

*Notes*
"""
cTauSoilT_Q10
