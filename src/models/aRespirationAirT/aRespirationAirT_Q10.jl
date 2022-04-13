export aRespirationAirT_Q10, aRespirationAirT_Q10_h
"""
estimate the effect of temperature in autotrophic maintenance respiration - q10 model

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct aRespirationAirT_Q10{T1, T2} <: aRespirationAirT
	Q10_RM::T1 = 2.0 | (1.05, 3.0) | "Q10 parameter for maintenance respiration" | ""
	Tref_RM::T2 = 20.0 | (0.0, 40.0) | "Reference temperature for the maintenance respiration" | "°C"
end

function precompute(o::aRespirationAirT_Q10, forcing, land, infotem)
	# @unpack_aRespirationAirT_Q10 o
	return land
end

function compute(o::aRespirationAirT_Q10, forcing, land, infotem)
	@unpack_aRespirationAirT_Q10 o

	## unpack variables
	@unpack_land begin
		Tair ∈ forcing
	end
	fT = Q10_RM ^ ((Tair - Tref_RM) / 10.0)

	## pack variables
	@pack_land begin
		fT ∋ land.aRespirationAirT
	end
	return land
end

function update(o::aRespirationAirT_Q10, forcing, land, infotem)
	# @unpack_aRespirationAirT_Q10 o
	return land
end

"""
estimate the effect of temperature in autotrophic maintenance respiration - q10 model

# precompute:
precompute/instantiate time-invariant variables for aRespirationAirT_Q10

# compute:
Temperature effect on autotrophic maintenance respiration using aRespirationAirT_Q10

*Inputs:*
 - forcing.Tair: air temperature [°C]

*Outputs:*
 - land.aRespirationAirT.fT: autotrophic respiration rate [gC.m-2.δT-1]

# update
update pools and states in aRespirationAirT_Q10
 -

# Extended help

*References:*
 - Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.
 - Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
 - Thornley, J. H. M., & M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation & realism, Ann Bot-London, 85[1]  55-67.

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]

*Notes:*
"""
function aRespirationAirT_Q10_h end