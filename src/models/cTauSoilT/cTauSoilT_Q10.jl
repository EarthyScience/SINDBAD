export cTauSoilT_Q10, cTauSoilT_Q10_h
"""
Compute effect of temperature on psoil carbon fluxes

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTauSoilT_Q10{T1, T2} <: cTauSoilT
	Q10::T1 = 1.4 | (1.05, 3.0) | "" | ""
	Tref::T2 = 30.0 | (0.01, 40.0) | "" | "°C"
end

function precompute(o::cTauSoilT_Q10, forcing, land, infotem)
	# @unpack_cTauSoilT_Q10 o
	return land
end

function compute(o::cTauSoilT_Q10, forcing, land, infotem)
	@unpack_cTauSoilT_Q10 o

	## unpack variables
	@unpack_land begin
		Tair ∈ forcing
	end
	# CALCULATE EFFECT OF TEMPERATURE ON psoil CARBON FLUXES
	fT = Q10 ^ ((Tair - Tref) / 10.0)

	## pack variables
	@pack_land begin
		fT ∋ land.cTauSoilT
	end
	return land
end

function update(o::cTauSoilT_Q10, forcing, land, infotem)
	# @unpack_cTauSoilT_Q10 o
	return land
end

"""
Compute effect of temperature on psoil carbon fluxes

# precompute:
precompute/instantiate time-invariant variables for cTauSoilT_Q10

# compute:
Effect of soil temperature on decomposition rates using cTauSoilT_Q10

*Inputs:*
 - forcing.Tair: values for air temperature

*Outputs:*
 - land.cTauSoilT.fT: air temperature stressor on turnover rates [k]

# update
update pools and states in cTauSoilT_Q10
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais

*Notes:*
"""
function cTauSoilT_Q10_h end