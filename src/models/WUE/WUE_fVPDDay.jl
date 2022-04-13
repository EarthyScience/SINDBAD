export WUE_fVPDDay, WUE_fVPDDay_h
"""
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct WUE_fVPDDay{T1} <: WUE
	WUEatOnehPa::T1 = 9.2 | (4.0, 17.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
end

function precompute(o::WUE_fVPDDay, forcing, land, infotem)
	# @unpack_WUE_fVPDDay o
	return land
end

function compute(o::WUE_fVPDDay, forcing, land, infotem)
	@unpack_WUE_fVPDDay o

	## unpack variables
	@unpack_land begin
		VPDDay ∈ forcing
	end
	# "WUEat1hPa"
	kpa_to_hpa = 10
	AoE = WUEatOnehPa * 1 / sqrt(kpa_to_hpa * (VPDDay +0.05))

	## pack variables
	@pack_land begin
		AoE ∋ land.WUE
	end
	return land
end

function update(o::WUE_fVPDDay, forcing, land, infotem)
	# @unpack_WUE_fVPDDay o
	return land
end

"""
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# precompute:
precompute/instantiate time-invariant variables for WUE_fVPDDay

# compute:
Estimate wue using WUE_fVPDDay

*Inputs:*
 - WUEat1hPa: the VPD at 1 hpa
 - forcing.VPDDay: daytime mean VPD [kPa]

*Outputs:*
 - land.WUE.AoE: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O]

# update
update pools and states in WUE_fVPDDay
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUEat1hPa  across fluxNet sites
 - Sujan Koirala [skoirala]
"""
function WUE_fVPDDay_h end