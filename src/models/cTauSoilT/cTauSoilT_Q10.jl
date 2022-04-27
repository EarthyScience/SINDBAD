export cTauSoilT_Q10

@bounds @describe @units @with_kw struct cTauSoilT_Q10{T1, T2} <: cTauSoilT
	Q10::T1 = 1.4 | (1.05, 3.0) | "" | ""
	Tref::T2 = 30.0 | (0.01, 40.0) | "" | "°C"
end

function compute(o::cTauSoilT_Q10, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters and forcing
	@unpack_cTauSoilT_Q10 o
	@unpack_forcing Tair ∈ forcing


	## calculate variables
	# CALCULATE EFFECT OF TEMPERATURE ON psoil CARBON FLUXES
	fT = Q10 ^ ((Tair - Tref) / 10.0)

	## pack land variables
	@pack_land fT => land.cTauSoilT
	return land
end

@doc """
Compute effect of temperature on psoil carbon fluxes

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of soil temperature on decomposition rates using cTauSoilT_Q10

*Inputs*
 - forcing.Tair: values for air temperature

*Outputs*
 - land.cTauSoilT.fT: air temperature stressor on turnover rates [k]

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